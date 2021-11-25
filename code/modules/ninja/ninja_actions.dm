/datum/action/cooldown/ninja
	name = "This shouldn't appear, yell at coders"
	check_flags = AB_CHECK_CONSCIOUS
	cooldown_time = 5 SECONDS
	var/obj/item/clothing/suit/space/space_ninja/suit
	var/power_cost = 50

/datum/action/cooldown/ninja/New()
	. = ..()
	if(!istype(target, /obj/item/clothing/suit/space/space_ninja))
		return
	suit = target

/datum/action/cooldown/ninja/Trigger()
	if(!..())
		return FALSE
	if(!suit.s_initialized)
		to_chat(owner, "<span class='warning'><b>ERROR</b>: suit offline. Please activate suit.</span>")
		return FALSE
	if(power_cost > suit.cell?.charge)
		to_chat(owner, "<span class='warning'><b>ERROR</b>: not enough power left.")
		return FALSE
	suit.cell.charge -= power_cost
	return TRUE

/datum/action/cooldown/ninja/initialize_ninja_suit
	name = "Toggle ninja suit"
	cooldown_time = 0
	power_cost = 0

/datum/action/cooldown/ninja/initialize_ninja_suit/Trigger()
	if(!..())
		return FALSE
	suit.toggle_on_off()
	return TRUE

/datum/action/cooldown/ninja/ninja_smoke
	name = "Smoke Bomb"
	desc = "Blind your enemies momentarily with a well-placed smoke bomb."
	button_icon_state = "smoke"
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	cooldown_time = 30 SECONDS
	power_cost = 300

/datum/action/cooldown/ninja/ninja_smoke/Trigger()
	if(!..())
		return FALSE
	suit.ninja_smoke()
	return TRUE

/datum/action/cooldown/ninja/ninja_boost
	check_flags = NONE
	name = "Adrenaline Boost"
	desc = "Inject a secret chemical that will counteract all movement-impairing effect."
	button_icon_state = "repulse"
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	cooldown_time = 1 MINUTES
	power_cost = 600

/datum/action/cooldown/ninja/ninja_boost/Trigger()
	if(!..())
		return FALSE
	suit.ninja_boost()
	return TRUE

/datum/action/cooldown/ninja/ninja_pulse
	name = "EM Burst (25E)"
	desc = "Disable any nearby technology with an electro-magnetic pulse."
	button_icon_state = "emp"
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	cooldown_time = 1 MINUTES
	power_cost = 250

/datum/action/cooldown/ninja/ninja_pulse/Trigger()
	if(!..())
		return FALSE
	suit.ninja_pulse()
	return TRUE

/datum/action/cooldown/ninja/ninja_star
	name = "Create Throwing Stars"
	desc = "Creates some throwing stars"
	button_icon_state = "throwingstar"
	icon_icon = 'icons/obj/items_and_weapons.dmi'
	cooldown_time = 3 SECONDS
	power_cost = 50

/datum/action/cooldown/ninja/ninja_star/Trigger()
	if(!..())
		return FALSE
	suit.ninja_star()
	return TRUE

/datum/action/cooldown/ninja/ninja_net
	name = "Energy Net"
	desc = "Captures a fallen opponent in a net of energy. Will teleport them to a holding facility after 30 seconds."
	button_icon_state = "energynet"
	icon_icon = 'icons/effects/effects.dmi'
	cooldown_time = 1 MINUTES
	power_cost = 600

/datum/action/cooldown/ninja/ninja_net/Trigger()
	if(!..())
		return FALSE
	suit.ninja_net()
	return TRUE

/datum/action/cooldown/ninja/ninja_sword_recall
	name = "Recall Energy Katana (Variable Cost)"
	desc = "Teleports the Energy Katana linked to this suit to its wearer, cost based on distance."
	button_icon_state = "energy_katana"
	icon_icon = 'icons/obj/items_and_weapons.dmi'
	cooldown_time = 30 SECONDS
	power_cost = 150

/datum/action/cooldown/ninja/ninja_sword_recall/Trigger()
	if(!..())
		return FALSE
	suit.ninja_sword_recall()
	return TRUE

/datum/action/cooldown/ninja/ninja_stealth
	name = "Toggle Stealth"
	desc = "Toggles stealth mode on and off."
	button_icon_state = "ninja_cloak"
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	cooldown_time = 5 SECONDS
	power_cost = 0		//the cost is calculated by the suit itself here

/datum/action/cooldown/ninja/ninja_stealth/Trigger()
	if(!..())
		return FALSE
	suit.stealth()
	return TRUE

/datum/action/cooldown/ninja/toggle_glove
	name = "Toggle interaction"
	desc = "Switch between normal interaction and drain mode."
	button_icon_state = "s-ninjan"
	icon_icon = 'icons/obj/clothing/gloves.dmi'
	cooldown_time = 3 SECONDS
	power_cost = 0

/datum/action/cooldown/ninja/toggle_glove/Trigger()
	if(!..())
		return FALSE
	var/obj/item/clothing/gloves/space_ninja/G = suit.n_gloves
	if(!istype(G))
		return FALSE

	G.toggle_drain()
	return TRUE
