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
	colour = "grey"

/obj/item/slimecross/reproductive/orange
	colour = "orange"

/obj/item/slimecross/reproductive/purple
	colour = "purple"

/obj/item/slimecross/reproductive/blue
	colour = "blue"

/obj/item/slimecross/reproductive/metal
	colour = "metal"

/obj/item/slimecross/reproductive/yellow
	colour = "yellow"

/obj/item/slimecross/reproductive/darkpurple
	colour = "dark purple"

/obj/item/slimecross/reproductive/darkblue
	colour = "dark blue"

/obj/item/slimecross/reproductive/silver
	colour = "silver"

/obj/item/slimecross/reproductive/bluespace
	colour = "bluespace"

/obj/item/slimecross/reproductive/sepia
	colour = "sepia"

/obj/item/slimecross/reproductive/cerulean
	colour = "cerulean"

/obj/item/slimecross/reproductive/pyrite
	colour = "pyrite"

/obj/item/slimecross/reproductive/red
	colour = "red"

/obj/item/slimecross/reproductive/green
	colour = "green"

/obj/item/slimecross/reproductive/pink
	colour = "pink"

/obj/item/slimecross/reproductive/gold
	colour = "gold"

/obj/item/slimecross/reproductive/oil
	colour = "oil"

/obj/item/slimecross/reproductive/black
	colour = "black"

/obj/item/slimecross/reproductive/lightpink
	colour = "light pink"

/obj/item/slimecross/reproductive/adamantine
	colour = "adamantine"

/obj/item/slimecross/reproductive/rainbow
	colour = "rainbow"
