/*
	Series 2
*/

/obj/item/sticker/series_2
	do_outline = FALSE

/obj/item/sticker/series_2/get_stats()
	. = "<span class='notice'>Series 2</span>\n"
	. += ..()

/obj/item/sticker/series_2/generate_unusual()
	var/obj/emitter/emitter = pick(list(/obj/emitter/flies, /obj/emitter/sparkle, /obj/emitter/rain))
	if(prob(1))
		playsound(src, 'sound/effects/audience-ooh.ogg', 50)
		add_emitter(emitter, "unusual", 10)
		is_unusual = TRUE

/obj/item/sticker/series_2/flower
	icon_state = "flower_1"
	sticker_icon_state = "flower_1_sticker"
	sticker_flags = STICKER_SERIES_2 | STICKER_RARITY_COMMON

/obj/item/sticker/series_2/banana
	icon_state = "banana"
	sticker_icon_state = "banana_sticker"
	sticker_flags = STICKER_SERIES_2 | STICKER_RARITY_COMMON

/obj/item/sticker/series_2/tomato
	icon_state = "tomato"
	sticker_icon_state = "tomato_sticker"
	sticker_flags = STICKER_SERIES_2 | STICKER_RARITY_COMMON
