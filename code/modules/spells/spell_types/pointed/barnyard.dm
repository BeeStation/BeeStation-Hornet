/datum/action/spell/pointed/barnyardcurse
	name = "Curse of the Barnyard"
	desc = "This spell dooms an unlucky soul to possess the speech and facial attributes of a barnyard animal."
	button_icon_state = "barn"
	ranged_mousepointer = 'icons/effects/mouse_pointers/barn_target.dmi'

	school = SCHOOL_TRANSMUTATION
	cooldown_time = 15 SECONDS
	cooldown_reduction_per_rank = 3 SECONDS

	invocation = "KN'A FTAGHU, PUCK 'BTHNK!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

	active_msg = "You prepare to curse a target..."
	deactive_msg = "You dispel the curse."

/datum/action/spell/pointed/barnyardcurse/is_valid_spell(mob/user, atom/target)
	. = ..()
	if(!.)
		return FALSE
	if (target == user)
		return FALSE
	if(!ishuman(target))
		return FALSE

	var/mob/living/carbon/human/human_target = target
	if(!human_target.wear_mask)
		return TRUE

	return !(human_target.wear_mask.type in GLOB.cursed_animal_masks)

/datum/action/spell/pointed/barnyardcurse/on_cast(mob/user, mob/living/carbon/human/target)
	. = ..()
	if(target.can_block_magic(antimagic_flags))
		target.visible_message(
			("<span class='danger'>[target]'s face bursts into flames, which instantly burst outward, leaving [target.p_them()] unharmed!</span>"),
			("<span class='danger'>Your face starts burning up, but the flames are repulsed by your anti-magic protection!</span>"),
		)
		to_chat(owner, ("<span class='warning'>The spell had no effect!</span>"))
		return FALSE

	var/chosen_type = pick(GLOB.cursed_animal_masks)
	var/obj/item/clothing/mask/cursed_mask = new chosen_type(get_turf(target))

	target.visible_message(
		("<span class='danger'>[target]'s face bursts into flames, and a barnyard animal's head takes its place!</span>"),
		("<span class='userdanger'>Your face burns up, and shortly after the fire you realise you have the [cursed_mask.name]!</span>"),
	)

	// Can't drop? Nuke it
	if(!target.dropItemToGround(target.wear_mask))
		qdel(target.wear_mask)

	target.equip_to_slot_if_possible(cursed_mask, ITEM_SLOT_MASK, TRUE, TRUE)
	target.flash_act()
	return TRUE
