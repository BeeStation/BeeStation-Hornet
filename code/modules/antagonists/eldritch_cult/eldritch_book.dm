/obj/item/forbidden_book
	name = "Codex Cicatrix"
	desc = "Book describing the secrets of the veil."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "book"
	w_class = WEIGHT_CLASS_SMALL
	///Last person that touched this
	var/mob/living/last_user
	///Where we cannot create the rune?
	var/static/list/blacklisted_turfs = typecacheof(list(/turf/closed,/turf/open/space,/turf/open/lava))
	///Is it in use?
	var/in_use = FALSE
	var/list/remarks = list("Is that a whisper I hear?", "The letters twist and jumble...","It's starting to make sense...","The illustration is staring into my eyes!","I have seen this in a dream!","Have I seen this symbol somewhere else?","This is the place I've been dreaming about!","I've seen this in a recurring dream!","It's like this book is reaching out to me...","Ah! A greater purpose!","I was destined to read this!") 

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
	. += "You can create holes in reality and gain favor by activating influences with the cover of this book."
	. += "Any mortal that reads this book will gain fascination. Strike them with your Mansus Grasp to turn them into your disciples."

/obj/item/forbidden_book/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag || !IS_HERETIC(user) || in_use)
		return
	in_use = TRUE
	if(istype(target,/obj/effect/reality_smash))
		get_power_from_influence(target,user)
	in_use = FALSE

///Gives you a charge and destroys a corresponding influence
/obj/item/forbidden_book/proc/get_power_from_influence(atom/target, mob/user)	//why is this a proc? literally not called anywhere else
	var/obj/effect/reality_smash/RS = target
	to_chat(target, "<span class='danger'>You start drawing power from influence...</span>")
	var/datum/antagonist/heretic/cultie = user.mind.has_antag_datum(/datum/antagonist/heretic)
	if(cultie && do_after(user,10 SECONDS,FALSE,RS))
		cultie.gain_favor(1,FALSE)
		qdel(RS)
		

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
	if(!istype(user) || IS_HERETIC(user) || in_use)
		return FALSE
	if(HAS_TRAIT(user, TRAIT_MINDSHIELD))
		to_chat(user, "<span class='alert'>You feel the [name] trying to take over your mind!</span>")
		return FALSE
	if(victim.has_trauma_type(/datum/brain_trauma/fascination))
		to_chat(user, "<span class='alert'>Reading the [name] will not satisfy our thirst for knowledge!</span>")
		return FALSE
		
	to_chat(user, "<span class='notice'>You open the [name]...</span>")
	in_use = TRUE
	for(var/i=1, i<=pages_to_mastery, i++)
		if(!turn_page(user))
			to_chat(user, "<span class='notice'>You resist temptation and put the [name] down.</span>")
			in_use = FALSE
			return
	if(do_after(user,50, user))
		if (prob(30))
			user.gain_trauma(/datum/brain_trauma/fascination,TRAUMA_RESILIENCE_SURGERY)
		else
			if (prob(95))
				to_chat(user, "<span class='notice'>Your sanity slips away...</span>")
				user.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10, 160)
			else
				to_chat(user, "<span class='notice'>I must have offended the Gods somehow!</span>")
				new /mob/living/simple_animal/hostile/netherworld/blankbody(GetTurf(user))
		in_use = FALSE
	return TRUE

/obj/item/forbidden_book/proc/turn_page(mob/user)
	playsound(user, pick('sound/effects/pageturn1.ogg','sound/effects/pageturn2.ogg','sound/effects/pageturn3.ogg'), 30, 1)
	if(do_after(user,50, user))
		to_chat(user, "<span class='notice'>[pick(remarks)]</span>")
		return TRUE
	return FALSE

/obj/item/forbidden_book/ui_state(mob/user)
	return GLOB.default_state

/obj/item/forbidden_book/ui_data(mob/user)
	var/datum/antagonist/heretic/cultie = user.mind.has_antag_datum(/datum/antagonist/heretic)
	var/list/to_know = list()
	for(var/Y in cultie.get_researchable_knowledge())
		to_know += new Y
	var/list/known = cultie.get_all_knowledge()
	var/list/data = list()
	var/list/lore = list()

	data["charges"] = cultie.get_favor_left()

	for(var/X in to_know)
		lore = list()
		var/datum/eldritch_knowledge/EK = X
		lore["type"] = EK.type
		lore["name"] = EK.name
		lore["cost"] = EK.cost
		lore["disabled"] = EK.cost <= cultie.get_favor_left() ? FALSE : TRUE
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

//obj/item/forbidden_book/debug
//	charge = 100


/datum/brain_trauma/fascination	REVISE
	name = "Delirium"
	desc = "Patient's unconscious is completely enthralled by a word or sentence, focusing their thoughts and actions on it."
	scan_desc = "paranormalitis fascinitis"
	gain_text = ""
	lose_text = ""
	resilience = TRAUMA_RESILIENCE_SURGERY

/datum/brain_trauma/fascination/on_gain()
	message_admins("[ADMIN_LOOKUPFLW(owner)] has become fascinated.")
	log_game("[key_name(owner)] has become fascinated.")
	to_chat(owner, "<span class='boldwarning'>¤¤¤.</span>")
	var/obj/screen/alert/hypnosis/hypno_alert = owner.throw_alert("hypnosis", /obj/screen/alert/hypnosis)
	hypno_alert.desc = "¤¤¤."
	..()

/datum/brain_trauma/fascination/on_lose()
	message_admins("[ADMIN_LOOKUPFLW(owner)] is no longer fascinated.")
	log_game("[key_name(owner)] is no longer fascinated.")
	to_chat(owner, "<span class='userdanger'>¤¤¤.</span>")
	owner.clear_alert("hypnosis")
	..()