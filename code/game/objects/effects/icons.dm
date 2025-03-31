//This particular effect should never be visible in a context menu
// or clickable, unlike other effects
/obj/effect/icon
	name = ""
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

CREATION_TEST_IGNORE_SUBTYPES(/obj/effect/icon)

/obj/effect/icon/Initialize(mapload, icon/render_source)
	. = ..()
	overlays = list(render_source)

CREATION_TEST_IGNORE_SUBTYPES(/obj/effect/icon/temp)

/obj/effect/icon/temp/Initialize(mapload, icon/render_source, duration)
	. = ..()
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), src), duration, TIMER_STOPPABLE | TIMER_CLIENT_TIME)
