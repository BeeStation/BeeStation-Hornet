/obj/item/implant/uplink
	name = "uplink implant"
	desc = "Sneeki breeki."
	icon = 'icons/obj/radio.dmi'
	icon_state = "radio"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	var/starting_tc = 0
	/// The uplink flags of the implant uplink inside, only checked during initialisation so modifying it after initialisation will do nothing
	var/uplink_flag = UPLINK_TRAITORS

/obj/item/implant/uplink/Initialize(mapload, owner, uplink_flag)
	. = ..()
	AddComponent(/datum/component/uplink, _owner = owner, _lockable = TRUE, _enabled = FALSE, uplink_flag = uplink_flag, starting_tc = starting_tc)
	RegisterSignal(src, COMSIG_COMPONENT_REMOVING, .proc/_component_removal)

/obj/item/implant/uplink/proc/_component_removal(datum/source, datum/component/component)
	SIGNAL_HANDLER
	if(istype(component, /datum/component/uplink))
		qdel(src)

/obj/item/implanter/uplink
	name = "implanter (uplink)"
	imp_type = /obj/item/implant/uplink

/obj/item/implanter/uplink/Initialize(mapload, uplink_flag = UPLINK_TRAITORS)
	imp = new imp_type(src, null, uplink_flag)
	. = ..()

/obj/item/implanter/uplink/precharged
	name = "implanter (precharged uplink)"
	imp_type = /obj/item/implant/uplink/precharged

/obj/item/implant/uplink/precharged
	starting_tc = 10
