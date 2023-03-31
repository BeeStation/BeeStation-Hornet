/datum/preference_character
	// Meta Vars //
	/// INT: Slot number. Used for internal tracking. The slot number also correspnds to the number of slots in the characters list
	var/slot_number = 0
	/// BOOL: Is this slot locked, likely due to not having enough character slots available
	var/slot_locked = FALSE
	/// STRING: The name of the character.
	var/real_name
	/// BOOL: If the name should be randomized
	var/be_random_name = FALSE
	/// BOOL: If the body should be randomized
	var/be_random_body = FALSE
	/// ENUM: The gender of the character
	var/gender = MALE
	/// INT: How old the character is
	var/age = 30
	/// STRING: What underwear type the character should use
	var/underwear = "Nude"
	/// STRING: The color of the underwear
	var/underwear_color = "000"
	/// STRING: What undershirt type the character should use
	var/undershirt = "Nude"
	/// STRING: What socks type the character should use
	var/socks = "Nude"
	/// STRING: (Plasmaman) What helmet type the character should spawn with
	var/helmet_style = HELMET_DEFAULT
	/// STRING: What backpack style the character should spawn with
	var/backbag = DBACKPACK
	/// STRING: What jumpsuit style the character should spawn with (suit/skirt)
	var/jumpsuit_style = PREF_SUIT
	/// STRING: What hair style the character should use
	var/hair_style = "Bald"
	/// STRING: What hair color the character should use
	var/hair_color = "000"
	/// STRING: What hair gradient color the character should use
	var/gradient_color = "000"
	/// STRING: What hair gradient style the character should use
	var/gradient_style = "None"
	/// STRING: What facial hair style the character should use
	var/facial_hair_style = "Shaved"
	/// STRING: What facial hair color the character should use
	var/facial_hair_color = "000"
	/// STRING: What skin tone the character should use
	var/skin_tone = "caucasian1"
	/// STRING: What eye color the character should use
	var/eye_color = "000"
	/// /datum/species: What species datum the character should spawn as
	var/datum/species/pref_species
	/// list: A relational list of features the character should spawn with, used for species specific data.
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
	/// list: A relational list of special name types to name values
	var/list/custom_names = list()
	/// STRING: What AI core display should be used
	var/preferred_ai_core_display = "Blue"
	/// STRING: What security department assignment is preferred
	var/preferred_security_department = SEC_DEPT_RANDOM
	/// list: List of all selected quirks
	var/list/all_quirks = list()
	var/list/job_preferences = list()
	/// list: List of all selected loadout equipment
	var/list/equipped_gear = list()
	/// STRING: What to do when the job you select is not available
	var/joblessrole = BERANDOMJOB  //defaults to 1 for fewer assistants
	/// STRING: Where your uplink should spawn as traitor
	var/uplink_spawn_loc = UPLINK_PDA
