// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

/// Called shortly before the holoparasite manifests: (forced)
#define COMSIG_HOLOPARA_MANIFEST					"holopara_manifest"
	/// Stops the holoparasite from manifesting.
	#define COMPONENT_OVERRIDE_HOLOPARA_MANIFEST	(1 << 0)

/// Called after the holoparasite manifests: (forced)
#define COMSIG_HOLOPARA_POST_MANIFEST				"holopara_post_manifest"

/// Called before the holoparasite recalls: (forced)
#define COMSIG_HOLOPARA_PRE_RECALL					"holopara_pre_recall"

/// Called whenever the holoparasite recalls: (forced)
#define COMSIG_HOLOPARA_RECALL						"holopara_recall"

/// Called before the holoparasite is snapped back to its summoner: ()
#define COMSIG_HOLOPARA_PRE_SNAPBACK				"holopara_pre_snapback"

/// Called when the holoparasite is snapped back to its summoner: (atom/old_loc)
#define COMSIG_HOLOPARA_SNAPBACK					"holopara_snapback"

/// Called whenever the holoparasite is reset: (old_ckey, new_ckey)
#define COMSIG_HOLOPARA_RESET						"holopara_reset"

/// Called whenever the holoparasite's name is set: (old_name, new_name)
#define COMSIG_HOLOPARA_SET_NAME					"holopara_set_name"

/// Called whenever the holoparasite's summoner is set: (old_summoner, new_summoner)
#define COMSIG_HOLOPARA_SET_SUMMONER				"holopara_set_summoner"

/// Called whenever the holoparasite's accent color is set: (old_accent_color, new_accent_color)
#define COMSIG_HOLOPARA_SET_ACCENT_COLOR			"holopara_set_accent_color"

/// Called whenever the holoparasite's theme is set: (old_theme, new_theme)
#define COMSIG_HOLOPARA_SET_THEME					"holopara_set_theme"

/// Called whenever get_stat_tab_status is called on the holoparasite: (list/tab_data)
#define COMSIG_HOLOPARA_STAT						"holopara_stat"

/// Called after a holoparasite's stats are applied: (mob/living/simple_animal/hostile/holoparasite/holopara)
#define COMSIG_HOLOPARA_STATS_APPLY					"holopara_stats_apply"

/// Called after a holoparasite's stats are removed: (mob/living/simple_animal/hostile/holoparasite/holopara)
#define COMSIG_HOLOPARA_STATS_REMOVE				"holopara_stats_remove"

/// Called whenever the holoparasite's major ability is set: (datum/holoparasite_ability/major/old_ability, datum/holoparasite_ability/major/old_ability)
#define COMSIG_HOLOPARA_STATS_SET_MAJOR_ABILITY		"holopara_stats_set_major_ability"

/// Called whenever a minor ability is added to a holoparasite: (datum/holoparasite_ability/lesser/new_ability)
#define COMSIG_HOLOPARA_STATS_ADD_LESSER_ABILITY	"holopara_stats_add_lesser_ability"

/// Called whenever a minor ability is taken from a holoparasite: (datum/holoparasite_ability/lesser/old_ability)
#define COMSIG_HOLOPARA_STATS_TAKE_LESSER_ABILITY	"holopara_stats_take_lesser_ability"

/// Called whenever a holoparasite's weapon is set: (datum/holoparasite_ability/weapon/weapon_ability)
#define COMSIG_HOLOPARA_STATS_SET_WEAPON			"holopara_stats_set_weapon"

#define COMSIG_HOLOPARA_SETUP_HUD					"holopara_setup_hud"

/// Called after the holoparasite's health medhud is updated: (image/holder)
#define COMSIG_HOLOPARA_SET_HUD_HEALTH				"holopara_set_hud_health"

/// Called after the holoparasite's status medhud is updated: (image/holder)
#define COMSIG_HOLOPARA_SET_HUD_STATUS				"holopara_set_hud_status"

#define COMSIG_HOLOPARA_CAN_FIRE_GUN				"holopara_can_fire_gun"
	#define HOLOPARA_CAN_FIRE_GUN					(1 << 0)
