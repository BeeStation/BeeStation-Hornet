// Usage for a bar light is 160, let's do a bit less then that since these tend to be used a lot in one place
#define CIRCUIT_FLOOR_POWERUSE 120

//Circuit flooring, glows a little
/turf/open/floor/circuit
	icon = 'icons/turf/floors.dmi'
	icon_state = "bcircuit"
	base_icon_state = "bcircuit"
	light_color = LIGHT_COLOR_BABY_BLUE
	floor_tile = /obj/item/stack/tile/circuit

	/// If we want to ignore our area's power status and just be always off
	/// Mostly for mappers doing asthetic things, or cases where the floor should be broken
	var/always_off = FALSE
	/// If this floor is powered or not
	/// We don't consume any power, but we do require it
	var/on = -1

/turf/open/floor/circuit/Initialize(mapload)
	SSmapping.nuke_tiles += src
	RegisterSignal(loc, COMSIG_AREA_POWER_CHANGE, PROC_REF(handle_powerchange))
	var/area/cur_area = get_area(src)
	if (!isnull(cur_area))
		handle_powerchange(cur_area, TRUE)
	return ..()

/turf/open/floor/circuit/Destroy()
	SSmapping.nuke_tiles -= src
	UnregisterSignal(loc, COMSIG_AREA_POWER_CHANGE)
	var/area/cur_area = get_area(src)
	if(on && !isnull(cur_area))
		cur_area.removeStaticPower(CIRCUIT_FLOOR_POWERUSE, AREA_USAGE_STATIC_LIGHT)
	return ..()

/turf/open/floor/circuit/update_appearance(updates)
	. = ..()
	if(!on)
		set_light(0)
		return

	set_light_color(LAZYLEN(SSmapping.nuke_threats) ? LIGHT_COLOR_INTENSE_RED : initial(light_color))
	set_light(2, 1.5)

/turf/open/floor/circuit/update_icon_state()
	icon_state = on ? (LAZYLEN(SSmapping.nuke_threats) ? "rcircuitanim" : initial(icon_state)) : "[base_icon_state]off"
	return ..()

/turf/open/floor/circuit/on_change_area(area/old_area, area/new_area)
	. = ..()
	UnregisterSignal(old_area, COMSIG_AREA_POWER_CHANGE)
	RegisterSignal(new_area, COMSIG_AREA_POWER_CHANGE, PROC_REF(handle_powerchange))
	if(on)
		old_area.removeStaticPower(CIRCUIT_FLOOR_POWERUSE, AREA_USAGE_STATIC_LIGHT)
	handle_powerchange(new_area)

/// Enables/disables our lighting based off our source area
/turf/open/floor/circuit/proc/handle_powerchange(area/source, mapload = FALSE)
	SIGNAL_HANDLER
	var/old_on = on
	if(always_off)
		on = FALSE
	else
		on = source.powered(AREA_USAGE_LIGHT)
	if(on == old_on)
		return

	if(on)
		source.addStaticPower(CIRCUIT_FLOOR_POWERUSE, AREA_USAGE_STATIC_LIGHT)
	else if (!mapload)
		source.removeStaticPower(CIRCUIT_FLOOR_POWERUSE, AREA_USAGE_STATIC_LIGHT)
	update_appearance()

#undef CIRCUIT_FLOOR_POWERUSE

/turf/open/floor/circuit/off
	icon_state = "bcircuitoff"
	always_off = TRUE

/turf/open/floor/circuit/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/circuit/telecomms
	initial_gas_mix = TCOMMS_ATMOS

/turf/open/floor/circuit/telecomms/mainframe
	name = "mainframe base"

/turf/open/floor/circuit/telecomms/server
	name = "server base"

/turf/open/floor/circuit/green
	icon_state = "gcircuit"
	base_icon_state = "gcircuit"
	light_color = LIGHT_COLOR_GREEN
	floor_tile = /obj/item/stack/tile/circuit/green

/turf/open/floor/circuit/green/off
	icon_state = "gcircuitoff"
	always_off = TRUE

/turf/open/floor/circuit/green/anim
	icon_state = "gcircuitanim"
	base_icon_state = "gcircuitanim"
	floor_tile = /obj/item/stack/tile/circuit/green/anim

/turf/open/floor/circuit/green/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/circuit/green/telecomms
	initial_gas_mix = TCOMMS_ATMOS

/turf/open/floor/circuit/green/telecomms/mainframe
	name = "mainframe base"

/turf/open/floor/circuit/red
	icon_state = "rcircuit"
	base_icon_state = "rcircuit"
	light_color = LIGHT_COLOR_FLARE
	floor_tile = /obj/item/stack/tile/circuit/red

/turf/open/floor/circuit/red/off
	icon_state = "rcircuitoff"
	always_off = TRUE

/turf/open/floor/circuit/red/anim
	icon_state = "rcircuitanim"
	base_icon_state = "rcircuitanim"
	floor_tile = /obj/item/stack/tile/circuit/red/anim

/turf/open/floor/circuit/red/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/circuit/red/telecomms
	initial_gas_mix = TCOMMS_ATMOS

/turf/open/floor/pod
	name = "pod floor"
	icon_state = "podfloor"
	floor_tile = /obj/item/stack/tile/pod

/turf/open/floor/pod/light
	icon_state = "podfloor_light"
	floor_tile = /obj/item/stack/tile/pod/light

/turf/open/floor/pod/dark
	icon_state = "podfloor_dark"
	floor_tile = /obj/item/stack/tile/pod/dark


/turf/open/floor/noslip
	name = "high-traction floor"
	icon_state = "noslip"
	floor_tile = /obj/item/stack/tile/noslip
	slowdown = -0.3

/turf/open/floor/noslip/Initialize(mapload)
	. = ..()
	make_traction()

/turf/open/floor/noslip/standard
	name = "high-traction floor"
	icon_state = "floor"
	floor_tile = /obj/item/stack/tile/noslip/standard

/turf/open/floor/noslip/white
	name = "high-traction floor"
	icon_state = "white"
	floor_tile = /obj/item/stack/tile/noslip/white

/turf/open/floor/noslip/blue
	name = "high-traction floor"
	icon_state = "bluefull"
	floor_tile = /obj/item/stack/tile/noslip/blue

/turf/open/floor/noslip/darkblue
	name = "high-traction floor"
	icon_state = "darkbluefull"
	floor_tile = /obj/item/stack/tile/noslip/darkblue

/turf/open/floor/noslip/dark
	name = "high-traction floor"
	icon_state = "darkfull"
	floor_tile = /obj/item/stack/tile/noslip/dark

/turf/open/floor/noslip/vaporwave
	name = "high-traction floor"
	icon_state = "bluefull"
	floor_tile = /obj/item/stack/tile/noslip/vaporwave

/turf/open/floor/oldshuttle
	icon = 'icons/turf/shuttleold.dmi'
	icon_state = "floor"
	floor_tile = /obj/item/stack/tile/iron/base

/turf/open/floor/bluespace
	slowdown = -1
	icon_state = "bluespace"
	desc = "Through a series of micro-teleports these tiles let people move at incredible speeds."
	floor_tile = /obj/item/stack/tile/bluespace


/turf/open/floor/sepia
	slowdown = 2
	icon_state = "sepia"
	desc = "Time seems to flow very slowly around these tiles."
	floor_tile = /obj/item/stack/tile/sepia

/turf/open/floor/sepia/planetary
	baseturfs = /turf/open/floor/plating/asteroid
	planetary_atmos = TRUE


/turf/open/floor/bronze
	name = "bronze floor"
	desc = "Some heavy bronze tiles."
	icon_state = "clockwork_floor"
	floor_tile = /obj/item/stack/sheet/bronze

/turf/open/floor/bronze/flat
	icon_state = "reebe"
	floor_tile = /obj/item/stack/tile/mineral/bronze/flat

/turf/open/floor/bronze/filled
	icon = 'icons/obj/clockwork_objects.dmi'
	floor_tile = /obj/item/stack/tile/mineral/bronze/filled

/turf/open/floor/bronze/filled/lavaland
	planetary_atmos = TRUE
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS

/turf/open/floor/white
	name = "white floor"
	desc = "A tile in a pure white color."
	icon_state = "pure_white"

/turf/open/floor/black
	name = "black floor"
	icon_state = "black"

/turf/open/floor/monotile
	icon_state = "grey_full"
	floor_tile = /obj/item/stack/tile/mono

/turf/open/floor/monotile/steel
	icon_state = "steel_monotile"

/turf/open/floor/monotile/dark
	icon_state = "black_full"
	floor_tile = /obj/item/stack/tile/mono/dark

/turf/open/floor/monotile/light
	icon_state = "white_full"
	floor_tile = /obj/item/stack/tile/mono/light

/turf/open/floor/monotile/chess_white
	icon_state = "white_full"
	color = "#eeeed2"

/turf/open/floor/monotile/chess_black
	icon_state = "white_full"
	color = "#93b570"

/turf/open/floor/monofloor
	icon_state = "steel_monofloor"

/turf/open/floor/stone
	icon_state = "stone"

/turf/open/floor/plating/rust
	//SDMM supports colors, this is simply for easier mapping
	//and should be removed on initialize
	color = COLOR_BROWN

/turf/open/floor/plating/rust/Initialize(mapload)
	. = ..()
	color = null
	AddElement(/datum/element/rust)

/turf/open/floor/vault
	name = "strange floor"
	desc = "You feel a strange nostalgia from looking at this..."
	icon_state = "rockvault"
	base_icon_state = "rockvault"

/turf/open/floor/vault/rock
	name = "rocky floor"

/turf/open/floor/vault/alien
	name = "alien floor"
	icon_state = "alienvault"
	base_icon_state = "alienvault"

/turf/open/floor/vault/sandstone
	name = "sandstone floor"
	icon_state = "sandstonevault"
	base_icon_state = "sandstonevault"

/turf/open/floor/cult
	name = "engraved floor"
	icon_state = "cult"
	base_icon_state = "cult"
	floor_tile = /obj/item/stack/tile/cult

/turf/open/floor/cult/narsie_act()
	return

/turf/open/floor/cult/airless
	initial_gas_mix = AIRLESS_ATMOS
