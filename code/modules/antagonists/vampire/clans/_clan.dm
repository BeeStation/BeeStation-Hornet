/**
 * Vampire clans
 *
 * Handles everything related to clans.
 * the entire idea of datumizing this came to me in a dream.
 */
/datum/vampire_clan
	/// The name of the clan we're in.
	var/name = "ERROR"
	/// Description of what the clan is, given when joining and through your antag UI.
	var/description = "ERROR"
	/// Description shown when trying to join the clan.
	var/join_description = "ERROR"

	/// The vampire datum that owns this clan. Use this over 'source', because while it's the same thing, this is more consistent (and used for deletion).
	var/datum/antagonist/vampire/vampiredatum

	/// The icon of this clan on the selection radial menu.
	var/join_icon = 'icons/vampires/clan_icons.dmi'
	var/join_icon_state = "base"

	/// Whether the clan can be joined by players. FALSE for flavortext-only clans.
	var/joinable_clan = FALSE

	/// How we will drink blood using Feed.
	var/blood_drink_type = VAMPIRE_DRINK_NORMAL

	var/is_sabbat = FALSE	// In case we want a bad guy clan that doesn't care about the masquerade.

/**
 * Starting Humanity score, some clans are closer to the beast, some closer to humanity.
 * 10 	Saintly
 * 9 	Compassionate
 * 8 	Caring			// Masquerade ability given at 8 or above
 * 7 	Normal
 * 6 	Distant
 * 5 	Removed
 * 4 	Unfeeling
 * 3 	Cold
 * 2 	Bestial
 * 1 	Horrific
 * 0 	Wight
 */
	var/default_humanity = 7

/datum/vampire_clan/New(datum/antagonist/vampire/owner_datum)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_VAMPIRE_BROKE_MASQUERADE, PROC_REF(on_vampire_broke_masquerade))

	vampiredatum = owner_datum
	vampiredatum.add_humanity(default_humanity, TRUE)

	// Masquerade breakers
	for(var/datum/antagonist/vampire/unmasked in GLOB.masquerade_breakers)
		if(unmasked.owner.current)
			on_vampire_broke_masquerade(vampiredatum.owner.current, unmasked)

	for(var/datum/action/vampire/clanselect/clanselect in vampiredatum.powers)
		vampiredatum.remove_power(clanselect)

	vampiredatum.owner.current.playsound_local(get_turf(vampiredatum.owner.current), 'sound/vampires/VampireAlert.ogg', 80, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	to_chat(vampiredatum.owner.current, span_narsiesmall("I remember now. I belong with the [name]..."))

/datum/vampire_clan/Destroy(force)
	vampiredatum = null
	UnregisterSignal(SSdcs, COMSIG_VAMPIRE_BROKE_MASQUERADE)
	. = ..()

/**
 * Called when a Vampire exits Torpor
 */
/datum/vampire_clan/proc/on_exit_torpor()
	return

/**
 * Called during Vampire's LifeTick
 */
/datum/vampire_clan/proc/handle_clan_life()
	return

/**
 * Called when a Vampire successfully ghoulizes someone via the persuasion rack.
 * Do not call this on [/datum/antagonist/vampire/proc/make_ghoul()] !!!
 */
/datum/vampire_clan/proc/on_ghoul_made(mob/living/living_vampire, mob/living/living_ghoul)
	living_vampire.playsound_local(null, 'sound/effects/singlebeat.ogg', 70, TRUE)

	living_ghoul.playsound_local(null, 'sound/effects/singlebeat.ogg', 70, TRUE)
	living_ghoul.set_jitter_if_lower(30 SECONDS)
	living_ghoul.emote("laugh")

/**
 * Called when we level up inside a coffin.
 */

	/**
	 * For every discipline in clan_disciplines we do:
	 * if the next level returns anything but null, we add it to the options
	 * ///
	 * Then we display the radial with the options.
	 * Picking a choice will do the following:
	 * Remove all powers from the discipline's current level, by:
	 * for every power in get_abilities_with_level(current level) > remove
	 * increase discipline level
	 * for every power in get_abilities_with_level(current level) > add
	 */
/datum/vampire_clan/proc/spend_rank(mob/living/carbon/carbon_vampire)
	if(QDELETED(vampiredatum.owner?.current) || vampiredatum.vampire_level_unspent <= 0)
		return

	// Generate radial menu
	var/list/options = list()
	var/list/radial_display = list()

	for(var/datum/discipline/discipline as anything in vampiredatum.owned_disciplines)	// We do owned_disciplines, not clan_disciplines. clan_disciplines is used to populate owned_disciplines.
		if(discipline.get_abilities_with_level("next"))
			options[discipline.name] = discipline
			var/datum/radial_menu_choice/option = new
			option.image = image(icon = 'icons/vampires/disciplines.dmi', icon_state = discipline.icon_state)
			option.info = "[span_boldnotice(discipline.name)]\n[span_cult(discipline.discipline_explanation)]"
			radial_display[initial(discipline.name)] = option

	var/mob/living/living_vampire = vampiredatum.owner.current

	// Show radial menu
	if(!length(options))
		to_chat(living_vampire, span_notice("You grow more familiar with your powers!"))
	else
		to_chat(living_vampire, span_notice("You have the opportunity to grow your expertise. Select a discipline to advance your Rank."))

		// If we're in a closet, anchor the radial menu to it. If not, anchor it to the vampire body
		var/datum/discipline/discipline_response

		if(istype(living_vampire.loc, /obj/structure/closet))
			var/obj/structure/closet/container = living_vampire.loc
			discipline_response = show_radial_menu(living_vampire, container, radial_display)
		else
			discipline_response = show_radial_menu(living_vampire, living_vampire, radial_display)

		var/datum/discipline/chosen_discipline

		for(var/datum/discipline/discipline as anything in vampiredatum.owned_disciplines)
			if(discipline.name == discipline_response)
				chosen_discipline = discipline

		if(isnull(discipline_response) || QDELETED(src) || QDELETED(living_vampire))
			return FALSE

		// Remove all current powers
		for(var/datum/action/vampire/power_old as anything in vampiredatum.powers)
			if(is_type_in_list(power_old, chosen_discipline.get_abilities_with_level("current")))
				vampiredatum.remove_power(power_old)

		// increment level
		chosen_discipline.level_up()

		// add all current powers (of the new level)
		for(var/datum/action/vampire/power_new as anything in chosen_discipline.get_abilities_with_level("current"))
			vampiredatum.grant_power(new power_new)

		living_vampire.balloon_alert(living_vampire, "learned [discipline_response] level [chosen_discipline.level - 1]!")
		to_chat(living_vampire, span_notice("You have learned how to use [discipline_response]!"))

	finalize_spend_rank()

	// QoL
	if(vampiredatum.vampire_level_unspent > 0)
		spend_rank(carbon_vampire)

/datum/vampire_clan/proc/finalize_spend_rank()
	// Level up the vampire
	vampiredatum.vampire_regen_rate += 0.05
	vampiredatum.max_blood_volume += 100

	if(ishuman(vampiredatum.owner.current))
		var/mob/living/carbon/human/vampire_human = vampiredatum.owner.current
		vampire_human.dna.species.punchdamage += 0.5

	// We're almost done - Spend your Rank now.
	vampiredatum.vampire_level++
	vampiredatum.vampire_level_unspent--

	// Ranked up enough to get your true Reputation?
	if(vampiredatum.vampire_level == 4)
		vampiredatum.select_reputation(am_fledgling = FALSE, forced = TRUE)

	// Flavor
	to_chat(vampiredatum.owner.current, span_notice("You are now a rank [vampiredatum.vampire_level] Vampire. \
		Your strength, health, feed rate, regen rate, and maximum blood capacity have all increased! \n\
		* Your existing powers have all ranked up as well!"))
	vampiredatum.owner.current.playsound_local(null, 'sound/effects/pope_entry.ogg', 25, TRUE, pressure_affected = FALSE)
	vampiredatum.update_hud()

/**
 * Calculates how many ghouls you can have at any given time
 */
/datum/vampire_clan/proc/get_max_ghouls()
	var/total_players = length(GLOB.joined_player_list)
	switch(total_players)
		if(1 to 15)			// No ghouls during low-lowpop
			return 0
		if(16 to 30)		// 1 ghoul during normal pop
			return 1
		if(31 to INFINITY)	// if we can support it, we allow 2
			return 2

/datum/vampire_clan/proc/on_vampire_broke_masquerade(datum/source, datum/antagonist/vampire/masquerade_breaker)
	SIGNAL_HANDLER

	if(masquerade_breaker == vampiredatum)
		return

	to_chat(vampiredatum.owner.current, span_userdanger("[masquerade_breaker.owner.current] has broken the Masquerade! We must punish this transgression with final death!"))
	var/datum/objective/assassinate/masquerade_objective = new()
	masquerade_objective.target = masquerade_breaker.owner
	masquerade_objective.name = "Masquerade Objective"
	masquerade_objective.explanation_text = "Ensure [masquerade_breaker.owner.current], who has broken the Masquerade, succumbs to Final Death."
	vampiredatum.objectives += masquerade_objective
	vampiredatum.owner.announce_objectives()
