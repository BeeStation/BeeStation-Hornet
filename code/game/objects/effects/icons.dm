/obj/effect/icon/Initialize(mapload, icon/render_source)
	. = ..()
	overlays = list(render_source)

/obj/effect/icon/temp/Initialize(mapload, icon/render_source, duration)
	. = ..()
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), src), duration, TIMER_STOPPABLE | TIMER_CLIENT_TIME)
