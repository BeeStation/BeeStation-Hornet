/obj/structure/mopbucket
	name = "mop bucket"
	desc = "Fill it with water, but don't forget a mop!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mopbucket"
	density = TRUE
	var/amount_per_transfer_from_this = 5	//shit I dunno, adding this so syringes stop runtime erroring. --NeoFite
	var/list/fill_icon_thresholds = list(1, 30, 50, 70, 90)

/obj/structure/mopbucket/Initialize(mapload)
	. = ..()
	create_reagents(100, OPENCONTAINER)

/obj/structure/mopbucket/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/mop))
		if(reagents.total_volume < 1)
			balloon_alert(user, "Out of water!")
		else
			reagents.trans_to(I, 5, transfered_by = user)
			balloon_alert(user, "Wet \the [I]")
			playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
			update_icon()
	else
		. = ..()
		update_icon()

/obj/structure/mopbucket/on_reagent_change(changetype)
	. = ..()
	update_icon()

/obj/structure/mopbucket/update_overlays()
	. = ..()
	if(reagents.total_volume < 1)
		return
	var/mutable_appearance/filling = mutable_appearance('icons/obj/janitor.dmi', "mopbucket_water[fill_icon_thresholds[1]]")
	var/percent = round((reagents.total_volume / reagents.maximum_volume) * 100)
	for(var/i in 1 to length(fill_icon_thresholds))
		var/threshold = fill_icon_thresholds[i]
		var/threshold_end = (i == length(fill_icon_thresholds)) ? INFINITY : fill_icon_thresholds[i+1]
		if(threshold <= percent && percent < threshold_end)
			filling.icon_state = "mopbucket_water[fill_icon_thresholds[i]]"
		filling.color = mix_color_from_reagents(reagents.reagent_list)
	. += filling
