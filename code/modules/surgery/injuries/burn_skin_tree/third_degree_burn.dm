/datum/injury/third_degree_burn
	skin_armour_modifier = 0.4
	effectiveness_modifier = 0
	surgeries_provided = list(/datum/surgery/skin_graft)
	health_doll_icon = "blood"
	examine_description = "<b>third-degree burns</b>"
	healed_type = /datum/injury/restored_skin_burn

/datum/injury/third_degree_burn/gain_message(mob/living/carbon/human/target, obj/item/bodypart/part)
	to_chat(target, span_userdanger("The burns on your [part.plaintext_zone] intensify."))

/datum/injury/third_degree_burn/on_tick(mob/living/carbon/human/target, delta_time)
	if (DT_PROB(10, delta_time) && !target.is_bleeding())
		to_chat(target, span_warning("A red-fluid seeps out of the burns on your [bodypart.plaintext_zone]."))
		target.add_bleeding(BLEED_CRITICAL)
	// Gain organ damage over time
	for (var/slot in bodypart.organ_slots)
		var/obj/item/organ/organ = target.getorganslot(slot)
		if (!organ)
			continue
		if (!prob(organ.organ_size))
			continue
		organ.applyOrganDamage(delta_time * ORGAN_DAMAGE_MULTIPLIER)

/datum/injury/third_degree_burn/on_damage_taken(total_damage, delta_damage, damage_type = BRUTE, damage_flag = DAMAGE_STANDARD, is_sharp = FALSE)
	if (damage_type != BURN)
		return FALSE
	if (total_damage >= 25 || delta_damage >= 5)
		transition_to(/datum/injury/limb_destroyed)
	return TRUE
