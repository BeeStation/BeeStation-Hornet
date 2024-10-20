
/obj/item/clothing/shoes/space_ninja
	name = "ninja shoes"
	desc = "A pair of running shoes. Excellent for running and even better for smashing skulls."
	icon_state = "s-ninja"
	item_state = "secshoes"
	clothing_flags = NOSLIP
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	armor_type = /datum/armor/shoes_space_ninja
	strip_delay = 120
	cold_protection = FEET
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT
	heat_protection = FEET
	max_heat_protection_temperature = SHOES_MAX_TEMP_PROTECT


/datum/armor/shoes_space_ninja
	melee = 60
	bullet = 50
	laser = 30
	energy = 15
	bomb = 30
	bio = 100
	rad = 30
	fire = 100
	acid = 100
	stamina = 60
	bleed = 60
