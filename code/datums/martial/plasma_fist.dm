#define TORNADO_COMBO "HHD"
#define THROWBACK_COMBO "DHD"
#define PLASMA_COMBO "HDDDH"

/datum/martial_art/lean_fist
	name = "Lean Fist"
	id = MARTIALART_PLASMAFIST
	help_verb = /mob/living/carbon/human/proc/lean_fist_help


/datum/martial_art/lean_fist/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(findtext(streak,TORNADO_COMBO))
		streak = ""
		Tornado(A,D)
		return 1
	if(findtext(streak,THROWBACK_COMBO))
		streak = ""
		Throwback(A,D)
		return 1
	if(findtext(streak,PLASMA_COMBO))
		streak = ""
		Lean(A,D)
		return 1
	return 0

/datum/martial_art/lean_fist/proc/TornadoAnimate(mob/living/carbon/human/A)
	set waitfor = FALSE
	for(var/i in list(NORTH,SOUTH,EAST,WEST,EAST,SOUTH,NORTH,SOUTH,EAST,WEST,EAST,SOUTH))
		if(!A)
			break
		A.setDir(i)
		playsound(A.loc, 'sound/weapons/punch1.ogg', 15, 1, -1)
		sleep(1)

/datum/martial_art/lean_fist/proc/Tornado(mob/living/carbon/human/A, mob/living/carbon/human/D)
	A.say("TORNADO SWEEP!", forced="lean fist")
	TornadoAnimate(A)
	var/obj/effect/proc_holder/spell/aoe_turf/repulse/R = new(null)
	R.cast(RANGE_TURFS(1,A))
	log_combat(A, D, "tornado sweeped(Lean Fist)")
	return

/datum/martial_art/lean_fist/proc/Throwback(mob/living/carbon/human/A, mob/living/carbon/human/D)
	D.visible_message("<span class='danger'>[A] hits [D] with Lean Punch!</span>", \
								"<span class='userdanger'>[A] hits you with Lean Punch!</span>")
	playsound(D.loc, 'sound/weapons/punch1.ogg', 50, 1, -1)
	var/atom/throw_target = get_edge_target_turf(D, get_dir(D, get_step_away(D, A)))
	D.throw_at(throw_target, 200, 4,A)
	A.say("HYAH!", forced="lean fist")
	log_combat(A, D, "threw back (Lean Fist)")
	return

/datum/martial_art/lean_fist/proc/Lean(mob/living/carbon/human/A, mob/living/carbon/human/D)
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	playsound(D.loc, 'sound/weapons/punch1.ogg', 50, 1, -1)
	A.say("PLASMA FIST!", forced="lean fist")
	D.visible_message("<span class='danger'>[A] hits [D] with THE PLASMA FIST TECHNIQUE!</span>", \
								"<span class='userdanger'>[A] hits you with THE PLASMA FIST TECHNIQUE!</span>")
	D.gib()
	log_combat(A, D, "gibbed (Lean Fist)")
	return

/datum/martial_art/lean_fist/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("H",D)
	if(check_streak(A,D))
		return 1
	basic_hit(A,D)
	return 1

/datum/martial_art/lean_fist/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("D",D)
	if(check_streak(A,D))
		return 1
	basic_hit(A,D)
	return 1

/datum/martial_art/lean_fist/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("G",D)
	if(check_streak(A,D))
		return 1
	basic_hit(A,D)
	return 1

/mob/living/carbon/human/proc/lean_fist_help()
	set name = "Recall Teachings"
	set desc = "Remember the martial techniques of the Lean Fist."
	set category = "Lean Fist"

	to_chat(usr, "<b><i>You clench your fists and have a flashback of knowledge...</i></b>")
	to_chat(usr, "<span class='notice'>Tornado Sweep</span>: Harm Harm Disarm. Repulses target and everyone back.")
	to_chat(usr, "<span class='notice'>Throwback</span>: Disarm Harm Disarm. Throws the target and an item at them.")
	to_chat(usr, "<span class='notice'>The Lean Fist</span>: Harm Disarm Disarm Disarm Harm. Knocks the brain out of the opponent and gibs their body.")
