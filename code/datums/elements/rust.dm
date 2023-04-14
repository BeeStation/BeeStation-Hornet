/**
 * Adding this element to an atom will have it automatically render an overlay.
 * The overlay can be specified in new as the first paramter; if not set it defaults to rust_overlay's rust_default
 */
/datum/element/rust
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH
	id_arg_index = 2
	/// The rust image itself, since the icon and icon state are only used as an argument
	var/image/rust_overlay

/datum/element/rust/Attach(atom/target, rust_icon = 'icons/effects/rust_overlay.dmi', rust_icon_state = "rust_default")
	. = ..()
	if(!isatom(target))
		return COMPONENT_INCOMPATIBLE
	if(!rust_overlay)
		rust_overlay = image(rust_icon, rust_icon_state)
	ADD_TRAIT(target, TRAIT_RUSTY, src)
	RegisterSignal(target, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(apply_rust_overlay))
	RegisterSignal(target, COMSIG_PARENT_EXAMINE, PROC_REF(handle_examine))
	RegisterSignal(target, list(COMSIG_ATOM_TOOL_ACT(TOOL_WELDER), COMSIG_ATOM_TOOL_ACT(TOOL_RUSTSCRAPER)), PROC_REF(secondary_tool_act))
	// Unfortunately registering with parent sometimes doesn't cause an overlay update
	target.update_icon()

/datum/element/rust/Detach(atom/source)
	. = ..()
	UnregisterSignal(source, COMSIG_ATOM_UPDATE_OVERLAYS)
	UnregisterSignal(source, COMSIG_PARENT_EXAMINE)
	UnregisterSignal(source, list(COMSIG_ATOM_TOOL_ACT(TOOL_WELDER), COMSIG_ATOM_TOOL_ACT(TOOL_RUSTSCRAPER)))
	REMOVE_TRAIT(source, TRAIT_RUSTY, src)
	source.update_icon()

/datum/element/rust/proc/handle_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	examine_text += "<span class='notice'>[source] is very rusty, you could probably <i>burn</i> or <i>scrape</i> it off.</span>"

/datum/element/rust/proc/apply_rust_overlay(atom/parent_atom, list/overlays)
	SIGNAL_HANDLER
	overlays += rust_overlay

/// Because do_after sleeps we register the signal here and defer via an async call
/datum/element/rust/proc/secondary_tool_act(atom/source, mob/user, obj/item/item)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(handle_tool_use), source, user, item)
	return COMPONENT_BLOCK_TOOL_ATTACK

/// We call this from secondary_tool_act because we sleep with do_after
/datum/element/rust/proc/handle_tool_use(atom/source, mob/user, obj/item/item)
	switch(item.tool_behaviour)
		if(TOOL_WELDER)
			if(item.use(5))
				user.balloon_alert(user, "You start burning off the rust...")
				if(!do_after(user, 5 SECONDS * item.toolspeed, target = source))
					return
				user.balloon_alert(user, "Sucessfully burned off the rust!")
				Detach(source)
				return
		if(TOOL_RUSTSCRAPER)
			user.balloon_alert(user, "You start scraping off the rust...")
			if(!do_after(user, 2 SECONDS * item.toolspeed, target = source))
				return
			user.balloon_alert(user, "Sucessfully scraped off the rust!")
			Detach(source)
			return
