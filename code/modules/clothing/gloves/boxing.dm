/obj/item/clothing/gloves/boxing
	name = "boxing gloves"
	desc = "Because you really needed another excuse to punch your crewmates."
	icon_state = "boxing"
	item_state = "boxing"
	equip_delay_other = 60
	species_exception = list(/datum/species/golem) // now you too can be a golem boxing champion

/obj/item/clothing/gloves/boxing/green
	icon_state = "boxinggreen"
	item_state = "boxinggreen"

/obj/item/clothing/gloves/boxing/blue
	icon_state = "boxingblue"
	item_state = "boxingblue"

/obj/item/clothing/gloves/boxing/yellow
	icon_state = "boxingyellow"
	item_state = "boxingyellow"

/obj/item/clothing/gloves/boxing/yellow/insulated
	name = "budget boxing gloves"
	desc = "Standard boxing gloves coated in a makeshift insulating coat. This can't possibly go wrong at all."
	icon_state = "boxingyellow"
	item_state = "boxingyellow"
	siemens_coefficient = 1	//Set to a default of 1, gets overridden in Initialize()

/obj/item/clothing/gloves/boxing/yellow/insulated/Initialize()
	. = ..()
	siemens_coefficient = pick(0,0,0,0,0.25,2)
