///The maximum level a Ventrue Vampire can be, before they have to level up their vassal instead.
#define VENTRUE_MAX_LEVEL 3
///How much it costs for a Ventrue to rank up without a spare rank to spend.
#define VAMPIRE_BLOOD_RANKUP_COST (550)

/datum/vampire_clan/ventrue
	name = CLAN_VENTRUE
	description = "The Ventrue Clan is extremely snobby with their meals, and refuse to drink blood from people without a mind. \n\
		You may only level yourself up to Level %MAX_LEVEL%, anything further will be ranks to spend on their Favorite Vassal through a Persuasion Rack. \n\
		The Favorite Vassal will slowly turn more Vampiric this way, until they finally lose their last bits of Humanity."
	clan_objective = /datum/objective/vampire/embrace
	join_icon_state = "ventrue"
	join_description = "Lose the ability to drink from mindless mobs, can't level up or gain new powers, \
		instead you raise a vassal into a Vampire."
	blood_drink_type = VAMPIRE_DRINK_SNOBBY

/datum/vampire_clan/ventrue/New(datum/antagonist/vampire/owner_datum)
	. = ..()
	description = replacetext(description, "%MAX_LEVEL%", VENTRUE_MAX_LEVEL)

/datum/vampire_clan/ventrue/spend_rank(datum/antagonist/vampire/source, mob/living/carbon/target, cost_rank = TRUE, blood_cost)
	if(!target)
		if(vampiredatum.vampire_level < VENTRUE_MAX_LEVEL)
			return ..()
		return FALSE
	var/datum/antagonist/vassal/favorite/vassaldatum = IS_FAVORITE_VASSAL(target)
	if(!vassaldatum)
		return FALSE
	// Purchase Power Prompt
	var/list/options = list()
	for(var/datum/action/cooldown/vampire/power as anything in vampiredatum.all_vampire_powers)
		if(initial(power.purchase_flags) & VASSAL_CAN_BUY && !(locate(power) in vassaldatum.powers))
			options[initial(power.name)] = power

	if(options.len < 1)
		to_chat(vampiredatum.owner.current, span_notice("You grow more ancient by the night!"))
	else
		// Give them the UI to purchase a power.
		var/choice = tgui_input_list(vampiredatum.owner.current, "You have the opportunity to level up your Favorite Vassal. Select a power you wish for them to receive.", "Your Blood Thickens...", options)
		// Prevent Vampires from closing/reopning their coffin to spam Levels.
		if(cost_rank && vampiredatum.vampire_level_unspent <= 0)
			return
		// Did you choose a power?
		if(!choice || !options[choice])
			to_chat(vampiredatum.owner.current, span_notice("You prevent your blood from thickening just yet, but you may try again later."))
			return
		// Prevent Vampires from closing/reopning their coffin to spam Levels.
		if((locate(options[choice]) in vassaldatum.powers))
			to_chat(vampiredatum.owner.current, span_notice("You prevent your blood from thickening just yet, but you may try again later."))
			return

		// Good to go - Buy Power!
		var/datum/action/cooldown/vampire/purchased_power = options[choice]
		vassaldatum.BuyPower(new purchased_power)
		vampiredatum.owner.current.balloon_alert(vampiredatum.owner.current, "taught [choice]!")
		to_chat(vampiredatum.owner.current, span_notice("You taught [target] how to use [choice]!"))
		target.balloon_alert(target, "learned [choice]!")
		to_chat(target, span_notice("Your master taught you how to use [choice]!"))

	vassaldatum.vassal_level++
	switch(vassaldatum.vassal_level)
		if(2)
			ADD_TRAIT(vampiredatum.owner.current, TRAIT_MUTE, TRAIT_VAMPIRE)
			ADD_TRAIT(vampiredatum.owner.current, TRAIT_NOBREATH, TRAIT_VAMPIRE)
			ADD_TRAIT(vampiredatum.owner.current, TRAIT_AGEUSIA, TRAIT_VAMPIRE)
			to_chat(target, span_notice("Your blood begins to feel cold, and as a mote of ash lands upon your tongue, you stop breathing..."))
		if(3)
			ADD_TRAIT(vampiredatum.owner.current, TRAIT_NOCRITDAMAGE, TRAIT_VAMPIRE)
			ADD_TRAIT(vampiredatum.owner.current, TRAIT_NOSOFTCRIT, TRAIT_VAMPIRE)
			to_chat(target, span_notice("You feel your Master's blood reinforce you, strengthening you up."))
		if(4)
			ADD_TRAIT(vampiredatum.owner.current, TRAIT_SLEEPIMMUNE, TRAIT_VAMPIRE)
			ADD_TRAIT(vampiredatum.owner.current, TRAIT_VIRUSIMMUNE, TRAIT_VAMPIRE)
			to_chat(target, span_notice("You feel your Master's blood begin to protect you from bacteria."))
			if(ishuman(target))
				var/mob/living/carbon/human/human_target = target
				human_target.skin_tone = "albino"
		if(5)
			ADD_TRAIT(vampiredatum.owner.current, TRAIT_NOHARDCRIT, TRAIT_VAMPIRE)
			to_chat(target, span_notice("You feel yourself able to take cuts and stabbings like it's nothing."))
		if(6 to INFINITY)
			to_chat(target, span_notice("You feel your heart stop pumping for the last time as you begin to thirst for blood, you feel... dead."))
			message_admins("[vassaldatum.owner] has become a Vampire, and was created by [vampiredatum.owner].")
			log_admin("[vampiredatum.owner] has become a Vampire, and was created by [vampiredatum.owner].")
			target.mind.make_vampire()

			SEND_SIGNAL(vampiredatum.owner, COMSIG_ADD_MOOD_EVENT, "vampcandle", /datum/mood_event/vampcandle)

	finalize_spend_rank(vampiredatum, cost_rank, blood_cost)
	vassaldatum.LevelUpPowers()

/datum/vampire_clan/ventrue/interact_with_vassal(datum/antagonist/vampire/source, datum/antagonist/vassal/favorite/vassaldatum)
	. = ..()
	if(.)
		return TRUE
	if(!istype(vassaldatum))
		return FALSE
	if(!vampiredatum.vampire_level_unspent <= 0)
		vampiredatum.SpendRank(vassaldatum.owner.current)
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
			vampiredatum.SpendRank(vassaldatum.owner.current, cost_rank = FALSE, blood_cost = VAMPIRE_BLOOD_RANKUP_COST)
		return TRUE
	to_chat(vampiredatum.owner.current, span_danger("You don't have any levels or enough Blood to Rank [vassaldatum.owner.current] up with."))
	return TRUE

/datum/vampire_clan/ventrue/on_favorite_vassal(datum/source, datum/antagonist/vassal/vassaldatum, mob/living/vampire)
	to_chat(vampire, span_announce("* Vampire Tip: You can now upgrade your Favorite Vassal by buckling them onto a Candelabrum!"))
	vassaldatum.BuyPower(new /datum/action/cooldown/vampire/distress)

#undef VAMPIRE_BLOOD_RANKUP_COST
#undef VENTRUE_MAX_LEVEL
