/* Null hide */

/obj/item/stack/sheet/animalhide
	name = "hide"
	desc = "Something went wrong."
	icon_state = "sheet-hide"
	inhand_icon_state = "sheet-hide"
	icon = 'icons/obj/stacks/organic.dmi'
	novariants = TRUE
	merge_type = /obj/item/stack/sheet/animalhide

/* Generic hide */

/obj/item/stack/sheet/animalhide/generic
	name = "skin"
	desc = "A piece of skin."
	singular_name = "skin piece"
	novariants = FALSE
	merge_type = /obj/item/stack/sheet/animalhide/generic

/* Human hide */

/obj/item/stack/sheet/animalhide/human
	name = "human skin"
	desc = "The by-product of human farming."
	singular_name = "human skin piece"
	novariants = FALSE
	trade_flags = TRADE_CONTRABAND
	merge_type = /obj/item/stack/sheet/animalhide/human

/obj/item/stack/sheet/animalhide/human/get_recipes()
	return GLOB.human_recipes

/* Corgi hide */

/obj/item/stack/sheet/animalhide/corgi
	name = "corgi hide"
	desc = "The by-product of corgi farming."
	singular_name = "corgi hide piece"
	icon_state = "sheet-corgi"
	inhand_icon_state = "sheet-corgi"
	trade_flags = TRADE_CONTRABAND
	merge_type = /obj/item/stack/sheet/animalhide/corgi

/obj/item/stack/sheet/animalhide/corgi/get_recipes()
	return GLOB.corgi_recipes

/* Mothroach hide */

/obj/item/stack/sheet/animalhide/mothroach
	name = "mothroach hide"
	desc = "A thin layer of mothroach hide."
	singular_name = "mothroach hide piece"
	icon_state = "sheet-mothroach"
	inhand_icon_state = "sheet-mothroach"
	merge_type = /obj/item/stack/sheet/animalhide/mothroach

/* Gondola hide */

/obj/item/stack/sheet/animalhide/gondola
	name = "gondola hide"
	desc = "The extremely valuable product of gondola hunting."
	singular_name = "gondola hide piece"
	icon_state = "sheet-gondola"
	inhand_icon_state = "sheet-gondola"
	merge_type = /obj/item/stack/sheet/animalhide/gondola

/obj/item/stack/sheet/animalhide/gondola/get_recipes()
	return GLOB.gondola_recipes

/* Cot hide */

/obj/item/stack/sheet/animalhide/cat
	name = "cat hide"
	desc = "The by-product of cat farming."
	singular_name = "cat hide piece"
	icon_state = "sheet-cat"
	inhand_icon_state = "sheet-cat"
	trade_flags = TRADE_CONTRABAND
	merge_type = /obj/item/stack/sheet/animalhide/cat

/* Monkey hide */

/obj/item/stack/sheet/animalhide/monkey
	name = "monkey hide"
	desc = "The by-product of monkey farming."
	singular_name = "monkey hide piece"
	icon_state = "sheet-monkey"
	icon_state = "sheet-monkey"
	merge_type = /obj/item/stack/sheet/animalhide/monkey

/obj/item/stack/sheet/animalhide/monkey/get_recipes()
	return GLOB.monkey_recipes

/* Lizard hide */

/obj/item/stack/sheet/animalhide/lizard
	name = "lizard hide"
	desc = "Sssssss..."
	singular_name = "lizard hide"
	icon_state = "sheet-lizard"
	inhand_icon_state = "sheet-lizard"
	merge_type = /obj/item/stack/sheet/animalhide/lizard

/* Xeno hide */

/obj/item/stack/sheet/animalhide/xeno
	name = "alien hide"
	desc = "The skin of a terrible creature."
	singular_name = "alien hide piece"
	icon_state = "sheet-xeno"
	inhand_icon_state = "sheet-xeno"

/obj/item/stack/sheet/animalhide/xeno/get_recipes()
	return GLOB.xeno_recipes

/* Ashdrake hide */

/obj/item/stack/sheet/animalhide/ashdrake
	name = "ash drake hide"
	desc = "The strong, scaled hide of an ash drake."
	icon_state = "dragon_hide"
	singular_name = "drake plate"
	max_amount = 10
	novariants = FALSE
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_NORMAL
	layer = MOB_LAYER
	merge_type = /obj/item/stack/sheet/animalhide/ashdrake

/* Goliath Plates */
/obj/item/stack/sheet/animalhide/goliath_hide
	name = "goliath hide plates"
	desc = "Pieces of a goliath's rocky hide, these might be able to make your suit a bit more durable to attack from the local fauna."
	icon_state = "goliath_hide"
	singular_name = "hide plate"
	max_amount = 6
	novariants = FALSE
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_NORMAL
	layer = MOB_LAYER
	merge_type = /obj/item/stack/sheet/animalhide/goliath_hide

/* Generic functions for hides, fun for all the family! */

//Step one to make leather - dehairing

/obj/item/stack/sheet/animalhide/attackby(obj/item/W, mob/user, params)
	if(W.is_sharp())
		playsound(loc, 'sound/weapons/slice.ogg', 50, 1, -1)
		user.visible_message("[user] starts cutting hair off \the [src].", span_notice("You start cutting the hair off \the [src]..."), span_italics("You hear the sound of a knife rubbing against flesh."))
		if(do_after(user, 50, target = src))
			to_chat(user, span_notice("You cut the hair from this [src.singular_name]."))
			new /obj/item/stack/sheet/leather/hairlesshide(user.drop_location(), 1)
			use(1)
	else
		return ..()

//Step two in leather.dm
