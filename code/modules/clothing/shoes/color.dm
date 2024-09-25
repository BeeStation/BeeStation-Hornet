/obj/item/clothing/shoes/sneakers
	icon_state = "sneakers"
	greyscale_colors = "#545454#ffffff"
	custom_price = 20 // For all sneakers
	greyscale_config = /datum/greyscale_config/sneakers
	greyscale_config_worn = /datum/greyscale_config/sneakers_worn

/obj/item/clothing/shoes/sneakers/black
	name = "black shoes"
	desc = "A pair of black shoes."
	greyscale_colors = "#545454#ffffff"

	cold_protection = FEET
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT
	heat_protection = FEET
	max_heat_protection_temperature = SHOES_MAX_TEMP_PROTECT

/obj/item/clothing/shoes/sneakers/brown
	name = "brown shoes"
	desc = "A pair of brown shoes."
	greyscale_colors = "#814112#ffffff"

/obj/item/clothing/shoes/sneakers/blue
	name = "blue shoes"
	greyscale_colors = "#16a9eb#ffffff"

/obj/item/clothing/shoes/sneakers/green
	name = "green shoes"
	greyscale_colors = "#54eb16#ffffff"

/obj/item/clothing/shoes/sneakers/yellow
	name = "yellow shoes"
	greyscale_colors = "#ebe216#ffffff"

/obj/item/clothing/shoes/sneakers/purple
	name = "purple shoes"
	greyscale_colors = "#ad16eb#ffffff"

/obj/item/clothing/shoes/sneakers/red
	name = "red shoes"
	desc = "Stylish red shoes."
	greyscale_colors = "#ff2626#ffffff"

/obj/item/clothing/shoes/sneakers/white
	name = "white shoes"
	greyscale_colors = "#ffffff#ffffff"
	permeability_coefficient = 0.01

/obj/item/clothing/shoes/sneakers/rainbow
	name = "rainbow shoes"
	desc = "Very gay shoes."
	icon_state = "rain_bow"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/obj/item/clothing/shoes/sneakers/orange
	name = "orange shoes"
	greyscale_colors = "#eb7016#ffffff"
	greyscale_config = /datum/greyscale_config/sneakers_orange
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
		src.icon_state = "sneakers_chained"
	return

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
