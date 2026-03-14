/obj/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	..()
	take_damage(AM.throwforce, BRUTE, MELEE, 1, get_dir(src, AM))

/obj/ex_act(severity, target)
	if(resistance_flags & INDESTRUCTIBLE)
		return

	..() //contents explosion
	if(QDELETED(src))
		return
	if(target == src)
		take_damage(INFINITY, BRUTE, BOMB, 0)
		return
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(INFINITY, BRUTE, BOMB, 0)
		if(EXPLODE_HEAVY)
			take_damage(rand(100, 250), BRUTE, BOMB, 0)
		if(EXPLODE_LIGHT)
			take_damage(rand(10, 90), BRUTE, BOMB, 0)

/obj/bullet_act(obj/projectile/P)
	. = ..()
	playsound(src, P.hitsound, 50, TRUE)
	var/damage
	if(!QDELETED(src)) //Bullet on_hit effect might have already destroyed this object
		damage = take_damage(P.damage, P.damage_type, P.armor_flag, 0, turn(P.dir, 180), P.armour_penetration)
	if(P.suppressed != SUPPRESSED_VERY)
		visible_message(span_danger("[src] is hit by \a [P][damage ? "" : ", without leaving a mark"]!"), null, null, COMBAT_MESSAGE_RANGE)

/obj/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)
	..()
	if(density)
		playsound(src, 'sound/effects/meteorimpact.ogg', 100, TRUE)
	else
		playsound(src, 'sound/effects/bang.ogg', 50, TRUE)
	var/damage = take_damage(hulk_damage(), BRUTE, MELEE, 0, get_dir(src, user))
	user.visible_message(span_danger("[user] smashes [src][damage ? "" : ", without leaving a mark"]!"), span_danger("You smash [src][damage ? "" : ", without leaving a mark"]!"), null, COMBAT_MESSAGE_RANGE)
	return TRUE

/obj/blob_act(obj/structure/blob/B)
	if (!..())
		return
	if(isturf(loc))
		var/turf/T = loc
		if(T.underfloor_accessibility < UNDERFLOOR_INTERACTABLE && HAS_TRAIT(src, TRAIT_T_RAY_VISIBLE))
			return
	take_damage(400, BRUTE, MELEE, 0, get_dir(src, B))

/obj/attack_alien(mob/living/carbon/alien/humanoid/user)
	if(attack_generic(user, 60, BRUTE, MELEE, 0))
		playsound(src.loc, 'sound/weapons/slash.ogg', 100, 1)

/obj/attack_animal(mob/living/simple_animal/M)
	if(!M.melee_damage && !M.obj_damage)
		M.emote("custom", message = "[M.friendly_verb_continuous] [src].")
		return FALSE
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

/obj/force_pushed(atom/movable/pusher, force = MOVE_FORCE_DEFAULT, direction)
	return TRUE

/obj/move_crushed(atom/movable/pusher, force = MOVE_FORCE_DEFAULT, direction)
	collision_damage(pusher, force, direction)
	return TRUE

/obj/proc/collision_damage(atom/movable/pusher, force = MOVE_FORCE_DEFAULT, direction)
	var/amt = max(0, ((force - (move_resist * MOVE_FORCE_CRUSH_RATIO)) / (move_resist * MOVE_FORCE_CRUSH_RATIO)) * 10)
	take_damage(amt, BRUTE)

/obj/attack_slime(mob/living/simple_animal/slime/user, list/modifiers)
	if(!user.is_adult)
		return
	var/damage = rand(15)
	if(user.transformeffects & SLIME_EFFECT_RED)
		damage *= 1.1
	attack_generic(user, damage, MELEE, 1)

/obj/singularity_act()
	SSexplosions.high_mov_atom += src
	if(src && !QDELETED(src))
		qdel(src)
	return 2


///// ACID

GLOBAL_DATUM_INIT(acid_overlay, /mutable_appearance, mutable_appearance('icons/effects/effects.dmi', "acid"))

//the obj's reaction when touched by acid
/obj/acid_act(acidpwr, acid_volume)
	if(!(resistance_flags & (UNACIDABLE | INDESTRUCTIBLE)) && acid_volume)

		if(!acid_level)
			SSacid.processing[src] = src
			update_icon()
		var/acid_cap = acidpwr * 300 //so we cannot use huge amounts of weak acids to do as well as strong acids.
		if(acid_level < acid_cap)
			acid_level = min(acid_level + acidpwr * acid_volume, acid_cap)
		return 1

//the proc called by the acid subsystem to process the acid that's on the obj
/obj/proc/acid_processing()
	. = 1
	if(!(resistance_flags & ACID_PROOF))
		if(prob(33))
			playsound(loc, 'sound/items/welder.ogg', 150, 1)
		take_damage(min(1 + round(sqrt(acid_level)*0.3), 300), BURN, ACID, 0)

	acid_level = max(acid_level - (5 + 3*round(sqrt(acid_level))), 0)
	if(!acid_level)
		return 0

//called when the obj is destroyed by acid.
/obj/proc/acid_melt()
	SSacid.processing -= src
	deconstruct(FALSE)

//// FIRE

/obj/fire_act(exposed_temperature, exposed_volume)
	if(isturf(loc))
		var/turf/T = loc
		if(T.underfloor_accessibility < UNDERFLOOR_INTERACTABLE && HAS_TRAIT(src, TRAIT_T_RAY_VISIBLE))
			return
	if(exposed_temperature && !(resistance_flags & FIRE_PROOF))
		take_damage(clamp(0.02 * exposed_temperature, 0, 20), BURN, FIRE, 0)
	if(!(resistance_flags & ON_FIRE) && (resistance_flags & FLAMMABLE) && !(resistance_flags & FIRE_PROOF))
		resistance_flags |= ON_FIRE
		SSfire_burning.processing[src] = src
		update_appearance()
		return 1
	return ..()

//called when the obj is destroyed by fire
/obj/proc/burn()
	if(resistance_flags & ON_FIRE)
		SSfire_burning.processing -= src
	deconstruct(FALSE)

/obj/extinguish()
	. = ..()
	if(resistance_flags & ON_FIRE)
		resistance_flags &= ~ON_FIRE
		update_icon()
		SSfire_burning.processing -= src

///Called when the obj is hit by a tesla bolt.
/obj/zap_act(power, zap_flags)
	if(QDELETED(src))
		return 0
	ADD_TRAIT(src, TRAIT_BEING_SHOCKED, WAS_SHOCKED)
	addtimer(TRAIT_CALLBACK_REMOVE(src, TRAIT_BEING_SHOCKED, WAS_SHOCKED), 1 SECONDS)
	return power / 2

//The surgeon general warns that being buckled to certain objects receiving powerful shocks is greatly hazardous to your health
//Only tesla coils and grounding rods currently call this because mobs are already targeted over all other objects, but this might be useful for more things later.
/obj/proc/zap_buckle_check(strength)
	if(has_buckled_mobs())
		for(var/mob/living/buckled_mob in buckled_mobs)
			buckled_mob.electrocute_act((clamp(round(strength * 1.25e-3), 10, 90) + rand(-5, 5)), src, flags = SHOCK_TESLA)

/obj/proc/reset_shocked()
	obj_flags &= ~BEING_SHOCKED

//the obj is deconstructed into pieces, whether through careful disassembly or when destroyed.
/obj/proc/deconstruct(disassembled = TRUE)
	SEND_SIGNAL(src, COMSIG_OBJ_DECONSTRUCT, disassembled)
	qdel(src)

//what happens when the obj's integrity reaches zero.
/obj/atom_destruction(damage_flag)
	. = ..()
	if(damage_flag == ACID)
		acid_melt()
	else if(damage_flag == FIRE)
		burn()
	else
		deconstruct(FALSE)

//returns how much the object blocks an explosion
/obj/proc/GetExplosionBlock()
	CRASH("Unimplemented GetExplosionBlock()")
