
	//The mob should have a gender you want before running this proc. Will run fine without H
/datum/preferences/proc/random_character(gender_override)
	if(gender_override)
		character.gender = gender_override
	else
		character.gender = pick(MALE,FEMALE)
	character.underwear = random_underwear(character.gender)
	character.underwear_color = random_short_color()
	character.undershirt = random_undershirt(character.gender)
	character.socks = random_socks()
	character.skin_tone = random_skin_tone()
	character.hair_style = random_hair_style(character.gender)
	character.facial_hair_style = random_facial_hair_style(character.gender)
	character.hair_color = random_short_color()
	character.facial_hair_color = character.hair_color
	character.eye_color = random_eye_color()
	if(!character.pref_species)
		var/rando_race = pick(GLOB.roundstart_races)
		character.pref_species = new rando_race()
	character.features = random_features()
	character.age = rand(AGE_MIN,AGE_MAX)

/datum/preferences/proc/update_preview_icon()
	// Determine what job is marked as 'High' priority, and dress them up as such.
	var/datum/job/previewJob
	var/highest_pref = 0
	for(var/job in character.job_preferences)
		if(character.job_preferences[job] > highest_pref)
			previewJob = SSjob.GetJob(job)
			highest_pref = character.job_preferences[job]

	if(previewJob)
		// Silicons only need a very basic preview since there is no customization for them.
		if(istype(previewJob,/datum/job/ai))
			parent.show_character_previews(image('icons/mob/ai.dmi', icon_state = resolve_ai_icon(character.preferred_ai_core_display), dir = SOUTH))
			return
		if(istype(previewJob,/datum/job/cyborg))
			parent.show_character_previews(image('icons/mob/robots.dmi', icon_state = "robot", dir = SOUTH))
			return

	// Set up the dummy for its photoshoot
	var/mob/living/carbon/human/dummy/mannequin = generate_or_wait_for_human_dummy(DUMMY_HUMAN_SLOT_PREFERENCES)
	copy_to(mannequin)

	if(previewJob)
		mannequin.job = previewJob.title
		previewJob.equip(mannequin, TRUE, preference_source = parent)

	COMPILE_OVERLAYS(mannequin)
	parent.show_character_previews(new /mutable_appearance(mannequin))
	unset_busy_human_dummy(DUMMY_HUMAN_SLOT_PREFERENCES)
