/// An element for atoms that, when dragged and dropped onto a mob, opens a strip panel.
/datum/element/strippable
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH
	id_arg_index = 2

	/// An assoc list of keys to /datum/strippable_item
	var/list/items

	/// An optional list of lists of strippable_item_layout to order the slots in.
	/// Nested lists are used to indicate sections which will be spaced out in the interface.
	var/list/layout

	/// A proc path that returns TRUE/FALSE if we should show the strip panel for this entity.
	/// If it does not exist, the strip menu will always show.
	/// Will be called with (mob/user).
	var/should_strip_proc_path

	/// An existing strip menus
	var/list/strip_menus

/datum/element/strippable/Attach(datum/target, list/items, should_strip_proc_path, list/layout)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_MOUSEDROP_ONTO, .proc/mouse_drop_onto)

	src.items = items
	src.should_strip_proc_path = should_strip_proc_path
	src.layout = layout

/datum/element/strippable/Detach(datum/source, force)
	. = ..()

	UnregisterSignal(source, COMSIG_MOUSEDROP_ONTO)

	if(!isnull(strip_menus))
		QDEL_NULL(strip_menus[source])

/datum/element/strippable/proc/mouse_drop_onto(datum/source, atom/over, mob/user)
	SIGNAL_HANDLER

	if(user == source)
		return

	if(over != user)
		return

	// Cyborgs buckle people by dragging them onto them, unless in combat mode.
	if(iscyborg(user))
		var/mob/living/silicon/robot/cyborg_user = user
		if(cyborg_user.a_intent != INTENT_HARM)
			return

	if(!isnull(should_strip_proc_path) && !call(source, should_strip_proc_path)(user))
		return

	var/datum/strip_menu/strip_menu = LAZYACCESS(strip_menus, source)

	if(isnull(strip_menu))
		strip_menu = new(source, src)
		LAZYSET(strip_menus, source, strip_menu)

	INVOKE_ASYNC(strip_menu, /datum/.proc/ui_interact, user)

/datum/strippable_item_layout
	/// The STRIPPABLE_ITEM_* key
	var/key

	/// Is the slot dependent on the last non-indented slot?
	var/indented

/datum/strippable_item_layout/New(key, indented)
	src.key = key
	src.indented = indented

/// A representation of an item that can be stripped down
/datum/strippable_item
	/// The STRIPPABLE_ITEM_* key
	var/key

	/// Should we warn about dangerous clothing?
	var/warn_dangerous_clothing = TRUE

/// Gets the item from the given source.
/datum/strippable_item/proc/get_item(atom/source)

/// Tries to equip the item onto the given source.
/// Returns TRUE/FALSE depending on if it is allowed.
/// This should be used for checking if an item CAN be equipped.
/// It should not perform the equipping itself.
/datum/strippable_item/proc/try_equip(atom/source, obj/item/equipping, mob/user)
	if(!equipping)
		return
	if(HAS_TRAIT(equipping, TRAIT_NODROP))
		to_chat(user, "<span class='warning'>You can't put [equipping] on [source], it's stuck to your hand!</span>")
		return FALSE
	return TRUE

/// Start the equipping process. This is the proc you should yield in.
/// Returns TRUE/FALSE depending on if it is allowed.
/datum/strippable_item/proc/start_equip(atom/source, obj/item/equipping, mob/user)
	if(isclothing(source))
		source.visible_message(
			"<span class='notice'>[user] tries to put [equipping] on [source].</span>",
			"<span class='notice'>[user] tries to put [equipping] on you.</span>",
			ignored_mobs = user
		)

	to_chat(user, "<span class='notice'>You try to put [equipping] on [source]...</span>")

	var/log = "[key_name(source)] is having [equipping] put on them by [key_name(user)]"
	source.log_message(log, LOG_ATTACK, color="red")
	user.log_message(log, LOG_ATTACK, color="red", log_globally=FALSE)

	return TRUE

/// The proc that places the item on the source. This should not yield.
/datum/strippable_item/proc/finish_equip(atom/source, obj/item/equipping, mob/user)
	SHOULD_NOT_SLEEP(TRUE)

/// Tries to unequip the item from the given source.
/// Returns TRUE/FALSE depending on if it is allowed.
/// This should be used for checking if it CAN be unequipped.
/// It should not perform the unequipping itself.
/datum/strippable_item/proc/try_unequip(atom/source, mob/user)
	SHOULD_NOT_SLEEP(TRUE)

	var/obj/item/item = get_item(source)
	if(isnull(item))
		return FALSE

	if(ismob(source))
		var/mob/mob_source = source
		if(!item.canStrip(user, mob_source))
			return FALSE

	return TRUE

/// Start the unequipping process. This is the proc you should yield in.
/// Returns TRUE/FALSE depending on if it is allowed.
/datum/strippable_item/proc/start_unequip(atom/source, mob/user)
	var/obj/item/item = get_item(source)
	if(isnull(item))
		return FALSE

	source.visible_message(
		"<span class='warning'>[user] tries to remove [source]'s [item].</span>",
		"<span class='userdanger'>[user] tries to remove your [item].</span>",
		ignored_mobs = user,
	)

	to_chat(user, "<span class='danger'>You try to remove [source]'s [item]...</span>")
	source.log_message("[key_name(source)] is being stripped of [item] by [key_name(user)]", LOG_ATTACK, color="red")
	user.log_message("[key_name(source)] is being stripped of [item] by [key_name(user)]", LOG_ATTACK, color="red", log_globally=FALSE)
	item.add_fingerprint(src)

	return TRUE

/// The proc that unequips the item from the source. This should not yield.
/datum/strippable_item/proc/finish_unequip(atom/source, mob/user)

/// Returns a STRIPPABLE_OBSCURING_* define to report on whether or not this is obscured.
/datum/strippable_item/proc/get_obscuring(atom/source)
	SHOULD_NOT_SLEEP(TRUE)
	return STRIPPABLE_OBSCURING_NONE

/// Returns the ID of this item's strippable action.
/// Return `null` if there is no alternate action.
/// Any return value of this must be in StripMenu.
/datum/strippable_item/proc/get_alternate_action(atom/source, mob/user)
	return null

/// Performs an alternative action on this strippable_item.
/// `has_alternate_action` needs to be TRUE.
/datum/strippable_item/proc/alternate_action(atom/source, mob/user)

/// Returns whether or not this item should show.
/datum/strippable_item/proc/should_show(atom/source, mob/user)
	return TRUE

/// Returns TRUE if the item is present for the mob, but not available.
/// This is used, for example, for pockets when a jumpsuit is not worn. 
/datum/strippable_item/proc/is_unavailable(atom/source)

/// A preset for equipping items onto mob slots
/datum/strippable_item/mob_item_slot
	/// The ITEM_SLOT_* to equip to.
	var/item_slot

/datum/strippable_item/mob_item_slot/get_item(atom/source)
	if(!ismob(source))
		return null

	var/mob/mob_source = source
	return mob_source.get_item_by_slot(item_slot)

/datum/strippable_item/mob_item_slot/try_equip(atom/source, obj/item/equipping, mob/user)
	. = ..()
	if(!.)
		return

	if(!ismob(source))
		return FALSE

	if(!equipping.mob_can_equip(
		source,
		user,
		item_slot,
		disable_warning = TRUE,
		bypass_equip_delay_self = TRUE,
	))
		to_chat(user, "<span class='warning'>\The [equipping] doesn't fit in that place!</span>")
		return FALSE

	return TRUE

/datum/strippable_item/mob_item_slot/start_equip(atom/source, obj/item/equipping, mob/user)
	. = ..()
	if(!.)
		return

	if(!ismob(source))
		return FALSE

	if(!do_mob(user, source, get_equip_delay(equipping)))
		return FALSE

	if(!equipping.mob_can_equip(
		source,
		user,
		item_slot,
		disable_warning = TRUE,
		bypass_equip_delay_self = TRUE,
	))
		return FALSE

	if(!user.temporarilyRemoveItemFromInventory(equipping))
		return FALSE

	return TRUE

/datum/strippable_item/mob_item_slot/finish_equip(atom/source, obj/item/equipping, mob/user)
	if(!ismob(source))
		return FALSE

	var/mob/mob_source = source
	mob_source.equip_to_slot(equipping, item_slot)

/datum/strippable_item/mob_item_slot/get_obscuring(atom/source)
	if(iscarbon(source))
		var/mob/living/carbon/carbon_source = source
		return(carbon_source.check_obscured_slots() & item_slot) \
			? STRIPPABLE_OBSCURING_COMPLETELY \
			: STRIPPABLE_OBSCURING_NONE

	return FALSE

/datum/strippable_item/mob_item_slot/start_unequip(atom/source, mob/user)
	. = ..()
	if(!.)
		return

	return start_unequip_mob(get_item(source), source, user)

/datum/strippable_item/mob_item_slot/finish_unequip(atom/source, mob/user)
	var/obj/item/item = get_item(source)
	if(isnull(item))
		return FALSE

	if(!ismob(source))
		return FALSE

	return finish_unequip_mob(item, source, user)

/// Returns the delay of equipping this item to a mob
/datum/strippable_item/mob_item_slot/proc/get_equip_delay(obj/item/equipping)
	return equipping.equip_delay_other

/datum/strippable_item/mob_item_slot/is_unavailable(atom/source)
	if(!iscarbon(source))
		return

	var/mob/living/carbon/carbon = source

	if(carbon.dna?.species && (item_slot in carbon.dna.species.no_equip))
		return TRUE

/// A utility function for `/datum/strippable_item`s to start unequipping an item from a mob.
/proc/start_unequip_mob(obj/item/item, mob/source, mob/user, strip_delay)
	if(!do_mob(user, source, strip_delay || item.strip_delay))
		return FALSE

	return TRUE

/// A utility function for `/datum/strippable_item`s to finish unequipping an item from a mob.
/proc/finish_unequip_mob(obj/item/item, mob/source, mob/user)
	if(!item.doStrip(user, source))
		return FALSE

	source.log_message("[key_name(source)] has been stripped of [item] by [key_name(user)]", LOG_ATTACK, color="red")
	user.log_message("[key_name(source)] has been stripped of [item] by [key_name(user)]", LOG_ATTACK, color="red", log_globally=FALSE)

	// Updates speed in case stripped speed affecting item
	source.update_equipment_speed_mods()

/// A representation of the stripping UI
/datum/strip_menu
	/// The owner who has the element /datum/element/strippable
	var/atom/movable/owner

	/// The strippable element itself
	var/datum/element/strippable/strippable

	/// A lazy list of user mobs to a list of strip menu keys that they're interacting with
	var/list/interactions

/datum/strip_menu/New(atom/movable/owner, datum/element/strippable/strippable)
	. = ..()
	src.owner = owner
	src.strippable = strippable

/datum/strip_menu/Destroy()
	owner = null
	strippable = null

	return ..()

/datum/strip_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "StripMenu")
		ui.open()
		ui.set_autoupdate(TRUE) // Item changes from outside stripping

/datum/strip_menu/ui_data(mob/user)
	var/list/data = list()

	var/list/items = list()

	for (var/strippable_key in strippable.items)
		var/datum/strippable_item/item_data = strippable.items[strippable_key]

		if(!item_data.should_show(owner, user))
			continue

		var/list/result

		if(strippable_key in LAZYACCESS(interactions, user))
			LAZYSET(result, "interacting", TRUE)

		var/obscuring = item_data.get_obscuring(owner)
		if(obscuring != STRIPPABLE_OBSCURING_NONE)
			LAZYSET(result, "obscured", obscuring)
			items[strippable_key] = result
			continue

		if(item_data.is_unavailable(owner))
			LAZYSET(result, "unavailable", TRUE)
			items[strippable_key] = result
			continue

		var/obj/item/item = item_data.get_item(owner)
		if(isnull(item))
			items[strippable_key] = result
			continue

		LAZYINITLIST(result)

		/* We don't use item icons in our strip menu, keeping this here in case we want it in the future
		result["icon"] = icon2base64(icon(item.icon, item.icon_state, frame=1))
		*/
		result["name"] = item.name
		result["alternate"] = item_data.get_alternate_action(owner, user)

		items[strippable_key] = result

	data["items"] = items

	// While most `\the`s are implicit, this one is not.
	// In this case, `\The` would otherwise be used.
	// This doesn't match with what it's used for, which is to say "Stripping the alien drone",
	// as opposed to "Stripping The alien drone".
	// Human names will still show without "the", as they are proper nouns.
	data["name"] = "\the [owner]"

	return data

/datum/strip_menu/ui_static_data(mob/user)
	. = list()

	if(!isnull(strippable.layout))
		var/layout = list()

		for(var/section in strippable.layout)
			var/section_result = list()

			for(var/datum/strippable_item_layout/slot as() in section)
				section_result += list(list(
					"id" = slot.key,
					"indented" = slot.indented,
				))

			layout += list(section_result)

		.["layout"] = layout

/datum/strip_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	. = TRUE

	var/mob/user = usr

	switch(action)
		if("use")
			var/key = params["key"]
			var/datum/strippable_item/strippable_item = strippable.items[key]

			if(isnull(strippable_item))
				return

			if(!strippable_item.should_show(owner, user))
				return

			if(strippable_item.get_obscuring(owner) == STRIPPABLE_OBSCURING_COMPLETELY)
				return

			var/item = strippable_item.get_item(owner)
			if(isnull(item))
				var/obj/item/held_item = user.get_active_held_item()
				if(isnull(held_item))
					return

				if(strippable_item.try_equip(owner, held_item, user))
					LAZYORASSOCLIST(interactions, user, key)

					SStgui.update_uis(src)
					// Yielding call
					var/should_finish = strippable_item.start_equip(owner, held_item, user)

					LAZYREMOVEASSOC(interactions, user, key)
					. = TRUE

					if(!should_finish)
						return

					if(QDELETED(src) || QDELETED(owner))
						return

					// They equipped an item in the meantime
					if(!isnull(strippable_item.get_item(owner)))
						return

					if(!user.Adjacent(owner))
						return

					strippable_item.finish_equip(owner, held_item, user)
			else if(strippable_item.try_unequip(owner, user))
				LAZYORASSOCLIST(interactions, user, key)

				SStgui.update_uis(src)
				var/should_unequip = strippable_item.start_unequip(owner, user)

				LAZYREMOVEASSOC(interactions, user, key)
				. = TRUE

				// Yielding call
				if(!should_unequip)
					return

				if(QDELETED(src) || QDELETED(owner))
					return

				// They changed the item in the meantime
				if(strippable_item.get_item(owner) != item)
					return

				if(!user.Adjacent(owner))
					return

				strippable_item.finish_unequip(owner, user)
		if("alt")
			var/key = params["key"]
			var/datum/strippable_item/strippable_item = strippable.items[key]

			if(isnull(strippable_item))
				return

			if(!strippable_item.should_show(owner, user))
				return

			if(strippable_item.get_obscuring(owner) == STRIPPABLE_OBSCURING_COMPLETELY)
				return

			var/item = strippable_item.get_item(owner)
			if(isnull(item))
				return

			if(isnull(strippable_item.get_alternate_action(owner, user)))
				return

			LAZYORASSOCLIST(interactions, user, key)

			// Potentially yielding
			strippable_item.alternate_action(owner, user)

			LAZYREMOVEASSOC(interactions, user, key)

/datum/strip_menu/ui_host(mob/user)
	return owner

/datum/strip_menu/ui_state(mob/user)
	return GLOB.always_state

/datum/strip_menu/ui_status(mob/user, datum/ui_state/state)
	return min(
		ui_status_only_living(user, owner),
		ui_status_user_is_adjacent(user, owner),
		max(
			ui_status_user_is_conscious_and_lying_down(user),
			ui_status_user_is_abled(user, owner),
		),
	)

/// Creates an assoc list of keys to /datum/strippable_item
/proc/create_strippable_list(types)
	var/list/strippable_items = list()

	for (var/strippable_type in types)
		var/datum/strippable_item/strippable_item = new strippable_type
		strippable_items[strippable_item.key] = strippable_item

	return strippable_items
