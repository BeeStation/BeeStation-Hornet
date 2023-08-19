/obj/item/clothing/head/monkey_sentience_helmet
	name = "Monkey mind-magnification helmet"
	desc = "This helmet rapidly stimulates a monkey's mind to increase brain function, and in turn enables critical thinking skills."

	flags_inv = HIDEHAIR
	icon_state = "monkeymind"
	base_icon_state = "monkeymind"
	strip_delay = 100
	clothing_flags = EFFECT_HAT | SNUG_FIT
	COOLDOWN_DECLARE(message_cooldown) //It'll get annoying quick when someone tries to remove their own helmet 20 times a second
	var/datum/mind/magnification = null ///A reference to the mind we govern

/obj/item/clothing/head/monkey_sentience_helmet/update_icon()
	. = ..()
	compile_monkey_icon()
	if(ismob(loc))
		var/mob/mob = loc
		mob.update_inv_head()

/obj/item/clothing/head/monkey_sentience_helmet/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state][magnification ? "_active" : ""]"

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
	if (user.stat) //Checks if the monkey is dead.
		playsound(src, 'sound/machines/buzz-sigh.ogg', 30, TRUE) //If so, buzz and do not poll ghosts
		return
	user.visible_message("<span class='warning'>[src] powers up!</span>")
	playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
	var/list/candidates = pollCandidatesForMob(
		Question = "Do you want to play as a mind magnified monkey?",
		jobbanType = ROLE_MONKEY_HELMET,
		role_preference_key = null,
		poll_time = 100,
		M = user,
		ignore_category = POLL_IGNORE_MONKEY_HELMET)

	//Some time has passed, and we could've been disintegrated for all we know (especially if we touch touch supermatter), or monkey has died
	if(QDELETED(src) || !user || magnification || user.stat)
		return
	if(user.key || (src != user.head)) //Something important about the monkey changed, abort
		user.visible_message("<span class='notice'>[src] powers down!</span>")
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
	RegisterSignal(magnification.current, COMSIG_MOB_LOGOUT, PROC_REF(disconnect))
	playsound(src, 'sound/machines/microwave/microwave-end.ogg', 100, FALSE)

	update_icon()
	to_chat(user, "<span class='notice'>You're a mind magnified monkey! Protect your helmet with your life; if you lose it, your sentience goes with it! Your helmet also strongly compels you to assist Nanotrasen and you should always act with the best interests of the station in mind.</span>")


/obj/item/clothing/head/monkey_sentience_helmet/Destroy()
	disconnect()
	. = ..()

/obj/item/clothing/head/monkey_sentience_helmet/on_mob_death(mob/living/L, gibbed)
	if(magnification.current == L)
		disconnect()

/obj/item/clothing/head/monkey_sentience_helmet/proc/disconnect(datum/mind/signaller, mob/old_mob, mob/new_mob)
	SIGNAL_HANDLER
	if(!magnification)
		return
	UnregisterSignal(magnification, COMSIG_MIND_TRANSFER_TO)
	UnregisterSignal(magnification.current, COMSIG_MOB_LOGOUT)
	var/mob/living/monkey = new_mob || magnification.current
	if (!monkey)
		CRASH("A mind registered to a disconnecting monkey sentience helmet doesn't have a current mob!")
	to_chat(monkey, "<span class='userdanger'>You feel your flicker of sentience ripped away from you, as everything becomes dim...</span>")
	monkey.ghostize(FALSE)
	QDEL_NULL(magnification) //This should be safe to do

	if(QDELING(src))
		return
	if(old_mob) //If the helmet was put through an attempted mind transfer, this is retribution
		playsound(src, 'sound/machines/buzz-sigh.ogg', 30, TRUE)
		playsound(src, "sparks", 100, TRUE)
		old_mob.visible_message("<span class='warning'>[src] fizzles and breaks apart!</span>")
		new /obj/effect/decal/cleanable/ash/crematorium(drop_location())
		qdel(src)
		return
	else
		playsound(src, 'sound/machines/buzz-sigh.ogg', 30, TRUE)
		update_icon()
		monkey.visible_message("<span class='warning'>[src] powers down!</span>")

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
