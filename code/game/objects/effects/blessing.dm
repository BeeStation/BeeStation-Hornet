/obj/effect/blessing
	name = "holy blessing"
	desc = "Holy energies interfere with ethereal travel at this location."
	icon = 'icons/effects/effects.dmi'
	icon_state = null
	anchored = TRUE
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/blessing/Initialize(mapload)
	. = ..()
	var/image/holy_effect = image(icon = 'icons/effects/effects.dmi', icon_state = "blessed", layer = ABOVE_OPEN_TURF_LAYER, loc = src)
	holy_effect.alpha = 64
	holy_effect.appearance_flags = RESET_ALPHA
	SSclient_vision.safe_stack_client_images(src, CLIVIS_KEY_HOLYTURF, holy_effect, cve_flags = CVE_FLAGS_CUT_IMAGE_ON_QDEL)
	RegisterSignal(loc, COMSIG_ATOM_INTERCEPT_TELEPORT, PROC_REF(block_cult_teleport))

/obj/effect/blessing/Destroy()
	UnregisterSignal(loc, COMSIG_ATOM_INTERCEPT_TELEPORT)
	return ..()

/obj/effect/blessing/proc/block_cult_teleport(datum/source, channel, turf/origin, turf/destination)
	SIGNAL_HANDLER

	if(channel == TELEPORT_CHANNEL_CULT)
		return COMPONENT_BLOCK_TELEPORT
