/datum/preferences/proc/create_character_preview_view()
	character_preview_view = new(null, src)

/datum/preferences/proc/render_new_preview_appearance(mob/living/carbon/human/dummy/mannequin)
	var/datum/job/preview_job = get_highest_priority_job()

	// Silicons only need a very basic preview since there is no customization for them.
	if (istype(preview_job, /datum/job/ai))
		return image('icons/mob/ai.dmi', icon_state = resolve_ai_icon_sync(read_character_preference(/datum/preference/choiced/ai_core_display)), dir = SOUTH)
	if (istype(preview_job, /datum/job/cyborg))
		return image('icons/mob/robots.dmi', icon_state = "robot", dir = SOUTH)

	// Set up the dummy for its photoshoot
	apply_prefs_to(mannequin, TRUE)

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

	var/list/plane_masters = list()

	/// List of clients with this registered to it.
	var/list/viewing_clients = list()

/atom/movable/screen/map_view/character_preview_view/Initialize(mapload, datum/preferences/preferences)
	. = ..()

	assigned_map = "character_preview_[REF(src)]"
	set_position(1, 1)

	src.preferences = preferences

/atom/movable/screen/map_view/character_preview_view/Destroy()
	QDEL_NULL(body)

	for (var/plane_master in plane_masters)
		qdel(plane_master)

	for(var/client/C as anything in viewing_clients)
		C?.clear_map(assigned_map)

	preferences?.character_preview_view = null

	viewing_clients = null
	plane_masters = null
	preferences = null

	return ..()

/// I know this looks stupid but it fixes a really important bug. https://www.byond.com/forum/post/2873835
/// Also the mouse opacity blocks this from being visible ever
/atom/movable/screen/map_view/character_preview_view/proc/rename_byond_bug_moment()
	name = name == "character_preview" ? "character_preview_1" : "character_preview"
	// Do it again, bitch!
	addtimer(CALLBACK(src, PROC_REF(rename_byond_bug_moment)), 1 SECONDS)

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
	if(!length(plane_masters))
		for(var/plane in subtypesof(/atom/movable/screen/plane_master) - /atom/movable/screen/plane_master/blackness)
			var/atom/movable/screen/plane_master/instance = new plane()
			instance.assigned_map = assigned_map
			if(instance.blend_mode_override)
				instance.blend_mode = instance.blend_mode_override
			instance.del_on_map_removal = FALSE
			instance.screen_loc = "[assigned_map]:CENTER"
			plane_masters += instance
	viewing_clients += client
	client.register_map_obj(src)
	for(var/plane_master in plane_masters)
		client.register_map_obj(plane_master)

/// Unregisters the relevant map objects to a client
/atom/movable/screen/map_view/character_preview_view/proc/unregister_from_client(client/client)
	if(!(client in viewing_clients))
		return
	client.clear_map(assigned_map)
	viewing_clients -= client
