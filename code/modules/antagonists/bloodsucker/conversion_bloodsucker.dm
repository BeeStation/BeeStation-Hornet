/**
 * Checks if the target's antag_datums contain any of the banned antags.
 */
/datum/antagonist/bloodsucker/proc/IsBlacklistedAntag(mob/target)
	for(var/datum/antagonist/antag_datum as anything in target.mind.antag_datums)
		if(antag_datum.type in vassal_banned_antags)
			return TRUE
	return FALSE

/**
 * # can_make_vassal
 * Checks if the person is allowed to turn into the Bloodsucker's
 * Vassal, ensuring they are a player and valid.
 * If they are a Vassal themselves, will check if their master
 * has broken the Masquerade, to steal them.
 * Args:
 * conversion_target - Person being vassalized
 */
/datum/antagonist/bloodsucker/proc/can_make_vassal(mob/living/conversion_target)
	var/mob/living/carbon/human/user = owner.current

	if(!my_clan)
		user.balloon_alert(user, "enter a clan first.")
		return FALSE
	if(IsBlacklistedAntag(conversion_target) || !ishuman(conversion_target) || !conversion_target.mind || conversion_target.mind?.unconvertable)
		user.balloon_alert(user, "can't be vassalized!")
		return FALSE
	var/datum/antagonist/vassal/vassaldatum = IS_VASSAL(conversion_target)
	if(vassaldatum && !vassaldatum?.master.broke_masquerade)
		user.balloon_alert(user, "someone else's vassal!")
		return FALSE
	if(conversion_target.stat > UNCONSCIOUS)
		user.balloon_alert(user, "must be awake!")
		return FALSE
	if(length(vassals) >= return_current_max_vassals())
		user.balloon_alert(user, "max vassals reached!")
		return FALSE
	var/mob/living/master = conversion_target.mind.enslaved_to
	if(master && master != owner.current)
		user.balloon_alert(user, "enslaved to someone else!")
		return FALSE

	return TRUE

/**
 *  This proc is responsible for calculating how many vassals you can have at any given
 *  time, ranges from 1 at 20 pop to 4 at 40 pop
 */
/datum/antagonist/bloodsucker/proc/return_current_max_vassals()
	var/total_players = GLOB.joined_player_list.len
	switch(total_players)
		if(1 to 20)
			return 1
		if(21 to 30)
			return 3
		else
			return 4

/datum/antagonist/bloodsucker/proc/make_vassal(mob/living/conversion_target)
	//Check if they used to be a Vassal and was stolen.
	if(IS_VASSAL(conversion_target))
		conversion_target.mind.remove_antag_datum(/datum/antagonist/vassal)

	SelectTitle(am_fledgling = FALSE)

	//Set the master, then give the datum.
	var/datum/antagonist/vassal/vassaldatum = new(conversion_target.mind)
	vassaldatum.master = src
	conversion_target.mind.add_antag_datum(vassaldatum)

	message_admins("[conversion_target] has become a Vassal, and is enslaved to [owner.current].")
	log_admin("[conversion_target] has become a Vassal, and is enslaved to [owner.current].")
	return TRUE

/*
 *	# make_bloodsucker
 *
 * MIND Helper proc that turns the person into a Bloodsucker
 * Args:
 * creator - Person attempting to convert them.
 */
/datum/mind/proc/make_bloodsucker(datum/mind/creator)
	var/datum/antagonist/bloodsuckerdatum = add_antag_datum(/datum/antagonist/bloodsucker)
	if(bloodsuckerdatum && creator)
		message_admins("[src] has become a Bloodsucker, and was created by [creator].")
		log_admin("[src] has become a Bloodsucker, and was created by [creator].")
	return bloodsuckerdatum
