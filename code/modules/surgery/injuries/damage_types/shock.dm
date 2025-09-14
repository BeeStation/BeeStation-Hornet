/datum/injury/acute/shock
	base_type = /datum/injury/acute/shock
	examine_description = "<b>neuromuscular incapacitation</b>"
	heal_description = "The effects of this injury will naturally dissipate over time."
	max_absorption = 0
	external = FALSE
	damage_multiplier = 0

/datum/injury/acute/shock/update_progressive_effects()
	pain = progression
	effectiveness_modifier = CLAMP01(1 - ((progression * 0.25) / bodypart.max_damage))
