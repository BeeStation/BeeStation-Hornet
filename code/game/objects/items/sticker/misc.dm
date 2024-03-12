/*
	Series 1
*/

/obj/item/sticker/series_1/get_stats()
	. = ..()
	. += "<span class='notice'>Series 1</span>"

/obj/item/sticker/series_1/smile
	sticker_flags = STICKER_SERIES_1 | STICKER_RARITY_COMMON

/obj/item/sticker/series_1/skub
	icon_state = "skub"
	sticker_icon_state = "skub_sticker"
	sticker_flags = STICKER_SERIES_1 | STICKER_RARITY_MYTHIC

/obj/item/sticker/series_1/c4
	icon_state = "c4"
	sticker_icon_state = "c4_sticker"
	do_outline = FALSE
	sticker_flags = STICKER_SERIES_1 | STICKER_RARITY_UNCOMMON
	drop_rate = STICKER_WEIGHT_UNCOMMON

/obj/item/sticker/series_1/sad
	icon_state = "sad"
	sticker_icon_state = "sad_sticker"
	sticker_flags = STICKER_SERIES_1 | STICKER_RARITY_COMMON

/obj/item/sticker/series_1/moth
	icon_state = "moth"
	sticker_icon_state = "moth_sticker"
	sticker_flags = STICKER_SERIES_1 | STICKER_RARITY_UNCOMMON
	drop_rate = STICKER_WEIGHT_UNCOMMON

//TODO: Consider tweaking the rarity for these pride ones - Racc
/obj/item/sticker/series_1/gay
	icon_state = "gay"
	sticker_icon_state = "gay_sticker"
	sticker_flags = STICKER_SERIES_1 | STICKER_RARITY_COMMON

/obj/item/sticker/series_1/lesbian
	icon_state = "lesbian"
	sticker_icon_state = "lesbian_sticker"
	sticker_flags = STICKER_SERIES_1 | STICKER_RARITY_COMMON

/obj/item/sticker/series_1/bi
	icon_state = "bi"
	sticker_icon_state = "bi_sticker"
	sticker_flags = STICKER_SERIES_1 | STICKER_RARITY_COMMON

/obj/item/sticker/series_1/trans
	icon_state = "trans"
	sticker_icon_state = "trans_sticker"
	sticker_flags = STICKER_SERIES_1 | STICKER_RARITY_COMMON

//Mime pride?
/obj/item/sticker/series_1/straight
	icon_state = "straight"
	sticker_icon_state = "straight_sticker"
	sticker_flags = STICKER_SERIES_1 | STICKER_RARITY_COMMON
