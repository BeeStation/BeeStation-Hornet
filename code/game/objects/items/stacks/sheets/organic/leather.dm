/* Leather Sheet */

/obj/item/stack/sheet/leather
	name = "leather"
	desc = "The by-product of mob grinding."
	singular_name = "leather piece"
	icon_state = "sheet-leather"
	item_state = "sheet-leather"
	icon = 'icons/obj/stacks/organic.dmi'


/obj/item/stack/sheet/leather/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.leather_recipes
	return ..()

/obj/item/stack/sheet/leather/hairlesshide
	name = "hairless hide"
	desc = "This hide was stripped of its hair, but still needs washing and tanning."
	singular_name = "hairless hide piece"
	icon_state = "sheet-hairlesshide"
	item_state = "sheet-hairlesshide"
	icon = 'icons/obj/stacks/organic.dmi'

/obj/item/stack/sheet/leather/wetleather
	name = "wet leather"
	desc = "This leather has been cleaned but still needs to be dried."
	singular_name = "wet leather piece"
	icon_state = "sheet-wetleather"
	item_state = "sheet-wetleather"
	icon = 'icons/obj/stacks/organic.dmi'
	var/wetness = 30 //Reduced when exposed to high temperautres
	var/drying_threshold_temperature = 500 //Kelvin to start drying

//Step two to make leather - washing

/obj/item/stack/sheet/leather/hairlesshide/machine_wash(obj/machinery/washing_machine/WM)
	new /obj/item/stack/sheet/leather/wetleather(drop_location(), amount)
	qdel(src)

//Step three to make leather - drying, either naturally or... in a more induced way.

/obj/item/stack/sheet/leather/wetleather/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature >= drying_threshold_temperature)
		wetness--
		if(wetness == 0)
			new /obj/item/stack/sheet/leather(drop_location(), 1)
			wetness = initial(wetness)
			use(1)

/obj/item/stack/sheet/leather/wetleather/microwave_act(obj/machinery/microwave/MW)
	..()
	new /obj/item/stack/sheet/leather(drop_location(), amount)
	qdel(src)
