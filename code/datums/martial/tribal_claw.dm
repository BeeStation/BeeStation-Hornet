#define TAIL_SWEEP_COMBO "DDGH"
#define FACE_SCRATCH_COMBO "HD"
#define JUGULAR_CUT_COMBO "HH"
#define TAIL_GRAB_COMBO "DHGH"

/datum/martial_art/tribal_claw
	name = "Tribal Claw"
	id = MARTIALART_TRIBALCLAW
	allow_temp_override = FALSE
	display_combos = TRUE
	COOLDOWN_DECLARE(jugular_cut_cd)

	Move1 = "Tail Sweep: Disarm Disarm Grab Harm. Requires a lizard tail. Pushes everyone around you away and knocks them down."
	Move2 = "Face Scratch: Harm Disarm. Damages your target's head and confuses them for a short time."
	Move3 = "Jugular Cut: Harm Harm. Causes your target to rapidly lose blood. Works only if you confuse your target, if they're lying down, or if you have them in an aggresive grab or higher."
	Move4 = "Tail Grab: Disarm Harm Grab Harm. Requires a lizard tail. Grabs your target by their neck and makes them unable to talk for a short time."

/datum/martial_art/tribal_claw/proc/check_streak(mob/living/A, mob/living/D)
	if(findtext(streak,TAIL_SWEEP_COMBO))
		reset_streak()
		return tailSweep(A,D)
	if(findtext(streak,FACE_SCRATCH_COMBO))
		reset_streak()
		return faceScratch(A,D)
	if(findtext(streak,JUGULAR_CUT_COMBO))
		reset_streak()
		return jugularCut(A,D)
	if(findtext(streak,TAIL_GRAB_COMBO))
		reset_streak()
		return tailGrab(A,D)
	return FALSE

//Tail Sweep, triggers an effect similar to Alien Queen's tail sweep but only affects stuff 1 tile next to you, basically 3x3.
/datum/martial_art/tribal_claw/proc/tailSweep(mob/living/A, mob/living/D)
	if(iscarbon(A))
		var/mob/living/carbon/L = A
		if(!istype(L.get_organ_slot(ORGAN_SLOT_TAIL), /obj/item/organ/tail/lizard))
			L.visible_message(span_warningbig("You lack the tail of a lizard."))
			return
	if(A == D) //Don't allow storing moves on yourself to cast on command
		return
	log_combat(A, D, "tail sweeped(Tribal Claw)", name)
	D.visible_message(span_warning("[A] sweeps [D]'s legs with their tail!"), \
					span_userdanger("[A] sweeps your legs with their tail!"))
	var/datum/action/spell/aoe/repulse/xeno/R = new
	R.aoe_radius = 1
	R.on_cast(A, null)

//Face Scratch, deals 10 brute to head(reduced by armor), blurs the target's vision and gives them the confused effect for a short time.
/datum/martial_art/tribal_claw/proc/faceScratch(mob/living/A, mob/living/D)
	var/def_check = D.getarmor(BODY_ZONE_HEAD, MELEE)
	log_combat(A, D, "face scratched (Tribal Claw)", name)
	D.visible_message(span_warning("[A] scratches [D]'s face with their claws!"), \
						span_userdanger("[A] scratches your face with their claws!"))
	D.apply_damage(10, BRUTE, BODY_ZONE_HEAD, def_check)
	D.adjust_confusion(8 SECONDS)
	D.set_eye_blur_if_lower(10 SECONDS)
	A.do_attack_animation(D, ATTACK_EFFECT_CLAW)
	playsound(get_turf(D), 'sound/weapons/slash.ogg', 100, TRUE, -1)

/*
Jugular Cut, can only be done if the target is confused, lying down, or in aggresive grab or higher.
Deals 15 brute to head(reduced by armor) and causes a rapid bleeding effect similar to throat slicing someone with a sharp item.
*/
/datum/martial_art/tribal_claw/proc/jugularCut(mob/living/A, mob/living/D)
	var/def_check = D.getarmor(BODY_ZONE_HEAD, MELEE)
	if(D.body_position == LYING_DOWN || (A.pulling == D && A.grab_state >= GRAB_AGGRESSIVE) || D.has_status_effect(/datum/status_effect/confusion))
		if(!COOLDOWN_FINISHED(src, jugular_cut_cd))	// No ultra DPS with gloves of the north star
			return
		COOLDOWN_START(src, jugular_cut_cd, CLICK_CD_MELEE * 2)
		log_combat(A, D, "jugular cut (Tribal Claw)", name)
		D.visible_message(span_warning("[A] cuts [D]'s jugular vein with their claws!"), \
							span_userdanger("[A] cuts your jugular vein!"))
		D.apply_damage(15, BRUTE, BODY_ZONE_HEAD, def_check)
		if(iscarbon(D))
			var/mob/living/carbon/carbon_defender = D
			carbon_defender.add_bleeding(BLEED_CRITICAL)
		D.apply_status_effect(/datum/status_effect/neck_slice)
		A.do_attack_animation(D, ATTACK_EFFECT_CLAW)
		playsound(get_turf(D), 'sound/weapons/slash.ogg', 100, TRUE, -1)

//Tail Grab, instantly puts your target in a T3 grab and makes them unable to talk for a short time.
/datum/martial_art/tribal_claw/proc/tailGrab(mob/living/A, mob/living/D)
	if(iscarbon(A))
		var/mob/living/carbon/L = A
		if(!istype(L.get_organ_slot(ORGAN_SLOT_TAIL), /obj/item/organ/tail/lizard))
			L.visible_message(span_warningbig("You lack the tail of a lizard."))
			return
	if(A == D) //Don't grab yourself
		return
	log_combat(A, D, "tail grabbed (Tribal Claw)", name)
	D.visible_message(span_warning("[A] grabs [D] with their tail!"), \
						span_userdanger("[A] grabs you with their tail!"))
	D.grabbedby(A, 1)
	D.Knockdown(5) //Without knockdown target still stands up while T3 grabbed.
	A.setGrabState(GRAB_NECK)
	D.adjust_silence_up_to(20 SECONDS, 20 SECONDS)
	playsound(get_turf(D), 'sound/effects/woodhit.ogg', 100, TRUE, -1)

/datum/martial_art/tribal_claw/harm_act(mob/living/A, mob/living/D)
	add_to_streak("H",D)
	if(check_streak(A,D))
		return TRUE
	return FALSE

/datum/martial_art/tribal_claw/disarm_act(mob/living/A, mob/living/D)
	add_to_streak("D",D)
	if(check_streak(A,D))
		return TRUE
	return FALSE

/datum/martial_art/tribal_claw/grab_act(mob/living/A, mob/living/D)
	add_to_streak("G",D)
	if(check_streak(A,D))
		return TRUE
	return FALSE

/mob/living/carbon/human/proc/tribal_claw_help()
	set name = "Recall Teachings"
	set desc = "Remember the martial techniques of the Tribal Claw"
	set category = "Tribal Claw"

	to_chat(usr, "<b><i>You retreat inward and recall the teachings of the Tribal Claw...</i></b>")



#undef TAIL_SWEEP_COMBO
#undef FACE_SCRATCH_COMBO
#undef JUGULAR_CUT_COMBO
#undef TAIL_GRAB_COMBO
