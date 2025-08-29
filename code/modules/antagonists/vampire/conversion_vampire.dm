/**
 * Checks if the target's antag_datums contain any of the banned antags.
 */
/datum/antagonist/vampire/proc/is_blacklisted_antag(mob/target)
	for(var/datum/antagonist/antag_datum as anything in target.mind?.antag_datums)
		if(antag_datum.type in vassal_banned_antags)
			return TRUE
	return FALSE

/**
 * # can_make_vassal
 * Checks if the person is allowed to turn into the Vampire's
 * Vassal, ensuring they are a player and valid.
 * If they are a Vassal themselves, will check if their master
 * has broken the Masquerade, to steal them.
 * Args:
 * conversion_target - Person being vassalized
 */
/datum/antagonist/vampire/proc/can_make_vassal(mob/living/conversion_target)
	var/mob/living/carbon/human/user = owner.current

	if(!my_clan)
		user.balloon_alert(user, "enter a clan first.")
		return FALSE

	if(length(vassals) >= my_clan.get_max_vassals())
		user.balloon_alert(user, "too many vassals!")
		return FALSE

#ifndef VAMPIRE_TESTING
	if(!conversion_target.client)
		user.balloon_alert(user, "can't be vassalized!")
		return FALSE
#endif

	if(is_blacklisted_antag(conversion_target) || !ishuman(conversion_target) || conversion_target.mind?.unconvertable)
		user.balloon_alert(user, "can't be vassalized!")
		return FALSE

	var/datum/antagonist/vassal/vassaldatum = IS_VASSAL(conversion_target)
	var/mob/living/vassal_master = conversion_target.mind.enslaved_to
	if((vassaldatum && !vassaldatum.master.broke_masquerade) || (vassal_master && vassal_master != owner.current))
		user.balloon_alert(user, "enslaved to someone else!")
		return FALSE

	if(conversion_target.stat > UNCONSCIOUS)
		user.balloon_alert(user, "must be awake!")
		return FALSE

	return TRUE

/datum/antagonist/vampire/proc/make_vassal(mob/living/conversion_target)
	if(IS_VASSAL(conversion_target))
		conversion_target.mind.remove_antag_datum(/datum/antagonist/vassal)

	SelectTitle(am_fledgling = FALSE)

	// Set the master, then give the datum.
	var/datum/antagonist/vassal/vassaldatum = new(conversion_target.mind)
	vassaldatum.master = src
	conversion_target.mind.add_antag_datum(vassaldatum)

	if(istype(my_clan?.clan_objective, /datum/objective/brujah_clan_objective) && (my_clan?.clan_objective.target == conversion_target.mind))
		vassaldatum.make_special(/datum/antagonist/vassal/discordant)

		message_admins("[conversion_target], the [conversion_target.mind.assigned_role] has become a Discordant Vassal, they were enthralled by [owner.current].")
		log_admin("[conversion_target], the [conversion_target.mind.assigned_role] has become a Discordant Vassal, they were enthralled by [owner.current].")
		return TRUE

	message_admins("[conversion_target] has become a Vassal, and is enslaved to [owner.current].")
	log_admin("[conversion_target] has become a Vassal, and is enslaved to [owner.current].")

	return TRUE
