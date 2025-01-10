/**
 *	# Assigning Sol
 *
 *	Sol is the sunlight, during this period, all Bloodsuckers must be in their coffin, else they burn.
 */

/// Start Sol, called when someone is assigned Bloodsucker
/datum/antagonist/bloodsucker/proc/check_start_sunlight()
	var/list/existing_suckers = get_antag_minds(/datum/antagonist/bloodsucker) - owner
	if(!length(existing_suckers))
		message_admins("New Sol has been created due to Bloodsucker assignment.")
		SSsunlight.can_fire = TRUE

/// End Sol, if you're the last Bloodsucker
/datum/antagonist/bloodsucker/proc/check_cancel_sunlight()
	var/list/existing_suckers = get_antag_minds(/datum/antagonist/bloodsucker) - owner
	if(!length(existing_suckers))
		message_admins("Sol has been deleted due to the lack of Bloodsuckers")
		SSsunlight.can_fire = FALSE

///Ranks the Bloodsucker up, called by Sol.
/datum/antagonist/bloodsucker/proc/sol_rank_up(atom/source)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(RankUp))

///Called when Sol is near starting.
/datum/antagonist/bloodsucker/proc/sol_near_start(atom/source)
	SIGNAL_HANDLER
	if(bloodsucker_lair_area && !(locate(/datum/action/cooldown/bloodsucker/gohome) in powers))
		BuyPower(new /datum/action/cooldown/bloodsucker/gohome)

///Called when Sol first ends.
/datum/antagonist/bloodsucker/proc/on_sol_end(atom/source)
	SIGNAL_HANDLER
	check_end_torpor()
	for(var/datum/action/cooldown/bloodsucker/power in powers)
		if(istype(power, /datum/action/cooldown/bloodsucker/gohome))
			RemovePower(power)

/// Cycle through all bloodsuckers and check if they're inside a closet.
/datum/antagonist/bloodsucker/proc/handle_sol()
	SIGNAL_HANDLER
	if(!owner || !owner.current)
		return

	if(!istype(owner.current.loc, /obj/structure))
		if(COOLDOWN_FINISHED(src, bloodsucker_spam_sol_burn))
			if(bloodsucker_level > 0)
				to_chat(owner, "<span class='userdanger'>The solar flare sets your skin ablaze!</span>")
			else
				to_chat(owner, "<span class='userdanger'>The solar flare scalds your neophyte skin!</span>")
			COOLDOWN_START(src, bloodsucker_spam_sol_burn, BLOODSUCKER_SPAM_SOL) //This should happen twice per Sol

		if(owner.current.fire_stacks <= 0)
			owner.current.fire_stacks = 0
		if(bloodsucker_level > 0)
			owner.current.adjust_fire_stacks(0.2 + bloodsucker_level / 10)
			owner.current.IgniteMob()
		owner.current.adjustFireLoss(2 + (bloodsucker_level / 2))
		owner.current.updatehealth()
		SEND_SIGNAL(owner.current, COMSIG_ADD_MOOD_EVENT, "vampsleep", /datum/mood_event/daylight_2)
		return

	if(istype(owner.current.loc, /obj/structure/closet/crate/coffin)) // Coffins offer the BEST protection
		if(check_staked() && COOLDOWN_FINISHED(src, bloodsucker_spam_sol_burn))
			to_chat(owner.current, "<span class='userdanger'>You are staked! Remove the offending weapon from your heart before sleeping.</span>")
			COOLDOWN_START(src, bloodsucker_spam_sol_burn, BLOODSUCKER_SPAM_SOL) //This should happen twice per Sol
		if(!is_in_torpor())
			check_begin_torpor(TRUE)
			SEND_SIGNAL(owner.current, COMSIG_ADD_MOOD_EVENT, "vampsleep", /datum/mood_event/coffinsleep)
		return

	if(COOLDOWN_FINISHED(src, bloodsucker_spam_sol_burn)) // Closets offer SOME protection
		to_chat(owner, "<span class='warning'>Your skin sizzles. [owner.current.loc] doesn't protect well against UV bombardment.</span>")
		COOLDOWN_START(src, bloodsucker_spam_sol_burn, BLOODSUCKER_SPAM_SOL) //This should happen twice per Sol
	owner.current.adjustFireLoss(0.5 + (bloodsucker_level / 4))
	owner.current.updatehealth()
	SEND_SIGNAL(owner.current, COMSIG_ADD_MOOD_EVENT, "vampsleep", /datum/mood_event/daylight_1)

/datum/antagonist/bloodsucker/proc/give_warning(atom/source, danger_level, vampire_warning_message, vassal_warning_message)
	SIGNAL_HANDLER
	if(!owner)
		return
	to_chat(owner, vampire_warning_message)

	switch(danger_level)
		if(DANGER_LEVEL_FIRST_WARNING)
			owner.current.playsound_local(null, 'sound/bloodsuckers/griffin_3.ogg', 50, 1)
		if(DANGER_LEVEL_SECOND_WARNING)
			owner.current.playsound_local(null, 'sound/bloodsuckers/griffin_5.ogg', 50, 1)
		if(DANGER_LEVEL_THIRD_WARNING)
			owner.current.playsound_local(null, 'sound/effects/alert.ogg', 75, 1)
		if(DANGER_LEVEL_SOL_ROSE)
			owner.current.playsound_local(null, 'sound/ambience/ambimystery.ogg', 75, 1)
		if(DANGER_LEVEL_SOL_ENDED)
			owner.current.playsound_local(null, 'sound/misc/ghosty_wind.ogg', 90, 1)

/**
 * # Torpor
 *
 * Torpor is what deals with the Bloodsucker falling asleep, their healing, the effects, ect.
 * This is basically what Sol is meant to do to them, but they can also trigger it manually if they wish to heal, as Burn is only healed through Torpor.
 * You cannot manually exit Torpor, it is instead entered/exited by:
 *
 * Torpor is triggered by:
 * - Being in a Coffin while Sol is on, dealt with by Sol
 * - Entering a Coffin with more than 10 combined Brute/Burn damage, dealt with by /closet/crate/coffin/close() [bloodsucker_coffin.dm]
 * - Death, dealt with by /HandleDeath()
 * Torpor is ended by:
 * - Having less than 10 Brute damage while OUTSIDE of your Coffin while it isnt Sol.
 * - Having less than 10 Brute & Burn Combined while INSIDE of your Coffin while it isnt Sol.
 * - Sol being over, dealt with by /sunlight/process() [bloodsucker_daylight.dm]
*/
/datum/antagonist/bloodsucker/proc/check_begin_torpor(SkipChecks = FALSE)
	/// Are we entering Torpor via Sol/Death? Then entering it isnt optional!
	if(SkipChecks)
		torpor_begin()
		return
	var/mob/living/carbon/user = owner.current
	var/total_brute = user.getBruteLoss_nonProsthetic()
	var/total_burn = user.getFireLoss_nonProsthetic()
	var/total_damage = total_brute + total_burn
	/// Checks - Not daylight & Has more than 10 Brute/Burn & not already in Torpor
	if(!SSsunlight.sunlight_active && total_damage >= 10 && !HAS_TRAIT_FROM(owner.current, TRAIT_NODEATH, TRAIT_TORPOR))
		torpor_begin()

/datum/antagonist/bloodsucker/proc/check_end_torpor()
	var/mob/living/carbon/user = owner.current
	var/total_brute = user.getBruteLoss_nonProsthetic()
	var/total_burn = user.getFireLoss_nonProsthetic()
	var/total_damage = total_brute + total_burn
	if(total_burn >= 199)
		return FALSE
	if(SSsunlight.sunlight_active)
		return FALSE
	// You are in a Coffin, so instead we'll check TOTAL damage, here.
	if(istype(user.loc, /obj/structure/closet/crate/coffin))
		if(total_damage <= 10)
			torpor_end()
	else
		if(total_brute <= 10)
			torpor_end()

/datum/antagonist/bloodsucker/proc/is_in_torpor()
	if(QDELETED(owner.current))
		return FALSE
	return HAS_TRAIT_FROM(owner.current, TRAIT_NODEATH, TRAIT_TORPOR)

/datum/antagonist/bloodsucker/proc/torpor_begin()
	var/mob/living/current = owner.current

	REMOVE_TRAIT(current, TRAIT_SLEEPIMMUNE, TRAIT_BLOODSUCKER)
	REMOVE_TRAIT(current, TRAIT_NOBREATH, TRAIT_BLOODSUCKER)
	current.add_traits(torpor_traits, TRAIT_TORPOR)
	current.jitteriness = 0

	DisableAllPowers()

	to_chat(current, "<span class='notice'>You enter the horrible slumber of deathless Torpor. You will heal until you are renewed.</span>")

/datum/antagonist/bloodsucker/proc/torpor_end()
	var/mob/living/current = owner.current
	current.grab_ghost()

	if(!HAS_TRAIT(current, TRAIT_MASQUERADE))
		ADD_TRAIT(current, TRAIT_SLEEPIMMUNE, TRAIT_BLOODSUCKER)
		ADD_TRAIT(current, TRAIT_NOBREATH, TRAIT_BLOODSUCKER)

	current.remove_traits(torpor_traits, TRAIT_TORPOR)
	if(!HAS_TRAIT(current, TRAIT_MASQUERADE))
		ADD_TRAIT(current, TRAIT_SLEEPIMMUNE, TRAIT_BLOODSUCKER)

	heal_vampire_organs()

	to_chat(current, "<span class='warning'>You have recovered from Torpor.</span>")
	SEND_SIGNAL(src, BLOODSUCKER_EXIT_TORPOR)
