
/obj/item/food/honeycomb
	name = "honeycomb"
	desc = "A hexagonal mesh of honeycomb."
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "honeycomb"
	max_volume = 30 //So honeycomb can still be injected with additional things
	foodtypes = SUGAR
	food_reagents = list(/datum/reagent/consumable/honey = 20)
	var/honey_color = ""

/obj/item/food/honeycomb/Initialize(mapload)
	. = ..()
	pixel_x = rand(8,-8)
	pixel_y = rand(8,-8)
	update_icon()

/obj/item/food/honeycomb/update_icon()
	cut_overlays()
	var/mutable_appearance/honey_overlay = mutable_appearance(icon, /datum/reagent/consumable/honey)
	if(honey_color)
		honey_overlay.icon_state = "greyscale_honey"
		honey_overlay.color = honey_color
	add_overlay(honey_overlay)


/obj/item/food/honeycomb/proc/set_reagent(reagent)
	var/datum/reagent/R = GLOB.chemical_reagents_list[reagent]
	if(istype(R))
		name = "honeycomb ([R.name])"
		honey_color = R.color
		reagents.add_reagent(R.type,20)
	else
		honey_color = ""
	update_icon()
