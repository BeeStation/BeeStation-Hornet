/**
 *	# Assigning Sol
 *
 *	Sol is the sunlight, during this period, all Vampires must be in their coffin, else they burn.
 */

/// Start Sol, called when someone is assigned Vampire
/datum/antagonist/vampire/proc/check_start_sunlight()
	var/list/existing_suckers = get_antag_minds(/datum/antagonist/vampire) - owner
	if(!length(existing_suckers))
		message_admins("New Sol has been created due to Vampire assignment.")
		SSsunlight.can_fire = TRUE

/// End Sol, if you're the last Vampire
/datum/antagonist/vampire/proc/check_cancel_sunlight()
	var/list/existing_suckers = get_antag_minds(/datum/antagonist/vampire) - owner
	if(!length(existing_suckers))
		message_admins("Sol has been deleted due to the lack of Vampires")
		SSsunlight.can_fire = FALSE

///Ranks the Vampire up, called by Sol.
/datum/antagonist/vampire/proc/sol_rank_up(atom/source)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(RankUp))

///Called when Sol is near starting.
/datum/antagonist/vampire/proc/sol_near_start(atom/source)
	SIGNAL_HANDLER
	if(vampire_lair_area && !(locate(/datum/action/cooldown/vampire/gohome) in powers))
		BuyPower(new /datum/action/cooldown/vampire/gohome)

///Called when Sol first ends.
/datum/antagonist/vampire/proc/on_sol_end(atom/source)
	SIGNAL_HANDLER
	check_end_torpor()
	for(var/datum/action/cooldown/vampire/gohome/power in powers)
		RemovePower(power)

/// Cycle through all vampires and check if they're inside a closet.
/datum/antagonist/vampire/proc/handle_sol()
	SIGNAL_HANDLER
	if(!owner?.current)
		return

	if(!istype(owner.current.loc, /obj/structure/closet/crate/coffin))
		owner.current.apply_status_effect(/datum/status_effect/vampire_sol)
		return
	owner.current.remove_status_effect(/datum/status_effect/vampire_sol)
	if(check_if_staked() && COOLDOWN_FINISHED(src, vampire_spam_sol_burn))
		to_chat(owner.current, span_userdanger("You are staked! Remove the offending weapon from your heart before sleeping."))
		COOLDOWN_START(src, vampire_spam_sol_burn, VAMPIRE_SPAM_SOL) //This should happen twice per Sol
	if(!is_in_torpor())
		check_begin_torpor(TRUE)
		SEND_SIGNAL(owner.current, COMSIG_ADD_MOOD_EVENT, "vampsleep", /datum/mood_event/coffinsleep)

/datum/antagonist/vampire/proc/give_warning(atom/source, danger_level, vampire_warning_message, vassal_warning_message)
	SIGNAL_HANDLER

	if(!owner || !owner.current)
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
 * - Being in a Coffin while Sol is on, dealt with by Sol
 * - Entering a Coffin with more than 10 combined Brute/Burn damage, dealt with by /closet/crate/coffin/close() [vampire_coffin.dm]
 * - Death, dealt with by /HandleDeath()
 * Torpor is ended by:
 * - Having less than 10 Brute damage while OUTSIDE of your Coffin while it isnt Sol.
 * - Having less than 10 Brute & Burn Combined while INSIDE of your Coffin while it isnt Sol.
 * - Sol being over, dealt with by /sunlight/process() [vampire_daylight.dm]
*/
/datum/antagonist/vampire/proc/check_begin_torpor()
	var/mob/living/carbon/user = owner.current
	var/total_brute = user.getBruteLoss()
	var/total_burn = user.getFireLoss()
	var/total_damage = total_brute + total_burn
	/// Checks - Not daylight & Has more than 10 Brute/Burn & not already in Torpor
	if(!SSsunlight.sunlight_active && total_damage >= 10 && !HAS_TRAIT_FROM(owner.current, TRAIT_NODEATH, TRAIT_TORPOR))
		torpor_begin()

/datum/antagonist/vampire/proc/check_end_torpor()
	var/mob/living/carbon/user = owner.current
	var/total_brute = user.getBruteLoss()
	var/total_burn = user.getFireLoss()
	var/total_damage = total_brute + total_burn
	if(total_burn >= 199)
		return
	if(SSsunlight.sunlight_active)
		return

	if(check_if_staked())
		torpor_end()
	// You are in a Coffin, so instead we'll check TOTAL damage, here.
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
	var/mob/living/current = owner.current

	REMOVE_TRAIT(current, TRAIT_SLEEPIMMUNE, TRAIT_VAMPIRE)
	REMOVE_TRAIT(current, TRAIT_NOBREATH, TRAIT_VAMPIRE)
	current.add_traits(torpor_traits, TRAIT_TORPOR)
	current.jitteriness = 0

	DisableAllPowers()

	to_chat(current, span_notice("You enter the horrible slumber of deathless Torpor. You will heal until you are renewed."))

/datum/antagonist/vampire/proc/torpor_end()
	var/mob/living/current = owner.current

	current.remove_status_effect(/datum/status_effect/vampire_sol)
	current.grab_ghost()

	if(!HAS_TRAIT(current, TRAIT_MASQUERADE))
		ADD_TRAIT(current, TRAIT_SLEEPIMMUNE, TRAIT_VAMPIRE)
		ADD_TRAIT(current, TRAIT_NOBREATH, TRAIT_VAMPIRE)

	current.remove_traits(torpor_traits, TRAIT_TORPOR)
	if(!HAS_TRAIT(current, TRAIT_MASQUERADE))
		ADD_TRAIT(current, TRAIT_SLEEPIMMUNE, TRAIT_VAMPIRE)

	heal_vampire_organs()

	to_chat(current, span_warning("You have recovered from Torpor."))
	SEND_SIGNAL(src, VAMPIRE_EXIT_TORPOR)

/datum/status_effect/vampire_sol
	id = "vampire_sol"
	tick_interval = -1
	alert_type = /atom/movable/screen/alert/status_effect/vampire_sol
	var/list/datum/action/cooldown/vampire/burdened_actions

/datum/status_effect/vampire_sol/on_apply()
	if(!SSsunlight.sunlight_active || istype(owner.loc, /obj/structure/closet/crate/coffin))
		return FALSE
	RegisterSignal(SSsunlight, COMSIG_SOL_END, PROC_REF(on_sol_end))
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_owner_moved))
	owner.remove_filter(id)
	owner.add_filter(id, 2, drop_shadow_filter(x = 0, y = 0, size = 3, offset = 1.5, color = "#ee7440"))
	owner.add_movespeed_modifier(/datum/movespeed_modifier/vampire_sol)
	owner.add_actionspeed_modifier(/datum/actionspeed_modifier/vampire_sol)
	to_chat(owner, span_userdanger("Sol has risen! Your powers are suppressed, your body is burdened, and you will not heal outside of a coffin!"), type = MESSAGE_TYPE_INFO)
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.physiology?.damage_resistance -= 50
	for(var/datum/action/cooldown/vampire/power in owner.actions)
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
	for(var/datum/action/cooldown/vampire/power in owner.actions)
		if(LAZYACCESS(burdened_actions, power))
			power.bloodcost /= power.sol_multiplier
			power.constant_bloodcost /= power.sol_multiplier
		power.update_desc()
		power.update_buttons()
	LAZYNULL(burdened_actions)

/datum/status_effect/vampire_sol/get_examine_text()
	return span_warning("[capitalize(owner.p_they())] seem[owner.p_s()] sickly and painfully overburned!")

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
