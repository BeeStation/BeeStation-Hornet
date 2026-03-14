/*
	Use this to set the substrate of a tray
	Don't worry about putting a limit on how many times we can use this, that's silly.
	Just use it to swap the substrate of a tray that isn't currently growing a plant
*/

/obj/item/substrate_bag
	name = "substrate bag"
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = "substrate_bag"
	///What substrate does this bag contain
	var/substrate = /datum/plant_subtrate

/obj/item/substrate_bag/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	var/datum/component/planter/tray_component = target.GetComponent(/datum/component/planter)
	if(!tray_component)
		return
	if(!do_after(user, 2.3 SECONDS, target))
		return
	to_chat(user, "<span class='notice'>You fill [target] from [src]</span>")
	playsound(src, 'sound/effects/shovel_dig.ogg', 60)
	tray_component.set_substrate(substrate)

/*
	Generic presets for botany
*/

/obj/item/substrate_bag/dirt
	name = "dirt substrate bag"
	icon_state = "substrate_dirt"
	substrate = /datum/plant_subtrate/dirt

/obj/item/substrate_bag/clay
	name = "clay substrate bag"
	icon_state = "substrate_clay"
	substrate = /datum/plant_subtrate/clay

/obj/item/substrate_bag/sand
	name = "sand substrate bag"
	icon_state = "substrate_sand"
	substrate = /datum/plant_subtrate/sand

/obj/item/substrate_bag/debris
	name = "debris substrate bag"
	icon_state = "substrate_debris"
	substrate = /datum/plant_subtrate/debris

/obj/item/substrate_bag/fairy
	name = "mysterious substrate bag"
	icon_state = "substrate_fairy"
	substrate = /datum/plant_subtrate/fairy
