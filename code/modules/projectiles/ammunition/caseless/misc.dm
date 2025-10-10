/obj/item/ammo_casing/caseless/laser
	name = "laser casing"
	desc = "You shouldn't be seeing this."
	caliber = "laser"
	icon_state = "s-casing-live"
	projectile_type = /obj/projectile/beam
	fire_sound = 'sound/weapons/laser.ogg'
	firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect/energy
	trade_flags = TRADE_NOT_SELLABLE | TRADE_DELETE_UNSOLD

/obj/item/ammo_casing/caseless/laser/bounce_away(still_warm, bounce_delay)
	qdel(src)

/obj/item/ammo_casing/caseless/laser/gatling
	projectile_type = /obj/projectile/beam/weak/penetrator
	variance = 0.8
	click_cooldown_override = 1

/obj/item/ammo_casing/caseless/laser/lesslethal
	projectile_type = /obj/projectile/beam/laser/lesslethal
