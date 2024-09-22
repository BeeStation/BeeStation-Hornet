/datum/holoparasite_theme/magic
	name = "Guardian Spirit"
	messages = list(
		HOLOPARA_MESSAGE_USE = "You shuffle the deck...",
		HOLOPARA_MESSAGE_USED = "All the cards seem to be blank now.",
		HOLOPARA_MESSAGE_FAILED = "...And draw a card! It's...blank? <b>Maybe you should try again later.</b>",
		HOLOPARA_MESSAGE_SUCCESS = "... And draw a card! <b>You have summoned %NAME%</b>!",
		HOLOPARA_MESSAGE_LING_FAILED = "<b>The deck refuses to respond to a soulless creature such as you.</b>"
	)
	mob_info = list(
		HOLOPARA_THEME_ICON_STATE = "magic:base",
		HOLOPARA_THEME_BUBBLE_ICON = "guardian",
		HOLOPARA_THEME_EMISSIVE = TRUE
	)

/datum/holoparasite_theme/magic/create_overlays(mob/living/simple_animal/hostile/holoparasite/holoparasite)
	. = list()
	var/mutable_appearance/glow_accent_overlay = mutable_appearance(initial(holoparasite.icon), "magic:accent:glow")
	glow_accent_overlay.color = holoparasite.accent_color
	glow_accent_overlay.layer = holoparasite.layer + 0.1
	glow_accent_overlay.plane = ABOVE_LIGHTING_PLANE
	. += glow_accent_overlay

	var/mutable_appearance/noglow_accent_overlay = mutable_appearance(initial(holoparasite.icon), "magic:accent")
	noglow_accent_overlay.color = holoparasite.accent_color
	noglow_accent_overlay.layer = holoparasite.layer + 0.1
	. += noglow_accent_overlay

	. += emissive_blocker(initial(holoparasite.icon), initial(holoparasite.icon_state), holoparasite.layer)
	. += emissive_appearance(initial(holoparasite.icon), "magic:accent:emissive", holoparasite.layer)
