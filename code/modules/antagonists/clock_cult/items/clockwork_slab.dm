/obj/item/clockwork/clockwork_slab
	name = "Clockwork Slab"
	desc = "A mechanical-looking device filled with intricate cogs that swirl to their own accord."
	clockwork_desc = "A beautiful work of art, harnessing mechanical energy for a variety of useful powers."
	icon_state = "dread_ipad"
	lefthand_file = 'icons/mob/inhands/antag/clockwork_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/clockwork_righthand.dmi'

	var/datum/clockcult/scripture/invoking_scripture
	var/datum/progressbar/invokation_bar

	var/holder_class
	var/list/scriptures = list()

	var/charge_overlay

	//Initialise an empty list for quickbinding
	var/list/quick_bound_scriptures = list(
		1 = null,
		2 = null,
		3 = null,
		4 = null,
		5 = null
	)

	//The default scriptures that get auto-assigned.
	var/list/default_scriptures = list(
		/datum/clockcult/scripture/abscond,
		/datum/clockcult/scripture/slab/kindle,
		/datum/clockcult/scripture/slab/hateful_manacles
	)

/obj/item/clockwork/clockwork_slab/Initialize()
	var/pos = 1
	for(var/script in default_scriptures)
		if(!script)
			continue
		var/datum/clockcult/scripture/default_script = new script
		message_admins("Assigning [default_script.name] to [name]")
		bind_spell(null, default_script, pos++)
	..()

/obj/item/clockwork/clockwork_slab/dropped(mob/user)
	//Clear quickbinds
	for(var/datum/action/innate/clockcult/quick_bind/script in quick_bound_scriptures)
		script.Remove(user)
	. = ..()

/obj/item/clockwork/clockwork_slab/pickup(mob/user)
	. = ..()
	//Grant quickbound spells
	for(var/datum/action/innate/clockcult/quick_bind/script in quick_bound_scriptures)
		message_admins("Granting [script.name] to [user.ckey]")
		script.Grant(user)

/obj/item/clockwork/clockwork_slab/update_icon()
	. = ..()
	cut_overlays()
	if(charge_overlay)
		add_overlay(charge_overlay)

//==================================//
// !   Quick bind spell handling  ! //
//==================================//

/obj/item/clockwork/clockwork_slab/proc/bind_spell(mob/living/M, datum/clockcult/scripture/spell, position = 1)
	if(position > quick_bound_scriptures.len || position <= 0)
		return
	if(quick_bound_scriptures[position])
		//Unbind the scripture that is quickbound
		qdel(quick_bound_scriptures[position])
	//Put the quickbound action onto the slab, the slab should grant when picked up
	var/datum/action/innate/clockcult/quick_bind/quickbound = new
	quickbound.scripture = spell
	quickbound.activation_slab = src
	quick_bound_scriptures[position] = quickbound
	if(M)
		quickbound.Grant(M)

//==================================//
// ! UI HANDLING BELOW THIS POINT ! //
//==================================//
/obj/item/clockwork/clockwork_slab/attack_self(mob/living/user)
	. = ..()
	ui_interact(user)

/obj/item/clockwork/clockwork_slab/ui_interact(mob/user, ui_key, datum/tgui/ui, force_open, datum/tgui/master_ui, datum/ui_state/state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "ClockworkSlab", name, 800, 420, master_ui, state)
		ui.set_autoupdate(FALSE) //we'll update this occasionally, but not as often as possible
		ui.open()

/obj/item/clockwork/clockwork_slab/ui_data(mob/user)
	var/list/data = list()
	data["scriptures"] = list()
	data["drivers"] = list()
	data["applications"] = list()
	//Generate Scriptures Infomation
	var/datum/antagonist/servant_of_ratvar/servant_datum = is_servant_of_ratvar(user)
	if(!servant_datum)
		return data
	var/list/accessable_scriptures = servant_datum.servant_class.class_scriptures
	accessable_scriptures += GLOB.servant_global_scriptures
	//2 scriptures accessable at the same time will cause issues
	for(var/datum/clockcult/scripture/scripture in accessable_scriptures)
		//Get the appropriate data
		var/list/S = list(
			"name" = scripture.name,
			"desc" = scripture.desc,
			"tip" = scripture.tip,
			"cost" = scripture.power_cost
		)
		//Add it to the correct list
		switch(scripture.scripture_type)
			if(SCRIPTURE)
				data["scriptures"] += list(S)
			if(DRIVER)
				data["drivers"] += list(S)
			if(APPLICATION)
				data["applications"] += list(S)
	return data

/obj/item/clockwork/clockwork_slab/ui_static_data(mob/user)
	var/list/data = list()
	//Class Infomation
	data["servant_classes"] = list()
	for(var/class_name in GLOB.servant_classes)
		var/datum/clockcult/servant_class/class = GLOB.servant_classes[class_name]
		var/list/C = list(
			"classname" = class.class_name,
			"classdesc" = class.class_description,
			"id" = class.class_ID
		)
		data["servant_classes"] += list(C)
	return data

/obj/item/clockwork/clockwork_slab/ui_act(action, params)
	message_admins("action: [action]")
	for(var/param in params)
		message_admins("param: [param] = [params[param]]")
	switch(action)
		if("setClass")
			var/mob/living/M = usr
			if(!istype(M))
				message_admins("not living mob")
				return FALSE
			var/datum/antagonist/servant_of_ratvar/S = is_servant_of_ratvar(M)
			if(!S)
				message_admins("no servant")
				return FALSE
			if(S.servant_class.type != /datum/clockcult/servant_class)
				message_admins("already chosen")
				return FALSE
			var/selected_name = params["class"]
			var/datum/clockcult/servant_class/class = GLOB.servant_classes[selected_name]
			if(!class)
				message_admins("Invalid class selected.")
				return FALSE
			to_chat(M, "<span class='brass'>You begin calling upon [class.class_name] for guidance!</span>")
			M.say("[text2ratvar("Oh great [class.class_name], [pick("show me the way!", "bless me with your light!", "teach my the way!")]")]")
			if(do_after(M, 100, target=M))
				to_chat(M, "<span class='brass'>You call upon [class.class_name] and are blessed with their knowledge and might!</span>")
				S.servant_class = class
			return TRUE
