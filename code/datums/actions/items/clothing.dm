/datum/action/item_action/toggle_helmet_flashlight
	name = "Toggle Helmet Flashlight"

/datum/action/item_action/toggle_helmet_mode
	name = "Toggle Helmet Mode"

/datum/action/item_action/toggle_beacon
	name = "Toggle Hardsuit Locator Beacon"
	button_icon = 'icons/hud/actions/action_generic.dmi'
	button_icon_state = "toggle-transmission"

/datum/action/item_action/toggle_beacon_hud
	name = "Toggle Hardsuit Locator HUD"
	button_icon = 'icons/hud/actions/action_generic.dmi'
	button_icon_state = "toggle-hud"

/datum/action/item_action/toggle_beacon_hud/explorer
	button_icon_state = "toggle-hud-explo"

/datum/action/item_action/toggle_beacon_frequency
	name = "Toggle Hardsuit Locator Frequency"
	button_icon = 'icons/hud/actions/action_generic.dmi'
	button_icon_state = "change-code"

/datum/action/item_action/toggle_research_scanner
	name = "Toggle Research Scanner"
	button_icon = 'icons/hud/actions/actions_items.dmi'
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
	button_icon = 'icons/hud/actions/actions_items.dmi'
	button_icon_state = "jetboot"

/datum/action/item_action/kindleKicks
	name = "Activate Kindle Kicks"
	desc = "Kick you feet together, activating the lights in your Kindle Kicks."
	button_icon = 'icons/hud/actions/actions_items.dmi'
	button_icon_state = "kindleKicks"

/datum/action/item_action/toggle_headphones
	name = "Open Music Menu"
	desc = "UNTZ UNTZ UNTZ"

/datum/action/item_action/toggle_headphones/on_activate(mob/user, atom/target)
	var/obj/item/clothing/ears/headphones/H = target
	if(istype(H))
		H.interact(owner)

//aurafarming
/datum/action/item_action/noirmode
	name = "Noir Ambience"
	desc = "Set up the mood for an interrogation."
	button_icon = 'icons/hud/actions/actions_items.dmi'
	button_icon_state = "noir_mode"
	cooldown_time = 30 SECONDS

/datum/action/item_action/noirmode/on_activate(mob/user, atom/target)
	var/area/A = get_area(user)
	if(istype(A, /area/security/detectives_office) || istype(A, /area/security/interrogation_room))
		var/list/mobs_to_iterate = mobs_in_area_type(list(A))
		for(var/mob/living/L as() in mobs_to_iterate)
			ADD_TRAIT(L, TRAIT_NOIR, TRAIT_GENERIC)
			L.add_client_colour(/datum/client_colour/monochrome)
			if(L == user)
				to_chat(L, span_notice("The shadows overtake the room. They are in your realm now."))
			else
				to_chat(L, span_userdanger("The shadows overtake the room. An ominous feeling falls over you."))
		start_cooldown()
	else
		to_chat(user, "<span class='warning'>You can only use the noir ability in the detective's office or interrogation room.</span>")
