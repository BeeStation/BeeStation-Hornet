/obj/item/ammo_box/magazine/sniper_rounds
	name = "sniper rounds (.50)"
	icon_state = ".50mag"
	ammo_type = /obj/item/ammo_casing/p50
	max_ammo = 6
	caliber = list(".50")

/obj/item/ammo_box/magazine/sniper_rounds/update_icon()
	..()
	if(ammo_count())
		icon_state = "[initial(icon_state)]-ammo"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/ammo_box/magazine/sniper_rounds/empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/sniper_rounds/soporific
	name = "sniper rounds (Zzzzz)"
	desc = "Soporific sniper rounds, designed for happy days and dead quiet nights..."
	icon_state = "soporific"
	ammo_type = /obj/item/ammo_casing/p50/soporific
	max_ammo = 3

/obj/item/ammo_box/magazine/sniper_rounds/penetrator
	name = "sniper rounds (penetrator)"
	desc = "An extremely powerful round capable of passing straight through cover and anyone unfortunate enough to be behind it."
	ammo_type = /obj/item/ammo_casing/p50/penetrator
	max_ammo = 5

/obj/item/ammo_box/sniper
	name = "ammo box (.50)"
	icon_state = "50cal"
	ammo_type = /obj/item/ammo_casing/p50
	max_ammo = 6
	custom_materials = list(/datum/material/iron = 50000)

/obj/item/ammo_box/sniper/soporific
	name = "ammo box (.50 Soporific)"
	ammo_type = /obj/item/ammo_casing/p50/soporific
	max_ammo = 2
	custom_materials = list(/datum/material/iron = 20000)

/obj/item/ammo_box/sniper/penetrator
	name = "ammo box (.50 Penetrator)"
	ammo_type = /obj/item/ammo_casing/p50/penetrator
	max_ammo = 2
	custom_materials = list(/datum/material/iron = 40000)
