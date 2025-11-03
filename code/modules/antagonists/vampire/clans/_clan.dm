/**
 * Vampire clans
 *
 * Handles everything related to clans.
 * the entire idea of datumizing this came to me in a dream.
 */
/datum/vampire_clan
	/// The name of the clan we're in.
	var/name = CLAN_CAITIFF
	/// Description of what the clan is, given when joining and through your antag UI.
	var/description = "The Caitiff are seen as either vile thinbloods, or vile mongrels, either case you are likely not to make many friends.\n\n\
		In your case, your blood is strong enough to grant you some basic abilities of various disciplines."
	/// Description shown when trying to join the clan.
	var/join_description = "The average thinblood, hated by polite kindred society. Expect to get killed by the first proper vampire that finds out your mongrel lineage."

	/// The vampire datum that owns this clan. Use this over 'source', because while it's the same thing, this is more consistent (and used for deletion).
	var/datum/antagonist/vampire/vampiredatum

	/// The icon of this clan on the selection radial menu.
	var/join_icon = 'icons/vampires/clan_icons.dmi'
	var/join_icon_state = "caitiff"

	/// Whether the clan can be joined by players. FALSE for flavortext-only clans.
	var/joinable_clan = TRUE

	/// How we will drink blood using Feed.
	var/blood_drink_type = VAMPIRE_DRINK_NORMAL

	var/is_sabbat = FALSE	// In case we want a bad guy clan that doesn't care about the masquerade.

/**
 * Starting Humanity score, some clans are closer to the beast, some closer to humanity.
 * 10 	Saintly
 * 9 	Compassionate
 * 8 	Caring
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
 * Called when we successfully turn a ghoul into a Favorite ghoul
 */
/datum/vampire_clan/proc/on_favorite_ghoul(datum/antagonist/ghoul/favorite/favorite_ghoul)
	favorite_ghoul.grant_power(new /datum/action/vampire/targeted/brawn)

/**
 * Called when we level up inside a coffin.
 */
/datum/vampire_clan/proc/spend_rank(mob/living/carbon/carbon_ghoul)
	if(QDELETED(vampiredatum.owner?.current) || vampiredatum.vampire_level_unspent <= 0)
		return

	// Generate radial menu
	var/list/options = list()
	var/list/radial_display = list()
	//for(var/datum/action/vampire/power as anything in vampiredatum.all_vampire_powers)
	//	if((initial(power.purchase_flags) & VAMPIRE_CAN_BUY) && !(locate(power) in vampiredatum.powers))
	//		options[initial(power.name)] = power

	//		var/datum/radial_menu_choice/option = new
	//		option.image = image(icon = 'icons/vampires/actions_vampire.dmi', icon_state = initial(power.button_icon_state))
	//		option.info = "[span_boldnotice(initial(power.name))]\n[span_cult(power.power_explanation)]"
	//		radial_display[initial(power.name)] = option

	var/mob/living/living_vampire = vampiredatum.owner.current

	// Show radial menu
	if(!length(options))
		to_chat(living_vampire, span_notice("You grow more familiar with your powers!"))
	else
		to_chat(living_vampire, span_notice("You have the opportunity to grow your expertise. Select a power to advance your Rank."))

		// If we're in a closet, anchor the radial menu to it. If not, anchor it to the vampire body
		var/power_response
		if(istype(living_vampire.loc, /obj/structure/closet))
			var/obj/structure/closet/container = living_vampire.loc
			power_response = show_radial_menu(living_vampire, container, radial_display, radius = 45)
		else
			power_response = show_radial_menu(living_vampire, living_vampire, radial_display, radius = 45)

		if(isnull(power_response) || QDELETED(src) || QDELETED(living_vampire))
			return FALSE

		// Give power
		var/datum/action/vampire/purchased_power = options[power_response]
		vampiredatum.grant_power(new purchased_power)

		living_vampire.balloon_alert(living_vampire, "learned [power_response]!")
		to_chat(living_vampire, span_notice("You have learned how to use [power_response]!"))

	finalize_spend_rank()

	// QoL
	if(vampiredatum.vampire_level_unspent > 0)
		spend_rank(carbon_ghoul)

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
 * Called when we click on a Persusasion Rack with one of our ghouls on it
 * args:
 * ghouldatum - the ghoul datum of the ghoul being interacted with.
 */
/datum/vampire_clan/proc/interact_with_ghoul(datum/antagonist/ghoul/ghouldatum)
	var/mob/living/living_vampire = vampiredatum.owner.current
	var/mob/living/living_ghoul = ghouldatum.owner.current

	if(ghouldatum.special_type)
		to_chat(living_vampire, span_notice("This ghoul was already assigned a special position."))
		return FALSE
	if(!(MOB_ORGANIC in living_ghoul.mob_biotypes)) // !(living_ghoul.mob_biotypes & MOB_ORGANIC)
		to_chat(living_vampire, span_notice("This ghoul is unable to gain a special rank due to innate features."))
		return FALSE

	var/list/options = list()
	var/list/radial_display = list()
	for(var/datum/antagonist/ghoul/ghoul_path as anything in subtypesof(/datum/antagonist/ghoul))

		options[initial(ghoul_path.name)] = ghoul_path

		var/datum/radial_menu_choice/option = new
		option.image = image(icon = 'icons/mob/hud.dmi', icon_state = initial(ghoul_path.ghoul_hud_name))
		option.info = "[span_boldnotice(initial(ghoul_path.name))]\n[span_cult(initial(ghoul_path.ghoul_description))]"
		radial_display[initial(ghoul_path.name)] = option

	if(!length(options))
		return

	to_chat(living_vampire, span_notice("You can change who this ghoul is, who are they to you?"))
	var/ghoul_response = show_radial_menu(living_vampire, living_ghoul, radial_display, radius = 45)
	if(!ghoul_response)
		return
	ghoul_response = options[ghoul_response]
	if(QDELETED(src) || QDELETED(living_vampire) || QDELETED(living_ghoul))
		return FALSE
	ghouldatum.make_special(ghoul_response)
	vampiredatum.vampire_blood_volume -= 150
	return TRUE

/**
 * Calculates how many ghouls you can have at any given time
 */
/datum/vampire_clan/proc/get_max_ghouls()
	var/total_players = length(GLOB.joined_player_list)
	switch(total_players)
		if(1 to 30)
			return 1
		if(31 to INFINITY)
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
