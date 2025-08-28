/*
Reproductive extracts:
	When fed three monkey cubes, produces between
	1 and 4 normal slime extracts of the same colour.
*/
/obj/item/slimecross/reproductive
	name = "reproductive extract"
	desc = "It pulses with a strange hunger."
	icon_state = "reproductive"
	effect = "reproductive"
	effect_desc = "When fed monkey cubes it produces a baby slime. Bio bag compatible as well."
	layer = LOW_ITEM_LAYER
	var/last_produce = 0
	var/cooldown = 30 SECONDS
	var/feed_amount = 3
	var/static/list/typecache_to_take

/obj/item/slimecross/reproductive/Initialize(mapload)
	. = ..()
	if(!typecache_to_take)
		typecache_to_take = typecacheof(/obj/item/food/monkeycube)
	create_storage(storage_type = /datum/storage/extract_inventory)
	atom_storage.can_hold = typecache_to_take

/obj/item/slimecross/reproductive/examine()
	. = ..()
	. += span_danger("It appears to have eaten [length(contents)] Monkey Cube[p_s()]")

/obj/item/slimecross/reproductive/attackby(obj/item/O, mob/user)
	var/datum/storage/extract_inventory/slime_storage = atom_storage
	if(!istype(slime_storage))
		return

	if((last_produce + cooldown) > world.time)
		to_chat(user, span_warning("[src] is still digesting!"))
		return

	if(length(contents) >= feed_amount) //if for some reason the contents are full, but it didnt digest, attempt to digest again
		to_chat(user,span_warning("[src] appears to be full but is not digesting! Maybe poking it stimulated it to digest."))
		slime_storage?.process_cubes(user)
		return

	if(istype(O, /obj/item/storage/bag/bio))
		var/list/inserted = list()
		O.atom_storage.remove_type(typecache_to_take, src, 1, null, null, user, inserted)
		if(inserted.len)
			to_chat(user, span_warning("You feed [length(inserted)] Monkey Cube[p_s()] to [src], and it pulses gently."))
			playsound(src, 'sound/items/eatfood.ogg', 20, TRUE)
			slime_storage?.process_cubes(src, user)
		else
			to_chat(user, span_notice("There are no monkey cubes in the bio bag!"))
		return

	else if(istype(O, /obj/item/food/monkeycube))
		if(atom_storage?.attempt_insert(O, user, override = TRUE, force = TRUE))
			to_chat(user, span_notice("You feed a Monkey Cube to [src], and it pulses gently."))
			slime_storage?.process_cubes(src, user)
			playsound(src, 'sound/items/eatfood.ogg', 20, TRUE)
			return
		to_chat(user, span_notice("The [src] rejects the Monkey Cube!")) //in case it fails to insert for whatever reason you get feedback

/obj/item/slimecross/reproductive/grey
	colour = SLIME_TYPE_GREY

/obj/item/slimecross/reproductive/orange
	colour = SLIME_TYPE_ORANGE

/obj/item/slimecross/reproductive/purple
	colour = SLIME_TYPE_PURPLE

/obj/item/slimecross/reproductive/blue
	colour = SLIME_TYPE_BLUE

/obj/item/slimecross/reproductive/metal
	colour = SLIME_TYPE_METAL

/obj/item/slimecross/reproductive/yellow
	colour = SLIME_TYPE_YELLOW

/obj/item/slimecross/reproductive/darkpurple
	colour = SLIME_TYPE_DARK_PURPLE

/obj/item/slimecross/reproductive/darkblue
	colour = SLIME_TYPE_DARK_BLUE

/obj/item/slimecross/reproductive/silver
	colour = SLIME_TYPE_SILVER

/obj/item/slimecross/reproductive/bluespace
	colour = SLIME_TYPE_BLUESPACE

/obj/item/slimecross/reproductive/sepia
	colour = SLIME_TYPE_SEPIA

/obj/item/slimecross/reproductive/cerulean
	colour = SLIME_TYPE_CERULEAN

/obj/item/slimecross/reproductive/pyrite
	colour = SLIME_TYPE_PYRITE

/obj/item/slimecross/reproductive/red
	colour = SLIME_TYPE_RED

/obj/item/slimecross/reproductive/green
	colour = SLIME_TYPE_GREEN

/obj/item/slimecross/reproductive/pink
	colour = SLIME_TYPE_PINK

/obj/item/slimecross/reproductive/gold
	colour = SLIME_TYPE_GOLD

/obj/item/slimecross/reproductive/oil
	colour = SLIME_TYPE_OIL

/obj/item/slimecross/reproductive/black
	colour = SLIME_TYPE_BLACK

/obj/item/slimecross/reproductive/lightpink
	colour = SLIME_TYPE_LIGHT_PINK

/obj/item/slimecross/reproductive/adamantine
	colour = SLIME_TYPE_ADAMANTINE

/obj/item/slimecross/reproductive/rainbow
	colour = SLIME_TYPE_RAINBOW
