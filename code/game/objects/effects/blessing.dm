/obj/effect/blessing
	name = "holy blessing"
	desc = "Holy energies interfere with ethereal travel at this location."
	icon = 'icons/effects/effects.dmi'
	icon_state = null
	anchored = TRUE
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/image/holy_effect

/obj/effect/blessing/Initialize(mapload)
	. = ..()
	holy_effect = image(icon = 'icons/effects/effects.dmi', icon_state = "blessed", layer = ABOVE_OPEN_TURF_LAYER, loc = src)
	holy_effect.alpha = 64
	holy_effect.appearance_flags = RESET_ALPHA
	GLOB.cimg_controller.stack_client_images(CIMG_KEY_HOLYTURF, holy_effect)
	RegisterSignal(loc, COMSIG_ATOM_INTERCEPT_TELEPORT, PROC_REF(block_cult_teleport))

/obj/effect/blessing/Destroy()
	UnregisterSignal(loc, COMSIG_ATOM_INTERCEPT_TELEPORT)
	GLOB.cimg_controller.cut_client_images(CIMG_KEY_HOLYTURF, holy_effect)
	holy_effect = null
	return ..()

/obj/effect/blessing/proc/block_cult_teleport(datum/source, channel, turf/origin, turf/destination)
	SIGNAL_HANDLER

	if(channel == TELEPORT_CHANNEL_CULT)
		return COMPONENT_BLOCK_TELEPORT
