
/obj/item/ammo_box/flak
	name = "ammunition box (flak)"
	icon_state = "45box"
	caliber = "shuttle_flak"
	ammo_type = /obj/item/ammo_casing/flak
	max_ammo = 10
	w_class = WEIGHT_CLASS_HUGE

/obj/item/ammo_box/flak/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands=TRUE)

/obj/item/ammo_box/chaingun
	name = "ammunition box (chaingun)"
	icon = 'icons/obj/shuttle_weapons.dmi'
	icon_state = "box1"
	caliber = "shuttle_chaingun"
	ammo_type = /obj/item/ammo_casing/chaingun
	max_ammo = 40
	w_class = WEIGHT_CLASS_HUGE

/obj/item/ammo_box/chaingun/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands=TRUE)

/obj/item/ammo_box/chaingun/heavy
	name = "ammunition box (chaingun)"
	icon = 'icons/obj/shuttle_weapons.dmi'
	icon_state = "boxb1"
	caliber = "shuttle_chaingun"
	ammo_type = /obj/item/ammo_casing/chaingun/heavy
	max_ammo = 25
