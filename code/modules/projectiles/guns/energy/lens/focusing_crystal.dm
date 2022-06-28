/obj/item/focusing_crystal
	name = "standard focusing crystal"
	desc = "A rare crystal used in the production of energy weapons. The properties of the crystal affect how the energy beam will be formed."
	icon = 'icons/obj/focusing_crystal.dmi'
	icon_state = "focusing_crystal"
	var/colour = "#ffffff"
	var/quality_rating = 1
	var/quality_text

/obj/item/focusing_crystal/Initialize(mapload)
	. = ..()
	//Select a quality rating
	quality_rating = rand(0, 100) * 0.01
	switch(quality_rating)
		if(0 to 0.2)
			quality_text = "terrible"
		if(0.2 to 0.4)
			quality_text = "poor"
		if(0.4 to 0.6)
			quality_text = "average"
		if(0.6 to 0.8)
			quality_text = "good"
		if(0.8 to 1)
			quality_text = "legendary"
	//Colour the crystal
	add_atom_colour(colour, FIXED_COLOUR_PRIORITY)

/obj/item/focusing_crystal/examine(mob/user)
	. = ..()
	. += "It's quality is [quality_text]."
	. += "You can install it into an energy gun that doesn't have a focusing lens installed. Once installed it cannot be removed."

/obj/item/focusing_crystal/attack_obj(obj/O, mob/living/user)
	var/obj/item/gun/G = O
	if(istype(G))
		G.insert_crystal(user, src)
		return
	. = ..()

/obj/item/focusing_crystal/proc/quality_effect(lower_bound, upper_bound)
	return CLAMP(CEILING(quality_rating * (upper_bound - lower_bound), 1) + lower_bound, min(upper_bound, lower_bound), max(upper_bound, lower_bound))

//This is called only once, affects the casings created inside the gun
/obj/item/focusing_crystal/proc/update_casing(obj/item/ammo_casing/fired_casing)
	fired_casing.variance += quality_effect(10, -10)

//This is called every time a new projectile is created
/obj/item/focusing_crystal/proc/update_bullet(obj/item/projectile/projectile)
	return

//==============================
// Splitting Crystal: Shotgun spread
//==============================

/obj/item/focusing_crystal/split
	name = "splitting crystal"
	desc = "A rare crystal used in the production of energy weapons. Rays of light seem to split as they enter the crystal."
	colour = "#eb896c"

/obj/item/focusing_crystal/split/update_casing(obj/item/ammo_casing/fired_casing)
	fired_casing.pellets += quality_effect(1, 5)
	fired_casing.variance += quality_effect(14, 20)
	fired_casing.randomspread = TRUE

/obj/item/focusing_crystal/split/update_bullet(obj/item/projectile/projectile)
	//Increase damage based on quality
	projectile.damage *= quality_effect(0.8, 1.5)
	//Divide damage into lasers evenly
	projectile.damage /= (quality_effect(1, 5) + 1)

//==============================
// Refractive Crystal: Causes projectiles to reflect
//==============================

/obj/item/focusing_crystal/refractive
	name = "refractive crystal"
	desc = "A rare crystal used in the production of energy weapons that refracts light passing through it, making it more likely to bounce off of surfaces but reduces accuracy."
	colour = "#a8ffe5"

/obj/item/focusing_crystal/refractive/update_casing(obj/item/ammo_casing/fired_casing)
	fired_casing.variance += quality_effect(20, 0)

/obj/item/focusing_crystal/refractive/update_bullet(obj/item/projectile/projectile)
	projectile.ricochets_max += quality_effect(1, 5)
	projectile.ricochet_chance += quality_effect(-30, 100)

//==============================
// Robust Crystal: Increases damage
//==============================

/obj/item/focusing_crystal/robust
	name = "robust crystal"
	desc = "A rare crystal used in the production of energy weapons. This crystal is shaped such that it will amplify the magnitude of light rays passing through it."
	colour = "#da4b57"

/obj/item/focusing_crystal/robust/update_casing(obj/item/ammo_casing/fired_casing)
	fired_casing.variance += quality_effect(10, 0)

/obj/item/focusing_crystal/robust/update_bullet(obj/item/projectile/projectile)
	projectile.damage *= quality_effect(0.8, 1.4)

//==============================
// Brisk Crystal: Increases projectile speed
//==============================

/obj/item/focusing_crystal/speed
	name = "brisk crystal"
	desc = "A rare crystal used in the production of energy weapons. This crystal has a low density medium, allowing light to travel faster after passing through it."
	colour = "#ba8af0"

/obj/item/focusing_crystal/speed/update_bullet(obj/item/projectile/projectile)
	projectile.speed *= quality_effect(0.8, 1.4)

//==============================
// Radioactive Crystal: Reduces damage, allowed lasers to pass through walls and deal radiation damage
//==============================

/obj/item/focusing_crystal/xray
	name = "radioactive crystal"
	desc = "A rare crystal used in the production of energy weapons. This crystal will shift the wavelength of lasers that enter it into the x-ray spectrum, allowing them to pass through walls but weakens the potency."
	colour = "#93f380"

/obj/item/focusing_crystal/xray/update_bullet(obj/item/projectile/projectile)
	projectile.damage *= quality_effect(0.5, 0.8)
	projectile.irradiate = projectile.damage * quality_effect(1, 3)
	projectile.flag = "rad"
	projectile.pass_flags |= PASSTABLE | PASSGLASS | PASSGRILLE | PASSCLOSEDTURF | PASSMACHINE | PASSSTRUCTURE | PASSDOORS
	projectile.set_light_color(LIGHT_COLOR_GREEN)
	projectile.icon_state = "xray"
	projectile.impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	projectile.tracer_type = /obj/effect/projectile/tracer/xray
	projectile.muzzle_type = /obj/effect/projectile/muzzle/xray
	projectile.impact_type = /obj/effect/projectile/impact/xray
