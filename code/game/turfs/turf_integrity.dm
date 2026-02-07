/**
 * Largely a copy paste of obj_dense.dm
 * The best way to do this would be with interfaces, however we do not have
 * access to them. Components could work but would be unwieldly for this situation.
 */

/turf
	/// Can this turf be hit by players?
	var/can_hit = TRUE
	/// The integrity that the turf starts at, defaulting to max_integrity
	var/integrity
	/// The maximum integrity that the turf has
	max_integrity = 450
	/// INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ON_FIRE | UNACIDABLE | ACID_PROOF
	resistance_flags = NONE
	/// If damage is less than this value for melee attacks, it will deal 0 damage
	damage_deflection = 5

/turf/examine(mob/user)
	. = ..()
	if (!isnull(integrity) && integrity < max_integrity)
		var/healthpercent = (integrity/max_integrity) * 100
		switch(healthpercent)
			if(50 to 99)
				. +=  "It looks slightly damaged."
			if(25 to 50)
				. +=  "It appears heavily damaged."
			if(0 to 25)
				. +=  span_warning("It's falling apart!")
	if (!can_hit)
		return
	if (istype(user, /mob/living/simple_animal))
		var/mob/living/simple_animal/attacker = user
		if ((attacker.obj_damage || attacker.melee_damage) >= damage_deflection)
			. += span_notice("You are capable of damaging this wall with your attacks!")
		else
			. += span_warning("It doesn't look like you can damage this...")

/turf/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir, armour_penetration = 0)
	if(QDELETED(src))
		CRASH("[src] taking damage after deletion")
	if(sound_effect)
		play_attack_sound(damage_amount, damage_type, damage_flag)
	if((resistance_flags & INDESTRUCTIBLE) || integrity <= 0)
		return
	damage_amount = run_atom_armor(damage_amount, damage_type, damage_flag, attack_dir, armour_penetration)
	if(damage_amount < DAMAGE_PRECISION)
		return
	. = damage_amount
	var/old_integ = integrity
	integrity = old_integ - damage_amount

	//DESTROYING SECOND
	if(integrity <= 0)
		turf_destruction(damage_flag, -integrity)
	else
		after_damage(damage_amount, damage_type, damage_flag)

/turf/proc/after_damage(damage_amount, damage_type, damage_flag)
	return

/// Destroy the turf and replace it with a new one
/// Note that due to the behaviour of turfs, the reference of src changes during ScrapeAway, so calling
/// the parent is not recommended.
/turf/proc/turf_destruction(damage_flag, additional_damage)
	var/previous_type = type
	ScrapeAway()
	// If we scrape away into a turf of the same type, don't go any deeper.
	if (type == previous_type)
		return
	// Cascade turf damage downwards on destruction
	if (additional_damage > 0)
		if (damage_flag == BOMB || damage_flag == ACID || damage_flag == FIRE)
			take_damage(additional_damage, BRUTE, damage_flag, FALSE)

//====================================
// Generic Hits
//====================================

/turf/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if (!can_hit)
		return ..()
	..()
	take_damage(AM.throwforce, BRUTE, MELEE, 1, get_dir(src, AM))

//====================================
// Explosives
//====================================

/turf/ex_act(severity, target)
	if(resistance_flags & INDESTRUCTIBLE)
		return ..()
	..() //contents explosion
	if(target == src)
		take_damage(INFINITY, BRUTE, BOMB, 0)
		return
	switch(severity)
		if(1)
			take_damage(INFINITY, BRUTE, BOMB, 0)
		if(2)
			hotspot_expose(1000,CELL_VOLUME)
			take_damage(rand(0.5, max(1600 / max_integrity, 1.2)) * max_integrity, BRUTE, BOMB, 0)
		if(3)
			hotspot_expose(1000,CELL_VOLUME)
			take_damage(rand(0.3, max(700 / max_integrity, 0.5)) * max_integrity, BRUTE, BOMB, 0)

/turf/contents_explosion(severity, target)
	for(var/thing in contents)
		var/atom/atom_thing = thing
		if(!QDELETED(atom_thing))
			if(ismovable(atom_thing))
				var/atom/movable/movable_thing = atom_thing
				if(!movable_thing.ex_check(explosion_id))
					continue
				switch(severity)
					if(EXPLODE_DEVASTATE)
						SSexplosions.high_mov_atom += movable_thing
					if(EXPLODE_HEAVY)
						SSexplosions.med_mov_atom += movable_thing
					if(EXPLODE_LIGHT)
						SSexplosions.low_mov_atom += movable_thing

//====================================
// Bullets
//====================================

/turf/bullet_act(obj/projectile/P)
	if (!can_hit)
		return ..()
	. = ..()
	playsound(src, P.hitsound, 50, 1)
	if(P.suppressed != SUPPRESSED_VERY)
		visible_message(span_danger("[src] is hit by \a [P]!"), null, null, COMBAT_MESSAGE_RANGE)
	take_damage(P.damage, P.damage_type, P.armor_flag, 0, turn(P.dir, 180), P.armour_penetration)

//====================================
// Generic Attack Chain
//====================================

/obj/item/proc/attack_turf(turf/T, mob/living/user)
	if(item_flags & NOBLUDGEON)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(T)
	T.attacked_by(src, user)

/turf/attacked_by(obj/item/I, mob/living/user)
	if(I.force)
		user.visible_message(span_danger("[user] hits [src] with [I]!"), \
					span_danger("You hit [src] with [I]!"), null, COMBAT_MESSAGE_RANGE)
		//only witnesses close by and the victim see a hit message.
		log_combat(user, src, "attacked", I)
	take_damage(I.force, I.damtype, MELEE, 1)

/turf/attackby(obj/item/W, mob/user, params)
	if (!ISADVANCEDTOOLUSER(user))
		to_chat(user, span_warning("You don't have the dexterity to do this!"))
		return

	//get the user's location
	if(!isturf(user.loc))
		return	//can't do this stuff whilst inside objects and such

	add_fingerprint(user)

	var/turf/T = user.loc	//get user's location for delay checks

	//the istype cascade has been spread among various procs for easy overriding
	if(try_clean(W, user, T) || try_wallmount(W, user, T) || try_decon(W, user, T) || try_destroy(W, user, T))
		return

	if(can_lay_cable() && istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/coil = W
		for(var/obj/structure/cable/LC in src)
			if(!LC.d1 || !LC.d2)
				LC.attackby(W,user)
				return
		coil.place_turf(src, user)
		return TRUE

	else if(istype(W, /obj/item/rcl))
		handleRCL(W, user)

	return ..() || ((can_hit) && W.attack_turf(src, user))

/turf/proc/try_clean(obj/item/W, mob/user, turf/T)
	return FALSE

/turf/proc/try_wallmount(obj/item/W, mob/user, turf/T)
	return FALSE


/turf/proc/try_decon(obj/item/I, mob/user, turf/T)
	return FALSE


/turf/proc/try_destroy(obj/item/I, mob/user, turf/T)
	return FALSE

//====================================
// Mob Attacks
//====================================

/turf/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)
	if (!can_hit)
		return ..()
	if(user.combat_mode)
		..(user, 1)
		user.visible_message(span_danger("[user] smashes [src]!"), span_danger("You smash [src]!"), null, COMBAT_MESSAGE_RANGE)
		if(density)
			playsound(src, 'sound/effects/meteorimpact.ogg', 100, 1)
			user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ), forced="hulk")
		else
			playsound(src, 'sound/effects/bang.ogg', 50, 1)
		take_damage(hulk_damage(), BRUTE, MELEE, 0, get_dir(src, user))
		return 1
	return 0

/turf/blob_act(obj/structure/blob/B)
	if (!can_hit)
		return ..()
	if (!..())
		return
	take_damage(400, BRUTE, MELEE, 0, get_dir(src, B))

/turf/attack_alien(mob/living/carbon/alien/humanoid/user)
	if (!can_hit)
		return ..()
	if (damage_deflection > 20)
		playsound(src, 'sound/effects/bang.ogg', 50, 1)
		to_chat(user, span_warning("This wall is too strong for you to destroy!"))
		return
	if(attack_generic(user, 60, BRUTE, MELEE, 0))
		playsound(src, 'sound/weapons/slash.ogg', 100, 1)

/turf/attack_animal(mob/living/simple_animal/M)
	if (!can_hit)
		return ..()
	if(!M.melee_damage && !M.obj_damage)
		M.emote("custom", message = "[M.friendly_verb_continuous] [src].")
		return 0
	else
		var/play_soundeffect = 1
		if(M.environment_smash)
			play_soundeffect = 0
		if(M.obj_damage)
			. = attack_generic(M, M.obj_damage, M.melee_damage_type, MELEE, play_soundeffect, M.armour_penetration)
		else
			. = attack_generic(M, M.melee_damage, M.melee_damage_type, MELEE, play_soundeffect, M.armour_penetration)
		if(. && !play_soundeffect)
			playsound(src, 'sound/effects/meteorimpact.ogg', 100, 1)

/turf/attack_slime(mob/living/simple_animal/slime/M)
	if (!can_hit)
		return
	if(!M.is_adult)
		return
	var/damage = 4
	if(M.transformeffects & SLIME_EFFECT_RED)
		damage = 10
	attack_generic(M, damage, MELEE, 1)

//====================================
// Mechs
//====================================

/turf/mech_melee_attack(obj/vehicle/sealed/mecha/mecha_attacker, mob/living/user)
	if (!can_hit)
		return FALSE
	mecha_attacker.do_attack_animation(src)
	switch(mecha_attacker.damtype)
		if(BRUTE)
			playsound(src, 'sound/weapons/punch4.ogg', 50, TRUE)
		if(BURN)
			playsound(src, 'sound/items/welder.ogg', 50, TRUE)
		else
			return FALSE
	mecha_attacker.visible_message(span_danger("[mecha_attacker.name] hits [src]!"), span_danger("You hit [src]!"), null, COMBAT_MESSAGE_RANGE)
	..()
	return take_damage(mecha_attacker.force * 3, mecha_attacker.damtype, "melee", FALSE, get_dir(src, mecha_attacker)) // multiplied by 3 so we can hit objs hard but not be overpowered against mobs.

//====================================
// Singularity
//====================================

/turf/singularity_act()
	if (resistance_flags & INDESTRUCTIBLE)
		return
	if(underfloor_accessibility < UNDERFLOOR_INTERACTABLE)
		for(var/obj/O in contents) //this is for deleting things like wires contained in the turf
			if(HAS_TRAIT(O, TRAIT_T_RAY_VISIBLE))
				O.singularity_act()
	ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
	return(2)

//====================================
// Acid
//====================================

/turf/acid_act(acidpwr, acid_volume)
	if (resistance_flags & (INDESTRUCTIBLE | ACID_PROOF))
		return
	. = 1
	var/acid_type = /obj/effect/acid
	if(acidpwr >= 200) //alien acid power
		acid_type = /obj/effect/acid/alien
	var/has_acid_effect = FALSE
	for(var/obj/O in src)
		if(istype(O, acid_type))
			var/obj/effect/acid/A = O
			A.acid_level = min(acid_volume * acidpwr, 12000)//capping acid level to limit power of the acid
			has_acid_effect = 1
			continue
		if(underfloor_accessibility < UNDERFLOOR_INTERACTABLE && HAS_TRAIT(O, TRAIT_T_RAY_VISIBLE))
			continue

		O.acid_act(acidpwr, acid_volume)
	if(!has_acid_effect)
		new acid_type(src, acidpwr, acid_volume)

/turf/proc/acid_melt()
	turf_destruction(ACID, 0)

//====================================
// Fire
//====================================

/turf/fire_act(exposed_temperature, exposed_volume)
	if (resistance_flags & INDESTRUCTIBLE)
		return
	if(exposed_temperature && !(resistance_flags & FIRE_PROOF))
		take_damage(clamp(0.02 * exposed_temperature, 0, 20), BURN, FIRE, 0)
	if(!(resistance_flags & ON_FIRE) && (resistance_flags & FLAMMABLE) && !(resistance_flags & FIRE_PROOF))
		resistance_flags |= ON_FIRE
		SSfire_burning.processing[src] = src
		update_icon()
		return 1

//called when the obj is destroyed by fire
/turf/proc/burn()
	if(resistance_flags & ON_FIRE)
		SSfire_burning.processing -= src
	turf_destruction(FIRE, 0)

/turf/extinguish()
	. = ..()
	if(resistance_flags & ON_FIRE)
		resistance_flags &= ~ON_FIRE
		update_icon()
		SSfire_burning.processing -= src

//Whatever happens after high temperature fire dies out or thermite reaction works.
//Should return new turf
/turf/proc/Melt()
	return ScrapeAway(flags = CHANGETURF_INHERIT_AIR)

/// Handles exposing a turf to reagents.
/turf/expose_reagents(list/reagents, datum/reagents/source, method=TOUCH, volume_modifier=1, show_message=TRUE)
	if((. = ..()) & COMPONENT_NO_EXPOSE_REAGENTS)
		return

	for(var/reagent in reagents)
		var/datum/reagent/R = reagent
		. |= R.expose_turf(src, reagents[R])

/turf/proc/burn_tile()
	return

//====================================
// Rust
//====================================

/turf/rust_heretic_act()
	if(HAS_TRAIT(src, TRAIT_RUSTY))
		return

	AddElement(/datum/element/rust)
	return TRUE

//====================================
// Gods
//====================================

/turf/narsie_act(force, ignore_mobs, probability = 20)
	. = (prob(probability) || force)
	for(var/I in src)
		var/atom/A = I
		if(ignore_mobs && ismob(A))
			continue
		if(ismob(A) || .)
			A.narsie_act()

/turf/ratvar_act(force, ignore_mobs, probability = 40)
	. = (prob(probability) || force)
	for(var/I in src)
		var/atom/A = I
		if(ignore_mobs && ismob(A))
			continue
		if(ismob(A) || .)
			A.ratvar_act()
