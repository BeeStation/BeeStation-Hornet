/mob/living/carbon/human
	hud_possible = list(HEALTH_HUD,STATUS_HUD,ID_HUD,WANTED_HUD,IMPLOYAL_HUD,IMPCHEM_HUD,IMPTRACK_HUD, NANITE_HUD, DIAG_NANITE_FULL_HUD,ANTAG_HUD,GLAND_HUD,SENTIENT_DISEASE_HUD)
	hud_type = /datum/hud/human
	pressure_resistance = 25
	can_buckle = TRUE
	buckle_lying = 0
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	/// build_worn_icon is reponsible for building this, as each bodypart may be emissive and clothes
	/// or other bodyparts may block the emissive elements of it.
	blocks_emissive = EMISSIVE_BLOCK_NONE
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1

	///Hair color
	var/hair_color = COLOR_BLACK
	///Hair style
	var/hairstyle = "Bald"
	//Colours used for hair and facial hair gradients.
	var/list/grad_color = list(
		COLOR_BLACK, //Hair Gradient Color
		COLOR_BLACK, //Facial Hair Gradient Color
	)
	///Styles used for hair and facial hair gradients.
	var/list/grad_style = list(
		"None", //Hair Gradient Style
		"None", //Facial Hair Gradient Style
	)
	///Facial hair colour
	var/facial_hair_color = COLOR_BLACK
	///Facial hair style
	var/facial_hairstyle = "Shaved"
	//Eye colour
	var/eye_color = COLOR_BLACK
	var/skin_tone = "caucasian1"	//Skin tone
	var/lip_style = null	//no lipstick by default- arguably misleading, as it could be used for general makeup
	var/lip_color = COLOR_WHITE

	var/age = 30 //Player's age

	/// Which body type to use
	var/physique = MALE

	//consider updating /mob/living/carbon/human/copy_clothing_prefs() if adding more of these
	var/underwear = "Nude" //Which underwear the player wants
	var/underwear_color = COLOR_BLACK
	var/undershirt = "Nude" //Which undershirt the player wants
	var/socks = "Nude" //Which socks the player wants
	var/backbag = DBACKPACK //Which backpack type the player has chosen.
	var/jumpsuit_style = PREF_SUIT //suit/skirt

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

	/// What types of mobs are allowed to ride/buckle to this mob
	var/static/list/can_ride_typecache = typecacheof(list(
		/mob/living/carbon/human,
		/mob/living/simple_animal/slime,
		/mob/living/simple_animal/parrot,
		/mob/living/carbon/monkey,
	))
	var/lastpuke = 0

	/// The core temperature of the human compaired to the skin temp of the body
	var/coretemperature = BODYTEMP_NORMAL

	///Exposure to damaging heat levels increases stacks, stacks clean over time when temperatures are lower. Stack is consumed to add a wound.
	var/heat_exposure_stacks = 0
