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

/obj/item/projectile/bullet/c38/trac
	name = ".38 TRAC bullet"
	damage = 10

/obj/item/projectile/bullet/c38/trac/on_hit(atom/target, blocked = FALSE)
	. = ..()
	var/mob/living/carbon/M = target
	var/obj/item/implant/tracking/c38/imp
	for(var/obj/item/implant/tracking/c38/TI in M.implants) //checks if the target already contains a tracking implant
		imp = TI
		return
	if(!imp)
		imp = new /obj/item/implant/tracking/c38(M)
		imp.implant(M)

/obj/item/projectile/bullet/c38/hotshot //similar to incendiary bullets, but do not leave a flaming trail
	name = ".38 Hot Shot bullet"
	damage = 20

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
