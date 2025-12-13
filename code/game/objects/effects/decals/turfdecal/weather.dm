/obj/effect/turf_decal/weather
	name = "sandy floor"
	icon_state = "sandyfloor"

/obj/effect/turf_decal/weather/snow
	icon = 'icons/turf/overlays.dmi'
	name = "snowy floor"
	icon_state = "snowfloor"

/obj/effect/turf_decal/weather/snow/full
	icon = 'icons/turf/snow.dmi'
	name = "snow"
	icon_state = "snow"

/obj/effect/turf_decal/weather/snow/full/Initialize(mapload)
	. = ..()
	icon_state = "snow[rand(1,12)]"

/obj/effect/turf_decal/weather/snow/full/corner
	icon_state = "snow_corner"

/obj/effect/turf_decal/weather/snow/full/edge
	icon_state = "snow_edge"

/obj/effect/turf_decal/weather/snow/full/end
	icon_state = "snow_end"

/obj/effect/turf_decal/weather/snow/spot
	name = "snow piece"
	icon_state = "snow_spot"
	layer = 3

/obj/effect/turf_decal/weather/dirt
	name = "dirt siding"
	icon = 'icons/turf/decals.dmi'
	icon_state = "dirt_side"

/obj/effect/turf_decal/weather/dirt/corner
	name = "corner"
	icon = 'icons/turf/decals.dmi'
	icon_state = "dirt_side_corner"
