/obj/projectile/bullet/dart
	name = "dart"
	icon_state = "cbbolt"
	damage = 5
	bleed_force = BLEED_SCRATCH
	var/piercing = FALSE
	var/obj/item/reagent_containers/syringe/syringe = null

/obj/projectile/bullet/dart/c38
	name = "bullet"
	icon_state = "bullet"
	damage = 4

/obj/projectile/bullet/dart/Initialize(mapload)
	. = ..()
	create_reagents(50, NO_REACT)

/obj/projectile/bullet/dart/c38/Initialize(mapload)
	. = ..()
	create_reagents(50, NO_REACT)

/obj/projectile/bullet/dart/on_hit(atom/target, blocked = FALSE)
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		if(blocked != 100) // not completely blocked
			if(M.can_inject(firer, FALSE, def_zone, piercing)) // Pass the hit zone to see if it can inject by whether it hit the head or the body.
				..()
				if(syringe)
					syringe.embed(M)
					return BULLET_ACT_HIT
				else
					reagents.expose(M, INJECT)
					reagents.trans_to(M, reagents.total_volume)
					return BULLET_ACT_HIT
			else
				blocked = 100
				target.visible_message(span_danger("\The [src] was deflected!"), \
									   span_userdanger("You were protected against \the [src]!"))

	..(target, blocked)
	if(syringe)
		syringe.forceMove(loc) //no noreact explosions bypassing piercing protection
	DISABLE_BITFIELD(reagents.flags, NO_REACT)
	reagents.handle_reactions()
	return BULLET_ACT_HIT

/obj/projectile/bullet/dart/metalfoam/Initialize(mapload)
	. = ..()
	reagents.add_reagent(/datum/reagent/aluminium, 15)
	reagents.add_reagent(/datum/reagent/foaming_agent, 5)
	reagents.add_reagent(/datum/reagent/toxin/acid/fluacid, 5)


/obj/projectile/bullet/dart/syringe
	name = "syringe"
	icon_state = "syringeproj"

/obj/projectile/bullet/dart/bee
	name = "bee"
	icon_state = "bee"
	damage = 1
	armor_flag = MELEE
	piercing = TRUE

/obj/projectile/bullet/dart/bee/on_hit(atom/target, blocked)
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		if(blocked != 100) // not completely blocked
			if(M.can_inject(target_zone = def_zone) && !HAS_TRAIT(M, TRAIT_BEEFRIEND))
				var/mob/living/simple_animal/hostile/poison/bees/B = new(src.loc)
				for(var/datum/reagent/R in reagents.reagent_list)
					B.assign_reagent(GLOB.chemical_reagents_list[R.type])
					break
			else
				playsound(src, 'sound/effects/splat.ogg', 40, 1)
				new /obj/effect/decal/cleanable/insectguts(src.loc)

		else if (prob(20)) //high velocity bees die easily
			var/mob/living/simple_animal/hostile/poison/bees/B = new(M.loc)
			for(var/datum/reagent/R in reagents.reagent_list)
				B.assign_reagent(GLOB.chemical_reagents_list[R.type])
				break

		else
			playsound(src, 'sound/effects/splat.ogg', 40, 1)
			new /obj/effect/decal/cleanable/insectguts(src.loc)

	else if(prob(20))
		var/mob/living/simple_animal/hostile/poison/bees/B = new(src.loc)
		for(var/datum/reagent/R in reagents.reagent_list)
			B.assign_reagent(GLOB.chemical_reagents_list[R.type])
			break

	else
		playsound(src, 'sound/effects/splat.ogg', 40, 1)
		new /obj/effect/decal/cleanable/insectguts(src.loc)

	return ..()

/obj/projectile/bullet/dart/tranq
	name = "tranquilizer dart"

/obj/projectile/bullet/dart/tranq/Initialize(mapload)
	. = ..()
	reagents.add_reagent(/datum/reagent/toxin/chloralhydrate, 4) //these'll get the victim wallslamming and then sleep em, but it will take awhile before it puts the victim to sleep

/obj/projectile/bullet/dart/tranq/plus

/obj/projectile/bullet/dart/tranq/plus/Initialize(mapload)
	. = ..()
	reagents.add_reagent(/datum/reagent/pax, 1)

/obj/projectile/bullet/dart/tranq/plusplus

/obj/projectile/bullet/dart/tranq/plusplus/Initialize(mapload)
	. = ..()
	reagents.add_reagent(/datum/reagent/pax, 3)
