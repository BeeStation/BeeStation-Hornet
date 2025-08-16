/**
 * Vampire clans
 *
 * Handles everything related to clans.
 * the entire idea of datumizing this came to me in a dream.
 */
/datum/vampire_clan
	///The vampire datum that owns this clan. Use this over 'source', because while it's the same thing, this is more consistent (and used for deletion).
	var/datum/antagonist/vampire/vampiredatum
	///The name of the clan we're in.
	var/name = CLAN_NONE
	///Description of what the clan is, given when joining and through your antag UI.
	var/description = "The Caitiff is as basic as you can get with Vampires.\n\
		No additional abilities are gained, nothing is lost, if you want a plain Vampire, this is it.\n\
		Your Favorite Vassal will gain the Brawn ability to help in combat."
	///The clan objective that is required to greentext.
	var/datum/objective/vampire/clan_objective
	///The icon of the radial icon to join this clan.
	var/join_icon = 'icons/vampires/clan_icons.dmi'
	///Same as join_icon, but the state
	var/join_icon_state = "caitiff"
	///Description shown when trying to join the clan.
	var/join_description = "The default, Classic Vampire. You gain nothing, you lose nothing."
	///Whether the clan can be joined by players. FALSE for flavortext-only clans.
	var/joinable_clan = TRUE

	///How we will drink blood using Feed.
	var/blood_drink_type = VAMPIRE_DRINK_NORMAL

/datum/vampire_clan/New(datum/antagonist/vampire/owner_datum)
	. = ..()
	vampiredatum = owner_datum

	RegisterSignal(vampiredatum, COMSIG_VAMPIRE_ON_LIFETICK, PROC_REF(handle_clan_life))
	RegisterSignal(vampiredatum, VAMPIRE_RANK_UP, PROC_REF(on_spend_rank))

	RegisterSignal(vampiredatum, VAMPIRE_INTERACT_WITH_VASSAL, PROC_REF(on_interact_with_vassal))
	RegisterSignal(vampiredatum, VAMPIRE_MAKE_FAVORITE, PROC_REF(on_favorite_vassal))

	RegisterSignal(vampiredatum, VAMPIRE_MADE_VASSAL, PROC_REF(on_vassal_made))
	RegisterSignal(vampiredatum, VAMPIRE_EXIT_TORPOR, PROC_REF(on_exit_torpor))

	RegisterSignal(vampiredatum, VAMPIRE_ENTERS_FRENZY, PROC_REF(on_enter_frenzy))
	RegisterSignal(vampiredatum, VAMPIRE_EXITS_FRENZY, PROC_REF(on_exit_frenzy))

	give_clan_objective()

/datum/vampire_clan/Destroy(force)
	UnregisterSignal(vampiredatum, list(
		COMSIG_VAMPIRE_ON_LIFETICK,
		VAMPIRE_RANK_UP,
		VAMPIRE_INTERACT_WITH_VASSAL,
		VAMPIRE_MAKE_FAVORITE,
		VAMPIRE_MADE_VASSAL,
		VAMPIRE_EXIT_TORPOR,
		VAMPIRE_ENTERS_FRENZY,
		VAMPIRE_EXITS_FRENZY,
	))
	remove_clan_objective()
	vampiredatum = null
	. = ..()

/datum/vampire_clan/proc/on_enter_frenzy(datum/antagonist/vampire/source)
	SIGNAL_HANDLER

	var/mob/living/carbon/human/human_vampire = vampiredatum.owner.current
	human_vampire?.physiology?.stamina_mod *= 0.4

/datum/vampire_clan/proc/on_exit_frenzy(datum/antagonist/vampire/source)
	SIGNAL_HANDLER

	var/mob/living/carbon/human/human_vampire = vampiredatum.owner.current
	if(human_vampire)
		human_vampire.set_dizziness(3 SECONDS)
		human_vampire.Paralyze(2 SECONDS)
		human_vampire.physiology.stamina_mod /= 0.4

/datum/vampire_clan/proc/give_clan_objective()
	if(isnull(clan_objective))
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
 * args:
 * source - the Vampire exiting Torpor
 */
/datum/vampire_clan/proc/on_exit_torpor(datum/antagonist/vampire/source)
	SIGNAL_HANDLER

/**
 * Called during Vampire's LifeTick
 * args:
 * vampiredatum - the antagonist datum of the Vampire running this.
 */
/datum/vampire_clan/proc/handle_clan_life(datum/antagonist/vampire/source)
	SIGNAL_HANDLER

/**
 * Called when a Vampire successfully Vassalizes someone.
 * args:
 * vampiredatum - the antagonist datum of the Vampire running this.
 */
/datum/vampire_clan/proc/on_vassal_made(datum/antagonist/vampire/source, mob/living/user, mob/living/target)
	SIGNAL_HANDLER
	user.playsound_local(null, 'sound/effects/explosion_distant.ogg', 40, TRUE)
	target.playsound_local(null, 'sound/effects/singlebeat.ogg', 40, TRUE)
	target.Jitter(15 SECONDS)
	INVOKE_ASYNC(target, TYPE_PROC_REF(/mob, emote), "laugh")

/**
 * Called when a Vampire successfully starts spending their Rank
 * args:
 * vampiredatum - the antagonist datum of the Vampire running this.
 * target - The Vassal (if any) we are upgrading.
 * cost_rank - TRUE/FALSE on whether this will cost us a rank when we go through with it.
 * blood_cost - A number saying how much it costs to rank up.
 */
/datum/vampire_clan/proc/on_spend_rank(datum/antagonist/vampire/source, mob/living/carbon/target, cost_rank = TRUE, blood_cost)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(spend_rank), vampiredatum, target, cost_rank, blood_cost)

/datum/vampire_clan/proc/spend_rank(datum/antagonist/vampire/source, mob/living/carbon/target, cost_rank = TRUE, blood_cost)
	// Purchase Power Prompt
	var/list/options = list()
	var/list/radial_display = list()
	for(var/datum/action/vampire/power as anything in vampiredatum.all_vampire_powers)
		if(initial(power.purchase_flags) & VAMPIRE_CAN_BUY && !(locate(power) in vampiredatum.powers))
			options[initial(power.name)] = power

			var/datum/radial_menu_choice/option = new
			option.image = image(icon = 'icons/vampires/actions_vampire.dmi', icon_state = initial(power.button_icon_state))
			option.info = "[span_boldnotice(initial(power.name))]\n[span_cult(power.power_explanation)]"
			radial_display[initial(power.name)] = option

	var/mob/living/user = vampiredatum.owner.current

	if(!length(options))
		to_chat(user, span_notice("You grow more ancient by the night!"))
	else
		to_chat(user, span_notice("You have the opportunity to grow more ancient. Select a power to advance your Rank."))

		var/power_response
		if(istype(user.loc, /obj/structure/closet))
			var/obj/structure/closet/container = user.loc
			power_response = show_radial_menu(user, container, radial_display)
		else
			power_response = show_radial_menu(user, user, radial_display)

		if(!power_response || QDELETED(src) || QDELETED(user))
			return FALSE

		var/datum/action/vampire/purchased_power = options[power_response]
		vampiredatum.BuyPower(new purchased_power)
		user.balloon_alert(user, "learned [power_response]!")
		to_chat(user, span_notice("You have learned how to use [power_response]!"))

	finalize_spend_rank(vampiredatum, cost_rank, blood_cost)

	// QoL
	if(vampiredatum.vampire_level_unspent > 0)
		spend_rank(source, target, cost_rank, blood_cost)

/datum/vampire_clan/proc/finalize_spend_rank(datum/antagonist/vampire/source, cost_rank = TRUE, blood_cost)
	vampiredatum.LevelUpPowers()
	vampiredatum.vampire_regen_rate += 0.05
	vampiredatum.max_blood_volume += 100

	var/mob/living/carbon/human/vampire_human = vampiredatum.owner.current
	if(ishuman(vampire_human))
		vampire_human.dna.species.punchdamage += 0.5
	// We're almost done - Spend your Rank now.
	vampiredatum.vampire_level++
	if(cost_rank)
		vampiredatum.vampire_level_unspent--
	if(blood_cost)
		vampiredatum.AddBloodVolume(-blood_cost)

	// Ranked up enough to get your true Reputation?
	if(vampiredatum.vampire_level == 4)
		vampiredatum.SelectReputation(am_fledgling = FALSE, forced = TRUE)

	to_chat(vampiredatum.owner.current, span_notice("You are now a rank [vampiredatum.vampire_level] Vampire. \
		Your strength, health, feed rate, regen rate, and maximum blood capacity have all increased! \n\
		* Your existing powers have all ranked up as well!"))
	vampiredatum.owner.current.playsound_local(null, 'sound/effects/pope_entry.ogg', 25, TRUE, pressure_affected = FALSE)
	vampiredatum.update_hud()

/**
 * Called when we are trying to turn someone into a Favorite Vassal
 * args:
 * vampiredatum - the antagonist datum of the Vampire performing this.
 * vassaldatum - the antagonist datum of the Vassal being offered up.
 */
/datum/vampire_clan/proc/on_interact_with_vassal(datum/antagonist/vampire/source, datum/antagonist/vassal/vassaldatum)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(interact_with_vassal), vampiredatum, vassaldatum)

/datum/vampire_clan/proc/interact_with_vassal(datum/antagonist/vampire/source, datum/antagonist/vassal/vassaldatum)
	if(vassaldatum.special_type)
		to_chat(vampiredatum.owner.current, span_notice("This Vassal was already assigned a special position."))
		return FALSE
	if(!(vassaldatum.owner.current.mob_biotypes & MOB_ORGANIC))
		to_chat(vampiredatum.owner.current, span_notice("This Vassal is unable to gain a special rank due to innate features."))
		return FALSE

	// Brujuah clan time
	if(istype(clan_objective, /datum/objective/brujah_clan_objective) && (clan_objective.target == vassaldatum.owner))
		var/datum/objective/brujah_clan_objective/brujah_objective = clan_objective

		// Find Mind Implant & Destroy
		for(var/obj/item/implant/mindshield/mindshield in vassaldatum.owner.current.implants)
			mindshield.Destroy()

		vassaldatum.make_special(/datum/antagonist/vassal/discordant)
		brujah_objective.target_subverted = TRUE
		to_chat(source.owner, span_notice("You have turned [vassaldatum.owner.current?.name] into a Discordant Vassal."))
		playsound(get_turf(vassaldatum.owner.current), 'sound/effects/rocktap3.ogg', 75)
		vassaldatum.owner.announce_objectives()
		return TRUE

	var/list/options = list()
	var/list/radial_display = list()
	for(var/datum/antagonist/vassal/vassal_path as anything in subtypesof(/datum/antagonist/vassal))
		if(vampiredatum.special_vassals[initial(vassal_path.special_type)])
			continue
		if(initial(vassal_path.special_type) == DISCORDANT_VASSAL && (!source.my_clan.clan_objective || vassaldatum.owner != source.my_clan.clan_objective.target))
			continue
		options[initial(vassal_path.name)] = vassal_path

		var/datum/radial_menu_choice/option = new
		option.image = image(icon = 'icons/mob/hud.dmi', icon_state = initial(vassal_path.vassal_hud_name))
		option.info = "[span_boldnotice(initial(vassal_path.name))]\n[span_cult(initial(vassal_path.vassal_description))]"
		radial_display[initial(vassal_path.name)] = option

	if(!length(options))
		return

	to_chat(vampiredatum.owner.current, span_notice("You can change who this Vassal is, who are they to you?"))
	var/vassal_response = show_radial_menu(vampiredatum.owner.current, vassaldatum.owner.current, radial_display)
	if(!vassal_response)
		return
	vassal_response = options[vassal_response]
	if(QDELETED(src) || QDELETED(vampiredatum.owner.current) || QDELETED(vassaldatum.owner.current))
		return FALSE
	vassaldatum.make_special(vassal_response)
	vampiredatum.vampire_blood_volume -= 150
	return TRUE

/**
 * Called when we are successfully turn a Vassal into a Favorite Vassal
 * args:
 * source - antagonist datum of the Vampire who turned them into a Vassal.
 * vassaldatum - the antagonist datum of the Vassal being offered up.
 */
/datum/vampire_clan/proc/on_favorite_vassal(datum/antagonist/vampire/source, datum/antagonist/vassal/vassaldatum)
	SIGNAL_HANDLER
	vassaldatum.BuyPower(new /datum/action/vampire/targeted/brawn)

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
