/datum/vampire_clan/tremere
	name = CLAN_TREMERE
	description = "You cannot purchase the standard vampire powers but instead learn Blood Magic, which are upgraded overtime. \n\
		More ranks are gained by Vassalizing crewmembers instead of each Sol.\n\
		The Favorite Vassal gains the ability to morph themselves into a bat at will."
	clan_objective = /datum/objective/vampire/tremere_power
	join_icon_state = "tremere"
	join_description = "You lose all default powers, but gain Blood Magic instead, powers you level up overtime.\n\
		<b>IMPORTANT:</b> Members of the Tremere clan do not gain ranks the usual way but are instead granted ranks per person they vassalize."

/datum/vampire_clan/tremere/New(mob/living/carbon/user)
	. = ..()
	vampiredatum.remove_nondefault_powers(return_levels = TRUE)
	for(var/datum/action/vampire/power as anything in vampiredatum.all_vampire_powers)
		if((initial(power.purchase_flags) & TREMERE_CAN_BUY) && initial(power.level_current) == 1)
			vampiredatum.grant_power(new power)

/datum/vampire_clan/tremere/Destroy(force)
	for(var/datum/action/vampire/power in vampiredatum.powers)
		if(power.purchase_flags & TREMERE_CAN_BUY)
			vampiredatum.remove_power(power)
	return ..()

/datum/vampire_clan/tremere/spend_rank(mob/living/carbon/carbon_vassal)
	// Purchase Power Prompt
	var/list/options = list()
	var/list/radial_display = list()
	for(var/datum/action/vampire/targeted/tremere/power as anything in vampiredatum.powers)
		if(!(power.purchase_flags & TREMERE_CAN_BUY) || isnull(power.upgraded_power))
			continue

		var/datum/action/vampire/targeted/tremere/upgrade = power.upgraded_power
		options[upgrade.name] = power

		var/datum/radial_menu_choice/option = new
		option.name = upgrade.name
		option.image = image(icon = 'icons/vampires/actions_vampire.dmi', icon_state = initial(upgrade.button_icon_state))
		option.info = "[span_boldnotice(upgrade.name)]\n[span_cult(upgrade.power_explanation)]"
		radial_display[upgrade.name] = option

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

		if(!power_response || QDELETED(src) || QDELETED(user) || QDELETED(user))
			return FALSE

		var/datum/action/vampire/purchased_power = options[power_response]
		var/datum/action/vampire/targeted/tremere/tremere_power = purchased_power

		if(isnull(tremere_power.upgraded_power))
			user.balloon_alert(vampiredatum.owner.current, "cannot upgrade [power_response]!")
			to_chat(user, span_notice("[power_response] is already at max level!"))
			return

		vampiredatum.grant_power(new tremere_power.upgraded_power)
		vampiredatum.remove_power(tremere_power)
		user.balloon_alert(user, "upgraded [power_response]!")
		to_chat(user, span_notice("You have upgraded [power_response]!"))

	finalize_spend_rank()

	// QoL
	if(vampiredatum.vampire_level_unspent > 0)
		spend_rank(carbon_vassal)

/datum/vampire_clan/tremere/on_favorite_vassal(datum/antagonist/vassal/favorite/favorite_vassal)
	favorite_vassal.grant_power(new /datum/action/vampire/shapeshift/batform)

/datum/vampire_clan/tremere/on_vassal_made(datum/antagonist/vampire/source, mob/living/user, mob/living/target)
	. = ..()
	to_chat(vampiredatum.owner.current, span_danger("You have now gained an additional Rank to spend!"))
	vampiredatum.vampire_level_unspent += 2

/datum/vampire_clan/tremere/get_max_vassals()
	var/total_players = length(GLOB.joined_player_list)
	switch(total_players)
		if(1 to 20)
			return 3
		if(21 to 30)
			return 5
		if(31 to INFINITY)
			return 7
