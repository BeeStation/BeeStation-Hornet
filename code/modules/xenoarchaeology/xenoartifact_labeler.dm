/obj/item/xenoartifact_labeler
	name = "Xenoartifact Labeler"
	icon = 'icons/obj/xenoarchaeology/xenoartifact_tech.dmi'
	icon_state = "xenoartifact_labeler"
	desc = "A tool scientists use to label their alien bombs."
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY

	var/list/activator = list() //Checked trait
	var/list/activator_traits = list() //Display names

	var/list/minor_trait = list()
	var/list/minor_traits = list()

	var/list/major_trait = list()
	var/list/major_traits = list()

	var/list/malfunction = list()
	var/list/malfunction_list = list()  

	var/list/info_list = list() //trait dialogue essentially

	var/sticker_name //Name artifacts something pretty
	var/list/sticker_traits = list()//passed down to sticker

/obj/item/xenoartifact_labeler/Initialize()
	. = ..()

/obj/item/xenoartifact_labeler/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "XenoartifactLabeler")
		ui.open()

/obj/item/xenoartifact_labeler/ui_data(mob/user)
	var/list/data = list()
	data["activator"] = activator
	data["activator_traits"] = get_trait_list_desc(activator_traits, /datum/xenoartifact_trait/activator)

	data["minor_trait"] = minor_trait
	data["minor_traits"] = get_trait_list_desc(minor_traits, /datum/xenoartifact_trait/minor)

	data["major_trait"] = major_trait
	data["major_traits"] = get_trait_list_desc(major_traits, /datum/xenoartifact_trait/major)

	data["malfunction"] = malfunction
	data["malfunction_list"] = get_trait_list_desc(malfunction_list, /datum/xenoartifact_trait/malfunction)

	data["info_list"] = info_list

	return data

/obj/item/xenoartifact_labeler/ui_act(action, params)
	if(..())
		return

	if(action == "print_traits")
		create_label(sticker_name)
		return

	if(action == "change_print_name" && istext(params["name"]))
		sticker_name = sanitize_text("[params["name"]]")
		return

	trait_toggle(action, "activator", activator_traits, activator)
	trait_toggle(action, "minor", minor_traits, minor_trait)
	trait_toggle(action, "major", major_traits, major_trait)
	trait_toggle(action, "malfunction", malfunction_list, malfunction)

	. = TRUE
	update_icon()

/obj/item/xenoartifact_labeler/proc/get_trait_list_desc(list/traits, trait_type)//Get a list of all the specified trait types names, actually
	trait_type = typesof(trait_type)
	for(var/t in trait_type)
		var/datum/xenoartifact_trait/X = t
		if(initial(X.desc) && !(initial(X.desc) in traits) && !(initial(X.label_name)))
			traits += initial(X.desc)
		else if(initial(X.label_name) && !(initial(X.label_name) in traits)) //For cases where the trait doesn't have a desc or is tool cool to use one
			traits += initial(X.label_name)
	return traits

/obj/item/xenoartifact_labeler/proc/look_for(list/place, culprit) //This isn't really needed but, It's easier to use as a function. What does this even do?
	for(var/X in place) //Using locate breaks this. Sorry.
		if(X == culprit)
			. = TRUE
	return

/obj/item/xenoartifact_labeler/afterattack(atom/target, mob/user)
	..()
	var/obj/item/xenoartifact_label/P = create_label(sticker_name)
	if(!P.afterattack(target, user, TRUE)) //In the circumstance the sticker fails, usually means you're doing something you shouldn't be
		qdel(P)

/obj/item/xenoartifact_labeler/proc/create_label(new_name)
	var/obj/item/xenoartifact_label/P = new(get_turf(src))
	if(new_name)
		P.name = new_name
		P.set_name = TRUE
	P.trait_list = sticker_traits
	P.info = activator+minor_trait+major_trait
	return P

/obj/item/xenoartifact_labeler/proc/trait_toggle(action, toggle_type, var/list/trait_list, var/list/active_trait_list)
	var/datum/xenoartifact_trait/description_holder
	var/new_trait
	for(var/t in trait_list)
		new_trait = desc2datum(t)
		description_holder = new_trait
		if(action == "assign_[toggle_type]_[t]")
			if(!look_for(active_trait_list, t))
				active_trait_list += t
				info_list += initial(description_holder.label_desc)
				sticker_traits += new_trait
			else
				active_trait_list -= t
				info_list -= initial(description_holder.label_desc)
				sticker_traits -= new_trait

/obj/item/xenoartifact_labeler/proc/desc2datum(udesc) //This is just a hacky way of getting the info from a datum using its desc becuase I wrote this last and it's not heartbreaking
	for(var/t in typesof(/datum/xenoartifact_trait))
		var/datum/xenoartifact_trait/X = t
		if((udesc == initial(X.desc))||(udesc == initial(X.label_name)))
			return t
	return "[udesc]: There's no known information on [udesc]!."

// Not to be confused with labeler
/obj/item/xenoartifact_label
	icon = 'icons/obj/xenoarchaeology/xenoartifact_sticker.dmi'
	icon_state = "sticker_star"
	name = "Xenoartifact Label"
	desc = "An adhesive label describing the characteristics of a Xenoartifact."
	var/info = "" 
	var/set_name = FALSE

	var/mutable_appearance/sticker_overlay

	var/list/trait_list = list() //List of traits used to compare and generate modifier.

/obj/item/xenoartifact_label/Initialize()
	icon_state = "sticker_[pick("star", "box", "tri", "round")]"
	var/sticker_state = "[icon_state]_small"
	sticker_overlay = mutable_appearance(icon, sticker_state)
	sticker_overlay.layer = FLOAT_LAYER
	sticker_overlay.appearance_flags = RESET_ALPHA
	sticker_overlay.appearance_flags = RESET_COLOR
	..()
	
/obj/item/xenoartifact_label/afterattack(atom/target, mob/user, instant = FALSE)
	if(istype(target, /mob/living))
		to_chat(target, "<span class='warning'>[user] attempts to stick a [src] to you!</span>")
		to_chat(user, "<span class='warning'>You attempt to stick a [src] on [target]!</span>")
		if(do_after(user, 30, target = target))
			if(!user.temporarilyRemoveItemFromInventory(src))
				return
		else
			return
		add_sticker(target)
		addtimer(CALLBACK(src, .proc/remove_sticker, target), 15 SECONDS)
		return TRUE
	else if(istype(target, /obj/item/xenoartifact))
		var/obj/item/xenoartifact/X = target
		if(locate(/obj/item/xenoartifact_label) in X)
			if(set_name) //You can update the now, that's cool
				X.name = name
			to_chat(user, "<span class='notice'>There's no space left to attach another sticker!</span>")
			return
		calculate_modifier(X)
		add_sticker(X)
		if(set_name)
			X.name = name
		if(info)
			var/textinfo = list2text(info)
			X.desc = "[X.desc] There's a sticker attached, it says-\n[textinfo]"
		return TRUE
	
/obj/item/xenoartifact_label/proc/add_sticker(mob/target)
	target.add_overlay(sticker_overlay)
	forceMove(target)

/obj/item/xenoartifact_label/proc/remove_sticker(mob/target) //Peels off
	target.cut_overlay(sticker_overlay)
	forceMove(get_turf(target))

/obj/item/xenoartifact_label/proc/calculate_modifier(obj/item/xenoartifact/X) //Modifier based off preformance of slueth. To:Do revisit this, complexity would be nice
	var/datum/xenoartifact_trait/trait
	var/datum/component/xenoartifact_pricing/xenop = X.GetComponent(/datum/component/xenoartifact_pricing)
	if(!xenop)
		return
	xenop.modifier = initial(xenop.modifier)
	for(var/t in trait_list)
		trait = new t
		if(X.get_trait(trait))
			xenop.modifier += 0.15 
		else
			xenop.modifier -= 0.35

/obj/item/xenoartifact_label/proc/list2text(list/listo) //list2params acting weird. Probably already a function for this.
	var/text = ""
	for(var/X in listo)
		if(X)
			text = "[text] [X]\n"
	return text

/obj/item/xenoartifact_label/Destroy()
	. = ..()
	loc?.cut_overlay(sticker_overlay)

/obj/item/xenoartifact_labeler/debug
	name = "Xenoartifact Debug Labeler"      
	desc = "Use to create specific Xenoartifacts" 

/obj/item/xenoartifact_labeler/debug/afterattack(atom/target, mob/user)
	return

/obj/item/xenoartifact_labeler/debug/create_label(new_name)
	var/obj/item/xenoartifact/A = new(get_turf(loc), XENOA_DEBUGIUM)
	say("Created [A] at [A.loc]")
	A.charge_req = 100
	A.malfunction_mod = 0
	A.malfunction_chance = 0
	qdel(A.traits)
	A.traits = list()
	for(var/X in sticker_traits) //Add new ones
		say(X)
		A.traits += new X
	for(var/datum/xenoartifact_trait/t as() in A.traits) //Setup new ones
		t.on_init(A)
	A = null
