///Global list of stickers by series
GLOBAL_LIST(stickers_by_series)

///Fill globals
/proc/fill_sticker_globals()
	if(length(GLOB.stickers_by_series))
		return
	/*
		Build sticker GLOB.stickers_by_series
		just index each series flag with a list of associated sticker objects
	*/
	var/list/temp = list()
	var/series = STICKER_SERIES_1 //Make sure you update this if you add more series
	for(var/obj/item/sticker/S as() in subtypesof(/obj/item/sticker))
		var/index = (series & initial(S.sticker_flags))
		if(!index || (ABSTRACT & initial(S.item_flags)))
			continue
		if(!temp["[index]"])
			temp["[index]"] = list()
		temp["[index]"] += S
	GLOB.stickers_by_series = temp
