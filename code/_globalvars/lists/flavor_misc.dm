//Preferences stuff
	//Hairstyles
/// Body sizes. The names (keys) are what is actually stored in the database. Don't get crazy with changing them.
GLOBAL_LIST_INIT(body_sizes, list(
	"Normal" = BODY_SIZE_NORMAL,
	"Short" = BODY_SIZE_SHORT,
	"Tall" = BODY_SIZE_TALL
))

GLOBAL_LIST_INIT(color_list_ethereal, list(
	"Red" = "#ff3131",
	"Maroon" = "#9c3030",
	"Burnt Orange" = "#cc4400",
	"Orange" = "#f69c28",
	"Yellow" = "#fbdf56",
	"Sandy Yellow" = "#ffefa5",
	"Green" = "#97ee63",
	"Dark Green" = "#0ab432",
	"Sea Green" = "#37835b",
	"Spring Green" = "#00fa9a",
	"Dark Teal" = "#5ea699",
	"Pink" = "#ff99cc",
	"Rose" = "#ff92b6",
	"Dark Fuschia" = "#cc0066",
	"Purple" = "#a42df7",
	"Orchid Purple" = "#ee82ee",
	"Lavender" = "#d1acff",
	"Gray" = "#979497",
	"White" = "#f2f2f2",
	"Cyan Blue" = "#00ffff",
	"Powder Blue" = "#95e5ff",
	"Blue" = "#3399ff",
	"Denim Blue" = "#3399ff",
	"Dark Blue" = "#6666ff",
	"Royal Blue" = "#5860f5"
))

//stores the ghost forms that support directional sprites
GLOBAL_LIST_INIT(ghost_forms_with_directions_list, list(
	"catghost",
	"ghost_black",
	"ghost_blazeit",
	"ghost_blue",
	"ghost_camo",
	"ghost_cyan",
	"ghost_dblue",
	"ghost_dcyan",
	"ghost_dgreen",
	"ghost_dpink",
	"ghost_dred",
	"ghost_dyellow",
	"ghost_fire",
	"ghost_funkypurp",
	"ghost_green",
	"ghost_grey",
	"ghost_mellow",
	"ghost_pink",
	"ghost_pinksherbert",
	"ghost_purpleswirl",
	"ghost_rainbow",
	"ghost_red",
	"ghost_yellow",
	"ghost",
	"ghostian",
	"ghostian2",
	"ghostking",
	"skeleghost",
))

//stores the ghost forms that support hair and other such things
GLOBAL_LIST_INIT(ghost_forms_with_accessories_list, list(
	"ghost",
	"ghost_red",
	"ghost_black",
	"ghost_blue",
	"ghost_yellow",
	"ghost_green",
	"ghost_pink",
	"ghost_cyan",
	"ghost_dblue",
	"ghost_dred",
	"ghost_dgreen",
	"ghost_dcyan",
	"ghost_grey",
	"ghost_dyellow",
	"ghost_dpink",
	"skeleghost",
	"ghost_purpleswirl",
	"ghost_rainbow",
	"ghost_fire",
	"ghost_funkypurp",
	"ghost_pinksherbert",
	"ghost_blazeit",
	"ghost_mellow",
	"ghost_camo",
))


GLOBAL_LIST_INIT(ai_core_display_screens, sort_list(list(
	":thinking:",
	"Alien",
	"Angel",
	"Banned",
	"Bliss",
	"Blue",
	"Cat",
	"Clown",
	"Database",
	"Dorf",
	"Firewall",
	"Fuzzy",
	"Gentoo",
	"Glitchman",
	"Gondola",
	"Goon",
	"Hades",
	"Heartline",
	"Helios",
	"House",
	"Inverted",
	"Matrix",
	"Monochrome",
	"Murica",
	"Nanotrasen",
	"Not Malf",
	"Portrait",
	"President",
	"Rainbow",
	"Random",
	"Red October",
	"Red",
	"Static",
	"Syndicat Meow",
	"Text",
	"Too Deep",
	"Triumvirate-M",
	"Triumvirate",
	"Weird"
)))

/// A form of resolve_ai_icon that is guaranteed to never sleep.
/// Not always accurate, but always synchronous.
/proc/resolve_ai_icon_sync(input)
	SHOULD_NOT_SLEEP(TRUE)

	if(!input || !(input in GLOB.ai_core_display_screens))
		return "ai"
	else
		if(input == "Random")
			input = pick(GLOB.ai_core_display_screens - "Random")
		return "ai-[LOWER_TEXT(input)]"

/proc/resolve_ai_icon(input)
	if (input == "Portrait")
		var/datum/portrait_picker/tgui = new(usr)//create the datum
		tgui.ui_interact(usr)//datum has a tgui component, here we open the window
		return "ai-portrait" //just take this until they decide

	return resolve_ai_icon_sync(input)

GLOBAL_LIST_INIT(security_depts_prefs, sort_list(list(
	SEC_DEPT_ENGINEERING,
	SEC_DEPT_MEDICAL,
	SEC_DEPT_NONE,
	SEC_DEPT_RANDOM,
	SEC_DEPT_SCIENCE,
	SEC_DEPT_SUPPLY
)))


GLOBAL_LIST_INIT(backbaglist, list(
	DBACKPACK,
	DDUFFELBAG,
	DSATCHEL,
	GBACKPACK,
	GDUFFELBAG,
	GSATCHEL,
	LSATCHEL
))


GLOBAL_LIST_INIT(jumpsuitlist, list(
	PREF_SKIRT,
	PREF_SUIT,
))

// What we show to the user
GLOBAL_LIST_INIT(uplink_spawn_loc_list, list(
	UPLINK_PDA,
	UPLINK_RADIO,
	UPLINK_PEN
))
// What is actually saved; if the uplink implant price changes, it won't affect save files then
GLOBAL_LIST_INIT(uplink_spawn_loc_list_save, list(
	UPLINK_PDA,
	UPLINK_RADIO,
	UPLINK_PEN
))

	//Female Uniforms
GLOBAL_LIST_EMPTY(female_clothing_icons)

GLOBAL_LIST_INIT(scarySounds, list(
	'sound/effects/clownstep1.ogg',
	'sound/effects/clownstep2.ogg',
	'sound/effects/glassbr1.ogg',
	'sound/effects/glassbr2.ogg',
	'sound/effects/glassbr3.ogg',
	'sound/items/welder.ogg',
	'sound/items/welder2.ogg',
	'sound/machines/airlock.ogg',
	'sound/voice/hiss1.ogg',
	'sound/voice/hiss2.ogg',
	'sound/voice/hiss3.ogg',
	'sound/voice/hiss4.ogg',
	'sound/voice/hiss5.ogg',
	'sound/voice/hiss6.ogg',
	'sound/weapons/armbomb.ogg',
	'sound/weapons/taser.ogg',
	'sound/weapons/thudswoosh.ogg',
))

GLOBAL_LIST_INIT(station_prefixes, world.file2list("strings/station_prefixes.txt") + "")

GLOBAL_LIST_INIT(station_names, world.file2list("strings/station_names.txt") + "")

GLOBAL_LIST_INIT(station_suffixes, world.file2list("strings/station_suffixes.txt"))

GLOBAL_LIST_INIT(greek_letters, world.file2list("strings/greek_letters.txt"))

GLOBAL_LIST_INIT(phonetic_alphabet, world.file2list("strings/phonetic_alphabet.txt"))

GLOBAL_LIST_INIT(numbers_as_words, world.file2list("strings/numbers_as_words.txt"))

GLOBAL_LIST_INIT(wisdoms, world.file2list("strings/wisdoms.txt"))

/proc/generate_number_strings()
	var/list/L[198]
	for(var/i in 1 to 99)
		L[i] = "[i]"
		L[i+99] = "\Roman[i]"
	return L

GLOBAL_LIST_INIT(station_numerals, greek_letters + phonetic_alphabet + numbers_as_words + generate_number_strings())

GLOBAL_LIST_INIT(admiral_messages, list(
	"<i>Error: No comment given.</i>",
	"<i>null</i>",
	"Do you know how expensive these stations are?",
	"I was sleeping, thanks a lot.",
	"It's a good day to die!",
	"No.",
	"Stand and fight you cowards!",
	"Stop being paranoid.",
	"Stop wasting my time.",
	"Whatever's broken just build a new one.",
	"You knew the risks coming in.",
))

// All valid inputs to status display post_status
GLOBAL_LIST_INIT(status_display_approved_pictures, list(
	"blank",
	"shuttle",
	"default",
	"biohazard",
	"lockdown",
	"greenalert",
	"bluealert",
	"redalert",
	"deltaalert",
	"radiation",
	"currentalert",
))

// Members of status_display_approved_pictures that are actually states and not alert values
GLOBAL_LIST_INIT(status_display_state_pictures, list(
	"blank",
	"shuttle",
))

GLOBAL_LIST_INIT(pAI_faces_list, list(
	"Angry" = "angry",
	"Cat" = "cat",
	"Extremely Happy" = "extremely-happy",
	"Face" = "face",
	"Happy" = "happy",
	"Laugh" = "laugh",
	"Off" = "off",
	"Sad" = "sad",
	"Sunglasses" = "sunglasses",
	"What" = "what",
))

GLOBAL_LIST_INIT(pAI_faces_icons, list(
	"Angry" = image(icon = 'icons/obj/aicards.dmi', icon_state = "pai-angry"),
	"Cat" = image(icon = 'icons/obj/aicards.dmi', icon_state = "pai-cat"),
	"Extremely Happy" = image(icon = 'icons/obj/aicards.dmi', icon_state = "pai-happy"),
	"Face" = image(icon = 'icons/obj/aicards.dmi', icon_state = "pai-face"),
	"Happy" = image(icon = 'icons/obj/aicards.dmi', icon_state = "pai-happy"),
	"Laugh" = image(icon = 'icons/obj/aicards.dmi', icon_state = "pai-laugh"),
	"Off" = image(icon = 'icons/obj/aicards.dmi', icon_state = "pai-off"),
	"Sad" = image(icon = 'icons/obj/aicards.dmi', icon_state = "pai-sad"),
	"Sunglasses" = image(icon = 'icons/obj/aicards.dmi', icon_state = "pai-sunglasses"),
	"What" = image(icon = 'icons/obj/aicards.dmi', icon_state = "pai-what"),
))

GLOBAL_LIST_INIT(accents, list(
	"British" = BRITISH_TALK_FILE,
	"Canadian" = CANADIAN_TALK_FILE,
	"French" = FRENCH_TALK_FILE,
	"Swedish" = SWEDISH_TALK_FILE,
	"Italian" = ITALIAN_TALK_FILE,
	"Scottish" = SCOTTISH_TALK_FILE,
	"Medieval" = MEDIEVAL_SPEECH_FILE,
	"Roadman" = ROADMAN_TALK_FILE,
))

GLOBAL_LIST_INIT(smoker_cigarettes, list(
	/obj/item/storage/fancy/cigarettes,
	/obj/item/storage/fancy/cigarettes/cigpack_midori,
	/obj/item/storage/fancy/cigarettes/cigpack_uplift,
	/obj/item/storage/fancy/cigarettes/cigpack_robust,
	/obj/item/storage/fancy/cigarettes/cigpack_robustgold,
	/obj/item/storage/fancy/cigarettes/cigpack_carp,
	/obj/item/storage/fancy/cigarettes/dromedaryco,
	/obj/item/storage/fancy/cigarettes/cigars,
	/obj/item/storage/fancy/cigarettes/cigars/cohiba,
	/obj/item/storage/fancy/cigarettes/cigars/havana,
	/obj/item/clothing/mask/vape
))

GLOBAL_LIST_INIT(alcoholic_bottles, list(
	/obj/item/reagent_containers/cup/glass/bottle/ale,
	/obj/item/reagent_containers/cup/glass/bottle/beer,
	/obj/item/reagent_containers/cup/glass/bottle/gin,
	/obj/item/reagent_containers/cup/glass/bottle/whiskey,
	/obj/item/reagent_containers/cup/glass/bottle/vodka,
	/obj/item/reagent_containers/cup/glass/bottle/rum,
	/obj/item/reagent_containers/cup/glass/bottle/applejack
))

GLOBAL_LIST_INIT(junkie_drugs, list(
	/datum/reagent/drug/crank,
	/datum/reagent/drug/krokodil,
	/datum/reagent/medicine/morphine,
	/datum/reagent/drug/happiness,
	/datum/reagent/drug/methamphetamine,
	/datum/reagent/drug/ketamine
))

/// Naturally occuring hair colours
GLOBAL_LIST_INIT(natural_hair_colours, list(
	"#f0e2ba",
	"#f4eede",
	"#c3a87c",
	"#ecd19d",
	"#feedb8",
	"#A0785F",
	"#996F53",
	"#60463D",
	"#9E7046",
	"#9B7257",
	"#523F38",
	"#50362F",
	"#A55A3B",
	"#4D3B2C",
	"#312016",
	"#432C20",
	"#2C1C11",
	"#2E3239",
	"#693822",
	"#663423"
))

/// Hair colours that aren't naturaly but relatively normal (I'll save the anime hair colours for custom characters)
GLOBAL_LIST_INIT(female_dyed_hair_colours, list(
	"#733338",
	"#593333",
	"#401B24",
	"#492D38",
	"#3E262D",
))

GLOBAL_LIST_INIT(secondary_dye_hair_colours, list(
	"#f0e2ba",
	"#f4eede",
	"#c3a87c",
	"#ecd19d",
	"#feedb8",
))

GLOBAL_LIST_INIT(secondary_dye_female_hair_colours, list(
	"#f0e2ba",
	"#f4eede",
	"#c3a87c",
	"#ecd19d",
	"#feedb8",
	"#733338",
	"#593333",
	"#401B24",
	"#492D38",
	"#3E262D",
))
