/datum/injury/shock
	examine_description = "<b>neuromuscular incapacitation</b>"
	heal_description = "The effects of this injury will naturally dissipate over time."
	max_absorption = 0
	external = FALSE
	damage_multiplier = 0

/datum/injury/shock/on_progression_changed()
	pain = progression
	effectiveness_modifier = CLAMP01(1 - ((progression * 0.25) / bodypart.max_damage))
