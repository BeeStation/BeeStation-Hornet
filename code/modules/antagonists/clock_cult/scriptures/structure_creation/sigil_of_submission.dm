/datum/clockcult/scripture/create_structure/sigil_submission
	name = "Sigil of Submission"
	desc = "Summons a sigil of submission, which will convert anyone placed on top of it to the faith of Rat'var."
	tip = "Convert the crew into servants using a sigil of submission."
	invokation_text = list("Relax you animal...", "for I shall show you the truth.")
	invokation_time = 5 SECONDS
	button_icon_state = "Sigil of Submission"
	power_cost = 250
	cogs_required = 1
	summoned_structure = /obj/structure/destructible/clockwork/sigil/submission
	category = SPELLTYPE_SERVITUDE

/obj/structure/destructible/clockwork/sigil/submission
	name = "sigil of submission"
	desc = "A strange sigil, with otherworldy drawings on it."
	clockwork_desc = span_brass("A sigil pulsating with a glorious light. Anyone held on top of this will become a loyal servant of Rat'var.")
	icon_state = "sigilsubmission"
	effect_charge_time = 8 SECONDS
	idle_color = COLOR_WHITE
	invokation_color = "#e042d8"
	success_color = "#EBC670"
	fail_color = "#d43333"

/obj/structure/destructible/clockwork/sigil/submission/can_affect(atom/movable/target_atom)
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/living_target = target_atom
	if(!is_convertable_to_clockcult(living_target))
		return FALSE

/obj/structure/destructible/clockwork/sigil/submission/apply_effects()
	var/mob/living/living_target = affected_atom

	// Paralyze
	living_target.Paralyze(5 SECONDS)

	// Apply flavor color
	if(living_target.client)
		var/previous_colour = living_target.client.color
		living_target.client.color = LIGHT_COLOR_CLOCKWORK
		animate(living_target.client, color = previous_colour, time = 1 SECONDS)

	// Convert
	var/datum/antagonist/servant_of_ratvar/cogger = add_servant_of_ratvar(living_target)
	cogger.equip_servant_conversion()
	return ..()

/obj/structure/destructible/clockwork/sigil/submission/on_fail()
	var/mob/living/living_target = affected_atom
	living_target.visible_message(span_warning("[living_target] resists conversion!"))
	return ..()

// Similar to cultist one, except silicons are allowed
/proc/is_convertable_to_clockcult(mob/living/convertee)
	if(!istype(convertee))
		return FALSE
	if(!convertee.mind)
		return FALSE
	if(ishuman(convertee) && (convertee.mind.assigned_role in list(JOB_NAME_CAPTAIN, JOB_NAME_CHAPLAIN)))
		return FALSE
	if(istype(convertee.get_item_by_slot(ITEM_SLOT_HEAD), /obj/item/clothing/head/costume/foilhat))
		return FALSE
	if(IS_SERVANT_OF_RATVAR(convertee))
		return FALSE
	if(convertee.mind.enslaved_to && !convertee.mind.enslaved_to.has_antag_datum(/datum/antagonist/servant_of_ratvar))
		return FALSE
	if(convertee.mind.unconvertable)
		return FALSE
	if(IS_CULTIST(convertee) || isconstruct(convertee) || ispAI(convertee))
		return FALSE
	if(HAS_TRAIT(convertee, TRAIT_MINDSHIELD))
		return FALSE
	return TRUE
