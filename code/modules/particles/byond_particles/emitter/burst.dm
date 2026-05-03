/obj/emitter/dust
	particles = new/particles/dust

/obj/emitter/debris
	particles = new/particles/debris

/obj/emitter/debris/colored

/obj/emitter/debris/colored/New(loc, _color)
	. = ..(loc)
	particles.color = _color
