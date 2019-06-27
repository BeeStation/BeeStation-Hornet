/obj/item/reagent_containers/pill/blotter
	name = "Blotter"
	desc = "Paper soaked in a reagent you can take by ingestion. Use a pen to rename or change its design."
	icon_state = "blotter-default"
	volume = 50
	var/list/alternate_sprites = list(
		"Blank" = "default",
		"Clown" = "clown",
		"Happy" = "smile",
		"Syndie" = "syndicate",
		"Coins" = "coin"
	)

/obj/item/reagent_containers/pill/blotter/attackby(obj/item/I, mob/living/User)
	if(istype(I, /obj/item/pen))
		var/obj/item/pen/P = I
		var/choice = alert(User, "Rename or Redesign", "", "Rename", "Redesign", "Cancel")
		switch(choice)
			if("Cancel")
			if("Redesign")
				var/new_sprite = input("Pick a design:", null) as null|anything in alternate_sprites
				if(new_sprite)
					var/status = alternate_sprites[new_sprite]
					if(status)
						icon_state = "blotter-[status]"
			if("Rename")
				var/str = stripped_input(User, "New name:", "Rename", "", MAX_NAME_LEN)
				if(str)
					name = str
		return

	else if(istype(I, /obj/item/reagent_containers))
		var/obj/item/reagent_containers/R = I
		if(!I.spillable)
			return
		I.reagents.trans_to(src, I.amount_per_transfer_from_this)
		color = mix_color_from_reagents(reagents.reagent_list)
		return


/obj/item/reagent_containers/pill/blotter/proc/generate_name()
	if(reagents.total_volume)
		var/datum/reagent/R = max(reagents.reagent_list)
		name = "Blotter - [R.name] ([reagents.total_volume]u)"