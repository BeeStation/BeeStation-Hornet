/**
 * This file contains all of the procs related to vassalizing someone
 *
**/

/**
 * Checks if the target's antag_datums contain any of the banned antags.
**/
/datum/antagonist/vampire/proc/is_blacklisted_antag(mob/target)
	for(var/datum/antagonist/antag_datum as anything in target.mind.antag_datums)
		if(antag_datum.type in vassal_banned_antags)
			return TRUE
	return FALSE

/**
 * Checks if the person is allowed to turn into the Vampire's vasssal
**/
/datum/antagonist/vampire/proc/can_make_vassal(mob/living/conversion_target, ignore_concious_check = FALSE)
	var/mob/living/living_vampire = owner.current

	if(!my_clan)
		living_vampire.balloon_alert(living_vampire, "enter a clan first.")
		return FALSE

	if(length(vassals) >= my_clan.get_max_vassals())
		living_vampire.balloon_alert(living_vampire, "too many vassals.")
		return FALSE

#ifndef VAMPIRE_TESTING
	if(!conversion_target.ckey)
		living_vampire.balloon_alert(living_vampire, "can't be vassalized.")
		return FALSE
#endif

	if(!iscarbon(conversion_target) || !conversion_target.mind || conversion_target.mind.unconvertable || is_blacklisted_antag(conversion_target))
		living_vampire.balloon_alert(living_vampire, "can't be vassalized.")
		return FALSE

	var/datum/antagonist/vassal/vassaldatum = IS_VASSAL(conversion_target)
	var/mob/living/vassal_master = conversion_target.mind.enslaved_to
	if((vassaldatum && !vassaldatum.master.broke_masquerade) || (vassal_master && vassal_master != owner.current))
		living_vampire.balloon_alert(living_vampire, "enslaved to someone else.")
		return FALSE

	if(!ignore_concious_check && conversion_target.stat > UNCONSCIOUS)
		living_vampire.balloon_alert(living_vampire, "must be awake.")
		return FALSE

	return TRUE

/datum/antagonist/vampire/proc/make_vassal(mob/living/conversion_target)
	if(IS_VASSAL(conversion_target))
		conversion_target.mind.remove_antag_datum(/datum/antagonist/vassal)

	select_title()

	// Set the master, then give the datum.
	var/datum/antagonist/vassal/vassaldatum = new(conversion_target.mind)
	vassaldatum.master = src
	conversion_target.mind.add_antag_datum(vassaldatum)

	if(istype(my_clan, /datum/vampire_clan/brujah) && my_clan.clan_objective.target == conversion_target.mind)
		vassaldatum.make_special(/datum/antagonist/vassal/discordant)

		message_admins("[conversion_target], the [conversion_target.mind.assigned_role] has become a Discordant Vassal, they were enthralled by [owner.current].")
		log_admin("[conversion_target], the [conversion_target.mind.assigned_role] has become a Discordant Vassal, they were enthralled by [owner.current].")
		return TRUE

	message_admins("[conversion_target] has become a Vassal, and is enslaved to [owner.current].")
	log_admin("[conversion_target] has become a Vassal, and is enslaved to [owner.current].")

	return TRUE
