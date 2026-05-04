/obj/item/gun/energy/taser
	name = "taser gun"
	desc = "A low-capacity, energy-based stun gun used by security teams to subdue targets at range."
	icon_state = "taser"
	inhand_icon_state = null	//so the human update icon uses the icon_state instead.
	ammo_type = list(/obj/item/ammo_casing/energy/electrode)
	ammo_x_offset = 3

/obj/item/gun/energy/tesla_revolver
	name = "tesla gun"
	desc = "An experimental gun based on an experimental engine, it's about as likely to kill its operator as it is the target."
	icon_state = "tesla"
	inhand_icon_state = "tesla"
	ammo_type = list(/obj/item/ammo_casing/energy/tesla_revolver)
	pin = null
	shaded_charge = TRUE
	fire_rate = 1.5

/obj/item/gun/energy/tesla_revolver/add_seclight_point()
	return

/obj/item/gun/energy/e_gun/advtaser
	name = "hybrid taser"
	desc = "A dual-mode taser designed to fire both short-range high-power electrodes and long-range disabler beams."
	icon_state = "advtaser"
	ammo_type = list(/obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/disabler)
	ammo_x_offset = 2
	custom_price = 200



/obj/item/gun/energy/e_gun/advtaser/heirloom
	name = "old hybrid taser"
	desc = "A old and dusty taser, used so much its cell no longer charges. there is a text scribbled on the side saying \"Dont forget your origins.\""
	w_class = WEIGHT_CLASS_NORMAL
	can_charge = FALSE
	dead_cell = TRUE
	ammo_type = list(/obj/item/ammo_casing/energy/electrode/broken) //Fool, you think you can outsmart me. But i am smarter.

/obj/item/gun/energy/disabler
	name = "disabler"
	desc = "A self-defense weapon that exhausts organic targets, weakening them until they collapse."
	icon_state = "disabler"
	inhand_icon_state = null
	ammo_type = list(/obj/item/ammo_casing/energy/disabler)
	ammo_x_offset = 2

/obj/item/gun/energy/disabler/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 15, \
		overlay_y = 10)

/obj/item/gun/energy/disabler/cyborg
	name = "cyborg disabler"
	desc = "An integrated disabler that draws from a cyborg's power cell. This weapon contains a limiter to prevent the cyborg's power cell from overheating."
	ammo_type = list(/obj/item/ammo_casing/energy/disabler/cyborg)
	gun_charge = 10000 WATT	//10 shot capacity
	fire_rate = 2		//2 shots per second
	charge_delay = 3 	//20 shots per minute
						//100 shots total out of a normal power cell, not factoring other drains. Up to 400 shots from a bluespace cell
	can_charge = FALSE
	use_cyborg_cell = TRUE
	requires_wielding = FALSE

/obj/item/gun/energy/pulse/carbine/cyborg
	name = "cyborg pulse carbine"
	desc = "An integrated pulse rifle"
	can_charge = FALSE
	use_cyborg_cell = TRUE
	requires_wielding = FALSE
