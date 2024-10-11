#define GRAPPLE_COMBO "GGH"
#define LACERATE_COMBO "DHD"
#define BLAST_COMBO "HDDDH"

/datum/martial_art/living_fist
	name = "Living Fist"
	id = MARTIALART_LIVINGFIST
	help_verb = /mob/living/carbon/human/proc/living_fist_help


/datum/martial_art/living_fist/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(findtext(streak,GRAPPLE_COMBO))
		streak = ""
		Grapple(A,D)
		return 1
	if(findtext(streak,LACERATE_COMBO))
		streak = ""
		Lacerate(A,D)
		return 1
	if(findtext(streak,BLAST_COMBO))
		streak = ""
		Blast(A,D)
		return 1
	return 0

/datum/martial_art/living_fist/proc/Grapple(mob/living/carbon/human/A, mob/living/carbon/human/D)
	A.say("VINE LASH!", forced="living fist")
	log_combat(A, D, "vine grabbed (Living Fist)", name)
	D.visible_message("<span class='warning'>[A] lashes out and grabs [D] with their vines!</span>", \
						"<span class='userdanger'>[A] grabs you with their vines!</span>")
	D.grabbedby(A, 1)
	D.Knockdown(5) //Without knockdown target still stands up while T3 grabbed.
	A.setGrabState(GRAB_NECK)
	playsound(A.loc, 'sound/weapons/whipgrab.ogg', 15, 1, -1)


/datum/martial_art/living_fist/proc/Lacerate(mob/living/carbon/human/A, mob/living/carbon/human/D)
	var/def_check = D.getarmor(BODY_ZONE_CHEST, MELEE)
	if(A.pulling == D && A.grab_state >= GRAB_NECK)
		for (var/i in 1 to 6)
			if(!A)
				break
			A.do_attack_animation(D, ATTACK_EFFECT_CLAW)
			playsound(A.loc, 'sound/weapons/slash.ogg', 15, 1, -1)
			sleep(1)
		D.visible_message("<span class='warning'>[A] lacerates [D]'s chest with their jagged vines!</span>", \
							"<span class='userdanger'>[A] lashes at you with vines!</span>")
		D.apply_damage(20, BRUTE, BODY_ZONE_CHEST, def_check)
		D.add_bleeding(BLEED_CRITICAL)
		D.apply_status_effect(/datum/status_effect/neck_slice)
		A.say("BLEED!", forced="living fist")
		log_combat(A, D, "lacerated (Living Fist)", name)
		return

/datum/martial_art/living_fist/proc/Blast(mob/living/carbon/human/A, mob/living/carbon/human/D)
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	playsound(D.loc, 'sound/weapons/punch1.ogg', 50, 1, -1)
	A.say("NYMPH BLAST!", forced="living fist")
	D.visible_message("<span class='danger'>[A] hits [D] with THE NYMPH BLAST!</span>", \
					"<span class='userdanger'>You're suddenly hit with THE NYMPH BLAST TECHNIQUE by [A]!</span>", "<span class='hear'>You hear a sickening sound of plant matter hitting flesh!</span>", null, A)
	to_chat(A, "<span class='danger'>You hit [D] with THE NYMPH BLAST TECHNIQUE!</span>")
	D.set_species(/datum/species/diona)
	D.apply_damage(400, BRUTE, BODY_ZONE_CHEST)
	log_combat(A, D, "dionafied and obliterated (Living Fist)", name)
	return

/datum/martial_art/living_fist/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("H",D)
	if(check_streak(A,D))
		return 1
	basic_hit(A,D)
	return 1

/datum/martial_art/living_fist/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("D",D)
	if(check_streak(A,D))
		return 1
	basic_hit(A,D)
	return 1

/datum/martial_art/living_fist/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("G",D)
	if(check_streak(A,D))
		return 1
	basic_hit(A,D)
	return 1

/mob/living/carbon/human/proc/living_fist_help()
	set name = "Recall Teachings"
	set desc = "Remember the martial techniques of the Living Fist."
	set category = "Living Fist"

	to_chat(usr, "<b><i>You clench your fists and have a flashback of knowledge...</i></b>")
	to_chat(usr, "<span class='notice'>Vine Grab</span>: Grab Grab Harm. Grabs a target in an immediate neck grab.")
	to_chat(usr, "<span class='notice'>Lacerate</span>: Disarm Harm Disarm. Shreds the target with vines, causing damage and bleeding. Requires a neck-tier grab.")
	to_chat(usr, "<span class='notice'>The Nymph Blast</span>: Harm Disarm Disarm Disarm Harm. Blows whoever it hits into a pile of nymphs, even if they're not a Diona.")

#undef GRAPPLE_COMBO
#undef LACERATE_COMBO
#undef BLAST_COMBO
