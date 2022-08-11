/datum/antagonist/blob
	name = "Blob"
	roundend_category = "blobs"
	antagpanel_category = "Blob"
	show_to_ghosts = TRUE
	job_rank = ROLE_BLOB

	var/datum/action/innate/blobpop/pop_action
	var/starting_points_human_blob = 60

/datum/antagonist/blob/roundend_report()
	var/basic_report = ..()
	//Display max blobpoints for blebs that lost
	if(isovermind(owner.current)) //embarrasing if not
		var/mob/camera/blob/overmind = owner.current
		if(!overmind.victory_in_progress) //if it won this doesn't really matter
			var/point_report = "<br><b>[owner.name]</b> took over [overmind.max_count] tiles at the height of its growth."
			return basic_report+point_report
	return basic_report

/datum/antagonist/blob/greet()
	to_chat(owner.current, "<span class='notice'><font color=\"#EE4000\">You are the Blob!</font></span>")
	owner.announce_objectives()
	if(!isovermind(owner.current))
		owner.current.client?.tgui_panel?.give_antagonist_popup("Blob", "Use the pop ability to place your blob core! It is recommended you do this away from anyone else, as you'll be taking on the entire crew!");
	else
		owner.current.client?.tgui_panel?.give_antagonist_popup("Blob",
			"Place your core by using the place core button.\n\
			Expand and manage your resources carefully, the crew will know about your existence soon \
			and will work together to destroy you.")
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/blobalert.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)

/datum/antagonist/blob/on_gain()
	create_objectives()
	. = ..()

/datum/antagonist/blob/remove_innate_effects()
	QDEL_NULL(pop_action)
	return ..()

/datum/antagonist/blob/farewell()
	to_chat(owner.current, "<span class='alertsyndie'><font color=\"#EE4000\">You are no longer the Blob!</font></span>")
	return ..()

/datum/antagonist/blob/proc/create_objectives()
	if(!give_objectives)
		return
	var/datum/objective/blob_takeover/main = new
	main.owner = owner
	objectives += main
	log_objective(owner, main.explanation_text)

/datum/antagonist/blob/apply_innate_effects(mob/living/mob_override)
	if(!isovermind(owner.current))
		if(!pop_action)
			pop_action = new
		pop_action.Grant(owner.current)

/datum/objective/blob_takeover
	explanation_text = "Reach critical mass!"

//Non-overminds get this on blob antag assignment
/datum/action/innate/blobpop
	name = "Pop"
	desc = "Unleash the blob"
	icon_icon = 'icons/mob/blob.dmi'
	button_icon_state = "blob"

	/// The time taken before this ability is automatically activated.
	var/autoplace_time = OVERMIND_STARTING_AUTO_PLACE_TIME

/datum/action/innate/blobpop/Grant(Target)
	. = ..()
	if(owner)
		addtimer(CALLBACK(src, .proc/Activate, TRUE), autoplace_time, TIMER_UNIQUE|TIMER_OVERRIDE)
		to_chat(owner, "<span class='big'><font color=\"#EE4000\">You will automatically pop and place your blob core in [DisplayTimeText(autoplace_time)].</font></span>")

/datum/action/innate/blobpop/Activate(timer_activated = FALSE)
	var/mob/living/old_body = owner
	if(!owner)
		return

	var/datum/antagonist/blob/blobtag = owner.mind.has_antag_datum(/datum/antagonist/blob)
	if(!blobtag)
		Remove(owner)
		return

	. = TRUE
	var/turf/target_turf = get_turf(owner)
	if(target_turf.density)
		to_chat(owner, "<span class='warning'>This spot is too dense to place a blob core on!</span>")
		. = FALSE
	var/area/target_area = get_area(target_turf)
	if(isspaceturf(target_turf) || !(target_area?.area_flags & BLOBS_ALLOWED) || !is_station_level(target_turf.z))
		to_chat(owner, "<span class='warning'>You cannot place your core here!</span>")
		. = FALSE

	var/placement_override = BLOB_FORCE_PLACEMENT
	if(!.)
		if(!timer_activated)
			return
		placement_override = BLOB_RANDOM_PLACEMENT
		to_chat(owner, "<span class='boldwarning'>Because your current location is an invalid starting spot and you need to pop, you've been moved to a random location!</span>")

	var/mob/camera/blob/blob_cam = new /mob/camera/blob(get_turf(old_body), blobtag.starting_points_human_blob)
	owner.mind.transfer_to(blob_cam)
	old_body.gib()
	blob_cam.place_blob_core(placement_override, pop_override = TRUE)
	playsound(get_turf(blob_cam), 'sound/ambience/antag/blobalert.ogg', 50, FALSE)

/datum/antagonist/blob/antag_listing_status()
	. = ..()
	if(owner?.current)
		var/mob/camera/blob/blob_cam = owner.current
		if(istype(blob_cam))
			. += "(Progress: [length(blob_cam.blobs_legit)]/[blob_cam.blobwincount])"
