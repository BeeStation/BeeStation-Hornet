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
