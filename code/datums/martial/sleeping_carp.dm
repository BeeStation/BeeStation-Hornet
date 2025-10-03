#define WRIST_WRENCH_COMBO "DD"
#define BACK_KICK_COMBO "HG"
#define STOMACH_KNEE_COMBO "GH"
#define HEAD_KICK_COMBO "DHH"
#define ELBOW_DROP_COMBO "HDHDH"

/datum/martial_art/the_sleeping_carp
	name = "The Sleeping Carp"
	id = MARTIALART_SLEEPINGCARP
	allow_temp_override = FALSE
	smashes_tables = TRUE
	display_combos = TRUE
	var/old_grab_state = null

	Move1 = "Wrist Wrench: Disarm Disarm. Forces opponent to drop item in hand."
	Move2 = "Back Kick: Harm Grab. Opponent must be facing away. Knocks down."
	Move3 = "Stomach Knee: Grab Harm. Knocks the wind out of opponent and stuns."
	Move4 = "Head Kick: Disarm Harm Harm. Decent damage, forces opponent to drop item in hand."
	Move5 = "Elbow Drop: Harm Disarm Harm Disarm Harm. Opponent must be on the ground. Deals huge damage, instantly kills anyone in critical condition."


/datum/martial_art/the_sleeping_carp/proc/check_streak(mob/living/A, mob/living/D)
	if(findtext(streak,WRIST_WRENCH_COMBO))
		reset_streak()
		wristWrench(A,D)
		return TRUE
	if(findtext(streak,BACK_KICK_COMBO))
		reset_streak()
		backKick(A,D)
		return TRUE
	if(findtext(streak,STOMACH_KNEE_COMBO))
		reset_streak()
		kneeStomach(A,D)
		return TRUE
	if(findtext(streak,HEAD_KICK_COMBO))
		reset_streak()
		headKick(A,D)
		return TRUE
	if(findtext(streak,ELBOW_DROP_COMBO))
		reset_streak()
		elbowDrop(A,D)
		return TRUE
	return FALSE

/datum/martial_art/the_sleeping_carp/proc/wristWrench(mob/living/A, mob/living/D)
	if(!D.stat && !D.IsStun() && !D.IsParalyzed())
		log_combat(A, D, "wrist wrenched (Sleeping Carp)", name)
		A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
		D.visible_message(span_danger("[A] grabs [D]'s wrist and wrenches it sideways!"), \
						span_userdanger("Your wrist is grabbed by [A] while simultaneously wrenched it to the side!"), span_hear("You hear aggressive shuffling!"), null, A)
		to_chat(A, span_danger("You grab [D]'s wrist and wrench it sideways!"))
		playsound(get_turf(A), 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		D.emote("scream")
		D.dropItemToGround(D.get_active_held_item())
		D.apply_damage(5, BRUTE, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
		D.Stun(60)
		return 1

	return FALSE

/datum/martial_art/the_sleeping_carp/proc/backKick(mob/living/A, mob/living/D)
	if(!D.stat && !D.IsParalyzed())
		if(A.dir != D.dir)
			log_combat(A, D, "missed a back-kick (Sleeping Carp) on", name)
			D.visible_message("<span class='warning'>[A] tries to kick [D] in the back, but misses!</span>", \
						"<span class='userdanger'>[A] tries to kick you in the back, but misses!</span>")
			return TRUE
		log_combat(A, D, "back-kicked (Sleeping Carp)", name)
		A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
		D.visible_message("<span class='warning'>[A] kicks [D] in the back!</span>", \
					"<span class='userdanger'>[A] kicks you in the back, making you stumble and fall!</span>")
		step_to(D,get_step(D,D.dir),1)
		D.Paralyze(80)
		playsound(get_turf(D), 'sound/weapons/punch1.ogg', 50, TRUE, -1)
		return TRUE
	return FALSE

/datum/martial_art/the_sleeping_carp/proc/kneeStomach(mob/living/A, mob/living/D)
	if(!D.stat && !D.IsParalyzed())
		log_combat(A, D, "stomach kneed (Sleeping Carp)", name)
		A.do_attack_animation(D, ATTACK_EFFECT_KICK)
		D.visible_message(span_danger("[A] knees [D] in the stomach!"), \
						span_userdanger("Your stomach is kneed by [A], making you gag!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), null, A)
		to_chat(A, span_danger("You knee [D] in the stomach, [D.p_them()] them gag!"))
		D.audible_message("<b>[D]</b> gags!")
		D.losebreath += 3
		D.Stun(40)
		playsound(get_turf(D), 'sound/weapons/punch1.ogg', 50, 1, -1)
		return 1
	return FALSE

/datum/martial_art/the_sleeping_carp/proc/headKick(mob/living/A, mob/living/D)
	var/def_check = D.getarmor(BODY_ZONE_HEAD, MELEE)
	if(!D.stat && !D.IsParalyzed())
		log_combat(A, D, "head kicked (Sleeping Carp)", name)
		A.do_attack_animation(D, ATTACK_EFFECT_KICK)
		D.visible_message("<span class='warning'>[A] kicks [D] in the head!</span>", \
						"<span class='userdanger'>Your jaw is kicked by [A]!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", null, A)
		to_chat(A, "<span class='danger'>You kick [D] in the jaw!</span>")
		D.apply_damage(20, A.get_attack_type(), BODY_ZONE_HEAD, blocked = def_check)
		D.drop_all_held_items()
		playsound(get_turf(D), 'sound/weapons/punch1.ogg', 50, 1, -1)
		D.Stun(80)
		return 1
	return FALSE

/datum/martial_art/the_sleeping_carp/proc/elbowDrop(mob/living/A, mob/living/D)
	var/def_check = D.getarmor(BODY_ZONE_CHEST, MELEE)
	if(D.body_position == LYING_DOWN)
		log_combat(A, D, "elbow dropped (Sleeping Carp)", name)
		A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
		D.visible_message(span_danger("[A] elbow drops [D]!"), \
						span_userdanger("You're piledrived by [A] with [A.p_their()] elbow!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), null, A)
		to_chat(A, span_danger("You piledrive [D] with your elbow!"))
		if(D.stat)
			D.death() //FINISH HIM!
		D.apply_damage(50, A.get_attack_type(), BODY_ZONE_CHEST, blocked = def_check)
		playsound(get_turf(D), 'sound/weapons/punch1.ogg', 75, 1, -1)
		return 1
	return FALSE

/datum/martial_art/the_sleeping_carp/grab_act(mob/living/A, mob/living/D)
	if(A==D)
		return 0 //prevents grabbing yourself

	add_to_streak("G",D)
	if(check_streak(A,D)) //if a combo is made no grab upgrade is done
		return TRUE
	old_grab_state = A.grab_state
	D.grabbedby(A, 1)
	if(old_grab_state == GRAB_PASSIVE)
		D.drop_all_held_items()
		A.setGrabState(GRAB_AGGRESSIVE) //Instant aggressive grab if on grab intent
		log_combat(A, D, "grabbed", name, addition="aggressively")
		D.visible_message("<span class='warning'>[A] violently grabs [D]!</span>", \
						"<span class='userdanger'>You're violently grabbed by [A]!</span>", "<span class='hear'>You hear aggressive shuffling!</span>", null, A)
		to_chat(A, "<span class='danger'>You violently grab [D]!</span>")
		return TRUE
	return FALSE

/datum/martial_art/the_sleeping_carp/harm_act(mob/living/A, mob/living/D)
	var/def_check = D.getarmor(BODY_ZONE_CHEST, MELEE)
	add_to_streak("H",D)
	if(check_streak(A,D))
		return 1
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	var/atk_verb = pick("kick", "chop", "hit", "slam")
	D.visible_message(span_danger("[A] [atk_verb]s [D]!"), \
					span_userdanger("[A] [atk_verb]s you!"), null, null, A)
	to_chat(A, span_danger("You [atk_verb] [D]!"))
	D.apply_damage(15, BRUTE, blocked = def_check)
	playsound(get_turf(D), 'sound/weapons/punch1.ogg', 25, TRUE, -1)
	log_combat(A, D, "[atk_verb] (Sleeping Carp)", name)
	return TRUE


/datum/martial_art/the_sleeping_carp/disarm_act(mob/living/A, mob/living/D)
	add_to_streak("D",D)
	if(check_streak(A,D))
		return TRUE
	log_combat(A, D, "disarmed (Sleeping Carp)")
	return ..()

/datum/martial_art/the_sleeping_carp/on_projectile_hit(mob/living/A, obj/projectile/P, def_zone)
	. = ..()
	if(A.incapacitated(IGNORE_GRAB)) //NO STUN
		return BULLET_ACT_HIT
	if(!(A.mobility_flags & MOBILITY_USE)) //NO UNABLE TO USE
		return BULLET_ACT_HIT
	var/datum/dna/dna = A.has_dna()
	if(dna?.check_mutation(/datum/mutation/hulk)) //NO HULK
		return BULLET_ACT_HIT
	if(!isturf(A.loc)) //NO MOTHERFLIPPIN MECHS!
		return BULLET_ACT_HIT
	A.visible_message("<span class='danger'>[A] deflects the projectile; [A.p_they()] can't be hit with ranged weapons!</span>", "<span class='userdanger'>You deflect the projectile!</span>")
	playsound(src, pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg'), 75, 1)
	P.firer = A
	P.set_angle(rand(0, 360))//SHING
	return BULLET_ACT_FORCE_PIERCE

/datum/martial_art/the_sleeping_carp/teach(mob/living/H, make_temporary = FALSE)
	. = ..()
	if(!.)
		return
	ADD_TRAIT(H, TRAIT_NOGUNS, SLEEPING_CARP_TRAIT)

/datum/martial_art/the_sleeping_carp/on_remove(mob/living/H)
	. = ..()
	REMOVE_TRAIT(H, TRAIT_NOGUNS, SLEEPING_CARP_TRAIT)

#undef WRIST_WRENCH_COMBO
#undef BACK_KICK_COMBO
#undef STOMACH_KNEE_COMBO
#undef HEAD_KICK_COMBO
#undef ELBOW_DROP_COMBO
