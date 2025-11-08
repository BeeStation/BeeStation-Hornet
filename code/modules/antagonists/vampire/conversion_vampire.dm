/**
 * This file contains all of the procs related to ghoulizing someone
 *
**/

/**
 * Checks if the target's antag_datums contain any of the banned antags.
**/
/datum/antagonist/vampire/proc/is_blacklisted_antag(mob/target)
	for(var/datum/antagonist/antag_datum as anything in target.mind.antag_datums)
		if(antag_datum.type in ghoul_banned_antags)
			return TRUE
	return FALSE

/**
 * Checks if the person is allowed to turn into the Vampire's ghoul
**/
/datum/antagonist/vampire/proc/can_make_ghoul(mob/living/conversion_target, ignore_concious_check = FALSE)
	var/mob/living/living_vampire = owner.current

	if(!my_clan)
		living_vampire.balloon_alert(living_vampire, "enter a clan first.")
		return FALSE

	if(length(ghouls) >= get_max_ghouls())
		living_vampire.balloon_alert(living_vampire, "more ghouls, in this small of a community? Surely not...")
		return FALSE

#ifndef VAMPIRE_TESTING
	if(!conversion_target.ckey)
		living_vampire.balloon_alert(living_vampire, "can't be ghoulized.")
		return FALSE
#endif

	if(!iscarbon(conversion_target) || !conversion_target.mind || conversion_target.mind.unconvertable || is_blacklisted_antag(conversion_target))
		living_vampire.balloon_alert(living_vampire, "can't be ghoulized.")
		return FALSE

	var/datum/antagonist/ghoul/ghouldatum = IS_GHOUL(conversion_target)
	var/mob/living/ghoul_master = conversion_target.mind.enslaved_to
	if((ghouldatum && !ghouldatum.master.broke_masquerade) || (ghoul_master && ghoul_master != owner.current))
		living_vampire.balloon_alert(living_vampire, "enslaved to someone else.")
		return FALSE

	if(!ignore_concious_check && conversion_target.stat > UNCONSCIOUS)
		living_vampire.balloon_alert(living_vampire, "must be awake.")
		return FALSE

	return TRUE

/datum/antagonist/vampire/proc/make_ghoul(mob/living/conversion_target)
	if(IS_GHOUL(conversion_target))
		conversion_target.mind.remove_antag_datum(/datum/antagonist/ghoul)

	select_title()

	// Set the master, then give the datum.
	var/datum/antagonist/ghoul/ghouldatum = new(conversion_target.mind)
	ghouldatum.master = src
	conversion_target.mind.add_antag_datum(ghouldatum)

	message_admins("[conversion_target] has become a ghoul, and is enslaved to [owner.current].")
	log_admin("[conversion_target] has become a ghoul, and is enslaved to [owner.current].")

	return TRUE
