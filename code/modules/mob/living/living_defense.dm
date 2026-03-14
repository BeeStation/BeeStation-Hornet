/// Runs an armour check against a mob and returns the armour value to use.
/// 0 represents 0% protection, while 100 represents 100% protection.
/// The return value for this proc can be negative, indicating that the damage values should be increased.
/// A message will be thrown to the user if their armour protects them, unless the silent flag is set.
/mob/living/proc/run_armor_check(def_zone = null, attack_flag = MELEE, absorb_text = null, soften_text = null, armour_penetration, penetrated_text, silent=FALSE)
	var/armor = getarmor(def_zone, attack_flag, penetration = armour_penetration)

	if(armor <= 0)
		return armor

	// This equation will reach a max value of 75
	armor = STANDARDISE_ARMOUR(armor)

	if(silent)
		return armor

	//the if "armor" check is because this is used for everything on /living, including humans
	if(armour_penetration)
		if(penetrated_text)
			to_chat(src, span_userdanger("[penetrated_text]"))
		else
			to_chat(src, span_userdanger("Your armor was penetrated!"))
	else if(armor >= 100)
		if(absorb_text)
			to_chat(src, span_notice("[absorb_text]"))
		else
			to_chat(src, span_notice("Your armor absorbs the blow!"))
	else
		if(soften_text)
			to_chat(src, span_warning("[soften_text]"))
		else
			to_chat(src, span_warning("Your armor softens the blow!"))
	return armor

/// Get the armour value for a specific damage type, targeting a particular zone.
/// def_zone: The body zone to get the armour for. Null indicates no body zone and will calculate an average armour value instead.
/// type: The damage type to test for. Must not be null.
/// penetration: The amount of penetration to add. A value of 20 will reduce the effectiveness of each individual armour piece by 80%.
/// Returns: An integer value with 0 representing 0% protection and 100 representing 100% protection.
/// - The return value can be negative which indicates additional armour, but will never exceed 100.
/// - Armour penetration should not be applied on the return value of this proc, due to its upper bound of 100.
/mob/living/proc/getarmor(def_zone, type, penetration = 0)
	return 0

//this returns the mob's protection against eye damage (number between -1 and 2) from bright lights
/mob/living/proc/get_eye_protection()
	return 0

//this returns the mob's protection against ear damage (0:no protection; 1: some ear protection; 2: has no ears)
/mob/living/proc/get_ear_protection()
	return 0

/mob/living/proc/is_mouth_covered(head_only = 0, mask_only = 0)
	return FALSE

/mob/living/proc/is_eyes_covered(check_glasses = 1, check_head = 1, check_mask = 1)
	return FALSE

/mob/living/proc/on_hit(obj/projectile/P)
	return BULLET_ACT_HIT

/mob/living/bullet_act(obj/projectile/P, def_zone, piercing_hit = FALSE)
	var/bullet_signal = SEND_SIGNAL(src, COMSIG_ATOM_BULLET_ACT, P, def_zone)
	if(bullet_signal & COMSIG_ATOM_BULLET_ACT_FORCE_PIERCE)
		return BULLET_ACT_FORCE_PIERCE
	else if(bullet_signal & COMSIG_ATOM_BULLET_ACT_BLOCK)
		return BULLET_ACT_BLOCK
	else if(bullet_signal & COMSIG_ATOM_BULLET_ACT_HIT)
		return BULLET_ACT_HIT
	var/armor = run_armor_check(def_zone, P.armor_flag, "","",P.armour_penetration)
	if(!P.nodamage)
		apply_damage(P.damage, P.damage_type, def_zone, armor)
		if(P.dismemberment)
			check_projectile_dismemberment(P, def_zone)
	return P.on_hit(src, armor, piercing_hit)? BULLET_ACT_HIT : BULLET_ACT_BLOCK

/mob/living/proc/check_projectile_dismemberment(obj/projectile/P, def_zone)
	return 0

/obj/item/proc/get_volume_by_throwforce_and_or_w_class()
		if(throwforce && w_class)
				return clamp((throwforce + (w_class / 2)) * 5, 30, 100)// Add the item's throwforce to its weight class and multiply by 5, then clamp the value between 30 and 100
		else if(w_class)
				return clamp(w_class * 4, 20, 100) // Multiply the item's weight class by 8, then clamp the value between 20 and 100
		else
				return 0

/mob/living/proc/set_combat_mode(new_mode, silent = TRUE)
	if(combat_mode == new_mode)
		return
	. = combat_mode
	combat_mode = new_mode
	if(hud_used?.action_intent)
		hud_used.action_intent.update_appearance()
	if(silent || !(client?.prefs.read_preference(/datum/preference/toggle/sound_combatmode)))
		return
	if(combat_mode)
		SEND_SOUND(src, sound('sound/misc/ui_togglecombat.ogg', volume = 25)) //Sound from interbay!
	else
		SEND_SOUND(src, sound('sound/misc/ui_toggleoffcombat.ogg', volume = 25)) //Slightly modified version of the above

/mob/living/hitby(atom/movable/AM, skipcatch, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	if(istype(AM, /obj/item))
		var/obj/item/I = AM
		var/zone = ran_zone(BODY_ZONE_CHEST, 65)//Hits a random part of the body, geared towards the chest
		var/dtype = BRUTE
		var/volume = I.get_volume_by_throwforce_and_or_w_class()
		var/nosell_hit = SEND_SIGNAL(I, COMSIG_MOVABLE_IMPACT_ZONE, src, zone, blocked, throwingdatum) // TODO: find a better way to handle hitpush and skipcatch for humans
		if(nosell_hit)
			skipcatch = TRUE
			hitpush = FALSE

		if(blocked)
			return TRUE

		if (I.throwforce > 0) //If the weapon's throwforce is greater than zero...
			if (I.throwhitsound) //...and throwhitsound is defined...
				playsound(loc, I.throwhitsound, volume, 1, -1) //...play the weapon's throwhitsound.
			else if(I.hitsound) //Otherwise, if the weapon's hitsound is defined...
				playsound(loc, I.hitsound, volume, 1, -1) //...play the weapon's hitsound.
			else if(!I.throwhitsound) //Otherwise, if throwhitsound isn't defined...
				playsound(loc, 'sound/weapons/genhit.ogg',volume, 1, -1) //...play genhit.ogg.

		else if(!I.throwhitsound && I.throwforce > 0) //Otherwise, if the item doesn't have a throwhitsound and has a throwforce greater than zero...
			playsound(loc, 'sound/weapons/genhit.ogg', volume, 1, -1)//...play genhit.ogg
		if(!I.throwforce)// Otherwise, if the item's throwforce is 0...
			playsound(loc, 'sound/weapons/throwtap.ogg', 1, volume, -1)//...play throwtap.ogg.
		if(!blocked)
			visible_message(span_danger("[src] is hit by [I]!"), \
							span_userdanger("You're hit by [I]!"))
			var/armor = run_armor_check(zone, MELEE, "Your armor has protected your [parse_zone(zone)].", "Your armor has softened hit to your [parse_zone(zone)].",I.armour_penetration)
			apply_damage(I.throwforce, dtype, zone, armor)

			var/mob/thrown_by = I.thrownby?.resolve()
			if(thrown_by)
				log_combat(thrown_by, src, "threw and hit", I, important = I.force)
			if(!INCAPACITATED_IGNORING(src, INCAPABLE_GRAB)) // physics says it's significantly harder to push someone by constantly chucking random furniture at them if they are down on the floor.
				hitpush = FALSE
		else
			return 1
	else
		playsound(loc, 'sound/weapons/genhit.ogg', 50, 1, -1)
	..(AM, skipcatch, hitpush, blocked, throwingdatum)

/mob/living/fire_act()
	. = ..()
	adjust_fire_stacks(3)
	ignite_mob()

/**
 * Called when this mob is grabbed by another mob.
 */
/mob/living/proc/grabbedby(mob/living/user, supress_message = FALSE)
	. = TRUE
	if(user == src || anchored || !isturf(user.loc))
		return FALSE
	if(!user.pulling || user.pulling != src)
		user.start_pulling(src, supress_message = supress_message)
		return

	if(!(status_flags & CANPUSH) || HAS_TRAIT(src, TRAIT_PUSHIMMUNE))
		to_chat(user, span_warning("[src] can't be grabbed more aggressively!"))
		return FALSE

	if(user.grab_state >= GRAB_AGGRESSIVE && HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, span_notice("You don't want to risk hurting [src]!"))
		return FALSE
	grippedby(user)
	update_incapacitated()

//proc to upgrade a simple pull into a more aggressive grab.
/mob/living/proc/grippedby(mob/living/user, instant = FALSE)
	if(user.grab_state >= user.max_grab)
		return
	user.changeNext_move(CLICK_CD_GRABBING)
	var/sound_to_play = 'sound/weapons/thudswoosh.ogg'
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.dna.species.grab_sound)
			sound_to_play = H.dna.species.grab_sound
	playsound(src.loc, sound_to_play, 50, TRUE, -1)

	if(user.grab_state) //only the first upgrade is instantaneous
		var/old_grab_state = user.grab_state
		var/grab_upgrade_time = instant ? 0 : 30
		visible_message("<span class='danger'>[user] starts to tighten [user.p_their()] grip on [src]!</span>", \
						"<span class='userdanger'>[user] starts to tighten [user.p_their()] grip on you!</span>", "<span class='hear'>You hear aggressive shuffling!</span>", null, user)
		to_chat(user, "<span class='danger'>You start to tighten your grip on [src]!</span>")
		switch(user.grab_state)
			if(GRAB_AGGRESSIVE)
				log_combat(user, src, "attempted to neck grab", addition="neck grab")
			if(GRAB_NECK)
				log_combat(user, src, "attempted to strangle", addition="kill grab")
		if(!do_after(user, grab_upgrade_time, src))
			return FALSE
		if(!user.pulling || user.pulling != src || user.grab_state != old_grab_state)
			return FALSE
	user.setGrabState(user.grab_state + 1)
	switch(user.grab_state)
		if(GRAB_AGGRESSIVE)
			var/add_log = ""
			if(HAS_TRAIT(user, TRAIT_PACIFISM))
				visible_message("<span class='danger'>[user] firmly grips [src]!</span>",
								"<span class='danger'>[user] firmly grips you!</span>", "<span class='hear'>You hear aggressive shuffling!</span>", null, user)
				to_chat(user, "<span class='danger'>You firmly grip [src]!</span>")
				add_log = " (pacifist)"
			else
				visible_message("<span class='danger'>[user] grabs [src] aggressively!</span>", \
								"<span class='userdanger'>[user] grabs you aggressively!</span>", "<span class='hear'>You hear aggressive shuffling!</span>", null, user)
				to_chat(user, "<span class='danger'>You grab [src] aggressively!</span>")
			stop_pulling()
			log_combat(user, src, "grabbed", addition="aggressive grab[add_log]")
		if(GRAB_NECK)
			log_combat(user, src, "grabbed", addition="neck grab")
			visible_message("<span class='danger'>[user] grabs [src] by the neck!</span>",\
							"<span class='userdanger'>[user] grabs you by the neck!</span>", "<span class='hear'>You hear aggressive shuffling!</span>", null, user)
			to_chat(user, "<span class='danger'>You grab [src] by the neck!</span>")
			if(!buckled && !density)
				Move(user.loc)
		if(GRAB_KILL)
			log_combat(user, src, "strangled", addition="kill grab")
			visible_message("<span class='danger'>[user] is strangling [src]!</span>", \
							"<span class='userdanger'>[user] is strangling you!</span>", "<span class='hear'>You hear aggressive shuffling!</span>", null, user)
			to_chat(user, "<span class='danger'>You're strangling [src]!</span>")
			if(!buckled && !density)
				Move(user.loc)
	user.set_pull_offsets(src, grab_state)
	return TRUE


/mob/living/attack_slime(mob/living/simple_animal/slime/M, list/modifiers)
	if(!SSticker.HasRoundStarted())
		to_chat(M, "You cannot attack people before the game has started.")
		return

	if(M.buckled)
		if(M in buckled_mobs)
			M.Feedstop()
		return // can't attack while eating!

	if(HAS_TRAIT(M, TRAIT_PACIFISM))
		to_chat(M, span_notice("You don't want to hurt anyone!"))
		return FALSE

	if(stat != DEAD)
		log_combat(M, src, "attacked")
		M.do_attack_animation(src)
		visible_message(span_danger("\The [M.name] glomps [src]!"), \
						span_userdanger("\The [M.name] glomps you!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, M)
		to_chat(M, span_danger("You glomp [src]!"))
		return TRUE

/mob/living/attack_animal(mob/living/simple_animal/M)
	M.face_atom(src)
	if(M.melee_damage == 0)
		visible_message(span_notice("\The [M] [M.friendly_verb_continuous] [src]!"), \
						span_notice("\The [M] [M.friendly_verb_continuous] you!"), null, COMBAT_MESSAGE_RANGE, M)
		to_chat(M, span_notice("You [M.friendly_verb_simple] [src]!"))
		return FALSE
	if(HAS_TRAIT(M, TRAIT_PACIFISM))
		to_chat(M, span_notice("You don't want to hurt anyone!"))
		return FALSE

	if(M.attack_sound)
		playsound(loc, M.attack_sound, 50, 1, 1)
	M.do_attack_animation(src)
	visible_message(span_danger("\The [M] [M.attack_verb_continuous] [src]!"), \
					span_userdanger("\The [M] [M.attack_verb_continuous] you!"), null, COMBAT_MESSAGE_RANGE, M)
	to_chat(M, span_danger("You [M.attack_verb_simple] [src]!"))
	log_combat(M, src, "attacked")
	return TRUE

/mob/living/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = ..()
	var/martial_result = user.apply_martial_art(src, modifiers)
	if (martial_result != MARTIAL_ATTACK_INVALID)
		return martial_result

/mob/living/attack_paw(mob/living/carbon/monkey/user, list/modifiers)
	var/martial_result = user.apply_martial_art(src, modifiers)
	if (martial_result != MARTIAL_ATTACK_INVALID)
		return martial_result

	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		if (user != src && iscarbon(src))
			user.disarm(src)
			return TRUE
	if (!user.combat_mode)
		return FALSE
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, "<span class='notice'>You don't want to hurt anyone!</span>")
		return FALSE

	if(user.is_mouth_covered(ITEM_SLOT_MASK))
		to_chat(user, span_warning("You can't bite with your mouth covered!"))
		return FALSE
	user.do_attack_animation(src, ATTACK_EFFECT_BITE)
	log_combat(user, src, "attacked")
	playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)
	visible_message("<span class='danger'>[user.name] bites [src]!</span>", \
						"<span class='userdanger'>[user.name] bites you!</span>", "<span class='hear'>You hear a chomp!</span>", COMBAT_MESSAGE_RANGE, user)
	to_chat(user, "<span class='danger'>You bite [src]!</span>")

	return TRUE

/mob/living/attack_larva(mob/living/carbon/alien/larva/L, list/modifiers)
	if(L.combat_mode)
		if(HAS_TRAIT(L, TRAIT_PACIFISM))
			to_chat(L, "<span class='warning'>You don't want to hurt anyone!</span>")
			return

		L.do_attack_animation(src)
		if(prob(90))
			log_combat(L, src, "attacked")
			visible_message("<span class='danger'>[L.name] bites [src]!</span>", \
							"<span class='userdanger'>[L.name] bites you!</span>", "<span class='hear'>You hear a chomp!</span>", COMBAT_MESSAGE_RANGE, L)
			to_chat(L, "<span class='danger'>You bite [src]!</span>")
			playsound(loc, 'sound/weapons/bite.ogg', 50, TRUE, -1)
			return TRUE
		else
			visible_message("<span class='danger'>[L.name]'s bite misses [src]!</span>", \
							"<span class='danger'>You avoid [L.name]'s bite!</span>", "<span class='hear'>You hear the sound of jaws snapping shut!</span>", COMBAT_MESSAGE_RANGE, L)
			to_chat(L, "<span class='warning'>Your bite misses [src]!</span>")
	else
		visible_message("<span class='notice'>[L.name] rubs its head against [src].</span>", \
						"<span class='notice'>[L.name] rubs its head against you.</span>", null, null, L)
		to_chat(L, "<span class='notice'>You rub your head against [src].</span>")
		return FALSE
	return FALSE

/mob/living/attack_alien(mob/living/carbon/alien/humanoid/user, modifiers)
	SEND_SIGNAL(src, COMSIG_MOB_ATTACK_ALIEN, user, modifiers)
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		user.do_attack_animation(src, ATTACK_EFFECT_DISARM)
		return TRUE
	if(user.combat_mode)
		if(HAS_TRAIT(user, TRAIT_PACIFISM))
			to_chat(user, span_warning("You don't want to hurt anyone!"))
			return FALSE
		user.do_attack_animation(src)
		return TRUE
	else
		visible_message(span_notice("[user] caresses [src] with its scythe-like arm."), \
						span_notice("[user] caresses you with its scythe-like arm."), null, null, user)
		to_chat(user, span_notice("You caress [src] with your scythe-like arm."))
		return FALSE

/mob/living/ex_act(severity, target, origin)
	if(origin && istype(origin, /datum/spacevine_mutation) && isvineimmune(src))
		return
	..()

//Looking for irradiate()? It's been moved to radiation.dm under the rad_act() for mobs.

/mob/living/acid_act(acidpwr, acid_volume)
	take_bodypart_damage(acidpwr * min(1, acid_volume * 0.1))
	return 1

///As the name suggests, this should be called to apply electric shocks.
/mob/living/proc/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE)
	SEND_SIGNAL(src, COMSIG_LIVING_ELECTROCUTE_ACT, shock_damage, source, siemens_coeff, flags)
	shock_damage *= siemens_coeff
	if((flags & SHOCK_TESLA) && (flags_1 & TESLA_IGNORE_1))
		return FALSE
	if(HAS_TRAIT(src, TRAIT_SHOCKIMMUNE))
		return FALSE
	if(shock_damage < 1)
		return FALSE
	if(!(flags & SHOCK_ILLUSION))
		adjustFireLoss(shock_damage)
	else
		adjustStaminaLoss(shock_damage)
	if(!(flags & SHOCK_SUPPRESS_MESSAGE))
		visible_message(
			span_danger("[src] was shocked by \the [source]!"), \
			span_userdanger("You feel a powerful shock coursing through your body!"), \
			span_hear("You hear a heavy electrical crack.") \
		)
	return shock_damage

/mob/living/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_CONTENTS)
		return
	for(var/obj/O in contents)
		O.emp_act(severity)

/*
 * Singularity acting on every (living)mob will generally lead to a big fat gib, and Mr. Singulo gaining 20 points.
 * Stuff like clown & engineers with their unique point values are under /mob/living/carbon/human/singularity_act()
 */
/mob/living/singularity_act()

	if (client)
		client.give_award(/datum/award/achievement/misc/singularity_death, client.mob)

	investigate_log("has been consumed by the singularity.", INVESTIGATE_ENGINES) //Oh that's where the clown ended up!
	investigate_log("has been gibbed by the singularity.", INVESTIGATE_DEATHS)
	gib()
	return 20 //20 points goes to our lucky winner Mr. Singulo!~

/mob/living/narsie_act()
	if(HAS_TRAIT(src, TRAIT_GODMODE) || QDELETED(src))
		return
	if(GLOB.narsie && GLOB.narsie.souls_needed[src])
		GLOB.narsie.souls_needed -= src
		GLOB.narsie.souls += 1
		if((GLOB.narsie.souls == GLOB.narsie.soul_goal) && (GLOB.narsie.resolved == FALSE))
			GLOB.narsie.resolved = TRUE
			sound_to_playing_players('sound/machines/alarm.ogg')
			addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(cult_ending_helper), 1), 120)
			addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(ending_helper)), 270)
	if(client)
		makeNewConstruct(/mob/living/simple_animal/hostile/construct/harvester, src, cultoverride = TRUE)
	else
		switch(rand(1, 4))
			if(1)
				new /mob/living/simple_animal/hostile/construct/juggernaut/hostile(get_turf(src))
			if(2)
				new /mob/living/simple_animal/hostile/construct/wraith/hostile(get_turf(src))
			if(3)
				new /mob/living/simple_animal/hostile/construct/artificer/hostile(get_turf(src))
			if(4)
				new /mob/living/simple_animal/hostile/construct/proteon/hostile(get_turf(src))
	spawn_dust()
	gib()
	return TRUE


//called when the mob receives a bright flash
/mob/living/proc/flash_act(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0, type = /atom/movable/screen/fullscreen/flash)
	if(get_eye_protection() >= intensity)
		return FALSE
	if(!override_blindness_check && is_blind())
		return FALSE
	if(client?.prefs?.read_player_preference(/datum/preference/toggle/darkened_flash))
		type = /atom/movable/screen/fullscreen/flash/black
	overlay_fullscreen("flash", type)
	addtimer(CALLBACK(src, PROC_REF(clear_fullscreen), "flash", 2.5 SECONDS), 2.5 SECONDS)
	return TRUE

//called when the mob receives a loud bang
/mob/living/proc/soundbang_act()
	return 0

//to damage the clothes worn by a mob
/mob/living/proc/damage_clothes(damage_amount, damage_type = BRUTE, damage_flag = 0, def_zone)
	return


/mob/living/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!used_item)
		used_item = get_active_held_item()
	..()

/mob/living/proc/force_hit_projectile(obj/projectile/projectile)
	return FALSE

/mob/living/proc/get_weapon_inaccuracy_modifier(atom/target, obj/item/gun/weapon)
	. = 0
	if(HAS_TRAIT(src, TRAIT_POOR_AIM)) //nice shootin' tex
		. += 25
	// Nothing to hold onto, slight penalty for flying around in space
	var/default_speed = get_config_multiplicative_speed() + CONFIG_GET(number/movedelay/run_delay)
	var/current_speed = cached_multiplicative_slowdown
	var/move_time = last_move_time
	// Check for being buckled to mobs and vehicles
	if (buckled)
		// If we are on a riding, check that
		var/datum/component/riding/riding_component = buckled.GetComponent(/datum/component/riding)
		if (riding_component)
			current_speed = riding_component.vehicle_move_delay
			move_time = move_time
		// If we are buckled to a mob, use the speed of the mob we are buckled to instead
		else if (istype(buckled, /mob))
			var/mob/buckle_target = buckled
			current_speed = buckle_target.get_config_multiplicative_speed() + CONFIG_GET(number/movedelay/run_delay)
			move_time = max(move_time, buckle_target.last_move_time)
		else
			// Take the higher value of move time if we don't know what we are buckled to
			move_time = max(move_time, buckled.last_move_time)
	// Lower speed is better, so this is reversed
	var/speed_delta = default_speed - current_speed
	// Are we holding onto something?
	var/is_holding = has_gravity(get_turf(src))
	if (!is_holding)
		if(locate(/obj/structure/lattice) in range(1, get_turf(src)))
			is_holding = TRUE
		else
			for (var/turf/T as() in RANGE_TURFS(1, src))
				if (T.density)
					is_holding = TRUE
					break
	// Every 1 faster than default, you get a penalty of 10 accuracy, or 20 if there is no gravity.
	// If you are moving slower than the default speed, you get a bonus.
	// This means with the captain's jetpack, the spread cone is 20 degrees.
	// However, if you aren't moving, this will be 0
	if (speed_delta > 0)
		// We haven't moved in 1 second, give us no penalty to aiming
		if (move_time + 1 SECONDS < world.time)
			return
		. += (speed_delta * 10) * (is_holding ? 1 : 2)
	else
		// Can only improve up to the maximum improvement, otherwise shotguns gain accuracy when walking
		// This means walking will improve your accuracy by a total of 12.
		// This is only really useful if you are using a gun with a shield.
		. = max(0, . + speed_delta * 8)

/mob/living/proc/is_shove_knockdown_blocked()
	return FALSE

/// Universal disarm effect, can be used by other components that also want a similar effect to pushback
/// and stun.
/mob/living/proc/disarm_effect(mob/living/carbon/attacker, silent = FALSE)
	var/turf/target_oldturf = loc
	var/shove_dir = get_dir(attacker.loc, target_oldturf)
	var/turf/target_shove_turf = get_step(loc, shove_dir)
	var/mob/living/carbon/human/target_collateral_human
	var/obj/structure/table/target_table
	var/obj/machinery/disposal/bin/target_disposal_bin
	var/turf/open/indestructible/sound/pool/target_pool	//This list is getting pretty long, but its better than calling shove_act or something on every atom
	var/shove_blocked = FALSE //Used to check if a shove is blocked so that if it is knockdown logic can be applied

	//Thank you based whoneedsspace
	target_collateral_human = locate(/mob/living/carbon) in target_shove_turf.contents
	if(target_collateral_human)
		shove_blocked = TRUE
	else
		Move(target_shove_turf, shove_dir)
		if(get_turf(src) == target_oldturf)
			target_table = locate(/obj/structure/table) in target_shove_turf.contents
			target_disposal_bin = locate(/obj/machinery/disposal/bin) in target_shove_turf.contents
			target_pool = istype(target_shove_turf, /turf/open/indestructible/sound/pool) ? target_shove_turf : null
			shove_blocked = TRUE

	if(IsKnockdown())
		var/target_held_item = get_active_held_item()
		if(target_held_item)
			if (!silent)
				visible_message(span_danger("[attacker.name] kicks \the [target_held_item] out of [src]'s hand!"),
								span_danger("[attacker.name] kicks \the [target_held_item] out of your hand!"), null, COMBAT_MESSAGE_RANGE)
			log_combat(attacker, src, "disarms [target_held_item]", "disarm")
		else
			if (!silent)
				visible_message(span_danger("[attacker.name] kicks [name] onto [p_their()] side!"),
								span_danger("[attacker.name] kicks you onto your side!"), null, COMBAT_MESSAGE_RANGE)
			log_combat(attacker, src, "kicks", "disarm", "onto their side (paralyzing)")
		Paralyze(SHOVE_CHAIN_PARALYZE) //duration slightly shorter than disarm cd
	if(shove_blocked && !is_shove_knockdown_blocked() && !buckled)
		var/directional_blocked = FALSE
		if(shove_dir in GLOB.cardinals) //Directional checks to make sure that we're not shoving through a windoor or something like that
			var/target_turf = get_turf(src)
			for(var/obj/O in target_turf)
				if(O.flags_1 & ON_BORDER_1 && O.dir == shove_dir && O.density)
					directional_blocked = TRUE
					break
			if(target_turf != target_shove_turf) //Make sure that we don't run the exact same check twice on the same tile
				for(var/obj/O in target_shove_turf)
					if(O.flags_1 & ON_BORDER_1 && O.dir == turn(shove_dir, 180) && O.density)
						directional_blocked = TRUE
						break
		if((!target_table && !target_collateral_human && !target_disposal_bin && !target_pool && !IsKnockdown()) || directional_blocked)
			Knockdown(SHOVE_KNOCKDOWN_SOLID)
			Immobilize(SHOVE_IMMOBILIZE_SOLID)
			if (!silent)
				attacker.visible_message(span_danger("[attacker.name] shoves [name], knocking [p_them()] down!"),
					span_danger("You shove [name], knocking [p_them()] down!"), null, COMBAT_MESSAGE_RANGE)
			log_combat(attacker, src, "shoved", "disarm", "knocking them down")
		else if(target_table)
			Paralyze(SHOVE_KNOCKDOWN_TABLE)
			if (!silent)
				attacker.visible_message(span_danger("[attacker.name] shoves [name] onto \the [target_table]!"),
					span_danger("You shove [name] onto \the [target_table]!"), null, COMBAT_MESSAGE_RANGE)
			throw_at(target_table, 1, 1, null, FALSE) //1 speed throws with no spin are basically just forcemoves with a hard collision check
			log_combat(attacker, src, "shoved", "disarm", "onto [target_table] (table)")
		else if(target_collateral_human)
			Knockdown(SHOVE_KNOCKDOWN_HUMAN)
			target_collateral_human.Knockdown(SHOVE_KNOCKDOWN_COLLATERAL)
			if (!silent)
				attacker.visible_message(span_danger("[attacker.name] shoves [name] into [target_collateral_human.name]!"),
					span_danger("You shove [name] into [target_collateral_human.name]!"), null, COMBAT_MESSAGE_RANGE)
			log_combat(attacker, src, "shoved", "disarm", "into [target_collateral_human.name]")
		else if(target_disposal_bin)
			Knockdown(SHOVE_KNOCKDOWN_SOLID)
			forceMove(target_disposal_bin)
			if (!silent)
				attacker.visible_message(span_danger("[attacker.name] shoves [name] into \the [target_disposal_bin]!"),
					span_danger("You shove [name] into \the [target_disposal_bin]!"), null, COMBAT_MESSAGE_RANGE)
			log_combat(attacker, src, "shoved", "disarm", "into [target_disposal_bin] (disposal bin)")
		else if(target_pool)
			Knockdown(SHOVE_KNOCKDOWN_SOLID)
			forceMove(target_pool)
			if (!silent)
				attacker.visible_message(span_danger("[attacker.name] shoves [name] into \the [target_pool]!"),
					span_danger("You shove [name] into \the [target_pool]!"), null, COMBAT_MESSAGE_RANGE)
			log_combat(attacker, src, "shoved", "disarm", "into [target_pool] (swimming pool)")
	else
		if (!silent)
			attacker.visible_message(span_danger("[attacker.name] shoves [name]!"),
				span_danger("You shove [name]!"), null, COMBAT_MESSAGE_RANGE)
		log_combat(attacker, src, "shoved", "disarm")

/** Handles exposing a mob to reagents.
  *
  * If the method is INGEST the mob tastes the reagents.
  * If the method is VAPOR it incorporates permiability protection.
  */
/mob/living/expose_reagents(list/reagents, datum/reagents/source, method=TOUCH, volume_modifier=1, show_message=TRUE, obj/item/bodypart/affecting)
	if((. = ..()) & COMPONENT_NO_EXPOSE_REAGENTS)
		return

	if(method == INGEST)
		taste(source)

	var/touch_protection = (method == VAPOR) ? getarmor(null, BIO) * 0.01 : 0
	for(var/reagent in reagents)
		var/datum/reagent/R = reagent
		. |= R.expose_mob(src, method, reagents[R], show_message, touch_protection, affecting)
