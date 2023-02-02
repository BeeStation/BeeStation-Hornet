/client/proc/spawn_liquid()
	set category = "Adminbus"
	set name = "Spawn Liquid"
	set desc = "Spawns an amount of chosen liquid at your current location."

	var/choice
	var/valid_id
	while(!valid_id)
		choice = stripped_input(usr, "Enter the ID of the reagent you want to add.", "Search reagents")
		if(isnull(choice)) //Get me out of here!
			break
		if (!ispath(text2path(choice)))
			choice = pick_closest_path(choice, make_types_fancy(subtypesof(/datum/reagent)))
			if (ispath(choice))
				valid_id = TRUE
		else
			valid_id = TRUE
		if(!valid_id)
			to_chat(usr, span_warning("A reagent with that ID doesn't exist!"))
	if(!choice)
		return
	var/volume = input(usr, "Volume:", "Choose volume") as num
	if(!volume)
		return
	if(volume >= 1000)
		to_chat(usr, span_warning("Please limit the volume to below 1000 units!"))
		return
	var/turf/epicenter = get_turf(mob)
	epicenter.add_liquid(choice, volume)
	message_admins("[ADMIN_LOOKUPFLW(usr)] spawned liquid at [epicenter.loc] ([choice] - [volume]).")
	log_admin("[key_name(usr)] spawned liquid at [epicenter.loc] ([choice] - [volume]).")

/client/proc/remove_liquid()
	set name = "Remove Liquids"
	set category = "Admin"
	set desc = "Fixes air in specified radius."
	var/turf/epicenter = get_turf(mob)

	var/range = input(usr, "Enter range:", "Range selection", 2) as num

	for(var/obj/effect/abstract/liquid_turf/liquid in range(range, epicenter))
		qdel(liquid, TRUE)

	message_admins("[key_name_admin(usr)] removed liquids with range [range] in [epicenter.loc.name]")
	log_game("[key_name_admin(usr)] removed liquids with range [range] in [epicenter.loc.name]")
