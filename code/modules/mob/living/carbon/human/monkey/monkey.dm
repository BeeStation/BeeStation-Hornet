/mob/living/carbon/human/species/monkey
	race = /datum/species/monkey
	ai_controller = /datum/ai_controller/monkey
	faction = list("neutral", "monkey")

/mob/living/carbon/human/species/monkey/Initialize(mapload, cubespawned=FALSE, mob/spawner)
	if (cubespawned)
		var/cap = CONFIG_GET(number/max_cube_monkeys)
		if (LAZYLEN(SSmobs.cubemonkeys) > cap)
			if (spawner)
				to_chat(spawner, "<span class='warning'>Bluespace harmonics prevent the spawning of more than [cap] monkeys on the station at one time!</span>")
			return INITIALIZE_HINT_QDEL
		SSmobs.cubemonkeys += src
	return ..()

/mob/living/carbon/human/species/monkey/Destroy()
	SSmobs.cubemonkeys -= src
	return ..()

/mob/living/carbon/human/species/monkey/angry
	ai_controller = /datum/ai_controller/monkey/angry

/mob/living/carbon/human/species/monkey/angry/Initialize()
	. = ..()
	if(prob(10))
		var/obj/item/clothing/head/helmet/justice/escape/helmet = new(src)
		equip_to_slot_or_del(helmet,ITEM_SLOT_HEAD)
		helmet.attack_self(src) // todo encapsulate toggle


/mob/living/carbon/human/species/monkey/punpun //except for a few special persistence features, pun pun is just a normal monkey
	name = "Pun Pun" //C A N O N
	unique_name = FALSE
	use_random_name = FALSE
	var/ancestor_name
	var/ancestor_chain = 1
	var/relic_hat	//Note: relic_hat and relic_mask are paths
	var/relic_hat_blacklist
	var/relic_mask
	var/relic_mask_blacklist
	var/memory_saved = FALSE

/mob/living/carbon/human/species/monkey/punpun/Initialize(mapload)
	// Init our blacklists.
	relic_hat_blacklist = typecacheof(list(/obj/item/clothing/head/chameleon,/obj/item/clothing/head/monkey_sentience_helmet), only_root_path = TRUE)
	relic_mask_blacklist = typecacheof(list(/obj/item/clothing/mask/facehugger, /obj/item/clothing/mask/chameleon), only_root_path = TRUE)

	// Read memory
	Read_Memory()

	var/name_to_use = name

	if(ancestor_name)
		name_to_use = ancestor_name
		if(ancestor_chain > 1)
			name_to_use += " \Roman[ancestor_chain]"
	else if(prob(10))
		name_to_use = pick(list("Professor Bobo", "Deempisi's Revenge", "Furious George", "King Louie", "Dr. Zaius", "Jimmy Rustles", "Dinner", "Lanky"))
		if(name_to_use == "Furious George")
			ai_controller = /datum/ai_controller/monkey/angry //hes always mad
	. = ..()

	fully_replace_character_name(real_name, name_to_use)

	//These have to be after the parent new to ensure that the monkey
	//bodyparts are actually created before we try to equip things to
	//those slots
	if(relic_hat && !is_type_in_typecache(relic_hat, relic_hat_blacklist))
		equip_to_slot_or_del(new relic_hat, ITEM_SLOT_HEAD)
	if(relic_mask && !is_type_in_typecache(relic_mask, relic_mask_blacklist))
		equip_to_slot_or_del(new relic_mask, ITEM_SLOT_MASK)

/mob/living/carbon/human/species/monkey/punpun/Life()
	if(!stat && SSticker.current_state == GAME_STATE_FINISHED && !memory_saved)
		Write_Memory(FALSE, FALSE)
		memory_saved = TRUE
	..()

/mob/living/carbon/human/species/monkey/punpun/death(gibbed)
	if(!memory_saved)
		Write_Memory(TRUE, gibbed)
	..()

/mob/living/carbon/human/species/monkey/punpun/proc/Read_Memory()
	if(fexists("data/npc_saves/Punpun.sav")) //legacy compatability to convert old format to new
		var/savefile/S = new /savefile("data/npc_saves/Punpun.sav")
		S["ancestor_name"]	>> ancestor_name
		S["ancestor_chain"] >> ancestor_chain
		S["relic_hat"]		>> relic_hat
		S["relic_mask"]		>> relic_mask
		fdel("data/npc_saves/Punpun.sav")
		relic_hat = text2path(relic_hat) // Convert from a string to a path
		relic_mask = text2path(relic_mask)
	else
		var/json_file = file("data/npc_saves/Punpun.json")
		if(!fexists(json_file))
			return
		var/list/json = json_decode(rustg_file_read(json_file))
		ancestor_name = json["ancestor_name"]
		ancestor_chain = json["ancestor_chain"]
		relic_hat = text2path(json["relic_hat"]) // We convert these to paths for type checking
		relic_mask = text2path(json["relic_mask"])

/mob/living/carbon/human/species/monkey/punpun/proc/Write_Memory(dead, gibbed)
	var/json_file = file("data/npc_saves/Punpun.json")
	var/list/file_data = list()
	if(gibbed)
		file_data["ancestor_name"] = null
		file_data["ancestor_chain"] = null
		file_data["relic_hat"] = null
		file_data["relic_mask"] = null
	else
		file_data["ancestor_name"] = ancestor_name ? ancestor_name : name
		file_data["ancestor_chain"] = dead ? ancestor_chain + 1 : ancestor_chain
		file_data["relic_hat"] = head ? head.type : null
		file_data["relic_mask"] = wear_mask ? wear_mask.type : null
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))

/datum/species/monkey/get_scream_sound(mob/living/carbon/user)
	return pick(
		'sound/creatures/monkey/monkey_screech_1.ogg',
		'sound/creatures/monkey/monkey_screech_2.ogg',
		'sound/creatures/monkey/monkey_screech_3.ogg',
		'sound/creatures/monkey/monkey_screech_4.ogg',
		'sound/creatures/monkey/monkey_screech_5.ogg',
		'sound/creatures/monkey/monkey_screech_6.ogg',
		'sound/creatures/monkey/monkey_screech_7.ogg',)

//Special monkeycube subtype to track the number of them and prevent spam
/mob/living/carbon/monkey/cube/Initialize(mapload)
	. = ..()
	GLOB.total_cube_monkeys++

/mob/living/carbon/monkey/cube/death(gibbed)
	GLOB.total_cube_monkeys--
	..()

//In case admins delete them before they die
/mob/living/carbon/monkey/cube/Destroy()
	if(stat != DEAD)
		GLOB.total_cube_monkeys--
	return ..()

/mob/living/carbon/human/species/monkey/tumor
	name = "living teratoma"
	verb_say = "blabbers"
	initial_language_holder = /datum/language_holder/monkey
	icon = 'icons/mob/monkey.dmi'
	icon_state = null
	butcher_results = list(/obj/effect/spawner/lootdrop/teratoma/minor = 5, /obj/effect/spawner/lootdrop/teratoma/major = 1)
	type_of_meat = /obj/effect/spawner/lootdrop/teratoma/minor
	bodyparts = list(/obj/item/bodypart/chest/monkey/teratoma, /obj/item/bodypart/head/monkey/teratoma, /obj/item/bodypart/l_arm/monkey/teratoma,
					/obj/item/bodypart/r_arm/monkey/teratoma, /obj/item/bodypart/r_leg/monkey/teratoma, /obj/item/bodypart/l_leg/monkey/teratoma)
	ai_controller = null

/datum/dna/tumor
	species = new /datum/species/teratoma

/datum/species/teratoma
	name = "Teratoma"
	id = "teratoma"
	species_traits = list(NOTRANSSTING, NO_DNA_COPY, EYECOLOR, HAIR, FACEHAIR, LIPS)
	inherent_traits = list(TRAIT_NOHUNGER, TRAIT_RADIMMUNE, TRAIT_BADDNA, TRAIT_NOGUNS, TRAIT_NONECRODISEASE)	//Made of mutated cells
	default_features = list("mcolor" = "FFF", "wings" = "None")
	use_skintones = FALSE
	skinned_type = /obj/item/stack/sheet/animalhide/monkey
	changesource_flags = MIRROR_BADMIN
	mutant_brain = /obj/item/organ/brain/tumor
	mutanttongue = /obj/item/organ/tongue/teratoma

	species_chest = /obj/item/bodypart/chest/monkey/teratoma
	species_head = /obj/item/bodypart/head/monkey/teratoma
	species_l_arm = /obj/item/bodypart/l_arm/monkey/teratoma
	species_r_arm = /obj/item/bodypart/r_arm/monkey/teratoma
	species_l_leg = /obj/item/bodypart/l_leg/monkey/teratoma
	species_r_leg = /obj/item/bodypart/r_leg/monkey/teratoma

/obj/item/organ/brain/tumor
	name = "teratoma brain"

/obj/item/organ/brain/tumor/Remove(mob/living/carbon/C, special, no_id_transfer, pref_load = FALSE)
	. = ..()
	//Removing it deletes it
	if(!QDELETED(src))
		qdel(src)

/mob/living/carbon/human/species/monkey/tumor/handle_mutations_and_radiation()
	return

/mob/living/carbon/human/species/monkey/tumor/has_dna()
	return FALSE

/mob/living/carbon/human/species/monkey/tumor/create_dna()
	dna = new /datum/dna/tumor(src)
	//Give us the juicy mutant organs
	dna.species.on_species_gain(src, null, FALSE)
	dna.species.regenerate_organs(src, replace_current = TRUE)
