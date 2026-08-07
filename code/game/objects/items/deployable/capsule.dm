/obj/item/bluespace_capsule
	name = "bluespace capsule"
	desc = "A small capsule that utilizes bluespace technology to store items in a very compact space."
	icon = 'icons/obj/device.dmi'
	icon_state = "capsule"
	w_class = WEIGHT_CLASS_TINY
	var/active = FALSE
	var/activation_delay = 3 SECONDS

/obj/item/bluespace_capsule/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/deployable, /obj/structure/closet/crate/capsule)

/obj/item/bluespace_capsule/update_icon()
	cut_overlays()
	icon_state = "capsule[active ? "_activated" : ""]"

/obj/item/bluespace_capsule/proc/try_deploy(mob/user, atom/location)
	if (SEND_SIGNAL(src, COMSIG_DEPLOYABLE_FORCE_DEPLOY, location))
		return TRUE
	playsound(src, 'sound/machines/button2.ogg', 15, 1)
	active = FALSE
	update_icon()

/obj/item/bluespace_capsule/attack_self(mob/user)
	playsound(src, 'sound/machines/button2.ogg', 15, 1)
	activate_capsule(user)

/obj/item/bluespace_capsule/proc/activate_capsule(mob/user)
	if(active)
		return
	active = TRUE
	addtimer(CALLBACK(src, PROC_REF(try_deploy), user), activation_delay)
	update_icon()
