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
	var/description = "The Caitiff is as basic as you can get with Vampires.\n\
		No additional abilities are gained, nothing is lost, if you want a plain Vampire, this is it.\n\
		Your Favorite Vassal will gain the Brawn ability to help in combat."
	/// Description shown when trying to join the clan.
	var/join_description = "The default, Classic Vampire. You gain nothing, you lose nothing."

	/// The vampire datum that owns this clan. Use this over 'source', because while it's the same thing, this is more consistent (and used for deletion).
	var/datum/antagonist/vampire/vampiredatum

	/// The clan objective that is required to greentext.
	var/datum/objective/vampire/clan_objective

	/// The icon of this clan on the selection radial menu.
	var/join_icon = 'icons/vampires/clan_icons.dmi'
	var/join_icon_state = "caitiff"

	/// Whether the clan can be joined by players. FALSE for flavortext-only clans.
	var/joinable_clan = TRUE

	/// How we will drink blood using Feed.
	var/blood_drink_type = VAMPIRE_DRINK_NORMAL

/datum/vampire_clan/New(datum/antagonist/vampire/owner_datum)
	. = ..()
	vampiredatum = owner_datum
	give_clan_objective()

/datum/vampire_clan/Destroy(force)
	remove_clan_objective()
	vampiredatum = null
	. = ..()

/datum/vampire_clan/proc/give_clan_objective()
	if(!ispath(clan_objective))
		return
	clan_objective = new clan_objective()
	clan_objective.name = "Clan Objective"
	clan_objective.owner = vampiredatum.owner
	vampiredatum.objectives += clan_objective
	vampiredatum.owner.announce_objectives()

/datum/vampire_clan/proc/remove_clan_objective()
	vampiredatum.objectives -= clan_objective
	QDEL_NULL(clan_objective)
	vampiredatum.owner.announce_objectives()

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
 * Called when a Vampire successfully vassalizes someone via the persuasion rack.
 * Do not call this on [/datum/antagonist/vampire/proc/make_vassal()] !!!
 */
/datum/vampire_clan/proc/on_vassal_made(mob/living/living_vampire, mob/living/living_vassal)
	living_vampire.playsound_local(null, 'sound/effects/singlebeat.ogg', 70, TRUE)

	living_vassal.playsound_local(null, 'sound/effects/singlebeat.ogg', 70, TRUE)
	living_vassal.set_jitter_if_lower(30 SECONDS)
	living_vassal.emote("laugh")

/**
 * Called when we successfully turn a Vassal into a Favorite Vassal
 */
/datum/vampire_clan/proc/on_favorite_vassal(datum/antagonist/vassal/favorite/favorite_vassal)
	favorite_vassal.grant_power(new /datum/action/vampire/targeted/brawn)

/datum/vampire_clan/proc/spend_rank(mob/living/carbon/carbon_vassal)
	if(QDELETED(vampiredatum.owner?.current) || vampiredatum.vampire_level_unspent <= 0)
		return

	// Generate radial menu
	var/list/options = list()
	var/list/radial_display = list()
	for(var/datum/action/vampire/power as anything in vampiredatum.all_vampire_powers)
		if((initial(power.purchase_flags) & VAMPIRE_CAN_BUY) && !(locate(power) in vampiredatum.powers))
			options[initial(power.name)] = power

			var/datum/radial_menu_choice/option = new
			option.image = image(icon = 'icons/vampires/actions_vampire.dmi', icon_state = initial(power.button_icon_state))
			option.info = "[span_boldnotice(initial(power.name))]\n[span_cult(power.power_explanation)]"
			radial_display[initial(power.name)] = option

	var/mob/living/living_vampire = vampiredatum.owner.current

	// Show radial menu
	if(!length(options))
		to_chat(living_vampire, span_notice("You grow more ancient by the night!"))
	else
		to_chat(living_vampire, span_notice("You have the opportunity to grow more ancient. Select a power to advance your Rank."))

		// If we're in a closet, anchor the radial menu to it. If not, anchor it to the vampire body
		var/power_response
		if(istype(living_vampire.loc, /obj/structure/closet))
			var/obj/structure/closet/container = living_vampire.loc
			power_response = show_radial_menu(living_vampire, container, radial_display)
		else
			power_response = show_radial_menu(living_vampire, living_vampire, radial_display)

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
		spend_rank(carbon_vassal)

/datum/vampire_clan/proc/finalize_spend_rank()
	// Level up the vampire
	vampiredatum.level_up_powers()
	vampiredatum.vampire_regen_rate += 0.05
	vampiredatum.max_blood_volume += 100

	if(ishuman(vampiredatum.owner.current))
		var/mob/living/carbon/human/vampire_human = vampiredatum.owner.current
		vampire_human.add_unarmed_damage_to_arms(0.5)

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
 * Called when we click on a Persusasion Rack with one of our vassals on it
 * args:
 * vassaldatum - the vassal datum of the vassal being interacted with.
 */
/datum/vampire_clan/proc/interact_with_vassal(datum/antagonist/vassal/vassaldatum)
	var/mob/living/living_vampire = vampiredatum.owner.current
	var/mob/living/living_vassal = vassaldatum.owner.current

	if(vassaldatum.special_type)
		to_chat(living_vampire, span_notice("This Vassal was already assigned a special position."))
		return FALSE
	if(!(living_vassal.mob_biotypes & MOB_ORGANIC))
		to_chat(living_vampire, span_notice("This Vassal is unable to gain a special rank due to innate features."))
		return FALSE

	// Brujuah clan time
	if(istype(clan_objective, /datum/objective/brujah) && clan_objective.target == vassaldatum.owner)
		var/datum/objective/brujah/brujah_objective = clan_objective

		// Find Mind Implant & Destroy
		for(var/obj/item/implant/mindshield/mindshield in living_vassal.implants)
			qdel(mindshield)

		vassaldatum.make_special(/datum/antagonist/vassal/discordant)
		brujah_objective.target_subverted = TRUE
		to_chat(living_vampire, span_notice("You have turned [living_vassal] into a Discordant Vassal."))
		playsound(living_vassal, 'sound/effects/rocktap3.ogg', 75)
		vassaldatum.owner?.announce_objectives()
		return TRUE

	var/list/options = list()
	var/list/radial_display = list()
	for(var/datum/antagonist/vassal/vassal_path as anything in subtypesof(/datum/antagonist/vassal))
		if(vampiredatum.special_vassals[initial(vassal_path.special_type)] > 0)
			continue
		if(initial(vassal_path.special_type) == DISCORDANT_VASSAL && \
			!(istype(vampiredatum.my_clan, /datum/vampire_clan/brujah) && vampiredatum.my_clan.clan_objective.target == vassaldatum.owner))
			continue

		options[initial(vassal_path.name)] = vassal_path

		var/datum/radial_menu_choice/option = new
		option.image = image(icon = 'icons/mob/hud.dmi', icon_state = initial(vassal_path.vassal_hud_name))
		option.info = "[span_boldnotice(initial(vassal_path.name))]\n[span_cult(initial(vassal_path.vassal_description))]"
		radial_display[initial(vassal_path.name)] = option

	if(!length(options))
		return

	to_chat(living_vampire, span_notice("You can change who this Vassal is, who are they to you?"))
	var/vassal_response = show_radial_menu(living_vampire, living_vassal, radial_display)
	if(!vassal_response)
		return
	vassal_response = options[vassal_response]
	if(QDELETED(src) || QDELETED(living_vampire) || QDELETED(living_vassal))
		return FALSE
	vassaldatum.make_special(vassal_response)
	vampiredatum.vampire_blood_volume -= 150
	return TRUE

/**
 * Calculates how many vassals you can have at any given time
 */
/datum/vampire_clan/proc/get_max_vassals()
	var/total_players = length(GLOB.joined_player_list)
	switch(total_players)
		if(1 to 20)
			return 1
		if(21 to 30)
			return 3
		if(31 to INFINITY)
			return 4
