/* In this file:
 * Wood floor
 * Grass floor
 * Fake Basalt
 * Carpet floor
 * Fake pits
 * Fake space
 */

/turf/open/floor/bamboo
	desc = "A bamboo mat with a decorative trim."
	icon = 'icons/turf/floors/bamboo_mat.dmi'
	icon_state = "mat-0"
	base_icon_state = "mat"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_BAMBOO_FLOOR)
	canSmoothWith = list(SMOOTH_GROUP_BAMBOO_FLOOR)
	floor_tile = /obj/item/stack/tile/bamboo
	flags_1 = NONE
	footstep = FOOTSTEP_WOOD
	barefootstep = FOOTSTEP_WOOD_BAREFOOT
	clawfootstep = FOOTSTEP_WOOD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE
	max_integrity = 50

/turf/open/floor/bamboo/examine(mob/user)
	. = ..()
	. += span_notice("There's a <b>small crack</b> on the edge of it.")

/turf/open/floor/wood
	desc = "Stylish dark wood."
	icon_state = "wood"
	floor_tile = /obj/item/stack/tile/wood
	footstep = FOOTSTEP_WOOD
	barefootstep = FOOTSTEP_WOOD_BAREFOOT
	clawfootstep = FOOTSTEP_WOOD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE
	max_integrity = 100
	variant_probability = 85
	variant_states = 6

/turf/open/floor/wood/broken_states()
	return GLOB.wood_turf_damage

/turf/open/floor/wood/broken
	broken = TRUE
	variant_states = 0

/turf/open/floor/wood/big
	icon_state = "wood_big"
	variant_probability = 80
	variant_states = 4

/turf/open/floor/wood/big/broken_states()
	return GLOB.wood_big_turf_damage

/turf/open/floor/wood/examine(mob/user)
	. = ..()
	. += span_notice("There's a few <b>screws</b> and a <b>small crack</b> visible.")

/turf/open/floor/wood/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	return pry_tile(I, user) ? TRUE : FALSE

/turf/open/floor/wood/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	if(T.turf_type == type)
		return
	var/obj/item/tool = user.is_holding_tool_quality(TOOL_SCREWDRIVER)
	if(!tool)
		tool = user.is_holding_tool_quality(TOOL_CROWBAR)
	if(!tool)
		return
	var/turf/open/floor/plating/P = pry_tile(tool, user, TRUE)
	if(!istype(P))
		return
	P.attackby(T, user, params)

/turf/open/floor/wood/pry_tile(obj/item/C, mob/user, silent = FALSE)
	C.play_tool_sound(src, 80)
	return remove_tile(user, silent, (C.tool_behaviour == TOOL_SCREWDRIVER))

/turf/open/floor/wood/remove_tile(mob/user, silent = FALSE, make_tile = TRUE)
	if(broken || burnt)
		broken = 0
		burnt = 0
		if(user && !silent)
			to_chat(user, span_notice("You remove the broken planks."))
	else
		if(make_tile)
			if(user && !silent)
				to_chat(user, span_notice("You unscrew the planks."))
			if(floor_tile)
				new floor_tile(src)
		else
			if(user && !silent)
				to_chat(user, span_notice("You forcefully pry off the planks, destroying them in the process."))
	return make_plating()

/turf/open/floor/wood/cold
	temperature = 255.37

/turf/open/floor/wood/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/grass
	name = "grass patch"
	desc = "You can't tell if this is real grass or just cheap plastic imitation."
	icon = 'icons/turf/floors/grass.dmi'
	icon_state = "grass"
	base_icon_state = "grass"
	floor_tile = /obj/item/stack/tile/grass
	flags_1 = NONE
	bullet_bounce_sound = null
	layer = EDGED_TURF_LAYER
	footstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_GRASS
	clawfootstep = FOOTSTEP_GRASS
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_FLOOR_GRASS)
	canSmoothWith = list(SMOOTH_GROUP_FLOOR_GRASS)
	var/ore_type = /obj/item/stack/ore/glass
	var/turfverb = "uproot"
	tiled_dirt = FALSE
	max_integrity = 80
	transform = MAP_SWITCH(TRANSLATE_MATRIX(-9, -9), matrix())

/turf/open/floor/grass/no_border
	layer = TURF_LAYER
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_OPEN_FLOOR)
	canSmoothWith = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_OPEN_FLOOR)
	smoothing_flags = NONE
	transform = null

/turf/open/floor/grass/Initialize(mapload)
	. = ..()
	update_icon()

/turf/open/floor/grass/attackby(obj/item/C, mob/user, params)
	if((C.tool_behaviour == TOOL_SHOVEL) && params)
		new ore_type(src, 2)
		user.visible_message("[user] digs up [src].", span_notice("You [turfverb] [src]."))
		playsound(src, 'sound/effects/shovel_dig.ogg', 50, 1)
		make_plating()
	else if(C.sharpness != BLUNT)
		QUEUE_SMOOTH(src)
		QUEUE_SMOOTH_NEIGHBORS(src)
		icon_state = "grass"
		smoothing_groups = list()
		canSmoothWith = list()
		transform = null
		playsound(src, 'sound/items/wirecutter.ogg')
	if(..())
		return

/turf/open/floor/grass/fairy //like grass but fae-er
	name = "fairygrass patch"
	desc = "Something about this grass makes you want to frolic. Or get high."
	icon = 'icons/turf/floors/grass_fairy.dmi'
	icon_state = "fairygrass"
	floor_tile = /obj/item/stack/tile/fairygrass
	light_range = 2
	light_power = 0.80
	light_color = COLOR_BLUE_LIGHT
	color = COLOR_BLUE_LIGHT

/turf/open/floor/grass/fairy/white
	name = "white fairygrass patch"
	floor_tile = /obj/item/stack/tile/fairygrass/white
	light_color = COLOR_WHITE
	color = COLOR_WHITE

/turf/open/floor/grass/fairy/red
	name = "red fairygrass patch"
	floor_tile = /obj/item/stack/tile/fairygrass/red
	light_color = COLOR_RED_LIGHT
	color = COLOR_RED_LIGHT

/turf/open/floor/grass/fairy/orange
	name = "orange fairygrass patch"
	floor_tile = /obj/item/stack/tile/fairygrass/orange
	light_color = "#FFA500"
	color = "#FFA500"

/turf/open/floor/grass/fairy/yellow
	name = "yellow fairygrass patch"
	floor_tile = /obj/item/stack/tile/fairygrass/yellow
	light_color = "#FFFF66"
	color = "#FFFF66"

/turf/open/floor/grass/fairy/green
	name = "green fairygrass patch"
	floor_tile = /obj/item/stack/tile/fairygrass/green
	light_color = "#99FF99"
	color = "#99FF99"

/turf/open/floor/grass/fairy/blue
	floor_tile = /obj/item/stack/tile/fairygrass/blue
	name = "blue fairygrass patch"

/turf/open/floor/grass/fairy/purple
	name = "purple fairygrass patch"
	floor_tile = /obj/item/stack/tile/fairygrass/purple
	light_color = "#D966FF"
	color = "#D966FF"

/turf/open/floor/grass/fairy/pink
	name = "pink fairygrass patch"
	floor_tile = /obj/item/stack/tile/fairygrass/pink
	light_color = "#FFB3DA"
	color = "#FFB3DA"

/turf/open/floor/grass/fairy/dark
	name = "dark fairygrass patch"
	floor_tile = /obj/item/stack/tile/fairygrass/dark
	light_power = -0.15
	light_range = 2
	light_color = "#AAD84B"
	color = "#53003f"

/turf/open/floor/grass/snow
	gender = PLURAL
	name = "snow"
	icon = 'icons/turf/snow.dmi'
	desc = "Looks cold."
	icon_state = "snow"
	ore_type = /obj/item/stack/sheet/snow

	planetary_atmos = TRUE
	floor_tile = null
	initial_gas_mix = FROZEN_ATMOS
	slowdown = 2
	bullet_sizzle = TRUE
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_OPEN_FLOOR)
	canSmoothWith = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_OPEN_FLOOR)
	smoothing_flags = NONE
	transform = null

/turf/open/floor/grass/snow/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/open/floor/grass/snow/crowbar_act(mob/living/user, obj/item/I)
	return

/turf/open/floor/grass/snow/basalt //By your powers combined, I am captain planet
	gender = NEUTER
	name = "volcanic floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "basalt"
	ore_type = /obj/item/stack/ore/glass/basalt
	initial_gas_mix = OPENTURF_LOW_PRESSURE
	slowdown = 0

/turf/open/floor/grass/snow/basalt/Initialize(mapload)
	. = ..()
	if(prob(15))
		icon_state = "basalt[rand(0, 12)]"
		set_basalt_light(src)

/turf/open/floor/grass/snow/safe
	slowdown = 1.5
	planetary_atmos = FALSE

/turf/open/floor/grass/snow/safe/nocold
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS


/turf/open/floor/grass/fakebasalt //Heart is not a real planeteer power
	name = "aesthetic volcanic flooring"
	desc = "Safely recreated turf for your hellplanet-scaping."
	icon = 'icons/turf/floors.dmi'
	icon_state = "basalt"
	floor_tile = /obj/item/stack/tile/basalt
	ore_type = /obj/item/stack/ore/glass/basalt
	turfverb = "dig up"
	slowdown = 0
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_OPEN_FLOOR)
	canSmoothWith = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_OPEN_FLOOR)
	smoothing_flags = NONE
	transform = null

/turf/open/floor/grass/fakebasalt/Initialize(mapload)
	. = ..()
	if(prob(15))
		icon_state = "basalt[rand(0, 12)]"
		set_basalt_light(src)


/turf/open/floor/carpet
	name = "carpet"
	desc = "Soft velvet carpeting. Feels good between your toes."
	icon = 'icons/turf/floors/carpet.dmi'
	icon_state = "carpet-255"
	base_icon_state = "carpet"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET)
	canSmoothWith = list(SMOOTH_GROUP_CARPET)
	floor_tile = /obj/item/stack/tile/carpet
	flags_1 = NONE
	bullet_bounce_sound = null
	footstep = FOOTSTEP_CARPET
	barefootstep = FOOTSTEP_CARPET_BAREFOOT
	clawfootstep = FOOTSTEP_CARPET_BAREFOOT
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE
	max_integrity = 150

/turf/open/floor/carpet/examine(mob/user)
	. = ..()
	. += span_notice("There's a <b>small crack</b> on the edge of it.")

/turf/open/floor/carpet/Initialize(mapload)
	. = ..()
	update_icon()

/turf/open/floor/carpet/update_icon()
	if(!..())
		return 0
	if(!broken && !burnt)
		if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
			QUEUE_SMOOTH(src)

/turf/open/floor/carpet/lone
	icon_state = "carpetsymbol"
	smoothing_flags = NONE
	floor_tile = /obj/item/stack/tile/carpet/symbol

/turf/open/floor/carpet/lone/star
	icon_state = "carpetstar"
	floor_tile = /obj/item/stack/tile/carpet/star

/turf/open/floor/carpet/black
	icon = 'icons/turf/floors/carpet_black.dmi'
	icon_state = "carpet_black-255"
	base_icon_state = "carpet_black"
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_BLACK)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_BLACK)
	floor_tile = /obj/item/stack/tile/carpet/black

/turf/open/floor/carpet/blue
	icon = 'icons/turf/floors/carpet_blue.dmi'
	icon_state = "carpet_blue-255"
	base_icon_state = "carpet_blue"
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_BLUE)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_BLUE)
	floor_tile = /obj/item/stack/tile/carpet/blue

/turf/open/floor/carpet/cyan
	icon = 'icons/turf/floors/carpet_cyan.dmi'
	icon_state = "carpet_cyan-255"
	base_icon_state = "carpet_cyan"
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_CYAN)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_CYAN)
	floor_tile = /obj/item/stack/tile/carpet/cyan

/turf/open/floor/carpet/green
	icon = 'icons/turf/floors/carpet_green.dmi'
	icon_state = "carpet_green-255"
	base_icon_state = "carpet_green"
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_GREEN)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_GREEN)
	floor_tile = /obj/item/stack/tile/carpet/green

/turf/open/floor/carpet/orange
	icon = 'icons/turf/floors/carpet_orange.dmi'
	icon_state = "carpet_orange-255"
	base_icon_state = "carpet_orange"
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_ORANGE)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_ORANGE)
	floor_tile = /obj/item/stack/tile/carpet/orange

/turf/open/floor/carpet/purple
	icon = 'icons/turf/floors/carpet_purple.dmi'
	icon_state = "carpet_purple-255"
	base_icon_state = "carpet_purple"
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_PURPLE)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_PURPLE)
	floor_tile = /obj/item/stack/tile/carpet/purple

/turf/open/floor/carpet/red
	icon = 'icons/turf/floors/carpet_red.dmi'
	icon_state = "carpet_red-255"
	base_icon_state = "carpet_red"
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_RED)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_RED)
	floor_tile = /obj/item/stack/tile/carpet/red

/turf/open/floor/carpet/olive
	icon = 'icons/turf/floors/carpet_olive.dmi'
	icon_state = "carpet_olive-255"
	base_icon_state = "carpet_olive"
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_OLIVE)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_OLIVE)
	floor_tile = /obj/item/stack/tile/carpet/olive

/turf/open/floor/carpet/royalblack
	icon = 'icons/turf/floors/carpet_royalblack.dmi'
	icon_state = "carpet_royalblack-255"
	base_icon_state = "carpet_royalblack"
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_ROYAL_BLACK)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_ROYAL_BLACK)
	floor_tile = /obj/item/stack/tile/carpet/royalblack

/turf/open/floor/carpet/royalblue
	icon = 'icons/turf/floors/carpet_royalblue.dmi'
	icon_state = "carpet_royalblue-255"
	base_icon_state = "carpet_royalblue"
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_ROYAL_BLUE)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_ROYAL_BLUE)
	floor_tile = /obj/item/stack/tile/carpet/royalblue

/turf/open/floor/carpet/grimy
	name = "grimy carpet"
	desc = "Hold on, wasn't this made with steel once?"
	icon = 'icons/turf/floors/carpet_grimy.dmi'
	icon_state = "carpet_grimy-255"
	base_icon_state = "carpet_grimy"
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET_GRIMY)
	canSmoothWith = list(SMOOTH_GROUP_CARPET_GRIMY)
	floor_tile = /obj/item/stack/tile/carpet/grimy

/turf/open/floor/eighties
	name = "retro floor"
	desc = "This one takes you back."
	icon_state = "eighties"
	floor_tile = /obj/item/stack/tile/eighties

/turf/open/floor/carpet/narsie_act(force, ignore_mobs, probability = 20)
	. = (prob(probability) || force)
	for(var/I in src)
		var/atom/A = I
		if(ignore_mobs && ismob(A))
			continue
		if(ismob(A) || .)
			A.narsie_act()

/turf/open/floor/carpet/break_tile()
	broken = TRUE
	make_plating()
	if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		QUEUE_SMOOTH_NEIGHBORS(src)

/turf/open/floor/carpet/burn_tile()
	burnt = TRUE
	make_plating()
	if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		QUEUE_SMOOTH_NEIGHBORS(src)

/turf/open/floor/carpet/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	return FALSE


/turf/open/floor/fakepit
	desc = "A clever illusion designed to look like a bottomless pit."
	base_icon_state = "chasms"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_TURF_CHASM)
	canSmoothWith = list(SMOOTH_GROUP_TURF_CHASM)
	icon = 'icons/turf/floors/Chasms.dmi'
	icon_state = "chasms-0"
	floor_tile = /obj/item/stack/tile/fakepit
	tiled_dirt = FALSE
	max_integrity = 100

/turf/open/floor/fakepit/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/floors.dmi'
	underlay_appearance.icon_state = "basalt"
	return TRUE

/turf/open/floor/fakespace
	icon = 'icons/turf/space.dmi'
	icon_state = "0"
	floor_tile = /obj/item/stack/tile/fakespace
	plane = PLANE_SPACE
	tiled_dirt = FALSE
	max_integrity = 100
	fullbright_type = FULLBRIGHT_STARLIGHT
	luminosity = 2

/turf/open/floor/fakespace/Initialize(mapload)
	. = ..()
	icon_state = SPACE_ICON_STATE

/turf/open/floor/fakespace/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/space.dmi'
	underlay_appearance.icon_state = SPACE_ICON_STATE
	underlay_appearance.plane = PLANE_SPACE
	return TRUE

/turf/open/floor/wax
	name = "wax"
	icon_state = "honeyfloor"
	desc = "Hard wax. Makes you feel like part of a hive."
	floor_tile = /obj/item/stack/tile/mineral/wax
	footstep = FOOTSTEP_WOOD
	barefootstep = FOOTSTEP_WOOD_BAREFOOT
	clawfootstep = FOOTSTEP_WOOD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE
	max_integrity = 120

/turf/open/floor/wax/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/concrete
	name = "concrete"
	icon_state = "conc_smooth"
	desc = "Cement Das Conk Creet Baybee."
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE
	max_integrity = 120

/turf/open/floor/concrete/slab
	icon_state = "conc_slab"

/turf/open/floor/concrete/tile
	icon_state = "conc_tiles"
