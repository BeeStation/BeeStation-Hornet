/**
 * # Torpor
 *
 * Torpor is what deals with the Vampire falling asleep, their healing, the effects, ect.
 * They trigger it manually if they wish to heal, as Burn is only healed through Torpor.
 * You cannot manually exit Torpor, it is instead entered/exited by:
 *
 * Torpor is triggered by:
 * - Entering a Coffin with more than 10 combined Brute/Burn damage, dealt with by /closet/crate/coffin/close() [coffins.dm]
 * - Death, dealt with by /HandleDeath()
 * Torpor is ended by:
 * - Having less than 10 Burn damage while OUTSIDE of your Coffin.
 * - Having less than 10 Brute & Burn Combined while INSIDE of your Coffin.
**/
/datum/antagonist/vampire/proc/check_begin_torpor()
	var/mob/living/carbon/carbon_owner = owner?.current
	if(!carbon_owner)
		return
	var/total_damage = carbon_owner.getBruteLoss() + carbon_owner.getFireLoss()
	if(total_damage < 10)
		return
	if(is_in_torpor())
		return
	if(frenzied)
		return
	if(final_death)
		return

	torpor_begin()

/datum/antagonist/vampire/proc/check_end_torpor()
	if(frenzied)
		torpor_end()
		return

	var/mob/living/carbon/user = owner?.current
	if(QDELETED(user))
		return

	var/total_brute = user.getBruteLoss()
	var/total_burn = user.getFireLoss()

	if(total_burn >= 199)
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

	if(final_death) // We do not want any of this to run if we have died for good.
		return

	// Handle traits
	REMOVE_TRAIT(living_owner, TRAIT_SLEEPIMMUNE, TRAIT_VAMPIRE)
	living_owner.add_traits(torpor_traits, TRAIT_TORPOR)

	living_owner.remove_status_effect(/datum/status_effect/jitter)

	disable_all_powers()

	// Resting in your coffin is far more pleasant than collapsing in the open.
	if(istype(living_owner.loc, /obj/structure/closet/crate/coffin))
		SEND_SIGNAL(living_owner, COMSIG_ADD_MOOD_EVENT, "vampsleep", /datum/mood_event/coffinsleep)

	to_chat(living_owner, span_notice("You enter the horrible slumber of deathless Torpor. You will heal until you are renewed."))

/datum/antagonist/vampire/proc/torpor_end()
	var/mob/living/living_owner = owner.current

	if(QDELETED(living_owner))
		return

	if(final_death) // We do not want any of this to run if we have died for good.
		return

	living_owner.grab_ghost()

	// Handle traits
	if(!HAS_TRAIT(living_owner, TRAIT_MIMICRY))
		ADD_TRAIT(living_owner, TRAIT_SLEEPIMMUNE, TRAIT_VAMPIRE)
	living_owner.remove_traits(torpor_traits, TRAIT_TORPOR)

	heal_vampire_organs()

	if(current_vitae >= 300) // We wake up hungy, but only if it wouldn't kill us. The baby check.
		current_vitae = 300
		to_chat(living_owner, span_notice("You use your vitae to revive from the deathless sleep."))
	else
		to_chat(living_owner, span_notice("You have recovered from Torpor."))

	my_clan?.on_exit_torpor()
