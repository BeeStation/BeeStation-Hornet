/mob/living/carbon/monkey/punpun //except for a few special persistence features, pun pun is just a normal monkey
	name = "Pun Pun" //C A N O N
	unique_name = 0
	var/ancestor_name
	var/ancestor_chain = 1
	var/relic_hat	//Note: relic_hat and relic_mask are paths
	var/relic_hat_blacklist
	var/relic_mask
	var/relic_mask_blacklist
	var/memory_saved = FALSE

/mob/living/carbon/monkey/punpun/Initialize(mapload)
	// Init our blacklists.
	relic_hat_blacklist = typecacheof(list(
		/obj/item/clothing/head/chameleon,
		/obj/item/clothing/head/helmet/monkey_sentience_helmet,
	), only_root_path = TRUE)

	relic_mask_blacklist = typecacheof(list(
		/obj/item/clothing/mask/facehugger,
		/obj/item/clothing/mask/chameleon,
	), only_root_path = TRUE)

	// Read memory
	Read_Memory()
	if(ancestor_name)
		name = ancestor_name
		if(ancestor_chain > 1)
			name += " \Roman[ancestor_chain]"
	else if(prob(10))
		name = pick(list("Professor Bobo", "Deempisi's Revenge", "Furious George", "King Louie", "Dr. Zaius", "Jimmy Rustles", "Dinner", "Lanky"))
		if(name == "Furious George")
			ai_controller = /datum/ai_controller/monkey/angry //hes always mad
	. = ..()

	//These have to be after the parent new to ensure that the monkey
	//bodyparts are actually created before we try to equip things to
	//those slots
	if(relic_hat && !is_type_in_typecache(relic_hat, relic_hat_blacklist))
		equip_to_slot_or_del(new relic_hat, ITEM_SLOT_HEAD)
	if(relic_mask && !is_type_in_typecache(relic_mask, relic_mask_blacklist))
		equip_to_slot_or_del(new relic_mask, ITEM_SLOT_MASK)

/mob/living/carbon/monkey/punpun/Life(delta_time = SSMOBS_DT, times_fired)
	if(!stat && SSticker.current_state == GAME_STATE_FINISHED && !memory_saved)
		Write_Memory(FALSE, FALSE)
		memory_saved = TRUE
	..()

/mob/living/carbon/monkey/punpun/death(gibbed)
	if(!memory_saved)
		Write_Memory(TRUE, gibbed)
	..()

/mob/living/carbon/monkey/punpun/proc/Read_Memory()
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

/mob/living/carbon/monkey/punpun/proc/Write_Memory(dead, gibbed)
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
