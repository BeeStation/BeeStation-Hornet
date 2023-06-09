/obj/item/clothing/head/mind_monkey_helmet/monkey_sentience
	name = "monkey mind magnification helmet"
	desc = "A fragile, circuitry embedded helmet for boosting the intelligence of a monkey to a higher level. You see several warning labels..."

	base_icon_state = "monkeymind"
	icon_state = "monkeymind1" //For mapping?
	item_state = "monkeymind"
	strip_delay = 100
	var/cooldown_expiry //It'll get annoying quick when someone tries to remove their own helmet 20 times a second
	var/mob/living/carbon/monkey/magnification = null ///if the helmet is on a valid target (just works like a normal helmet if not (cargo please stop))
	var/polling = FALSE///if the helmet is currently polling for targets (special code for removal)

/obj/item/clothing/head/mind_monkey_helmet/monkey_sentience/Initialize()
	. = ..()
	base_icon_state = "[base_icon_state][rand(1,3)]"
	update_icon()

/obj/item/clothing/head/mind_monkey_helmet/monkey_sentience/update_icon(updates)
	. = ..()
	if (magnification)
		icon_state = "[base_icon_state]up"
		return
	icon_state = "[base_icon_state]"


/obj/item/clothing/head/mind_monkey_helmet/monkey_sentience/examine(mob/user)
	. = ..()
	. += "<span class='boldwarning'>---WARNING: REMOVAL OF HELMET ON SUBJECT MAY LEAD TO:---</span>"
	. += "<span class='warning'>BLOOD RAGE</span>"
	. += "<span class='warning'>BRAIN DEATH</span>"
	. += "<span class='warning'>PRIMAL GENE ACTIVATION</span>"
	. += "<span class='warning'>GENETIC MAKEUP MASS SUSCEPTIBILITY</span>"
	. += "<span class='boldnotice'>Ask your CMO if mind magnification is right for you.</span>"

/obj/item/clothing/head/mind_monkey_helmet/monkey_sentience/equipped(mob/user, slot)
	. = ..()
	if(slot != ITEM_SLOT_HEAD)
		return
	if(!ismonkey(user) || user.ckey)
		var/mob/living/something = user
		to_chat(something, "<span class='boldnotice'>You feel a stabbing pain in the back of your head for a moment.</span>")
		something.apply_damage(5,BRUTE,BODY_ZONE_HEAD,FALSE,FALSE,FALSE) //notably: no damage resist (it's in your helmet), no damage spread (it's in your helmet)
		playsound(src, 'sound/machines/buzz-sigh.ogg', 30, TRUE)
		return
	magnification = user //this polls ghosts
	visible_message("<span class='warning'>[src] powers up!</span>")
	playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
	polling = TRUE
	var/list/candidates = pollCandidatesForMob("Do you want to play as a mind magnified monkey?", ROLE_SENTIENCE, null, ROLE_SENTIENCE, 50, magnification, POLL_IGNORE_SENTIENCE_POTION)
	polling = FALSE
	if(!candidates.len)
		magnification = null
		visible_message("<span class='notice'>[src] falls silent. Maybe you should try again later?</span>")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 30, TRUE)
	else
		var/mob/picked = pick(candidates)
		magnification.key = picked.key
		playsound(src, 'sound/machines/microwave/microwave-end.ogg', 100, FALSE)
		to_chat(magnification, "<span class='notice'>You're a mind magnified monkey! Protect your helmet with your life- if you lose it, your sentience goes with it!</span>")
		update_icon()

/obj/item/clothing/head/mind_monkey_helmet/monkey_sentience/Destroy()
	. = ..()
	disconnect()

/obj/item/clothing/head/mind_monkey_helmet/monkey_sentience/proc/disconnect()
	if(!magnification) //not put on a viable head
		return
	if(!polling)//put on a viable head, but taken off after polling finished.
		if(magnification.client)
			to_chat(magnification, "<span class='userdanger'>You feel your flicker of sentience ripped away from you, as everything becomes dim...</span>")
			magnification.ghostize(FALSE)
		if(prob(10))
			magnification.apply_damage(500,BRAIN,BODY_ZONE_HEAD,FALSE,FALSE,FALSE) //brain death
		magnification = null
		update_icon()
	else
		//either used up correctly or taken off before polling finished (punish this by destroying the helmet)
		playsound(src, 'sound/machines/buzz-sigh.ogg', 30, TRUE)
		playsound(src, "sparks", 100, TRUE)
		visible_message("<span class='warning'>[src] fizzles and breaks apart!</span>")
		magnification = null
		new /obj/effect/decal/cleanable/ash/crematorium(drop_location()) //just in case they're in a locker or other containers it needs to use crematorium ash, see the path itself for an explanation
		qdel(src)

/obj/item/clothing/head/mind_monkey_helmet/monkey_sentience/dropped(mob/user)
	. = ..()
	disconnect()

/obj/item/clothing/head/mind_monkey_helmet/monkey_sentience/attack_paw(mob/user)
	//Typecasting to monkey just to see if we're on the user's head
	if (!istype(user, /mob/living/carbon/monkey))
		return ..()
	var/mob/living/carbon/monkey/M = user
	if(src!=M.head)
		return ..()

	//Spam? No thanks, we're good.
	if(cooldown_expiry > world.time)
		return
	cooldown_expiry = world.time

	//Give them a fair chance to realize they're about to commit mind death
	user.visible_message("<span class='userdanger'>You feel a sharp pain as you take the [src] off!</span>", \
		"<span class='warning'>[user.name] [user.p_are()] trying to take the [src] off [user.p_their()] head!</span>")
	if (do_after(user, 8 SECONDS, user))
		return ..()
	return
