/mob/living/carbon/human
	hud_possible = list(HEALTH_HUD,STATUS_HUD,ID_HUD,WANTED_HUD,IMPLOYAL_HUD,IMPCHEM_HUD,IMPTRACK_HUD, NANITE_HUD, DIAG_NANITE_FULL_HUD,ANTAG_HUD,GLAND_HUD,SENTIENT_DISEASE_HUD)
	hud_type = /datum/hud/human
	pressure_resistance = 25
	can_buckle = TRUE
	buckle_lying = 0
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	/// build_worn_icon is reponsible for building this, as each bodypart may be emissive and clothes
	/// or other bodyparts may block the emissive elements of it.
	blocks_emissive = FALSE

	///Hair color
	var/hair_color = "000"
	///Hair style
	var/hair_style = "Bald"
	///Colour used for the hair gradient.
	var/gradient_color = "000"
	///Style used for the hair gradient.
	var/gradient_style = "None"
	///Facial hair colour
	var/facial_hair_color = "000"
	///Facial hair style
	var/facial_hair_style = "Shaved"
	//Eye colour
	var/eye_color = "000"
	var/skin_tone = "caucasian1"	//Skin tone
	var/lip_style = null	//no lipstick by default- arguably misleading, as it could be used for general makeup
	var/lip_color = "white"
	var/age = 30		//Player's age
	//consider updating /mob/living/carbon/human/copy_clothing_prefs() if adding more of these
	var/underwear = "Nude"	//Which underwear the player wants
	var/underwear_color = "000"
	var/undershirt = "Nude" //Which undershirt the player wants
	var/socks = "Nude" //Which socks the player wants
	var/backbag = DBACKPACK		//Which backpack type the player has chosen.
	var/jumpsuit_style = PREF_SUIT		//suit/skirt

	//Equipment slots
	var/obj/item/clothing/wear_suit = null
	var/obj/item/clothing/w_uniform = null
	var/obj/item/belt = null
	var/obj/item/wear_id = null
	var/obj/item/r_store = null
	var/obj/item/l_store = null
	var/obj/item/s_store = null

	var/special_voice = "" // For changing our voice. Used by a symptom.

	var/bleed_rate = 0 //how much are we bleeding
	/// How many "units of blood" we have on our hands
	var/blood_in_hands = 0

	var/name_override //For temporary visible name changes

	var/datum/physiology/physiology

	var/list/datum/bioware = list()

	/// What types of mobs are allowed to ride/buckle to this mob
	var/static/list/can_ride_typecache = typecacheof(
		list(
			/mob/living/carbon/human,
			/mob/living/simple_animal/slime,
			/mob/living/simple_animal/parrot,
			/mob/living/carbon/monkey
		)
	)
	var/lastpuke = 0
	var/last_fire_update

	/// The core temperature of the human compaired to the skin temp of the body
	var/coretemperature = BODYTEMP_NORMAL

	///Exposure to damaging heat levels increases stacks, stacks clean over time when temperatures are lower. Stack is consumed to add a wound.
	var/heat_exposure_stacks = 0
