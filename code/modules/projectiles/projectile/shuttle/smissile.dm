/obj/item/projectile/bullet/shuttle/missile
	name = "missile"
	desc = "You should probably move rather than stare at this."
	damage = 0
	armour_penetration = 100
	dismemberment = 0
	ricochets_max = 0
	icon = 'icons/obj/shuttle_32x64.dmi'
	icon_state = "fmissile_normal"
	var/has_impacted = FALSE
	var/penetration_range = 0
	var/devastation = -1
	var/heavy = -1
	var/light_r = -1
	var/flash = -1
	var/fire = -1

/obj/item/projectile/bullet/shuttle/missile/on_hit(atom/target, blocked = FALSE)
	if(get_turf(target) != original && istype(target, /obj/structure/emergency_shield))
		explosion(target, devastation, heavy, light_r, flash, 0, flame_range = fire)
		return BULLET_ACT_HIT
	if (penetration_range > 0)
		has_impacted = TRUE
		return BULLET_ACT_FORCE_PIERCE
	explosion(target, devastation, heavy, light_r, flash, 0, flame_range = fire)
	return BULLET_ACT_HIT

/obj/item/projectile/bullet/shuttle/missile/Range()
	. = ..()
	if (has_impacted)
		penetration_range --

/obj/item/projectile/bullet/shuttle/missile/breach
	name = "breaching missile"
	desc = "Putting holes in your hulls since 2042."
	icon_state = "fmissile_breach"
	devastation = 1
	heavy = 4
	light_r = 5
	flash = 5
	fire = 1

/obj/item/projectile/bullet/shuttle/missile/fire
	name = "incediary missile"
	desc = "An anti-personnel weapon, for roasting your enemies harder than any diss-track ever could."
	icon_state = "fmissile_fire"
	light_r = 2
	flash = 8
	fire = 5

/obj/item/projectile/bullet/shuttle/missile/mini
	name = "missile"
	desc = "A missile with a small payload."
	heavy = 2
	light_r = 4
	flash = 4
	fire = 2

/obj/item/projectile/bullet/shuttle/missile/mini/examine(mob/user)
	. = ..()
	if (in_range(src, user))
		. += "It has a label on it that reads <b>'Caution: This missile is extremely underwhelming.'</b>"
	else
		. += "It has a small label on the side, but you are too far away to read it."

/obj/item/projectile/bullet/shuttle/missile/emp
	name = "emp missile"
	desc = "An missile with an electromagnetic pulse payload."
	icon_state = "fmissile_emp"

/obj/item/projectile/bullet/shuttle/missile/emp/on_hit(atom/target, blocked = FALSE)
	// Pretty big EMP
	empulse(src, 5, 8)
	return BULLET_ACT_HIT
