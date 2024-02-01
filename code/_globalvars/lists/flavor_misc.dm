//Preferences stuff
	//Hairstyles
GLOBAL_LIST_EMPTY(hair_styles_list)			//stores /datum/sprite_accessory/hair indexed by name
GLOBAL_LIST_EMPTY(hair_styles_male_list)		//stores only hair names
GLOBAL_LIST_EMPTY(hair_styles_female_list)	//stores only hair names
GLOBAL_LIST_EMPTY(hair_gradients_list) //stores /datum/sprite_accessory/hair_gradient indexed by name
GLOBAL_LIST_EMPTY(facial_hair_styles_list)	//stores /datum/sprite_accessory/facial_hair indexed by name
GLOBAL_LIST_EMPTY(facial_hair_styles_male_list)	//stores only hair names
GLOBAL_LIST_EMPTY(facial_hair_styles_female_list)	//stores only hair names
	//Underwear
GLOBAL_LIST_EMPTY(underwear_list)		//stores /datum/sprite_accessory/underwear indexed by name
GLOBAL_LIST_EMPTY(underwear_m)	//stores only underwear name
GLOBAL_LIST_EMPTY(underwear_f)	//stores only underwear name
	//Undershirts
GLOBAL_LIST_EMPTY(undershirt_list) 	//stores /datum/sprite_accessory/undershirt indexed by name
GLOBAL_LIST_EMPTY(undershirt_m)	 //stores only undershirt name
GLOBAL_LIST_EMPTY(undershirt_f)	 //stores only undershirt name
	//Socks
GLOBAL_LIST_EMPTY(socks_list)		//stores /datum/sprite_accessory/socks indexed by name
/// Body sizes. The names (keys) are what is actually stored in the database. Don't get crazy with changing them.
GLOBAL_LIST_INIT(body_sizes, list(
	"Normal" = BODY_SIZE_NORMAL,
	"Short" = BODY_SIZE_SHORT,
	"Tall" = BODY_SIZE_TALL
))
	//Lizard Bits (all datum lists indexed by name)
GLOBAL_LIST_EMPTY(body_markings_list)
GLOBAL_LIST_EMPTY(tails_list_lizard)
GLOBAL_LIST_EMPTY(animated_tails_list_lizard)
GLOBAL_LIST_EMPTY(snouts_list)
GLOBAL_LIST_EMPTY(horns_list)
GLOBAL_LIST_EMPTY(frills_list)
GLOBAL_LIST_EMPTY(spines_list)
GLOBAL_LIST_EMPTY(legs_list)
GLOBAL_LIST_EMPTY(animated_spines_list)

	//Mutant Human bits
GLOBAL_LIST_EMPTY(tails_list_human)
GLOBAL_LIST_EMPTY(animated_tails_list_human)
GLOBAL_LIST_EMPTY(tails_roundstart_list_human)
GLOBAL_LIST_EMPTY(ears_list)
GLOBAL_LIST_EMPTY(wings_list)
GLOBAL_LIST_EMPTY(wings_open_list)
GLOBAL_LIST_EMPTY(moth_wings_list)
GLOBAL_LIST_EMPTY(moth_wings_roundstart_list)//this lacks the blacklisted wings such as burned, clockwork and angel
GLOBAL_LIST_EMPTY(moth_antennae_list)
GLOBAL_LIST_EMPTY(moth_antennae_roundstart_list)//this lacks the blacklisted antennae such as burned, clockwork and angel
GLOBAL_LIST_EMPTY(moth_markings_list)
GLOBAL_LIST_EMPTY(moth_markings_roundstart_list)//this lacks the blacklisted markings such as burned, clockwork and angel
GLOBAL_LIST_EMPTY(moth_wingsopen_list)
GLOBAL_LIST_EMPTY(caps_list)
GLOBAL_LIST_EMPTY(ipc_screens_list)
GLOBAL_LIST_EMPTY(ipc_antennas_list)
GLOBAL_LIST_EMPTY(ipc_chassis_list)
GLOBAL_LIST_EMPTY(insect_type_list)
GLOBAL_LIST_EMPTY(apid_antenna_list)
GLOBAL_LIST_EMPTY(apid_stripes_list)
GLOBAL_LIST_EMPTY(apid_headstripes_list)
GLOBAL_LIST_EMPTY(psyphoza_cap_list)

GLOBAL_LIST_INIT(color_list_ethereal, list(
	"Cyan" = "00ffff",
	"Dark Green" = "0ab432",
	"Dark Teal" = "5ea699",
	"Denim Blue" = "3399ff",
	"Gray" = "979497",
	"Green" = "97ee63",
	"Lavender" = "d1acff",
	"Maroon" = "9c3030",
	"Orange" = "f69c28",
	"Orchid Purple" = "ee82ee",
	"Powder Blue" = "95e5ff",
	"Purple" = "a42df7",
	"Red" = "ff3131",
	"Rose" = "ff92b6",
	"Royal Blue" = "5860f5",
	"Sandy Yellow" = "ffefa5",
	"Sea Green" = "37835b",
	"Spring Green" = "00fa9a",
	"Yellow" = "fbdf56",
))

GLOBAL_LIST_INIT(ghost_forms_with_directions_list, list("ghost")) //stores the ghost forms that support directional sprites
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
	"ghost_camo",))
	//stores the ghost forms that support hair and other such things

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
		return "ai-[lowertext(input)]"

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
	UPLINK_IMPLANT_WITH_PRICE,
	UPLINK_PDA,
	UPLINK_PEN,
	UPLINK_RADIO,
))
// What is actually saved; if the uplink implant price changes, it won't affect save files then
GLOBAL_LIST_INIT(uplink_spawn_loc_list_save, list(
	UPLINK_IMPLANT,
	UPLINK_PDA,
	UPLINK_PEN,
	UPLINK_RADIO,
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


// Reference list for disposal sort junctions. Set the sortType variable on disposal sort junctions to
// the index of the sort department that you want. For example, sortType set to 2 will reroute all packages
// tagged for the Cargo Bay.

/* List of sortType codes for mapping reference
0 Waste
1 Disposals - All unwrapped items and untagged parcels get picked up by a junction with this sortType. Usually leads to the recycler.
2 Cargo Bay
3 QM Office
4 Engineering
5 CE Office
6 Atmospherics
7 Security
8 HoS Office
9 Medbay
10 CMO Office
11 Chemistry
12 Research
13 RD Office
14 Robotics
15 HoP Office
16 Library
17 Chapel
18 Theatre
19 Bar
20 Kitchen
21 Hydroponics
22 Janitor
23 Genetics
24 Testing Range
25 Toxins
26 Dormitories
27 Virology
28 Xenobiology
29 Law Office
30 Detective's Office
*/

//The whole system for the sorttype var is determined based on the order of this list,
//disposals must always be 1, since anything that's untagged will automatically go to disposals, or sorttype = 1 --Superxpdude

//If you don't want to fuck up disposals, add to this list, and don't change the order.
//If you insist on changing the order, you'll have to change every sort junction to reflect the new order. --Pete

GLOBAL_LIST_INIT(TAGGERLOCATIONS, list(
	"Disposals",
	"Cargo Bay",
	"QM Office",
	"Engineering",
	"CE Office",
	"Atmospherics",
	"Security",
	"HoS Office",
	"Medbay",
	"CMO Office",
	"Chemistry",
	"Research",
	"RD Office",
	"Robotics",
	"HoP Office",
	"Library",
	"Chapel",
	"Theatre",
	"Bar",
	"Kitchen",
	"Hydroponics",
	"Janitor Closet",
	"Genetics",
	"Testing Range",
	"Toxins",
	"Dormitories",
	"Virology",
	"Xenobiology",
	"Law Office",
	"Detective's Office",
))

GLOBAL_LIST_INIT(station_prefixes, world.file2list("strings/station_prefixes.txt") + "")

GLOBAL_LIST_INIT(station_names, world.file2list("strings/station_names.txt") + "")

GLOBAL_LIST_INIT(station_suffixes, world.file2list("strings/station_suffixes.txt"))

GLOBAL_LIST_INIT(greek_letters, world.file2list("strings/greek_letters.txt"))

GLOBAL_LIST_INIT(phonetic_alphabet, world.file2list("strings/phonetic_alphabet.txt"))

GLOBAL_LIST_INIT(numbers_as_words, world.file2list("strings/numbers_as_words.txt"))

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

GLOBAL_LIST_INIT(junkmail_messages, world.file2list("strings/junkmail.txt"))

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

GLOBAL_LIST_INIT(smoker_cigarettes, list(
	/obj/item/storage/fancy/cigarettes,
	/obj/item/storage/fancy/cigarettes/cigpack_midori,
	/obj/item/storage/fancy/cigarettes/cigpack_uplift,
	/obj/item/storage/fancy/cigarettes/cigpack_robust,
	/obj/item/storage/fancy/cigarettes/cigpack_robustgold,
	/obj/item/storage/fancy/cigarettes/cigpack_carp
))

GLOBAL_LIST_INIT(alcoholic_bottles, list(
	/obj/item/reagent_containers/food/drinks/bottle/ale,
	/obj/item/reagent_containers/food/drinks/bottle/beer,
	/obj/item/reagent_containers/food/drinks/bottle/gin,
	/obj/item/reagent_containers/food/drinks/bottle/whiskey,
	/obj/item/reagent_containers/food/drinks/bottle/vodka,
	/obj/item/reagent_containers/food/drinks/bottle/rum,
	/obj/item/reagent_containers/food/drinks/bottle/applejack
))

GLOBAL_LIST_INIT(junkie_drugs, list(
	/datum/reagent/drug/crank,
	/datum/reagent/drug/krokodil,
	/datum/reagent/medicine/morphine,
	/datum/reagent/drug/happiness,
	/datum/reagent/drug/methamphetamine,
	/datum/reagent/drug/ketamine
))
