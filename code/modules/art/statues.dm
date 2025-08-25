//Statues stuff goes above chisels

///////////Other Stuff//////////////////////////////////////////////
/obj/item/chisel
	name = "chisel"
	desc = "Breaking and making art since 4000 BC. This one uses advanced technology to allow the creation of lifelike moving statues."
	icon = 'icons/obj/art/statue.dmi'
	icon_state = "chisel"
	item_state = "screwdriver_nuke"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	force = 5
	w_class = WEIGHT_CLASS_TINY
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	custom_materials = list(/datum/material/iron=75)
	attack_verb_continuous = list("stabs")
	attack_verb_simple = list("stab")
	hitsound = 'sound/items/weapons/bladeslice.ogg'
	usesound = list('sound/effects/pickaxe/picaxe1.ogg', 'sound/effects/pickaxe/picaxe2.ogg', 'sound/effects/pickaxe/picaxe3.ogg')
	drop_sound = 'sound/items/handling/screwdriver_drop.ogg'
	pickup_sound = 'sound/items/handling/screwdriver_pickup.ogg'
	sharpness = SHARP
	tool_behaviour = TOOL_RUSTSCRAPER
	toolspeed = 3 // You're gonna have a bad time

	/// Block we're currently carving in
	//var/obj/structure/carving_block/prepared_block
	/// If tracked user moves we stop sculpting
	var/mob/living/tracked_user
	/// Currently sculpting
	//var/sculpting = FALSE

/obj/item/chisel/Initialize(mapload)
	. = ..()
	//AddElement(/datum/element/eyestab)
	AddElement(/datum/element/wall_engraver)
	//deals 200 damage to statues, meaning you can actually kill one in ~250 hits
	//AddElement(/datum/element/bane, target_type = /mob/living/basic/statue, damage_multiplier = 40)

/obj/item/chisel/Destroy()
	//prepared_block = null
	tracked_user = null
	return ..()
