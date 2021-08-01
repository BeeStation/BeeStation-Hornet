/obj/item/clothing/shoes/sneakers
	icon_state = "sneakers"
	greyscale_colors = "#545454#ffffff"
	greyscale_config = /datum/greyscale_config/sneakers
	greyscale_config_worn = /datum/greyscale_config/sneakers_worn

/obj/item/clothing/shoes/sneakers/black
	name = "black shoes"
	item_color = "black"
	desc = "A pair of black shoes."
	custom_price = 20

	cold_protection = FEET
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT
	heat_protection = FEET
	max_heat_protection_temperature = SHOES_MAX_TEMP_PROTECT

/obj/item/clothing/shoes/sneakers/black/redcoat
	item_color = "redcoat"	//Exists for washing machines. Is not different from black shoes in any way.

/obj/item/clothing/shoes/sneakers/brown
	name = "brown shoes"
	desc = "A pair of brown shoes."
	item_color = "brown"
	greyscale_colors = "#814112#ffffff"

/obj/item/clothing/shoes/sneakers/brown/captain
	item_color = "captain"	//Exists for washing machines. Is not different from brown shoes in any way.

/obj/item/clothing/shoes/sneakers/brown/hop
	item_color = "hop"		//Exists for washing machines. Is not different from brown shoes in any way.

/obj/item/clothing/shoes/sneakers/brown/ce
	item_color = "chief"		//Exists for washing machines. Is not different from brown shoes in any way.

/obj/item/clothing/shoes/sneakers/brown/rd
	item_color = "director"	//Exists for washing machines. Is not different from brown shoes in any way.

/obj/item/clothing/shoes/sneakers/brown/cmo
	item_color = "medical"	//Exists for washing machines. Is not different from brown shoes in any way.

/obj/item/clothing/shoes/sneakers/brown/qm
	item_color = "cargo"		//Exists for washing machines. Is not different from brown shoes in any way.

/obj/item/clothing/shoes/sneakers/blue
	name = "blue shoes"
	item_color = "blue"
	greyscale_colors = "#16a9eb#ffffff"

/obj/item/clothing/shoes/sneakers/green
	name = "green shoes"
	item_color = "green"
	greyscale_colors = "#54eb16#ffffff"

/obj/item/clothing/shoes/sneakers/yellow
	name = "yellow shoes"
	item_color = "yellow"
	greyscale_colors = "#ebe216#ffffff"

/obj/item/clothing/shoes/sneakers/purple
	name = "purple shoes"
	item_color = "purple"
	greyscale_colors = "#ad16eb#ffffff"

/obj/item/clothing/shoes/sneakers/red
	name = "red shoes"
	desc = "Stylish red shoes."
	item_color = "red"
	greyscale_colors = "#ff2626#ffffff"

/obj/item/clothing/shoes/sneakers/white
	name = "white shoes"
	greyscale_colors = "#ffffff#ffffff"
	permeability_coefficient = 0.01
	item_color = "white"

/obj/item/clothing/shoes/sneakers/rainbow
	name = "rainbow shoes"
	desc = "Very gay shoes."
	icon_state = "rain_bow"
	item_color = "rainbow"
	greyscale_config = null
	greyscale_colors = null

/obj/item/clothing/shoes/sneakers/orange
	name = "orange shoes"
	item_color = "orange"
	greyscale_config = /datum/greyscale_config/sneakers_orange
	greyscale_colors = "#eb7016#ffffff"
	greyscale_config_worn = /datum/greyscale_config/sneakers_orange_worn

/obj/item/clothing/shoes/sneakers/orange/attack_self(mob/user)
	if (src.chained)
		src.chained = null
		src.slowdown = SHOES_SLOWDOWN
		new /obj/item/restraints/handcuffs( user.loc )
		src.icon_state = ""
	return

/obj/item/clothing/shoes/sneakers/orange/attackby(obj/H, loc, params)
	..()
	// Note: not using istype here because we want to ignore all subtypes
	if (!chained && H.type == /obj/item/restraints/handcuffs)
		qdel(H)
		src.chained = 1
		src.slowdown = 15
		src.icon_state = ""
	
/obj/item/clothing/shoes/sneakers/orange/allow_attack_hand_drop(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/hummie = user
		if(hummie.shoes == src && chained)
			to_chat(hummie, "<span class='warning'>You start taking off your [src]!</span>")
			if(!do_after(hummie,15 SECONDS, src))
				return FALSE
	return ..()

/obj/item/clothing/shoes/sneakers/orange/MouseDrop(atom/over)
	var/mob/m = usr
	if(ishuman(m))
		var/mob/living/carbon/human/hummie = m
		if(hummie.shoes == src && chained)
			to_chat(hummie, "<span class='warning'>You start taking off your [src]!</span>")			
			if(!do_after(hummie,15 SECONDS, src))
				return FALSE
	return ..()
