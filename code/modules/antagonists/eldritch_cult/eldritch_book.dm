/obj/item/forbidden_book
	name = "Codex Cicatrix"
	desc = "This book describes the secrets of the veil between worlds."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "book"
	w_class = WEIGHT_CLASS_SMALL
	///Last person that touched this
	var/mob/living/last_user
	///how many charges do we have?
	var/charge = 1
	///Is it in use?
	var/in_use = FALSE

/obj/item/forbidden_book/empty
	charge = 0

/obj/item/forbidden_book/Destroy()
	last_user = null
	. = ..()


/obj/item/forbidden_book/examine(mob/user)
	. = ..()
	if(!IS_HERETIC(user))
		return
	. += "The Tome holds [charge] charges."
	. += "Hit an influence in the black part with it to gain a charge."

/obj/item/forbidden_book/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag || !IS_HERETIC(user) || in_use)
		return
	in_use = TRUE
	if(istype(target,/obj/effect/reality_smash))
		get_power_from_influence(target,user)
	in_use = FALSE

///Gives you a charge and destroys a corresponding influence
/obj/item/forbidden_book/proc/get_power_from_influence(atom/target, mob/user)
	var/obj/effect/reality_smash/RS = target
	to_chat(target, "<span class='danger'>You start drawing power from influence...</span>")
	if(do_after(user,10 SECONDS,FALSE,RS))
		qdel(RS)
		charge += 1


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
					charge -= text2num(params["cost"])
					return TRUE

	update_icon() // Not applicable to all objects.

/obj/item/forbidden_book/ui_close(mob/user)
	flick("book_closing",src)
	icon_state = initial(icon_state)
	return ..()

/obj/item/forbidden_book/debug
	charge = 100
