/datum/objective/cascade
	name = "cascade"
	explanation_text = "Cause a supermatter cascade."
	murderbone_flag = TRUE

/datum/objective/cascade/check_completion()
	if(SSticker.news_report == SUPERMATTER_CASCADE)
		return TRUE

	return FALSE

/datum/objective/cascade/New()
	generate_stash(list(/obj/item/storage/box/syndie_kit/cascade))
