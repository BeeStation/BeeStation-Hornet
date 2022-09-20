/datum/action/innate/clockcult/insight/integration_cog
	name = "Insight - Integration cog"
	desc = "Using a welder and 5 iron, create an integration cog which will transimt power to an unknown location when inserted into an APC."
	button_icon_state = "Integration Cog"

/datum/action/innate/clockcult/insight/integration_cog/Activate()
	var/mob/living/L = owner
	var/obj/item/held_item = L.get_active_held_item()
	//Locate a welder
	if (!held_item || held_item.tool_behaviour != TOOL_WELDER)
		L.balloon_alert(L, "You need to hold a welder in order to do this.")
		return
	if (!held_item.use(5))
		L.balloon_alert(L, "The welder doesn't have enough fuel.")
		return
	//Locate iron
	var/obj/item/stack/sheet/iron/iron_sheets = locate(/obj/item/stack/sheet/iron) in L.get_inactive_held_item()
	if(!iron_sheets)
		iron_sheets = locate(/obj/item/stack/sheet/iron) in get_turf(L)
	// Check
	if(iron_sheets.get_amount() < 5)
		L.balloon_alert(L, "You need 5 iron sheets.")
		return
	if(!iron_sheets.use(5))
		L.balloon_alert(L, "You need 5 iron sheets.")
		return
	// Create the integration cog
	var/obj/item/clockwork/integration_cog/created_cog = new (L.loc)
	L.put_in_inactive_hand(created_cog)
