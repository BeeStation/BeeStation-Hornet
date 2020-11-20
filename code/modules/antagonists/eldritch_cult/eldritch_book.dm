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
	var/list/failure_reads = list("Did something whisper my name?", "It's just shapes and scribbles!","This page is just blank...","Are these the scribbles of a madman?","These sketches don't resemble anything.")
	var/list/success_reads = list("The letters begin to twist and jumble...","It's starting to make sense.","The illustration is staring me right in the eyes!","Have I seen this symbol somewhere else?","This is the place I've been dreaming about!","I've seen this in a recurring dream!","This part is in Galactic Common.","It's like this book is reaching out to me...","Was I destined to read this?",)

/obj/item/forbidden_book/Destroy()
	last_user = null
	. = ..()

/obj/item/forbidden_book/examine(mob/user)
	. = ..()
	if(!IS_HERETIC(user))
		return
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
	in_use = TRUE
	if(istype(target,/obj/effect/reality_smash))
		//Gives you a charge and destroys a corresponding influence
		var/obj/effect/reality_smash/RS = target
		to_chat(target, "<span class='danger'>You start drawing power from influence...</span>")
		var/datum/antagonist/heretic/cultie = user.mind.has_antag_datum(/datum/antagonist/heretic)
		if(cultie && do_after(user,10 SECONDS,FALSE,RS))
			to_chat(target, "<span class='notice'>You rupture the seal between this world and the other, increasing the influence of your Gods!</span>")
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

/obj/item/forbidden_book/attack_self(mob/living/carbon/human/user)
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
	for(var/i=1, i<=rand(2,5), i++)
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
	return FALSE

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

/datum/brain_trauma/fascination
	name = "Delirium"
	desc = "Patient is deluded into believing that omnipotent extraterestrial entities meddle in our world."
	scan_desc = "lovecraftian madness"
	gain_text = "Ah! A greater purpose."
	lose_text = "You come to the realization that there are no omnipotent Gods that can save you from the monotony of your day-to-day job."
	resilience = TRAUMA_RESILIENCE_SURGERY

/datum/brain_trauma/fascination/on_gain()
	message_admins("[ADMIN_LOOKUPFLW(owner)] has become fascinated.")	//self antag warning?
	log_game("[key_name(owner)] has become fascinated.")


	to_chat(owner, "<span class='warning'>Whether it is through your own foolishness, or through a ritual performed by someone practicing the forbidden arts, you have become FASCINATED!<br>\
		Entities of amazing power have reached out to you, but because of your limited knowledge, you were unable to understand and respond to their message!<br>\
		But there are people who can help! Seek them out, so they can help you find method to your madness! Seek Answers!</span>")
	to_chat(owner, "<span class='boldwarning'>You are NOT an antagonist, and should not perform evil acts to accomplis your goal.</span>")

	var/obj/screen/alert/hypnosis/hypno_alert = owner.throw_alert("hypnosis", /obj/screen/alert/hypnosis)
	hypno_alert.desc = "Seek Answers!"

	..()

/datum/brain_trauma/fascination/on_lose()
	message_admins("[ADMIN_LOOKUPFLW(owner)] is no longer fascinated.")
	log_game("[key_name(owner)] is no longer fascinated.")
	owner.clear_alert("hypnosis")
	..()

/datum/brain_trauma/fascination/on_life()
	if(prob(2))
		var/message = pick(
			"The strange figurines! They must be related to this!",			//strange figurines
			"I must collect those strange figurines!",
			"Could those strange figurines be somewhat related?",
			"Flesh... Ash... Rust... What do all these have in common?",	//refferencing heretics
			"Follow the trail of rust, it said. Trail of rust?",
			"The witch of ashes can answer your questions...",
			"Beautiful creatures forged out of of flesh and bone.",
			"A book... Written in blood and bile?",							//the book
			"Codex Cich... Chika... Rex... Cicatrix?",
			"A hook blade. A hook blade?",									//the items
			"Those who wear ashen eyes around their neck?",
			"Mansus... Do you know of the Mansus? What is the Mansus?",
			"Security is actively trying to suppress my quest!",			//avoid security
			"Those in command know more then they lead on! And they're trying to hide it!",
			"Under strange aeons, even death may die!",						//lovecraft refference
		)
		to_chat(owner, "<span class='hypnophrase'>[message]</span>")

/datum/brain_trauma/fascination/on_hear(message, speaker, message_language, raw_message, radio_freq)	//copy paste from phobia, good idea?
	if(!owner.can_hear())
		return message

	var/list/trigger_words = list( "heretic","curse","magic","eldritch","god" )

	for(var/word in trigger_words)
		var/regex/reg = regex("(\\b|\\A)[REGEX_QUOTE(word)]'?s*(\\b|\\Z)", "i")

		if(findtext(raw_message, reg))
			message = reg.Replace(message, "<span class='phobia'>$1</span>")
			break
	return message