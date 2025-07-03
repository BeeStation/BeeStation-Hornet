GLOBAL_LIST_INIT_TYPED(holoparasite_themes, /datum/holoparasite_theme, init_holoparasite_themes())

/datum/holoparasite_theme
	/// The name of this holoparasite theme, which will also be the [themed_name] of the holoparasite.
	var/name
	/// A list of messages that are displayed during different events when a holoparasite with this theme is being built.
	/// Use the HOLOPARA_MESSAGE_* defines to specify the event.
	var/list/messages = list()
	/// A list of various variables to be set on the holoparasite when it is built.
	/// Use the HOLOPARA_THEME_* defines to specify the variable.
	var/list/mob_info = list()

/datum/holoparasite_theme/proc/apply(mob/living/simple_animal/hostile/holoparasite/holoparasite)
	SHOULD_CALL_PARENT(TRUE)
	if(holoparasite.name == initial(holoparasite.name))
		holoparasite.name = name
		holoparasite.real_name = name
	holoparasite.icon_state = mob_info[HOLOPARA_THEME_ICON_STATE] || initial(holoparasite.icon_state)
	holoparasite.icon_living = mob_info[HOLOPARA_THEME_ICON_STATE] || initial(holoparasite.icon_living)
	holoparasite.icon_dead = mob_info[HOLOPARA_THEME_ICON_STATE] || initial(holoparasite.icon_dead)
	holoparasite.bubble_icon = mob_info[HOLOPARA_THEME_BUBBLE_ICON] || initial(holoparasite.bubble_icon)
	holoparasite.desc = mob_info[HOLOPARA_THEME_DESC] || initial(holoparasite.desc)
	holoparasite.speak_emote = length(mob_info[HOLOPARA_THEME_SPEAK_EMOTE]) ? mob_info[HOLOPARA_THEME_SPEAK_EMOTE] : list("emanates", "radiates")
	holoparasite.attack_sound = mob_info[HOLOPARA_THEME_ATTACK_SOUND] || initial(holoparasite.attack_sound)
	holoparasite.emissive = isnull(mob_info[HOLOPARA_THEME_EMISSIVE]) ? initial(holoparasite.emissive) : mob_info[HOLOPARA_THEME_EMISSIVE]
	if(holoparasite.emissive)
		holoparasite.set_light_range(0)
		holoparasite.set_light_power(0.1)
	if(length(holoparasite.accent_overlays))
		holoparasite.cut_overlay(holoparasite.accent_overlays)
		QDEL_LIST(holoparasite.accent_overlays)
	var/list/accent_overlays = create_overlays(holoparasite)
	if(accent_overlays && !islist(accent_overlays))
		accent_overlays = list(accent_overlays)
	if(length(accent_overlays))
		holoparasite.add_overlay(accent_overlays)
		holoparasite.accent_overlays = accent_overlays
	if(isnull(mob_info[HOLOPARA_THEME_RECOLOR_SPRITE]) ? initial(holoparasite.recolor_entire_sprite) : mob_info[HOLOPARA_THEME_RECOLOR_SPRITE])
		holoparasite.recolor_entire_sprite = TRUE
		holoparasite.color = holoparasite.accent_color

/datum/holoparasite_theme/proc/create_overlays(mob/living/simple_animal/hostile/holoparasite/holoparasite)
	return

/datum/holoparasite_theme/proc/display_message(mob/living/user, key, mob/living/simple_animal/hostile/holoparasite/holoparasite)
	if(!key || !messages[key] || !istype(user))
		return
	var/message = messages[key]
	if(holoparasite)
		message = replacetext(message, "%NAME%", holoparasite.color_name)
	to_chat(user, span_holoparasite("[message]"), type = MESSAGE_TYPE_INFO)

/proc/init_holoparasite_themes()
	. = list()
	for(var/theme_path in subtypesof(/datum/holoparasite_theme))
		var/datum/holoparasite_theme/theme = new theme_path
		if(!theme.name)
			qdel(theme)
			continue
		.[theme_path] = theme

/proc/get_holoparasite_theme(path_or_instance)
	if(ispath(path_or_instance, /datum/holoparasite_theme))
		return GLOB.holoparasite_themes[path_or_instance]
	else if(istype(path_or_instance, /datum/holoparasite_theme))
		return path_or_instance
	else if(istext(path_or_instance))
		var/theme_name = LOWER_TEXT(trim(path_or_instance))
		var/named_path = text2path(theme_name)
		if(ispath(named_path, /datum/holoparasite_theme))
			return GLOB.holoparasite_themes[named_path]
		for(var/theme_path in GLOB.holoparasite_themes)
			var/datum/holoparasite_theme/theme = GLOB.holoparasite_themes[theme_path]
			if(cmptext(theme_name, theme.name))
				return theme
	else
		CRASH("Invalid value ([path_or_instance]) passed to get_holoparasite_theme: should either be a typepath of /datum/holoparasite_theme, an instance of /datum/holoparasite_theme, a string path of a holoparasite theme, or a string name of a holoparasite theme.")
