/**
 * Favorite Vassal
 *
 * Gets some cool abilities depending on the Clan.
 */
/datum/antagonist/vassal/favorite
	name = "\improper Favorite Vassal"
	show_in_antagpanel = FALSE
	antag_hud_name = "vassal6"
	special_type = FAVORITE_VASSAL
	vassal_description = "The Favorite Vassal gets unique abilities over other Vassals depending on your Clan \
		and becomes completely immune to Mindshields. If part of Ventrue, this is the Vassal you will rank up."

	/// Vampire levels, but for Vassals, used by Ventrue.
	var/vassal_level

/datum/antagonist/vassal/favorite/on_gain()
	. = ..()
	master.my_clan?.on_favorite_vassal(src)
