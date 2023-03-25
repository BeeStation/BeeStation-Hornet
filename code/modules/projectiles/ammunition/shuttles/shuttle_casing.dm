/obj/item/ammo_casing/flak
	name = "88mm flak casing"
	desc = "An 88mm bullet casing."
	caliber = "shuttle_flak"
	projectile_type = /obj/item/projectile/bullet/shuttle/ballistic/bullet

/obj/item/ammo_casing/chaingun
	name = "chaingun casing"
	desc = "An 88mm bullet casing."
	caliber = "shuttle_chaingun"
	projectile_type = /obj/item/projectile/bullet/shuttle/ballistic/bullet

/obj/item/ammo_casing/chaingun/heavy
	name = "heavy chaingun casing"
	desc = "An armour-peircing 88mm bullet casing."
	caliber = "shuttle_chaingun"
	projectile_type = /obj/item/projectile/bullet/shuttle/ballistic/bullet/heavy

/obj/item/ammo_casing/caseless/shuttle_missile
	name = "\improper Centaur missile"
	desc = "A long-ranged inter-ship missile with an explosive payload."
	caliber = "shuttle_missile"
	icon = 'icons/obj/shuttle_weapons_large.dmi'
	icon_state = "missile_normal"
	projectile_type = /obj/item/projectile/bullet/shuttle/missile/mini
	w_class = WEIGHT_CLASS_HUGE

/obj/item/ammo_casing/caseless/shuttle_missile/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands=TRUE, ignore_attack_self = TRUE)

/obj/item/ammo_casing/caseless/shuttle_missile/breach
	name = "\improper Minotaur breaching missile"
	desc = "A highly explosive missile for loading into shuttle mounted rocket pods. Use in hand to set the penetration distance."
	caliber = "shuttle_missile"
	icon_state = "missile_breach"
	projectile_type = /obj/item/projectile/bullet/shuttle/missile/breach
	var/penetration_distance = 0

/obj/item/ammo_casing/caseless/shuttle_missile/breach/Initialize(mapload)
	. = ..()
	var/obj/item/projectile/bullet/shuttle/missile/breach/missile = BB
	if (istype(missile))
		missile.penetration_range = penetration_distance

/obj/item/ammo_casing/caseless/shuttle_missile/breach/attack_self(mob/user)
	. = ..()
	penetration_distance = tgui_input_number(user, "Enter the penetration distance of the missile (0 to 8).", "Penetration Distance", 0, 8, 0, round_value = TRUE)
	var/obj/item/projectile/bullet/shuttle/missile/breach/missile = BB
	if (istype(missile))
		missile.penetration_range = penetration_distance

/obj/item/ammo_casing/caseless/shuttle_missile/fire
	name = "\improper Prometheus incediary missile"
	desc = "A highly explosive missile for loading into shuttle mounted rocket pods."
	caliber = "shuttle_missile"
	icon_state = "missile_fire"
	projectile_type = /obj/item/projectile/bullet/shuttle/missile/fire

/obj/item/ammo_casing/caseless/shuttle_missile/emp
	name = "\improper Icarus electromagnetic disruption missile"
	desc = "A highly advanced missile that emits an electromagnetic pulse upon impact. Can be loaded into shuttle rocket pods."
	caliber = "shuttle_missile"
	icon_state = "missile_emp"
	projectile_type = /obj/item/projectile/bullet/shuttle/missile/emp

