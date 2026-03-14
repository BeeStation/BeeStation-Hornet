/obj/item/gun/energy/pulse
	name = "pulse rifle"
	desc = "A heavy-duty, multifaceted energy rifle with three modes. Preferred by front-line combat personnel."
	icon_state = "pulse"
	inhand_icon_state = null
	worn_icon_state = null
	w_class = WEIGHT_CLASS_BULKY
	force = 10
	modifystate = TRUE
	flags_1 =  CONDUCT_1
	slot_flags = ITEM_SLOT_BACK
	ammo_type = list(/obj/item/ammo_casing/energy/laser/pulse, /obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/laser)
	gun_charge = 400 KILOWATT
	fire_rate = 3
	automatic = 1

/obj/item/gun/energy/pulse/prize
	pin = /obj/item/firing_pin

/obj/item/gun/energy/pulse/prize/Initialize(mapload)
	. = ..()
	SSpoints_of_interest.make_point_of_interest(src)
	var/turf/T = get_turf(src)

	message_admins("A pulse rifle prize has been created at [ADMIN_VERBOSEJMP(T)]")
	log_game("A pulse rifle prize has been created at [AREACOORD(T)]")

	notify_ghosts(
		"Someone won a pulse rifle as a prize!",
		source = src,
		header = "Pulse rifle prize"
	)

/obj/item/gun/energy/pulse/loyalpin
	pin = /obj/item/firing_pin/implant/mindshield

/obj/item/gun/energy/pulse/carbine
	name = "pulse carbine"
	desc = "A compact variant of the pulse rifle with less firepower but easier storage."
	w_class = WEIGHT_CLASS_LARGE
	slot_flags = ITEM_SLOT_BELT
	icon_state = "pulse_carbine"
	worn_icon_state = "gun"
	inhand_icon_state = null
	gun_charge = 50 KILOWATT

/obj/item/gun/energy/pulse/carbine/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 18, \
		overlay_y = 12)

/obj/item/gun/energy/pulse/carbine/loyalpin
	pin = /obj/item/firing_pin/implant/mindshield

/obj/item/gun/energy/pulse/carbine/cyborg
	name = "pulse carbine"
	desc = "A compact, cyborg variant of the commonly used pulse carbine."
	w_class = WEIGHT_CLASS_LARGE
	slot_flags = ITEM_SLOT_BELT
	icon_state = "pulse_carbine"
	inhand_icon_state = null
	gun_charge = 50 KILOWATT

//Handling seclights would be weird/why would borgs need seclights.
/obj/item/gun/energy/pulse/carbine/cyborg/add_seclight_point()
	return


/obj/item/gun/energy/pulse/pistol
	name = "pulse pistol"
	desc = "A pulse rifle in an easily concealed handgun package with low capacity."
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	icon_state = "pulse_pistol"
	worn_icon_state = "gun"
	inhand_icon_state = "gun"
	gun_charge = 20 KILOWATT
	automatic = 0
	fire_rate = 1.5
	weapon_weight = WEAPON_LIGHT

/obj/item/gun/energy/pulse/pistol/loyalpin
	pin = /obj/item/firing_pin/implant/mindshield

/obj/item/gun/energy/pulse/destroyer
	name = "pulse destroyer"
	desc = "A heavy-duty energy rifle built for pure destruction."
	worn_icon_state = "pulse"
	gun_charge = 500 GIGAWATT
	ammo_type = list(/obj/item/ammo_casing/energy/laser/pulse)

/obj/item/gun/energy/pulse/destroyer/loyalpin
	pin = /obj/item/firing_pin/implant/mindshield

/obj/item/gun/energy/pulse/destroyer/attack_self(mob/living/user)
	to_chat(user, span_danger("[src.name] has three settings, and they are all DESTROY."))

/obj/item/gun/energy/pulse/pistol/m1911
	name = "\improper M1911-P"
	desc = "A compact pulse core in a classic handgun frame for Nanotrasen officers. It's not the size of the gun, it's the size of the hole it puts through people."
	icon_state = "m1911"
	inhand_icon_state = "gun"
	gun_charge = 500 GIGAWATT // Something completely absurd (infinite)
