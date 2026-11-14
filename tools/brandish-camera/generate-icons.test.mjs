import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import { readPng, decodePng, encodePng, parseDmi, conversionPlan, generateVariant, generateForeground, generateViewGate, generate, directions, turnJunction, tile, squareGeometry, rotatePixels, allDirections, alignFootprint } from './generate-icons.mjs';

function fixture(description, frames, depth=8, color=6, chunks=[]) {
  const pixelBytes = color===6 ? 4 : 1;
  const header=Buffer.alloc(13); header.writeUInt32BE(2);header.writeUInt32BE(frames.length*2,4);header[8]=depth;header[9]=color;
  const metadata=`# BEGIN DMI\nversion = 4.0\nwidth = 2\nheight = 2\n${description}# END DMI\n`;
  return encodePng({header,depth,color,channels:pixelBytes,pixelBytes,chunks},Buffer.concat(frames),2,frames.length*2,metadata);
}
const colored=Buffer.from([255,0,0,255, 0,255,0,255, 0,0,255,255, 255,255,0,255]);
const description='state = "arrow"\n dirs = 1\n frames = 1\n';

test('surface directions rotate known asymmetric pixels and preserve every physical dir baseline',()=>{
  const png=readPng(fixture(description,[colored])), pixels=decodePng(png), dmi=parseDmi(png);
  for(const anchor of directions) {
    const generated=readPng(generateVariant(png,pixels,dmi,'surface',anchor));
    const parsed=parseDmi(generated), data=decodePng(generated);
    assert.deepEqual(tile(generated,data,parsed,directions.indexOf(anchor)),colored);
    assert.equal(parsed.states[0].name,'arrow');
  }
  const east=readPng(generateVariant(png,pixels,dmi,'surface',2));
  assert.deepEqual(tile(east,decodePng(east),parseDmi(east),2),Buffer.from([0,255,0,255,255,255,0,255,255,0,0,255,0,0,255,255]));
});

test('existing eight directions and animation/movement/loop/rewind metadata remain exact',()=>{
  const states='state = "native"\n dirs = 8\n frames = 1\nstate = "blink"\n dirs = 1\n frames = 2\n delay = 1,3\n loop = 2\n rewind = 1\n movement = 1\n';
  const frames=Array.from({length:10},(_,i)=>Buffer.alloc(16,i+1));
  const png=readPng(fixture(states,frames)),original=parseDmi(png),pixels=decodePng(png);
  const out=readPng(generateVariant(png,pixels,original,'surface',8)),generated=parseDmi(out),data=decodePng(out);
  assert.equal(generated.states[0].dirs,8);
  for(let i=0;i<8;i++) assert.deepEqual(tile(out,data,generated,i),frames[i]);
  assert.equal(generated.states[1].frames,2);
  assert.match(generated.states[1].block,/delay = 1,3/);
  assert.match(generated.states[1].block,/loop = 2/);
  assert.match(generated.states[1].block,/rewind = 1/);
  assert.equal(generated.states[1].movement,1);
  assert.deepEqual(tile(out,data,generated,11),frames[8]); // WEST baseline, first animation frame
  assert.deepEqual(tile(out,data,generated,15),frames[9]);
});

test('palette, packed samples and transparency survive rotation without RGBA conversion',()=>{
  const chunks=[{type:'PLTE',data:Buffer.from([255,0,0,0,255,0,0,0,255,255,255,0])},{type:'tRNS',data:Buffer.from([0,128,255,255])}];
  const png=readPng(fixture(description,[Buffer.from([0,1,2,3])],2,3,chunks));
  const out=readPng(generateVariant(png,decodePng(png),parseDmi(png),'surface',2));
  assert.equal(out.depth,2);assert.equal(out.color,3);
  assert.deepEqual(out.chunks.find(c=>c.type==='tRNS').data,chunks[1].data);
  assert.deepEqual(tile(out,decodePng(out),parseDmi(out),2),Buffer.from([1,3,0,2]));
});

test('smoothing picks existing painted wall states, including diagonal art, without pixel rotation',()=>{
  const names=['wall-0','wall-1','wall-2','wall-4','wall-8','wall-5-d','wall-9-d','wall-6-d','wall-10-d'];
  const states=names.map(n=>`state = "${n}"\n dirs = 1\n frames = 1\n`).join('');
  const frames=names.map((_,i)=>Buffer.alloc(16,i+1));
  const png=readPng(fixture(states,frames)), dmi=parseDmi(png),plan=conversionPlan(dmi,'smooth');
  assert.deepEqual(plan.prefixes,['wall']);
  const out=readPng(generateVariant(png,decodePng(png),dmi,'smooth',2)),parsed=parseDmi(out),pixels=decodePng(out);
  const north=parsed.states.find(s=>s.name==='wall-1');
  assert.deepEqual(tile(out,pixels,parsed,north.firstTile+2),frames[names.indexOf('wall-8')]);
  assert.equal(parsed.states.find(s=>s.name==='wall-5-d').dirs,4);
  assert.equal(turnJunction(1|4|16,90),1|8|128);
});

test('truncated input and bad CRC cannot silently create corrupted assets',()=>{
  const png=fixture(description,[colored]);
  assert.throws(()=>readPng(png.subarray(0,-5)));
  const corrupted=Buffer.from(png);corrupted[corrupted.length-1]^=1;
  assert.throws(()=>readPng(corrupted),/CRC/);
});

test('all real prebuilt variants retain source names, timing and exact normal-view pixels',()=>{
  const root=process.cwd(), manifest=JSON.parse(fs.readFileSync(path.join(root,'tmp/brandish-icons/manifest.json')));
  let checked=0;
  for(const entry of manifest.entries) {
    let source=readPng(fs.readFileSync(path.join(root,entry.source))), original=parseDmi(source),pixels=decodePng(source);
    if(manifest.policy.rectangularSurfaces?.includes(entry.source)) ({png:source,dmi:original,pixels}=squareGeometry(source,pixels,original));
    const originals=original.states.map(s=>Array.from({length:s.dirs*s.frames},(_,i)=>entry.footprintSize ? alignFootprint(tile(source,pixels,original,s.firstTile+i),original.width,source.pixelBytes,...entry.footprintSize,0) : tile(source,pixels,original,s.firstTile+i)));
    for(const kind of ['surface','smooth','corner']) for(const [anchor,file] of Object.entries(entry[kind]??{})) {
      const out=readPng(fs.readFileSync(path.join(root,file))), dmi=parseDmi(out), data=decodePng(out);
      const plan=conversionPlan(original,kind,kind==='surface' && manifest.policy.directionalSurfaces?.includes(entry.source)).plan;
      const allowed=kind==='surface' && manifest.policy.surfaceStates?.[entry.source];
      if(allowed) for(const state of plan.keys()) if(!allowed.includes(state.name)) plan.delete(state);
      assert.equal(dmi.states.length,original.states.length,file);
      dmi.states.forEach((state,i)=>{
        const old=original.states[i];
        assert.equal(state.name,old.name);assert.equal(state.frames,old.frames);assert.equal(state.movement,old.movement);
        assert.equal(state.block.replace(/(^\s*dirs\s*=\s*)\d+/m,'$1X'),old.block.replace(/(^\s*dirs\s*=\s*)\d+/m,'$1X'));
        if(!plan.has(old)) for(let n=0;n<old.dirs*old.frames;n++) assert.deepEqual(tile(out,data,dmi,state.firstTile+n),originals[i][n],`${file}:${state.name}:${n}`);
        else for(let frame=0;frame<old.frames;frame++) assert.deepEqual(tile(out,data,dmi,state.firstTile+frame*state.dirs+allDirections.indexOf(Number(anchor))),originals[i][frame*old.dirs+(old.dirs===1?0:allDirections.indexOf(Number(anchor)))],`${file}:${state.name}:normal`);
      });checked++;
    }
  }
  assert(checked>100);console.log(`Preserved baseline and state metadata across ${checked} real resource variants`);
});

test('all fourteen Runtime Station plaque pieces rotate as one connected bitmap',()=>{
  const root=process.cwd(), manifest=JSON.parse(fs.readFileSync(path.join(root,'tmp/brandish-icons/manifest.json')));
  const entry=manifest.entries.find(e=>e.source==='icons/turf/decals.dmi');
  const source=readPng(fs.readFileSync(path.join(root,entry.source))), dmi=parseDmi(source), pixels=decodePng(source);
  const generated=readPng(fs.readFileSync(path.join(root,entry.surface['2']))), gdmi=parseDmi(generated), gpixels=decodePng(generated);
  const bytes=source.pixelBytes, size=dmi.width, width=7*size, height=2*size;
  const original=Buffer.alloc(width*height*bytes);
  const place=(out,w,frame,x,y)=>{for(let row=0;row<size;row++) frame.copy(out,((y*size+row)*w+x*size)*bytes,row*size*bytes,(row+1)*size*bytes);};
  for(let i=1;i<=14;i++) {
    const state=dmi.states.find(s=>s.name===`L${i}`);
    place(original,width,tile(source,pixels,dmi,state.firstTile),Math.floor((i-1)/2),(i-1)%2);
  }
  const rotated=(x,y,w,h,cw)=>cw===90?[h-1-y,x]:cw===180?[w-1-x,h-1-y]:cw===270?[y,w-1-x]:[x,y];
  for(const [slot,cw] of [[2,0],[4,270],[1,180],[8,90]]) {
    const w=cw%180?height:width,h=cw%180?width:height;
    const expected=Buffer.alloc(w*h*bytes), actual=Buffer.alloc(w*h*bytes);
    for(let y=0;y<height;y++) for(let x=0;x<width;x++) {
      const [nx,ny]=rotated(x,y,width,height,cw);
      original.copy(expected,(ny*w+nx)*bytes,(y*width+x)*bytes,(y*width+x+1)*bytes);
    }
    for(let i=1;i<=14;i++) {
      const state=gdmi.states.find(s=>s.name===`L${i}`);
      assert.equal(state.dirs,4);
      const [x,y]=rotated(Math.floor((i-1)/2),(i-1)%2,7,2,cw);
      place(actual,w,tile(generated,gpixels,gdmi,state.firstTile+directions.indexOf(slot)),x,y);
    }
    assert.deepEqual(actual,expected,`plaque rotation ${cw}`);
  }
});

test('corner geometry selects the corresponding painted quadrant and large cells keep their size',()=>{
  const names=['1-i','2-i','3-i','4-i'];
  const states=names.map(n=>`state = "${n}"\n dirs = 1\n frames = 1\n`).join('');
  let p=readPng(fixture(states,names.map((_,i)=>Buffer.alloc(16,i+1))));
  const d=parseDmi(p), out=readPng(generateVariant(p,decodePng(p),d,'corner',2)), od=parseDmi(out);
  assert.equal(conversionPlan(d,'corner').plan.size,4);
  const northeast=od.states.find(s=>s.name==='2-i');
  assert.deepEqual(tile(out,decodePng(out),od,northeast.firstTile+2),Buffer.alloc(16,1));
  const manifest=JSON.parse(fs.readFileSync('tmp/brandish-icons/manifest.json'));
  assert(manifest.entries.some(e=>e.smooth && parseDmi(readPng(fs.readFileSync(e.source))).width>32));
});

test('foreground masks preserve visible RGB and select front/behind per native direction',()=>{
  for(const [file,family] of [['icons/obj/fluff.dmi','railing'],['icons/obj/platforms.dmi','platform']]) {
    const p=readPng(fs.readFileSync(file)), data=decodePng(p), d=parseDmi(p);
    const out=readPng(generateForeground(p,data,d,family)), od=parseDmi(out), pixels=decodePng(out);
    for(const [name,fullDirs] of [[`${family}_gray`,[2]],[`${family}_gray_corner`,[2,8]]]) {
      const state=d.states.find(s=>s.name===name), newState=od.states.find(s=>s.name===name);
      for(let i=0;i<4;i++) {
        const old=tile(p,data,d,state.firstTile+i), now=tile(out,pixels,od,newState.firstTile+i);
        for(let n=0;n<old.length;n+=4) {
          assert.deepEqual(now.subarray(n,n+3),old.subarray(n,n+3));
          if(fullDirs.includes(directions[i])) assert.equal(now[n+3],old[n+3]);
          if(directions[i]===1) assert.equal(now[n+3],0);
        }
      }
    }
  }
});

test('content cache rebuilds a damaged catalog, missing resource and removed source',()=>{
  const root=fs.mkdtempSync(path.join(os.tmpdir(),'brandish-cache-'));
  try {
    fs.mkdirSync(path.join(root,'icons/turf'),{recursive:true});
    const source=path.join(root,'icons/turf/probe.dmi');
    fs.writeFileSync(source,fixture(description,[colored]));
    const first=generate(root), catalog=path.join(root,'tmp/brandish-icons/manifest.dm');
    const expected=fs.readFileSync(catalog);
    assert.equal(generate(root).fingerprint,first.fingerprint);
    fs.writeFileSync(catalog,'corrupt');generate(root);
    assert.deepEqual(fs.readFileSync(catalog),expected);
    const asset=path.join(root,first.entries[0].surface['2']);
    fs.unlinkSync(asset);generate(root);assert(fs.existsSync(asset));
    fs.unlinkSync(source);assert.equal(generate(root).entries.length,0);
  } finally {
    assert.equal(path.dirname(path.resolve(root)),path.resolve(os.tmpdir()));
    assert(path.basename(root).startsWith('brandish-cache-'));
    fs.rmSync(root,{recursive:true,force:true});
  }
});


test('world-transform gates expose exactly one unchanged animated sprite to each camera',()=>{
  const p=readPng(fixture('state = "bolt"\n dirs = 1\n frames = 2\n delay = 2,3\n',[colored,Buffer.alloc(16,100)]));
  for(const facing of directions) {
    const out=readPng(generateViewGate(p,decodePng(p),parseDmi(p),facing)),d=parseDmi(out),pixels=decodePng(out);
    assert.equal(d.states.length,1);assert.equal(d.states[0].name,'bolt@2');
    assert.match(d.states[0].block,/delay = 2,3/);
    assert.equal((out.description.match(/# END DMI/g)||[]).length,1);
    const visible={1:1,4:8,2:2,8:4}[facing];
    for(let frame=0;frame<2;frame++) for(let slot=0;slot<4;slot++) {
      const data=tile(out,pixels,d,frame*4+slot);
      assert.deepEqual(data,directions[slot]===visible?(frame?Buffer.alloc(16,100):colored):Buffer.alloc(16));
    }
  }
});

test('directional computers remap both junction topology and native facing, including broken screens',()=>{
  const names=['computer-0','computer-1','computer-2','computer-4','computer-8'];
  const all=names.concat(names.map(n=>n+'_broken'));
  const states=all.map(n=>`state = "${n}"\n dirs = 4\n frames = 1\n`).join('');
  const frames=all.flatMap((_,i)=>directions.map((_,j)=>Buffer.alloc(16,i*4+j+1)));
  const p=readPng(fixture(states,frames)),d=parseDmi(p);
  const out=readPng(generateVariant(p,decodePng(p),d,'smooth',2)),od=parseDmi(out),pixels=decodePng(out);
  for(const suffix of ['', '_broken']) {
    const state=od.states.find(s=>s.name==='computer-1'+suffix);
    assert.equal(state.dirs,4);
    assert.deepEqual(tile(out,pixels,od,state.firstTile+2),frames[all.indexOf('computer-8'+suffix)*4+2]);
    assert.deepEqual(tile(out,pixels,od,state.firstTile),frames[all.indexOf('computer-1'+suffix)*4]);
  }
});

test('station map halves rotate into one connected surface',()=>{
  const manifest=JSON.parse(fs.readFileSync('tmp/brandish-icons/manifest.json'));
  const e=manifest.entries.find(e=>e.source==='icons/obj/decals.dmi');
  const p=readPng(fs.readFileSync(e.source)),d=parseDmi(p),data=decodePng(p);
  const out=readPng(fs.readFileSync(e.surface['2'])),od=parseDmi(out),pixels=decodePng(out);
  for(const suffix of ['', '-MS', '-fland']) for(const half of ['left','right']) {
    const name=`map-${half}${suffix}`,s=d.states.find(s=>s.name===name),t=od.states.find(s=>s.name===name);
    const src=tile(p,data,d,s.firstTile);
    const dest=tile(out,pixels,od,t.firstTile+2);
    for(let y=0;y<32;y++) for(let x=0;x<32;x++) {
      // Native SOUTH -> EAST is the 90-degree camera turn, 270 raster degrees.
      assert.deepEqual(dest.subarray(((31-x)*32+y)*p.pixelBytes,((31-x)*32+y+1)*p.pixelBytes),src.subarray((y*32+x)*p.pixelBytes,(y*32+x+1)*p.pixelBytes));
    }
  }
});


test('chair foreground hides only the seated north-facing body, including indexed source art',()=>{
  for(const file of ['chairs','benches','sofa']) {
    const p=readPng(fs.readFileSync(`icons/obj/beds_chairs/${file}.dmi`)),d=parseDmi(p);
    const out=readPng(generateForeground(p,decodePng(p),d,'chair')),od=parseDmi(out),pixels=decodePng(out);
    for(const s of od.states) for(let frame=0;frame<s.frames;frame++) for(let slot=0;slot<s.dirs;slot++) {
      const t=tile(out,pixels,od,s.firstTile+frame*s.dirs+slot);
      if(slot!==1) for(let n=3;n<t.length;n+=4) assert.equal(t[n],0);
    }
    assert(pixels.some((v,i)=>i%4===3&&v));
  }
});

test('directional pipe banks rotate the physical art, not a different direction with another layer layout',()=>{
  const p=readPng(fs.readFileSync('icons/obj/atmospherics/pipes/manifold.dmi')),d=parseDmi(p),data=decodePng(p);
  const plan=conversionPlan(d,'surface',true),s=d.states.find(s=>s.name==='manifoldlayer_center');
  for(const anchor of directions) {
    const out=readPng(generateVariant(p,data,d,'surface',anchor,plan)),od=parseDmi(out),pixels=decodePng(out),t=od.states.find(t=>t.name===s.name);
    const original=tile(p,data,d,s.firstTile+directions.indexOf(anchor));
    assert.deepEqual(tile(out,pixels,od,t.firstTile+directions.indexOf(anchor)),original);
    const angle={1:0,2:180,4:270,8:90};
    for(let slot=0;slot<4;slot++) assert.deepEqual(tile(out,pixels,od,t.firstTile+slot),rotatePixels(original,32,p.pixelBytes,(angle[anchor]-angle[directions[slot]]+360)%360));
  }
});

test('lighting channel basis stays world-aligned with an explicit NORTH overlay',()=>{
  const p=readPng(fs.readFileSync('icons/effects/lighting_object.dmi')),d=parseDmi(p),pixels=decodePng(p);
  const out=readPng(generateVariant(p,pixels,d,'basis',1)),od=parseDmi(out),data=decodePng(out);
  for(let slot=0;slot<4;slot++) assert.deepEqual(tile(out,data,od,slot),rotatePixels(tile(p,pixels,d,0),32,4,[180,0,90,270][slot]));
});

test('large airlock padding and mask share one center through every camera turn',()=>{
  const p=readPng(fs.readFileSync('icons/obj/doors/airlocks/glass_large/glass_large.dmi')),d=parseDmi(p),original=decodePng(p);
  const q=squareGeometry(p,original,d);assert.equal(q.dmi.width,64);assert.equal(q.dmi.height,64);
  const src=tile(p,original,d,0),padded=tile(q.png,q.pixels,q.dmi,0),mask=tile(q.png,q.mask,q.dmi,0);
  for(let y=0;y<64;y++) for(let x=0;x<64;x++) {
    const i=(y*64+x)*4;
    if(y>=16&&y<48) {
      const index=(y-16)*64+x;
      const palette=p.chunks.find(c=>c.type==='PLTE')?.data,alpha=p.chunks.find(c=>c.type==='tRNS')?.data;
      const rgba=palette?Buffer.from([...palette.subarray(src[index]*3,src[index]*3+3),alpha?.[src[index]]??255]):src.subarray(index*4,index*4+4);
      assert.deepEqual(padded.subarray(i,i+4),rgba);assert.equal(mask[i+3],255);
    }
    else {assert.equal(padded[i+3],0);assert.equal(mask[i+3],0);}
  }
});


test('eight-direction heat pipes preserve each physical bend and rotate its layer offset with the map',()=>{
  const p=readPng(fs.readFileSync('icons/obj/atmospherics/pipes/he-simple.dmi')),d=parseDmi(p),data=decodePng(p);
  for(const anchor of allDirections) {
    const out=readPng(generateVariant(p,data,d,'surface',anchor,conversionPlan(d,'surface',true))),od=parseDmi(out),pixels=decodePng(out);
    for(let i=0;i<d.states.length;i++) for(const quarter of [0,90,180,270]) {
      const direction=turnJunction(anchor,quarter);
      assert.deepEqual(tile(out,pixels,od,od.states[i].firstTile+allDirections.indexOf(direction)),rotatePixels(tile(p,data,d,d.states[i].firstTile+allDirections.indexOf(anchor)),32,p.pixelBytes,360-quarter));
    }
  }
});


test('native multi-tile bounds and rotated frames preserve every pixel world position',()=>{
  for(const [width,height] of [[64,32],[128,224],[96,96]]) {
    const size=Math.max(width,height),ox=(size-width)/2,oy=(size-height)/2,source=Buffer.alloc(size*size*4);
    for(let y=0;y<height;y++) for(let x=0;x<width;x++) {const i=((oy+height-1-y)*size+ox+x)*4;source[i]=x+1;source[i+1]=y+1;source[i+3]=255;}
    for(const [cw,bx,by,project] of [[0,0,0,(x,y)=>[x,y]],[270,32-height,0,(x,y)=>[32-y,x]],[180,32-width,32-height,(x,y)=>[32-x,32-y]],[90,0,32-width,(x,y)=>[y,32-x]]]) {
      const result=alignFootprint(rotatePixels(source,size,4,cw),size,4,width,height,cw);
      let seen=0;
      for(let y=0;y<size;y++) for(let x=0;x<size;x++) {const i=(y*size+x)*4;if(!result[i+3])continue;seen++;
        const expected=project(result[i]-0.5,result[i+1]-0.5);
        assert.deepEqual([x+0.5+bx,size-y-0.5+by],expected);
      }
      assert.equal(seen,width*height);
    }
  }
});
