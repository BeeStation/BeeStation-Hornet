#define SURPRISE_SPIN_COMBO "DD"
#define TOUNGE_PULL_COMBO "GHG"
#define THROAT_PUNCH_COMBO "HHG"
#define ARM_PULL_COMBO "GD"
#define MIME_SPECIAL_COMBO "DHGGHD"

/datum/martial_art/cqm
	name = "Close Quarters Mimery"
	id = MARTIALART_CQM
	allow_temp_override = FALSE
	help_verb = /mob/living/carbon/human/proc/cqm_help

/datum/martial_art/cqm/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(findtext(streak,SURPRISE_SPIN_COMBO))
		streak = ""
		surpriseSpin(A,D)
		return TRUE
	if(findtext(streak,TOUNGE_PULL_COMBO))
		streak = ""
		toungePull(A,D)
		return TRUE
	if(findtext(streak,THROAT_PUNCH_COMBO))
		streak = ""
		throatPunch(A,D)
		return TRUE
	if(findtext(streak,ARM_PULL_COMBO))
		streak = ""
		armPull(A,D)
		return TRUE
	if(findtext(streak,MIME_SPECIAL_COMBO))
		streak = ""
		mimeSpecial(A,D)
		return TRUE
	return FALSE

//Surprise Spin, confused effect for a some time
/datum/martial_art/cqm/proc/surpriseSpin(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!D.stat && !D.IsStun() && !D.IsParalyzed())
		log_combat(A, D, "Surprise spun (Close Quarters Mimery)")
		D.visible_message("<span class='warning'>[A] spins [D] right round like a record!</span>", \
		"<span class='userdanger'>[A] spins you right round like a record!</span>")
		D.emote("spin")
		D.confused += 20
		A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
		playsound(get_turf(D), 'sound/weapons/thudswoosh.ogg', 30, 1, -1)
		return TRUE

	return basic_hit(A,D)

//Tounge Pull, Deal 10 brute to the head(reduced by armor(space magic), Deals damage to the targets tounge and restricts speech for a bit.
/datum/martial_art/cqm/proc/toungePull(mob/living/carbon/human/A, mob/living/carbon/human/D)
	var/def_check = D.getarmor(BODY_ZONE_HEAD, "melee")
	log_combat(A, D, "Tounge Pulled (Close Quarters Mimery)")
	D.visible_message("<span class='warning'>[A] pulls [D]'s tounge painfully!</span>", \
		"<span class='userdanger'>[A] pulls your tounge painfully restricting your speech!</span>")
	D.apply_damage(10, A.dna.species.attack_type, BODY_ZONE_HEAD, def_check)
	D.adjustOrganLoss(ORGAN_SLOT_TONGUE, 15, 200)
	D.Jitter(20)
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	playsound(get_turf(D), 'sound/effects/hit_punch.ogg', 30, 1, -1)
	if(D.silent <= 10)
		D.silent = CLAMP(D.silent + 10, 0, 10)
	return TRUE

//Throat Punch, Prevents breating for a moment, deals oxygen damage and restricts speech for a some time.
/datum/martial_art/cqm/proc/throatPunch(mob/living/carbon/human/A, mob/living/carbon/human/D)
	log_combat(A, D, "Throat punched (Close Quarters Mimery)")
	D.visible_message("<span class='warning'>[A] Punches [D]'s throat!</span>", \
		"<span class='userdanger'>[A] punches your throat restricting your speech and breathing!</span>")
	playsound(get_turf(A), 'sound/effects/hit_punch.ogg', 50, 1, -1)
	D.losebreath += 3
	D.adjustOxyLoss(10)
	if(D.silent <= 15)
		D.silent = CLAMP(D.silent + 15, 0, 15)
	return TRUE

//Arm Pull, a weaker wrist wrench that wont grant distance from batons. Disarms and very briefly stuns the target for three seconds as well as dealing 5 brute to either arm.
/datum/martial_art/cqm/proc/armPull(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!D.stat && !D.IsStun() && !D.IsParalyzed())
		log_combat(A, D, "Arm pulled (Close Quarters Mimery)")
		D.visible_message("<span class='warning'>[A] grabs [D]'s arm and pulls it sideways painfully!</span>", \
			"<span class='userdanger'>[A] grabs and pulls your arm painfully to the side!</span>")
		playsound(get_turf(A), 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
		D.apply_damage(5, BRUTE, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
		D.dropItemToGround(D.get_active_held_item())
		D.emote("scream")
		D.Stun(30)
		return TRUE

	return basic_hit(A,D)

//Mime special, RIP HIS TOUNGE OUT AND CRUSH IT BEFORE HIS EYES! 25 brute to the head and a 6s stun also destroying the targets tounge and making them BLEED!
/datum/martial_art/cqm/proc/mimeSpecial(mob/living/carbon/human/A, mob/living/carbon/human/D)
	var/obj/item/organ/tongue/T = D.getorganslot(ORGAN_SLOT_TONGUE)
	log_combat(A, D, "Mime specialed (Close Quarters Mimery)")
	D.visible_message("<span class='warning'>[A] grabs [D]'s tounge and violently rips it out and crushes it!</span>", \
		"<span class='userdanger'>[A] grabs and rips your tounge out and crushes it!</span>")
	D.apply_damage(25, BRUTE, BODY_ZONE_HEAD)
	D.emote("scream")
	D.Stun(60)
	D.bleed_rate = CLAMP(D.bleed_rate + 30, 0, 30)
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	playsound(get_turf(A), 'sound/effects/hit_punch.ogg', 50, 1, -1)
	if(T)
		T.Remove(D)
		qdel(T)
	return TRUE

/datum/martial_art/cqm/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("H",D)
	if(check_streak(A,D))
		return TRUE
	return ..()

/datum/martial_art/cqm/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("G",D)
	if(check_streak(A,D))
		return TRUE
	return ..()

/datum/martial_art/cqm/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("D",D)
	if(check_streak(A,D))
		return TRUE
	return ..()

/mob/living/carbon/human/proc/cqm_help()
	set name = "Recall Teachings"
	set desc = "Remember the martial techniques of Mimes."
	set category = "CQM"

	to_chat(usr, "<b><i>You try to remember the fundamentals of Close Quarters Mimery...</i></b>")

	to_chat(usr, "<span class='notice'>Surprise spin</span>: Disarm Disarm. Greatly confuses your target and makes them spin if they are standing")
	to_chat(usr, "<span class='notice'>Tounge Pull</span>: Grab Harm Grab. Deals some damage to your targets tounge and prevents them from speaking for a short time .")
	to_chat(usr, "<span class='notice'>Throat Punch</span>: Harm Harm Grab. Prevents your target from speaking for some time and stops them from breating for a moment aswell as dealing slight oxygen damage")
	to_chat(usr, "<span class='notice'>Arm Pull</span>: Grab Disarm. Deals very minor brute damage to one of your targets arms and disarms them while also stunning them for three seconds.")
	to_chat(usr, "<span class='notice'>Mime special</span>: Disarm Harm Grab Grab Harm Disarm. Rips your targets tounge out causing causing heavy bleeding and brute damage aswell as destroying their tounge and stunning them.")
