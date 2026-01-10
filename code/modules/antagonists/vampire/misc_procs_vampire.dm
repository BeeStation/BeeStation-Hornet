/**
 * Helper proc for adding a power
**/
/datum/antagonist/vampire/proc/grant_power(datum/action/vampire/power)
	for(var/datum/action/vampire/current_powers as anything in powers)
		if(current_powers.type == power.type)
			return FALSE
	powers += power

	power.Grant(owner.current)
	log_game("[key_name(owner.current)] has purchased: [power].")
	return TRUE

/**
 * Helper proc for removing a power
**/
/datum/antagonist/vampire/proc/remove_power(datum/action/vampire/power)
	if(power.currently_active)
		power.deactivate_power()
	powers -= power
	power.Remove(owner.current)

/**
 * When a Vampire breaks the Masquerade, they get their HUD icon changed, and Malkavian Vampires get alerted.
**/
/datum/antagonist/vampire/proc/break_masquerade(mob/admin)
	if(broke_masquerade)
		return
	broke_masquerade = TRUE

	to_chat(owner.current, span_userdanger("You have broken the Masquerade!"))
	to_chat(owner.current, span_warning("Vampire Tip: When you break the Masquerade, you become open for termination by fellow Vampires, and your vassals are no longer completely loyal to you, as other Vampires can steal them for themselves!"))

	set_antag_hud(owner.current, "masquerade_broken")

	SEND_GLOBAL_SIGNAL(COMSIG_VAMPIRE_BROKE_MASQUERADE, src)
	GLOB.masquerade_breakers.Add(src)

/**
 * Increment the masquerade infraction counter and warn the vampire accordingly
**/
/datum/antagonist/vampire/proc/give_masquerade_infraction()
	if(broke_masquerade)
		return
	masquerade_infractions++

	owner.current.playsound_local(null, 'sound/vampires/lunge_warn.ogg', 100, FALSE, pressure_affected = FALSE)

	if(masquerade_infractions >= 3)
		break_masquerade()
	else
		to_chat(owner.current, span_cultbold("You violated the Masquerade! Break the Masquerade [3 - masquerade_infractions] more times and you will become hunted by all other Vampires!"))

/**
 * Increase our unspent vampire levels by one and try to rank up if inside a coffin
 * Called near the end of Sol and admin abuse
**/
/datum/antagonist/vampire/proc/rank_up(levels, ignore_reqs = FALSE)
	if(QDELETED(owner) || QDELETED(owner.current))
		return

	if(vitae_goal_progress <= current_vitae_goal && !ignore_reqs)
		to_chat(owner.current, span_notice("Your lack of experience has left you unable to level up. Fulfill your vitae goal next time in order to level up."))
		return

	vampire_level_unspent += levels
	if(!my_clan)
		to_chat(owner.current, span_notice("You have grown in power. Join a clan to spend it."))
		return

	to_chat(owner, span_notice("<EM>You have grown familiar with your powers!"))

	current_vitae_goal += VITAE_GOAL_STANDARD
	vitae_goal_progress = 0

/**
 * Decrease the unspent vampire levels by one. Only for admins
**/
/datum/antagonist/vampire/proc/rank_down()
	vampire_level_unspent--

/datum/antagonist/vampire/proc/remove_nondefault_powers(return_levels = FALSE)
	for(var/datum/action/vampire/power as anything in powers)
		if(power.special_flags & VAMPIRE_DEFAULT_POWER)
			continue
		remove_power(power)
		if(return_levels)
			vampire_level_unspent++

/**
 * Disables all Torpor exclusive powers, if forced is TRUE, disable all powers
**/
/datum/antagonist/vampire/proc/disable_all_powers(forced = FALSE)
	for(var/datum/action/vampire/power as anything in powers)
		if(forced || ((power.check_flags & BP_CANT_USE_IN_TORPOR) && is_in_torpor()))
			if(power.currently_active)
				power.deactivate_power()

/**
 * Check if we have a stake in our heart
**/
/datum/antagonist/vampire/proc/check_if_staked()
	var/obj/item/bodypart/chosen_bodypart = owner.current.get_bodypart(BODY_ZONE_CHEST)
	for(var/obj/item/stake/embedded_stake in chosen_bodypart?.embedded_objects)
		return TRUE

	return FALSE
/**
 * ##adjust_humanity(count, silent)
 *
 * Adds the specified amount of humanity to the vampire
 * Checks to make sure it doesn't exceed 10,
 * Checks to make sure it doesn't go under 0,
 * Adds the masquerade power at 9 or above
 */
/datum/antagonist/vampire/proc/adjust_humanity(count, silent = FALSE)
	// Step one: Toreadors have doubled gains and losses
	if(istype(my_clan, /datum/vampire_clan/toreador))
		count = count * 2

	// No-op if nothing to change
	if(count == 0)
		return FALSE

	// If trying to add but already at max, there's nothing to do
	if(count > 0 && humanity >= 10)
		return FALSE

	// Same for removing
	if(count < 0 && humanity <= 0)
		return FALSE

	var/temp_humanity = humanity + count

	var/power_given = FALSE
	var/power_removed = FALSE

	// Are we adding or removing?
	if(count > 0)
		// We are adding
		if(temp_humanity >= VAMPIRE_HUMANITY_MASQUERADE_POWER && !is_type_in_list(/datum/action/vampire/masquerade, powers))
			// Grant_power might fail, so we need to check if it actually got granted
			var/was_granted = grant_power(new /datum/action/vampire/masquerade)
			if(was_granted)
				power_given = TRUE

		// Only run this code if there is an actual increase in humanity. Also don't run it if we wanna be silent.
		if(humanity < temp_humanity && !silent)
			if(power_given)
				to_chat(owner.current, span_userdanger("Your closeness to humanity has granted you the ability to feign life!"))
			else
				to_chat(owner.current, span_userdanger("You have gained humanity."))
	else
		// We are removing
		if(temp_humanity < VAMPIRE_HUMANITY_MASQUERADE_POWER)
			for(var/datum/action/vampire/masquerade/power in powers)
				remove_power(power)
				power_removed = TRUE

		// Only run this code if there is an actual decrease in humanity
		if(humanity > temp_humanity && !silent)
			if(power_removed)
				to_chat(owner.current, span_userdanger("Your inhuman actions have caused you to lose the masquerade ability!"))
			else
				to_chat(owner.current, span_userdanger("You have lost humanity."))

	// Clamp to valid range, we are so sane we might see the face of god
	if(temp_humanity > 10)
		temp_humanity = 10
	if(temp_humanity < 0)
		temp_humanity = 0

	humanity = temp_humanity
	return TRUE

/// Bacon wanted a signal
/datum/antagonist/vampire/proc/on_track_humanity_gain_signal(datum/source, type, subject)
	SIGNAL_HANDLER
	return track_humanity_gain_progress(type, subject)

/// Signal handler for when the vampire pets an animal
/datum/antagonist/vampire/proc/on_pet_animal(datum/source, mob/living/pet)
	SIGNAL_HANDLER
	return track_humanity_gain_progress(HUMANITY_PETTING_TYPE, pet)

/// Signal handler for when the vampire hugs a carbon
/datum/antagonist/vampire/proc/on_hug_carbon(datum/source, mob/living/carbon/hugged)
	SIGNAL_HANDLER
	if(!hugged.client) // Only count hugs with real players for humanity
		return
	return track_humanity_gain_progress(HUMANITY_HUGGING_TYPE, hugged)

/// Signal handler for when the vampire appraises art
/datum/antagonist/vampire/proc/on_appraise_art(datum/source, atom/art_piece)
	SIGNAL_HANDLER
	return track_humanity_gain_progress(HUMANITY_ART_TYPE, art_piece)

/**
 * ##track_humanity_gain_progress(type, subject)
 *
 * Adds the specified subject to the tracking lists and handles all the other stuff related to it.
 * When a defined threshold is met, hands out humanity as appropriate and stops tracking.
 * Ideally this can be expanded on easily by just defining a new threshold and tracking list in the datum and defines respectively.
 * We return TRUE if it successfully added to tracked, and FALSE if it was already tracked or failed for some other reason.
 */
/datum/antagonist/vampire/proc/track_humanity_gain_progress(type, subject)
	// placeholders to populate // I dunno why this works btw, i thought i made a mistake but it worked anyways.
	var/list/tracking_list = null
	var/goal = null

	if(humanity >= 10) // Don't add anything if we're already at max.
		return

	// map all the placeholders to the correct type, get the list for easier handling
	switch(type)
		if(HUMANITY_HUGGING_TYPE)
			tracking_list = humanity_trackgain_hugged
			goal = humanity_hugging_goal
		if(HUMANITY_PETTING_TYPE)
			tracking_list = humanity_trackgain_petted
			goal = humanity_petting_goal
		if(HUMANITY_ART_TYPE)
			tracking_list = humanity_trackgain_art
			goal = humanity_art_goal
		else
			return FALSE // Cheeky check for type built in? Tsunami you genius!

	// already tracked?
	if(subject in tracking_list)
		return FALSE

	// Update the corresponding list
	switch(type)
		if(HUMANITY_HUGGING_TYPE)
			humanity_trackgain_hugged += subject
		if(HUMANITY_PETTING_TYPE)
			humanity_trackgain_petted += subject
		if(HUMANITY_ART_TYPE)
			humanity_trackgain_art += subject

	if(tracking_list.len >= goal)
		// set the corresponding gained flag and award humanity
		switch(type)
			if(HUMANITY_HUGGING_TYPE)
				humanity_hugging_goal *= 2
			if(HUMANITY_PETTING_TYPE)
				humanity_petting_goal *= 2
			if(HUMANITY_ART_TYPE)
				humanity_art_goal *= 2
		adjust_humanity(1)

	return TRUE

	// It's a proc cuz we need to call this asynchronously from lifetick
/datum/antagonist/vampire/proc/provide_clan_selector()
	if(!is_type_in_list(/datum/action/vampire/clanselect, powers))
		grant_power(new /datum/action/vampire/clanselect)
		return

/datum/antagonist/vampire/proc/get_rank_string()
	switch(vampire_level)
		if(0 to 1)
			return "'Initiate'"
		if(2 to 3)
			return "'Novice'"
		if(4 to 5)
			return "'Apprentice'"
		if(6 to 7)
			return "'Adept'"
		if(8 to 9)
			return "'Expert'"
		if(10 to 11)
			return "'Master'"
		if(12 to 24)
			return "'Grand Master'"
		if(25 to INFINITY)
			return "[span_narsiesmall("'Methuselah'")]"

/// This is where we store clan descriptions.
/// We will need to know the description of a clan before we "make" one,
/// because we can't just get the description from the "not-made" clan ref.
/datum/antagonist/vampire/proc/get_clan_description(clan_name)
	/// This makes descriptions about a billion times cleaner: Spans for discipline names and their individual descriptions:
	var/disciplines = "[span_tooltip("Disciplines are the aspects of the original curse bestowed upon caine, of which every kindred suffers/benefits. In terms of gameplay, they are groups of abilities that you level up.", "Disciplines")]"
	var/animalism = "[span_tooltip("Animalism is a Discipline that brings the vampire closer to their animalistic nature. This typically allows them to communicate with and gain dominance over creatures of nature.", "Animalism")]"
	var/auspex = "[span_tooltip("Auspex is a Discipline that grants vampires supernatural senses, letting them peer far further and deeper than any mortal. The malkavians especially have a strong bond with it.", "Auspex")]"
	var/celerity = "[span_tooltip("Celerity is a Discipline that grants vampires supernatural quickness and reflexes.", "Celerity")]"
	var/dominate = "[span_tooltip("Dominate is a Discipline that overwhelms another person's mind with the vampire's will.", "Dominate")]"
	var/fortitude = "[span_tooltip("Fortitude is a Discipline that grants Kindred unearthly toughness.", "Fortitude")]"
	var/obfuscate = "[span_tooltip("Obfuscate is a Discipline that allows vampires to conceal themselves, deceive the mind of others, or make them ignore what the user does not want to be seen.", "Obfuscate")]"
	var/potence = "[span_tooltip("Potence is the Discipline that endows vampires with physical vigor and preternatural strength.", "Potence")]"
	var/presence = "[span_tooltip("Presence is the Discipline of supernatural allure and emotional manipulation which allows Kindred to attract, sway, and control crowds.", "Presence")]"
	var/protean = "[span_tooltip("Protean is a Discipline that gives vampires the ability to change form, from growing feral claws to turning into something entirely different.", "Protean")]"
	var/thaumaturgy = "[span_tooltip("Thaumaturgy is the secret blood-art of the clan tremere. Allowing them all manners of blood-sorcery and pacts.", "Thaumaturgy")]"

	/// All the descriptions:
	var/ventrue = "The ventrue are the de-facto leaders of the camarilla. They style themselves as kings and emperors, often inhabiting positions of power.\n\
		<b>IMPORTANT:</b> Members of the Ventrue Clan are eligible for princedom. If there is no current prince, you will become one. Please remember that princes are expected to behave in a manner befitting their office.\n\
		<b>[disciplines]:</b> [dominate], [fortitude], [presence]"
	var/tremere = "With a powerful ancestry of wizards and magicians, the tremere wield the secret art of blood magic, which they guard with utmost care.\n\
		<b>[disciplines]:</b> [thaumaturgy], [auspex], [dominate]"
	var/toreador = "Artists, Pleasure-workers, Celebrities. These are the people of the toreador clan. They are by far the closest to humanity of all kindred, each a deeply sensitive individual.\n\
		<b>[disciplines]:</b> [presence], [auspex], [celerity]"
	var/malkavian = "Completely insane. You gain constant hallucinations, become a prophet with unintelligable rambling, and gain insights better left unknown. You can also travel through Phobetor tears, rifts through spacetime only you can travel through.\n\
		<b>[disciplines]:</b> [dominate], [auspex], [obfuscate]"
	var/gangrel = "Often mistaken as werewolves, gangrel carry the smell of wet dog wherever they go. Their unique bond with the beast within allows them to transform parts of their body into powerful claws, even becoming entirely different beings.\n\
		<b>[disciplines]:</b> [animalism], [protean], [fortitude]"
	var/brujah = "A clan now, of mostly rebels. Though some still show fragments of their lost lineage of warrior-poets. They are long split from the camarilla, and often form their own groups.\n\
		<b>[disciplines]:</b> [potence], [celerity], [presence]"

	// Now the logic
	switch(clan_name)
		if(CLAN_TOREADOR)
			return toreador
		if(CLAN_VENTRUE)
			return ventrue
		if(CLAN_BRUJAH)
			return brujah
		if(CLAN_MALKAVIAN)
			return malkavian
		if(CLAN_TREMERE)
			return tremere
		if(CLAN_GANGREL)
			return gangrel

	log_runtime("Unknown clan name passed to get_clan_description: [clan_name]")
	return "No description available."

/**
 * Called when a Vampire reaches Final Death
 * Releases all Vassals.
 */
/datum/antagonist/vampire/proc/free_all_vassals()
	for(var/datum/antagonist/vassal/all_vassals in vassals)
		all_vassals.owner.remove_antag_datum(/datum/antagonist/vassal)
