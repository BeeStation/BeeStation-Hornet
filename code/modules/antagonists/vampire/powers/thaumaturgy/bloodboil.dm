/datum/action/vampire/targeted/bloodboil
	name = "Thaumaturgy: Boil Blood"
	desc = "Boil the target's blood inside their body."
	button_icon_state = "power_thaumaturgy"
	background_icon_state_on = "tremere_power_bronze_on"
	background_icon_state_off = "tremere_power_bronze_off"
	power_explanation = "Afflict a debilitating status effect on a target within range, causing them to suffer bloodloss, burn damage, and slowing them down.\n\
						This is the only thaumaturgy ability to scale with level. It will become more powerful, last longer, gain range, and have a shorter cooldown."
	power_flags = NONE
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_UNCONSCIOUS
	vitaecost = 30
	cooldown_time = 35 SECONDS
	target_range = 7
	power_activates_immediately = FALSE
	prefire_message = "Whom will you afflict?"

	var/powerlevel = 1

/datum/action/vampire/targeted/bloodboil/two
	cooldown_time = 30 SECONDS
	vitaecost = 45
	target_range = 10
	powerlevel = 2

/datum/action/vampire/targeted/bloodboil/three
	cooldown_time = 25 SECONDS
	vitaecost = 60
	target_range = 15
	powerlevel = 3

/datum/action/vampire/targeted/bloodboil/four
	cooldown_time = 20 SECONDS
	vitaecost = 75
	target_range = 20
	powerlevel = 4

/datum/action/vampire/targeted/bloodboil/check_valid_target(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE

	// Must be a carbon
	if(!iscarbon(target_atom) || issilicon(target_atom))
		owner.balloon_alert(owner, "not a valid target.")
		return FALSE
	var/mob/living/living_target = target_atom

	// Check for magic immunity
	if(living_target.can_block_magic(MAGIC_RESISTANCE_HOLY))
		owner.balloon_alert(owner, "your curse was blocked.")
		return FALSE

	// Already boiled
	if(living_target.has_status_effect(/datum/status_effect/bloodboil) || living_target.has_status_effect(/datum/status_effect/bloodboil/strong) || living_target.has_status_effect(/datum/status_effect/bloodboil/stronger) || living_target.has_status_effect(/datum/status_effect/bloodboil/strongest))
		return FALSE

/datum/action/vampire/targeted/bloodboil/FireTargetedPower(atom/target_atom)
	. = ..()
	// Just to make absolutely sure
	if(!iscarbon(target_atom) || issilicon(target_atom))
		return FALSE
	var/mob/living/living_target = target_atom

	owner.whisper("Potestas Vitae...")

	switch(powerlevel)
		if(1)
			if(living_target.apply_status_effect(/datum/status_effect/bloodboil, owner))
				to_chat(owner, span_warning("You cause [living_target.name]'s blood to boil inside their body!"))
				power_activated_sucessfully() // PAY COST! BEGIN COOLDOWN!
			else
				to_chat(owner, span_warning("Your thaumaturgy fails to take hold."))
				deactivate_power()
		if(2)
			if(living_target.apply_status_effect(/datum/status_effect/bloodboil/strong, owner))
				to_chat(owner, span_warning("You cause [living_target.name]'s blood to boil inside their body!"))
				power_activated_sucessfully() // PAY COST! BEGIN COOLDOWN!
			else
				to_chat(owner, span_warning("Your thaumaturgy fails to take hold."))
				deactivate_power()
		if(3)
			if(living_target.apply_status_effect(/datum/status_effect/bloodboil/stronger, owner))
				to_chat(owner, span_warning("You cause [living_target.name]'s blood to boil inside their body!"))
				power_activated_sucessfully() // PAY COST! BEGIN COOLDOWN!
			else
				to_chat(owner, span_warning("Your thaumaturgy fails to take hold."))
				deactivate_power()
		if(4)
			if(living_target.apply_status_effect(/datum/status_effect/bloodboil/strongest, owner))
				to_chat(owner, span_warning("You cause [living_target.name]'s blood to boil inside their body!"))
				power_activated_sucessfully() // PAY COST! BEGIN COOLDOWN!
			else
				to_chat(owner, span_warning("Your thaumaturgy fails to take hold."))
				deactivate_power()

/datum/status_effect/bloodboil
	id = "bloodboil"
	status_type = STATUS_EFFECT_UNIQUE
	duration = 4 SECONDS
	tick_interval = 1 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/bloodboil
	var/power = 1

/datum/status_effect/bloodboil/strong
	duration = 6 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/bloodboil
	power = 2

/datum/status_effect/bloodboil/stronger
	duration = 8 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/bloodboil
	power = 3

/datum/status_effect/bloodboil/strongest
	duration = 10 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/bloodboil
	power = 4

/atom/movable/screen/alert/status_effect/bloodboil
	name = "Blood Boil"
	desc = "You feel an intense heat coursing through your veins. Your blood is boiling!"
	icon_state = "bloodboil"

/datum/status_effect/bloodboil/tick()
	var/mob/living/carbon/carbon_owner
	if(iscarbon(owner))
		carbon_owner = owner
	else
		return

	playsound(owner, 'sound/effects/wounds/sizzle1.ogg', 50, vary = TRUE)
	switch(power)
		if(1)
			carbon_owner.adjustStaminaLoss(5)
			carbon_owner.adjustFireLoss(8)
			owner.blood_volume -= 4
			if(prob(50))
				to_chat(owner, span_warning("Oh god! IT BURNS!"))
				owner.emote("screams")
		if(2)
			carbon_owner.adjustStaminaLoss(10)
			carbon_owner.adjustFireLoss(6)
			owner.blood_volume -= 6
			if(prob(50))
				to_chat(owner, span_warning("Oh god! IT BURNS!"))
				owner.emote("screams")
		if(3)
			carbon_owner.adjustStaminaLoss(15)
			carbon_owner.adjustFireLoss(8)
			owner.blood_volume -= 8
			if(prob(50))
				to_chat(owner, span_warning("Oh god! IT BURNS!"))
				owner.emote("screams")
		if(4)
			carbon_owner.adjustStaminaLoss(20)
			carbon_owner.adjustFireLoss(9)
			owner.blood_volume -= 10
			if(prob(50))
				to_chat(owner, span_warning("Oh god! IT BURNS!"))
				owner.emote("screams")
	return

/datum/status_effect/bloodboil/on_apply()
	if(!iscarbon(owner))
		return FALSE
	return TRUE

/datum/status_effect/bloodboil/on_creation(mob/living/new_owner, target)
	. = ..()
	return

/datum/status_effect/bloodboil/on_remove()

/datum/status_effect/bloodboil/get_examine_text()
	return span_warning("[owner.p_They()] writhe[owner.p_s()] and squirm[owner.p_s()], [owner.p_They()] seem[owner.p_s()] weirdly red?")
