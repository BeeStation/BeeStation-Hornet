/obj/item/reagent_containers/pill/blotter
	name = "Blotter"
	desc = "Paper soaked in a reagent you can take by ingestion. Use a pen to rename or change its design."
	icon_state = "blotter-default"
	volume = 50
	var/list/alternate_sprites = list(
		"Blank" = "default",
		"Clown" = "clown",
		"Happy" = "smile",
		"Syndie" = "syndicate"
	)

/obj/item/reagent_containers/pill/blotter/attackby(obj/item/pen/P, mob/living/User)
	var/choice = alert(User, "Rename or Redesign", "", "Rename", "Redesign", "Cancel")
	switch(choice)
		if("Cancel")
			return
		if("Redesign")
			var/new_sprite = input("Pick a design:", null) as null|anything in alternate_sprites
			if(new_sprite)
				var/status = alternate_sprites[new_sprite]
				icon_state = "blotter-[status]"
			return
		if("Rename")
			var/str = stripped_input(User, "New name:", "Rename", "", MAX_NAME_LEN)
			if(str)
				name = str
			return

/obj/item/reagent_containers/pill/blotter/proc/generate_name()
	if(reagents.total_volume)
		var/datum/reagent/R = max(reagents.reagent_list)
		name = "Blotter - [R.name] ([reagents.total_volume]u)"