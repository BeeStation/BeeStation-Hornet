GLOBAL_LIST_EMPTY(preferences_datums)

/datum/preferences
	var/client/parent

	/// The current active slot, and the one that will be saved as active
	var/default_slot = 1
	/// The maximum number of slots we're allowed to contain
	var/max_save_slots = 3
	/// Cache for the current active character slot
	var/datum/preferences_holder/preferences_character/character_data
	/// Cache for player datumized preferences
	var/datum/preferences_holder/preferences_player/player_data

	/// Bitflags for communications that are muted
	var/muted = NONE
	/// Last IP that this client has connected from
	var/last_ip
	/// Last CID that this client has connected from
	var/last_id

	// pAI profile
	var/pai_name = ""
	var/pai_description = ""
	var/pai_comment = ""

	/// Cached changelog size, to detect new changelogs since last join
	var/lastchangelog = ""

	/// List of ROLE_X that the client wants to be eligible for (PER CHARACTER)
	/// Use /client/proc/role_preference_enabled() please
	var/list/role_preferences = list()

	/// List of ROLE_X that the client wants to be eligible for (GLOBALLY)
	/// Use /client/proc/role_preference_enabled() please
	var/list/role_preferences_global = list()

	/// Custom keybindings. Map of keybind names to keyboard inputs.
	/// For example, by default would have "swap_hands" -> "X"
	var/list/key_bindings = list()

	/// Cached list of keybindings, mapping keys to actions.
	/// For example, by default would have "X" -> list("swap_hands")
	var/list/key_bindings_by_key = list()

	var/db_flags

	//character preferences
	var/slot_randomized //keeps track of round-to-round randomization of the character slot, prevents overwriting

	var/list/randomise = list()

	//Quirk list
	var/list/all_quirks = list()

	//Job preferences 2.0 - indexed by job title , no key or value implies never
	var/list/job_preferences = list()

	/// The current window, PREFERENCE_TAB_* in [`code/__DEFINES/preferences.dm`]
	var/current_window = PREFERENCE_TAB_CHARACTER_PREFERENCES

	/// If the user is a BYOND Member
	var/unlock_content = 0

	var/list/ignoring = list()

	var/list/purchased_gear = list()
	var/list/equipped_gear = list()

	var/list/exp = list()
	var/job_exempt = 0

	var/action_buttons_screen_locs = list()

	///What outfit typepaths we've favorited in the SelectEquipment menu
	var/list/favorite_outfits = list()

	/// A preview of the current character
	var/atom/movable/screen/map_view/character_preview_view/character_preview_view

	/// A list of instantiated middleware
	var/list/datum/preference_middleware/middleware = list()

	/// A list of keys that have been updated since the last save.
	var/list/recently_updated_keys = list()

	/// List of slot index -> character names
	var/list/character_profiles_cached

	/// If the last save was a success or not. True for success, false for fail.
	var/fail_state = TRUE

/datum/preferences/Destroy(force, ...)
	QDEL_NULL(character_preview_view)
	QDEL_LIST(middleware)
	QDEL_NULL(character_data)
	QDEL_NULL(player_data)
	return ..()

/datum/preferences/New(client/parent)
	src.parent = parent

	for (var/middleware_type in subtypesof(/datum/preference_middleware))
		middleware += new middleware_type(src)

	if(istype(parent))
		if(!IS_GUEST_KEY(parent.key))
			unlock_content = !!parent.IsByondMember()
			if(unlock_content)
				max_save_slots = 8
	else
		CRASH("attempted to create a preferences datum without a client!")

	// give them default keybinds and update their movement keys
	set_default_key_bindings(save = FALSE) // no point in saving these since everyone gets them. They'll be saved if needed.
	randomise = get_default_randomization()

	var/loaded_preferences_successfully = load_preferences()
	if(loaded_preferences_successfully)
		if("6030fe461e610e2be3a2c3e75c06067e" in purchased_gear) //MD5 hash of, "extra character slot"
			max_save_slots += 1
		if(load_character()) // This returns true if there is a database and character in the active slot.
			// Get the profile data
			fetch_character_profiles()
			create_character_preview_view()
			return
	// Begin no database / new player logic. This ONLY fires if there is an SQL error or no database / the player and character is new.

	if(!loaded_preferences_successfully) // create a new character object
		character_data = new(src, default_slot)
		// Get the profile data
		fetch_character_profiles()
		var/new_species_path = GLOB.species_list[get_fallback_species_id() || "human"]
		character_data.write_preference(src, GLOB.preference_entries[/datum/preference/choiced/species], new_species_path)
	// We couldn't load character data so just randomize the character appearance
	randomize_appearance_prefs()
	if(parent)
		apply_all_client_preferences() // apply now since normally this is done in load_preferences(). Defaults were set in preferences_player

	// The character name is fresh, update the character list.
	update_current_character_profile()
	create_character_preview_view()

	// If this was a NEW CKEY ENTRY, and not a guest key (handled in save_preferences()), save it.
	// Guest keys are ignored by mark_undatumized_dirty
	if(!loaded_preferences_successfully)
		// This will essentially force a write, while also using the queueing system.
		// For new ckeys, it is almost guaranteed we already hit the queue, since write_preference (used for when a datumized entry is null)
		// Will also queue the CKEY. But this will also ensure that undatumized prefs get written.
		mark_undatumized_dirty_player()
	mark_undatumized_dirty_character()

/datum/preferences/ui_interact(mob/user, datum/tgui/ui)
	// IMPORTANT: If someone opens the prefs menu before jobs load, then the jobs menu will be empty for everyone.
	// Do NOT call ui_assets until the jobs are loaded.
	if(!length(SSjob.occupations))
		return

	// If you leave and come back, re-register the character preview. This also runs the first time it's opened
	if (!isnull(character_preview_view) && !(character_preview_view in user.client?.screen))
		character_preview_view.register_to_client(user.client)
		character_preview_view.update_body() // For first opens, this needs to update.

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PreferencesMenu")
		ui.set_autoupdate(FALSE)
		ui.open()
		// Force an update shortly after opening so it renders the body.
		addtimer(CALLBACK(character_preview_view, TYPE_PROC_REF(/atom/movable/screen/map_view/character_preview_view, update_body)), 1 SECONDS, NONE, SSearly_timer)

/datum/preferences/ui_state(mob/user)
	return GLOB.always_state

// Without this, a hacker would be able to edit other people's preferences if
// they had the ref to Topic to.
/datum/preferences/ui_status(mob/user, datum/ui_state/state)
	return user.client == parent ? UI_INTERACTIVE : UI_CLOSE

/datum/preferences/ui_data(mob/user)
	var/list/data = list()

	data["character_profiles"] = character_profiles_cached

	data["character_preferences"] = compile_character_preferences(user)

	data["active_slot"] = default_slot
	data["max_slot"] = max_save_slots
	data["save_in_progress"] = !isnull(SSpreferences.datums[parent.ckey])
	data["is_guest"] = !!IS_GUEST_KEY(parent.key)
	data["is_db"] = !!SSdbcore.IsConnected()
	data["save_sucess"] = !!fail_state

	for (var/datum/preference_middleware/preference_middleware as anything in middleware)
		data += preference_middleware.get_ui_data(user)

	return data

/datum/preferences/ui_static_data(mob/user)
	var/list/data = list()

	data["character_preview_view"] = character_preview_view.assigned_map
	data["overflow_role"] = SSjob.GetJob(SSjob.overflow_role).title
	data["window"] = current_window

	data["content_unlocked"] = unlock_content

	for (var/datum/preference_middleware/preference_middleware as anything in middleware)
		data += preference_middleware.get_ui_static_data(user)

	return data

/datum/preferences/ui_assets(mob/user)
	var/list/assets = list(
		get_asset_datum(/datum/asset/spritesheet/preferences),
		get_asset_datum(/datum/asset/spritesheet/preferences_loadout),
		get_asset_datum(/datum/asset/json/preferences),
	)

	for (var/datum/preference_middleware/preference_middleware as anything in middleware)
		assets += preference_middleware.get_ui_assets()

	return assets

/datum/preferences/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return

	switch (action)
		if ("change_slot")
			var/new_slot = params["slot"]
			if(new_slot == default_slot) // No need to change to the current character.
				return
			// Save previous character (immediately, delaying this could mean data is lost)
			save_character()

			// SAFETY: `load_character` performs sanitization the slot number
			if (!load_character(new_slot))
				// there is no character in the slot. Make a new one. Save it.
				update_current_character_profile()
				randomize_appearance_prefs()
				// Queue an undatumized save, just in case (it's likely already queued, but we should write undatumized data as well)
				mark_undatumized_dirty_character()

			for (var/datum/preference_middleware/preference_middleware as anything in middleware)
				preference_middleware.on_new_character(usr)

			character_preview_view.update_body()

			return TRUE
		if ("rotate")
			var/direction = !!params["direction"]
			if(isatom(character_preview_view.body))
				character_preview_view.body.dir = turn(character_preview_view.body.dir, (direction ? 1 : -1) * 90)

			return TRUE
		if ("set_preference")
			var/requested_preference_key = params["preference"]
			var/value = params["value"]

			for (var/datum/preference_middleware/preference_middleware as anything in middleware)
				if (preference_middleware.pre_set_preference(usr, requested_preference_key, value))
					return TRUE

			var/datum/preference/requested_preference = GLOB.preference_entries_by_key[requested_preference_key]
			if (isnull(requested_preference))
				return FALSE

			// SAFETY: `update_preference` performs validation checks
			if (!update_preference(requested_preference, value))
				return FALSE

			if (istype(requested_preference, /datum/preference/name/real_name))
				update_current_character_profile()

			return TRUE
		if ("set_color_preference")
			var/requested_preference_key = params["preference"]

			var/datum/preference/requested_preference = GLOB.preference_entries_by_key[requested_preference_key]
			if (isnull(requested_preference))
				return FALSE

			if (!istype(requested_preference, /datum/preference/color) \
				&& !istype(requested_preference, /datum/preference/color_legacy) \
			)
				return FALSE

			var/default_value = read_preference(requested_preference.type)
			if (istype(requested_preference, /datum/preference/color_legacy))
				default_value = expand_three_digit_color(default_value)

			// Yielding
			var/new_color = tgui_color_picker(
				usr,
				"Select new color",
				"Preference Color",
				default_value || COLOR_WHITE,
			)

			if (!new_color)
				return FALSE

			if (!update_preference(requested_preference, new_color))
				return FALSE

			return TRUE

	for (var/datum/preference_middleware/preference_middleware as anything in middleware)
		var/delegation = preference_middleware.action_delegations[action]
		if (!isnull(delegation))
			return call(preference_middleware, delegation)(params, usr)

	return FALSE

/datum/preferences/ui_close(mob/user)
	// Save immediately. This should also handle if the player disconnects before their mob/ckey/client is null.
	save_character()
	save_preferences()
	character_preview_view.unregister_from_client(user.client)

/datum/preferences/Topic(href, list/href_list)
	. = ..()
	if (.)
		return

	if (href_list["open_keybindings"])
		current_window = PREFERENCE_TAB_KEYBINDINGS
		update_static_data(usr)
		ui_interact(usr)
		return TRUE

/datum/preferences/proc/compile_character_preferences(mob/user)
	var/list/preferences = list()

	for (var/datum/preference/preference as anything in get_preferences_in_priority_order())
		if (!preference.is_accessible(src))
			continue

		LAZYINITLIST(preferences[preference.category])

		var/value = read_preference(preference.type)
		var/data = preference.compile_ui_data(user, value)

		preferences[preference.category][preference.db_key] = data

	for (var/datum/preference_middleware/preference_middleware as anything in middleware)
		var/list/append_character_preferences = preference_middleware.get_character_preferences(user)
		if (isnull(append_character_preferences))
			continue

		for (var/category in append_character_preferences)
			if (category in preferences)
				preferences[category] += append_character_preferences[category]
			else
				preferences[category] = append_character_preferences[category]

	return preferences

/// Applies all PREFERENCE_PLAYER preferences immediately
/datum/preferences/proc/apply_all_client_preferences()
	for (var/datum/preference/preference as anything in get_preferences_in_priority_order())
		if (preference.preference_type != PREFERENCE_PLAYER)
			continue
		preference.apply_to_client(parent, read_player_preference(preference.type))

/// Updates cached character list with new real_name
/datum/preferences/proc/update_current_character_profile()
	if(!islist(character_profiles_cached))
		return
	character_profiles_cached[default_slot] = read_character_preference(/datum/preference/name/real_name)

/// Immediately refetch the character list
/datum/preferences/proc/fetch_character_profiles()
	character_data.get_all_character_names(src)

/// Applies the given preferences to a human mob.
/datum/preferences/proc/apply_prefs_to(mob/living/carbon/human/character, icon_updates = TRUE)
	character.dna.features = list()

	for (var/datum/preference/preference as anything in get_preferences_in_priority_order())
		if (preference.preference_type != PREFERENCE_CHARACTER)
			continue

		preference.apply_to_human(character, read_character_preference(preference.type))

	character.dna.real_name = character.real_name

	if(icon_updates)
		character.icon_render_keys = list() // turns out if you don't set this to null update_body_parts does nothing, since it assumes the operation was cached
		character.update_body()
		character.update_hair()
		character.update_body_parts(TRUE) // Must pass true here or limbs won't catch changes like body_model
		character.dna.update_body_size()
