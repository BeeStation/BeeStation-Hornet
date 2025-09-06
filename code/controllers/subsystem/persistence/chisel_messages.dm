/datum/controller/subsystem/persistence/proc/load_chisel_messages()
	var/list/saved_messages = list()
	if(fexists("data/npc_saves/ChiselMessages.sav")) //legacy compatability to convert old format to new
		var/savefile/chisel_messages_sav = new /savefile("data/npc_saves/ChiselMessages.sav")
		var/saved_json
		chisel_messages_sav[SSmapping.current_map.map_name] >> saved_json
		if(!saved_json)
			return
		saved_messages = json_decode(saved_json)
		fdel("data/npc_saves/ChiselMessages.sav")
	else
		var/json_file = file("data/npc_saves/ChiselMessages[SSmapping.current_map.map_name].json")
		if(!fexists(json_file))
			return
		var/list/json = json_decode(rustg_file_read(json_file))

		if(!json)
			return
		saved_messages = json["data"]

	for(var/item in saved_messages)
		if(!islist(item))
			continue

		var/xvar = item["x"]
		var/yvar = item["y"]
		var/zvar = item["z"]

		if(!xvar || !yvar || !zvar)
			continue

		var/turf/T = locate(xvar, yvar, zvar)
		if(!isturf(T))
			continue

		if(locate(/obj/structure/chisel_message) in T)
			continue

		var/obj/structure/chisel_message/M = new(T)

		if(!QDELETED(M))
			M.unpack(item)

	log_world("Loaded [saved_messages.len] engraved messages on map [SSmapping.current_map.map_name]")

/datum/controller/subsystem/persistence/proc/collect_chisel_messages()
	var/json_file = file("data/npc_saves/ChiselMessages[SSmapping.current_map.map_name].json")

	for(var/obj/structure/chisel_message/M in chisel_messages)
		saved_messages += list(M.pack())

	log_world("Saved [saved_messages.len] engraved messages on map [SSmapping.current_map.map_name]")
	var/list/file_data = list()
	file_data["data"] = saved_messages
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))

/datum/controller/subsystem/persistence/proc/save_chisel_message(obj/structure/chisel_message/M)
	saved_messages += list(M.pack()) // dm eats one list
