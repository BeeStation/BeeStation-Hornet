/turf/open/floor/holofloor
	icon_state = "floor"
	holodeck_compatible = TRUE
	thermal_conductivity = 0
	flags_1 = NONE
	var/direction = SOUTH

/turf/open/floor/holofloor/attackby(obj/item/I, mob/living/user)
	return // HOLOFLOOR DOES NOT GIVE A FUCK

/turf/open/floor/holofloor/tool_act(mob/living/user, obj/item/I, tool_type)
	return

/turf/open/floor/holofloor/burn_tile()
	return //you can't burn a hologram!

/turf/open/floor/holofloor/break_tile()
	return //you can't break a hologram!

/turf/open/floor/holofloor/plating
	name = "holodeck projector floor"
	icon_state = "engine"

/turf/open/floor/holofloor/chapel
	name = "chapel floor"
	icon_state = "chapel"

/turf/open/floor/holofloor/chapel/bottom_left
	direction = WEST

/turf/open/floor/holofloor/chapel/top_right
	direction = EAST

/turf/open/floor/holofloor/chapel/bottom_right

/turf/open/floor/holofloor/chapel/top_left
	direction = NORTH

/turf/open/floor/holofloor/chapel/Initialize(mapload)
	. = ..()
	if (direction != SOUTH)
		setDir(direction)

/turf/open/floor/holofloor/white
	name = "white floor"
	icon_state = "white"

/turf/open/floor/holofloor/plating/burnmix
	name = "burn-mix floor"
	initial_gas_mix = BURNMIX_ATMOS

/turf/open/floor/holofloor/grass
	gender = PLURAL
	name = "lush grass"
	icon = 'icons/turf/floors/grass.dmi'
	icon_state = "grass"
	bullet_bounce_sound = null
	tiled_dirt = FALSE

/turf/open/floor/holofloor/beach
	gender = PLURAL
	name = "sand"
	icon = 'icons/misc/beach.dmi'
	icon_state = "sand"
	bullet_bounce_sound = null
	tiled_dirt = FALSE

/turf/open/floor/holofloor/beach/coast_t
	gender = NEUTER
	name = "coastline"
	icon_state = "sandwater_t"

/turf/open/floor/holofloor/beach/coast_b
	gender = NEUTER
	name = "coastline"
	icon_state = "sandwater_b"

/turf/open/floor/holofloor/beach/water
	name = "water"
	icon_state = "water"
	bullet_sizzle = TRUE

/turf/open/floor/holofloor/asteroid
	name = "asteroid"
	icon_state = "asteroid0"
	tiled_dirt = FALSE

/turf/open/floor/holofloor/asteroid/Initialize(mapload)
	icon_state = "asteroid[rand(0, 12)]"
	. = ..()

/turf/open/floor/holofloor/basalt
	gender = PLURAL
	name = "basalt"
	icon_state = "basalt0"
	tiled_dirt = FALSE

/turf/open/floor/holofloor/basalt/Initialize(mapload)
	. = ..()
	if(prob(15))
		icon_state = "basalt[rand(0, 12)]"
		set_basalt_light(src)

/turf/open/floor/holofloor/space
	name = "\proper space"
	icon = 'icons/turf/space.dmi'
	icon_state = "0"
	fullbright_type = FULLBRIGHT_STARLIGHT
	luminosity = 2

/turf/open/floor/holofloor/space/Initialize(mapload)
	icon_state = SPACE_ICON_STATE // so realistic
	. = ..()

/turf/open/floor/holofloor/hyperspace
	name = "\proper hyperspace"
	icon = 'icons/turf/space.dmi'
	icon_state = "speedspace_ns_1"
	bullet_bounce_sound = null
	tiled_dirt = FALSE
	fullbright_type = FULLBRIGHT_STARLIGHT
	luminosity = 2

/turf/open/floor/holofloor/hyperspace/nograv/check_gravity()
	return FALSE

/turf/open/floor/holofloor/hyperspace/Initialize(mapload)
	icon_state = "speedspace_ns_[(x + 5*y + (y%2+1)*7)%15+1]"
	. = ..()

/turf/open/floor/holofloor/hyperspace/ns/Initialize(mapload)
	. = ..()
	icon_state = "speedspace_ns_[(x + 5*y + (y%2+1)*7)%15+1]"

/turf/open/floor/holofloor/carpet
	name = "carpet"
	desc = "Electrically inviting."
	icon = 'icons/turf/floors/carpet.dmi'
	icon_state = "carpet-255"
	base_icon_state = "carpet"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_CARPET)
	canSmoothWith = list(SMOOTH_GROUP_CARPET)
	floor_tile = /obj/item/stack/tile/carpet
	bullet_bounce_sound = null
	tiled_dirt = FALSE

/turf/open/floor/holofloor/carpet/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_appearance)), 1)

/turf/open/floor/holofloor/carpet/update_icon(updates=ALL)
	. = ..()
	if((updates & UPDATE_SMOOTHING) && overfloor_placed && smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		QUEUE_SMOOTH(src)

/turf/open/floor/holofloor/wood
	icon_state = "wood"
	tiled_dirt = FALSE
	variant_probability = 80
	variant_states = 4

/turf/open/floor/holofloor/snow
	gender = PLURAL
	name = "snow"
	desc = "Looks cold."
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow"
	slowdown = 2
	bullet_sizzle = TRUE
	bullet_bounce_sound = null
	tiled_dirt = FALSE

/turf/open/floor/holofloor/snow/cold
	initial_gas_mix = "nob=7500;TEMP=2.7"

/turf/open/floor/holofloor/asteroid
	gender = PLURAL
	name = "asteroid sand"
	icon = 'icons/turf/floors.dmi'
	icon_state = "asteroid"
	tiled_dirt = FALSE

/turf/open/floor/holofloor/dark
	icon_state = "darkfull"

/turf/open/floor/holofloor/clown
	icon_state = "bananium"

/turf/open/floor/holofloor/white
	name = "white floor"
	desc = "A tile in a pure white color."
	icon_state = "pure_white"

/turf/open/floor/holofloor/eighties
	name = "retro floor"
	desc = "This one takes you back."
	icon_state = "eighties"

/turf/open/floor/holofloor/monotile/dark
	name = "dark holotile"
	desc = "A really big dark steel holotile."
	icon_state = "monotile_dark"

/turf/open/floor/holofloor/monotile/steel
	name = "steel holotile"
	desc = "A really big steel holotile."
	icon_state = "steel_monotile"

/turf/open/floor/holofloor/monotile/light
	name = "light holotile"
	desc = "A really big light steel holotile."
	icon_state = "grey_full"

/turf/open/floor/holofloor/chess_white
	icon_state = "white_full"
	color = "#eeeed2"

/turf/open/floor/holofloor/chess_black
	icon_state = "white_full"
	color = "#93b570"
