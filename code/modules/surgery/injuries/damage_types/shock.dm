/datum/injury/acute/shock
	base_type = /datum/injury/acute/shock
	examine_description = "<b>neuromuscular incapacitation</b>"
	heal_description = "The effects of this injury will naturally dissipate over time."
	max_absorption = 0
	external = FALSE
	damage_multiplier = 0
	injury_flags = INJURY_LIMB
	pain_multiplier = 1.4
	var/stam_regen_start_time

/datum/injury/acute/shock/adjust_progression(delta_damage)
	. = ..()
	// Block regeneration
	if (delta_damage > 0)
		stam_regen_start_time = world.time + STAMINA_REGEN_BLOCK_TIME

/datum/injury/acute/shock/update_progressive_effects()
	pain = progression
	effectiveness_modifier = CLAMP01(1 - ((progression * 0.25) / bodypart.max_damage))

/datum/injury/acute/shock/on_tick(mob/living/carbon/human/target, delta_time)
	. = ..()
	if (world.time > stam_regen_start_time)
		return
	// TODO: Replicate old stamina healing behaviour, don't allow
	// the victim to be stunlocked forever inside of pain-crit.
	var/heal_rate = clamp(progression / 50, 1, 2)
	adjust_progression(-1 * heal_rate * delta_time)
