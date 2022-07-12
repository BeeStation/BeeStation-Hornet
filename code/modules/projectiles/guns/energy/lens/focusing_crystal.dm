#define RARITY_COMMON 1
#define RARITY_RARE 2
#define RARITY_LEGENDARY 3

/obj/item/focusing_crystal
	name = "standard focusing crystal"
	desc = "A rare crystal used in the production of energy weapons. The properties of the crystal affect how the energy beam will be formed."
	icon = 'icons/obj/focusing_crystal.dmi'
	icon_state = "focusing_crystal"
	var/colour = "#ffffff"
	var/quality_rating = 1
	var/quality_text
	var/rarity = RARITY_COMMON

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

/obj/item/focusing_crystal/proc/quality_effect(lower_bound, upper_bound)
	return CLAMP(quality_rating * (upper_bound - lower_bound) + lower_bound, min(upper_bound, lower_bound), max(upper_bound, lower_bound))

//This is called only once, affects the casings created inside the gun
/obj/item/focusing_crystal/proc/update_casing(obj/item/ammo_casing/fired_casing)
	fired_casing.variance += quality_effect(10, -10)
	fired_casing.randomspread = TRUE

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
	rarity = RARITY_LEGENDARY

/obj/item/focusing_crystal/split/update_casing(obj/item/ammo_casing/fired_casing)
	fired_casing.pellets += CEILING(quality_effect(1, 5), 1)
	fired_casing.variance += CEILING(quality_effect(14, 20), 1)
	fired_casing.randomspread = TRUE

/obj/item/focusing_crystal/split/update_bullet(obj/item/projectile/projectile)
	//Increase damage based on quality
	projectile.damage *= quality_effect(0.8, 1.5)
	//Divide damage into lasers evenly
	projectile.damage /= (CEILING(quality_effect(1, 5), 1) + 1)

//==============================
// Refractive Crystal: Causes projectiles to reflect
//==============================

/obj/item/focusing_crystal/refractive
	name = "refractive crystal"
	desc = "A rare crystal used in the production of energy weapons that refracts light passing through it, making it more likely to bounce off of surfaces but reduces accuracy."
	colour = "#a8ffe5"
	rarity = RARITY_RARE

/obj/item/focusing_crystal/refractive/update_casing(obj/item/ammo_casing/fired_casing)
	fired_casing.variance += CEILING(quality_effect(20, 0), 1)
	fired_casing.randomspread = TRUE

/obj/item/focusing_crystal/refractive/update_bullet(obj/item/projectile/projectile)
	/// Directly set it since most energy weapons have a ton of bouncing already
	projectile.ricochets_max = CEILING(quality_effect(1, 5), 1)
	projectile.ricochet_chance += CEILING(quality_effect(-30, 30), 1)
	projectile.force_ricochet = TRUE

//==============================
// Robust Crystal: Increases damage
//==============================

/obj/item/focusing_crystal/robust
	name = "robust crystal"
	desc = "A rare crystal used in the production of energy weapons. This crystal is shaped such that it will amplify the magnitude of light rays passing through it."
	colour = "#da4b57"
	rarity = RARITY_COMMON

/obj/item/focusing_crystal/robust/update_casing(obj/item/ammo_casing/fired_casing)
	fired_casing.variance += CEILING(quality_effect(10, 0), 1)
	fired_casing.randomspread = TRUE

/obj/item/focusing_crystal/robust/update_bullet(obj/item/projectile/projectile)
	projectile.damage *= quality_effect(0.8, 1.4)

//==============================
// Brisk Crystal: Increases projectile speed
//==============================

/obj/item/focusing_crystal/speed
	name = "brisk crystal"
	desc = "A rare crystal used in the production of energy weapons. This crystal has a low density medium, allowing light to travel faster after passing through it."
	colour = "#ba8af0"
	rarity = RARITY_COMMON

/obj/item/focusing_crystal/speed/update_bullet(obj/item/projectile/projectile)
	projectile.speed *= quality_effect(0.8, 1.4)

//==============================
// Radioactive Crystal: Reduces damage, allowed lasers to pass through walls and deal radiation damage
//==============================

/obj/item/focusing_crystal/xray
	name = "radioactive crystal"
	desc = "A rare crystal used in the production of energy weapons. This crystal will shift the wavelength of lasers that enter it into the x-ray spectrum, allowing them to pass through walls but weakens the potency."
	colour = "#93f380"
	rarity = RARITY_LEGENDARY

/obj/item/focusing_crystal/xray/update_bullet(obj/item/projectile/projectile)
	projectile.damage *= quality_effect(0.5, 0.8)
	projectile.irradiate = projectile.damage * CEILING(quality_effect(1, 3), 1)
	projectile.flag = "rad"
	projectile.pass_flags |= PASSTABLE | PASSGLASS | PASSGRILLE | PASSCLOSEDTURF | PASSMACHINE | PASSSTRUCTURE | PASSDOORS
	projectile.set_light_color(LIGHT_COLOR_GREEN)
	projectile.icon_state = "xray"
	projectile.impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	projectile.tracer_type = /obj/effect/projectile/tracer/xray
	projectile.muzzle_type = /obj/effect/projectile/muzzle/xray
	projectile.impact_type = /obj/effect/projectile/impact/xray

//==============================
// Unstable Crystal: Randomises damage and has a chance to do something bad
//==============================

/obj/item/focusing_crystal/unstable
	name = "unstable crystal"
	desc = "An extremely unstable energy crystal. It is highly recommended not to use this in the production of energy based weaponry."
	colour = "#555555"
	rarity = RARITY_RARE

/obj/item/focusing_crystal/unstable/update_bullet(obj/item/projectile/projectile)
	projectile.damage *= rand(0, quality_effect(70, 150)) * 0.01
	if (prob(quality_effect(20, 3)))
		switch (rand(1, quality_effect(1, 4)))
			if(1)
				visible_message("<span class='warning'>[src] releases a burst of radiation!</span>")
				radiation_pulse(src, 60)
			if(2)
				visible_message("<span class='warning'>[src] releases a burst of electromagnetic radiation!</span>")
				empulse(src, 1, 2)
			if(3)
				visible_message("<span class='warning'>[src] releases a burst of radiation!</span>")
				tesla_zap(get_turf(src), 1, 5000)
			if(4)
				visible_message("<span class='userdanger'>[src] begins to collapse in on itself! It's going to blow!</span>")
				addtimer(CALLBACK(GLOBAL_PROC, /proc/explosion, get_turf(src), 0, 0, 2, 5), 60)

//==============================
// Supermatter Crystal: Shooting it too much may cause it to delaminate
//==============================

/obj/item/focusing_crystal/supermatter
	name = "supermatter focusing crystal"
	desc = "An energy focusing crystal ingrained with a rare sample of supermatter. It is extremely unstable and will make weapons almost as deadly to their user as they are to the person on the other end. The supermatter core is shielded by an inert outer crystaline shell."
	colour = "#fdcc2c"
	rarity = RARITY_LEGENDARY
	var/datum/looping_sound/supermatter/soundloop
	var/death_counter = 0
	var/integrity = 100
	var/last_message
	var/emergency_message = FALSE
	var/explode_time

/obj/item/focusing_crystal/supermatter/Initialize(mapload)
	. = ..()
	soundloop = new(list(src), TRUE)
	START_PROCESSING(SSprocessing, src)

/obj/item/focusing_crystal/supermatter/Destroy()
	QDEL_NULL(soundloop)
	STOP_PROCESSING(SSprocessing, src)
	. = ..()

/obj/item/focusing_crystal/supermatter/update_bullet(obj/item/projectile/projectile)
	death_counter ++
	projectile.damage *= quality_effect(0.8, 1.4) * ((min(death_counter, 8) + 1) / 4)
	if (death_counter > 5)
		playsound(get_turf(src), 'sound/effects/supermatter.ogg', 40, 1)
		radiation_pulse(src, 2000, 2, TRUE)

/obj/item/focusing_crystal/supermatter/process(delta_time)
	//Reduce the death counter
	if (death_counter > 0 && prob(death_counter * 20))
		death_counter --
	//Delamination
	if (integrity <= 0)
		if(explode_time && world.time > explode_time)
			explosion(src, 1, 3, 5)
			qdel(src)
			return
		if (!emergency_message)
			say("CRYSTAL DELAMINATION IMMINENT. The supermatter has reached critical integrity failure. Emergency causality destabilization field has been activated.")
			emergency_message = TRUE
			explode_time = world.time + 30 SECONDS
		//Do shocks
		playsound(src, 'sound/weapons/emitter2.ogg', 100, 1, extrarange = 10)
		tesla_zap(get_turf(src), 1, 1500, TESLA_FUSION_FLAGS)
		return
	//Uh oh
	if (death_counter > 3)
		if(prob(20))
			playsound(src, "smdelam", 60, FALSE, 3)
		//Start taking damage
		integrity -= (death_counter - 2)
		if (last_message + 10 SECONDS < world.time)
			message_admins("[src] is beginning to delaminate at [ADMIN_COORDJMP(src)]. It has [integrity]% integrity left.")
			say("Danger! Crystal hyperstructure integrity faltering! Integrity: [integrity]%")
			last_message = world.time
	else
		if(prob(20))
			playsound(src, "smcalm", 60, FALSE, 3)
