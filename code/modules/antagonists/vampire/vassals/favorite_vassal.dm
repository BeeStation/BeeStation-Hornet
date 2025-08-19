/**
 * Favorite Vassal
 *
 * Gets some cool abilities depending on the Clan.
 */
/datum/antagonist/vassal/favorite
	name = "\improper Favorite Vassal"
	show_in_antagpanel = FALSE
	vassal_hud_name = "vassal6"
	special_type = FAVORITE_VASSAL
	vassal_description = "The Favorite Vassal gets unique abilities over other Vassals depending on your Clan \
		and becomes completely immune to Mindshields. If part of Ventrue, this is the Vassal you will rank up."

	///Vampire levels, but for Vassals, used by Ventrue.
	var/vassal_level

/datum/antagonist/vassal/favorite/on_gain()
	. = ..()
	SEND_SIGNAL(master, VAMPIRE_MAKE_FAVORITE, src)

/datum/antagonist/vassal/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current
	set_antag_hud(current_mob, vassal_hud_name)

///Set the Vassal's rank to their Vampire level
/datum/antagonist/vassal/favorite/proc/set_vassal_level(mob/living/carbon/human/target)
	master.vampire_level = vassal_level
