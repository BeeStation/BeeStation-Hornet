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
	clockwork_desc = "A sigil pulsating with a glorious light. Anyone held on top of this will become a loyal servant of Rat'var."
	icon_state = "sigilsubmission"
	effect_charge_time = 8 SECONDS
	idle_color = "#FFFFFF"
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
	. = ..()

/obj/structure/destructible/clockwork/sigil/submission/on_fail()
	var/mob/living/living_target = affected_atom
	living_target.visible_message(span_warning("[living_target] resists conversion!"))
	. = ..()
