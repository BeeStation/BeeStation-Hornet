/obj/item/clothing/shoes/sneakers
	icon_state = "sneakers"
	greyscale_colors = "#545454#ffffff"
	custom_price = 20 // For all sneakers
	greyscale_config = /datum/greyscale_config/sneakers
	greyscale_config_worn = /datum/greyscale_config/sneakers_worn
	flags_1 = IS_PLAYER_COLORABLE_1

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
	icon_preview = 'icons/obj/previews.dmi'
	icon_state_preview = "shoes_cloth"
	armor_type = /datum/armor/sneakers_white


/datum/armor/sneakers_white
	bio = 95

/obj/item/clothing/shoes/sneakers/rainbow
	name = "rainbow shoes"
	desc = "Very gay shoes."
	icon_state = "rain_bow"

	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/obj/item/clothing/shoes/sneakers/rainbow/denied
	name = "ERROR shoes"
	desc = "What are those?!"
	icon_state = "denied"
	flags_1 = NONE

/obj/item/clothing/shoes/sneakers/orange
	name = "orange shoes"
	icon_preview = 'icons/obj/previews.dmi'
	icon_state_preview = "prisonshoes"
	greyscale_colors = "#eb7016#ffffff"
	greyscale_config = /datum/greyscale_config/sneakers_orange
	greyscale_config_worn = /datum/greyscale_config/sneakers_orange_worn
	flags_1 = NONE

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
			to_chat(hummie, span_warning("You start taking off your [src]!"))
			if(!do_after(hummie,15 SECONDS, src))
				return FALSE
	return ..()

/obj/item/clothing/shoes/sneakers/orange/MouseDrop(atom/over)
	var/mob/m = usr
	if(ishuman(m))
		var/mob/living/carbon/human/hummie = m
		if(hummie.shoes == src && chained)
			to_chat(hummie, span_warning("You start taking off your [src]!"))
			if(!do_after(hummie,15 SECONDS, src))
				return FALSE
	return ..()

/obj/item/clothing/shoes/sneakers/mime
	name = "mime shoes"
	greyscale_colors = "#ffffff#ffffff"

/obj/item/clothing/shoes/sneakers/marisa
	desc = "A pair of magic black shoes."
	name = "magic shoes"
	worn_icon_state = "marisa"
	greyscale_colors = "#545454#ffffff"
	greyscale_config = /datum/greyscale_config/sneakers_marisa
	greyscale_config_worn = null
	strip_delay = 5
	equip_delay_other = 50
	resistance_flags = FIRE_PROOF |  ACID_PROOF
	armor_type = /datum/armor/sneakers_marisa


/datum/armor/sneakers_marisa
	bio = 50
	fire = 70
	acid = 30

/obj/item/clothing/shoes/sneakers/cyborg
	name = "cyborg boots"
	desc = "Shoes for a cyborg costume."
	greyscale_colors = "#4e4e4e#4e4e4e"
