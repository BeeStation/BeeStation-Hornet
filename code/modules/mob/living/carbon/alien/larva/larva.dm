/mob/living/carbon/alien/larva
	name = "alien larva"
	real_name = "alien larva"
	icon_state = "larva0"
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	density = FALSE
	hud_type = /datum/hud/larva

	maxHealth = 25
	health = 25
	hardcrit_threshold = HEALTH_THRESHOLD_CRIT

	rotate_on_lying = FALSE

	default_num_legs = 1
	num_legs = 1 //Alien larvas always have a movable apendage.
	usable_legs = 1 //Alien larvas always have a movable apendage.
	default_num_hands = 0

	bodyparts = list(
		/obj/item/bodypart/chest/larva,
		/obj/item/bodypart/head/larva,
		)

	var/amount_grown = 0
	var/max_grown = 100
	var/time_of_birth

	flavor_text = FLAVOR_TEXT_EVIL
	playable = TRUE


//This is fine right now, if we're adding organ specific damage this needs to be updated
/mob/living/carbon/alien/larva/Initialize(mapload)
	var/datum/action/alien/larva_evolve/evolution = new(src)
	evolution.Grant(src)
	var/datum/action/alien/hide/hide = new(src)
	hide.Grant(src)
	return ..()

/mob/living/carbon/alien/larva/create_internal_organs()
	organs += new /obj/item/organ/alien/plasmavessel/small/tiny
	..()

//This needs to be fixed
// This comment is 12 years old I hope it's fixed by now
// 14 years old idk if it's fixed
/mob/living/carbon/alien/larva/get_stat_tab_status()
	var/list/tab_data = ..()
	tab_data["Progress"] = GENERATE_STAT_TEXT("[amount_grown]/[max_grown]")
	return tab_data

/mob/living/carbon/alien/larva/adjustPlasma(amount)
	if(stat != DEAD && amount > 0)
		amount_grown = min(amount_grown + 1, max_grown)
	..(amount)

//can't equip anything
/mob/living/carbon/alien/larva/attack_ui(slot_id, params)
	return

// new damage icon system
// now constructs damage icon for each organ from mask * damage field

/mob/living/carbon/alien/larva/toggle_throw_mode()
	return

/mob/living/carbon/alien/larva/start_pulling(atom/movable/AM, state, force = move_force, supress_message = FALSE)
	return

/mob/living/carbon/alien/larva/canBeHandcuffed()
	return TRUE
