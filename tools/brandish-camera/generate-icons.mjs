// Build-only DMI expansion. Pixel samples, palette/color chunks, state names,
// animation timing, movement/loop/rewind and existing directional art survive.
// No image dependency: Node's standard library is already a build requirement.
import fs from 'node:fs';
import path from 'node:path';
import zlib from 'node:zlib';
import crypto from 'node:crypto';
import { fileURLToPath } from 'node:url';

const signature = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
export const directions = [2, 1, 4, 8]; // BYOND's DMI order: S,N,E,W
export const allDirections = [2, 1, 4, 8, 6, 10, 5, 9];
const angle = { 1: 0, 2: 180, 4: 270, 8: 90, 6:225, 10:135, 5:315, 9:45 };
const crcTable = Array.from({ length: 256 }, (_, n) => {
  for (let i = 0; i < 8; i++) n = (n & 1) ? 0xedb88320 ^ (n >>> 1) : n >>> 1;
  return n >>> 0;
});
function crc(bytes) {
  let value = 0xffffffff;
  for (const byte of bytes) value = crcTable[(value ^ byte) & 255] ^ (value >>> 8);
  return (value ^ 0xffffffff) >>> 0;
}
export function chunk(type, data) {
  const out = Buffer.alloc(data.length + 12);
  out.writeUInt32BE(data.length); out.write(type, 4); data.copy(out, 8);
  out.writeUInt32BE(crc(out.subarray(4, -4)), out.length - 4);
  return out;
}
function textChunk(c) {
  const zero = c.data.indexOf(0);
  if (zero < 0 || c.data.subarray(0, zero).toString() !== 'Description') return null;
  if (c.type === 'zTXt') return zlib.inflateSync(c.data.subarray(zero + 2)).toString('latin1');
  if (c.type === 'tEXt') return c.data.subarray(zero + 1).toString('latin1');
  return null;
}
export function readPng(bytes) {
  if (!bytes.subarray(0, 8).equals(signature)) throw Error('Not a PNG');
  const chunks = [];
  for (let off = 8; off < bytes.length;) {
    const length = bytes.readUInt32BE(off);
    if (off + length + 12 > bytes.length) throw Error('Truncated PNG');
    const type = bytes.toString('ascii', off + 4, off + 8);
    const data = bytes.subarray(off + 8, off + 8 + length);
    if (crc(bytes.subarray(off + 4, off + 8 + length)) !== bytes.readUInt32BE(off + 8 + length)) throw Error(`Bad ${type} CRC`);
    chunks.push({ type, data }); off += length + 12;
  }
  const header = chunks.find(c => c.type === 'IHDR')?.data;
  if (!header || chunks.some(c => c.type === 'acTL')) throw Error('Unsupported PNG/APNG');
  const width = header.readUInt32BE(), height = header.readUInt32BE(4);
  const depth = header[8], color = header[9];
  const channels = { 0: 1, 2: 3, 3: 1, 4: 2, 6: 4 }[color];
  if (!channels || header[10] || header[11] || header[12] > 1) throw Error('Unsupported PNG header');
  const pixelBytes = depth < 8 ? 1 : channels * depth / 8;
  const description = chunks.map(textChunk).find(t => t !== null);
  return { width, height, depth, color, channels, pixelBytes, header, chunks, description };
}
export function decodePng(png) {
  const raw = zlib.inflateSync(Buffer.concat(png.chunks.filter(c => c.type === 'IDAT').map(c => c.data)));
  const pixels = Buffer.alloc(png.width * png.height * png.pixelBytes);
  const passes = png.header[12] ? [[0,0,8,8],[4,0,8,8],[0,4,4,8],[2,0,4,4],[0,2,2,4],[1,0,2,2],[0,1,1,2]] : [[0,0,1,1]];
  const bpp = Math.max(1, Math.ceil(png.channels * png.depth / 8));
  let offset = 0;
  for (const [sx, sy, dx, dy] of passes) {
    const w = Math.max(0, Math.ceil((png.width - sx) / dx));
    const h = Math.max(0, Math.ceil((png.height - sy) / dy));
    if (!w || !h) continue;
    const stride = Math.ceil(w * png.channels * png.depth / 8);
    let previous = Buffer.alloc(stride);
    for (let y = 0; y < h; y++) {
      const filter = raw[offset++];
      if (filter > 4 || offset + stride > raw.length) throw Error('Invalid PNG scanline');
      const row = Buffer.from(raw.subarray(offset, offset + stride)); offset += stride;
      for (let i = 0; i < stride; i++) {
        const a = i >= bpp ? row[i-bpp] : 0, b = previous[i], c = i >= bpp ? previous[i-bpp] : 0;
        const p = a+b-c, pa = Math.abs(p-a), pb = Math.abs(p-b), pc = Math.abs(p-c);
        const prediction = [0, a, b, Math.floor((a+b)/2), pa <= pb && pa <= pc ? a : pb <= pc ? b : c][filter];
        row[i] = (row[i] + prediction) & 255;
      }
      for (let x = 0; x < w; x++) {
        const dest = ((sy+y*dy) * png.width + sx+x*dx) * png.pixelBytes;
        if (png.depth < 8) pixels[dest] = (row[Math.floor(x*png.depth/8)] >>> (8-png.depth-(x*png.depth%8))) & ((1 << png.depth)-1);
        else row.copy(pixels, dest, x*png.pixelBytes, (x+1)*png.pixelBytes);
      }
      previous = row;
    }
  }
  if (offset !== raw.length) throw Error('Unexpected PNG scanline length');
  return pixels;
}
export function encodePng(png, pixels, width, height, description) {
  const stride = Math.ceil(width * png.channels * png.depth / 8);
  const raw = Buffer.alloc((stride+1)*height);
  for (let y = 0; y < height; y++) {
    const row = raw.subarray(y*(stride+1)+1, (y+1)*(stride+1));
    if (png.depth < 8) {
      for (let x = 0; x < width; x++) row[Math.floor(x*png.depth/8)] |= pixels[y*width+x] << (8-png.depth-(x*png.depth%8));
    } else pixels.copy(row, 0, y*width*png.pixelBytes, (y+1)*width*png.pixelBytes);
  }
  const header = Buffer.from(png.header); header.writeUInt32BE(width); header.writeUInt32BE(height, 4); header[12] = 0;
  // Keep the same sample representation, including palette, transparency and profiles.
  const keep = new Set(['PLTE','tRNS','cHRM','gAMA','iCCP','sBIT','sRGB','cICP','mDCV','cLLI','pHYs']);
  return Buffer.concat([signature, chunk('IHDR', header), ...png.chunks.filter(c => keep.has(c.type)).map(c => chunk(c.type,c.data)),
    chunk('zTXt', Buffer.concat([Buffer.from('Description\0\0'), zlib.deflateSync(Buffer.from(description,'latin1'))])),
    chunk('IDAT', zlib.deflateSync(raw, { level: 9 })), chunk('IEND', Buffer.alloc(0))]);
}
export function parseDmi(png) {
  if (!png.description?.includes('# BEGIN DMI')) throw Error('No DMI metadata');
  const matches = [...png.description.matchAll(/^state\s*=\s*"((?:\\.|[^"\\])*)"[^\r\n]*$/gm)];
  const width = Number(png.description.match(/^\s*width\s*=\s*(\d+)/m)?.[1] ?? 32);
  const height = Number(png.description.match(/^\s*height\s*=\s*(\d+)/m)?.[1] ?? 32);
  if (png.width % width || png.height % height) throw Error('DMI grid mismatch');
  let firstTile = 0;
  const states = matches.map((match, i) => {
    const block = png.description.slice(match.index, matches[i+1]?.index ?? png.description.length);
    const name = match[1].replace(/\\(["\\])/g, '$1');
    const dirs = Number(block.match(/^\s*dirs\s*=\s*(\d+)/m)?.[1] ?? 1);
    const frames = Number(block.match(/^\s*frames\s*=\s*(\d+)/m)?.[1] ?? 1);
    const movement = Number(block.match(/^\s*movement\s*=\s*(\d+)/m)?.[1] ?? 0);
    if (![1,4,8].includes(dirs) || !Number.isInteger(frames) || frames < 1) throw Error('Unsupported DMI directions/frames');
    const state = { name, dirs, frames, movement, block, firstTile };
    firstTile += dirs*frames;
    return state;
  });
  if (firstTile > png.width/width * (png.height/height)) throw Error('DMI frames exceed sheet');
  return { width, height, states, prefix: png.description.slice(0, matches[0]?.index) };
}
export function turnJunction(mask, ccw) {
  const ring = [1, 16, 4, 32, 2, 64, 8, 128]; // N,NE,E,SE,S,SW,W,NW
  const steps = ((-ccw/45)%8+8)%8;
  return ring.reduce((out, bit, i) => mask & bit ? out | ring[(i+steps)%8] : out, 0);
}
function animationSignature(s) {
  return s.block.replace(/^state[^\r\n]*/m, '').replace(/^\s*dirs[^\r\n]*/m, '').replace(/# END DMI[\s\S]*/, '').trim();
}
function turnCornerState(name, ccw) {
  const bit = {n:1,s:2,e:4,w:8}, letter={1:'n',2:'s',4:'e',8:'w'};
  const orient = s => {
    const changed=[...s].map(c=>letter[turnJunction(bit[c],ccw)]);
    return ['n','s','e','w'].filter(c=>changed.includes(c)).join('');
  };
  const match=name.match(/^([1-4])-(i|f|n|s|e|w|nw|ne|sw|se)$/);
  if(match) {
    const corner={1:'nw',2:'ne',3:'sw',4:'se'}, index={nw:1,ne:2,sw:3,se:4};
    return `${index[orient(corner[match[1]])]}-${['i','f'].includes(match[2])?match[2]:orient(match[2])}`;
  }
  const diagonal=name.match(/^d-(nw|ne|sw|se)(-[01])?$/);
  return diagonal?`d-${orient(diagonal[1])}${diagonal[2]??''}`:null;
}
export function conversionPlan(dmi, mode, directionalSurface = false) {
  const lookup = new Map(dmi.states.map(s => [`${s.name}\0${s.movement}`,s]));
  const plan = new Map(), prefixes = new Set();
  for (const state of dmi.states) {
    if (dmi.width !== dmi.height || (state.dirs !== 1 && !((mode === 'smooth' || mode === 'basis' || directionalSurface) && state.dirs === 4) && !(directionalSurface && state.dirs===8))) continue;
    if (mode === 'surface' || mode === 'basis') { plan.set(state, null); continue; }
    if (mode === 'corner') {
      const names=[0,90,180,270].map(a=>turnCornerState(state.name,a));
      if(names.some(n=>!n)) continue;
      const targets=names.map(n=>lookup.get(`${n}\0${state.movement}`));
      if(targets.some(t=>!t||t.dirs!==1||animationSignature(t)!==animationSignature(state))) continue;
      plan.set(state,targets); continue;
    }
    const match = state.name.match(/^(.*)-(\d+)(-d|_broken)?$/);
    if (!match || Number(match[2]) > 255 || String(Number(match[2])) !== match[2]) continue;
    const [,prefix,mask,ending=''] = match;
    // Exclude unrelated numbered states; a real junction family contains all cardinal bits.
    if (![1,2,4,8].every(n => lookup.has(`${prefix}-${n}\0${state.movement}`) || lookup.has(`${prefix}-${n}${ending}\0${state.movement}`))) continue;
    const targets = [0,90,180,270].map(a => lookup.get(`${prefix}-${turnJunction(Number(mask),a)}${ending}\0${state.movement}`));
    if (targets.some(t => !t || t.dirs !== state.dirs || animationSignature(t) !== animationSignature(state))) continue;
    plan.set(state, targets); prefixes.add(prefix);
  }
  return { plan, prefixes: [...prefixes].sort() };
}
export function tile(png, pixels, dmi, index) {
  const out = Buffer.alloc(dmi.width*dmi.height*png.pixelBytes);
  const cols = png.width/dmi.width, sx = index%cols*dmi.width, sy = Math.floor(index/cols)*dmi.height;
  for (let y=0; y<dmi.height; y++) {
    const start = ((sy+y)*png.width+sx)*png.pixelBytes;
    pixels.copy(out, y*dmi.width*png.pixelBytes, start, start+dmi.width*png.pixelBytes);
  }
  return out;
}
export function rotatePixels(pixels, size, bytes, cw) {
  const out = Buffer.alloc(pixels.length); cw = (cw+360)%360;
  for (let y=0;y<size;y++) for(let x=0;x<size;x++) {
    let nx=x,ny=y;
    if(cw===90) {nx=size-1-y;ny=x;} else if(cw===180) {nx=size-1-x;ny=size-1-y;} else if(cw===270) {nx=y;ny=size-1-x;}
    pixels.copy(out,(ny*size+nx)*bytes,(y*size+x)*bytes,(y*size+x+1)*bytes);
  }
  return out;
}

/// Center rectangular world geometry in a square canvas before native turns.
/// Returns the padded image and a matching opaque footprint mask.
export function squareGeometry(png,pixels,dmi) {
  [png,pixels]=rgbaPixels(png,pixels);
  const size=Math.max(dmi.width,dmi.height), cols=png.width/dmi.width, rows=png.height/dmi.height;
  const width=cols*size,height=rows*size, packed=Buffer.alloc(width*height*4),mask=Buffer.alloc(width*height*4);
  const ox=(size-dmi.width)/2,oy=(size-dmi.height)/2;
  if(!Number.isInteger(ox)||!Number.isInteger(oy)) throw Error('Rectangular geometry requires even padding');
  for(let row=0;row<rows;row++) for(let col=0;col<cols;col++) for(let y=0;y<dmi.height;y++) for(let x=0;x<dmi.width;x++) {
    const src=((row*dmi.height+y)*png.width+col*dmi.width+x)*4;
    const dst=((row*size+y+oy)*width+col*size+x+ox)*4;
    pixels.copy(packed,dst,src,src+4);mask.fill(255,dst,dst+4);
  }
  const description=png.description.replace(/(^\s*width\s*=\s*)\d+/m,`$1${size}`).replace(/(^\s*height\s*=\s*)\d+/m,`$1${size}`);
  const result=readPng(encodePng(png,packed,width,height,description));
  return {png:result,pixels:packed,dmi:parseDmi(result),mask};
}

/// Large movable bounds already re-anchor to their rotated southwest corner
/// in BYOND. Align each rectangular frame there; adding a world-center offset
/// on the atom would apply that rotation twice.
export function alignFootprint(pixels,size,bytes,width,height,cw) {
  if(cw%180) [width,height]=[height,width];
  const ox=(size-width)/2,oy=(size-height)/2,result=Buffer.alloc(pixels.length);
  for(let y=0;y<height;y++) {
    const start=((y+oy)*size+ox)*bytes;
    pixels.copy(result,((y+size-height)*size)*bytes,start,start+width*bytes);
  }
  return result;
}
export function generateVariant(png, pixels, dmi, mode, anchor, conversion = conversionPlan(dmi,mode)) {
  const frames = [], blocks = [];
  for (const state of dmi.states) {
    const converted = conversion.plan.has(state);
    blocks.push(converted ? state.block.replace(/(^\s*dirs\s*=\s*)1\b/m,'$14') : state.block);
    for(let frame=0;frame<state.frames;frame++) {
      if (!converted) {
        for(let dir=0;dir<state.dirs;dir++) frames.push(tile(png,pixels,dmi,state.firstTile+frame*state.dirs+dir));
        continue;
      }
      for (const direction of (state.dirs===8 ? allDirections : directions)) {
        const ccw = (angle[direction]-angle[anchor]+360)%360;
        const targets = conversion.plan.get(state);
        const source = targets ? targets[ccw/90] : state;
        const sourceDir = source.dirs === 1 || mode === 'basis' ? 0 : allDirections.indexOf(targets ? direction : anchor);
        let data = tile(png,pixels,dmi,source.firstTile+frame*source.dirs+sourceDir);
        if (!targets) data = rotatePixels(data,dmi.width,png.pixelBytes,(360-ccw)%360);
        if(conversion.footprint) data=alignFootprint(data,dmi.width,png.pixelBytes,...conversion.footprint,(360-ccw)%360);
        frames.push(data);
      }
    }
  }
  const cols = Math.ceil(Math.sqrt(frames.length)), rows = Math.ceil(frames.length/cols);
  const width = cols*dmi.width, height = rows*dmi.height;
  const packed = Buffer.alloc(width*height*png.pixelBytes);
  frames.forEach((frame,i) => {
    for(let y=0;y<dmi.height;y++) frame.copy(packed,((Math.floor(i/cols)*dmi.height+y)*width+i%cols*dmi.width)*png.pixelBytes,y*dmi.width*png.pixelBytes,(y+1)*dmi.width*png.pixelBytes);
  });
  return encodePng(png,packed,width,height,dmi.prefix+blocks.join(''));
}
/// Bake the existing foreground alpha masks into native directional frames.
/// The low layer keeps the complete art; this file contains only the part
/// which occludes a mob in each screen direction. No viewer-specific layers.
export function generateForeground(png, pixels, dmi, family) {
  [png,pixels]=rgbaPixels(png,pixels);
  if(png.color!==6 || png.depth!==8) throw Error('Foreground masks require RGBA8 source art');
  const allDirs=[2,1,4,8,6,10,5,9], output=Buffer.from(pixels);
  const states=new Map(dmi.states.map(s=>[s.name,s]));
  const matching=s=>family==='chair' ? true : family==='railing' ? /^railing_(gray|black|wood)(_|$)/.test(s.name) : s.name.startsWith('platform_');
  const read=(state,dir,frame=0)=>tile(png,pixels,dmi,state.firstTile+frame*state.dirs+(state.dirs===1?0:allDirs.slice(0,state.dirs).indexOf(dir)));
  const cols=png.width/dmi.width;
  for(const state of dmi.states) {
    if(!matching(state)) continue;
    for(let frame=0;frame<state.frames;frame++) for(let slot=0;slot<state.dirs;slot++) {
      const direction=allDirs[slot];
      const reverse=((direction&1)<<1)|((direction&2)>>1)|((direction&4)<<1)|((direction&8)>>1);
      const blocking=state.name.endsWith('_end') ? 15^reverse : direction;
      let maskDir=0, maskName=`${family}_gray`, full=false;
      if(family==='chair') full=state.dirs>1 && direction===1;
      else if(state.name.endsWith('_corner')) full=direction===8 || direction===2;
      else if(blocking===2) full=true;
      else if([4,5].includes(blocking)) maskDir=4;
      else if([8,9].includes(blocking)) maskDir=8;
      else if([6,7].includes(blocking)) maskDir=6;
      else if([10,11].includes(blocking)) maskDir=10;
      else if([13,14].includes(blocking)) {maskDir=2;maskName+='_end';}
      const mask=maskDir?read(states.get(maskName),maskDir):null;
      const index=state.firstTile+frame*state.dirs+slot;
      for(let y=0;y<dmi.height;y++) for(let x=0;x<dmi.width;x++) {
        const dest=((Math.floor(index/cols)*dmi.height+y)*png.width+index%cols*dmi.width+x)*4+3;
        output[dest]=full?pixels[dest]:mask?Math.round(pixels[dest]*mask[(y*dmi.width+x)*4+3]/255):0;
      }
    }
  }
  return encodePng(png,output,png.width,png.height,png.description);
}

/// Four sparse native-direction sheets select one world transform per viewer.
/// NORTH is explicit on the overlay (SOUTH would inherit its parent's dir).
/// Pixel data is unchanged; arbitrary rotation/stretch happens in the renderer.
function rgbaPixels(png,pixels) {
  if(png.color===3) {
    const palette=png.chunks.find(c=>c.type==='PLTE').data;
    const alpha=png.chunks.find(c=>c.type==='tRNS')?.data;
    const rgba=Buffer.alloc(png.width*png.height*4);
    for(let i=0;i<pixels.length;i++) {
      palette.copy(rgba,i*4,pixels[i]*3,pixels[i]*3+3);rgba[i*4+3]=alpha?.[pixels[i]]??255;
    }
    const header=Buffer.from(png.header);header[8]=8;header[9]=6;
    png={...png,header,depth:8,color:6,channels:4,pixelBytes:4,chunks:png.chunks.filter(c=>!['PLTE','tRNS'].includes(c.type))};pixels=rgba;
  }
  return [png,pixels];
}

export function generateViewGate(png, pixels, dmi, facing) {
  [png,pixels]=rgbaPixels(png,pixels);
  if(png.color!==6 || png.depth!==8) throw Error('View gates require RGBA8 or indexed8 source art');
  const frames=[], blocks=[], allDirs=[2,1,4,8,6,10,5,9];
  const visibleDir={1:1,4:8,2:2,8:4}[facing];
  for(const state of dmi.states) for(let sourceDir=0;sourceDir<state.dirs;sourceDir++) {
    blocks.push(state.block.replace(/# END DMI\s*/g,'').replace(/^(state\s*=\s*".*)"/m,`$1@${allDirs[sourceDir]}"`).replace(/(^\s*dirs\s*=\s*)\d+/m,'$14'));
    for(let frame=0;frame<state.frames;frame++) for(const direction of directions) {
      frames.push(direction===visibleDir?tile(png,pixels,dmi,state.firstTile+frame*state.dirs+sourceDir):Buffer.alloc(dmi.width*dmi.height*4));
    }
  }
  const cols=Math.ceil(Math.sqrt(frames.length)),rows=Math.ceil(frames.length/cols);
  const width=cols*dmi.width,height=rows*dmi.height,packed=Buffer.alloc(width*height*4);
  frames.forEach((frame,i)=>{for(let y=0;y<dmi.height;y++) frame.copy(packed,((Math.floor(i/cols)*dmi.height+y)*width+i%cols*dmi.width)*4,y*dmi.width*4,(y+1)*dmi.width*4);});
  return encodePng(png,packed,width,height,dmi.prefix+blocks.join('')+'# END DMI\n');
}
const quote = s => '"'+s.replaceAll('\\','\\\\').replaceAll('"','\\"').replaceAll('[','\\[')+'"';
const resource = s => "'"+s.replaceAll("'","\\'")+"'";
function writeChanged(file, bytes) {
  if (fs.existsSync(file) && fs.readFileSync(file).equals(Buffer.from(bytes))) return;
  fs.mkdirSync(path.dirname(file),{recursive:true}); fs.writeFileSync(file,bytes);
}
function walk(folder) {
  if (!fs.existsSync(folder)) return [];
  return fs.readdirSync(folder,{withFileTypes:true}).sort((a,b)=>a.name.localeCompare(b.name,'en')).flatMap(e => e.isDirectory() ? walk(path.join(folder,e.name)) : e.name.endsWith('.dmi') ? [path.join(folder,e.name)] : []);
}
export function generate(root) {
  const output = path.join(root,'tmp/brandish-icons'), entries = [], skipped = [];
  const policy=JSON.parse(fs.readFileSync(new URL('./asset-policy.json',import.meta.url),'utf8'));
  const excluded=[];
  const candidates=walk(path.join(root,'icons')).filter(file=>{
    const relative=path.relative(root,file).replaceAll('\\','/');
    return policy.rules.some(r=>relative.startsWith(r.prefix)) || policy.files[relative] || policy.worldTransforms?.includes(relative);
  });
  const fingerprintHash=crypto.createHash('sha256').update(fs.readFileSync(fileURLToPath(import.meta.url))).update(JSON.stringify(policy));
  for(const file of candidates) fingerprintHash.update(path.relative(root,file).replaceAll('\\','/')).update(fs.readFileSync(file));
  const fingerprint=fingerprintHash.digest('hex');
  try {
    const previous=JSON.parse(fs.readFileSync(path.join(output,'manifest.json'),'utf8'));
    const files=new Set(previous.entries.flatMap(e=>[...['surface','smooth','corner','basis','viewGates','footprint'].flatMap(k=>Object.values(e[k]??{})),...(e.foreground?[e.foreground]:[])]));
    if(previous.schema===2 && previous.fingerprint===fingerprint && previous.catalogHash===crypto.createHash('sha256').update(fs.readFileSync(path.join(output,'manifest.dm'))).digest('hex') && [...files].every(f=>crypto.createHash('sha256').update(fs.readFileSync(path.join(root,f))).digest('hex').startsWith(path.basename(f,'.dmi')))) {
      console.log(`Brandish native icons: verified cached ${previous.statistics.variants} variants`);
      return previous;
    }
  } catch { /* Missing, corrupt or outdated outputs are rebuilt below. */ }
  let variants=0, bytes=0;
  for(const file of candidates) {
    const source = path.relative(root,file).replaceAll('\\','/');
    let modes=[...new Set([...policy.rules.filter(r=>source.startsWith(r.prefix)).flatMap(r=>r.modes),...(policy.files[source]??[])])];
    const worldTransform=policy.worldTransforms?.includes(source);
    if(!modes.length && !worldTransform) continue;
    let png,dmi;
    try { png=readPng(fs.readFileSync(file)); dmi=parseDmi(png); } catch(error) {skipped.push({source,reason:error.message});continue;}
    let pixels=decodePng(png),footprint,footprintSize;
    const rectangle=policy.rectangularSurfaces?.includes(source);
    if(rectangle) {
      footprintSize=[dmi.width,dmi.height];
      ({png,pixels,dmi,mask:footprint}=squareGeometry(png,pixels,dmi));
    }
    if(dmi.width!==dmi.height || (dmi.width>policy.maxGeometrySize && !worldTransform)) {excluded.push({source,reason:'non-square or exceeds geometry limit',width:dmi.width,height:dmi.height});continue;}
    if(dmi.width>policy.maxSurfaceSize && !rectangle) modes=modes.filter(m=>m!=='surface');
    const entry = {source}, plans = modes.map(mode => {
      const plan=conversionPlan(dmi,mode,mode==='surface' && policy.directionalSurfaces?.includes(source));
      if(rectangle && mode==='surface') plan.footprint=footprintSize;
      const allowed=mode==='surface' && policy.surfaceStates?.[source];
      if(allowed) for(const state of plan.plan.keys()) if(!allowed.includes(state.name)) plan.plan.delete(state);
      return [mode,plan];
    }).filter(([,p])=>p.plan.size);
    const foregroundFamily=policy.foreground?.[source];
    if(!plans.length && !foregroundFamily && !worldTransform) {excluded.push({source,reason:'no convertible states for declared policy',width:dmi.width,height:dmi.height});continue;}
    if(footprint) {
      entry.footprint={};
      entry.footprintSize=footprintSize;
      const maskPlan=conversionPlan(dmi,'surface',true);
      maskPlan.footprint=footprintSize;
      for(const anchor of directions) {
        const encoded=generateVariant(png,footprint,dmi,'surface',anchor,maskPlan);
        const hash=crypto.createHash('sha256').update(encoded).digest('hex').slice(0,24);
        const relative=`tmp/brandish-icons/assets/${hash}.dmi`;
        writeChanged(path.join(root,relative),encoded);entry.footprint[anchor]=relative;
      }
    }
    if(worldTransform) {
      entry.viewGates={};entry.stateDirs=Object.fromEntries(dmi.states.map(s=>[s.name,s.dirs]));
      for(const facing of directions) {
        const encoded=generateViewGate(png,pixels,dmi,facing);
        const hash=crypto.createHash('sha256').update(encoded).digest('hex').slice(0,24);
        const relative=`tmp/brandish-icons/assets/${hash}.dmi`;
        writeChanged(path.join(root,relative),encoded);entry.viewGates[facing]=relative;
        variants++;bytes+=encoded.length;
      }
    }
    if(foregroundFamily) {
      const encoded=generateForeground(png,pixels,dmi,foregroundFamily);
      const hash=crypto.createHash('sha256').update(encoded).digest('hex').slice(0,24);
      entry.foreground=`tmp/brandish-icons/assets/${hash}.dmi`;
      writeChanged(path.join(root,entry.foreground),encoded);
      variants++;bytes+=encoded.length;
    }
    for(const [mode,plan] of plans) {
      entry[mode]={}; if(mode==='smooth') entry.prefixes=plan.prefixes;
      for(const anchor of (mode==='surface' && policy.directionalSurfaces?.includes(source) && dmi.states.some(s=>s.dirs===8) ? allDirections : directions)) {
        const encoded=generateVariant(png,pixels,dmi,mode,anchor,plan);
        const hash=crypto.createHash('sha256').update(encoded).digest('hex').slice(0,24);
        const relative=`tmp/brandish-icons/assets/${hash}.dmi`;
        writeChanged(path.join(root,relative),encoded); entry[mode][anchor]=relative;
        variants++;bytes+=encoded.length;
      }
    }
    entries.push(entry);
  }
  const lines=['// Generated by tools/brandish-camera/generate-icons.mjs; do not edit.','/proc/brandish_prebuilt_icons()','\tvar/static/list/catalog = list('];
  for(const entry of entries) {
    const fields=[`${quote('source')} = ${resource(entry.source)}`];
    if(entry.foreground) fields.push(`${quote('foreground')} = ${resource(entry.foreground)}`);
    if(entry.viewGates) {
      fields.push(`${quote('viewGates')} = list(${directions.map(d=>`${quote(String(d))} = ${resource(entry.viewGates[d])}`).join(', ')})`);
      fields.push(`${quote('stateDirs')} = list(${Object.entries(entry.stateDirs).map(([s,n])=>`${quote(Buffer.from(s,'latin1').toString('utf8'))} = ${n}`).join(', ')})`);
    }
    for(const mode of ['surface','smooth','corner','basis','footprint']) if(entry[mode]) fields.push(`${quote(mode)} = list(${Object.entries(entry[mode]).map(([d,file])=>`${quote(d)} = ${resource(file)}`).join(', ')})`);
    if(entry.prefixes) fields.push(`${quote('prefixes')} = list(${entry.prefixes.map(s=>`${quote(Buffer.from(s,'latin1').toString('utf8'))} = 1`).join(', ')})`);
    lines.push(`\t\tlist(${fields.join(', ')}),`);
  }
  lines.push('\t)','\treturn catalog','');
  // These catalog mtimes certify a completed generation for the build cache.
  fs.mkdirSync(output,{recursive:true});
  fs.writeFileSync(path.join(output,'manifest.dm'),lines.join('\n'));
  const catalogHash=crypto.createHash('sha256').update(lines.join('\n')).digest('hex');
  const manifest={schema:2,fingerprint,catalogHash,entries,skipped,excluded,policy,statistics:{sources:entries.length,variants,variantBytesBeforeDeduplication:bytes}};
  fs.writeFileSync(path.join(output,'manifest.json'),JSON.stringify(manifest,null,2)+'\n');
  console.log(`Brandish native icons: ${entries.length} sources, ${variants} directional variants, ${skipped.length} skipped files`);
  return manifest;
}
if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) generate(path.resolve(process.argv[2] ?? '.'));
