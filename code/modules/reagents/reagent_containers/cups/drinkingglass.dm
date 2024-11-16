/obj/item/reagent_containers/cup/glass/drinkingglass
	name = "drinking glass"
	desc = "Your standard drinking glass."
	custom_price = 5
	icon_state = "glass_empty"
	amount_per_transfer_from_this = 10
	volume = 50
	custom_materials = list(/datum/material/glass=500)
	max_integrity = 20
	spillable = TRUE
	resistance_flags = ACID_PROOF
	obj_flags = UNIQUE_RENAME
	drop_sound = 'sound/items/handling/drinkglass_drop.ogg'
	pickup_sound =  'sound/items/handling/drinkglass_pickup.ogg'

/obj/item/reagent_containers/cup/glass/drinkingglass/on_reagent_change(changetype)
	cut_overlays()
	if(reagents.reagent_list.len)
		var/datum/reagent/R = reagents.get_master_reagent()
		if(!renamedByPlayer)
			name = R.glass_name
			desc = R.glass_desc
		if(R.glass_icon_state)
			icon_state = R.glass_icon_state
		else
			var/mutable_appearance/reagent_overlay = mutable_appearance(icon, "glassoverlay")
			reagent_overlay.color = mix_color_from_reagents(reagents.reagent_list)
			add_overlay(reagent_overlay)
	else
		icon_state = "glass_empty"
		renamedByPlayer = FALSE //so new drinks can rename the glass

//Shot glasses!//
//  This lets us add shots in here instead of lumping them in with drinks because >logic  //
//  The format for shots is the exact same as iconstates for the drinking glass, except you use a shot glass instead.  //
//  If it's a new drink, remember to add it to Chemistry-Reagents.dm  and Chemistry-Recipes.dm as well.  //
//  You can only mix the ported-over drinks in shot glasses for now (they'll mix in a shaker, but the sprite won't change for glasses). //
//  This is on a case-by-case basis, and you can even make a separate sprite for shot glasses if you want. //

/obj/item/reagent_containers/cup/glass/drinkingglass/shotglass
	name = "shot glass"
	desc = "A shot glass - the universal symbol for bad decisions."
	custom_price = 5
	icon_state = "shotglass"
	gulp_size = 15
	amount_per_transfer_from_this = 15
	possible_transfer_amounts = list()
	volume = 15
	custom_materials = list(/datum/material/glass=100)

/obj/item/reagent_containers/cup/glass/drinkingglass/shotglass/on_reagent_change(changetype)
	cut_overlays()

	gulp_size = max(round(reagents.total_volume / 15), 15)

	if (reagents.reagent_list.len > 0)
		var/datum/reagent/largest_reagent = reagents.get_master_reagent()
		name = "filled shot glass"
		desc = "The challenge is not taking as many as you can, but guessing what it is before you pass out."

		if(largest_reagent.shot_glass_icon_state)
			icon_state = largest_reagent.shot_glass_icon_state
		else
			icon_state = "shotglassclear"
			var/mutable_appearance/shot_overlay = mutable_appearance(icon, "shotglassoverlay")
			shot_overlay.color = mix_color_from_reagents(reagents.reagent_list)
			add_overlay(shot_overlay)


	else
		icon_state = "shotglass"
		name = "shot glass"
		desc = "A shot glass - the universal symbol for bad decisions."
		return

/obj/item/reagent_containers/cup/glass/drinkingglass/filled/Initialize(mapload)
	. = ..()
	on_reagent_change(ADD_REAGENT)

/obj/item/reagent_containers/cup/glass/drinkingglass/filled/soda
	name = "Soda Water"
	list_reagents = list(/datum/reagent/consumable/sodawater = 50)
	icon_state_preview = "glass_clear"

/obj/item/reagent_containers/cup/glass/drinkingglass/filled/cola
	name = "Space Cola"
	list_reagents = list(/datum/reagent/consumable/space_cola = 50)
	icon_state_preview = "glass_brown"

/obj/item/reagent_containers/cup/glass/drinkingglass/filled/nuka_cola
	name = "Nuka Cola"
	list_reagents = list(/datum/reagent/consumable/nuka_cola = 50)
	icon_state_preview = "nuka_colaglass"
