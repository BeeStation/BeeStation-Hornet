/datum/action/innate/clockcult/insight/clockwork_slab
	name = "Insight - Clockwork Slab"
	desc = "Using a welder and 25 iron, create a clockwork slab which allows you to invoke arcane scriptures, granting you with short term powers."
	button_icon_state = "Replicant"

/datum/action/innate/clockcult/insight/clockwork_slab/Activate()
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
	if(iron_sheets.get_amount() < 25)
		L.balloon_alert(L, "You need 25 iron sheets.")
		return
	if(!iron_sheets.use(25))
		L.balloon_alert(L, "You need 25 iron sheets.")
		return
	// Create the integration cog
	var/obj/item/clockwork/clockwork_slab/created_slab = new (L.loc)
	L.put_in_inactive_hand(created_slab)
