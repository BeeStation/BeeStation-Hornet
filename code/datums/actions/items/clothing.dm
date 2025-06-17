/datum/action/item_action/toggle_helmet_flashlight
	name = "Toggle Helmet Flashlight"

/datum/action/item_action/toggle_helmet_mode
	name = "Toggle Helmet Mode"

/datum/action/item_action/toggle_beacon
	name = "Toggle Hardsuit Locator Beacon"
	icon_icon = 'icons/hud/actions/action_generic.dmi'
	button_icon_state = "toggle-transmission"

/datum/action/item_action/toggle_beacon_hud
	name = "Toggle Hardsuit Locator HUD"
	icon_icon = 'icons/hud/actions/action_generic.dmi'
	button_icon_state = "toggle-hud"

/datum/action/item_action/toggle_beacon_hud/explorer
	button_icon_state = "toggle-hud-explo"

/datum/action/item_action/toggle_beacon_frequency
	name = "Toggle Hardsuit Locator Frequency"
	icon_icon = 'icons/hud/actions/action_generic.dmi'
	button_icon_state = "change-code"

/datum/action/item_action/toggle_research_scanner
	name = "Toggle Research Scanner"
	icon_icon = 'icons/hud/actions/actions_items.dmi'
	button_icon_state = "scan_mode"
	toggleable = TRUE

/datum/action/item_action/toggle_research_scanner/on_activate(mob/user, atom/target)
	owner.research_scanner++
	to_chat(owner, "<span class='notice'>[target] research scanner has been activated.</span>")
	return TRUE

/datum/action/item_action/toggle_research_scanner/on_deactivate(mob/user, atom/target)
	owner.research_scanner--
	to_chat(owner, "<span class='notice'>[target] research scanner has been deactivated.</span>")
	return TRUE

/datum/action/item_action/toggle_research_scanner/Remove(mob/M)
	if(owner && active)
		owner.research_scanner--
		active = FALSE
	..()

//surf_ss13
/datum/action/item_action/bhop
	name = "Activate Jump Boots"
	desc = "Activates the jump boot's internal propulsion system, allowing the user to dash over 4-wide gaps."
	icon_icon = 'icons/hud/actions/actions_items.dmi'
	button_icon_state = "jetboot"

/datum/action/item_action/kindleKicks
	name = "Activate Kindle Kicks"
	desc = "Kick you feet together, activating the lights in your Kindle Kicks."
	icon_icon = 'icons/hud/actions/actions_items.dmi'
	button_icon_state = "kindleKicks"

/datum/action/item_action/toggle_headphones
	name = "Open Music Menu"
	desc = "UNTZ UNTZ UNTZ"

/datum/action/item_action/toggle_headphones/on_activate(mob/user, atom/target)
	var/obj/item/clothing/ears/headphones/H = target
	if(istype(H))
		H.interact(owner)
