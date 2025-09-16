/obj/projectile/beam
	name = "laser"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSTRANSPARENT | PASSGRILLE
	damage = 20
	damage_type = BURN
	hitsound = 'sound/weapons/sear.ogg'
	hitsound_wall = 'sound/weapons/effects/searwall.ogg'
	armor_flag = LASER
	eyeblur = 2
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	muzzle_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect/energy
	light_system = MOVABLE_LIGHT
	light_range = 2
	light_power = 1
	light_color = LIGHT_COLOR_RED
	light_flags = LIGHT_NO_LUMCOUNT
	ricochets_max = 50	//Honk!
	ricochet_chance = 80
	reflectable = REFLECT_NORMAL

/obj/projectile/beam/laser
	hitscan_tracer_type = /obj/effect/projectile/tracer/laser
	hitscan_muzzle_type = /obj/effect/projectile/muzzle/laser
	hitscan_impact_type = /obj/effect/projectile/impact/laser

/obj/projectile/beam/laser/heavylaser
	name = "heavy laser"
	icon_state = "heavylaser"
	damage = 40
	hitscan_tracer_type = /obj/effect/projectile/tracer/heavy_laser
	hitscan_muzzle_type = /obj/effect/projectile/muzzle/heavy_laser
	hitscan_impact_type = /obj/effect/projectile/impact/heavy_laser

/obj/projectile/beam/laser/on_hit(atom/target, blocked = FALSE)
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

/obj/projectile/beam/laser/lesslethal
	damage = 11
	stamina = 22
	icon_state = "minilaser"

/obj/projectile/beam/weak
	damage = 12

/obj/projectile/beam/weak/shotgun
	damage = 18

/obj/projectile/beam/weak/penetrator //laser gatling and centcom shuttle turret
	damage = 15
	armour_penetration = 50

/obj/projectile/beam/practice
	name = "practice laser"
	damage = 0
	nodamage = TRUE
	martial_arts_no_deflect = TRUE

/obj/projectile/beam/scatter
	name = "laser pellet"
	icon_state = "scatterlaser"
	damage = 5

/obj/projectile/beam/xray
	name = "\improper X-ray beam"
	icon_state = "xray"
	damage = 15
	irradiate = 300
	range = 15
	armour_penetration = 60
	pass_flags = PASSTABLE | PASSTRANSPARENT | PASSGRILLE | PASSCLOSEDTURF | PASSMACHINE | PASSSTRUCTURE | PASSDOORS

	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	light_color = LIGHT_COLOR_GREEN
	hitscan_tracer_type = /obj/effect/projectile/tracer/xray
	hitscan_muzzle_type = /obj/effect/projectile/muzzle/xray
	hitscan_impact_type = /obj/effect/projectile/impact/xray

/obj/projectile/beam/disabler
	name = "disabler beam"
	icon_state = "omnilaser"
	damage = 28
	damage_type = STAMINA
	armor_flag = ENERGY
	hitsound = 'sound/weapons/tap.ogg'
	eyeblur = 0
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE
	hitscan_tracer_type = /obj/effect/projectile/tracer/disabler
	hitscan_muzzle_type = /obj/effect/projectile/muzzle/disabler
	hitscan_impact_type = /obj/effect/projectile/impact/disabler

/obj/projectile/beam/disabler/pass_glass ///this is for the malf ai turret upgrade xdxdxd
	name = "beam-disabler"
	damage = 50
	damage_type = STAMINA
	pass_flags = PASSTABLE | PASSGRILLE | PASSTRANSPARENT

/obj/projectile/beam/pulse
	name = "pulse"
	icon_state = "u_laser"
	damage = 50
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE
	hitscan_tracer_type = /obj/effect/projectile/tracer/pulse
	hitscan_muzzle_type = /obj/effect/projectile/muzzle/pulse
	hitscan_impact_type = /obj/effect/projectile/impact/pulse

/obj/projectile/beam/pulse/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if (!QDELETED(target) && (isturf(target) || istype(target, /obj/structure/)))
		if(isobj(target))
			SSexplosions.med_mov_atom += target
		else
			SSexplosions.medturf += target

/obj/projectile/beam/pulse/shotgun
	damage = 35

/obj/projectile/beam/pulse/heavy
	name = "heavy pulse laser"
	icon_state = "pulse1_bl"
	var/life = 20

/obj/projectile/beam/pulse/heavy/on_hit(atom/target, blocked = FALSE)
	life -= 10
	if(life > 0)
		. = BULLET_ACT_FORCE_PIERCE
	..()

/obj/projectile/beam/emitter
	name = "emitter beam"
	icon_state = "emitter"
	//Will actually be 30 when fired from an emitter due to additional damage provided by stock parts
	damage = 25
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

/obj/projectile/beam/emitter/on_hit(atom/target, blocked)
	if(istype(target, /obj/structure/blob))
		damage *= 0.25
	. = ..()

/obj/projectile/beam/emitter/drill
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

/obj/projectile/beam/emitter/drill/on_hit(atom/target, blocked)
	if(istype(target, /turf/closed/mineral))
		var/turf/closed/mineral/T = target
		T.gets_drilled()
	else if(isturf(target) || (isobj(target) && !istype(target, /obj/structure/blob)))
		damage *= 10
	. = ..()

/obj/projectile/beam/lasertag
	name = "laser tag beam"
	icon_state = "omnilaser"
	hitsound = null
	damage = 0
	damage_type = STAMINA
	armor_flag = ENERGY
	var/suit_types = list(/obj/item/clothing/suit/redtag, /obj/item/clothing/suit/bluetag)
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE
	martial_arts_no_deflect = TRUE

/obj/projectile/beam/lasertag/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/M = target
		if(istype(M.wear_suit))
			if(M.wear_suit.type in suit_types)
				M.adjustStaminaLoss(34)

/obj/projectile/beam/lasertag/redtag
	icon_state = "laser"
	suit_types = list(/obj/item/clothing/suit/bluetag)
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	light_color = LIGHT_COLOR_RED
	hitscan_tracer_type = /obj/effect/projectile/tracer/laser
	hitscan_muzzle_type = /obj/effect/projectile/muzzle/laser
	hitscan_impact_type = /obj/effect/projectile/impact/laser

/obj/projectile/beam/lasertag/redtag/hitscan
	hitscan = TRUE

/obj/projectile/beam/lasertag/bluetag
	icon_state = "bluelaser"
	suit_types = list(/obj/item/clothing/suit/redtag)
	hitscan_tracer_type = /obj/effect/projectile/tracer/laser/blue
	hitscan_muzzle_type = /obj/effect/projectile/muzzle/laser/blue
	hitscan_impact_type = /obj/effect/projectile/impact/laser/blue

/obj/projectile/beam/lasertag/bluetag/hitscan
	hitscan = TRUE

/obj/projectile/beam/instakill
	name = "instagib laser"
	icon_state = "purple_laser"
	damage = 200
	damage_type = BURN
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser
	light_color = LIGHT_COLOR_PURPLE

/obj/projectile/beam/instakill/blue
	icon_state = "blue_laser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE

/obj/projectile/beam/instakill/red
	icon_state = "red_laser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	light_color = LIGHT_COLOR_RED

/obj/projectile/beam/instakill/on_hit(atom/target)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.visible_message(span_danger("[M] explodes into a shower of gibs!"))
		M.gib()

/obj/projectile/beam/colour
	icon_state = "normal_laser_white"
	var/core_overlay = "normal_laser_core"
	color = COLOR_WHITE	// Colour will also be applied to every "type" var you see below us
	light_color = LIGHT_COLOR_WHITE	// Same with light color!
	// This one is important for normal shots
	impact_effect_type = /obj/effect/temp_visual/impact_effect/color
	muzzle_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect/color
	// These ones are important for hitscaner shots
	hitscan_tracer_type = /obj/effect/projectile/tracer/color
	hitscan_muzzle_type = /obj/effect/projectile/muzzle/color
	hitscan_impact_type = /obj/effect/projectile/impact/color

/obj/projectile/beam/colour/update_overlays()
	. = ..()
	var/mutable_appearance/ma = mutable_appearance(icon, "normal_laser_core")
	ma.appearance_flags |= RESET_COLOR
	. += ma

/obj/effect/projectile/impact/color
	icon_state = "laser_impact_white"

/obj/effect/projectile/muzzle/color
	icon_state = "laser_muzzle_white"

/obj/effect/projectile/tracer/color
	icon_state = "laser_beam_white"

/obj/effect/temp_visual/impact_effect/color
	icon_state = "laser_impact_white"
	duration = 4

/obj/effect/temp_visual/dir_setting/firing_effect/color
	icon_state = "firing_effect_white"
	duration = 3
	light_range = 1
	light_power = 1
	light_color = LIGHT_COLOR_WHITE
	light_flags = LIGHT_NO_LUMCOUNT

/obj/effect/temp_visual/impact_effect/color/wall
	icon_state = "laser_impact_wall_white"
	duration = 10

/obj/projectile/beam/colour/disabler
	name = "disabler beam"
	damage = 28
	damage_type = STAMINA
	armor_flag = ENERGY
	hitsound = 'sound/weapons/tap.ogg'
	eyeblur = 0
	color = COLOR_LIGHT_PINK
	light_color = LIGHT_COLOR_PINK
