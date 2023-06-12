/datum/preferences/proc/create_character_preview_view(mob/user)
	character_preview_view = new(null, src, user.client)
	character_preview_view.update_body()
	character_preview_view.register_to_client(user.client)

	return character_preview_view

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

	/// The client that is watching this view
	var/client/client

/atom/movable/screen/map_view/character_preview_view/Initialize(mapload, datum/preferences/preferences, client/client)
	. = ..()

	assigned_map = "character_preview_[REF(src)]"
	set_position(1, 1)

	src.preferences = preferences

/atom/movable/screen/map_view/character_preview_view/Destroy()
	QDEL_NULL(body)

	for (var/plane_master in plane_masters)
		client?.screen -= plane_master
		qdel(plane_master)

	client?.clear_map(assigned_map)
	client?.screen -= src

	preferences?.character_preview_view = null

	client = null
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
	QDEL_LIST(plane_masters)

	src.client = client

	if (!client)
		return

	for (var/plane_master_type in subtypesof(/atom/movable/screen/plane_master))
		var/atom/movable/screen/plane_master/plane_master = new plane_master_type
		plane_master.screen_loc = "[assigned_map]:CENTER"
		client?.screen |= plane_master

		plane_masters += plane_master

	client?.register_map_obj(src)
