//AYY LTD
/obj/item/clothing/head/helmet/space/hardsuit/bee
	name = "/improper BRT Hardsuit Helmet"
	desc = "You feel faintly buzzed, and it isn't the omega weed..."
	icon = 'code/modules/opo/spankmeqwerty.dmi'
	icon_state = "bteamhelmet"
	item_state = "bteamhelmet"
	item_color = "bee"
	armor = list("melee" = 35, "bullet" = 15, "laser" = 30,"energy" = 10, "bomb" = 10, "bio" = 100, "rad" = 50, "fire" = 75, "acid" = 75)


/obj/item/clothing/suit/space/hardsuit/bee
	name = "/improper BRT Hardsuit"
	desc = "You feel faintly buzzed, and it isn't the omega weed..."
	icon = 'code/modules/opo/spankmeqwerty.dmi'
	item_state = "bteamhardsuit"
	icon_state = "bteamhardsuit"
	armor = list("melee" = 35, "bullet" = 15, "laser" = 30, "energy" = 10, "bomb" = 10, "bio" = 100, "rad" = 50, "fire" = 75, "acid" = 75)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/bee

/obj/item/gun/energy/kinetic_accelerator/ayymosin
	name = "/improper AYY Surplus Rifle"
	desc = "A less civilized weapon, for a less civilized time."
	icon = 'code/modules/opo/spankmeqwerty.dmi'
	icon_state = "alienmosin_full"
	item_state = "alienmosin_empty"
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(/datum/material/iron=2000)
	suppressed = TRUE
	ammo_type = list(/obj/item/projectile/energy/ayymosin)
	weapon_weight = WEAPON_LIGHT
	obj_flags = 0
	overheat_time = 20
	holds_charge = TRUE
	unique_frequency = TRUE
	can_flashlight = FALSE
	max_mod_capacity = 0

/obj/item/projectile/energy/ayymosin
	name = "condensed cosmoline"
	damage = 40
