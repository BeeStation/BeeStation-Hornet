//precursor to light tiles

/obj/item/stack/light_w
	name = "wired glass tile"
	singular_name = "wired glass floor tile"
	desc = "A glass tile, which is wired, somehow."
	icon = 'icons/obj/tiles.dmi'
	icon_state = "glass_wire"
	w_class = WEIGHT_CLASS_NORMAL
	force = 3
	throwforce = 5
	throw_speed = 3
	throw_range = 7
	flags_1 = CONDUCT_1
	max_amount = 60
	grind_results = list(/datum/reagent/silicon = 20, /datum/reagent/copper = 5)
	merge_type = /obj/item/stack/light_w

/obj/item/stack/light_w/attackby(obj/item/O, mob/user, params)
	if(!istype(O, /obj/item/stack/sheet/iron))
		return ..()
	var/obj/item/stack/sheet/iron/M = O
	if(!M.use(1))
		to_chat(user, span_warning("You need one iron sheet to finish the light tile!"))
		return
	new /obj/item/stack/tile/light(user.drop_location(), null, TRUE, user)
	to_chat(user, span_notice("You make a light tile."))
	use(1)

/obj/item/stack/light_w/wirecutter_act(mob/living/user, obj/item/I)
	var/atom/Tsec = user.drop_location()
	new /obj/item/stack/cable_coil(Tsec, 5, TRUE, user)
	new /obj/item/stack/sheet/glass(Tsec, null, TRUE, user)
	use(1)

//actual light tiles

/obj/item/stack/tile/light
	name = "light tile"
	singular_name = "light floor tile"
	desc = "A floor tile, made out of glass. It produces light."
	icon_state = "tile_e"
	flags_1 = CONDUCT_1
	attack_verb_continuous = list("bashes", "batters", "bludgeons", "thrashes", "smashes")
	attack_verb_simple = list("bash", "batter", "bludgeon", "thrash", "smash")
	turf_type = /turf/open/floor/light
	var/state = 0
	merge_type = /obj/item/stack/tile/light

CREATION_TEST_IGNORE_SUBTYPES(/obj/item/stack/tile/light)

/obj/item/stack/tile/light/Initialize(mapload, new_amount, merge = TRUE)
	. = ..()
	if(prob(5))
		state = 3 //broken
	else if(prob(5))
		state = 2 //breaking
	else if(prob(10))
		state = 1 //flickering occasionally
	else
		state = 0 //fine

/obj/item/stack/tile/light/attackby(obj/item/O, mob/user, params)
	if(O.tool_behaviour == TOOL_CROWBAR)
		new/obj/item/stack/sheet/iron(user.loc)
		amount--
		new/obj/item/stack/light_w(user.loc)
		if(amount <= 0)
			qdel(src)
	else
		return ..()

/obj/item/stack/tile/light/place_tile(turf/open/target_plating, mob/user)
	. = ..()
	var/turf/open/floor/light/floor = .
	floor?.state = state

/obj/item/stack/tile/light/cyborg
	custom_materials = null
	is_cyborg = 1
	cost = 125
	merge_type = /obj/item/stack/tile/light/cyborg

/obj/item/stack/tile/light/cyborg/attackby(obj/item/O, mob/user, params)
	return
