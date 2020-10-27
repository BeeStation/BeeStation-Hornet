//This file contains main code about ancient red liquid. The purpose of it is to charge armor, enrage bosses and maybe(?) allow you to go to another more dangerous Z.

/obj/structure/lavaland/power_collector
	name = "ancient device"
	desc = "A strange rock-mounted device with it's upper part is floating in air. Looks like it is intended to... collect something?"
	icon = 'icons/obj/lavaland/power_filler.dmi'
	icon_state = "power_collector_off"

	move_resist = INFINITY //Nope

	anchored = TRUE
	density = TRUE
	resistance_flags = FIRE_PROOF | LAVA_PROOF | ACID_PROOF
	max_integrity = 780 //An ANCIENT device. Also, it is quite valuable to pro-miners since it's the only way to go and fight super fauna

	var/obj/item/power_tube/power_tube = null
	var/collecting = FALSE //Is animation goin?

/obj/structure/lavaland/power_collector/Initialize()
	. = ..()
	if(prob(15)) //A small chance that there will already be a power tube
		power_tube = new(src)
		power_tube.filled = TRUE
		update_icon()
		power_tube.update_icon()

/obj/structure/lavaland/power_collector/attack_hand(mob/user)
	if(!power_tube)
		return
	if(collecting)
		to_chat(user, "<span class = 'warning'>The [src] emits a strange sound and beeps, \"Please, wait until the procedure is complete\".</span>")
		return

	power_tube.forceMove(get_turf(user))
	user.put_in_hands(power_tube)
	power_tube = null
	update_icon()

/obj/structure/lavaland/power_collector/attackby(obj/item/A, mob/user, params)
	if(istype(A, /obj/item/power_tube))
		power_tube = A
		to_chat(user, "<span class = 'notice'>You carefully put [A] into the [src].</span>")
		power_tube.forceMove(src)
		update_icon()
		fill_up()
		return
	. = ..()

/obj/structure/lavaland/power_collector/proc/fill_up()
	if(!power_tube)
		return
	if(collecting)
		return

	if(power_tube.filled)
		return

	visible_message("<span class = 'notice'>[src] starts slowly filling [power_tube].</span>")

	flick("power_collector_on", src)

	power_tube.filled = TRUE

	update_icon()
	power_tube.update_icon()

/obj/structure/lavaland/power_collector/update_icon_state()
	if(power_tube)
		if(power_tube.filled)
			icon_state = "power_collector_on_full"
		else
			icon_state = "power_collector_on_empty"
	else
		icon_state = "power_collector_off"

/obj/item/power_tube
	name = "ancient cylinder"
	desc = "A strange cylinder with a tap on it's top. Looks like it's intended to contain something."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "energy_cylinder_empty"
	resistance_flags = FIRE_PROOF | LAVA_PROOF | ACID_PROOF //nope

	var/filled = FALSE

/obj/item/power_tube/update_icon_state()
	if(filled)
		icon_state = "energy_cylinder_full"
	else
		icon_state = "energy_cylinder_empty"

/obj/item/power_tube/filled
	filled = TRUE
	icon_state = "energy_cylinder_full"