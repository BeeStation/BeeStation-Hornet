

// contains all of the ninja clothes except the gloves, because they're complex enough to warrant their own file.

/obj/item/clothing/suit/space/space_ninja
	name = "ninja suit"
	desc = "A unique, vacuum-proof suit of nano-enhanced armor designed specifically for Spider Clan assassins."
	icon_state = "s-ninja"
	item_state = "s-ninja_suit"
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals, /obj/item/stock_parts/cell)
	slowdown = 0
	resistance_flags = LAVA_PROOF | ACID_PROOF
	armor = list("melee" = 45, "bullet" = 30, "laser" = 20,"energy" = 10, "bomb" = 30, "bio" = 30, "rad" = 30, "fire" = 100, "acid" = 100)
	strip_delay = 12

/obj/item/clothing/suit/space/space_ninja/might
	name = "M.I.G.H.T. combat ninja suit"
	desc = "A reinforced space ninja suit for spider clan operatives following the path of might."
	icon_state = "s-ninja"
	item_state = "s-ninja_suit"
	armor = list("melee" = 65, "bullet" = 60, "laser" = 40,"energy" = 25, "bomb" = 70, "bio" = 30, "rad" = 30, "fire" = 100, "acid" = 100)

/obj/item/clothing/head/helmet/space/space_ninja
	desc = "What may appear to be a simple black garment is in fact a highly sophisticated nano-weave helmet. Standard issue ninja gear."
	name = "ninja hood"
	icon_state = "s-ninja"
	item_state = "s-ninja_mask"
	armor = list("melee" = 45, "bullet" = 30, "laser" = 20,"energy" = 10, "bomb" = 30, "bio" = 30, "rad" = 30, "fire" = 100, "acid" = 100)
	strip_delay = 12
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	blockTracking = 1//Roughly the only unique thing about this helmet.
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR

/obj/item/clothing/head/helmet/space/space_ninja/might
	desc = "A reinforced space ninja hood for spider clan operatives following the path of might."
	name = "M.I.G.H.T. ninja hood"
	armor = list("melee" = 65, "bullet" = 60, "laser" = 40,"energy" = 25, "bomb" = 70, "bio" = 30, "rad" = 30, "fire" = 100, "acid" = 100)

/obj/item/clothing/shoes/space_ninja
	name = "ninja shoes"
	desc = "A pair of running shoes. Excellent for running and even better for smashing skulls."
	icon_state = "s-ninja"
	item_state = "secshoes"
	permeability_coefficient = 0.01
	clothing_flags = NOSLIP
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	armor = list("melee" = 60, "bullet" = 50, "laser" = 30,"energy" = 15, "bomb" = 30, "bio" = 30, "rad" = 30, "fire" = 100, "acid" = 100)
	strip_delay = 120
	cold_protection = FEET
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT
	heat_protection = FEET
	max_heat_protection_temperature = SHOES_MAX_TEMP_PROTECT

/obj/item/clothing/mask/gas/space_ninja
	name = "ninja mask"
	desc = "A close-fitting mask that acts both as an air filter and a post-modern fashion statement."
	icon_state = "s-ninja"
	item_state = "s-ninja_mask"
	strip_delay = 120
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
