//AYY LTD

/obj/item/gun/energy/kinetic_accelerator/ayymosin
	name = "/improper AYY Surplus Rifle"
	desc = "A less civilized weapon, for a less civilized time."
	icon = 'code/modules/opo/opo.dmi'
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
