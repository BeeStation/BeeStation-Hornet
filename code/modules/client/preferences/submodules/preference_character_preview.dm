/datum/preferences/proc/render_new_preview_appearance(mob/living/carbon/human/dummy/mannequin, show_job_clothes = TRUE)
	var/datum/job/no_job = SSjob.get_job_type(/datum/job/unassigned)
	var/datum/job/preview_job = get_highest_priority_job() || no_job

	if(preview_job)
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

	mannequin.job = preview_job.title
	mannequin.dress_up_as_job(
		equipping = show_job_clothes ? preview_job : no_job,
		visual_only = TRUE,
		player_client = parent,
		consistent = TRUE,
	)

	return mannequin.appearance

/// A preview of a character for use in the preferences menu
/atom/movable/screen/map_view/character_preview_view
	name = "character_preview"
	del_on_map_removal = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	/// The body that is displayed
	var/mob/living/carbon/human/dummy/body
	/// The preferences this refers to
	var/datum/preferences/preferences
	/// Whether we show current job clothes or nude/loadout only
	var/show_job_clothes = TRUE

CREATION_TEST_IGNORE_SUBTYPES(/atom/movable/screen/map_view/character_preview_view)

/atom/movable/screen/map_view/character_preview_view/Initialize(mapload, datum/hud/hud_owner, datum/preferences/preferences)
	. = ..()
	src.preferences = preferences

/atom/movable/screen/map_view/character_preview_view/Destroy()
	QDEL_NULL(body)
	if(preferences)
		preferences.character_preview_view = null
		preferences = null
	return ..()

/// Updates the currently displayed body
/atom/movable/screen/map_view/character_preview_view/proc/update_body()
	if (isnull(body))
		create_body()
	else
		body.wipe_state()

	body.appearance = preferences.render_new_preview_appearance(body, show_job_clothes)

/atom/movable/screen/map_view/character_preview_view/proc/create_body()
	vis_contents.Cut()
	QDEL_NULL(body)

	body = new

	// Without this, it doesn't show up in the menu
	body.appearance_flags &= ~KEEP_TOGETHER
	body.wipe_state() // cleanup the body immediately since it spawns with overlays, AI and cyborgs will retain them.
	vis_contents += body

/atom/movable/screen/map_view/character_preview_view/generate_view(map_key)
	. = ..()
	var/atom/lighting_plane = remote_view?.get_plane(/atom/movable/screen/plane_master/lighting)
	lighting_plane?.alpha = LIGHTING_PLANE_ALPHA_INVISIBLE

