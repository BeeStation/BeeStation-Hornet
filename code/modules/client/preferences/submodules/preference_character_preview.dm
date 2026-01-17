/datum/preferences/proc/create_character_preview_view()
	if(istype(character_preview_view))
		return
	character_preview_view = new(null, src)

/datum/preferences/proc/render_new_preview_appearance(mob/living/carbon/human/dummy/mannequin)
	var/datum/job/preview_job = get_highest_priority_job()

	// Silicons only need a very basic preview since there is no customization for them.
	if (istype(preview_job, /datum/job/ai))
		return image('icons/mob/ai.dmi', icon_state = resolve_ai_icon_sync(read_character_preference(/datum/preference/choiced/ai_core_display)), dir = SOUTH)
	if (istype(preview_job, /datum/job/cyborg))
		return image('icons/mob/robots.dmi', icon_state = "robot", dir = SOUTH)

	// Set up the dummy for its photoshoot
	apply_prefs_to(mannequin, TRUE, log = FALSE)
	// Normalize size, since it doesn't scale properly in the preview.
	mannequin.dna.features["body_size"] = "Normal"
	mannequin.dna.update_body_size()

	if(preview_job)
		mannequin.job = preview_job.title
		preview_job.equip(mannequin, TRUE, preference_source = parent)
		preview_job.after_spawn(mannequin, mannequin, preference_source = parent, on_dummy = TRUE)
	else
		apply_loadout_to_mob(mannequin, mannequin, preference_source = parent, on_dummy = TRUE)

	COMPILE_OVERLAYS(mannequin)
	return mannequin.appearance

// This is necessary because you can open the set preferences menu before
// the atoms SS is done loading.
INITIALIZE_IMMEDIATE(/atom/movable/screen/map_view/character_preview_view)

/// A preview of a character for use in the preferences menu
/atom/movable/screen/map_view/character_preview_view
	name = "character_preview"
	del_on_map_removal = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	/// The body that is displayed
	var/mob/living/carbon/human/dummy/body

	/// The preferences this refers to
	var/datum/preferences/preferences

	var/datum/remote_view/remote_view

	/// List of clients with this registered to it.
	var/list/viewing_clients = list()

CREATION_TEST_IGNORE_SUBTYPES(/atom/movable/screen/map_view/character_preview_view)

/atom/movable/screen/map_view/character_preview_view/Initialize(mapload, datum/preferences/preferences)
	. = ..()

	// Remove brackets, as clients do not support map views with [] at the start or end well, or numbers for that matter.
	var/safe_ref = replacetext(replacetext(REF(src), "\[", ""), "\]", "")
	assigned_map = "character_preview_[safe_ref]_map"
	set_position(1, 1)

	src.preferences = preferences

/atom/movable/screen/map_view/character_preview_view/Destroy()
	QDEL_NULL(body)

	for(var/client/C as anything in viewing_clients)
		remote_view.leave(C)

	QDEL_NULL(remote_view)

	preferences?.character_preview_view = null

	viewing_clients = null
	preferences = null

	return ..()

/// Updates the currently displayed body
/atom/movable/screen/map_view/character_preview_view/proc/update_body()
	if (isnull(body))
		create_body()
	else
		body.wipe_state()
	body.appearance = preferences.render_new_preview_appearance(body)

/atom/movable/screen/map_view/character_preview_view/proc/create_body()
	vis_contents.Cut()
	QDEL_NULL(body)

	body = new

	// Without this, it doesn't show up in the menu
	body.appearance_flags &= ~KEEP_TOGETHER
	body.wipe_state() // cleanup the body immediately since it spawns with overlays, AI and cyborgs will retain them.
	vis_contents += body

/// Registers the relevant map objects to a client
/atom/movable/screen/map_view/character_preview_view/proc/register_to_client(client/client)
	if(client in viewing_clients)
		return
	if(!remote_view)
		remote_view = new(assigned_map)
		var/atom/lighting_plane = remote_view.get_plane(/atom/movable/screen/plane_master/lighting)
		lighting_plane?.alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
	viewing_clients += client
	client.register_map_obj(src)
	remote_view.join(client)

/// Unregisters the relevant map objects to a client
/atom/movable/screen/map_view/character_preview_view/proc/unregister_from_client(client/client)
	if(!istype(client) || !(client in viewing_clients))
		return
	remote_view.leave(client)
	viewing_clients -= client
	QDEL_NULL(remote_view)
