/obj/item/deployable/capsule
	name = "bluespace capsule"
	desc = "A small capsule that utilizes bluespace technology to store items in a very compact space."
	icon = 'icons/obj/device.dmi'
	icon_state = "capsule"
	w_class = WEIGHT_CLASS_TINY
	deployed_object = /obj/structure/closet/crate/capsule
	var/active = FALSE
	var/activation_delay = 3 SECONDS

/obj/item/deployable/capsule/update_icon()
	cut_overlays()
	icon_state = "capsule[active ? "_activated" : ""]"

/obj/item/deployable/capsule/try_deploy(mob/user, atom/location)
	if(..())
		return TRUE
	playsound(src, 'sound/machines/button2.ogg', 15, 1)
	active = FALSE
	update_icon()

/obj/item/deployable/capsule/deploy(mob/user, atom/location)
	if(!active)
		return
	..()

/obj/item/deployable/capsule/attack_self(mob/user)
	playsound(src, 'sound/machines/button2.ogg', 15, 1)
	activate_capsule(user)

/obj/item/deployable/capsule/proc/activate_capsule(mob/user)
	if(active)
		return
	active = TRUE
	addtimer(CALLBACK(src, PROC_REF(try_deploy), user), activation_delay)
	update_icon()
