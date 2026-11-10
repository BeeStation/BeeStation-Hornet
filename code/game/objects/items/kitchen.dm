/* Kitchen tools
 * Contains:
 *		Fork
 *		Kitchen knives
 *		Ritual Knife
 *		Butcher's cleaver
 *		Combat Knife
 *		Rolling Pins
 *      Poison Knife
 */

/obj/item/kitchen
	abstract_type = /obj/item/kitchen
	icon = 'icons/obj/service/kitchen.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	item_flags = ISWEAPON

/obj/item/kitchen/fork
	name = "fork"
	desc = "Pointy."
	icon_state = "fork"
	force = 5
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	throw_speed = 3
	throw_range = 5
	custom_price = 5 /// Silly useless thing
	custom_materials = list(/datum/material/iron=80)
	obj_flags = CONDUCTS_ELECTRICITY
	attack_verb_continuous = list("attacks", "stabs", "pokes")
	attack_verb_simple = list("attack", "stab", "poke")
	hitsound = 'sound/weapons/bladeslice.ogg'
	armor_type = /datum/armor/kitchen_fork
	/// overlay ontop a utensil
	var/food_overlay_state = "forkloaded"
	var/bite_word = "forkful"
	var/eat_sound = 'sound/items/eatfood.ogg'
	var/scoops_soup = FALSE


/datum/armor/kitchen_fork
	fire = 50
	acid = 30

/obj/item/kitchen/fork/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] stabs \the [src] into [user.p_their()] chest! It looks like [user.p_theyre()] trying to take a bite out of [user.p_them()]self!"))
	playsound(src, 'sound/items/eatfood.ogg', 50, 1)
	return BRUTELOSS

/obj/item/kitchen/fork/Initialize(mapload)
	create_reagents(5, NO_REACT)
	return ..()

/obj/item/kitchen/fork/update_overlays()
	. = ..()
	if(reagents.total_volume)
		. += mutable_appearance(icon, food_overlay_state, appearance_flags = RESET_COLOR, color = mix_color_from_reagents(reagents.reagent_list))

/obj/item/kitchen/fork/proc/can_scoop(atom/food, mob/user)
	if(reagents.total_volume)
		to_chat(user, span_warning("You already have food on your [name]!"))
		return FALSE
	if(istype(food, /obj/item/food/soup) == scoops_soup)
		return TRUE
	if(scoops_soup)
		to_chat(user, span_warning("[food] doesn't seem to fit on your [name]! Maybe try a fork."))
	else
		to_chat(user, span_warning("You try to scoop up [food] with your [name], but it slips through the prongs! Maybe try a spoon."))
	return FALSE

/obj/item/kitchen/fork/attack(mob/living/carbon/eating_person, mob/living/carbon/user)
	if(!istype(eating_person))
		return ..()

	if(reagents.total_volume)
		var/obj/item/covering = eating_person.is_mouth_covered()
		if(covering)
			to_chat(user, span_warning("You have to remove [eating_person == user ? "your" : "[eating_person.p_their()]"] [covering.name] first!"))
			return
		if(eating_person != user)
			eating_person.visible_message(span_notice("[user] starts feeding [eating_person] a [bite_word] of food..."), span_userdanger("[user] starts feeding you a [bite_word]..."))
			if(!do_after(user, 1.5 SECONDS, eating_person, extra_checks = CALLBACK(src, PROC_REF(can_feed_loaded))))
				return
			log_combat(user, eating_person, "fed", reagents.log_list(), important = FALSE)
			eating_person.visible_message(span_notice("[user] feeds [eating_person] a [bite_word] of food!"))
		else
			eating_person.visible_message(span_notice("[user] eats a [bite_word] of food!"), span_notice("You eat a [bite_word] of food!"))
		playsound(eating_person, eat_sound, 25, TRUE)
		reagents.trans_to(eating_person, reagents.total_volume, transfered_by = user, method = INGEST)
		update_appearance()
		return
	else if(user.is_zone_selected(BODY_ZONE_PRECISE_EYES, precise_only = TRUE) && user.is_zone_selected(BODY_GROUP_CHEST_HEAD))
		if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
			eating_person = user
		if (eyestab(eating_person, user, src, silent = user.is_zone_selected(BODY_GROUP_CHEST_HEAD)))
			return TRUE
	return ..()

/obj/item/kitchen/fork/proc/can_feed_loaded()
	return reagents.total_volume > 0

/obj/item/kitchen/fork/spoon
	name = "spoon"
	desc = "Like a fork, but more round and shallow."
	icon_state = "spoon"
	food_overlay_state = "spoonloaded"
	bite_word = "spoonful"
	eat_sound = 'sound/items/drink.ogg'
	scoops_soup = TRUE
	attack_verb_continuous = list("attacks", "slaps", "pokes")
	attack_verb_simple = list("attack", "slap", "poke")

/obj/item/knife/kitchen
	name = "kitchen knife"
	desc = "A general purpose Chef's Knife made by SpaceCook Incorporated. Guaranteed to stay sharp for years to come."

/obj/item/kitchen/rollingpin
	name = "rolling pin"
	desc = "Used to knock out the Bartender."
	icon_state = "rolling_pin"
	force = 8
	throwforce = 5
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/wood = MINERAL_MATERIAL_AMOUNT * 1.5)
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb_continuous = list("bashes", "batters", "bludgeons", "thrashes", "whacks")
	attack_verb_simple = list("bash", "batter", "bludgeon", "thrash", "whack")
	custom_price = 20
	tool_behaviour = TOOL_ROLLINGPIN

/obj/item/kitchen/rollingpin/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins flattening [user.p_their()] head with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS
