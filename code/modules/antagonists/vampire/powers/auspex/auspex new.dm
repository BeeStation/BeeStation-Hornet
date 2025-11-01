/**
 *	# Auspex
 *
 *	Level 1 - Raise sightrange by 1, project sight 2 tiles ahead.
 *	Level 2 - Raise sightrange by 2, project sight 4 tiles ahead. Meson Vision
 *	Level 3 - Raise sightrange by 3, project sight 6 tiles ahead.
 *	Level 4 - Raise sightrange by 4, project sight 8 tiles ahead. Xray Vision
 *	Level 5 - For Malkavians: Gain ability to astral project like a wizard.
 */
/datum/action/vampire/auspex
	name = "Auspex(Level 1)"
	upgraded_power = /datum/action/vampire/two
	level_current = 1
	desc = "Sense the vitae of any creature directly, and use your keen senses to widen your perception."
	button_icon_state = "power_auspex"
	power_explanation = "When Activated, you will see further."
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	bloodcost = 5
	constant_bloodcost = 2
	cooldown_time = 10 SECONDS
	discipline = DISCIPLINE_AUSPEX

/datum/action/vampire/two
	name = "Auspex(Level 2)"
	upgraded_power = /datum/action/vampire/auspex/three
	level_current = 2
	power_explanation = "When Activated, you will see further, and be able to sense walls and the layout of rooms."
	bloodcost = 10
	cooldown_time = 10 SECONDS

/datum/action/vampire/auspex/three
	name = "Auspex(Level 3)"
	upgraded_power = /datum/action/vampire/auspex/four
	level_current = 3
	power_explanation = "When Activated, you will see further, and be able to sense walls and the layout of rooms."
	bloodcost = 15
	cooldown_time = 10 SECONDS

/datum/action/vampire/auspex/four
	name = "Auspex(Level 4)"
	upgraded_power = /datum/action/vampire/auspex/advanced
	level_current = 4
	power_explanation = "When Activated, you will see further, and be able to sense anything in sight, seeing through walls and barriers as if they were glass."
	bloodcost = 20
	cooldown_time = 10 SECONDS

/datum/action/vampire/auspex/advanced
	name = "Auspex(Max Level)"
	upgraded_power = null
	level_current = 5
	desc = "The power of your blood empowers your auspex. Become able to project your consciousness outside your body."
	power_explanation = "When Activated, you will become a ghost.\n\
		Visit anywhere you like, watch anyone you want.\n\
		Talk to the dead, and know all things."
	background_icon_state_on = "tremere_power_gold_on"
	background_icon_state_off = "tremere_power_gold_off"
	bloodcost = 20
	cooldown_time = 10 SECONDS
	discipline = DISCIPLINE_AUSPEX_MALKAVIAN	//They may see flying monkeys eating your eyes while you talk to them, but maybe those are real.

/datum/action/vampire/targeted/tremere/auspex/activate_power()
	. = ..()
	owner.AddElement(/datum/element/digital_camo)
	animate(owner, alpha = 15, time = 1 SECONDS)

/datum/action/vampire/targeted/tremere/auspex/deactivate_power()
	animate(owner, alpha = 255, time = 1 SECONDS)
	owner.RemoveElement(/datum/element/digital_camo)
	return ..()
