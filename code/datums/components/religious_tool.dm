/**
 *
 * Allows the parent to act similarly to the Altar of Gods with modularity. Invoke and Sect Selection is done via attacking with a bible. This means you cannot sacrifice Bibles (you shouldn't want to do this anyways although now that I mentioned it you probably will want to).
 *
 */
/datum/component/religious_tool
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// Enables access to the global sect directly
	var/datum/religion_sect/easy_access_sect
	/// Prevents double selecting sects
	var/selecting_sect = FALSE
	/// What extent do we want this religious tool to act? In case you don't want full access to the list. Generated on New
	var/operation_flags
	/// The rite currently being invoked
	var/datum/religion_rites/performing_rite
	///Sets the type for catalyst
	var/catalyst_type = /obj/item/storage/book/bible
	///Enables overide of COMPONENT_NO_AFTERATTACK, not recommended as it means you can potentially cause damage to the item using the catalyst.
	var/force_catalyst_afterattack = FALSE
	var/datum/callback/after_sect_select_cb

/datum/component/religious_tool/Initialize(_flags = ALL, _force_catalyst_afterattack = FALSE, _after_sect_select_cb, override_catalyst_type)
	. = ..()
	SetGlobalToLocal() //attempt to connect on start in case one already exists!
	operation_flags = _flags
	force_catalyst_afterattack = _force_catalyst_afterattack
	after_sect_select_cb = _after_sect_select_cb
	if(override_catalyst_type)
		catalyst_type = override_catalyst_type

/datum/component/religious_tool/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY,PROC_REF(AttemptActions))
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/datum/component/religious_tool/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_PARENT_ATTACKBY, COMSIG_PARENT_EXAMINE))

/**
 * Sets the easy access variable to the global if it exists.
 */
/datum/component/religious_tool/proc/SetGlobalToLocal()
	if(easy_access_sect)
		return TRUE
	if(!GLOB.religious_sect)
		return FALSE
	easy_access_sect = GLOB.religious_sect
	if(after_sect_select_cb)
		after_sect_select_cb.Invoke()
	return TRUE

/**
 * Since all of these involve attackby, we require mega proc. Handles Invocation, Sacrificing, And Selection of Sects.
 */
/datum/component/religious_tool/proc/AttemptActions(datum/source, obj/item/the_item, mob/living/user)
	SIGNAL_HANDLER

	if(istype(the_item, catalyst_type))
		INVOKE_ASYNC(src, TYPE_PROC_REF(/datum, ui_interact), user) //asynchronous to avoid sleeping in a signal

	/**********Sacrificing**********/
	else if(operation_flags & RELIGION_TOOL_SACRIFICE)
		if(!easy_access_sect?.can_sacrifice(the_item,user))
			return
		easy_access_sect.on_sacrifice(the_item,user)
		return COMPONENT_NO_AFTERATTACK

/datum/component/religious_tool/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ReligiousTool")
		ui.open()
	return COMPONENT_NO_AFTERATTACK

/datum/component/religious_tool/ui_state(mob/user)
	if(!iscarbon(usr))
		return GLOB.never_state
	var/mob/living/carbon/carbon = usr
	if(!carbon.is_holding_item_of_type(catalyst_type))
		return GLOB.never_state
	return GLOB.default_state

/datum/component/religious_tool/ui_data(mob/user)
	var/list/data = list()
	//cannot find global vars, so lets offer options
	if(!SetGlobalToLocal())
		data["sects"] = generate_available_sects(user)
		data["alignment"] = ALIGNMENT_NEUT //neutral theme if you have no sect
	else
		data["sects"] = null
		data["name"] = easy_access_sect.name
		data["desc"] = easy_access_sect.desc
		data["quote"] = easy_access_sect.quote
		data["alignment"] = easy_access_sect.alignment
		data["icon"] = easy_access_sect.tgui_icon
		data["favordesc"] = easy_access_sect.tool_examine(user)
		data["favor"] = easy_access_sect.favor
		data["deity"] = GLOB.deity
		data["rites"] = generate_available_rites()
		data["wanted"] = generate_sacrifice_list()

	var/atom/atom_parent = parent
	data["toolname"] = atom_parent.name
	data["can_select_sect"] = (operation_flags & RELIGION_TOOL_SECTSELECT)
	data["can_invoke_rite"] = (operation_flags & RELIGION_TOOL_INVOKE)
	data["can_sacrifice_item"] = (operation_flags & RELIGION_TOOL_SACRIFICE)
	return data

/datum/component/religious_tool/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch(action)
		if("sect_select")
			select_sect(usr, params["path"])
			return TRUE //they picked a sect lets update so some weird spammy shit doesn't happen
		if("perform_rite")
			perform_rite(usr, params["path"])

/// Select the sect, called from [/datum/component/religious_tool/proc/AttemptActions]
/datum/component/religious_tool/proc/select_sect(mob/living/user, path)
	if(!ispath(text2path(path), /datum/religion_sect))
		message_admins("[ADMIN_LOOKUPFLW(usr)] has tried to spawn an item when selecting a sect.")
		return
	if(user.mind.holy_role != HOLY_ROLE_HIGHPRIEST)
		to_chat(user, "<span class='warning'>You are not the high priest, and therefore cannot select a religious sect.")
		return
	if(!user.canUseTopic(parent, BE_CLOSE, FALSE, NO_TK))
		to_chat(user, "<span class='warning'>You cannot select a sect at this time.</span>")
		return
	if(GLOB.religious_sect)
		return
	GLOB.religious_sect = new path()
	for(var/i in GLOB.player_list)
		if(!isliving(i))
			continue
		var/mob/living/am_i_holy_living = i
		if(!am_i_holy_living.mind?.holy_role)
			continue
		GLOB.religious_sect.on_conversion(am_i_holy_living)
	easy_access_sect = GLOB.religious_sect
	after_sect_select_cb.Invoke()

/// Perform the rite, called from [/datum/component/religious_tool/proc/AttemptActions]
/datum/component/religious_tool/proc/perform_rite(mob/living/user, path)
	if(!ispath(text2path(path), /datum/religion_rites))
		message_admins("[ADMIN_LOOKUPFLW(usr)] has tried to spawn an item when performing a rite.")
		return
	if(user.mind.holy_role < HOLY_ROLE_PRIEST)
		if(user.mind.holy_role == HOLY_ROLE_DEACON)
			to_chat(user, "<span class='warning'>You are merely a deacon of [GLOB.deity], and therefore cannot perform rites.</span>")
		else
			to_chat(user, "<span class='warning'>You are not holy, and therefore cannot perform rites.</span>")
		return
	if(performing_rite)
		to_chat(user, "<span class='notice'>There is a rite currently being performed here already.</span>")
		return
	if(!user.canUseTopic(parent, BE_CLOSE, FALSE, NO_TK))
		to_chat(user, "<span class='warning'>You are not close enough to perform the rite.</span>")
		return
	performing_rite = new path(parent)
	if(!performing_rite.perform_rite(user, parent))
		QDEL_NULL(performing_rite)
	else
		performing_rite.invoke_effect(user, parent)
		easy_access_sect.adjust_favor(-performing_rite.favor_cost)
		if(performing_rite.auto_delete)
			QDEL_NULL(performing_rite)
		else
			performing_rite = null

/**
 * Generates a list of available sects to the user. Intended to support custom-availability sects.
 */
/datum/component/religious_tool/proc/generate_available_sects(mob/user)
	var/list/sects_to_pick = list()
	var/human_highpriest = ishuman(user)
	var/mob/living/carbon/human/highpriest = user
	for(var/path in subtypesof(/datum/religion_sect))
		if(human_highpriest && initial(easy_access_sect.invalidating_qualities))
			var/datum/species/highpriest_species = highpriest.dna.species
			if(initial(easy_access_sect.invalidating_qualities) in highpriest_species.inherent_traits)
				continue
		var/list/sect = list()
		var/datum/religion_sect/not_a_real_instance_rs = path
		sect["name"] = initial(not_a_real_instance_rs.name)
		sect["desc"] = initial(not_a_real_instance_rs.desc)
		sect["alignment"] = initial(not_a_real_instance_rs.alignment)
		sect["quote"] = initial(not_a_real_instance_rs.quote)
		sect["icon"] = initial(not_a_real_instance_rs.tgui_icon)
		sect["path"] = path
		sects_to_pick += list(sect)
	return sects_to_pick

/**
 * Generates available rites to pick from. It expects the sect to be picked by the time it was called (by tgui data)
 */
/datum/component/religious_tool/proc/generate_available_rites()
	var/list/rites_to_pick = list()
	for(var/path in easy_access_sect.rites_list)
		///checks to invalidate
		var/list/rite = list()
		var/datum/religion_rites/rite_type = path
		rite["name"] = initial(rite_type.name)
		rite["desc"] = initial(rite_type.desc)
		var/cost = initial(rite_type.favor_cost)
		rite["favor"] = cost
		rite["can_cast"] = cost > easy_access_sect.favor
		rite["path"] = path
		rites_to_pick += list(rite)
	return rites_to_pick

/**
 * Generates an english list (so string) of wanted sac items. Returns null if no targets!
 */
/datum/component/religious_tool/proc/generate_sacrifice_list()
	if(!easy_access_sect.desired_items)
		return //specifically null so the data sends as such
	var/list/item_names = list()
	for(var/atom/sac_type as anything in easy_access_sect.desired_items)
		var/append = easy_access_sect.desired_items[sac_type]
		var/entry = "[initial(sac_type.name)]s [append]"
		item_names += entry
	return english_list(item_names)

/**
 * Appends to examine so the user knows it can be used for religious purposes.
 */
/datum/component/religious_tool/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	var/can_i_see = FALSE
	if(isobserver(user))
		can_i_see = TRUE
	else if(isliving(user))
		var/mob/living/L = user
		if(L.mind?.holy_role)
			can_i_see = TRUE

	if(!can_i_see)
		return
	examine_list += ("<span class='notice'>Use a bible to interact with this.</span>")
	if(!easy_access_sect)
		if(operation_flags & RELIGION_TOOL_SECTSELECT)
			examine_list += ("<span class='notice'>This looks like it can be used to select a sect.</span>")
			return
	if(operation_flags & RELIGION_TOOL_SACRIFICE)//this can be moved around if things change but usually no rites == no sacrifice
		examine_list += ("<span class='notice'>Desired items can be used on this to increase favor.</span>")
	if(easy_access_sect.rites_list && operation_flags & RELIGION_TOOL_INVOKE)
		examine_list += ("<span class='notice'>You can invoke rites from this.</span>")
