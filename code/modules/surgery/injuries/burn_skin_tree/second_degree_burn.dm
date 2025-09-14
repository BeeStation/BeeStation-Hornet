/datum/injury/second_degree_burns
	base_type = /datum/injury/healthy_skin_burn
	skin_armour_modifier = 0.6
	effectiveness_modifier = 0.6
	surgeries_provided = list(/datum/surgery/skin_graft)
	severity_level = INJURY_PRIORITY_ACTIVE
	health_doll_icon = "blood"
	examine_description = "<b>second-degree burns</b>"
	healed_type = /datum/injury/treated_burn
	heal_description = "The victim can be treated with 5 units of advanced burn gel applied via patch to the site of the injury."
	pain = 25
	external = TRUE
	progression = 50
	injury_flags = INJURY_LIMB | INJURY_GRAPH

/datum/injury/second_degree_burns/on_damage_taken(total_damage, delta_damage, damage_type = BRUTE, damage_flag = DAMAGE_STANDARD, is_sharp = FALSE)
	if (damage_type != BURN)
		return FALSE
	if (total_damage >= 25 || delta_damage >= 5)
		transition_to(/datum/injury/third_degree_burn)
	return TRUE

/datum/injury/second_degree_burns/gain_message(mob/living/carbon/human/target, obj/item/bodypart/part)
	to_chat(target, span_userdanger("The burns on your [part.plaintext_zone] intensify."))

/datum/injury/second_degree_burns/on_tick(mob/living/carbon/human/target, delta_time)
	if (DT_PROB(5, delta_time) && !target.is_bleeding())
		to_chat(target, span_warning("A red-fluid seeps out of the burns on your [bodypart.plaintext_zone]."))
		target.add_bleeding(BLEED_SURFACE)

/datum/injury/second_degree_burns/apply_to_part(obj/item/bodypart/part)
	// If we lose the injury, stop the timer
	addtimer(CALLBACK(src, PROC_REF(check_heal), part), rand(5 MINUTES, 15 MINUTES), TIMER_DELETE_ME)

/datum/injury/second_degree_burns/proc/check_heal(obj/item/bodypart/part)
	//if (prob(60))
		// Gain an infection
	// Heal the blisters
	transition_to(/datum/injury/repaired_skin_burn)

/datum/injury/second_degree_burns/intercept_reagent_exposure(datum/reagent, mob/living/victim, method, reac_volume, touch_protection)
	if (!istype(reagent, /datum/reagent/medicine/advanced_burn_gel))
		return
	if (reac_volume < 5)
		to_chat(victim, span_warning("The pain in your second-degree burns start to numb, however they do not fully subside. It wasn't enough!"))
		return
	if (method != TOUCH && method != PATCH)
		return
	heal()
