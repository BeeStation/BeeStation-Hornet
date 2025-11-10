/datum/action/vampire/targeted/pact
	name = "Beast Pact"
	desc = "Form a pact with a beast of your choice. It must not have prior allegiances. Higher levels increase the power of a pact-bond."
	button_icon_state = "power_beckon"
	power_explanation = "Click on a dog-type beast to forge a pact.\n\
		With higher levels, the beast gains vitality and attack power upon bonding.\n\
		Important: The boost is only applied once, at the time of bonding. Further uses of the ability heal the beast."
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	bloodcost = 15
	sol_multiplier = 2
	cooldown_time = 60 SECONDS
	target_range = 15
	power_activates_immediately = FALSE

	var/bonus_health = 10
	var/bonus_damage = 5

/datum/action/vampire/targeted/pact/two
	bloodcost = 30

	bonus_health = 30
	bonus_damage = 10

/datum/action/vampire/targeted/pact/three
	bloodcost = 45

	bonus_health = 50
	bonus_damage = 15

/datum/action/vampire/targeted/pact/four
	bloodcost = 60

	bonus_health = 70
	bonus_damage = 20

/// Anything will do, if it's not me or my square
/datum/action/vampire/targeted/pact/check_valid_target(atom/target_atom)
	. = ..()
	var/mob/living/living_owner = owner

	if(!.)
		return FALSE

	if(!isliving(target_atom))
		return FALSE

	var/mob/living/target = target_atom

	if (!isdog(target))
		owner.balloon_alert(owner, "not a type of dog!")
		return ..()

	if (living_owner.combat_mode)
		owner.balloon_alert(owner, "can't be in combat mode!")
		return ..()

	var/mob/living/basic/pet/dog/dog_target = target
	if (dog_target.stat != CONSCIOUS)
		owner.balloon_alert(owner, "must be conscious!")
		return ..()

/datum/action/vampire/targeted/pact/FireTargetedPower(atom/target_atom)
	. = ..()
	var/mob/living/basic/pet/dog/dog_target = target_atom

	dog_target.emote("spin")
	dog_target.fully_heal()

	if (dog_target.befriend(owner))
		dog_target.tamed(owner)
		new /obj/effect/temp_visual/heart(dog_target.loc)

		dog_target.maxHealth += bonus_health
		dog_target.melee_damage += bonus_damage

	power_activated_sucessfully()
