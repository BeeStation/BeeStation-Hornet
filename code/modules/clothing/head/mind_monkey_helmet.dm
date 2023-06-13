/obj/item/clothing/head/monkey_sentience_helmet
	name = "Monkey mind-magnification helmet"
	desc = "Reverse engineered from an artifact found on the head of a martian primate's skeleton, this hat rapidly stimulates the ape's mind to increase brain function. Simply put, hat make chimp more smarter."

	icon_state = "monkeymind"
	strip_delay = 100
	clothing_flags = EFFECT_HAT
	COOLDOWN_DECLARE(message_cooldown) //It'll get annoying quick when someone tries to remove their own helmet 20 times a second
	var/datum/mind/magnification = null ///A reference to the mind we govern

/obj/item/clothing/head/monkey_sentience_helmet/equipped(mob/user, slot)
	. = ..()
	if(slot != ITEM_SLOT_HEAD)
		return
	if(!ismonkey(user) || user.key)
		to_chat(user, "<span class='boldnotice'>You feel a stabbing pain in the back of your head for a moment.</span>")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 30, TRUE)
		if(isliving(user)) //I don't know what normally would force us to check this, but it's worth checking
			var/mob/living/M = user
			M.apply_damage(5,BRUTE,BODY_ZONE_HEAD,FALSE,FALSE,FALSE) //notably: no damage resist (it's in your helmet), no damage spread (it's in your helmet)
			return
		return
	INVOKE_ASYNC(src, PROC_REF(poll), user)

/obj/item/clothing/head/monkey_sentience_helmet/proc/poll(mob/living/carbon/monkey/user) //At this point, we can assume we're given a monkey, since this'll put them in the body anyways
	user.visible_message("<span class='warning'>[src] powers up!</span>")
	playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
	var/list/candidates = pollCandidatesForMob(
		Question = "Do you want to play as a mind magnified monkey?",
		jobbanType = ROLE_MONKEY_HELMET,
		gametypeCheck = null,
		be_special_flag = null,
		poll_time = 100,
		M = user,
		ignore_category = POLL_IGNORE_MONKEY_HELMET)

	//Some time has passed, and we could've been disintegrated for all we know (especially if we touch touch supermatter)
	if(QDELETED(src) || !user || magnification)
		return
	if(user.key || (src != user.head)) //Something important about the monkey changed, abort
		playsound(src, 'sound/machines/buzz-sigh.ogg', 30, TRUE)
		return
	if(!candidates.len)
		user.visible_message("<span class='notice'>[src] falls silent. Maybe you should try again later?</span>")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 30, TRUE)
		return
	var/mob/picked = pick(candidates)
	user.key = picked.key
	magnification = user.mind
	RegisterSignal(magnification, COMSIG_MIND_TRANSFER_TO, PROC_REF(disconnect))
	playsound(src, 'sound/machines/microwave/microwave-end.ogg', 100, FALSE)
	to_chat(user, "<span class='notice'>You're a mind magnified monkey! Protect your helmet with your life- if you lose it, your sentience goes with it!</span>")

/obj/item/clothing/head/monkey_sentience_helmet/Destroy()
	. = ..()
	disconnect()

/obj/item/clothing/head/monkey_sentience_helmet/proc/disconnect(datum/mind/signaller, mob/old, mob/current)
	SIGNAL_HANDLER
	if(!magnification)
		return
	UnregisterSignal(magnification, COMSIG_MIND_TRANSFER_TO)
	if(!current)
		current = magnification.current //In case we weren't called by COMSIG_MIND_TRANSFER_TO
	magnification = null
	to_chat(current, "<span class='userdanger'>You feel your flicker of sentience ripped away from you, as everything becomes dim...</span>")
	current.ghostize(FALSE)

	if(QDELING(src)) //The rest of this is stuff that would be pointless if we're being destroyed
		return
	if(old) //If the helmet was put through an attempted mind transfer, this is retribution
		playsound(src, 'sound/machines/buzz-sigh.ogg', 30, TRUE)
		playsound(src, "sparks", 100, TRUE)
		current.visible_message("<span class='warning'>[src] fizzles and breaks apart!</span>")
		new /obj/effect/decal/cleanable/ash/crematorium(drop_location()) //just in case they're in a locker or other containers it needs to use crematorium ash, see the path itself for an explanation
		qdel(src)
		return
	playsound(src, 'sound/machines/buzz-sigh.ogg', 30, TRUE)
	current.visible_message("<span class='warning'>[src] powers down!</span>")

/obj/item/clothing/head/monkey_sentience_helmet/attack_paw(mob/user)
	//Typecasting to monkey just to see if we're on the user's head
	if (!istype(user, /mob/living/carbon/monkey))
		return ..()
	var/mob/living/carbon/monkey/M = user
	if(src!=M.head)
		return ..()
	if(!magnification)
		return ..() //In case the monkey was already sentient

	//Spam? No thanks, we're good.
	if(COOLDOWN_FINISHED(src, message_cooldown))
		user.visible_message( \
		"<span class='warning'>[user.name] [user.p_are()] trying to take [src] off [user.p_their()] head!</span>", \
		"<span class='userdanger'>You feel a sharp pain as you take [src] off!</span>")
		COOLDOWN_START(src, message_cooldown, 5 SECONDS)

	//Give them a fair chance to realize they're about to commit mind death
	if (do_after(user, 8 SECONDS, user))
		return ..()
	return

/obj/item/clothing/head/monkey_sentience_helmet/dropped(mob/user)
	. = ..()
	disconnect()
