#define CALF_KICK_COMBO "HGD" //Calf Kick - paralyse one leg
#define FLOOR_KICK_COMBO "HGH" //Floor Stomp - brute and stamina damage if target isn't standing
#define JUMPING_KNEE_COMBO "HDH" //Jumping Knee - knockdown and stamina damage
#define KARATE_CHOP_COMBO "GHD" //Karate Chop - short confusion and blurred eyes

/datum/martial_art/karate
	name = "Karate"
	id = MARTIALART_KARATE
	allow_temp_override = FALSE
	display_combos = TRUE

	Move1 = "Calf Kick: Harm Grab Disarm. Paralyses one of your opponent's legs."
	Move2 = "Jumping Knee: Harm Disarm Harm. Deals significant stamina damage and knocks your opponent down briefly."
	Move3 = "<b>Karate Chop: Grab Harm Disarm. Very briefly confuses your opponent and blurs their vision."
	Move4 = "<b>Floor Stomp: Harm Grab Harm. Deals brute and stamina damage if your opponent isn't standing up."


/datum/martial_art/karate/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(findtext(streak,JUMPING_KNEE_COMBO))
		reset_streak()
		jumpingKnee(A,D)
		return 1
	if(findtext(streak,KARATE_CHOP_COMBO))
		reset_streak()
		karateChop(A,D)
		return 1
	if(findtext(streak,FLOOR_KICK_COMBO))
		reset_streak()
		floorKick(A,D)
		return 1
	if(findtext(streak,CALF_KICK_COMBO))
		reset_streak()
		calfKick(A,D)
		return 1
	return 0

//Floor Stomp - brute and stamina damage if target isn't standing
/datum/martial_art/karate/proc/floorKick(mob/living/carbon/human/A, mob/living/carbon/human/D)
	var/def_check = D.getarmor(BODY_ZONE_HEAD, MELEE)
	if(!can_use(A))
		return FALSE
	if(D.body_position == LYING_DOWN)
		log_combat(A, D, "floor stomped (Karate)", name)
		D.visible_message(span_warning("[A] stomped [D] in the head!"), \
							span_userdanger("[A] stomped you in the head!"), null, COMBAT_MESSAGE_RANGE)
		playsound(get_turf(D), 'sound/weapons/punch1.ogg', 75, 1, -1)
		A.do_attack_animation(D, ATTACK_EFFECT_KICK)
		D.apply_damage(20, A.dna.species.attack_type, BODY_ZONE_HEAD, def_check)
		D.apply_damage(10, STAMINA, BODY_ZONE_HEAD, def_check)
		return 1
	return FALSE

//Calf Kick - paralyse one leg with stamina damage
/datum/martial_art/karate/proc/calfKick(mob/living/carbon/human/A, mob/living/carbon/human/D)
	var/def_check = D.getarmor(BODY_ZONE_L_LEG, MELEE)
	if(!can_use(A))
		return FALSE
	if(!D.stat)
		log_combat(A, D, "calf kicked (Karate)", name)
		D.visible_message(span_warning("[A] roundhouse kicked [D] in the calf!"), \
							span_userdanger("[A] roundhouse kicked you in the calf!"), null, COMBAT_MESSAGE_RANGE)
		playsound(get_turf(D), 'sound/weapons/punch1.ogg', 75, 1, -1)
		A.do_attack_animation(D, ATTACK_EFFECT_KICK)
		D.apply_damage(50, STAMINA, pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG), def_check)
		return 1
	return FALSE

//Jumping Knee - brief knockdown and decent stamina damage
/datum/martial_art/karate/proc/jumpingKnee(mob/living/carbon/human/A, mob/living/carbon/human/D)
	var/def_check = D.getarmor(BODY_ZONE_HEAD, MELEE)
	if(!can_use(A))
		return FALSE
	if(!D.stat)
		log_combat(A, D, "jumped kneed (Karate)", name)
		D.visible_message(span_warning("[A] jumping kneed [D] in the stomach!"), \
							span_userdanger("[A] jumping kneed you in the stomach!"), null, COMBAT_MESSAGE_RANGE)
		playsound(get_turf(D), 'sound/weapons/punch1.ogg', 75, 1, -1)
		D.emote("gasp")
		A.do_attack_animation(D, ATTACK_EFFECT_KICK)
		D.apply_damage(30, STAMINA, BODY_ZONE_CHEST, def_check)
		D.Knockdown(10)
		return 1
	return FALSE

// Karate Chop - short confusion and blurred eyes
/datum/martial_art/karate/proc/karateChop(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	if(!D.stat)
		log_combat(A, D, "karate chopped (Karate)", name)
		D.visible_message(span_warning("[A] karate chopped [D] in the neck!"), \
							span_userdanger("[A] karate chopped you in the neck!"), null, COMBAT_MESSAGE_RANGE)
		playsound(get_turf(A), 'sound/weapons/thudswoosh.ogg', 75, 1, -1)
		A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
		D.blur_eyes(10)
		D.adjust_confusion(2 SECONDS)
		D.set_jitter_if_lower(40 SECONDS)
		return 1
	return FALSE

/datum/martial_art/karate/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("H",D)
	if(check_streak(A,D))
		return 1
	return ..()

/datum/martial_art/karate/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("G",D)
	if(check_streak(A,D))
		return 1
	return ..()

/datum/martial_art/karate/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("D",D)
	if(check_streak(A,D))
		return 1
	return ..()

#undef CALF_KICK_COMBO
#undef FLOOR_KICK_COMBO
#undef JUMPING_KNEE_COMBO
#undef KARATE_CHOP_COMBO
