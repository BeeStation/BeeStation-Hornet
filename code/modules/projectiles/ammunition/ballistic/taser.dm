/obj/item/ammo_casing/taser
	name = "Taser cartridge"
	desc = "Standard-issue APS-Arc taser cartridge. Easily repacked with pre-prepared load-assemblies. Some text is stamped into the polymer body: 'ATTENTION: DO NOT LOSE.'"
	icon_state = "taser_cartridge"
	projectile_type = /obj/projectile/energy/electrode
	fire_sound = 'sound/weapons/taser.ogg'
	harmful = FALSE
	caliber = "taser load"
	custom_price = 250

/obj/item/ammo_casing/taser/attackby(obj/item/I, mob/user, params)
	if (istype(I, /obj/item/taser_load) && !BB)
		newshot()
		update_appearance(UPDATE_ICON)
		qdel(I)
		return TRUE
	. = ..()
