/obj/projectile/laser
	name = "laser"
	pass_flags = PASSTABLE | PASSTRANSPARENT | PASSGRILLE
	damage = 20
	damage_type = BURN
	hitsound = 'sound/weapons/sear.ogg'
	hitsound_wall = 'sound/weapons/effects/searwall.ogg'
	armor_flag = LASER
	eyeblur = 2
	light_system = MOVABLE_LIGHT
	light_range = 2
	light_power = 1
	light_flags = LIGHT_NO_LUMCOUNT
	ricochets_max = 50	//Honk!
	ricochet_chance = 80
	reflectable = REFLECT_NORMAL

	// Dynamic Colour vars:
	icon_state = "normal_laser_white"
	/// Overlay used to keep the bullets core pure white
	var/core_overlay = "normal_laser_core"
	// Colour will also be applied to every "type" var you see below us
	color = COLOR_WHITE
	// Same with light color!
	light_color = LIGHT_COLOR_WHITE
	// This one is important for normal shots
	impact_effect_type = /obj/effect/temp_visual/impact_effect/color
	muzzle_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect/color
	// These ones are important for hitscaner shots
	hitscan_tracer_type = /obj/effect/projectile/tracer/color
	hitscan_muzzle_type = /obj/effect/projectile/muzzle/color
	hitscan_impact_type = /obj/effect/projectile/impact/color

//* EFFECT SUBTYPES FOR COLOURING *//

/obj/effect/projectile/impact/color
	icon_state = "laser_impact_white"

/obj/effect/projectile/muzzle/color
	icon_state = "laser_muzzle_white"

/obj/effect/projectile/tracer/color
	icon_state = "laser_beam_white"

/obj/effect/temp_visual/impact_effect/color
	icon_state = "laser_impact_white"
	core_overlay = "laser_impact_core"
	duration = 4
	light_range = 1
	light_power = 1
	light_color = LIGHT_COLOR_WHITE
	light_flags = LIGHT_NO_LUMCOUNT

/obj/effect/temp_visual/dir_setting/firing_effect/color
	icon_state = "firing_effect_white"
	core_overlay = "firing_effect_core"
	duration = 3
	/// Muzzles now have a light effect, they didn't prior!
	light_range = 1
	light_power = 1
	light_color = LIGHT_COLOR_WHITE
	light_flags = LIGHT_NO_LUMCOUNT

/obj/effect/temp_visual/impact_effect/color/wall
	icon_state = "laser_impact_wall_white"
	core_overlay = "laser_impact_wall_core"
	duration = 10

/obj/projectile/laser/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/projectile/laser/update_overlays()
	. = ..()
	var/mutable_appearance/ma = mutable_appearance(icon, core_overlay)
	ma.appearance_flags |= RESET_COLOR
	. += ma

/obj/projectile/laser/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.IgniteMob()
	else if(isturf(target))
		// If the target is a turf change impact effect, if its not meant to be colourable give it default red
		if(istype(impact_effect_type, /obj/effect/temp_visual/impact_effect/color))
			impact_effect_type = /obj/effect/temp_visual/impact_effect/color/wall
		else
			impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser/wall

/obj/projectile/laser/mini
	// This is a smaller version of the laser beam, it amounts to a small bullet
	name = "mini-laser"
	icon_state = "minilaser_white"
	core_overlay = "minilaser_core"

//* BEAM SUBTYPES *//

/obj/projectile/laser/lethal
	name = "lethal beam"
	damage = 20
	damage_type = BURN
	color = COLOR_RED
	light_color = LIGHT_COLOR_RED

/obj/projectile/laser/mini/lesslethal
	damage = 11
	stamina = 22
	color = COLOR_ORANGE
	light_color = LIGHT_COLOR_ORANGE

/obj/projectile/laser/heavy
	name = "heavy laser"
	icon_state = "heavylaser"
	damage = 40
	color = null
	light_color = LIGHT_COLOR_RED
	hitscan_tracer_type = /obj/effect/projectile/tracer/heavy_laser
	hitscan_muzzle_type = /obj/effect/projectile/muzzle/heavy_laser
	hitscan_impact_type = /obj/effect/projectile/impact/heavy_laser

/obj/projectile/laser/weak
	damage = 12
	color = COLOR_RED
	light_color = LIGHT_COLOR_RED

/obj/projectile/laser/weak/shotgun
	damage = 18

/obj/projectile/laser/weak/penetrator //laser gatling and centcom shuttle turret
	damage = 15
	armour_penetration = 50

/obj/projectile/laser/practice
	name = "practice laser"
	damage = 0
	nodamage = TRUE
	martial_arts_no_deflect = TRUE
	color = COLOR_RED
	light_color = LIGHT_COLOR_RED

/obj/projectile/laser/scatter
	name = "laser pellet"
	icon_state = "scatterlaser"	// This does NOT exit
	damage = 5	// TO DO

/obj/projectile/laser/xray
	name = "\improper X-ray beam"
	icon_state = "xray"
	damage = 15
	irradiate = 300
	range = 15
	armour_penetration = 60
	pass_flags = PASSTABLE | PASSTRANSPARENT | PASSGRILLE | PASSCLOSEDTURF | PASSMACHINE | PASSSTRUCTURE | PASSDOORS
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	color = null
	light_color = LIGHT_COLOR_GREEN
	hitscan_tracer_type = /obj/effect/projectile/tracer/xray
	hitscan_muzzle_type = /obj/effect/projectile/muzzle/xray
	hitscan_impact_type = /obj/effect/projectile/impact/xray

/obj/projectile/laser/disabler
	name = "disabler beam"
	damage = 28
	damage_type = STAMINA
	armor_flag = ENERGY
	hitsound = 'sound/weapons/tap.ogg'
	eyeblur = 0
	color = COLOR_LIGHT_PINK
	light_color = LIGHT_COLOR_PINK
	//color = COLOR_CYAN
	//light_color = LIGHT_COLOR_BLUE

/obj/projectile/laser/disabler/pass_glass ///this is for the malf ai turret upgrade xdxdxd
	name = "beam-disabler"
	damage = 50
	damage_type = STAMINA
	pass_flags = PASSTABLE | PASSGRILLE | PASSTRANSPARENT

/obj/projectile/laser/pulse
	name = "pulse"
	icon_state = "u_laser"
	damage = 50
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	color = null
	light_color = LIGHT_COLOR_BLUE
	hitscan_tracer_type = /obj/effect/projectile/tracer/pulse
	hitscan_muzzle_type = /obj/effect/projectile/muzzle/pulse
	hitscan_impact_type = /obj/effect/projectile/impact/pulse

/obj/projectile/laser/pulse/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if (!QDELETED(target) && (isturf(target) || istype(target, /obj/structure/)))
		if(isobj(target))
			SSexplosions.med_mov_atom += target
		else
			SSexplosions.medturf += target

/obj/projectile/laser/pulse/shotgun
	damage = 35

/obj/projectile/laser/pulse/heavy
	name = "heavy pulse laser"
	icon_state = "pulse1_bl"
	var/life = 20

/obj/projectile/laser/pulse/heavy/on_hit(atom/target, blocked = FALSE)
	life -= 10
	if(life > 0)
		. = BULLET_ACT_FORCE_PIERCE
	..()

/obj/projectile/laser/emitter
	name = "emitter beam"
	icon_state = "emitter"
	//Will actually be 30 when fired from an emitter due to additional damage provided by stock parts
	damage = 25
	color = null
	light_color = LIGHT_COLOR_GREEN
	hitscan = TRUE
	hitscan_muzzle_type = /obj/effect/projectile/muzzle/laser/emitter
	hitscan_tracer_type = /obj/effect/projectile/tracer/laser/emitter
	hitscan_impact_type = /obj/effect/projectile/impact/laser/emitter
	impact_effect_type = null
	hitscan_light_intensity = 3
	hitscan_light_range = 0.75
	hitscan_light_color_override = COLOR_LIME
	muzzle_flash_intensity = 6
	muzzle_flash_range = 2
	muzzle_flash_color_override = COLOR_LIME
	impact_light_intensity = 7
	impact_light_range = 2.5
	impact_light_color_override = COLOR_LIME

/obj/projectile/laser/emitter/on_hit(atom/target, blocked)
	if(istype(target, /obj/structure/blob))
		damage *= 0.25
	. = ..()

/obj/projectile/laser/emitter/drill
	name = "driller beam"
	icon_state = "emitter"
	//Will actually be 10 when fired from an emitter due to additional damage provided by stock parts
	damage = 5
	light_color = COLOR_DARK_ORANGE
	hitscan_muzzle_type = /obj/effect/projectile/muzzle/laser/emitter/drill
	hitscan_tracer_type = /obj/effect/projectile/tracer/laser/emitter/drill
	hitscan_impact_type = /obj/effect/projectile/impact/laser/emitter/drill
	hitscan_light_color_override = COLOR_DARK_ORANGE
	muzzle_flash_color_override = COLOR_DARK_ORANGE
	impact_light_color_override = COLOR_DARK_ORANGE

/obj/projectile/laser/emitter/drill/on_hit(atom/target, blocked)
	if(istype(target, /turf/closed/mineral))
		var/turf/closed/mineral/T = target
		T.gets_drilled()
	else if(isturf(target) || (isobj(target) && !istype(target, /obj/structure/blob)))
		damage *= 10
	. = ..()

/obj/projectile/laser/lasertag
	name = "laser tag beam"
	icon_state = "omnilaser"
	hitsound = null
	damage = 0
	damage_type = STAMINA
	armor_flag = ENERGY
	var/suit_types = list(/obj/item/clothing/suit/redtag, /obj/item/clothing/suit/bluetag)
	color = COLOR_DARK_CYAN
	light_color = LIGHT_COLOR_BLUE
	martial_arts_no_deflect = TRUE

/obj/projectile/laser/lasertag/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/M = target
		if(istype(M.wear_suit))
			if(M.wear_suit.type in suit_types)
				M.adjustStaminaLoss(34)

/obj/projectile/laser/lasertag/redtag
	icon_state = "laser"
	suit_types = list(/obj/item/clothing/suit/bluetag)
	color = COLOR_RED
	light_color = LIGHT_COLOR_RED

/obj/projectile/laser/lasertag/redtag/hitscan
	hitscan = TRUE
	color = null
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	hitscan_tracer_type = /obj/effect/projectile/tracer/laser
	hitscan_muzzle_type = /obj/effect/projectile/muzzle/laser
	hitscan_impact_type = /obj/effect/projectile/impact/laser

/obj/projectile/laser/lasertag/bluetag
	icon_state = "bluelaser"
	suit_types = list(/obj/item/clothing/suit/redtag)
	color = COLOR_DARK_CYAN
	light_color = LIGHT_COLOR_BLUE

/obj/projectile/laser/lasertag/bluetag/hitscan
	hitscan = TRUE
	color = null
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	hitscan_tracer_type = /obj/effect/projectile/tracer/laser/blue
	hitscan_muzzle_type = /obj/effect/projectile/muzzle/laser/blue
	hitscan_impact_type = /obj/effect/projectile/impact/laser/blue

/obj/projectile/laser/instakill
	name = "instagib laser"
	icon_state = "purple_laser"
	damage = 200
	damage_type = BURN
	color = COLOR_STRONG_MAGENTA
	light_color = LIGHT_COLOR_PURPLE

/obj/projectile/laser/instakill/blue
	icon_state = "blue_laser"
	color = COLOR_DARK_CYAN
	light_color = LIGHT_COLOR_BLUE

/obj/projectile/laser/instakill/red
	icon_state = "red_laser"
	color = COLOR_RED
	light_color = LIGHT_COLOR_RED

/obj/projectile/laser/instakill/on_hit(atom/target)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.visible_message(span_danger("[M] explodes into a shower of gibs!"))
		M.gib()

///* SHOTGUN PELLETS *///

/obj/projectile/laser/pellet
	name = "laser pellet"
	icon_state = "laser_pellet"
	core_overlay = "laser_pellet_core"
	range = 10
	ricochets_max = 1
	ricochet_chance = 50
	ricochet_decay_chance = 0.9
	light_range = 1
	light_power = 2

/obj/projectile/laser/pellet/Range()
	..()
	if(damage > 0)
		damage = min(initial(damage), range)
	if(stamina > 0)
		stamina = min(initial(stamina), range)
	// The following makes shots fade out
	var/target_alpha = min(initial(alpha), initial(alpha) * min(1, range / 10))
	light_power = initial(light_power) * (range / 10)
	alpha = target_alpha
	set_light_power(light_power)

/obj/projectile/laser/pellet/disabler
	name = "disabler pellet"
	damage = 12
	damage_type = STAMINA
	armor_flag = ENERGY
	hitsound = 'sound/weapons/tap.ogg'
	eyeblur = 0
	speed = 1
	color = COLOR_CYAN
	light_color = LIGHT_COLOR_CYAN

/obj/projectile/laser/pellet/lethal
	name = "lethal pellet"
	damage = 10
	range = 12
	speed = 1
	color = COLOR_RED
	light_color = LIGHT_COLOR_RED
