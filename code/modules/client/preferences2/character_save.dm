/**
  * # Character Save Datum
  *
  * Datum to hold a character save which is put into a list on [/datum/preferences].
  * All of these are loaded on login.
  */
/datum/character_save
	// Meta Vars //
	/// Slot number. Used for internal tracking. The slot number also correspnds to the number of slots in the characters list
	var/slot_number = 0
	/// Is this slot locked, likely due to not having enough character slots available
	var/slot_locked = FALSE
	/// Was this loaded from the DB? (This is used to decide on INSERT or UPDATE queries)
	var/from_db = FALSE

	// Character Related Vars //
	/// Species datum

	var/real_name
	var/be_random_name = FALSE
	var/be_random_body = FALSE
	var/gender = MALE
	var/age = 30
	var/underwear = "Nude"
	var/underwear_color = "000"
	var/undershirt = "Nude"
	var/socks = "Nude" // how lewd
	var/helmet_style = HELMET_DEFAULT
	var/backbag = DBACKPACK
	var/jumpsuit_style = PREF_SUIT
	var/hair_style = "Bald"
	var/hair_color = "000"
	var/gradient_color = "000"
	var/gradient_style = "None"
	var/facial_hair_style = "Shaved"
	var/facial_hair_color = "000"
	var/skin_tone = "caucasian1"
	var/eye_color = "000"
	var/datum/species/pref_species
	var/list/features = list(
						"body_size" = "Normal",
						"mcolor" = "FFF",
						"ethcolor" = "9c3030",
						"tail_lizard" = "Smooth",
						"tail_human" = "None",
						"snout" = "Round",
						"horns" = "None",
						"ears" = "None",
						"wings" = "None",
						"frills" = "None",
						"spines" = "None",
						"body_markings" = "None",
						"legs" = "Normal Legs",
						"moth_wings" = "Plain",
						"moth_antennae" = "Plain",
						"moth_markings" = "None",
						"ipc_screen" = "Blue",
						"ipc_antenna" = "None",
						"ipc_chassis" = "Morpheus Cyberkinetics(Greyscale)",
						"insect_type" = "Common Fly",
						"apid_antenna" = "Curled",
						"apid_stripes" = "Thick",
						"apid_headstripes" = "Thick",
						"body_model" = MALE
					)
	var/list/custom_names = list()
	var/preferred_ai_core_display = "Blue"
	var/preferred_security_department = SEC_DEPT_RANDOM
	var/list/all_quirks = list()
	var/list/job_preferences = list()
	var/list/equipped_gear = list()
	var/joblessrole = BERANDOMJOB  //defaults to 1 for fewer assistants
	var/uplink_spawn_loc = UPLINK_PDA


/datum/character_save/New()
	real_name = get_default_name()
	for(var/custom_name_id in GLOB.preferences_custom_names)
		custom_names[custom_name_id] = get_default_name(custom_name_id)

#define SAFE_READ_QUERY(idx, target)  if(Q.item[idx]) target = Q.item[idx]

/datum/character_save/proc/handle_query(datum/DBQuery/Q)
	from_db = TRUE

	// please keep these in numerical order I beg
	//Species
	var/species_id
	SAFE_READ_QUERY(2, species_id)

	if(!species_id) // There was no species ID saved, make it random
		species_id = pick(GLOB.roundstart_races)

	var/newtype = GLOB.species_list[species_id]

	if(!newtype) // The species ID doesn't exist in the species list, make it random
		newtype = GLOB.species_list[pick(GLOB.roundstart_races)]

	pref_species = new newtype

	if(!pref_species) // there are no roundstart species enabled. Time to die
		pref_species = new /datum/species/human
		if(!length(GLOB.roundstart_races))
			CRASH("There are no roundstart races enabled! You must enable at least one for the character setup to function.")

	//Character
	SAFE_READ_QUERY(3, real_name)
	SAFE_READ_QUERY(4, be_random_name)
	SAFE_READ_QUERY(5, be_random_body)
	SAFE_READ_QUERY(6, gender)
	SAFE_READ_QUERY(7, age)
	SAFE_READ_QUERY(8, hair_color)
	SAFE_READ_QUERY(9, gradient_color)
	SAFE_READ_QUERY(10, facial_hair_color)
	SAFE_READ_QUERY(11, eye_color)
	SAFE_READ_QUERY(12, skin_tone)
	SAFE_READ_QUERY(13, hair_style)
	SAFE_READ_QUERY(14, gradient_style)
	SAFE_READ_QUERY(15, facial_hair_style)
	SAFE_READ_QUERY(16, underwear)
	SAFE_READ_QUERY(17, underwear_color)
	SAFE_READ_QUERY(18, undershirt)
	SAFE_READ_QUERY(19, socks)
	SAFE_READ_QUERY(20, backbag)
	SAFE_READ_QUERY(21, jumpsuit_style)
	SAFE_READ_QUERY(22, uplink_spawn_loc)

	var/tmp_features
	SAFE_READ_QUERY(23, tmp_features)
	if(tmp_features)
		features = json_decode(tmp_features)

	if(!CONFIG_GET(flag/join_with_mutant_humans) && !species_id != "felinid") // felinids arent mutant humans anymore i guess
		features["tail_human"] = "none"
		features["ears"] = "none"

	//Custom names
	var/tmp_names
	SAFE_READ_QUERY(24, tmp_names)
	custom_names = json_decode(tmp_names)

	SAFE_READ_QUERY(25, helmet_style)

	SAFE_READ_QUERY(26, preferred_ai_core_display)
	SAFE_READ_QUERY(27, preferred_security_department)

	//Jobs
	SAFE_READ_QUERY(28, joblessrole)
	//Load prefs
	var/job_tmp
	SAFE_READ_QUERY(29, job_tmp)
	job_preferences = json_decode(job_tmp)

	//Quirks
	var/quirks_tmp
	SAFE_READ_QUERY(30, quirks_tmp)
	all_quirks = json_decode(quirks_tmp)

	// Gear
	var/loadout_tmp
	SAFE_READ_QUERY(31, loadout_tmp)
	equipped_gear = json_decode(loadout_tmp)

	//Sanitize. Please dont put query reads below this point. Please.

	real_name = reject_bad_name(real_name, pref_species.allow_numbers_in_name)
	gender = sanitize_gender(gender)
	real_name ||= pref_species.random_name(gender, TRUE)

	for(var/custom_name_id in GLOB.preferences_custom_names)
		var/namedata = GLOB.preferences_custom_names[custom_name_id]
		custom_names[custom_name_id] = reject_bad_name(custom_names[custom_name_id],namedata["allow_numbers"])
		if(!custom_names[custom_name_id])
			custom_names[custom_name_id] = get_default_name(custom_name_id)

	if(!features["mcolor"] || features["mcolor"] == "#000")
		features["mcolor"] = pick("FFFFFF","7F7F7F", "7FFF7F", "7F7FFF", "FF7F7F", "7FFFFF", "FF7FFF", "FFFF7F")

	if(!features["ethcolor"] || features["ethcolor"] == "#000")
		features["ethcolor"] = GLOB.color_list_ethereal[pick(GLOB.color_list_ethereal)]

	// Keep it updated
	if(!helmet_style || !(helmet_style in list(HELMET_DEFAULT, HELMET_MK2, HELMET_PROTECTIVE)))
		helmet_style = HELMET_DEFAULT

	be_random_name	= sanitize_integer(be_random_name, 0, 1, initial(be_random_name))
	be_random_body	= sanitize_integer(be_random_body, 0, 1, initial(be_random_body))

	hair_style = sanitize_inlist(hair_style, GLOB.hair_styles_list)
	facial_hair_style = sanitize_inlist(facial_hair_style, GLOB.facial_hair_styles_list)
	underwear = sanitize_inlist(underwear, GLOB.underwear_list)
	undershirt = sanitize_inlist(undershirt, GLOB.undershirt_list)
	features["body_model"] = sanitize_gender(features["body_model"], FALSE, FALSE, gender == FEMALE ? FEMALE : MALE)
	socks = sanitize_inlist(socks, GLOB.socks_list)
	age = sanitize_integer(age, AGE_MIN, AGE_MAX, initial(age))
	hair_color = sanitize_hexcolor(hair_color, 3, 0)
	facial_hair_color = sanitize_hexcolor(facial_hair_color, 3, 0)
	gradient_style = sanitize_inlist(gradient_style, GLOB.hair_gradients_list, "None")
	gradient_color = sanitize_hexcolor(gradient_color, 3, 0)
	underwear_color	= sanitize_hexcolor(underwear_color, 3, 0)
	eye_color = sanitize_hexcolor(eye_color, 3, 0)
	skin_tone = sanitize_inlist(skin_tone, GLOB.skin_tones)
	backbag	= sanitize_inlist(backbag, GLOB.backbaglist, initial(backbag))
	jumpsuit_style = sanitize_inlist(jumpsuit_style, GLOB.jumpsuitlist, initial(jumpsuit_style))
	uplink_spawn_loc = sanitize_inlist(uplink_spawn_loc, GLOB.uplink_spawn_loc_list_save, initial(uplink_spawn_loc))
	features["body_size"] = sanitize_inlist(features["body_size"], GLOB.body_sizes, "Normal")
	features["mcolor"]	= sanitize_hexcolor(features["mcolor"], 3, 0)
	features["ethcolor"]	= copytext_char(features["ethcolor"], 1, 7)
	features["tail_lizard"]	= sanitize_inlist(features["tail_lizard"], GLOB.tails_list_lizard)
	features["tail_human"] 	= sanitize_inlist(features["tail_human"], GLOB.tails_list_human, "None")
	features["snout"] = sanitize_inlist(features["snout"], GLOB.snouts_list)
	features["horns"] = sanitize_inlist(features["horns"], GLOB.horns_list)
	features["ears"] = sanitize_inlist(features["ears"], GLOB.ears_list, "None")
	features["frills"] = sanitize_inlist(features["frills"], GLOB.frills_list)
	features["spines"] = sanitize_inlist(features["spines"], GLOB.spines_list)
	features["body_markings"] = sanitize_inlist(features["body_markings"], GLOB.body_markings_list)
	features["feature_lizard_legs"]	= sanitize_inlist(features["legs"], GLOB.legs_list, "Normal Legs")
	features["moth_wings"] = sanitize_inlist(features["moth_wings"], GLOB.moth_wings_roundstart_list, "Plain")
	features["moth_antennae"] = sanitize_inlist(features["moth_antennae"], GLOB.moth_antennae_roundstart_list, "Plain")
	features["moth_markings"] = sanitize_inlist(features["moth_markings"], GLOB.moth_markings_roundstart_list, "None")
	features["ipc_screen"] = sanitize_inlist(features["ipc_screen"], GLOB.ipc_screens_list)
	features["ipc_antenna"]	= sanitize_inlist(features["ipc_antenna"], GLOB.ipc_antennas_list)
	features["ipc_chassis"]	= sanitize_inlist(features["ipc_chassis"], GLOB.ipc_chassis_list)
	features["insect_type"]	= sanitize_inlist(features["insect_type"], GLOB.insect_type_list)
	features["apid_antenna"] = sanitize_inlist(features["apid_antenna"], GLOB.apid_antenna_list)
	features["apid_stripes"] = sanitize_inlist(features["apid_stripes"], GLOB.apid_stripes_list)
	features["apid_headstripes"] = sanitize_inlist(features["apid_headstripes"], GLOB.apid_headstripes_list)


	//Validate species forced mutant parts
	for(var/forced_part in pref_species.forced_features)
		//Get the forced type
		var/forced_type = pref_species.forced_features[forced_part]
		//Apply the forced bodypart.
		features[forced_part] = forced_type

	joblessrole	= sanitize_integer(joblessrole, 1, 3, initial(joblessrole))
	//Validate job prefs
	for(var/j in job_preferences)
		if(job_preferences[j] != JP_LOW && job_preferences[j] != JP_MEDIUM && job_preferences[j] != JP_HIGH)
			job_preferences -= j

	all_quirks = SANITIZE_LIST(all_quirks)

	return TRUE

#undef SAFE_READ_QUERY

/datum/character_save/proc/randomise(gender_override)
	if(gender_override)
		gender = gender_override
	else
		gender = pick(MALE,FEMALE)
	underwear = random_underwear(gender)
	underwear_color = random_short_color()
	undershirt = random_undershirt(gender)
	socks = random_socks()
	skin_tone = random_skin_tone()
	hair_style = random_hair_style(gender)
	facial_hair_style = random_facial_hair_style(gender)
	hair_color = random_short_color()
	facial_hair_color = hair_color
	eye_color = random_eye_color()
	if(!pref_species)
		var/datum/species/spath = GLOB.species_list[pick(GLOB.roundstart_races)]
		pref_species = new spath
	features = random_features()
	if(gender)
		features["body_model"] = pick(MALE,FEMALE)
	age = rand(AGE_MIN,AGE_MAX)

/datum/character_save/proc/update_preview_icon(client/parent)
	if(!parent)
		CRASH("Someone called update_preview_icon() without passing a client.")
	// Determine what job is marked as 'High' priority, and dress them up as such.
	var/datum/job/previewJob
	var/highest_pref = 0
	for(var/job in job_preferences)
		if(job_preferences[job] > highest_pref)
			previewJob = SSjob.GetJob(job)
			highest_pref = job_preferences[job]

	if(previewJob)
		// Silicons only need a very basic preview since there is no customization for them.
		if(istype(previewJob,/datum/job/ai))
			parent.show_character_previews(image('icons/mob/ai.dmi', icon_state = resolve_ai_icon(preferred_ai_core_display), dir = SOUTH))
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

/datum/character_save/proc/save(client/C, async = TRUE)
	if(!SSdbcore.IsConnected())
		return

	if(IS_GUEST_KEY(C.ckey))
		return

	// Get ready for a disgusting query
	var/datum/DBQuery/insert_query = SSdbcore.NewQuery({"
		REPLACE INTO [format_table_name("characters")] (
			slot,
			ckey,
			species,
			real_name,
			name_is_always_random,
			body_is_always_random,
			gender,
			age,
			hair_color,
			gradient_color,
			facial_hair_color,
			eye_color,
			skin_tone,
			hair_style_name,
			gradient_style,
			facial_style_name,
			underwear,
			underwear_color,
			undershirt,
			socks,
			backbag,
			jumpsuit_style,
			uplink_loc,
			features,
			custom_names,
			helmet_style,
			preferred_ai_core_display,
			preferred_security_department,
			joblessrole,
			job_preferences,
			all_quirks,
			equipped_gear
		) VALUES (
			:slot,
			:ckey,
			:species,
			:real_name,
			:name_is_always_random,
			:body_is_always_random,
			:gender,
			:age,
			:hair_color,
			:gradient_color,
			:facial_hair_color,
			:eye_color,
			:skin_tone,
			:hair_style_name,
			:gradient_style,
			:facial_style_name,
			:underwear,
			:underwear_color,
			:undershirt,
			:socks,
			:backbag,
			:jumpsuit_style,
			:uplink_loc,
			:features,
			:custom_names,
			:helmet_style,
			:preferred_ai_core_display,
			:preferred_security_department,
			:joblessrole,
			:job_preferences,
			:all_quirks,
			:equipped_gear
		)
	"}, list(
		// Now for the above but in a fucking monsterous list
		"slot" = slot_number,
		"ckey" = C.ckey,
		"species" = pref_species.id,
		"real_name" = real_name,
		"name_is_always_random" = be_random_name,
		"body_is_always_random" = be_random_body,
		"gender" = gender,
		"age" = age,
		"hair_color" = hair_color,
		"gradient_color" = gradient_color,
		"facial_hair_color" = facial_hair_color,
		"eye_color" = eye_color,
		"skin_tone" = skin_tone,
		"hair_style_name" = hair_style,
		"gradient_style" = gradient_style,
		"facial_style_name" = facial_hair_style,
		"underwear" = underwear,
		"underwear_color" = underwear_color,
		"undershirt" = undershirt,
		"socks" = socks,
		"backbag" = backbag,
		"jumpsuit_style" = jumpsuit_style,
		"uplink_loc" = uplink_spawn_loc,
		"features" = json_encode(features),
		"custom_names" = json_encode(custom_names),
		"helmet_style" = helmet_style,
		"preferred_ai_core_display" = preferred_ai_core_display,
		"preferred_security_department" = preferred_security_department,
		"joblessrole" = joblessrole,
		"job_preferences" = json_encode(job_preferences),
		"all_quirks" = json_encode(all_quirks),
		"equipped_gear" = json_encode(equipped_gear)
	))

	if(!insert_query.warn_execute())
		to_chat(usr, "<span class='boldannounce'>Failed to save your character. Please inform the server operator.</span>")
		qdel(insert_query)
		return

	qdel(insert_query)

	// We defo exist in the DB now
	from_db = TRUE

/datum/character_save/proc/copy_to(mob/living/carbon/human/character, icon_updates = 1, roundstart_checks = TRUE)
	if(be_random_name)
		real_name = pref_species.random_name(gender)

	if(be_random_body)
		randomise(gender)

	if(roundstart_checks)
		if(CONFIG_GET(flag/humans_need_surnames) && (pref_species.id == SPECIES_HUMAN))
			var/firstspace = findtext(real_name, " ")
			var/name_length = length(real_name)
			if(!firstspace)	//we need a surname
				real_name += " [pick(GLOB.last_names)]"
			else if(firstspace == name_length)
				real_name += "[pick(GLOB.last_names)]"

	character.real_name = real_name
	character.name = character.real_name

	character.gender = gender
	character.age = age

	character.eye_color = eye_color
	var/obj/item/organ/eyes/organ_eyes = character.getorgan(/obj/item/organ/eyes)
	if(organ_eyes)
		if(!initial(organ_eyes.eye_color))
			organ_eyes.eye_color = eye_color
		organ_eyes.old_eye_color = eye_color

	character.hair_color = hair_color
	character.gradient_color = gradient_color
	character.gradient_style = gradient_style
	character.facial_hair_color = facial_hair_color
	character.skin_tone = skin_tone
	character.underwear = underwear
	character.underwear_color = underwear_color
	character.undershirt = undershirt
	character.socks = socks

	character.backbag = backbag
	character.jumpsuit_style = jumpsuit_style

	var/datum/species/chosen_species
	chosen_species = pref_species.type
	if(!roundstart_checks || (pref_species.id in GLOB.roundstart_races) || pref_species.check_no_hard_check())
		chosen_species = pref_species.type
	else
		chosen_species = /datum/species/human
		pref_species = new /datum/species/human
		save(usr.client, async = FALSE) // This entire proc is called a lot at roundstart, and we dont want to lag that


	character.dna.features = features.Copy()
	character.set_species(chosen_species, icon_update = FALSE, pref_load = TRUE)

	//Because of how set_species replaces all bodyparts with new ones, hair needs to be set AFTER species.
	character.dna.real_name = character.real_name
	character.hair_color = hair_color
	character.facial_hair_color = facial_hair_color

	character.hair_style = hair_style
	character.facial_hair_style = facial_hair_style

	if("tail_lizard" in pref_species.default_features)
		character.dna.species.mutant_bodyparts |= "tail_lizard"

	if(icon_updates)
		character.update_body()
		character.update_hair()
		character.update_body_parts(TRUE)
