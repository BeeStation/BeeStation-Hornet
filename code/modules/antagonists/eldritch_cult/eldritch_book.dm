/obj/item/forbidden_book
	name = "Codex Cicatrix"
	desc = "Book describing the secrets of the veil."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "book"
	w_class = WEIGHT_CLASS_SMALL
	///Last person that touched this
	var/mob/living/last_user
	///how many charges do we have?
	var/charge = 1
	///Where we cannot create the rune?
	var/static/list/blacklisted_turfs = typecacheof(list(/turf/closed,/turf/open/space,/turf/open/lava))
	///Is it in use?
	var/in_use = FALSE

/obj/item/forbidden_book/Destroy()
	last_user = null
	. = ..()


/obj/item/forbidden_book/examine(mob/user)
	. = ..()
	if(!IS_HERETIC(user))
		return
	. += "The Tome holds [charge] charges."
	. += "Use it on the floor to create a transmutation rune, used to perform rituals."
	. += "Hit an influence in the black part with it to gain a charge."
	. += "Hit a transmutation rune to destroy it."

/obj/item/forbidden_book/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag || !IS_HERETIC(user) || in_use)
		return
	in_use = TRUE
	if(istype(target,/obj/effect/eldritch))
		remove_rune(target,user)
	if(istype(target,/obj/effect/reality_smash))
		get_power_from_influence(target,user)
	if(istype(target,/turf/open))
		draw_rune(target,user)
	in_use = FALSE

///Gives you a charge and destroys a corresponding influence
/obj/item/forbidden_book/proc/get_power_from_influence(atom/target, mob/user)
	var/obj/effect/reality_smash/RS = target
	to_chat(target, "<span class='danger'>You start drawing power from influence...</span>")
	if(do_after(user,10 SECONDS,FALSE,RS))
		qdel(RS)
		charge += 1

///Draws a rune on a selected turf
/obj/item/forbidden_book/proc/draw_rune(atom/target,mob/user)

	for(var/turf/T in range(1,target))
		if(is_type_in_typecache(T, blacklisted_turfs))
			to_chat(target, "<span class='warning'>The terrain doesn't support runes!</span>")
			return
	var/A = get_turf(target)
	to_chat(user, "<span class='danger'>You start drawing a rune...</span>")

	if(do_after(user,30 SECONDS,FALSE,A))

		new /obj/effect/eldritch/big(A)


///Removes runes from the selected turf
/obj/item/forbidden_book/proc/remove_rune(atom/target,mob/user)

	to_chat(user, "<span class='danger'>You start removing a rune...</span>")
	if(do_after(user,2 SECONDS,user))
		qdel(target)


/obj/item/forbidden_book/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state) // Remember to use the appropriate state.
	if(!IS_HERETIC(user))
		return FALSE
	last_user = user
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		icon_state = "book_open"
		flick("book_opening",src)
		ui = new(user, src, ui_key, "ForbiddenLore", name, 500, 900, master_ui, state)
		ui.open()

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
