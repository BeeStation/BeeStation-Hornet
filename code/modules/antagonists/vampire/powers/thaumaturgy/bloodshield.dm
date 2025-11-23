/datum/action/vampire/bloodshield
	name = "Thaumaturgy: Blood Shield"
	desc = "Create a Blood shield to protect yourself from damage."
	button_icon_state = "power_thaumaturgy"
	background_icon_state_on = "tremere_power_gold_on"
	background_icon_state_off = "tremere_power_gold_off"
	power_explanation = "Activating Thaumaturgy will temporarily give you a Blood Shield.\n\
		The blood shield has very good block power, but costs 15 Blood per hit to maintain."

	power_flags = BP_AM_TOGGLE | BP_AM_STATIC_COOLDOWN
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS

	vitaecost = 50
	cooldown_time = 10 SECONDS
	constant_vitaecost = 6

	/// Blood shield given while this Power is active.
	var/datum/weakref/blood_shield

/datum/action/vampire/bloodshield/activate_power()
	. = ..()
	var/obj/item/shield/vampire/new_shield = new
	blood_shield = WEAKREF(new_shield)
	if(!owner.put_in_inactive_hand(new_shield))
		owner.balloon_alert(owner, "off hand is full!")
		to_chat(owner, span_notice("Blood shield couldn't be activated as your off hand is full."))
		deactivate_power()
		return FALSE
	owner.visible_message(
		span_warning("[owner] 's hands begins to bleed and forms into a blood shield!"),
		span_warning("We activate our Blood shield!"),
		span_hear("You hear liquids forming together."))

/datum/action/vampire/bloodshield/deactivate_power()
	. = ..()
	to_chat(owner, span_notice("Blood shield couldn't be activated as your off hand is full."))
	if(blood_shield)
		QDEL_NULL(blood_shield)

/**
 *	# Blood Shield
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
	block_power = 100

/obj/item/shield/vampire/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, TRAIT_VAMPIRE)

/obj/item/shield/vampire/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	var/datum/antagonist/vampire/vampire = IS_VAMPIRE(owner)
	vampire?.AdjustBloodVolume(-15)
	return ..()
