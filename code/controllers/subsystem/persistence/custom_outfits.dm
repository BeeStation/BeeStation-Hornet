#define FILE_CUSTOM_OUTFITS "data/custom_outfits.json"

/datum/controller/subsystem/persistence/proc/load_custom_outfits()
	var/file = file(FILE_CUSTOM_OUTFITS)
	if(!fexists(file))
		return
	var/outfits_json = file2text(file)
	var/list/outfits = json_decode(outfits_json)
	if(!islist(outfits))
		return

	for(var/outfit_data in outfits)
		if(!islist(outfit_data))
			continue

		var/outfittype = text2path(outfit_data["outfit_type"])
		if(!ispath(outfittype, /datum/outfit))
			continue
		var/datum/outfit/outfit = new outfittype
		if(!outfit.load_from(outfit_data))
			continue
		GLOB.custom_outfits += outfit

/datum/controller/subsystem/persistence/proc/save_custom_outfits()
	var/file = file(FILE_CUSTOM_OUTFITS)
	fdel(file)

	var/list/data = list()
	for(var/datum/outfit/outfit in GLOB.custom_outfits)
		data += list(outfit.get_json_data())

	WRITE_FILE(file, json_encode(data))

#undef FILE_CUSTOM_OUTFITS
