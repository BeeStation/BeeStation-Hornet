//Similar to cultist one, except silicons are allowed
/proc/is_convertable_to_clockcult(mob/living/M)
	if(!istype(M))
		return FALSE
	if(!M.mind)
		return FALSE
	if(ishuman(M) && (M.mind.assigned_role in list(JOB_NAME_CAPTAIN, JOB_NAME_CHAPLAIN)))
		return FALSE
	if(istype(M.get_item_by_slot(ITEM_SLOT_HEAD), /obj/item/clothing/head/costume/foilhat))
		return FALSE
	if(IS_SERVANT_OF_RATVAR(M))
		return FALSE
	if(M.mind.enslaved_to && !M.mind.enslaved_to.has_antag_datum(/datum/antagonist/servant_of_ratvar))
		return FALSE
	if(M.mind.unconvertable)
		return FALSE
	if(IS_CULTIST(M) || isconstruct(M) || ispAI(M))
		return FALSE
	if(HAS_TRAIT(M, TRAIT_MINDSHIELD))
		return FALSE
	return TRUE


//==================================//
// !      Sigil of Submission     ! //
//==================================//
/datum/clockcult/scripture/create_structure/sigil_submission
	name = "Sigil of Submission"
	desc = "Summons a sigil of submission, which will convert anyone placed on top of it to the faith of Rat'var."
	tip = "Convert the crew into servants using a sigil of submission."
	button_icon_state = "Sigil of Submission"
	power_cost = 250
	invokation_time = 50
	invokation_text = list("Relax you animal...", "for I shall show you the truth.")
	summoned_structure = /obj/structure/destructible/clockwork/sigil/submission
	cogs_required = 1
	category = SPELLTYPE_SERVITUDE

//==========Submission=========
/obj/structure/destructible/clockwork/sigil/submission
	name = "sigil of submission"
	desc = "A strange sigil, with otherworldy drawings on it."
	clockwork_desc = "A sigil pulsating with a glorious light. Anyone held on top of this will become a loyal servant of Rat'var."
	icon_state = "sigilsubmission"
	effect_stand_time = 80
	idle_color = "#FFFFFF"
	invokation_color = "#e042d8"
	pulse_color = "#EBC670"
	fail_color = "#d43333"

/obj/structure/destructible/clockwork/sigil/submission/can_affect(mob/living/M)
	if(!..())
		return FALSE
	return is_convertable_to_clockcult(M)

/obj/structure/destructible/clockwork/sigil/submission/apply_effects(mob/living/M)
	if(!..())
		M.visible_message(span_warning("[M] resists conversion!"))
		return FALSE
	M.Paralyze(50)
	if(M.client)
		var/previous_colour = M.client.color
		M.client.color = LIGHT_COLOR_CLOCKWORK
		animate(M.client, color=previous_colour, time=10)
	var/datum/antagonist/servant_of_ratvar/R = add_servant_of_ratvar(M)
	R.equip_servant_conversion()
