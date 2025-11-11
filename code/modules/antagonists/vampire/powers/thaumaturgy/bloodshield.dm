/datum/action/vampire/targeted/tremere/thaumaturgy/two
	name = "Level 2: Thaumaturgy"
	upgraded_power = /datum/action/vampire/targeted/tremere/thaumaturgy/three
	desc = "Create a Blood shield and fire a blood bolt at your enemy, dealing Burn damage."
	level_current = 2
	power_explanation = "Activating Thaumaturgy will temporarily give you a Blood Shield.\n\
		The blood shield has a 75% block chance, but costs 15 Blood per hit to maintain.\n\
		You can also fire a blood bolt which will deactivate your shield."
	prefire_message = "Click where you wish to fire (using your power removes blood shield)."
	bloodcost = 40
	cooldown_time = 4 SECONDS


/**
 *	# Blood Shield
 *
 *	The shield spawned when using Thaumaturgy when strong enough.
 *	Copied mostly from '/obj/item/shield/changeling'
 */
/obj/item/shield/vampire
	name = "blood shield"
	desc = "A shield made out of blood, requiring blood to sustain hits."
	item_flags = ABSTRACT | DROPDEL
	icon = 'icons/vampires/vamp_obj.dmi'
	icon_state = "blood_shield"
	lefthand_file = 'icons/vampires/bs_leftinhand.dmi'
	righthand_file = 'icons/vampires/bs_rightinhand.dmi'
	block_power = 75

/obj/item/shield/vampire/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, TRAIT_VAMPIRE)

/obj/item/shield/vampire/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	var/datum/antagonist/vampire/vampire = IS_VAMPIRE(owner)
	vampire?.AddBloodVolume(-15)
	return ..()
