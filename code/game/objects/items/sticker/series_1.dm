/*
	Series 1
*/

/obj/item/sticker/series_1/get_stats()
	. = "<span class='notice'>Series 1</span>\n"
	. += ..()

/obj/item/sticker/series_1/generate_unusual()
	var/obj/emitter/emitter = pick(list(/obj/emitter/electrified, /obj/emitter/snow, /obj/emitter/fire))
	if(prob(1))
		playsound(src, 'sound/effects/audience-gasp.ogg', 50)
		add_emitter(emitter, "unusual", 10)
		is_unusual = TRUE

/obj/item/sticker/series_1/smile
	sticker_flags = STICKER_SERIES_1 | STICKER_RARITY_COMMON

/obj/item/sticker/series_1/skub
	icon_state = "skub"
	sticker_icon_state = "skub_sticker"
	sticker_flags = STICKER_SERIES_1 | STICKER_RARITY_MYTHIC
	//Don't chance the drop weight for this, the joke is it's common

/obj/item/sticker/series_1/c4
	icon_state = "c4"
	sticker_icon_state = "c4_sticker"
	do_outline = FALSE
	sticker_flags = STICKER_SERIES_1 | STICKER_RARITY_EXOTIC
	drop_rate = STICKER_WEIGHT_EXOTIC

/obj/item/sticker/series_1/emagged
	icon_state = "apcemag"
	sticker_icon_state = "apcemag_sticker"
	do_outline = FALSE
	sticker_flags = STICKER_SERIES_1 | STICKER_RARITY_EXOTIC
	drop_rate = STICKER_WEIGHT_EXOTIC

/obj/item/sticker/series_1/sad
	icon_state = "sad"
	sticker_icon_state = "sad_sticker"
	sticker_flags = STICKER_SERIES_1 | STICKER_RARITY_COMMON

/obj/item/sticker/series_1/moth
	icon_state = "moth"
	sticker_icon_state = "moth_sticker"
	sticker_flags = STICKER_SERIES_1 | STICKER_RARITY_UNCOMMON
	drop_rate = STICKER_WEIGHT_UNCOMMON

/obj/item/sticker/series_1/dog
	icon_state = "dog"
	sticker_icon_state = "dog_sticker"
	sticker_flags = STICKER_SERIES_1 | STICKER_RARITY_UNCOMMON
	drop_rate = STICKER_WEIGHT_UNCOMMON

/obj/item/sticker/series_1/cat
	icon_state = "cat"
	sticker_icon_state = "cat_sticker"
	sticker_flags = STICKER_SERIES_1 | STICKER_RARITY_UNCOMMON
	drop_rate = STICKER_WEIGHT_UNCOMMON

/obj/item/sticker/series_1/carp
	icon_state = "carp"
	sticker_icon_state = "carp_sticker"
	sticker_flags = STICKER_SERIES_1 | STICKER_RARITY_UNCOMMON
	drop_rate = STICKER_WEIGHT_UNCOMMON

/obj/item/sticker/series_1/valid
	icon_state = "valid"
	sticker_icon_state = "valid_sticker"
	sticker_flags = STICKER_SERIES_1 | STICKER_RARITY_UNCOMMON
	drop_rate = STICKER_WEIGHT_UNCOMMON

/obj/item/sticker/series_1/salad
	icon_state = "salad"
	sticker_icon_state = "salad_sticker"
	sticker_flags = STICKER_SERIES_1 | STICKER_RARITY_UNCOMMON
	drop_rate = STICKER_WEIGHT_UNCOMMON

/obj/item/sticker/series_1/heart
	icon_state = "heart"
	sticker_icon_state = "heart_sticker"
	sticker_flags = STICKER_SERIES_1 | STICKER_RARITY_COMMON

/obj/item/sticker/series_1/eggplant
	icon_state = "eggplant"
	sticker_icon_state = "eggplant_sticker"
	sticker_flags = STICKER_SERIES_1 | STICKER_RARITY_UNCOMMON
	drop_rate = STICKER_WEIGHT_UNCOMMON

/obj/item/sticker/series_1/nuke_disk
	icon_state = "nucleardisk"
	sticker_icon_state = "nucleardisk_sticker"
	sticker_flags = STICKER_SERIES_1 | STICKER_RARITY_RARE
	drop_rate = STICKER_WEIGHT_RARE


/obj/item/sticker/series_1/generic
	icon_state = "generic"
	sticker_icon_state = "generic_sticker"
	sticker_flags = STICKER_SERIES_1 | STICKER_RARITY_COMMON
	drop_rate = STICKER_WEIGHT_COMMON
	///What random color we rocking with?
	var/random_color
	///Ref to our color overlay
	var/mutable_appearance/color_overlay

/obj/item/sticker/series_1/generic/Initialize(mapload)
	random_color = "#[random_color()]"
	. = ..()
	update_appearance()

/obj/item/sticker/series_1/generic/setup_appearance(_appearance)
	. = ..()
	var/mutable_appearance/base = .
	color_overlay = new()
	color_overlay.appearance = base.appearance
	color_overlay.color = random_color
	base.add_overlay(color_overlay)

/obj/item/sticker/series_1/eye
	icon_state = "eye"
	sticker_icon_state = "eye_sticker"
	sticker_flags = STICKER_SERIES_1 | STICKER_RARITY_UNCOMMON
	drop_rate = STICKER_WEIGHT_UNCOMMON
	do_outline = FALSE
