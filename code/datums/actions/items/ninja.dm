/datum/action/item_action/initialize_ninja_suit
	name = "Toggle ninja suit"

/datum/action/item_action/ninjaboost
	check_flags = NONE
	name = "Adrenaline Boost"
	desc = "Inject a secret chemical that will counteract all movement-impairing effect."
	button_icon_state = "repulse"
	icon_icon = 'icons/hud/actions/actions_spells.dmi'

/datum/action/item_action/ninjastar
	name = "Create Throwing Stars (10W)"
	desc = "Creates some throwing stars"
	button_icon_state = "throwingstar"
	icon_icon = 'icons/obj/items_and_weapons.dmi'

/datum/action/item_action/ninjastar/is_available()
	if (!..())
		return FALSE
	var/obj/item/clothing/suit/space/space_ninja/ninja = master
	return ninja.cell.charge >= 100

/datum/action/item_action/ninja_sword_recall
	name = "Recall Energy Katana (Variable Cost)"
	desc = "Teleports the Energy Katana linked to this suit to its wearer, cost based on distance."
	button_icon_state = "energy_katana"
	icon_icon = 'icons/obj/items_and_weapons.dmi'

/datum/action/item_action/toggle_glove
	name = "Toggle interaction"
	desc = "Switch between normal interaction and drain mode."
	button_icon_state = "s-ninjan"
	icon_icon = 'icons/obj/clothing/gloves.dmi'
