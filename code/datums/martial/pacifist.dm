#define DISARM_COMBO "GD"
#define VULCAN_NERVE_PINCH "GG"

/datum/martial_art/pacifist
	name = "The Paci-Fist"
	id = MARTIALART_PACIFIST
	help_verb = /mob/living/carbon/human/proc/pacifist_help
	block_chance = 75

/datum/martial_art/pacifist/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	if(A==D)
		return FALSE //prevents grabbing yourself
	if(A.a_intent == INTENT_GRAB)
		add_to_streak("G",D)
		if(check_streak(A,D))
			return TRUE
		D.grabbedby(A, 1)
		if(A.grab_state == GRAB_PASSIVE)
			A.setGrabState(GRAB_AGGRESSIVE) //Instant "firm" grab if on grab intent
			log_combat(A, D, "grabbed", addition="aggressively (Paci-Fist)")
			D.visible_message("<span class='danger'>[A] firmly grips [D]!</span>",
							"<span class='danger'>[A] firmly grips you!</span>")
	else
		D.grabbedby(A, 1)
	return TRUE

/datum/martial_art/pacifist/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	add_to_streak("D",D)
	if(check_streak(A,D))
		return TRUE
	if(prob(25))
		log_combat(A, D, "feinted (Paci-Fist)")
		D.visible_message("<span class='warning'>[A] feints [D]!</span>", \
						"<span class='userdanger'>[A] feints you!</span>")
		D.drop_all_held_items()
		D.Stun(30)
	return ..()

/datum/martial_art/pacifist/can_use(mob/living/carbon/human/H)
	if(!HAS_TRAIT(H, TRAIT_PACIFISM))
		return FALSE
	return ..()

/datum/martial_art/pacifist/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	if(findtext(streak,DISARM_COMBO))
		streak = ""
		Disarm(A,D)
		return TRUE
	if(findtext(streak,VULCAN_NERVE_PINCH))
		streak = ""
		Vulcan(A,D)
		return TRUE
	return FALSE

/datum/martial_art/pacifist/proc/Disarm(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	if(!D.stat)
		var/obj/item/I = D.get_active_held_item()
		if(I && D.temporarilyRemoveItemFromInventory(I))
			playsound(get_turf(D), 'sound/weapons/punchmiss.ogg', 50, 1, -1)
			D.Stun(10)
			D.Jitter(2)
			log_combat(A, D, "took [I] from (Disarm) (Paci-Fist)")
			D.visible_message("<span class='warning'>[A] swiftly grabs [D]'s [I] out of their their hand!</span>", \
							"<span class='userdanger'>[A] swiftly grabs your [I] out of your hand!</span>", null, COMBAT_MESSAGE_RANGE)
			A.put_in_hands(I)
			return TRUE
	return TRUE

/datum/martial_art/pacifist/proc/Vulcan(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	if(A.pulling == D && !D.IsSleeping())
		while(do_after(A, 30, target = D))
			D.visible_message("<span class='danger'>[A] reaches for [D]'s neck!</span>", \
							"<span class='userdanger'>[A] reaches for your neck!</span>")
			if(!A.CanReach(D) || !A.pulling == D || D.IsSleeping())
				A.visible_message("<span class='notice'>[A] fails to reach [D]'s neck...</span>", \
							"<span class='notice'>[A] fails to reach your neck...</span>")
				break
			else
				log_combat(A, D, "knocked out (Vulcan Nerve Pinch) (Paci-Fist)")
				D.visible_message("<span class='danger'>[A] pinches a nerve in [D]'s neck!</span>", \
								"<span class='userdanger'>[A] pinches a nerve in your neck!</span>")
				D.SetSleeping(400)
				if(A.grab_state < GRAB_NECK)
					A.setGrabState(GRAB_NECK)
				break
	return TRUE

/mob/living/carbon/human/proc/pacifist_help()
	set name = "Remember The Basics"
	set desc = "You try to remember some of the basics of Paci-Fist."
	set category = "Paci-Fist"
	to_chat(usr, "<b><i>You try to remember some of the basics of Paci-Fist.</i></b>")

	to_chat(usr, "<span class='notice'>Disarms</span>: Your disarms have a higher chance to disarm.")
	to_chat(usr, "<span class='notice'>Grabs</span>: Your grabs instantly grab your opponents firmly.")
	to_chat(usr, "<span class='notice'>Disarm Combo</span>: Grab Disarm. You will grab opponents item out of their hand.")
	to_chat(usr, "<span class='notice'>Nerve Pinch Combo</span>: Grab Grab. You will reach for your opponents neck and after some time pacify them.")
	to_chat(usr, "<b><i>In addition, by having your throw mode on when being attacked, you enter an active defense mode where you have a chance to block attacks done to you.</i></b>")
