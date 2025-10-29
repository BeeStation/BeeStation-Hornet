/datum/vampire_clan/tremere
	name = CLAN_TREMERE
	description = "You cannot purchase the standard vampire powers but instead learn Blood Magic, which are upgraded overtime. \n\
		More ranks are gained by ghoulizing crewmembers instead of each Sol.\n\
		The Favorite ghoul gains the ability to morph themselves into a bat at will."
	clan_objective = /datum/objective/vampire/tremere_power
	join_icon_state = "tremere"
	join_description = "You lose all default powers, but gain Blood Magic instead, powers you level up overtime.\n\
		<b>IMPORTANT:</b> Members of the Tremere clan do not gain ranks the usual way but are instead granted ranks per person they ghoulize."

/datum/vampire_clan/tremere/New(mob/living/carbon/user)
	. = ..()
	vampiredatum.remove_nondefault_powers(return_levels = TRUE)

	// TODO: this is where default powers should be given

/datum/vampire_clan/tremere/Destroy(force)
	// TODO: this is where default powers should be given
	return ..()

/datum/vampire_clan/tremere/on_favorite_ghoul(datum/antagonist/ghoul/favorite/favorite_ghoul)
	favorite_ghoul.grant_power(new /datum/action/vampire/shapeshift/batform)



/datum/vampire_clan/tremere/get_max_ghouls()
	var/total_players = length(GLOB.joined_player_list)
	switch(total_players)
		if(1 to 20)
			return 3
		if(21 to 30)
			return 5
		if(31 to INFINITY)
			return 7
