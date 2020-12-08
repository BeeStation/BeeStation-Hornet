/obj/item/forbidden_book
	name = "Codex Cicatrix"
	desc = "Book describing the secrets of the veil."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "book"
	w_class = WEIGHT_CLASS_SMALL
	///Last person that touched this
	var/mob/living/last_user
	///Is it in use?
	var/in_use = FALSE
	var/charge = 0

/obj/item/forbidden_book/Destroy()
	last_user = null
	. = ..()

/obj/item/forbidden_book/examine(mob/user)
	. = ..()
	if(!IS_HERETIC(user))
		return
	//revise
	//. += "The Tome holds [charge] charges."
	//. += "Use it on the floor to create a transmutation rune, used to perform rituals."
	//. += "Hit an influence in the black part with it to gain a charge."
	//. += "Hit a transmutation rune to destroy it."
	. += "Any mortal that reads this book will gain fascination. Baptise them with your Mansus Grasp to turn them into your disciples."
	var/datum/antagonist/heretic/cultie = user.mind.has_antag_datum(/datum/antagonist/heretic)
	. +=  "You have earned [cultie.get_favor_left()] favor for your deeds."
	for (var/EK in cultie.get_all_knowledge())
		var/datum/eldritch_knowledge/known = EK
		if (istype(known))
			. +=  known.desc

/obj/item/forbidden_book/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag || !IS_HERETIC(user) || in_use)
		return
	var/datum/antagonist/heretic/cultie = user.mind.has_antag_datum(/datum/antagonist/heretic)
	var/mob/living/carbon/human/victim = target
	in_use = TRUE
	if (istype(victim) && victim.stat != DEAD && cultie.get_knowledge(/datum/eldritch_knowledge/dreamgate))
		to_chat(user,"<span class='warning'>You open the [src] and start assaulting the mind of [victim]!</span>")
		icon_state = "book_open"
		flick("book_opening",src)
		if (do_after(user,10 SECONDS,victim))
			user.whisper("That is not dead which can eternal lie...", language = /datum/language/common)
			var/dream_text = pick ("a hooded figurine","dead bodies, as far as the eye can see","whispering","opens a third eye","grows tentacles", "the monster of a thousand hands","beautiful creatures made out of of flesh and bone","a book... written in blood and bile")
			to_chat(victim, "<span class='warning'>... [dream_text]...</span>")
			if (do_after(user,10 SECONDS,victim) && !QDELETED(victim) && victim.stat != DEAD && victim.IsSleeping())
				user.whisper("And with strange aeons even death may die...", language = /datum/language/common)
				switch (cultie.enslave(victim))
					if (0)
						victim.SetSleeping(0)
						to_chat(user,"<span class='warning'>You corrupt the mind of [victim] and is now bound to do your bidding...</span>")
					if (3)
						to_chat(user,"<span class='warning'>You cannot enslave this mind!</span>")
					if (2)
						to_chat(user,"<span class='notice'>[victim] has no mind to enslave!</span>")
					if (1)
						to_chat(user, "<span class='notice'>You sense a weak mind, but your powers are not strong enough to take it over!</span>")

		flick("book_closing",src)
		icon_state = initial(icon_state)
	if(istype(target,/obj/effect/reality_smash))
		//Gives you a charge and destroys a corresponding influence
		var/obj/effect/reality_smash/RS = target
		to_chat(target, "<span class='danger'>You start drawing power from influence...</span>")
		if(cultie && do_after(user,10 SECONDS,FALSE,RS))
			to_chat(target, "<span class='notice'>You rupture the seal between this world and the other, increasing the influence of your Gods!</span>")	//this is never explained
			cultie.gain_favor(5)
			qdel(RS)
	in_use = FALSE
	..()

/obj/item/forbidden_book/ui_interact(mob/user, datum/tgui/ui = null)
	if(!IS_HERETIC(user))
		return FALSE
	last_user = user
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		icon_state = "book_open"
		flick("book_opening",src)
		ui = new(user, src, "ForbiddenLore")
		ui.open()

/*/obj/item/forbidden_book/attack_self(mob/living/carbon/human/user)
	if(!istype(user) || in_use)
		return FALSE
	if (IS_HERETIC(user))
		ui_interact(user)
		return FALSE
	if(HAS_TRAIT(user, TRAIT_MINDSHIELD))
		to_chat(user, "<span class='alert'>The pages of [src] appear empty to you!</span>")
		return FALSE
	if(user.has_trauma_type(/datum/brain_trauma/fascination))
		to_chat(user, "<span class='alert'>Reading the [name] again will not satisfy your thirst for knowledge!</span>")
		return FALSE

	to_chat(user, "<span class='notice'>You start reading the [name]...</span>")
	in_use = TRUE

	var/success = FALSE
	for(var/i in 1 to rand(2,5))
		if (!success)
			success = prob(5)
		if(!turn_page(user,success))
			to_chat(user, "<span class='notice'>You resist temptation and put the [name] down.</span>")
			in_use = FALSE
			return FALSE
	if(do_after(user,3 SECONDS, user))
		if (success)
			user.gain_trauma(/datum/brain_trauma/fascination,TRAUMA_RESILIENCE_SURGERY)
		else
			if (prob(95))
				to_chat(user, "<span class='notice'>Your sanity slips away...</span>")
				user.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5, 160)
			else
				to_chat(user, "<span class='notice'>You must have offended the Gods somehow!</span>")
				new /mob/living/simple_animal/hostile/netherworld/blankbody(get_turf(user))
	in_use = FALSE
	return TRUE

/obj/item/forbidden_book/proc/turn_page(mob/user,var/success)
	playsound(user, pick('sound/effects/pageturn1.ogg','sound/effects/pageturn2.ogg','sound/effects/pageturn3.ogg'), 30, 1)
	if(do_after(user,3 SECONDS, user))
		if (success)
			to_chat(user, "<span class='notice'>[pick(success_reads)]</span>")
		else
			to_chat(user, "<span class='notice'>[pick(failure_reads)]</span>")
		return TRUE
	return FALSE*/

/obj/item/forbidden_book/ui_state(mob/user)
	return GLOB.default_state

/obj/item/forbidden_book/ui_data(mob/user)
	var/datum/antagonist/heretic/cultie = user.mind.has_antag_datum(/datum/antagonist/heretic)

	var/charge = cultie.get_favor_left()
	var/list/to_know = list()
	for(var/Y in cultie.get_researchable_knowledge())
		to_know += new Y
	var/list/known = cultie.get_all_knowledge()
	var/list/data = list()
	var/list/lore = list()

	data["charges"] = charge

	for(var/X in to_know)
		lore = list()
		var/datum/eldritch_knowledge/EK = X
		lore["type"] = EK.type
		lore["name"] = EK.name
		lore["cost"] = EK.cost
		lore["disabled"] = EK.cost <= charge ? FALSE : TRUE
		lore["path"] = EK.route
		lore["state"] = "Research"
		lore["flavour"] = EK.gain_text
		lore["desc"] = EK.desc
		data["to_know"] += list(lore)

	for(var/X in known)
		lore = list()
		var/datum/eldritch_knowledge/EK = known[X]
		lore["name"] = EK.name
		lore["cost"] = EK.cost
		lore["disabled"] = TRUE
		lore["path"] = EK.route
		lore["state"] = "Researched"
		lore["flavour"] = EK.gain_text
		lore["desc"] = EK.desc
		data["to_know"] += list(lore)

	if(!length(data["to_know"]))
		data["to_know"] = null

	return data

/obj/item/forbidden_book/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("research")
			var/datum/antagonist/heretic/cultie = last_user.mind.has_antag_datum(/datum/antagonist/heretic)
			var/ekname = params["name"]
			for(var/X in cultie.get_researchable_knowledge())
				var/datum/eldritch_knowledge/EK = X
				if(initial(EK.name) != ekname)
					continue
				if(cultie.gain_knowledge(EK))
					cultie.spend_favor(text2num(params["cost"]))
					return TRUE

	update_icon() // Not applicable to all objects.

/obj/item/forbidden_book/ui_close(mob/user)
	flick("book_closing",src)
	icon_state = initial(icon_state)
	return ..()
