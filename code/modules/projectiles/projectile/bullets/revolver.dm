// 7.62x38mmR (Nagant Revolver)

/obj/projectile/bullet/n762
	name = "7.62x38mmR bullet"
	damage = 40
	armour_penetration = 12
	bleed_force = BLEED_BULLET

// .50AE (Desert Eagle)

/obj/projectile/bullet/a50AE
	name = ".50AE bullet"
	damage = 40
	armour_penetration = 10 // Heavy round, slight penetration advantage
	bleed_force = BLEED_BULLET

// .38 (Detective's Gun)

/obj/projectile/bullet/c38
	name = ".38 bullet"
	damage = 20
	ricochets_max = 2
	ricochet_chance = 50
	ricochet_auto_aim_angle = 10
	ricochet_auto_aim_range = 3
	bleed_force = BLEED_BULLET

/obj/projectile/bullet/c38/match
	name = ".38 Match bullet"
	ricochets_max = 4
	ricochet_chance = 100
	ricochet_auto_aim_angle = 40
	ricochet_auto_aim_range = 5
	ricochet_incidence_leeway = 50
	ricochet_decay_chance = 1
	ricochet_decay_damage = 1

/obj/projectile/bullet/c38/match/bouncy
	name = ".38 Bouncy Rubber bullet"
	damage = 5
	stamina = 27
	bleed_force = BLEED_SCRATCH
	organ_damage_multiplier = 0 // Rubber bullets don't penetrate
	ricochets_max = 5
	ricochet_incidence_leeway = 70
	ricochet_chance = 130
	ricochet_decay_damage = 0.9
	armour_penetration = -20

/obj/projectile/bullet/c38/dumdum
	name = ".38 DumDum bullet"
	damage = 12
	armour_penetration = -30
	ricochets_max = 0
	shrapnel_type = /obj/item/shrapnel/bullet/c38/dumdum
	bleed_force = BLEED_BULLET_DEVASTATING
	organ_damage_multiplier = ORGAN_DAMAGE_MULT_HEAVY

/obj/projectile/bullet/c38/trac
	name = ".38 TRAC bullet"
	damage = 10
	ricochets_max = 0

/obj/projectile/bullet/c38/trac/on_hit(atom/target, blocked = FALSE)
	. = ..()
	var/mob/living/M = target
	if(!istype(M))
		return
	if(locate(/obj/item/implant/tracking/c38) in M.implants) //checks if the target already contains a tracking implant
		return

	var/obj/item/implant/tracking/c38/imp = new (M)
	imp.implant(M)

/obj/projectile/bullet/c38/hotshot //similar to incendiary bullets, but do not leave a flaming trail
	name = ".38 Hot Shot bullet"
	damage = 12
	ricochets_max = 0

/obj/projectile/bullet/c38/hotshot/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.adjust_fire_stacks(2)
		M.ignite_mob()

/obj/projectile/bullet/c38/iceblox //see /obj/projectile/temp for the original code
	name = ".38 Iceblox bullet"
	damage = 14
	var/temperature = 100
	ricochets_max = 0

/obj/projectile/bullet/c38/iceblox/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(isliving(target))
		var/mob/living/M = target
		M.adjust_bodytemperature(((100-blocked)/100)*(temperature - M.bodytemperature))

/obj/projectile/bullet/c38/mime
	name = "invisible .38 bullet"
	icon_state = null
	damage = 0
	nodamage = TRUE
	martial_arts_no_deflect = TRUE
	bleed_force = 0
	organ_damage_multiplier = 0 // Mime bullets don't deal real damage

/obj/projectile/bullet/c38/mime/on_hit(atom/target, blocked = FALSE)
	if(isliving(target))
		var/mob/living/carbon/human/M = target
		if(HAS_MIND_TRAIT(M, TRAIT_MIMING))
			var/defense = M.getarmor(CHEST, BULLET, armour_penetration)
			M.apply_damage(5, BRUTE, CHEST, defense)
			M.visible_message(span_danger("A bullet wound appears in [M]'s chest!"), \
							span_userdanger("You get hit with a .38 bullet from a finger gun! Those hurt!..."))
		else
			to_chat(M, span_userdanger("You get shot with the finger gun!"))

/obj/projectile/bullet/c38/mime_lethal
	name = "invisible .38 bullet"
	icon_state = null
	damage = 17
	bleed_force = BLEED_BULLET

/obj/projectile/bullet/c38/mime_lethal/on_hit(atom/target, blocked)
	. = ..()
	if(isliving(target))
		var/mob/living/living_target = target
		living_target.set_silence_if_lower(20 SECONDS)

// .357 (Syndie Revolver)

/obj/projectile/bullet/a357
	name = ".357 bullet"
	damage = 40
	armour_penetration = 20 // Magnum round, good penetration
	bleed_force = BLEED_BULLET

// admin only really, for ocelot memes
/obj/projectile/bullet/a357/match
	name = ".357 match bullet"
	ricochets_max = 5
	ricochet_chance = 140
	ricochet_auto_aim_angle = 50
	ricochet_auto_aim_range = 6
	ricochet_incidence_leeway = 80
	ricochet_decay_chance = 1
