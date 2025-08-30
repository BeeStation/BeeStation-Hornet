///The maximum level a Ventrue Vampire can be, before they have to level up their vassal instead.
#define VENTRUE_MAX_LEVEL 3
///How much it costs for a Ventrue to rank up without a spare rank to spend.
#define VAMPIRE_BLOOD_RANKUP_COST (550)

/datum/vampire_clan/ventrue
	name = CLAN_VENTRUE
	description = "The Ventrue Clan is extremely snobby with their meals and refuse to drink blood from the mindless.\n\
		You may only level yourself up to Rank 3, anything further will be ranks to spend on your Favorite Vassal through a Persuasion Rack.\n\
		The Favorite Vassal will slowly turn more Vampiric this way, until they finally lose their last bits of Humanity."
	clan_objective = /datum/objective/vampire/embrace
	join_icon_state = "ventrue"
	join_description = "You lose the ability to drink from mindless mobs\n<b>IMPORTANT:</b> \
		Members of the Ventrue Clan can only purchase 3 powers. The rest of their ranks they will use to level up a vassal into a vampire."
	blood_drink_type = VAMPIRE_DRINK_SNOBBY

/datum/vampire_clan/ventrue/spend_rank(datum/antagonist/vampire/source, mob/living/carbon/carbon_vassal, cost_rank = TRUE, blood_cost)
	// No vassal to level up? Just level yourself up (if you can)
	if(!carbon_vassal)
		if(vampiredatum.vampire_level < VENTRUE_MAX_LEVEL)
			return ..()
		return FALSE

	// Must be the favorite vassal
	var/datum/antagonist/vassal/favorite/vassaldatum = IS_FAVORITE_VASSAL(carbon_vassal)
	if(!vassaldatum)
		return FALSE

	// Generate radial menu
	var/list/options = list()
	var/list/radial_display = list()
	for(var/datum/action/vampire/power as anything in vampiredatum.all_vampire_powers)
		if((initial(power.purchase_flags) & VASSAL_CAN_BUY) && !(locate(power) in vassaldatum.powers))
			options[initial(power.name)] = power

			var/datum/radial_menu_choice/option = new
			option.image = image(icon = initial(power.icon_icon), icon_state = initial(power.button_icon_state))
			option.info = "[span_boldnotice(initial(power.name))]\n[span_cult(power.power_explanation)]"
			radial_display[initial(power.name)] = option

	var/mob/living/living_vampire = vampiredatum.owner.current

	// Purchase Power Prompt
	if(!length(options))
		to_chat(living_vampire, span_notice("You grow more ancient by the night!"))
	else
		to_chat(living_vampire, span_notice("You have the opportunity to level up your Favorite Vassal. Select a power you wish for them to receive."))

		var/power_response = show_radial_menu(living_vampire, carbon_vassal, radial_display)

		if(isnull(power_response) || QDELETED(src) || QDELETED(carbon_vassal) || QDELETED(living_vampire))
			return FALSE

		// Prevent Vampires from closing/reopning their coffin to spam Levels.
		if(cost_rank && vampiredatum.vampire_level_unspent <= 0)
			return FALSE
		if((locate(options[power_response]) in vassaldatum.powers))
			return FALSE

		// Give power
		var/datum/action/vampire/purchased_power = options[power_response]
		vassaldatum.BuyPower(new purchased_power)

		living_vampire.balloon_alert(living_vampire, "taught [power_response]!")
		to_chat(living_vampire, span_notice("You taught [carbon_vassal] how to use [power_response]!"))

		carbon_vassal.balloon_alert(carbon_vassal, "learned [power_response]!")
		to_chat(carbon_vassal, span_notice("Your master taught you how to use [power_response]!"))

	vassaldatum.vassal_level++
	switch(vassaldatum.vassal_level)
		if(2)
			carbon_vassal.add_traits(list(TRAIT_COLDBLOODED, TRAIT_NOBREATH, TRAIT_AGEUSIA), TRAIT_VAMPIRE)
			to_chat(carbon_vassal, span_notice("Your blood begins to feel cold, and as a mote of ash lands upon your tongue, you stop breathing..."))
		if(3)
			carbon_vassal.add_traits(list(TRAIT_NOCRITDAMAGE, TRAIT_NOSOFTCRIT), TRAIT_VAMPIRE)
			to_chat(carbon_vassal, span_notice("You feel your Master's blood reinforce you, strengthening you up."))
		if(4)
			carbon_vassal.add_traits(list(TRAIT_SLEEPIMMUNE, TRAIT_VIRUSIMMUNE), TRAIT_VAMPIRE)
			to_chat(carbon_vassal, span_notice("You feel your Master's blood begin to protect you from bacteria."))
			if(ishuman(carbon_vassal))
				var/mob/living/carbon/human/human_vassal = carbon_vassal
				human_vassal.skin_tone = "albino"
		if(5)
			ADD_TRAIT(carbon_vassal, TRAIT_NOHARDCRIT, TRAIT_VAMPIRE)
			to_chat(carbon_vassal, span_notice("You feel yourself able to take cuts and stabbings like it's nothing."))
		if(6 to INFINITY)
			to_chat(carbon_vassal, span_notice("You feel your heart stop pumping for the last time as you begin to thirst for blood, you feel... dead."))
			message_admins("[carbon_vassal] has become a Vampire, and was created by [living_vampire].")
			log_admin("[carbon_vassal] has become a Vampire, and was created by [living_vampire].")

			// Complete objective
			var/datum/objective/vampire/embrace/embrace_objective = clan_objective
			embrace_objective.completed = TRUE

			// Make them a vampire
			var/vassal_level = vassaldatum.vassal_level
			vassaldatum.silent = TRUE
			carbon_vassal.mind.remove_antag_datum(/datum/antagonist/vassal)

			carbon_vassal.mind.add_antag_datum(/datum/antagonist/vampire)
			var/datum/antagonist/vampire/new_vampire = IS_VAMPIRE(carbon_vassal)
			new_vampire.vampire_level_unspent = vassal_level

			SEND_SIGNAL(vampiredatum.owner, COMSIG_ADD_MOOD_EVENT, "vampcandle", /datum/mood_event/vampcandle)

	finalize_spend_rank(vampiredatum, cost_rank, blood_cost)
	vassaldatum.LevelUpPowers()

	// QoL
	if(vampiredatum.vampire_level_unspent > 0)
		spend_rank(source, carbon_vassal, cost_rank, blood_cost)

/datum/vampire_clan/ventrue/interact_with_vassal(datum/antagonist/vampire/source, datum/antagonist/vassal/favorite/vassaldatum)
	. = ..()
	if(.)
		return TRUE

	if(!istype(vassaldatum))
		return FALSE
	if(!vampiredatum.vampire_level_unspent <= 0)
		vampiredatum.spend_rank(vassaldatum.owner.current)
		return TRUE
	if(vampiredatum.vampire_blood_volume >= VAMPIRE_BLOOD_RANKUP_COST)
		// We don't have any ranks to spare? Let them upgrade... with enough Blood.
		to_chat(vampiredatum.owner.current, span_warning("Do you wish to spend [VAMPIRE_BLOOD_RANKUP_COST] Blood to Rank [vassaldatum.owner.current] up?"))
		var/static/list/rank_options = list(
			"Yes" = image(icon = 'icons/hud/radials/radial_generic.dmi', icon_state = "radial_yes"),
			"No" = image(icon = 'icons/hud/radials/radial_generic.dmi', icon_state = "radial_no"),
		)
		var/rank_response = show_radial_menu(vampiredatum.owner.current, vassaldatum.owner.current, rank_options, radius = 36, require_near = TRUE)
		if(rank_response == "Yes")
			vampiredatum.spend_rank(vassaldatum.owner.current, cost_rank = FALSE, blood_cost = VAMPIRE_BLOOD_RANKUP_COST)
		return TRUE
	to_chat(vampiredatum.owner.current, span_danger("You don't have any levels or enough Blood to Rank [vassaldatum.owner.current] up with."))
	return TRUE

/datum/vampire_clan/ventrue/on_favorite_vassal(datum/source, datum/antagonist/vassal/vassaldatum, mob/living/vampire)
	to_chat(vampire, span_announce("* Vampire Tip: You can now upgrade your Favorite Vassal by buckling them onto a persuasion rack!"))

#undef VAMPIRE_BLOOD_RANKUP_COST
#undef VENTRUE_MAX_LEVEL
