/**
 * Favorite ghoul
 *
 * Gets some cool abilities depending on the Clan.
 */
/datum/antagonist/ghoul/favorite
	name = "\improper Favorite ghoul"
	show_in_antagpanel = FALSE
	ghoul_hud_name = "ghoul6"
	special_type = FAVORITE_ghoul
	ghoul_description = "The Favorite ghoul gets unique abilities over other ghouls depending on your Clan \
		and becomes completely immune to Mindshields. If part of Ventrue, this is the ghoul you will rank up."

	/// Vampire levels, but for ghouls, used by Ventrue.
	var/ghoul_level

/datum/antagonist/ghoul/favorite/on_gain()
	. = ..()
	master.my_clan?.on_favorite_ghoul(src)

/datum/antagonist/ghoul/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current
	set_antag_hud(current_mob, ghoul_hud_name)
