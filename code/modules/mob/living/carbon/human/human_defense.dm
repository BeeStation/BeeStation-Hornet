/mob/living/carbon/human/getarmor(def_zone, type, penetration)
	var/armorval = 0
	var/organnum = 0

	if(def_zone)
		if(isbodypart(def_zone))
			var/obj/item/bodypart/bp = def_zone
			if(bp)
				return checkarmor(def_zone, type, penetration)
		var/obj/item/bodypart/affecting = get_bodypart(check_zone(def_zone))
		if(affecting)
			return checkarmor(affecting, type, penetration)
		//If a specific bodypart is targetted, check how that bodypart is protected and return the value.

	//If you don't specify a bodypart, it checks ALL your bodyparts for protection, and averages out the values
	for(var/obj/item/bodypart/BP as() in bodyparts)
		armorval += checkarmor(BP, type, penetration)
		organnum++
	return (armorval/max(organnum, 1))

/// Check the armour for a specified bodyzone and damagetype.
/// Returns a value with 0 representing 0% protection and 100 representing 100% protection.
/// 50 + 50 = (1 - (1 * 0.5 * 0.5) = 75%)
/// 100 + 50 = (1 - (1 * 0 * 0.5) = 100%)
/// 50 + (-50) = (1 - (1 * 0.5 * 1.5) = 25%)
/// 100 + (-50) = (1 - (1 * 0 * 1.5) = 100%)
/// -50 = (1 - (1 * 1.5) = -50%)
/// Any armour that exceeds 100% protection will be clamped down to 100%
/// Input armour values should never exceed 100%, or be at 100% as 100% represents
/// full protection outside of armour penetration.
/// The penetration value will affect the armour value for each individual armour peice directly,
/// before it is clamped to 100%. This means that an armour of 130% with a penetration of 20% will become
/// an armour value of 130 - (130 * 0.2) = 104% ~= 100%.
/mob/living/carbon/human/proc/checkarmor(obj/item/bodypart/def_zone, d_type, penetration)
	if(!d_type)
		return 0
	var/protection = 1
	var/list/body_parts = list(head, wear_mask, wear_suit, w_uniform, back, gloves, shoes, belt, s_store, glasses, ears, wear_id, wear_neck) //Everything but pockets. Pockets are l_store and r_store. (if pockets were allowed, putting something armored, gloves or hats for example, would double up on the armor)
	for(var/bp in body_parts)
		if(!bp)
			continue
		if(bp && isclothing(bp))
			var/obj/item/clothing/C = bp
			if(C.body_parts_covered & def_zone.body_part)
				protection *= 1 - min((C.get_armor_rating(d_type) / 100) * (1 - (penetration / 100)), 1)

	protection *= 1 - CLAMP01(physiology.physio_armor.get_rating(d_type) / 100)
	return (1 - protection) * 100

///Get all the clothing on a specific body part
/mob/living/carbon/human/proc/clothingonpart(obj/item/bodypart/def_zone)
	var/list/covering_part = list()
	var/list/body_parts = list(head, wear_mask, wear_suit, w_uniform, back, gloves, shoes, belt, s_store, glasses, ears, wear_id, wear_neck) //Everything but pockets. Pockets are l_store and r_store. (if pockets were allowed, putting something armored, gloves or hats for example, would double up on the armor)
	for(var/bp in body_parts)
		if(!bp)
			continue
		if(bp && istype(bp , /obj/item/clothing))
			var/obj/item/clothing/C = bp
			if(C.body_parts_covered & def_zone.body_part)
				covering_part += C
	return covering_part

/mob/living/carbon/human/on_hit(obj/projectile/P)
	if(dna?.species)
		dna.species.on_hit(P, src)


/mob/living/carbon/human/bullet_act(obj/projectile/P, def_zone, piercing_hit = FALSE)
	if(dna && dna.species)
		var/spec_return = dna.species.bullet_act(P, src)
		if(spec_return)
			return spec_return

	//MARTIAL ART STUFF
	if(mind)
		if(mind.martial_art && mind.martial_art.can_use(src)) //Some martial arts users can deflect projectiles!
			var/martial_art_result = mind.martial_art.on_projectile_hit(src, P, def_zone)
			if(!(martial_art_result == BULLET_ACT_HIT))
				return martial_art_result

	if(!(P.original == src && P.firer == src)) //can't block or reflect when shooting yourself
		if(P.reflectable & REFLECT_NORMAL)
			if(check_reflect(def_zone)) // Checks if you've passed a reflection% check
				visible_message(span_danger("The [P.name] gets reflected by [src]!"), \
								span_userdanger("The [P.name] gets reflected by [src]!"))
				// Find a turf near or on the original location to bounce to
				if(!isturf(loc)) //Open canopy mech (ripley) check. if we're inside something and still got hit
					P.force_hit = TRUE //The thing we're in passed the bullet to us. Pass it back, and tell it to take the damage.
					loc.bullet_act(P, def_zone, piercing_hit)
					return BULLET_ACT_HIT
				if(P.starting)
					var/new_x = P.starting.x + pick(0, 0, 0, 0, 0, -1, 1, -2, 2)
					var/new_y = P.starting.y + pick(0, 0, 0, 0, 0, -1, 1, -2, 2)
					var/turf/current_location = get_turf(src)

					// redirect the projectile
					P.original = locate(new_x, new_y, P.z)
					P.starting = current_location
					P.firer = src
					P.yo = new_y - current_location.y
					P.xo = new_x - current_location.x
					var/new_angle_s = P.Angle + rand(120,240)
					while(new_angle_s > 180)	// Translate to regular projectile degrees
						new_angle_s -= 360
					P.set_angle(new_angle_s)

				return BULLET_ACT_FORCE_PIERCE // complete projectile permutation

		if(check_shields(P, P.damage, "the [P.name]", PROJECTILE_ATTACK, P.armour_penetration))
			P.on_hit(src, 100, def_zone, piercing_hit)
			return BULLET_ACT_HIT

	return ..()

/mob/living/carbon/human/proc/check_reflect(def_zone) //Reflection checks for anything in your l_hand, r_hand, or wear_suit based on the reflection chance of the object
	if(wear_suit)
		if(wear_suit.IsReflect(def_zone, src) == 1)
			return 1
	for(var/obj/item/I in held_items)
		if(I.IsReflect(def_zone, src) == 1)
			return 1
	return 0

/mob/living/carbon/human/proc/check_shields(atom/AM, var/damage, attack_text = "the attack", attack_type = MELEE_ATTACK, armour_penetration = 0)
	SEND_SIGNAL(src, COMSIG_HUMAN_ATTACKED, AM, attack_text, damage, attack_type, armour_penetration)
	for(var/obj/item/I in held_items)
		if(!isclothing(I))
			if(I.hit_reaction(src, AM, attack_text, damage, attack_type))
				I.on_block(src, AM, attack_text, damage, attack_type)
				return 1
	if(wear_suit?.hit_reaction(src, AM, attack_text, damage, attack_type))
		return TRUE
	if(w_uniform?.hit_reaction(src, AM, attack_text, damage, attack_type))
		return TRUE
	if(wear_neck?.hit_reaction(src, AM, attack_text, damage, attack_type))
		return TRUE
	if(belt?.hit_reaction(src, AM, attack_text, damage, attack_type))
		return TRUE
	return FALSE

/mob/living/carbon/human/hitby(atom/movable/AM, skipcatch = FALSE, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	if(dna && dna.species)
		var/spec_return = dna.species.spec_hitby(AM, src)
		if(spec_return)
			return spec_return
	var/obj/item/I
	var/throwpower = 30
	if(istype(AM, /obj/item))
		I = AM
		throwpower = I.throwforce
		if(I.thrownby == WEAKREF(src)) //No throwing stuff at yourself to trigger hit reactions
			return ..()
	if(check_shields(AM, throwpower, "\the [AM.name]", THROWN_PROJECTILE_ATTACK))
		hitpush = FALSE
		skipcatch = TRUE
		blocked = TRUE

	return ..(AM, skipcatch, hitpush, blocked, throwingdatum)

/mob/living/carbon/human/grippedby(mob/living/user, instant = FALSE)
	if(w_uniform)
		w_uniform.add_fingerprint(user)
	..()


/mob/living/carbon/human/attacked_by(obj/item/I, mob/living/user)
	if(!I || !user)
		return FALSE

	var/obj/item/bodypart/affecting
	if(user == src)
		affecting = get_bodypart(check_zone(user.get_combat_bodyzone(src))) //stabbing yourself always hits the right target
	else
		affecting = get_bodypart(ran_zone(user.get_combat_bodyzone(src)))
	var/target_area = parse_zone(check_zone(user.get_combat_bodyzone(src))) //our intended target
	if(affecting)
		if(I.force && I.damtype != STAMINA && (!IS_ORGANIC_LIMB(affecting))) // Bodpart_robotic sparks when hit, but only when it does real damage
			if(I.force >= 5)
				do_sparks(1, FALSE, loc)
				if(prob(25))
					new /obj/effect/decal/cleanable/oil(loc)

	SEND_SIGNAL(I, COMSIG_ITEM_ATTACK_ZONE, src, user, affecting)

	SSblackbox.record_feedback("nested tally", "item_used_for_combat", 1, list("[I.force]", "[I.type]"))
	SSblackbox.record_feedback("tally", "zone_targeted", 1, target_area)

	// the attacked_by code varies among species
	return dna.species.spec_attacked_by(I, user, affecting, src)


/mob/living/carbon/human/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)
	if(user.combat_mode)
		var/hulk_verb = pick("smash","pummel")
		if(check_shields(user, 15, "the [hulk_verb]ing"))
			return
		..(user, 1)
		playsound(loc, user.dna.species.attack_sound, 25, TRUE, -1)
		visible_message(span_danger("[user] [hulk_verb]ed [src]!"), \
					span_userdanger("[user] [hulk_verb]ed [src]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), null, user)
		to_chat(user, span_danger("You [hulk_verb] [src]!"))
		var/obj/item/bodypart/affecting = get_bodypart(ran_zone(user.get_combat_bodyzone(src)))
		if(!affecting)
			affecting = get_bodypart(BODY_ZONE_CHEST)
		var/armor_block = run_armor_check(affecting, MELEE,"","",10)
		apply_damage(20, BRUTE, affecting, armor_block)
		return 1

/mob/living/carbon/human/attack_hand(mob/user, modifiers)
	if(..())	//to allow surgery to return properly.
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.dna.species.spec_attack_hand(H, src, null, modifiers)

/mob/living/carbon/human/attack_paw(mob/living/carbon/monkey/user, list/modifiers)
	if(check_shields(user, 0, "the [user.name]", UNARMED_ATTACK))
		visible_message(span_danger("[user] attempts to touch [src]!"), \
						span_danger("[user] attempts to touch you!"), span_hear("You hear a swoosh!"), null, user)
		to_chat(user, span_warning("You attempt to touch [src]!"))
		return 0
	var/dam_zone = pick(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/obj/item/bodypart/affecting = get_bodypart(ran_zone(dam_zone))
	if(!affecting)
		affecting = get_bodypart(BODY_ZONE_CHEST)

	var/martial_result = user.apply_martial_art(src, modifiers)
	if (martial_result != MARTIAL_ATTACK_INVALID)
		return martial_result

	if(LAZYACCESS(modifiers, RIGHT_CLICK)) //Always drop item in hand, if no item, get stunned instead.
		dna.species.disarm(user, src)
		return TRUE

	if(!user.combat_mode)
		..() //shaking
		return FALSE

	if(user.limb_destroyer)
		dismembering_strike(user, affecting.body_zone)

	if(try_inject(user, affecting, injection_flags = INJECT_TRY_SHOW_ERROR_MESSAGE))//Thick suits can stop monkey bites.
		if(..()) //successful monkey bite, this handles disease contraction.
			var/damage = rand(1, 3)
			if(stat != DEAD)
				apply_damage(damage, BRUTE, affecting, run_armor_check(affecting, MELEE))
		return TRUE

/mob/living/carbon/human/attack_alien(mob/living/carbon/alien/humanoid/M, list/modifiers)
	if(check_shields(M, 20, "the [M.name]", UNARMED_ATTACK))
		visible_message("<span class='danger'>[M] attempts to touch [src]!</span>", \
						"<span class='danger'>[M] attempts to touch you!</span>", "<span class='hear'>You hear a swoosh!</span>", null, M)
		to_chat(M, "<span class='warning'>You attempt to touch [src]!</span>")
		return FALSE
	. = ..()
	if(!.)
		return

	if(LAZYACCESS(modifiers, RIGHT_CLICK)) //Always drop item in hand, if no item, get stun instead.
		var/obj/item/I = get_active_held_item()
		if(I && dropItemToGround(I))
			playsound(loc, 'sound/weapons/slash.ogg', 25, TRUE, -1)
			visible_message("<span class='danger'>[M] disarms [src]!</span>", \
							"<span class='userdanger'>[M] disarms you!</span>", "<span class='hear'>You hear aggressive shuffling!</span>", null, M)
			to_chat(M, "<span class='danger'>You disarm [src]!</span>")
		else
			playsound(loc, 'sound/weapons/pierce.ogg', 25, TRUE, -1)
			Paralyze(100)
			log_combat(M, src, "tackled")
			visible_message("<span class='danger'>[M] tackles [src] down!</span>", \
							"<span class='userdanger'>[M] tackles you down!</span>", "<span class='hear'>You hear aggressive shuffling followed by a loud thud!</span>", null, M)
			to_chat(M, "<span class='danger'>You tackle [src] down!</span>")
		return TRUE

	if(M.combat_mode)
		if (w_uniform)
			w_uniform.add_fingerprint(M)
		var/obj/item/bodypart/affecting = get_bodypart(ran_zone(M.get_combat_bodyzone(src)))
		if(!affecting)
			affecting = get_bodypart(BODY_ZONE_CHEST)
		var/armor_block = run_armor_check(affecting, MELEE,"","",10)

		playsound(loc, 'sound/weapons/slice.ogg', 25, TRUE, -1)
		visible_message("<span class='danger'>[M] slashes at [src]!</span>", \
						"<span class='userdanger'>[M] slashes at you!</span>", "<span class='hear'>You hear a sickening sound of a slice!</span>", null, M)
		to_chat(M, "<span class='danger'>You slash at [src]!</span>")
		log_combat(M, src, "attacked", M)
		if(!dismembering_strike(M, M.get_combat_bodyzone(src))) //Dismemberment successful
			return TRUE
		apply_damage(20, BRUTE, affecting, armor_block)


/mob/living/carbon/human/attack_larva(mob/living/carbon/alien/larva/L, list/modifiers)
	if(..()) //successful larva bite.
		var/damage = rand(1, 3)
		if(check_shields(L, damage, "the [L.name]"))
			return 0
		if(stat != DEAD)
			L.amount_grown = min(L.amount_grown + damage, L.max_grown)
			var/obj/item/bodypart/affecting = get_bodypart(ran_zone(L.get_combat_bodyzone(src)))
			if(!affecting)
				affecting = get_bodypart(BODY_ZONE_CHEST)
			var/armor_block = run_armor_check(affecting, MELEE)
			apply_damage(damage, BRUTE, affecting, armor_block)

/mob/living/carbon/human/attack_slime(mob/living/simple_animal/slime/M, list/modifiers)
	if(..()) //successful slime attack
		var/damage = 20
		if(M.is_adult)
			damage = 30

		if(M.transformeffects & SLIME_EFFECT_RED)
			damage *= 1.1

		if(check_shields(M, damage, "the [M.name]"))
			return FALSE

		var/dam_zone = dismembering_strike(M, pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		if(!dam_zone) //Dismemberment successful
			return TRUE

		var/obj/item/bodypart/affecting = get_bodypart(ran_zone(dam_zone))
		if(!affecting)
			affecting = get_bodypart(BODY_ZONE_CHEST)
		var/armor_block = run_armor_check(affecting, MELEE)
		apply_damage(damage, BRUTE, affecting, armor_block)

/mob/living/carbon/human/ex_act(severity, target, origin)
	if(TRAIT_BOMBIMMUNE in dna.species.species_traits)
		return
	..()
	if (!severity || QDELETED(src))
		return
	var/brute_loss = 0
	var/burn_loss = 0
	var/bomb_armor = getarmor(null, BOMB)

//200 max knockdown for EXPLODE_HEAVY
//160 max knockdown for EXPLODE_LIGHT


	switch (severity)
		if (EXPLODE_DEVASTATE)
			if(bomb_armor < EXPLODE_GIB_THRESHOLD) //gibs the mob if their bomb armor is lower than EXPLODE_GIB_THRESHOLD
				for(var/thing in contents)
					switch(severity)
						if(EXPLODE_DEVASTATE)
							SSexplosions.high_mov_atom += thing
						if(EXPLODE_HEAVY)
							SSexplosions.med_mov_atom += thing
						if(EXPLODE_LIGHT)
							SSexplosions.low_mov_atom += thing
				investigate_log("has been gibbed by an explosion.", INVESTIGATE_DEATHS)
				gib()
				return
			else
				brute_loss = 500
				var/atom/throw_target = get_edge_target_turf(src, get_dir(src, get_step_away(src, src)))
				throw_at(throw_target, 200, 4)
				damage_clothes(400 - bomb_armor, BRUTE, BOMB)

		if (EXPLODE_HEAVY)
			brute_loss = 60
			burn_loss = 60
			damage_clothes(200 - bomb_armor, BRUTE, BOMB)
			if (!istype(ears, /obj/item/clothing/ears/earmuffs))
				adjustEarDamage(30, 120)
			Unconscious(20)							//short amount of time for follow up attacks against elusive enemies like wizards
			Knockdown(200 - (bomb_armor * 1.6)) 	//between ~4 and ~20 seconds of knockdown depending on bomb armor

		if(EXPLODE_LIGHT)
			brute_loss = 30
			burn_loss = 10
			damage_clothes(max(50 - bomb_armor, 0), BRUTE, BOMB)
			if (!istype(ears, /obj/item/clothing/ears/earmuffs))
				adjustEarDamage(15,60)
			Knockdown(160 - (bomb_armor * 1.6))		//100 bomb armor will prevent knockdown altogether

	apply_damage(brute_loss, BRUTE, blocked = (bomb_armor * 0.6))
	apply_damage(burn_loss, BURN, blocked = (bomb_armor * 0.6))

	//attempt to dismember bodyparts
	if(severity >= EXPLODE_HEAVY || !bomb_armor)
		var/max_limb_loss = 0
		var/probability = 0
		switch(severity)
			if(EXPLODE_HEAVY)
				max_limb_loss = 3
				probability = 40
			if(EXPLODE_DEVASTATE)
				max_limb_loss = 4
				probability = 50
		for(var/obj/item/bodypart/BP as() in bodyparts)
			if(prob(probability) && !prob(getarmor(BP, BOMB)) && BP.body_zone != BODY_ZONE_HEAD && BP.body_zone != BODY_ZONE_CHEST)
				BP.brute_dam = BP.max_damage
				BP.dismember()
				max_limb_loss--
				if(!max_limb_loss)
					break


/mob/living/carbon/human/blob_act(obj/structure/blob/B)
	if(stat == DEAD)
		return
	show_message(span_userdanger("The blob attacks you!"))
	var/dam_zone = pick(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/obj/item/bodypart/affecting = get_bodypart(ran_zone(dam_zone))
	apply_damage(5, BRUTE, affecting, run_armor_check(affecting, MELEE))


///Calculates the siemens coeff based on clothing and species, can also restart hearts.
/mob/living/carbon/human/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE)
	//Calculates the siemens coeff based on clothing. Completely ignores the arguments
	if(flags & SHOCK_TESLA) //I hate this entire block. This gets the siemens_coeff for tesla shocks
		if(gloves && gloves.siemens_coefficient <= 0)
			siemens_coeff -= 0.5
		if(wear_suit)
			if(wear_suit.siemens_coefficient == -1)
				siemens_coeff -= 1
			else if(wear_suit.siemens_coefficient <= 0)
				siemens_coeff -= 0.95
		siemens_coeff = max(siemens_coeff, 0)
	else if(!(flags & SHOCK_NOGLOVES)) //This gets the siemens_coeff for all non tesla shocks
		if(gloves)
			siemens_coeff *= gloves.siemens_coefficient
	siemens_coeff *= physiology.siemens_coeff
	siemens_coeff *= dna.species.siemens_coeff
	. = ..()
	//Don't go further if the shock was blocked/too weak.
	if(!.)
		return
	//Note we both check that the user is in cardiac arrest and can actually heartattack
	//If they can't, they're missing their heart and this would runtime
	if(undergoing_cardiac_arrest() && can_heartattack() && !(flags & SHOCK_ILLUSION))
		if(shock_damage * siemens_coeff >= 1 && prob(25))
			var/obj/item/organ/heart/heart = getorganslot(ORGAN_SLOT_HEART)
			if(heart.Restart() && stat == CONSCIOUS)
				to_chat(src, span_notice("You feel your heart beating again!"))
	electrocution_animation(40)

/mob/living/carbon/human/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_CONTENTS)
		return
	var/informed = FALSE
	for(var/obj/item/bodypart/bodypart in src.bodyparts)
		if(!IS_ORGANIC_LIMB(bodypart))
			if(!informed)
				to_chat(src, span_userdanger("You feel a sharp pain as [bodypart] overloads!"))
				informed = TRUE
			if(prob(30/severity)) //Random chance to disable and burn limbs
				bodypart.receive_damage(burn = 5)
				bodypart.receive_damage(stamina = 120) //Disable the limb since we got EMP'd
			else
				bodypart.receive_damage(stamina = 10) //Progressive stamina damage to ensure a consistent takedown within a reasonable number of hits, regardless of RNG
			if(HAS_TRAIT(bodypart, TRAIT_EASYDISMEMBER) && bodypart.body_zone != "chest")
				if(prob(5))
					bodypart.dismember(BRUTE)

/mob/living/carbon/human/acid_act(acidpwr, acid_volume, bodyzone_hit) //todo: update this to utilize check_obscured_slots() //and make sure it's check_obscured_slots(TRUE) to stop aciding through visors etc
	var/list/damaged = list()
	var/list/inventory_items_to_kill = list()
	var/acidity = acidpwr * min(acid_volume*0.005, 0.1)
	//HEAD//
	if(!bodyzone_hit || bodyzone_hit == BODY_ZONE_HEAD) //only if we didn't specify a zone or if that zone is the head.
		var/obj/item/clothing/head_clothes = null
		if(glasses)
			head_clothes = glasses
		if(wear_mask)
			head_clothes = wear_mask
		if(wear_neck)
			head_clothes = wear_neck
		if(head)
			head_clothes = head
		if(head_clothes)
			if(!(head_clothes.resistance_flags & (UNACIDABLE | INDESTRUCTIBLE)))
				head_clothes.acid_act(acidpwr, acid_volume)
				update_inv_glasses()
				update_inv_wear_mask()
				update_inv_neck()
				update_inv_head()
			else
				to_chat(src, span_notice("Your [head_clothes.name] protects your head and face from the acid!"))
		else
			. = get_bodypart(BODY_ZONE_HEAD)
			if(.)
				damaged += .
			if(ears)
				inventory_items_to_kill += ears

	//CHEST//
	if(!bodyzone_hit || bodyzone_hit == BODY_ZONE_CHEST)
		var/obj/item/clothing/chest_clothes = null
		if(w_uniform)
			chest_clothes = w_uniform
		if(wear_suit)
			chest_clothes = wear_suit
		if(chest_clothes)
			if(!(chest_clothes.resistance_flags & (UNACIDABLE | INDESTRUCTIBLE)))
				chest_clothes.acid_act(acidpwr, acid_volume)
				update_inv_w_uniform()
				update_inv_wear_suit()
			else
				to_chat(src, span_notice("Your [chest_clothes.name] protects your body from the acid!"))
		else
			. = get_bodypart(BODY_ZONE_CHEST)
			if(.)
				damaged += .
			if(wear_id)
				inventory_items_to_kill += wear_id
			if(r_store)
				inventory_items_to_kill += r_store
			if(l_store)
				inventory_items_to_kill += l_store
			if(s_store)
				inventory_items_to_kill += s_store


	//ARMS & HANDS//
	if(!bodyzone_hit || bodyzone_hit == BODY_ZONE_L_ARM || bodyzone_hit == BODY_ZONE_R_ARM)
		var/obj/item/clothing/arm_clothes = null
		if(gloves)
			arm_clothes = gloves
		if(w_uniform && ((w_uniform.body_parts_covered & HANDS) || (w_uniform.body_parts_covered & ARMS)))
			arm_clothes = w_uniform
		if(wear_suit && ((wear_suit.body_parts_covered & HANDS) || (wear_suit.body_parts_covered & ARMS)))
			arm_clothes = wear_suit

		if(arm_clothes)
			if(!(arm_clothes.resistance_flags & (UNACIDABLE | INDESTRUCTIBLE)))
				arm_clothes.acid_act(acidpwr, acid_volume)
				update_inv_gloves()
				update_inv_w_uniform()
				update_inv_wear_suit()
			else
				to_chat(src, span_notice("Your [arm_clothes.name] protects your arms and hands from the acid!"))
		else
			. = get_bodypart(BODY_ZONE_R_ARM)
			if(.)
				damaged += .
			. = get_bodypart(BODY_ZONE_L_ARM)
			if(.)
				damaged += .


	//LEGS & FEET//
	if(!bodyzone_hit || bodyzone_hit == BODY_ZONE_L_LEG || bodyzone_hit == BODY_ZONE_R_LEG || bodyzone_hit == "feet")
		var/obj/item/clothing/leg_clothes = null
		if(shoes)
			leg_clothes = shoes
		if(w_uniform && ((w_uniform.body_parts_covered & FEET) || (bodyzone_hit != "feet" && (w_uniform.body_parts_covered & LEGS))))
			leg_clothes = w_uniform
		if(wear_suit && ((wear_suit.body_parts_covered & FEET) || (bodyzone_hit != "feet" && (wear_suit.body_parts_covered & LEGS))))
			leg_clothes = wear_suit
		if(leg_clothes)
			if(!(leg_clothes.resistance_flags & (UNACIDABLE | INDESTRUCTIBLE)))
				leg_clothes.acid_act(acidpwr, acid_volume)
				update_inv_shoes()
				update_inv_w_uniform()
				update_inv_wear_suit()
			else
				to_chat(src, span_notice("Your [leg_clothes.name] protects your legs and feet from the acid!"))
		else
			. = get_bodypart(BODY_ZONE_R_LEG)
			if(.)
				damaged += .
			. = get_bodypart(BODY_ZONE_L_LEG)
			if(.)
				damaged += .


	//DAMAGE//
	for(var/obj/item/bodypart/affecting in damaged)
		var/damage_mod = 1
		if(affecting.body_zone == BODY_ZONE_HEAD && prob(min(acidpwr * acid_volume * 0.1, 90))) //Applies disfigurement
			damage_mod = 2
			emote("scream")
			facial_hair_style = "Shaved"
			hair_style = "Bald"
			update_hair()
			ADD_TRAIT(src, TRAIT_DISFIGURED, TRAIT_GENERIC)

		apply_damage(acidity * damage_mod, BRUTE, affecting)
		apply_damage(acidity * damage_mod * 2, BURN, affecting)

	//MELTING INVENTORY ITEMS//
	//these items are all outside of armour visually, so melt regardless.
	if(!bodyzone_hit)
		if(back)
			inventory_items_to_kill += back
		if(belt)
			inventory_items_to_kill += belt

		inventory_items_to_kill += held_items

	for(var/obj/item/inventory_item in inventory_items_to_kill)
		inventory_item.acid_act(acidpwr, acid_volume)
	return TRUE

///The point value is how much they affect the singularity's size
/mob/living/carbon/human/singularity_act()
	. = 20

	if (client)
		client.give_award(/datum/award/achievement/misc/singularity_death, client.mob)

	if(mind)
		if((mind.assigned_role == JOB_NAME_STATIONENGINEER) || (mind.assigned_role == JOB_NAME_CHIEFENGINEER) )
			. = 100
		if(mind.assigned_role == JOB_NAME_CLOWN)
			. = rand(-1000, 1000)
	..()

/mob/living/carbon/human/help_shake_act(mob/living/carbon/M)
	if(!istype(M))
		return

	if(src == M)
		if(has_status_effect(/datum/status_effect/strandling))
			to_chat(src, span_notice("You attempt to remove the durathread strand from around your neck."))
			if(do_after(src, 35, src, timed_action_flags = IGNORE_HELD_ITEM))
				to_chat(src, span_notice("You succesfuly remove the durathread strand."))
				remove_status_effect(/datum/status_effect/strandling)
			return
		check_self_for_injuries()


	else
		if(wear_suit)
			wear_suit.add_fingerprint(M)
		else if(w_uniform)
			w_uniform.add_fingerprint(M)

		..()

/mob/living/carbon/human/check_self_for_injuries()
	if(stat >= UNCONSCIOUS)
		return

	visible_message("[src] examines [p_them()]self.", \
		span_notice("You check yourself for injuries."))
	var/list/harm_descriptors = dna?.species.get_harm_descriptors()
	harm_descriptors ||= list("bleed" = "bleeding")
	var/bleed_msg = harm_descriptors["bleed"]

	var/list/missing = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	for(var/obj/item/bodypart/LB as() in bodyparts)
		missing -= LB.body_zone
		if(LB.is_pseudopart) //don't show injury text for fake bodyparts; ie chainsaw arms or synthetic armblades
			continue
		var/self_aware = FALSE
		if(HAS_TRAIT(src, TRAIT_SELF_AWARE))
			self_aware = TRUE
		var/limb_max_damage = LB.max_damage
		var/status = ""
		var/brutedamage = LB.brute_dam
		var/burndamage = LB.burn_dam
		if(hallucination)
			if(prob(30))
				brutedamage += rand(30,40)
			if(prob(30))
				burndamage += rand(30,40)

		if(HAS_TRAIT(src, TRAIT_SELF_AWARE))
			status = "[brutedamage] brute damage and [burndamage] burn damage"
			if(!brutedamage && !burndamage)
				status = "no damage"

		else
			if(brutedamage > 0)
				status = LB.light_brute_msg
			if(brutedamage > (limb_max_damage*0.4))
				status = LB.medium_brute_msg
			if(brutedamage > (limb_max_damage*0.8))
				status = LB.heavy_brute_msg
			if(brutedamage > 0 && burndamage > 0)
				status += " and "

			if(burndamage > (limb_max_damage*0.8))
				status += LB.heavy_burn_msg
			else if(burndamage > (limb_max_damage*0.2))
				status += LB.medium_burn_msg
			else if(burndamage > 0)
				status += LB.light_burn_msg

			if(status == "")
				status = "OK"
		var/no_damage
		if(status == "OK" || status == "no damage")
			no_damage = TRUE
		var/isdisabled = " "
		if(LB.bodypart_disabled)
			isdisabled = " is disabled "
			if(no_damage)
				isdisabled += " but otherwise "
			else
				isdisabled += " and "
		to_chat(src, "\t <span class='[no_damage ? "notice" : "warning"]'>Your [LB.name][isdisabled][self_aware ? " has " : " is "][status].</span>")

		for(var/obj/item/I in LB.embedded_objects)
			if(I.isEmbedHarmless())
				to_chat(src, "\t <a href='byond://?src=[REF(src)];embedded_object=[REF(I)];embedded_limb=[REF(LB)]' class='warning'>There is \a [I] stuck to your [LB.name]!</a>")
			else
				to_chat(src, "\t <a href='byond://?src=[REF(src)];embedded_object=[REF(I)];embedded_limb=[REF(LB)]' class='warning'>There is \a [I] embedded in your [LB.name]!</a>")

	for(var/t in missing)
		to_chat(src, span_boldannounce("Your [parse_zone(t)] is missing!"))

	if(is_bleeding())
		to_chat(src, span_danger("You are [bleed_msg]!"))
	else if (is_bandaged())
		to_chat(src, span_danger("Your [bleed_msg] is bandaged!"))
	if(getStaminaLoss())
		if(getStaminaLoss() > 30)
			to_chat(src, span_info("You're completely exhausted."))
		else
			to_chat(src, span_info("You feel fatigued."))
	if(HAS_TRAIT(src, TRAIT_SELF_AWARE))
		if(toxloss)
			if(toxloss > 10)
				to_chat(src, span_danger("You feel sick."))
			else if(toxloss > 20)
				to_chat(src, span_danger("You feel nauseated."))
			else if(toxloss > 40)
				to_chat(src, span_danger("You feel very unwell!"))
		if(oxyloss)
			if(oxyloss > 10)
				to_chat(src, span_danger("You feel lightheaded."))
			else if(oxyloss > 20)
				to_chat(src, span_danger("Your thinking is clouded and distant."))
			else if(oxyloss > 30)
				to_chat(src, span_danger("You're choking!"))

	if(!HAS_TRAIT(src, TRAIT_NOHUNGER) && !HAS_TRAIT(src, TRAIT_POWERHUNGRY))
		switch(nutrition)
			if(NUTRITION_LEVEL_FULL to INFINITY)
				to_chat(src, span_info("You're completely stuffed!"))
			if(NUTRITION_LEVEL_WELL_FED to NUTRITION_LEVEL_FULL)
				to_chat(src, span_info("You're well fed!"))
			if(NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
				to_chat(src, span_info("You're not hungry."))
			if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
				to_chat(src, span_info("You could use a bite to eat."))
			if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
				to_chat(src, span_info("You feel quite hungry."))
			if(0 to NUTRITION_LEVEL_STARVING)
				to_chat(src, span_danger("You're starving!"))

	//Compiles then shows the list of damaged organs and broken organs
	var/list/broken = list()
	var/list/damaged = list()
	var/broken_message
	var/damaged_message
	var/broken_plural
	var/damaged_plural
	//Sets organs into their proper list
	for(var/obj/item/organ/organ as anything in internal_organs)
		if(organ.organ_flags & ORGAN_FAILING)
			if(broken.len)
				broken += ", "
			broken += organ.name
		else if(organ.damage > organ.low_threshold)
			if(damaged.len)
				damaged += ", "
			damaged += organ.name
	//Checks to enforce proper grammar, inserts words as necessary into the list
	if(broken.len)
		if(broken.len > 1)
			broken.Insert(broken.len, "and ")
			broken_plural = TRUE
		else
			var/holder = broken[1]	//our one and only element
			if(holder[length(holder)] == "s")
				broken_plural = TRUE
		//Put the items in that list into a string of text
		for(var/B in broken)
			broken_message += B
		to_chat(src, span_warning(" Your [broken_message] [broken_plural ? "are" : "is"] non-functional!"))
	if(damaged.len)
		if(damaged.len > 1)
			damaged.Insert(damaged.len, "and ")
			damaged_plural = TRUE
		else
			var/holder = damaged[1]
			if(holder[length(holder)] == "s")
				damaged_plural = TRUE
		for(var/D in damaged)
			damaged_message += D
		to_chat(src, span_info("Your [damaged_message] [damaged_plural ? "are" : "is"] hurt."))

	if(length(mind?.quirks))
		to_chat(src, span_notice("You have these quirks: [get_quirk_string()]."))

/mob/living/carbon/human/damage_clothes(damage_amount, damage_type = BRUTE, damage_flag = 0, def_zone)
	if(damage_type != BRUTE && damage_type != BURN)
		return
	damage_amount *= 0.5 //0.5 multiplier for balance reason, we don't want clothes to be too easily destroyed
	var/list/torn_items = list()

	//HEAD//
	if(!def_zone || def_zone == BODY_ZONE_HEAD)
		var/obj/item/clothing/head_clothes = null
		if(glasses)
			head_clothes = glasses
		if(wear_mask)
			head_clothes = wear_mask
		if(wear_neck)
			head_clothes = wear_neck
		if(head)
			head_clothes = head
		if(head_clothes)
			torn_items += head_clothes
		else if(ears)
			torn_items += ears

	//CHEST//
	if(!def_zone || def_zone == BODY_ZONE_CHEST)
		var/obj/item/clothing/chest_clothes = null
		if(w_uniform)
			chest_clothes = w_uniform
		if(wear_suit)
			chest_clothes = wear_suit
		if(chest_clothes)
			torn_items += chest_clothes

	//ARMS & HANDS//
	if(!def_zone || def_zone == BODY_ZONE_L_ARM || def_zone == BODY_ZONE_R_ARM)
		var/obj/item/clothing/arm_clothes = null
		if(gloves)
			arm_clothes = gloves
		if(w_uniform && ((w_uniform.body_parts_covered & HANDS) || (w_uniform.body_parts_covered & ARMS)))
			arm_clothes = w_uniform
		if(wear_suit && ((wear_suit.body_parts_covered & HANDS) || (wear_suit.body_parts_covered & ARMS)))
			arm_clothes = wear_suit
		if(arm_clothes)
			torn_items |= arm_clothes

	//LEGS & FEET//
	if(!def_zone || def_zone == BODY_ZONE_L_LEG || def_zone == BODY_ZONE_R_LEG)
		var/obj/item/clothing/leg_clothes = null
		if(shoes)
			leg_clothes = shoes
		if(w_uniform && ((w_uniform.body_parts_covered & FEET) || (w_uniform.body_parts_covered & LEGS)))
			leg_clothes = w_uniform
		if(wear_suit && ((wear_suit.body_parts_covered & FEET) || (wear_suit.body_parts_covered & LEGS)))
			leg_clothes = wear_suit
		if(leg_clothes)
			torn_items |= leg_clothes

	for(var/obj/item/I in torn_items)
		I.take_damage(damage_amount, damage_type, damage_flag, 0)

/mob/living/carbon/human/proc/blockbreak()
	to_chat(src, span_userdanger("Your block was broken!"))
	ADD_TRAIT(src, TRAIT_NOBLOCK, type)
	stoplag(50)
	REMOVE_TRAIT(src, TRAIT_NOBLOCK, type)

/mob/living/carbon/human/attack_basic_mob(mob/living/basic/user)
	if(user.melee_damage != 0 && !HAS_TRAIT(user, TRAIT_PACIFISM) && check_shields(user, user.melee_damage, "the [user.name]", MELEE_ATTACK, user.armour_penetration))
		return FALSE
	return ..()

/mob/living/carbon/human/attack_animal(mob/living/simple_animal/M)
	if(M.melee_damage != 0 && !HAS_TRAIT(M, TRAIT_PACIFISM) && check_shields(M, M.melee_damage, "the [M.name]", MELEE_ATTACK, M.armour_penetration))
		return FALSE
	return ..()
