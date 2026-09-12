/proc/machine_upgrade(obj/machinery/M in world)
	set name = "Tweak Component Ratings"
	set category = "Debug"
	if (!istype(M))
		return

	var/new_rating = input("Enter new rating:","Num") as num
	if(new_rating && M.component_parts)
		for(var/datum/stock_part/part in M.component_parts)
			var/datum/stock_part/replacement = part.of_tier(new_rating)
			if(isnull(replacement))
				continue
			M.component_parts -= part
			M.component_parts += replacement
		for(var/obj/item/stock_parts/part in M.component_parts)
			part.rating = new_rating
		M.RefreshParts()

	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Machine Upgrade", "[new_rating]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
