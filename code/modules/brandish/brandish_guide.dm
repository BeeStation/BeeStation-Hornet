/// Activation-local acknowledgement survives reconnects and body transfers. There
/// is deliberately no permanent opt-out while the perspective is experimental.
GLOBAL_LIST_EMPTY(brandish_intro_shown)

/client/verb/brandish_perspective_guide()
	set name = "Brandish Perspective Guide"
	set category = "OOC"
	set desc = "Show the directional camera controls and your current movement keys."
	if(!mob?.brandish_perspective_allowed() || mob.stat == DEAD)
		to_chat(src, span_notice("This character cannot use the Brandish perspective. The guide requires a supported living body outside an item."))
		return
	if(!brandish_camera?.is_available())
		to_chat(src, span_notice("This guide is available while using the Brandish perspective as a living character."))
		return
	brandish_camera.ui_interact(mob)

/datum/brandish_camera/proc/show_intro()
	// Recheck ownership and eligibility when the delayed callback runs: death,
	// body transfers and global disable may all happen during the first second.
	if(!is_available() || !owner.ckey || (owner.ckey in GLOB.brandish_intro_shown))
		return
	GLOB.brandish_intro_shown += owner.ckey
	ui_interact(body)

/datum/brandish_camera/ui_state(mob/user)
	return GLOB.always_state

/datum/brandish_camera/ui_status(mob/user, datum/ui_state/state)
	return user == body && user.client == owner && is_available() ? UI_INTERACTIVE : UI_CLOSE

/datum/brandish_camera/ui_interact(mob/user, datum/tgui/ui)
	if(user != body || user.client != owner || !is_available())
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BrandishGuide", "Brandish perspective")
		ui.open()

/datum/brandish_camera/ui_data(mob/user)
	var/list/controls = list()
	for(var/name in owner.prefs.key_bindings)
		var/datum/keybinding/binding = GLOB.keybindings_by_name[name]
		if(!istype(binding, /datum/keybinding/brandish))
			continue
		controls += list(list("name" = binding.full_name, "keys" = owner.prefs.key_bindings[name]))
	return list("controls" = controls)

/datum/brandish_camera/ui_act(action, list/params)
	. = ..()
	if(. || usr != body || usr.client != owner || !is_available())
		return
	switch(action)
		if("close")
			SStgui.close_uis(src)
			return TRUE
