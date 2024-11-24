
#define HINT_ICON_FILE 'icons/ui_icons/screentips/cursor_hints.dmi'
#define HINT_TOOL_ICON_FILE 'icons/ui_icons/screentips/tool_hints.dmi'

/// Stores the cursor hint icons for screentip context.
GLOBAL_LIST_INIT_TYPED(screentip_context_icons, /image, prepare_screentip_context_icons())

// These invisible tokens are added to fix a byond rendering bug where icons don't properly position themselves if they are the first thing on a new line
GLOBAL_VAR_INIT(lmb_icon, "<span style='font-size: 1px'>.</span>\icon[GLOB.screentip_context_icons["LMB"]]")
GLOBAL_VAR_INIT(rmb_icon, "<span style='font-size: 1px'>.</span>\icon[GLOB.screentip_context_icons["RMB"]]")
GLOBAL_VAR_INIT(hint_screwdriver, "<span style='font-size: 1px'>.</span>\icon[GLOB.screentip_context_icons["screwdriver"]]")
GLOBAL_VAR_INIT(hint_wrench, "<span style='font-size: 1px'>.</span>\icon[GLOB.screentip_context_icons["wrench"]]")
GLOBAL_VAR_INIT(hint_crowbar, "<span style='font-size: 1px'>.</span>\icon[GLOB.screentip_context_icons["crowbar"]]")
GLOBAL_VAR_INIT(hint_wirecutters, "<span style='font-size: 1px'>.</span>\icon[GLOB.screentip_context_icons["wirecutters"]]")
GLOBAL_VAR_INIT(hint_welder, "<span style='font-size: 1px'>.</span>\icon[GLOB.screentip_context_icons["welder"]]")
GLOBAL_VAR_INIT(hint_multitool, "<span style='font-size: 1px'>.</span>\icon[GLOB.screentip_context_icons["multitool"]]")
GLOBAL_VAR_INIT(hint_knife, "<span style='font-size: 1px'>.</span>\icon[GLOB.screentip_context_icons["knife"]]")
GLOBAL_VAR_INIT(hint_rolling_pin, "<span style='font-size: 1px'>.</span>\icon[GLOB.screentip_context_icons["rolling_pin"]]")

/proc/prepare_screentip_context_icons()
	var/list/output = list()
	for(var/state in icon_states(HINT_ICON_FILE))
		output[state] = image(HINT_ICON_FILE, icon_state = state)
	for(var/state in icon_states(HINT_TOOL_ICON_FILE))
		output[state] = image(HINT_TOOL_ICON_FILE, icon_state = state)
	return output

#define SCREEN_TIP_ALLOWED "#a9f59d"
#define SCREEN_TIP_REJECTED "#e39191"
#define SCREEN_TIP_NORMAL "#daf3f2"
#define SCREEN_TIP_INACCESSIBLE "#a1b6b5"

// ============================
// Auto-tips: Developer QOL
// ============================

GLOBAL_LIST_INIT(screentips_cache, init_autotips())

#define SCREENTIP_ATTACK_HAND(type, message) /datum/screentip_cache##type/attack_hand = "\n" + "<span class='maptext'><span style='line-height: 0.35; color:" + SCREEN_TIP_NORMAL + "'><center>%LMB% " + message + "</center></span></span>"

/proc/init_autotips()
	. = list()
	for (var/datum/screentip_cache/type as anything in subtypesof(/datum/screentip_cache))
		// Parent type, not a real type
		if (!initial(type.attack_hand))
			continue
		var/path = text2path(copytext("[type]", 23))
		var/datum/screentip_cache/cache = new type
		cache.attack_hand = replacetext(cache.attack_hand, "%LMB%", GLOB.lmb_icon)
		.["[path]"] = cache
		for (var/subtype in subtypesof(path))
			if (!.["[subtype]"])
				.["[subtype]"] = cache
