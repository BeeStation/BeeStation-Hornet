/**********************
Various Cloths
	Contains:
		- Cloth
		- Durathread cloth
		- Silk
**********************/

/* Cloth */

/obj/item/stack/sheet/cotton
	name = "raw cotton bundle"
	desc = "A bundle of raw cotton ready to be spun on the loom."
	singular_name = "raw cotton ball"
	icon = 'icons/obj/stacks/organic.dmi'
	icon_state = "sheet-cotton"
	resistance_flags = FLAMMABLE
	force = 0
	throwforce = 0
	merge_type = /obj/item/stack/sheet/cotton
	drop_sound = 'sound/items/handling/cloth_drop.ogg'
	pickup_sound =  'sound/items/handling/cloth_pickup.ogg'
	var/pull_effort = 10
	var/loom_result = /obj/item/stack/sheet/cotton/cloth
	/// A lazily initiated "food" version of the cloth for moths
	var/obj/item/food/clothing/moth_snack

/obj/item/stack/sheet/cotton/attack(mob/living/target_mob, mob/living/user, params)
	if(isnull(moth_snack))
		moth_snack = new
		moth_snack.name = name
		moth_snack.clothing = WEAKREF(src)
	moth_snack.attack(target_mob, user, params)

/obj/item/stack/sheet/cotton/Destroy()
	QDEL_NULL(moth_snack)
	return ..()

/obj/item/stack/sheet/cotton/cloth
	name = "cloth"
	desc = "Is it cotton? Linen? Denim? Burlap? Canvas? You can't tell."
	singular_name = "cloth roll"
	icon_state = "sheet-cloth"
	icon = 'icons/obj/stacks/organic.dmi'
	inhand_icon_state = "sheet-cloth"
	resistance_flags = FLAMMABLE
	force = 0
	throwforce = 0
	merge_type = /obj/item/stack/sheet/cotton/cloth
	pull_effort = 50
	loom_result = /obj/item/stack/sheet/silk

/obj/item/stack/sheet/cotton/cloth/get_recipes()
	return GLOB.cloth_recipes

/* Durathread cloth */

/obj/item/stack/sheet/cotton/durathread
	name = "raw durathread bundle"
	desc = "A bundle of raw durathread ready to be spun on the loom."
	singular_name = "raw durathread ball"
	icon_state = "sheet-durathreadraw"
	merge_type = /obj/item/stack/sheet/cotton/durathread
	loom_result = /obj/item/stack/sheet/cotton/cloth/durathread

/obj/item/stack/sheet/cotton/cloth/durathread
	name = "durathread"
	desc = "A fabric sown from incredibly durable threads, known for its usefulness in armor production."
	singular_name = "durathread roll"
	icon_state = "sheet-durathread"
	inhand_icon_state = "sheet-durathread"
	icon = 'icons/obj/stacks/organic.dmi'
	resistance_flags = FLAMMABLE
	force = 0
	throwforce = 0
	merge_type = /obj/item/stack/sheet/cotton/cloth/durathread
	drop_sound = 'sound/items/handling/cloth_drop.ogg'
	pickup_sound =  'sound/items/handling/cloth_pickup.ogg'

/obj/item/stack/sheet/cotton/cloth/durathread/get_recipes()
	return GLOB.durathread_recipes

/* Silk */

/obj/item/stack/sheet/silk
	name = "silk"
	desc = "A long soft material. This one is made from cotton rather than spidersilk."
	singular_name = "Silk Sheet"
	icon_state = "sheet-silk"
	inhand_icon_state = "sheet-silk"
	novariants = TRUE
	merge_type = /obj/item/stack/sheet/silk
	icon = 'icons/obj/stacks/organic.dmi'
	drop_sound = 'sound/items/handling/cloth_drop.ogg'
	pickup_sound =  'sound/items/handling/cloth_pickup.ogg'

/obj/item/stack/sheet/silk/get_recipes()
	return GLOB.silk_recipes
