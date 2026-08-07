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
	for(var/obj/item/sticker/sticker as anything in subtypesof(/obj/item/sticker))
		var/index = (series & initial(sticker.sticker_flags))
		if(!index || (ABSTRACT & initial(sticker.item_flags)))
			continue
		var/string_index = "[index]"
		if(!temp[string_index])
			temp[string_index] = list()
		temp[string_index] += sticker
	GLOB.stickers_by_series = temp
