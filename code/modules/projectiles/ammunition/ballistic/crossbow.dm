/obj/item/ammo_casing/rebar
	name = "Sharpened Iron Rod"
	desc = "A Sharpened Iron rod. It's Pointy!"
	icon_state = "rod_sharp"
	caliber = "sharpened_rod"
	projectile_type = /obj/projectile/bullet/rebar

/obj/item/ammo_casing/rebar/update_icon_state()
	. = ..()
	icon_state = initial(icon_state)

/obj/item/ammo_casing/rebar/syndie
	name = "Jagged Iron Rod"
	desc = "An Iron rod, with notches cut into it. You really don't want this stuck in you."
	icon_state = "rod_jagged"
	projectile_type = /obj/projectile/bullet/rebar/syndie

/obj/item/ammo_casing/rebar/zaukerite
	name = "Zaukerite Sliver"
	desc = "A sliver of a zaukerite crystal. Due to its irregular, jagged edges, removal of an embedded zaukerite sliver should only be done by trained surgeons."
	icon_state = "rod_zaukerite"
	projectile_type = /obj/projectile/bullet/rebar/zaukerite

/obj/item/ammo_casing/rebar/hydrogen
	name = "Metallic Hydrogen Bolt"
	desc = "An ultra-sharp rod made from pure metallic hydrogen. Armor may as well not exist."
	icon_state = "rod_hydrogen"
	projectile_type = /obj/projectile/bullet/rebar/hydrogen

/obj/item/ammo_casing/rebar/healium
	name = "Healium Crystal Bolt"
	desc = "Who needs a syringe gun, anyway?"
	icon_state = "rod_healium"
	projectile_type = /obj/projectile/bullet/rebar/healium

/obj/item/ammo_casing/rebar/supermatter
	name = "Supermatter Bolt"
	desc = "Wait, how is the bow capable of firing this without dusting?"
	icon_state = "rod_supermatter"
	projectile_type = /obj/projectile/bullet/rebar/supermatter
