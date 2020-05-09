#define WRIST_WRENCH_COMBO "DD"
#define BACK_KICK_COMBO "HG"
#define STOMACH_KNEE_COMBO "GH"
#define HEAD_KICK_COMBO "DHH"
#define ELBOW_DROP_COMBO "HDHDH"

/datum/martial_art/the_sleeping_carp
	name = "The Sleeping Carp"
	id = MARTIALART_SLEEPINGCARP
	deflection_chance = 100
	reroute_deflection = TRUE
	no_guns = TRUE
	allow_temp_override = FALSE
	help_verb = /mob/living/carbon/human/proc/sleeping_carp_help
	smashes_tables = TRUE

/datum/martial_art/the_sleeping_carp/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(findtext(streak,WRIST_WRENCH_COMBO))
		streak = ""
		wristWrench(A,D)
		return 1
	if(findtext(streak,BACK_KICK_COMBO))
		streak = ""
		backKick(A,D)
		return 1
	if(findtext(streak,STOMACH_KNEE_COMBO))
		streak = ""
		kneeStomach(A,D)
		return 1
	if(findtext(streak,HEAD_KICK_COMBO))
		streak = ""
		headKick(A,D)
		return 1
	if(findtext(streak,ELBOW_DROP_COMBO))
		streak = ""
		elbowDrop(A,D)
		return 1
	return 0

/datum/martial_art/the_sleeping_carp/proc/wristWrench(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!D.stat && !D.IsStun() && !D.IsParalyzed())
		log_combat(A, D, "wrist wrenched (Sleeping Carp)")
		A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
		D.visible_message("<span class='warning'>[A] grabs [D]'s wrist and wrenches it sideways!</span>", \
						  "<span class='userdanger'>[A] grabs your wrist and violently wrenches it to the side!</span>")
		playsound(get_turf(A), 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		D.emote("scream")
		D.dropItemToGround(D.get_active_held_item())
		D.apply_damage(5, BRUTE, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
		D.Stun(60)
		return 1
	
	return basic_hit(A,D)

/datum/martial_art/the_sleeping_carp/proc/backKick(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!D.stat && !D.IsParalyzed())
		if(A.dir == D.dir)
			log_combat(A, D, "back-kicked (Sleeping Carp)")
			A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
			D.visible_message("<span class='warning'>[A] kicks [D] in the back!</span>", \
								"<span class='userdanger'>[A] kicks you in the back, making you stumble and fall!</span>")
			step_to(D,get_step(D,D.dir),1)
			D.Paralyze(80)
			playsound(get_turf(D), 'sound/weapons/punch1.ogg', 50, 1, -1)
			return 1
		else
			log_combat(A, D, "missed a back-kick (Sleeping Carp) on")
			D.visible_message("<span class='warning'>[A] tries to kick [D] in the back, but misses!</span>", \
								"<span class='userdanger'>[A] tries to kick you in the back, but misses!</span>")
	return basic_hit(A,D)

/datum/martial_art/the_sleeping_carp/proc/kneeStomach(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!D.stat && !D.IsParalyzed())
		log_combat(A, D, "stomach kneed (Sleeping Carp)")
		A.do_attack_animation(D, ATTACK_EFFECT_KICK)
		D.visible_message("<span class='warning'>[A] knees [D] in the stomach!</span>", \
						  "<span class='userdanger'>[A] winds you with a knee in the stomach!</span>")
		D.audible_message("<b>[D]</b> gags!")
		D.losebreath += 3
		D.Stun(40)
		playsound(get_turf(D), 'sound/weapons/punch1.ogg', 50, 1, -1)
		return 1
	return basic_hit(A,D)

/datum/martial_art/the_sleeping_carp/proc/headKick(mob/living/carbon/human/A, mob/living/carbon/human/D)
	var/def_check = D.getarmor(BODY_ZONE_HEAD, "melee")
	if(!D.stat && !D.IsParalyzed())
		log_combat(A, D, "head kicked (Sleeping Carp)")
		A.do_attack_animation(D, ATTACK_EFFECT_KICK)
		D.visible_message("<span class='warning'>[A] kicks [D] in the head!</span>", \
						  "<span class='userdanger'>[A] kicks you in the jaw!</span>")
		D.apply_damage(20, A.dna.species.attack_type, BODY_ZONE_HEAD, blocked = def_check)
		D.drop_all_held_items()
		playsound(get_turf(D), 'sound/weapons/punch1.ogg', 50, 1, -1)
		D.Stun(80)
		return 1
	return basic_hit(A,D)

/datum/martial_art/the_sleeping_carp/proc/elbowDrop(mob/living/carbon/human/A, mob/living/carbon/human/D)
	var/def_check = D.getarmor(BODY_ZONE_CHEST, "melee")
	if(!(D.mobility_flags & MOBILITY_STAND))
		log_combat(A, D, "elbow dropped (Sleeping Carp)")
		A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
		D.visible_message("<span class='warning'>[A] elbow drops [D]!</span>", \
							"<span class='userdanger'>[A] piledrives you with their elbow!</span>")
		if(D.stat)
			D.death() //FINISH HIM!
		D.apply_damage(50, A.dna.species.attack_type, BODY_ZONE_CHEST, blocked = def_check)
		playsound(get_turf(D), 'sound/weapons/punch1.ogg', 75, 1, -1)
		return 1
	return basic_hit(A,D)

/datum/martial_art/the_sleeping_carp/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(A==D)
		return 0 //prevents grabbing yourself
	if(A.a_intent == INTENT_GRAB)
		add_to_streak("G",D)
		if(check_streak(A,D)) //doing combos is prioritized over upgrading grabs
			return 1
		D.grabbedby(A, 1)
		if(A.grab_state == GRAB_PASSIVE)
			D.drop_all_held_items()
			A.setGrabState(GRAB_AGGRESSIVE) //Instant agressive grab if on grab intent
			log_combat(A, D, "grabbed", addition="aggressively")
			D.visible_message("<span class='warning'>[A] violently grabs [D]!</span>", \
								"<span class='userdanger'>[A] violently grabs you!</span>")
	else
		D.grabbedby(A, 1)
	return 1

/datum/martial_art/the_sleeping_carp/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	var/def_check = D.getarmor(BODY_ZONE_CHEST, "melee")
	add_to_streak("H",D)
	if(check_streak(A,D))
		return 1
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	var/atk_verb = pick("punches", "kicks", "chops", "hits", "slams")
	D.visible_message("<span class='danger'>[A] [atk_verb] [D]!</span>", \
					  "<span class='userdanger'>[A] [atk_verb] you!</span>")
	D.apply_damage(15, BRUTE, blocked = def_check)
	playsound(get_turf(D), 'sound/weapons/punch1.ogg', 25, 1, -1)
	log_combat(A, D, "[atk_verb] (Sleeping Carp)")
	return 1


/datum/martial_art/the_sleeping_carp/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("D",D)
	if(check_streak(A,D))
		return 1
	return ..()

/mob/living/carbon/human/proc/sleeping_carp_help()
	set name = "Recall Teachings"
	set desc = "Remember the martial techniques of the Sleeping Carp clan."
	set category = "Sleeping Carp"

	to_chat(usr, "<b><i>You retreat inward and recall the teachings of the Sleeping Carp...</i></b>")

	to_chat(usr, "<span class='notice'>Wrist Wrench</span>: Disarm Disarm. Forces opponent to drop item in hand.")
	to_chat(usr, "<span class='notice'>Back Kick</span>: Harm Grab. Opponent must be facing away. Knocks down.")
	to_chat(usr, "<span class='notice'>Stomach Knee</span>: Grab Harm. Knocks the wind out of opponent and stuns.")
	to_chat(usr, "<span class='notice'>Head Kick</span>: Disarm Harm Harm. Decent damage, forces opponent to drop item in hand.")
	to_chat(usr, "<span class='notice'>Elbow Drop</span>: Harm Disarm Harm Disarm Harm. Opponent must be on the ground. Deals huge damage, instantly kills anyone in critical condition.")

/obj/item/twohanded/bostaff
	name = "bo staff"
	desc = "A long, tall staff made of polished wood. Traditionally used in ancient old-Earth martial arts. Can be wielded to both kill and incapacitate."
	force = 10
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	force_unwielded = 10
	force_wielded = 24
	block_power_wielded = 50
	block_power_unwielded = 25
	throwforce = 20
	throw_speed = 2
	attack_verb = list("smashed", "slammed", "whacked", "thwacked")
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "bostaff0"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	block_level = 1
	block_upgrade_walk = 1
	block_power = 25

/obj/item/twohanded/bostaff/update_icon_state()
	icon_state = "bostaff[wielded]"

/obj/item/twohanded/bostaff/attack(mob/target, mob/living/user)
	add_fingerprint(user)
	if((HAS_TRAIT(user, TRAIT_CLUMSY)) && prob(50))
		to_chat(user, "<span class ='warning'>You club yourself over the head with [src].</span>")
		user.Paralyze(60)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(2*force, BRUTE, BODY_ZONE_HEAD)
		else
			user.take_bodypart_damage(2*force)
		return
	if(iscyborg(target))
		return ..()
	if(!isliving(target))
		return ..()
	var/mob/living/carbon/C = target
	if(C.stat)
		to_chat(user, "<span class='warning'>It would be dishonorable to attack a foe while they cannot retaliate.</span>")
		return
	if(user.a_intent == INTENT_DISARM)
		if(!wielded)
			return ..()
		if(!ishuman(target))
			return ..()
		var/mob/living/carbon/human/H = target
		var/list/fluffmessages = list("[user] clubs [H] with [src]!", \
									  "[user] smacks [H] with the butt of [src]!", \
									  "[user] broadsides [H] with [src]!", \
									  "[user] smashes [H]'s head with [src]!", \
									  "[user] beats [H] with front of [src]!", \
									  "[user] twirls and slams [H] with [src]!")
		H.visible_message("<span class='warning'>[pick(fluffmessages)]</span>", \
							   "<span class='userdanger'>[pick(fluffmessages)]</span>")
		playsound(get_turf(user), 'sound/effects/woodhit.ogg', 75, 1, -1)
		H.adjustStaminaLoss(rand(13,20))
		if(prob(10))
			H.visible_message("<span class='warning'>[H] collapses!</span>", \
								   "<span class='userdanger'>Your legs give out!</span>")
			H.Paralyze(80)
		if(H.staminaloss && !H.IsSleeping())
			var/total_health = (H.health - H.staminaloss)
			if(total_health <= HEALTH_THRESHOLD_CRIT && !H.stat)
				H.visible_message("<span class='warning'>[user] delivers a heavy hit to [H]'s head, knocking [H.p_them()] out cold!</span>", \
									   "<span class='userdanger'>[user] knocks you unconscious!</span>")
				H.SetSleeping(600)
				H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 15, 150)
	else
		return ..()

/obj/item/twohanded/bostaff/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(wielded)
		return ..()
	return 0
