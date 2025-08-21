/datum/holoparasite_theme/tech
	name = "Holoparasite"
	messages = list(
		HOLOPARA_MESSAGE_USE = "You start to power on the injector...",
		HOLOPARA_MESSAGE_USED = "The injector has already been used.",
		HOLOPARA_MESSAGE_FAILED = span_redtext("ERROR") + ". FAILED TO PROJECT WILLPOWER CRYSTALS ONTO HOST. <b>PLEASE TRY AGAIN LATER.</b>",
		HOLOPARA_MESSAGE_SUCCESS = "Willpower crystal projection successful. <b>%NAME% is now online</b>!",
		HOLOPARA_MESSAGE_LING_FAILED = "The crystals violently reverberate at you. They want <b>nothing</b> to do with a creature like you."
	)
	mob_info = list(
		HOLOPARA_THEME_ICON_STATE = "tech:base",
		HOLOPARA_THEME_BUBBLE_ICON = "holo",
		HOLOPARA_THEME_EMISSIVE = TRUE
	)

/datum/holoparasite_theme/tech/create_overlays(mob/living/simple_animal/hostile/holoparasite/holoparasite)
	. = list()
	var/mutable_appearance/accent_overlay = mutable_appearance(initial(holoparasite.icon), "tech:accent")
	accent_overlay.color = holoparasite.accent_color
	accent_overlay.layer = holoparasite.layer + 0.1
	accent_overlay.plane = ABOVE_LIGHTING_PLANE
	. += accent_overlay

	. += emissive_blocker(initial(holoparasite.icon), initial(holoparasite.icon_state), holoparasite.layer)
	. += emissive_appearance(initial(holoparasite.icon), "tech:accent:emissive", holoparasite.layer)
