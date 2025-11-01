/**
 * Resumes Sol, called when someone is assigned Vampire
**/
/datum/antagonist/vampire/proc/check_start_sunlight()
	var/list/existing_suckers = get_antag_minds(/datum/antagonist/vampire) - owner
	if(!length(existing_suckers))
		SSsunlight.can_fire = TRUE

/**
 * Pauses Sol, called when someone is unassigned Vampire
**/
/datum/antagonist/vampire/proc/check_cancel_sunlight()
	var/list/existing_suckers = get_antag_minds(/datum/antagonist/vampire) - owner
	if(!length(existing_suckers))
		SSsunlight.can_fire = FALSE

/**
 * Gives the Vampire the gohome power, called 1.5 minutes before Sol starts
**/
/datum/antagonist/vampire/proc/sol_near_start(atom/source)
	SIGNAL_HANDLER
	if(vampire_lair_area && !(locate(/datum/action/vampire/gohome) in powers))
		grant_power(new /datum/action/vampire/gohome)

/**
 * Removes the gohome power, called at the end of Sol
**/
/datum/antagonist/vampire/proc/on_sol_end(atom/source)
	SIGNAL_HANDLER
	check_end_torpor()
	for(var/datum/action/vampire/gohome/power in powers)
		remove_power(power)

/**
 * Called near the end of Sol. Give our vampire a level to spend if we aren't Tremere.
**/
/datum/antagonist/vampire/proc/sol_near_end(atom/source)
	SIGNAL_HANDLER

	if(!istype(my_clan, /datum/vampire_clan/tremere))
		INVOKE_ASYNC(src, PROC_REF(rank_up))

/**
 * Handles the Sol status effect, called while Sol is risen
**/
/datum/antagonist/vampire/proc/handle_sol()
	SIGNAL_HANDLER
	if(!owner?.current)
		return

	// Give Sol debuff if not in a coffin
	if(!istype(owner.current.loc, /obj/structure/closet/crate/coffin))
		owner.current.apply_status_effect(/datum/status_effect/vampire_sol)
	else
		// Try to remove Sol debuff
		owner.current.remove_status_effect(/datum/status_effect/vampire_sol)

		// Try to enter torpor if we're not in a frenzy or staked
		if(frenzied)
			if(COOLDOWN_FINISHED(src, vampire_spam_sol_burn))
				to_chat(owner.current, span_userdanger("You are in a frenzy! You cannot enter Torpor until you have enough blood."))
				COOLDOWN_START(src, vampire_spam_sol_burn, VAMPIRE_SPAM_SOL)
			return
		if(check_if_staked())
			if(COOLDOWN_FINISHED(src, vampire_spam_sol_burn))
				to_chat(owner.current, span_userdanger("You are staked! Remove the offending weapon from your heart before sleeping."))
				COOLDOWN_START(src, vampire_spam_sol_burn, VAMPIRE_SPAM_SOL)
			return
		if(!is_in_torpor())
			torpor_begin()
			SEND_SIGNAL(owner.current, COMSIG_ADD_MOOD_EVENT, "vampsleep", /datum/mood_event/coffinsleep)
			return

/datum/antagonist/vampire/proc/give_warning(atom/source, danger_level, vampire_warning_message, vassal_warning_message)
	SIGNAL_HANDLER

	if(!owner?.current)
		return
	to_chat(owner, vampire_warning_message)

	switch(danger_level)
		if(DANGER_LEVEL_FIRST_WARNING)
			owner.current.playsound_local(null, 'sound/vampires/griffin_3.ogg', 50, TRUE)
		if(DANGER_LEVEL_SECOND_WARNING)
			owner.current.playsound_local(null, 'sound/vampires/griffin_5.ogg', 50, TRUE)
		if(DANGER_LEVEL_THIRD_WARNING)
			owner.current.playsound_local(null, 'sound/effects/alert.ogg', 75, TRUE)
		if(DANGER_LEVEL_SOL_ROSE)
			owner.current.playsound_local(null, 'sound/ambience/ambimystery.ogg', 75, TRUE)
		if(DANGER_LEVEL_SOL_ENDED)
			owner.current.playsound_local(null, 'sound/misc/ghosty_wind.ogg', 90, TRUE)

/**
 * # Torpor
 *
 * Torpor is what deals with the Vampire falling asleep, their healing, the effects, ect.
 * This is basically what Sol is meant to do to them, but they can also trigger it manually if they wish to heal, as Burn is only healed through Torpor.
 * You cannot manually exit Torpor, it is instead entered/exited by:
 *
 * Torpor is triggered by:
 * - Entering a Coffin with more than 10 combined Brute/Burn damage, dealt with by /closet/crate/coffin/close() [coffins.dm]
 * - Death, dealt with by /HandleDeath()
 * Torpor is ended by:
 * - Having less than 10 Brute damage while OUTSIDE of your Coffin while it isnt Sol.
 * - Having less than 10 Brute & Burn Combined while INSIDE of your Coffin while it isnt Sol.
 * - Sol being over, dealt with by /sunlight/process() [vampire_daylight.dm]
**/
/datum/antagonist/vampire/proc/check_begin_torpor()
	var/mob/living/carbon/carbon_owner = owner.current
	var/total_damage = carbon_owner.getBruteLoss() + carbon_owner.getFireLoss()
	if(total_damage < 10)
		return
	if(is_in_torpor())
		return
	if(SSsunlight.sunlight_active)
		return
	if(frenzied)
		return

	torpor_begin()

/datum/antagonist/vampire/proc/check_end_torpor()
	if(frenzied)
		torpor_end()
		return

	var/mob/living/carbon/user = owner.current

	var/total_brute = user.getBruteLoss()
	var/total_burn = user.getFireLoss()

	if(total_burn >= 199)
		return
	if(SSsunlight.sunlight_active)
		return

	if(check_if_staked())
		torpor_end()
		return

	// You are in a Coffin, so instead we'll check TOTAL damage.
	var/total_damage = total_brute + total_burn
	if(istype(user.loc, /obj/structure/closet/crate/coffin))
		if(total_damage <= 10)
			torpor_end()
	else
		if(total_brute <= 10)
			torpor_end()

/datum/antagonist/vampire/proc/is_in_torpor()
	if(QDELETED(owner.current))
		return FALSE

	return HAS_TRAIT_FROM(owner.current, TRAIT_NODEATH, TRAIT_TORPOR)

/datum/antagonist/vampire/proc/torpor_begin()
	var/mob/living/living_owner = owner.current
	if(QDELETED(living_owner))
		return

	// Handle traits
	REMOVE_TRAIT(living_owner, TRAIT_SLEEPIMMUNE, TRAIT_VAMPIRE)
	living_owner.add_traits(torpor_traits, TRAIT_TORPOR)

	living_owner.remove_status_effect(/datum/status_effect/jitter)

	disable_all_powers()

	to_chat(living_owner, span_notice("You enter the horrible slumber of deathless Torpor. You will heal until you are renewed."))

/datum/antagonist/vampire/proc/torpor_end()
	var/mob/living/living_owner = owner.current

	living_owner.remove_status_effect(/datum/status_effect/vampire_sol)
	living_owner.grab_ghost()

	// Handle traits
	if(!HAS_TRAIT(living_owner, TRAIT_MASQUERADE))
		ADD_TRAIT(living_owner, TRAIT_SLEEPIMMUNE, TRAIT_VAMPIRE)
	living_owner.remove_traits(torpor_traits, TRAIT_TORPOR)

	heal_vampire_organs()

	to_chat(living_owner, span_notice("You have recovered from Torpor."))
	my_clan?.on_exit_torpor()


/datum/status_effect/vampire_sol
	id = "vampire_sol"
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = /atom/movable/screen/alert/status_effect/vampire_sol
	var/list/datum/action/vampire/burdened_actions

/datum/status_effect/vampire_sol/on_apply()
	if(!SSsunlight.sunlight_active || istype(owner.loc, /obj/structure/closet/crate/coffin))
		return FALSE

	RegisterSignal(SSsunlight, COMSIG_SOL_END, PROC_REF(on_sol_end))
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_owner_moved))
	owner.add_movespeed_modifier(/datum/movespeed_modifier/vampire_sol)
	owner.add_actionspeed_modifier(/datum/actionspeed_modifier/vampire_sol)
	to_chat(owner, span_userdanger("Sol has risen! Your powers are suppressed, your body is burdened, and you will not heal outside of a coffin!"), type = MESSAGE_TYPE_INFO)
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.physiology?.damage_resistance -= 50
	for(var/datum/action/vampire/power in owner.actions)
		if(power.sol_multiplier)
			power.bloodcost *= power.sol_multiplier
			power.constant_bloodcost *= power.sol_multiplier
			if(power.currently_active)
				to_chat(owner, span_warning("[power.name] is harder to upkeep during Sol, now requiring [power.constant_bloodcost] blood while the solar flares last!"), type = MESSAGE_TYPE_INFO)
			LAZYSET(burdened_actions, power, TRUE)
		power.update_desc()
		power.update_buttons()
	return TRUE

/datum/status_effect/vampire_sol/on_remove()
	UnregisterSignal(SSsunlight, COMSIG_SOL_END)
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)
	owner.remove_filter(id)
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/vampire_sol)
	owner.remove_actionspeed_modifier(/datum/actionspeed_modifier/vampire_sol)
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.physiology?.damage_resistance += 50
	for(var/datum/action/vampire/power in owner.actions)
		if(LAZYACCESS(burdened_actions, power))
			power.bloodcost /= power.sol_multiplier
			power.constant_bloodcost /= power.sol_multiplier
		power.update_desc()
		power.update_buttons()
	LAZYNULL(burdened_actions)

/datum/status_effect/vampire_sol/proc/on_sol_end()
	SIGNAL_HANDLER
	if(!QDELING(src))
		to_chat(owner, span_big(span_boldnotice("Sol has ended, your vampiric powers are no longer strained!")), type = MESSAGE_TYPE_INFO)
		qdel(src)

/datum/status_effect/vampire_sol/proc/on_owner_moved()
	SIGNAL_HANDLER
	if(istype(owner.loc, /obj/structure/closet/crate/coffin))
		qdel(src)

/atom/movable/screen/alert/status_effect/vampire_sol
	name = "Solar Flares"
	desc = "Solar flares bombard the station, heavily weakening your vampiric abilities and burdening your body!\nSleep in a coffin to avoid the effects of the solar flare!"
	icon = 'icons/vampires/actions_vampire.dmi'
	icon_state = "sol_alert"

/datum/actionspeed_modifier/vampire_sol
	multiplicative_slowdown = 1

/datum/movespeed_modifier/vampire_sol
	multiplicative_slowdown = 0.45
