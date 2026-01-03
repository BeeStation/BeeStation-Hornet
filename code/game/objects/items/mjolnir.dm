/obj/item/mjolnir
	name = "Mjolnir"
	desc = "A weapon worthy of a god, able to strike with the force of a lightning bolt. It crackles with barely contained energy."
	icon_state = "mjollnir0"
	lefthand_file = 'icons/mob/inhands/weapons/hammers_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/hammers_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BACK
	force = 5
	throwforce = 30
	throw_range = 7

	attack_weight = 3
	w_class = WEIGHT_CLASS_HUGE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

/obj/item/mjolnir/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, force_multiplier=5, icon_wielded="mjollnir1", attacksound="sparks")

/obj/item/mjolnir/update_icon_state()
	icon_state = "mjollnir0"
	return ..()

/obj/item/mjolnir/Moved(atom/OldLoc, Dir)
	//If it was thrown out of an anchored mjolnir, destroy that
	if (istype(OldLoc, /obj/structure/anchored_mjolnir))
		var/obj/structure/anchored_mjolnir/old_mjolnir = OldLoc
		old_mjolnir.contained = null
		qdel(old_mjolnir)
	. = ..()

/obj/item/mjolnir/proc/shock(mob/living/target)
	var/datum/effect_system/lightning_spread/s = new /datum/effect_system/lightning_spread
	s.set_up(5, 1, target.loc)
	s.start()
	target.visible_message(span_danger("[target.name] was shocked by [src]!"), \
		span_userdanger("You feel a powerful shock course through your body sending you flying!"), \
		span_italics("You hear a heavy electrical crack!"))
	var/atom/throw_target = get_edge_target_turf(target, get_dir(src, get_step_away(target, src)))
	target.throw_at(throw_target, 200, 4)
	return

/obj/item/mjolnir/attack(mob/living/M, mob/user)
	..()
	if(ISWIELDED(src))
		playsound(src.loc, "sparks", 50, 1)
		shock(M)

/obj/item/mjolnir/throw_at(atom/target, range, speed, mob/thrower, spin, diagonals_first, datum/callback/callback, force, quickstart)
	thrower.visible_message(span_warning("[thrower] throws [src] with impossible strength!"), span_notice("You lightly throw [src] and it accelerates out of your hand!"))
	//Create the mjolnir projectile
	var/obj/projectile/created = new /obj/projectile/mjolnir(get_turf(src), src)
	created.preparePixelProjectile(target, thrower)
	created.firer = thrower
	created.fire()

/obj/item/mjolnir/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(isliving(hit_atom))
		shock(hit_atom)

/obj/item/mjolnir/update_icon()  //Currently only here to fuck with the on-mob icons.
	icon_state = "mjollnir0"
	..()

/obj/item/mjolnir/dropped(mob/user)
	. = ..()
	user.visible_message(span_warning("[user] releases [src] and it instantly slams to the ground with a heavy thud."))
	//Create the mjolnir hammer
	new /obj/structure/anchored_mjolnir(get_turf(src), src)

/obj/structure/anchored_mjolnir
	name = "Mjolnir"
	desc = "A weapon worthy of a god, able to strike with the force of a lightning bolt. It crackles with barely contained energy."
	icon = 'icons/obj/wizard_48x32.dmi'
	icon_state = "anchored_mjolnir"
	flags_1 = CONDUCT_1
	anchored = TRUE
	move_resist = INFINITY
	density = TRUE
	layer = HIGH_OBJ_LAYER
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	var/obj/item/mjolnir/contained

CREATION_TEST_IGNORE_SUBTYPES(/obj/structure/anchored_mjolnir)

/obj/structure/anchored_mjolnir/Initialize(mapload, obj/item/mjolnir/god_hammer)
	. = ..()
	//Put the hammer inside of ourselves
	contained = god_hammer
	if (god_hammer)
		god_hammer.forceMove(src)
	//Get a meteor sound, to show how intense the drop it
	var/random_frequency = get_rand_frequency()
	//Shake cameras of nearby mobs, its just that heavy
	for(var/mob/M in GLOB.player_list)
		if((M.orbiting) && (SSaugury.watchers[M]))
			continue
		var/turf/T = get_turf(M)
		if(!T || T.get_virtual_z_level() != src.get_virtual_z_level())
			continue
		var/dist = get_dist(M.loc, src.loc)
		if (dist < 30)
			shake_camera(M, dist > 20 ? 2 : 4, dist > 20 ? 1 : 3)
			M.playsound_local(get_turf(src), 'sound/effects/bamf.ogg', 50, 1, random_frequency, 10)
	//Any lying mobs on the turf (apart from wizards) get crushed
	for (var/mob/living/mob_on_tile in loc)
		if (mob_on_tile.mobility_flags & MOBILITY_STAND || IS_WIZARD(mob_on_tile))
			continue
		mob_on_tile.emote("scream")
		mob_on_tile.take_bodypart_damage(40, 0, 0, check_armor = TRUE)
		to_chat(mob_on_tile, span_userdanger("You are crushed by [god_hammer]!"))

//How did this even happen?
/obj/structure/anchored_mjolnir/Destroy()
	if(contained)
		QDEL_NULL(contained)
	return ..()

/obj/structure/anchored_mjolnir/attack_hand(mob/user, list/modifiers)
	. = ..()
	if (IS_WIZARD(user))
		var/hammer = contained
		if (user.put_in_active_hand(contained))
			user.visible_message(span_danger("[user] effortlessly lifts [hammer]."))
	else
		user.visible_message(span_notice("[user] attempts to lift [contained], but its too heavy!"), span_userdanger("[contained] is too heavy!"))


/obj/projectile/mjolnir
	name = "mjolnir"
	desc = "A weapon worthy of a god, able to strike with the force of a lightning bolt. It crackles with barely contained energy."
	icon_state = "mjollnir"
	nodamage = FALSE
	damage = 30
	range = 40
	projectile_phasing = NONE
	projectile_piercing = (ALL & (~PASSCLOSEDTURF))
	speed = 0.3
	var/obj/item/mjolnir/contained

CREATION_TEST_IGNORE_SUBTYPES(/obj/projectile/mjolnir)

/obj/projectile/mjolnir/Initialize(mapload, obj/item/mjolnir/contained_hammer)
	. = ..()
	contained = contained_hammer
	if (contained_hammer)
		contained_hammer.forceMove(src)

/obj/projectile/mjolnir/Destroy()
	if (contained)
		new /obj/structure/anchored_mjolnir(loc, contained)
		contained = null
	. = ..()

/obj/projectile/mjolnir/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	if (isobj(target))
		var/obj/hit_structure = target
		hit_structure.take_damage(120)
		if (hit_structure.get_integrity() > 0)
			qdel(src)
	if (isliving(target))
		var/mob/living/hit_mob = target
		if (contained)
			if (IS_WIZARD(hit_mob))
				//Pickup the hammer
				if (hit_mob.put_in_active_hand(contained))
					contained = null
			else
				contained.shock(hit_mob)
		qdel(src)
