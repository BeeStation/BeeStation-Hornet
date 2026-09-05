// Global list to store hit counts per mob per limb - defined using helper
GLOBAL_LIST_EMPTY(baton_hit_counts)

/obj/item/melee/baton
	name = "police baton"
	desc = "A wooden truncheon for beating criminal scum."
	desc_controls = "Left click to stun, right click to harm."
	icon = 'icons/obj/weapons/baton.dmi'
	icon_state = "classic_baton"
	inhand_icon_state = "classic_baton"
	worn_icon_state = "classic_baton"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	item_flags = ISWEAPON
	block_flags = BLOCKING_EFFORTLESS
	w_class = WEIGHT_CLASS_NORMAL

	custom_price = 100
	force = 10
	hitsound = 'sound/effects/woodhit.ogg' //Smack

	/// Whether this baton is active or not
	var/active = TRUE
	/// Used interally, you don't want to modify
	var/cooldown_check = 0
	// Default wait time until it can stun again.
	var/cooldown = (20)
	/// The length of the knockdown applied to a struck living, non-cyborg mob.
	var/knockdown_time = (1.5 SECONDS)
	/// If affect_cyborg is TRUE, this is how long we stun cyborgs for on a hit.
	var/stun_time_cyborg = (5 SECONDS)
	/// The length of the knockdown applied to the user on clumsy_check()
	var/clumsy_knockdown_time = 18 SECONDS
	/// How much stamina damage we deal on a successful hit against a living, non-cyborg mob.
	var/stamina_damage = 55
	/// Chance of causing force_say() when stunning a human mob
	var/force_say_chance = 33
	/// Can we stun cyborgs?
	var/affect_cyborg = FALSE
	/// The path of the default sound to play when we stun something.
	var/on_stun_sound = 'sound/effects/woodhit.ogg'
	/// The volume of the above.
	var/on_stun_volume = 75
	/// Do we animate the "hit" when stunning something?
	var/stun_animation = TRUE
	/// Whether the stun attack is logged. Only relevant for abductor batons, which have different modes.
	var/log_stun_attack = TRUE

	/// The context to show when the baton is active and targeting a living thing
	var/context_living_target_active = "Stun"

	/// The context to show when the baton is active and targeting a living thing in combat mode
	var/context_living_target_active_combat_mode = "Stun"

	/// The context to show when the baton is inactive and targeting a living thing
	var/context_living_target_inactive = "Prod"

	/// The context to show when the baton is inactive and targeting a living thing in combat mode
	var/context_living_target_inactive_combat_mode = "Attack"

	/// The RMB context to show when the baton is active and targeting a living thing
	var/context_living_rmb_active = "Attack"

	/// The RMB context to show when the baton is inactive and targeting a living thing
	var/context_living_rmb_inactive = "Attack"

/obj/item/melee/baton/Initialize(mapload)
	. = ..()
	// Adding an extra break for the sake of presentation
	if(stamina_damage != 0)
		offensive_notes = "It takes [span_warning("[ceil(100 / stamina_damage)] stunning hit\s")] to stun an enemy."

/**
 * Ok, think of baton attacks like a melee attack chain:
 *
 * [/baton_attack()] comes first. It checks if the user is clumsy, if the target parried the attack and handles some messages and sounds.
 * * Depending on its return value, it'll either do a normal attack, continue to the next step or stop the attack.
 *
 * [/finalize_baton_attack()] is then called. It handles logging stuff, sound effects and calls baton_effect().
 * * The proc is also called in other situations such as stunbatons right clicking or throw impact. Basically when baton_attack()
 * * checks are either redundant or unnecessary.
 *
 * [/baton_effect()] is third in the line. It knockdowns targets, along other effects called in additional_effects_cyborg() and
 * * additional_effects_non_cyborg().
 *
 * Last but not least [/set_batoned()], which gives the target the IWASBATONED trait with REF(user) as source and then removes it
 * * after a cooldown has passed. Basically, it stops users from cheesing the cooldowns by dual wielding batons.
 *
 * TL;DR: [/baton_attack()] -> [/finalize_baton_attack()] -> [/baton_effect()] -> [/set_batoned()]
 */
/obj/item/melee/baton/attack(mob/living/target, mob/living/user, params)
	add_fingerprint(user)
	var/list/modifiers = params2list(params)
	switch(baton_attack(target, user, modifiers))
		if(BATON_DO_NORMAL_ATTACK)
			return ..()
		if(BATON_ATTACKING)
			finalize_baton_attack(target, user, modifiers, in_attack_chain = TRUE, is_harm = LAZYACCESS(modifiers, RIGHT_CLICK))
		// else BATON_ATTACK_DONE -> do nothing

/obj/item/melee/baton/add_context_interaction(datum/screentip_context/context, mob/living/user, atom/target)
	if (isturf(target))
		return NONE

	if (isobj(target))
		context.add_left_click_action("Attack")
	else
		if (active)
			context.add_right_click_action(context_living_rmb_active)

			if (user.combat_mode)
				context.add_left_click_action(context_living_target_active_combat_mode)
			else
				context.add_left_click_action(context_living_target_active)
		else
			context.add_right_click_action(context_living_rmb_inactive)

			if (user.combat_mode)
				context.add_left_click_action(context_living_target_inactive_combat_mode)
			else
				context.add_left_click_action(context_living_target_inactive)

/obj/item/melee/baton/proc/baton_attack(mob/living/target, mob/living/user, modifiers)
	. = BATON_ATTACKING

	if(clumsy_check(user, target))
		return BATON_ATTACK_DONE

	// Inactive baton handling
	if(!active)
		if(LAZYACCESS(modifiers, RIGHT_CLICK))
			// Right-click while off -> normal attack
			return BATON_DO_NORMAL_ATTACK
		else
			// Left-click while off -> prod message, cancel attack
			target.visible_message(span_warning("[user] prods [target] with [src]. Luckily it was off."), \
				span_warning("[user] prods you with [src]. Luckily it was off."))
			return BATON_ATTACK_DONE

	// Active baton: both left and right click proceed with stun chain
	if(!COOLDOWN_FINISHED(src, cooldown_check))
		var/wait_desc = get_wait_description()
		if(wait_desc)
			to_chat(user, wait_desc)
		return BATON_ATTACK_DONE

	if(check_parried(target, user))
		return BATON_ATTACK_DONE

	if(HAS_TRAIT_FROM(target, TRAIT_IWASBATONED, REF(user)))
		to_chat(user, span_danger("You fumble and miss [target]!"))
		return BATON_ATTACK_DONE

	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.check_shields(src, 0, "[user]'s [name]", MELEE_ATTACK))
			return BATON_ATTACK_DONE
		if(check_martial_counter(H, user))
			log_combat(user, target, "attempted to attack", src, "(blocked by martial arts)")
			return BATON_ATTACK_DONE

	if(stun_animation)
		user.do_attack_animation(target)

	var/list/desc
	if(iscyborg(target))
		if(affect_cyborg)
			desc = get_cyborg_stun_description(target, user)
		else
			desc = get_unga_dunga_cyborg_stun_description(target, user)
			playsound(get_turf(src), 'sound/effects/bang.ogg', 10, TRUE)
			if(desc)
				target.visible_message(desc["visible"], desc["local"])
			return BATON_ATTACK_DONE
	else
		desc = get_stun_description(target, user)

	if(desc)
		target.visible_message(desc["visible"], desc["local"])

	// Return BATON_ATTACKING so the attack proc calls finalize_baton_attack
	// with the right click flag.
	return BATON_ATTACKING

/obj/item/melee/baton/proc/check_parried(mob/living/carbon/human/human_target, mob/living/user)
	if (istype(human_target) && human_target.check_block(src, 0, "[user]'s [name]", MELEE_ATTACK))
		playsound(human_target, 'sound/weapons/genhit.ogg', 50, TRUE)
		return TRUE
	return FALSE

/obj/item/melee/baton/proc/finalize_baton_attack(mob/living/target, mob/living/user, modifiers, in_attack_chain = TRUE, is_harm = FALSE)
	if(!in_attack_chain && HAS_TRAIT_FROM(target, TRAIT_IWASBATONED, REF(user)))
		return BATON_ATTACK_DONE

	COOLDOWN_START(src, cooldown_check, cooldown)
	if(on_stun_sound)
		playsound(get_turf(src), on_stun_sound, on_stun_volume, TRUE, -1)
	if(is_harm && stamina_damage > 0)
		playsound(get_turf(src), "swing_hit", on_stun_volume, TRUE, -1)
	if(user)
		target.lastattacker = user.real_name
		target.lastattackerckey = user.ckey
		if(log_stun_attack)
			log_combat(user, target, "stun attacked", src)
	if(baton_effect(target, user, modifiers) && user)
		set_batoned(target, user, cooldown)

	if(is_harm && stamina_damage > 0)
		var/brute_damage = force
		if(brute_damage > 0)
			var/zone = user ? user.get_combat_bodyzone(target) : BODY_ZONE_CHEST
			var/armor_brute = target.getarmor(MELEE, armour_penetration)
			target.apply_damage(brute_damage, BRUTE, zone, armor_brute)
			log_combat(user, target, "harmed", src)

	return BATON_ATTACK_DONE

/obj/item/melee/baton/proc/baton_effect(mob/living/target, mob/living/user, modifiers, stun_override)
	var/trait_check = HAS_TRAIT(target, TRAIT_BATON_RESISTANCE)

	if(iscyborg(target))
		if(!affect_cyborg)
			return FALSE

		target.flash_act(affect_silicon = TRUE)
		target.Paralyze((isnull(stun_override) ? stun_time_cyborg : stun_override) * (trait_check ? 0.1 : 1))
		additional_effects_cyborg(target, user)
		return TRUE
	else
		if(ishuman(target))
			var/mob/living/carbon/human/human_target = target
			if(prob(force_say_chance))
				human_target.force_say()

		// Non-cyborg: delegate to hook
		return baton_effect_non_cyborg(target, user, modifiers, stun_override, trait_check)

// =========================================================================
//  Hit counters using a global list (reliable)
// =========================================================================
/obj/item/melee/baton/proc/get_hit_count(mob/living/target, zone)
	var/ref = REF(target)
	if(!GLOB.baton_hit_counts[ref])
		GLOB.baton_hit_counts[ref] = list()
	return GLOB.baton_hit_counts[ref][zone] || 0

/obj/item/melee/baton/proc/increment_hit_count(mob/living/target, zone)
	var/ref = REF(target)
	if(!GLOB.baton_hit_counts[ref])
		GLOB.baton_hit_counts[ref] = list()
	var/current = GLOB.baton_hit_counts[ref][zone] || 0
	current++
	GLOB.baton_hit_counts[ref][zone] = current
	return current

/obj/item/melee/baton/proc/reset_hit_count(mob/living/target, zone)
	var/ref = REF(target)
	if(GLOB.baton_hit_counts[ref])
		GLOB.baton_hit_counts[ref] -= zone

/obj/item/melee/baton/proc/apply_limb_paralysis(mob/living/target, zone, duration = 5 SECONDS)
	var/is_wooden = (type == /obj/item/melee/baton)
	var/is_deputy = (type == /obj/item/melee/baton/deputy)
	var/is_electric = istype(src, /obj/item/melee/baton/security)

	if((is_wooden || is_deputy) && (zone != BODY_ZONE_L_ARM && zone != BODY_ZONE_R_ARM))
		return

	var/paralysis_trait
	switch(zone)
		if(BODY_ZONE_L_LEG)
			paralysis_trait = TRAIT_PARALYSIS_L_LEG
		if(BODY_ZONE_R_LEG)
			paralysis_trait = TRAIT_PARALYSIS_R_LEG
		if(BODY_ZONE_L_ARM)
			paralysis_trait = TRAIT_PARALYSIS_L_ARM
		if(BODY_ZONE_R_ARM)
			paralysis_trait = TRAIT_PARALYSIS_R_ARM
	if(!paralysis_trait)
		return

	var/hits = increment_hit_count(target, zone)
	var/paralyze = FALSE

	if(is_wooden)
		if(hits > 1 && prob(50))
			paralyze = TRUE
	else if(is_deputy)
		if(hits > 1 && prob(40))
			paralyze = TRUE
	else if(is_electric)
		if(hits == 2 && prob(75))
			paralyze = TRUE
		else if(hits >= 3)
			paralyze = TRUE

	if(paralyze)
		ADD_TRAIT(target, paralysis_trait, "baton_paralysis")
		addtimer(TRAIT_CALLBACK_REMOVE(target, paralysis_trait, "baton_paralysis"), duration)
		reset_hit_count(target, zone)
		to_chat(target, span_warning("Your [parse_zone(zone)] goes limp!"))

/obj/item/melee/baton/proc/baton_effect_non_cyborg(mob/living/target, mob/living/user, modifiers, stun_override, trait_check)
	var/zone = user ? user.get_combat_bodyzone(target) : BODY_ZONE_CHEST
	if(!zone)
		zone = BODY_ZONE_CHEST

	var/is_wooden_or_deputy = (type == /obj/item/melee/baton) || (type == /obj/item/melee/baton/deputy)
	var/is_electric = istype(src, /obj/item/melee/baton/security)

	// ----- LEGS -----
	if(zone == BODY_ZONE_L_LEG || zone == BODY_ZONE_R_LEG)
		if(is_wooden_or_deputy)
			if(!trait_check)
				target.Knockdown(knockdown_time)
			log_combat(user, target, "tripped", src)
		else if(is_electric)
			var/armor = target.getarmor(MELEE, armour_penetration)
			target.apply_damage(stamina_damage, STAMINA, zone, armor)
			apply_limb_paralysis(target, zone)
			log_combat(user, target, "stunned (legs)", src)
		else
			var/armor = target.getarmor(MELEE, armour_penetration)
			target.apply_damage(stamina_damage, STAMINA, zone, armor)
			log_combat(user, target, "stunned (legs)", src)

	// ----- ARMS -----
	else if(zone == BODY_ZONE_L_ARM || zone == BODY_ZONE_R_ARM)
		if(is_wooden_or_deputy || is_electric)
			var/armor = target.getarmor(MELEE, armour_penetration)
			target.apply_damage(stamina_damage, STAMINA, zone, armor)
			apply_limb_paralysis(target, zone)
			log_combat(user, target, "stunned (arm)", src)
		else
			var/armor = target.getarmor(MELEE, armour_penetration)
			target.apply_damage(stamina_damage, STAMINA, zone, armor)
			log_combat(user, target, "stunned (arm)", src)

	// ----- HEAD/CHEST -----
	else
		if(stamina_damage > 0)
			var/armor = target.getarmor(MELEE, armour_penetration)
			target.apply_damage(stamina_damage, STAMINA, zone, armor)
		log_combat(user, target, "stunned (torso/head)", src)

	// Note: brute damage is now applied in finalize_baton_attack for harm attacks

	additional_effects_non_cyborg(target, user)
	return TRUE

/// Description for trying to stun when still on cooldown.
/obj/item/melee/baton/proc/get_wait_description()
	return

// Default message for stunning mob.
/obj/item/melee/baton/proc/get_stun_description(mob/living/target, mob/living/user)
	. = list()

	.["visibletrip"] =  span_danger("[user] has knocked [target]'s legs out from under them with [src]!")
	.["localtrip"] = span_danger("[user] has knocked your legs out from under you with [src]!")
	.["visibleknockout"] =  span_danger("[user] has violently knocked out [target] with [src]!")
	.["localknockout"] = span_danger("[user] has beat you with such force on the head with [src] you fall unconscious...")
	.["visibledisarm"] =  span_danger("[user] has disarmed [target] with [src]!")
	.["localdisarm"] = span_danger("[user] whacks your arm with [src], causing a coursing pain!")
	.["visiblestun"] =  span_danger("[user] beat [target] with [src]!")
	.["localstun"] = span_danger("[user] has beat you with [src]!")
	.["visibleshead"] =  span_danger("[user] beat [target] on the head with [src]!")
	.["localhead"] = span_danger("[user] has beat your head with [src]!")
	.["visiblearm"] =  span_danger("[user] beat [target]'s arm with [src]!")
	.["localarm"] = span_danger("[user] has beat your arm with [src]!")
	.["visibleleg"] =  span_danger("[user] beat [target]'s leg with [src]!")
	.["localleg"] = span_danger("[user] has beat you in the leg with [src]!")
	.["visible"] = span_danger("[user] beats [target] with [src]!")
	.["local"] = span_danger("[user] beats you with [src]!")

	return .

/// Default message for stunning a cyborg.
/obj/item/melee/baton/proc/get_cyborg_stun_description(mob/living/target, mob/living/user)
	. = list()

	.["visible"] = span_danger("[user] pulses [target]'s sensors with the baton!")
	.["local"] = span_danger("You pulse [target]'s sensors with the baton!")

	return .

/// Default message for trying to stun a cyborg with a baton that can't stun cyborgs.
/obj/item/melee/baton/proc/get_unga_dunga_cyborg_stun_description(mob/living/target, mob/living/user)
	. = list()

	.["visible"] = span_danger("[user] tries to knock down [target] with [src], and predictably fails!") //look at this duuuuuude
	.["local"] = span_userdanger("[user] tries to... knock you down with [src]?") //look at the top of his head!

	return .

/// Contains any special effects that we apply to living, non-cyborg mobs we stun. Does not include applying a knockdown, dealing stamina damage, etc.
/obj/item/melee/baton/proc/additional_effects_non_cyborg(mob/living/target, mob/living/user)
	return

/// Contains any special effects that we apply to cyborgs we stun. Does not include flashing the cyborg's screen, hardstunning them, etc.
/obj/item/melee/baton/proc/additional_effects_cyborg(mob/living/target, mob/living/user)
	return

/obj/item/melee/baton/proc/set_batoned(mob/living/target, mob/living/user, cooldown)
	if(!cooldown)
		return
	var/user_ref = REF(user) // avoids harddels.
	ADD_TRAIT(target, TRAIT_IWASBATONED, user_ref)
	addtimer(TRAIT_CALLBACK_REMOVE(target, TRAIT_IWASBATONED, user_ref), cooldown)

/obj/item/melee/baton/proc/clumsy_check(mob/living/user, mob/living/intented_target)
	if(!active || !HAS_TRAIT(user, TRAIT_CLUMSY) || prob(50))
		return FALSE
	user.visible_message(
		span_danger("[user] accidentally hits [user.p_them()]self over the head with [src]! What a doofus!"),
		span_userdanger("You accidentally hit yourself over the head with [src]!")
	)
	user.adjustStaminaLoss(stamina_damage)

	if(iscyborg(user))
		if(affect_cyborg)
			user.flash_act(affect_silicon = TRUE)
			user.Paralyze(clumsy_knockdown_time)
			additional_effects_cyborg(user, user)
			if(on_stun_sound)
				playsound(get_turf(src), on_stun_sound, on_stun_volume, TRUE, -1)
		else
			playsound(get_turf(src), 'sound/effects/bang.ogg', 10, TRUE)
	else
		//straight up always force say for clumsy humans
		if(ishuman(user))
			var/mob/living/carbon/human/human_user = user
			human_user.force_say()
		user.Knockdown(clumsy_knockdown_time)
		user.apply_damage(stamina_damage, STAMINA, BODY_ZONE_HEAD)
		additional_effects_non_cyborg(user, user)
		if(on_stun_sound)
			playsound(get_turf(src), on_stun_sound, on_stun_volume, TRUE, -1)

	user.apply_damage(2*force, BRUTE, BODY_ZONE_HEAD)

	log_combat(user, user, "accidentally stun attacked [user.p_them()]self due to their clumsiness", src)
	if(stun_animation)
		user.do_attack_animation(user)
	return

/obj/item/melee/baton/deputy
	name = "deputy baton"
	force = 12
	cooldown = 10
	stamina_damage = 20
	stun_animation = TRUE
	custom_price = 120

/obj/item/conversion_kit
	name = "conversion kit"
	desc = "A strange box containing wood working tools and an instruction paper to turn stun batons into something else."
	icon = 'icons/obj/storage/box.dmi'
	icon_state = "uk"
	custom_price = PAYCHECK_COMMAND * 4.5

// =========================================================================
//  TELESCOPIC BATON
// =========================================================================
/obj/item/melee/baton/telescopic
	name = "telescopic baton"
	desc = "A compact and harmless personal defense weapon. Sturdy enough to knock the feet out from under attackers and robust enough to disarm with a quick strike to the hand"
	icon_state = "telebaton"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	inhand_icon_state = null
	attack_verb_continuous = list("hits", "pokes")
	attack_verb_simple = list("hit", "poke")
	worn_icon_state = "tele_baton"
	stamina_damage = 0   // No stamina damage
	stun_animation = FALSE
	slot_flags = ITEM_SLOT_BELT
	block_flags = BLOCKING_EFFORTLESS
	w_class = WEIGHT_CLASS_SMALL
	item_flags = ISWEAPON
	force = 0
	active = FALSE

	/// The sound effect played when our baton is extended.
	var/on_sound = 'sound/weapons/batonextend.ogg'
	/// The inhand iconstate used when our baton is extended.
	var/on_inhand_icon_state = "nullrod"
	/// The force on extension.
	var/active_force = 0

/obj/item/melee/baton/telescopic/Initialize(mapload)
	. = ..()
	AddComponent( \
		/datum/component/transforming, \
		force_on = active_force, \
		hitsound_on = hitsound, \
		w_class_on = WEIGHT_CLASS_BULKY, \
		clumsy_check = FALSE, \
		attack_verb_continuous_on = list("smacks", "strikes", "cracks", "beats"), \
		attack_verb_simple_on = list("smack", "strike", "crack", "beat"), \
	)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/obj/item/melee/baton/telescopic/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	if(active)
		return ..()
	return 0

/obj/item/melee/baton/telescopic/get_stun_description(mob/living/target, mob/living/user)
	. = ..() // gets your big list with visibletrip/localtrip/etc

	// Default to "stun" pair
	.["visible"] = .["visiblestun"]
	.["local"] = .["localstun"]

	// Called shot legs => trip pair
	if(!user.combat_mode && (user.is_zone_selected(BODY_ZONE_R_LEG) || user.is_zone_selected(BODY_ZONE_L_LEG)))
		.["visible"] = .["visibletrip"]
		.["local"] = .["localtrip"]
		return .

	// Arms => disarm pair
	// Use get_combat_bodyzone to match your effect logic
	var/zone = user.get_combat_bodyzone(target)
	if(!user.combat_mode && (zone == BODY_ZONE_L_ARM || zone == BODY_ZONE_R_ARM))
		.["visible"] = .["visibledisarm"]
		.["local"] = .["localdisarm"]

	return .

/obj/item/melee/baton/telescopic/suicide_act(mob/living/user)
	var/mob/living/carbon/human/H = user
	var/obj/item/organ/brain/B = H.get_organ_by_type(/obj/item/organ/brain)

	user.visible_message(span_suicide("[user] stuffs [src] up [user.p_their()] nose and presses the 'extend' button! It looks like [user.p_theyre()] trying to clear [user.p_their()] mind."))
	if(!active)
		src.attack_self(user)
	else
		playsound(src, on_sound, 50, 1)
		add_fingerprint(user)
	sleep(3)
	if (!QDELETED(H))
		if(!QDELETED(B))
			H.internal_organs -= B
			qdel(B)
		new /obj/effect/gibspawner/generic(H.drop_location(), H)
		return BRUTELOSS

/obj/item/melee/baton/telescopic/baton_effect_non_cyborg(mob/living/target, mob/living/user, modifiers, stun_override, trait_check)
	// Telescopic baton: No stamina damage, only trip on legs and disarm on arms.
	var/zone = user.get_combat_bodyzone(target)
	if(!zone)
		zone = BODY_ZONE_CHEST

	switch(zone)
		if(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
			// Legs: trip (knockdown only, no stamina)
			if(!trait_check)
				target.Knockdown(30)
			log_combat(user, target, "tripped", src)
		if(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
			// Disarm only the specific hand
			if(zone == BODY_ZONE_L_ARM)
				var/obj/item/held = target.get_item_for_held_index(LEFT_HANDS)
				if(held)
					target.dropItemToGround(held)
					log_combat(user, target, "disarmed (left hand)", src)
			else if(zone == BODY_ZONE_R_ARM)
				var/obj/item/held = target.get_item_for_held_index(RIGHT_HANDS)
				if(held)
					target.dropItemToGround(held)
					log_combat(user, target, "disarmed (right hand)", src)
		else
			// Head/Chest: no effect (harmless hit)
			log_combat(user, target, "lightly tapped", src)
			return TRUE

	additional_effects_non_cyborg(target, user)
	return TRUE

/*
 * Signal proc for [COMSIG_TRANSFORMING_ON_TRANSFORM].
 *
 * Gives feedback to the user and makes it show up inhand.
 */
/obj/item/melee/baton/telescopic/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	src.active = active
	inhand_icon_state = active ? on_inhand_icon_state : null // When inactive, there is no inhand icon_state.
	if(user)
		balloon_alert(user, active ? "extended" : "collapsed")
	playsound(src, on_sound, 50, TRUE)
	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/melee/baton/telescopic/contractor_baton
	name = "contractor baton"
	desc = "A compact, specialised baton assigned to Syndicate contractors. Applies light electric shocks that can resonate with a specific target's brain frequency causing significant stunning effects."
	icon_state = "contractor_baton"
	worn_icon_state = "contractor_baton"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY
	inhand_icon_state = null
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	item_flags = ISWEAPON
	force = 5
	var/datum/antagonist/traitor/owner_data = null

	force_say_chance = 80
	stamina_damage = 85
	affect_cyborg = TRUE
	on_sound = 'sound/weapons/contractorbatonextend.ogg'
	on_stun_sound = 'sound/effects/contractorbatonhit.ogg'
	stun_animation = TRUE

	on_inhand_icon_state = "contractor_baton_on"
	active_force = 10

/obj/item/melee/baton/telescopic/contractor_baton/get_wait_description()
	return span_danger("The baton is still charging!")

/obj/item/melee/baton/telescopic/contractor_baton/additional_effects_non_cyborg(mob/living/target, mob/living/user)
	target.set_jitter_if_lower(20 SECONDS)
	target.set_stutter_if_lower(20 SECONDS)

/obj/item/melee/baton/telescopic/contractor_baton/baton_attack(mob/living/target, mob/living/user, modifiers)
	if(!owner_data || owner_data?.owner?.current != user)
		return BATON_DO_NORMAL_ATTACK
	return ..()

/obj/item/melee/baton/telescopic/contractor_baton/get_stun_description(mob/living/target, mob/living/user)
	. = ..()

	var/targeted = owner_data?.contractor_hub?.current_contract?.contract?.target == target.mind
	if(targeted)
		.["visible"] = span_danger("[user] shocks [target] with [src], dropping [target.p_their()] guard completely!")
		.["local"] = span_userdanger("[user] shocks you with [src]—your body locks up!")
	else
		.["visible"] = span_danger("[user] zaps [target] with [src]!")
		.["local"] = span_userdanger("[user] zaps you with [src]!")

	return .

/obj/item/melee/baton/telescopic/contractor_baton/baton_effect_non_cyborg(mob/living/target, mob/living/user, modifiers, stun_override, trait_check)
	var/targeted = owner_data?.contractor_hub?.current_contract?.contract?.target == target.mind

	if(!trait_check)
		target.Knockdown(knockdown_time)

	if(targeted)
		target.drop_all_held_items()
		target.adjustStaminaLoss(stamina_damage)
		target.adjust_confusion_up_to(4 SECONDS, 6 SECONDS)
	else
		target.adjustStaminaLoss(max(stamina_damage - 30, 0))

	additional_effects_non_cyborg(target, user)

	log_combat(user, target, targeted ? "stunned (target)" : "stunned (non-target)", src)
	return TRUE

/obj/item/melee/baton/telescopic/contractor_baton/pickup(mob/user)
	..()
	if(!owner_data)
		var/datum/antagonist/traitor/traitor_data = user.mind?.has_antag_datum(/datum/antagonist/traitor)
		if(traitor_data)
			owner_data = traitor_data
			to_chat(user, span_notice("[src] scans your genetic data as you pick it up, creating an uplink with the syndicate database. Attacking your current target will stun them, however the baton is weak against non-targets."))

/obj/item/melee/baton/telescopic/contractor_baton/bounty
	name = "bounty hunter baton"
	desc = "A compact, specialised retractible stun baton assigned to bounty hunters."
	knockdown_time = (2 SECONDS)

// =========================================================================
//  SECURITY STUN BATON (electric) - Restored all original overrides except baton_attack
// =========================================================================
/obj/item/melee/baton/security
	name = "stun baton"
	desc = "A stun baton for incapacitating people with."
	desc_controls = "Left click to stun, right click to harm."
	icon_state = "stunbaton"
	inhand_icon_state = "baton"
	worn_icon_state = "baton"
	force = 8
	stamina_damage = 40
	cooldown = 0
	attack_verb_continuous = list("beats")
	attack_verb_simple = list("beat")
	armor_type = /datum/armor/melee_baton
	force_say_chance = 50
	// Default electrical sound for stunning (non-combat mode)
	on_stun_sound = 'sound/weapons/egloves.ogg'
	on_stun_volume = 50
	active = FALSE
	context_living_rmb_active = "Harmful Stun"
	light_range = 1.5
	light_system = MOVABLE_LIGHT
	light_on = FALSE
	light_color = LIGHT_COLOR_ORANGE
	light_power = 0.5

	var/throw_stun_chance = 35
	var/obj/item/stock_parts/cell/cell
	var/preload_cell_type //if not empty the baton starts with this type of cell
	var/cell_hit_cost = 10 KILOWATT
	var/can_remove_cell = TRUE
	var/convertible = TRUE //if it can be converted with a conversion kit

/datum/armor/melee_baton
	bomb = 50
	fire = 80
	acid = 80

/obj/item/melee/baton/security/Initialize(mapload)
	. = ..()
	if(preload_cell_type)
		if(!ispath(preload_cell_type, /obj/item/stock_parts/cell))
			log_mapping("[src] at [AREACOORD(src)] had an invalid preload_cell_type: [preload_cell_type].")
		else
			cell = new preload_cell_type(src)
	RegisterSignal(src, COMSIG_ATOM_ATTACKBY, PROC_REF(convert))
	update_appearance()

/obj/item/melee/baton/security/get_cell()
	return cell

/obj/item/melee/baton/security/suicide_act(mob/living/user)
	if(cell?.charge && active)
		user.visible_message(span_suicide("[user] is putting the live [name] in [user.p_their()] mouth! It looks like [user.p_theyre()] trying to commit suicide!"))
		attack(user, user)
		return FIRELOSS
	else
		user.visible_message(span_suicide("[user] is shoving the [name] down their throat! It looks like [user.p_theyre()] trying to commit suicide!"))
		return OXYLOSS

/obj/item/melee/baton/security/Destroy()
	if(cell)
		QDEL_NULL(cell)
	UnregisterSignal(src, COMSIG_ATOM_ATTACKBY)
	return ..()

/obj/item/melee/baton/security/proc/convert(datum/source, obj/item/item, mob/user)
	SIGNAL_HANDLER

	if(!istype(item, /obj/item/conversion_kit) || !convertible)
		return
	var/turf/source_turf = get_turf(src)
	var/obj/item/melee/baton/baton = new (source_turf)
	baton.alpha = 20
	playsound(source_turf, 'sound/items/drill_use.ogg', 80, TRUE, -1)
	animate(src, alpha = 0, time = 1 SECONDS)
	animate(baton, alpha = 255, time = 1 SECONDS)
	qdel(item)
	qdel(src)

/obj/item/melee/baton/security/Exited(atom/movable/mov_content)
	. = ..()
	if(mov_content == cell)
		cell.update_appearance()
		cell = null
		active = FALSE
		update_appearance()

/obj/item/melee/baton/security/update_icon_state()
	if(active)
		icon_state = "[initial(icon_state)]_active"
		return ..()
	if(!cell)
		icon_state = "[initial(icon_state)]_nocell"
		return ..()
	icon_state = "[initial(icon_state)]"
	return ..()

/obj/item/melee/baton/security/examine(mob/user)
	. = ..()
	if(cell)
		. += span_notice("\The [src] has [floor(cell.charge / cell_hit_cost)] remaining uses.")
	else
		. += span_warning("\The [src] does not have a power source installed.")

/obj/item/melee/baton/security/screwdriver_act(mob/living/user, obj/item/tool)
	if(tryremovecell(user))
		tool.play_tool_sound(src)
	return TRUE

/obj/item/melee/baton/security/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/active_cell = item
		if(cell)
			to_chat(user, span_warning("[src] already has a cell!"))
		else
			if(active_cell.maxcharge < cell_hit_cost)
				to_chat(user, span_notice("[src] requires a higher capacity cell."))
				return
			if(!user.transferItemToLoc(item, src))
				return
			cell = item
			to_chat(user, span_notice("You install a cell in [src]."))
			update_appearance()
	else
		return ..()

/obj/item/melee/baton/security/proc/tryremovecell(mob/user)
	if(cell && can_remove_cell)
		cell.forceMove(drop_location())
		to_chat(user, span_notice("You remove the cell from [src]."))
		if(active)
			//Good one, idiot
			attack_self()
		return TRUE
	return FALSE

/obj/item/melee/baton/security/attack_self(mob/user)
	if(cell?.charge >= cell_hit_cost)
		active = !active
		balloon_alert(user, "turned [active ? "on" : "off"]")
		playsound(src, "sparks", 75, TRUE, -1)
		toggle_light(user)
		do_sparks(1, TRUE, src)
		if(active)
			hitsound = "swing_hit"
		else
			hitsound = "swing_hit"
	else
		active = FALSE
		if(!cell)
			balloon_alert(user, "no power source!")
		else
			balloon_alert(user, "out of charge!")
		hitsound = "swing_hit"
	update_appearance()
	add_fingerprint(user)

/// Toggles the stun baton's light
/obj/item/melee/baton/security/proc/toggle_light(mob/user)
	set_light_on(!light_on)
	return

/obj/item/melee/baton/security/proc/deductcharge(deducted_charge)
	if(!cell)
		return
	//Note this value returned is significant, as it will determine
	//if a stun is applied or not
	. = cell.use(deducted_charge)
	if(active && cell.charge < cell_hit_cost)
		//we're below minimum, turn off
		active = FALSE
		set_light_on(FALSE)
		update_appearance()
		playsound(src, "sparks", 75, TRUE, -1)
		hitsound = "swing_hit"

// Override baton_effect to handle cell usage and special cases
/obj/item/melee/baton/security/baton_effect(mob/living/target, mob/living/user, modifiers, stun_override)
	if(iscyborg(loc))
		var/mob/living/silicon/robot/robot = loc
		if(!robot || !robot.cell || !robot.cell.use(cell_hit_cost))
			return FALSE
	else if(!deductcharge(cell_hit_cost))
		return FALSE

	// For cyborgs, use parent behavior (they get stunned)
	if(iscyborg(target))
		return ..()

	var/trait_check = HAS_TRAIT(target, TRAIT_BATON_RESISTANCE)
	return baton_effect_non_cyborg(target, user, modifiers, stun_override, trait_check)

// Override for security baton: no knockdown, but still zone-specific stamina damage
/obj/item/melee/baton/security/baton_effect_non_cyborg(mob/living/target, mob/living/user, modifiers, stun_override, trait_check)
	// Special handling for stamina-immune limbs
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/target_zone = user ? user.get_combat_bodyzone(H) : target.get_random_valid_zone()
		var/obj/item/bodypart/affecting = H.get_bodypart(target_zone)
		if(!affecting)
			affecting = H.bodyparts[1]

		// Check if the limb is stamina-immune
		if(affecting && affecting.stamina_modifier == 0)
			// take burn damage from electrical shock instead of stamina
			var/armor_block = H.run_armor_check(affecting, STAMINA, armour_penetration = armour_penetration)

			// Electrocute and deal burn damage (force/4)
			H.electrocute_act(1, src, flags = SHOCK_NOGLOVES|SHOCK_NOSTUN)
			H.apply_damage(force/4, BURN, affecting, armor_block)

			// Still apply effects and signals
			if(stun_animation)
				target.do_stun_animation(target)
			SEND_SIGNAL(target, COMSIG_LIVING_MINOR_SHOCK)
			additional_effects_non_cyborg(target, user)
			return TRUE

	var/zone = user ? user.get_combat_bodyzone(target) : BODY_ZONE_CHEST
	if(!zone)
		zone = BODY_ZONE_CHEST

	// Apply stamina damage to the specific zone
	var/armor = target.getarmor(MELEE, armour_penetration)
	target.apply_damage(stamina_damage, STAMINA, zone, armor)

	// Apply paralysis on legs and arms (head/chest no paralysis)
	if(zone == BODY_ZONE_L_LEG || zone == BODY_ZONE_R_LEG || zone == BODY_ZONE_L_ARM || zone == BODY_ZONE_R_ARM)
		apply_limb_paralysis(target, zone)

	if(stun_animation)
		target.do_stun_animation(target)
	SEND_SIGNAL(target, COMSIG_LIVING_MINOR_SHOCK)

	additional_effects_non_cyborg(target, user)
	return TRUE

/*
 * Additional effects after stamina damage.
 * For stun batons, this is minimal - just a brief trait to prevent rapid double-batoning.
 */
/obj/item/melee/baton/security/additional_effects_non_cyborg(mob/living/target, mob/living/user)
	// Brief anti-double-baton trait (0.75 second)
	var/user_ref = REF(user)
	ADD_TRAIT(target, TRAIT_IWASBATONED, user_ref)
	addtimer(TRAIT_CALLBACK_REMOVE(target, TRAIT_IWASBATONED, user_ref), 0.75 SECONDS)

/obj/item/melee/baton/security/get_wait_description()
	if(!cell)
		return span_warning("[src] does not have a power source!")
	if(cell.charge < cell_hit_cost)
		return span_warning("[src] is out of charge.")
	return span_danger("The baton is still charging!") // Shouldn't happen with cooldown=0

/obj/item/melee/baton/security/get_stun_description(mob/living/target, mob/living/user)
	. = list()

	.["visible"] = span_danger("[user] stuns [target] with [src]!")
	.["local"] = span_userdanger("[user] stuns you with [src]!")

/obj/item/melee/baton/security/get_unga_dunga_cyborg_stun_description(mob/living/target, mob/living/user)
	. = list()

	.["visible"] = span_danger("[user] tries to stun [target] with [src], and predictably fails!")
	.["local"] = span_userdanger("[user] tries to... stun you with [src]?")

/obj/item/melee/baton/security/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	//base 35% success chance if you throw it
	if(!. && active && prob(throw_stun_chance) && isliving(hit_atom))
		finalize_baton_attack(hit_atom, thrownby?.resolve(), in_attack_chain = FALSE, is_harm = FALSE)

/obj/item/melee/baton/security/emp_act(severity)
	. = ..()
	if (!cell)
		return
	if (!(. & EMP_PROTECT_SELF))
		deductcharge(cell.charge)
	if (cell.charge >= cell_hit_cost)
		var/scramble_time
		scramble_mode()
		for(var/loops in 1 to rand(6, 12))
			scramble_time = rand(5, 15) / (1 SECONDS)
			addtimer(CALLBACK(src, PROC_REF(scramble_mode)), scramble_time*loops * (1 SECONDS))

/obj/item/melee/baton/security/proc/scramble_mode()
	if (!cell || cell.charge < cell_hit_cost)
		return
	active = !active
	toggle_light()
	do_sparks(1, TRUE, src)
	playsound(src, "sparks", 75, TRUE, -1)
	update_appearance()

//This one starts with a cell pre-installed.
/obj/item/melee/baton/security/loaded
	preload_cell_type = /obj/item/stock_parts/cell/high

/obj/item/melee/baton/security/cattleprod
	name = "stunprod"
	desc = "An improvised stun baton."
	desc_controls = "Left click to stun, right click to harm."
	icon = 'icons/obj/weapons/spear.dmi'
	icon_state = "stunprod"
	inhand_icon_state = "prod"
	worn_icon_state = null
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	force = 3
	throwforce = 5
	custom_price = 25
	cell_hit_cost = 20 KILOWATT
	slot_flags = ITEM_SLOT_BACK
	convertible = FALSE
	var/obj/item/assembly/igniter/sparkler
	///Determines whether or not we can improve the cattleprod into a new type. Prevents turning the cattleprod subtypes into different subtypes, or wasting materials on making it....another version of itself.
	var/can_upgrade = TRUE

/obj/item/melee/baton/security/cattleprod/Initialize(mapload)
	. = ..()
	sparkler = new (src)

/obj/item/melee/baton/security/cattleprod/attackby(obj/item/item, mob/user, params)//handles sticking a crystal onto a stunprod to make a teleprod
	if(!istype(item, /obj/item/stack))
		return ..()

	if(!can_upgrade)
		user.visible_message(span_warning("This prod is already improved!"))
		return ..()

	if(cell)
		user.visible_message(span_warning("You can't put the crystal onto the stunprod while it has a power cell installed!"))
		return ..()

	var/our_prod
	if(istype(item, /obj/item/stack/ore/bluespace_crystal))
		var/obj/item/stack/ore/bluespace_crystal/our_crystal = item
		our_crystal.use(1)
		our_prod = /obj/item/melee/baton/security/cattleprod/teleprod

	else
		to_chat(user, span_notice("You don't think the [item.name] will do anything to improve the [src]."))
		return ..()

	to_chat(user, span_notice("You place the [item.name] firmly into the igniter."))
	remove_item_from_storage(user)
	qdel(src)
	var/obj/item/melee/baton/security/cattleprod/brand_new_prod = new our_prod(user.loc)
	user.put_in_hands(brand_new_prod)
	log_crafting(user, brand_new_prod, TRUE)

/obj/item/melee/baton/security/cattleprod/baton_effect()
	if(!sparkler.activate())
		return BATON_ATTACK_DONE
	return ..()

/obj/item/melee/baton/security/cattleprod/Destroy()
	if(sparkler)
		QDEL_NULL(sparkler)
	return ..()

/obj/item/melee/baton/security/cattleprod/teleprod
	name = "teleprod"
	desc = "A prod with a bluespace crystal on the end. The crystal doesn't look too fun to touch."
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "teleprod"
	inhand_icon_state = "teleprod"
	canblock = TRUE
	block_flags = BLOCKING_ACTIVE | BLOCKING_COUNTERATTACK
	block_power = 50

/obj/item/melee/baton/security/cattleprod/teleprod/baton_effect(mob/living/target, mob/living/user, modifiers, stun_override)
	. = ..()
	if(!. || target.move_resist >= MOVE_FORCE_OVERPOWERING)
		return
	do_teleport(target, get_turf(target), 15, channel = TELEPORT_CHANNEL_BLUESPACE)
