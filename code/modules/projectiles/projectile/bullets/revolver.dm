// 7.62x38mmR (Nagant Revolver)

/obj/item/projectile/bullet/n762
	name = "7.62x38mmR bullet"
	damage = 60

// .50AE (Desert Eagle)

/obj/item/projectile/bullet/a50AE
	name = ".50AE bullet"
	damage = 60

// .38 (Detective's Gun)

/obj/item/projectile/bullet/c38
	name = ".38 bullet"
	damage = 25
	ricochets_max = 2
	ricochet_chance = 50
	ricochet_auto_aim_angle = 10
	ricochet_auto_aim_range = 3

/obj/item/projectile/bullet/c38/match
	name = ".38 Match bullet"
	ricochets_max = 4
	ricochet_chance = 100
	ricochet_auto_aim_angle = 40
	ricochet_auto_aim_range = 5
	ricochet_incidence_leeway = 50
	ricochet_decay_chance = 1
	ricochet_decay_damage = 1

/obj/item/projectile/bullet/c38/match/bouncy
	name = ".38 Rubber bullet"
	damage = 10
	stamina = 30
	armour_penetration = -30
	ricochets_max = 6
	ricochet_incidence_leeway = 70
	ricochet_chance = 130
	ricochet_decay_damage = 0.8
	shrapnel_type = NONE

/obj/item/projectile/bullet/c38/dumdum
	name = ".38 DumDum bullet"
	damage = 15
	armour_penetration = -30
	ricochets_max = 0
	shrapnel_type = /obj/item/shrapnel/bullet/c38/dumdum

/obj/item/projectile/bullet/c38/trac
	name = ".38 TRAC bullet"
	damage = 10
	ricochets_max = 0

/obj/item/projectile/bullet/c38/trac/on_hit(atom/target, blocked = FALSE)
	. = ..()
	var/mob/living/M = target
	if(!istype(M))
		return
	if(locate(/obj/item/implant/tracking/c38) in M.implants) //checks if the target already contains a tracking implant
		return

	var/obj/item/implant/tracking/c38/imp = new (M)
	imp.implant(M)

/obj/item/projectile/bullet/c38/hotshot //similar to incendiary bullets, but do not leave a flaming trail
	name = ".38 Hot Shot bullet"
	damage = 20
	ricochets_max = 0

/obj/item/projectile/bullet/c38/hotshot/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.adjust_fire_stacks(6)
		M.IgniteMob()

/obj/item/projectile/bullet/c38/iceblox //see /obj/item/projectile/temp for the original code
	name = ".38 Iceblox bullet"
	damage = 20
	var/temperature = 100
	ricochets_max = 0

/obj/item/projectile/bullet/c38/iceblox/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(isliving(target))
		var/mob/living/M = target
		M.adjust_bodytemperature(((100-blocked)/100)*(temperature - M.bodytemperature))

/obj/item/projectile/bullet/c38/mime
	name = "invisible .38 bullet"
	icon_state = null
	damage = 0
	nodamage = TRUE
	martial_arts_no_deflect = TRUE

/obj/item/projectile/bullet/c38/mime/on_hit(atom/target, blocked = FALSE)
	if(isliving(target))
		var/mob/living/carbon/human/M = target
		if(M.job == "Mime")
			var/defense = M.getarmor(CHEST, "bullet")
			M.apply_damage(5, BRUTE, CHEST, defense)
			M.visible_message("<span class='danger'>A bullet wound appears in [M]'s chest!</span>", \
							"<span class='userdanger'>You get hit with a .38 bullet from a finger gun! Those hurt!...</span>")
		else
			to_chat(M, "<span class='userdanger'>You get shot with the finger gun!</span>")

// .357 (Syndie Revolver)

/obj/item/projectile/bullet/a357
	name = ".357 bullet"
	damage = 60

// admin only really, for ocelot memes
/obj/item/projectile/bullet/a357/match
	name = ".357 match bullet"
	ricochets_max = 5
	ricochet_chance = 140
	ricochet_auto_aim_angle = 50
	ricochet_auto_aim_range = 6
	ricochet_incidence_leeway = 80
	ricochet_decay_chance = 1
