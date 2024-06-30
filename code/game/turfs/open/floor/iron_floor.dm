/turf/open/floor/iron
	icon_state = "floor"
	floor_tile = /obj/item/stack/tile/iron/base

/turf/open/floor/iron/get_turf_texture()
	return GLOB.turf_texture_iron

/turf/open/floor/iron/examine(mob/user)
	. = ..()
	. += "<span class='notice'>There's a <b>small crack</b> on the edge of it.</span>"


/turf/open/floor/iron/rust_heretic_act()
	if(prob(70))
		new /obj/effect/temp_visual/glowing_rune(src)
	var/atom/changed_turf = ChangeTurf(/turf/open/floor/plating)
	changed_turf.AddElement(/datum/element/rust)
	return TRUE

/turf/open/floor/iron/update_icon_state()
	if(broken || burnt)
		return
	icon_state = base_icon_state
	return ..()

/turf/open/floor/iron/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/iron/telecomms
	initial_gas_mix = TCOMMS_ATMOS

/turf/open/floor/iron/edge
	icon_state = "floor_edge"
	base_icon_state = "floor_edge"
	floor_tile = /obj/item/stack/tile/iron/edge

/turf/open/floor/iron/half
	icon_state = "floor_half"
	base_icon_state = "floor_half"
	floor_tile = /obj/item/stack/tile/iron/half

/turf/open/floor/iron/corner
	icon_state = "floor_corner"
	base_icon_state = "floor_corner"
	floor_tile = /obj/item/stack/tile/iron/corner

/turf/open/floor/iron/large
	icon_state = "floor_large"
	base_icon_state = "floor_large"
	floor_tile = /obj/item/stack/tile/iron/large

/turf/open/floor/iron/textured
	icon_state = "textured"
	base_icon_state = "textured"
	floor_tile = /obj/item/stack/tile/iron/textured

/turf/open/floor/iron/textured_edge
	icon_state = "textured_edge"
	base_icon_state = "textured_edge"
	floor_tile = /obj/item/stack/tile/iron/textured_edge

/turf/open/floor/iron/textured_half
	icon_state = "textured_half"
	base_icon_state = "textured_half"
	floor_tile = /obj/item/stack/tile/iron/textured_half

/turf/open/floor/iron/textured_corner
	icon_state = "textured_corner"
	base_icon_state = "textured_corner"
	floor_tile = /obj/item/stack/tile/iron/textured_corner

/turf/open/floor/iron/textured_large
	icon_state = "textured_large"
	base_icon_state = "textured_large"
	floor_tile = /obj/item/stack/tile/iron/textured_large

/turf/open/floor/iron/dark
	icon_state = "darkfull"
	base_icon_state = "darkfull"
	floor_tile = /obj/item/stack/tile/iron/dark

/turf/open/floor/iron/dark/smooth_edge
	icon_state = "dark_edge"
	base_icon_state = "dark_edge"
	floor_tile = /obj/item/stack/tile/iron/dark/smooth_edge

/turf/open/floor/iron/dark/smooth_half
	icon_state = "dark_half"
	base_icon_state = "dark_half"
	floor_tile = /obj/item/stack/tile/iron/dark/smooth_half

/turf/open/floor/iron/dark/smooth_corner
	icon_state = "dark_corner"
	base_icon_state = "dark_corner"
	floor_tile = /obj/item/stack/tile/iron/dark/smooth_corner

/turf/open/floor/iron/dark/smooth_large
	icon_state = "dark_large"
	base_icon_state = "dark_large"
	floor_tile = /obj/item/stack/tile/iron/dark/smooth_large

/turf/open/floor/iron/dark/side
	icon_state = "darkside"
	base_icon_state = "darkside"
	floor_tile = /obj/item/stack/tile/iron/dark_side

/turf/open/floor/iron/dark/corner
	icon_state = "darkcorner"
	base_icon_state = "darkcorner"
	floor_tile = /obj/item/stack/tile/iron/dark_corner

/turf/open/floor/iron/checker
	icon_state = "checker"
	base_icon_state = "checker"
	floor_tile = /obj/item/stack/tile/iron/checker

/turf/open/floor/iron/dark/textured
	icon_state = "textured_dark"
	base_icon_state = "textured_dark"
	floor_tile = /obj/item/stack/tile/iron/dark/textured

/turf/open/floor/iron/dark/textured_edge
	icon_state = "textured_dark_edge"
	base_icon_state = "textured_dark_edge"
	floor_tile = /obj/item/stack/tile/iron/dark/textured_edge

/turf/open/floor/iron/dark/textured_half
	icon_state = "textured_dark_half"
	base_icon_state = "textured_dark_half"
	floor_tile = /obj/item/stack/tile/iron/dark/textured_half

/turf/open/floor/iron/dark/textured_corner
	icon_state = "textured_dark_corner"
	base_icon_state = "textured_dark_corner"
	floor_tile = /obj/item/stack/tile/iron/dark/textured_corner

/turf/open/floor/iron/dark/textured_large
	icon_state = "textured_dark_large"
	base_icon_state = "textured_dark_large"
	floor_tile = /obj/item/stack/tile/iron/dark/textured_large

/turf/open/floor/iron/dark/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/iron/dark/telecomms
	initial_gas_mix = TCOMMS_ATMOS

/turf/open/floor/iron/dark/side/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/iron/dark/corner/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/iron/checker/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/iron/white
	icon_state = "white"
	base_icon_state = "white"
	floor_tile = /obj/item/stack/tile/iron/white

/turf/open/floor/iron/white/smooth_edge
	icon_state = "white_edge"
	base_icon_state = "white_edge"
	floor_tile = /obj/item/stack/tile/iron/white/smooth_edge

/turf/open/floor/iron/white/smooth_half
	icon_state = "white_half"
	base_icon_state = "white_half"
	floor_tile = /obj/item/stack/tile/iron/white/smooth_half

/turf/open/floor/iron/white/smooth_corner
	icon_state = "white_corner"
	base_icon_state = "white_corner"
	floor_tile = /obj/item/stack/tile/iron/white/smooth_corner

/turf/open/floor/iron/white/smooth_large
	icon_state = "white_large"
	base_icon_state = "white_large"
	floor_tile = /obj/item/stack/tile/iron/white/smooth_large

/turf/open/floor/iron/white/side
	icon_state = "whitehall"
	base_icon_state = "whitehall"
	floor_tile = /obj/item/stack/tile/iron/white_side

/turf/open/floor/iron/white/corner
	icon_state = "whitecorner"
	base_icon_state = "whitecorner"
	floor_tile = /obj/item/stack/tile/iron/white_corner

/turf/open/floor/iron/cafeteria
	icon_state = "cafeteria"
	base_icon_state = "cafeteria"
	floor_tile = /obj/item/stack/tile/iron/cafeteria

/turf/open/floor/iron/white/textured
	icon_state = "textured_white"
	base_icon_state = "textured_white"
	floor_tile = /obj/item/stack/tile/iron/white/textured

/turf/open/floor/iron/white/textured_edge
	icon_state = "textured_white_edge"
	base_icon_state = "textured_white_edge"
	floor_tile = /obj/item/stack/tile/iron/white/textured_edge

/turf/open/floor/iron/white/textured_half
	icon_state = "textured_white_half"
	base_icon_state = "textured_white_half"
	floor_tile = /obj/item/stack/tile/iron/white/textured_half

/turf/open/floor/iron/white/textured_corner
	icon_state = "textured_white_corner"
	base_icon_state = "textured_white_corner"
	floor_tile = /obj/item/stack/tile/iron/white/textured_corner

/turf/open/floor/iron/white/textured_large
	icon_state = "textured_white_large"
	base_icon_state = "textured_white_large"
	floor_tile = /obj/item/stack/tile/iron/white/textured_large

/turf/open/floor/iron/white/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/iron/white/telecomms
	initial_gas_mix = TCOMMS_ATMOS

/turf/open/floor/iron/white/side/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/iron/white/corner/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/iron/cafeteria/airless
	initial_gas_mix = AIRLESS_ATMOS


/turf/open/floor/iron/recharge_floor
	icon_state = "recharge_floor"
	base_icon_state = "recharge_floor"
	floor_tile = /obj/item/stack/tile/iron/recharge_floor

/turf/open/floor/iron/recharge_floor/asteroid
	icon_state = "recharge_floor_asteroid"
	base_icon_state = "recharge_floor_asteroid"

/turf/open/floor/iron/smooth
	icon_state = "smooth"
	base_icon_state = "smooth"
	floor_tile = /obj/item/stack/tile/iron/smooth

/turf/open/floor/iron/smooth_edge
	icon_state = "smooth_edge"
	base_icon_state = "smooth_edge"
	floor_tile = /obj/item/stack/tile/iron/smooth_edge

/turf/open/floor/iron/smooth_half
	icon_state = "smooth_half"
	base_icon_state = "smooth_half"
	floor_tile = /obj/item/stack/tile/iron/smooth_half

/turf/open/floor/iron/smooth_corner
	icon_state = "smooth_corner"
	base_icon_state = "smooth_corner"
	floor_tile = /obj/item/stack/tile/iron/smooth_corner

/turf/open/floor/iron/smooth_large
	icon_state = "smooth_large"
	base_icon_state = "smooth_large"
	floor_tile = /obj/item/stack/tile/iron/smooth_large

/turf/open/floor/iron/chapel
	icon_state = "chapel"
	base_icon_state = "chapel"
	floor_tile = /obj/item/stack/tile/iron/chapel

/turf/open/floor/iron/showroomfloor
	icon_state = "showroomfloor"
	base_icon_state = "showroomfloor"
	floor_tile = /obj/item/stack/tile/iron/showroomfloor

/turf/open/floor/iron/showroomfloor/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/iron/solarpanel
	icon_state = "solarpanel"
	base_icon_state = "solarpanel"
	floor_tile = /obj/item/stack/tile/iron/solarpanel

/turf/open/floor/iron/solarpanel/airless
	initial_gas_mix = AIRLESS_ATMOS


/turf/open/floor/iron/freezer
	icon_state = "freezerfloor"
	base_icon_state = "freezerfloor"
	floor_tile = /obj/item/stack/tile/iron/freezer

/turf/open/floor/iron/freezer/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/iron/kitchen_coldroom
	name = "cold room floor"

/turf/open/floor/iron/kitchen_coldroom/Initialize(mapload)
	initial_gas_mix = KITCHEN_COLDROOM_ATMOS
	return ..()

/turf/open/floor/iron/kitchen_coldroom/freezerfloor
	icon_state = "freezerfloor"
	base_icon_state = "freezerfloor"
	floor_tile = /obj/item/stack/tile/iron/freezer

/turf/open/floor/iron/grimy
	icon_state = "grimy"
	base_icon_state = "grimy"
	tiled_dirt = FALSE
	floor_tile = /obj/item/stack/tile/iron/grimy


/turf/open/floor/cult
	name = "engraved floor"
	icon_state = "cult"
	base_icon_state = "cult"

/turf/open/floor/iron/vaporwave
	icon_state = "pinkblack"
	base_icon_state = "pinkblack"

/turf/open/floor/iron/goonplaque
	name = "commemorative plaque"
	desc = "\"This is a plaque in honour of our comrades on the G4407 Stations. Hopefully TG4407 model can live up to your fame and fortune.\" Scratched in beneath that is a crude image of a meteor and a spaceman. The spaceman is laughing. The meteor is exploding."
	icon_state = "plaque"
	base_icon_state = "plaque"
	tiled_dirt = FALSE
	floor_tile = /obj/item/stack/tile/iron/goonplaque

/turf/open/floor/iron/goonplaque/fland
	desc = "\"This plaque commemorates all the effort that has been put by the construction workers of this station, their department experts advisors, and the many roaming spacemans, that took the effort to walk around this station discovering anomalies that has been found during it's construction. This is a heartfelt thanks from the head developer of this station, hoping that the station will last for as long as possible.\" Beneath the text, you see engraved on the plaque a weird orb like being with a propeller on his head and a smile on it's face."

/turf/open/floor/iron/stairs
	icon_state = "stairs"
	base_icon_state = "stairs"
	tiled_dirt = FALSE

/turf/open/floor/iron/stairs/left
	icon_state = "stairs-l"
	base_icon_state = "stairs-l"

/turf/open/floor/iron/stairs/medium
	icon_state = "stairs-m"
	base_icon_state = "stairs-m"

/turf/open/floor/iron/stairs/right
	icon_state = "stairs-r"
	base_icon_state = "stairs-r"

/turf/open/floor/iron/stairs/old
	icon_state = "stairs-old"
	base_icon_state = "stairs-old"

/turf/open/floor/iron/bluespace
	icon_state = "bluespace"
	base_icon_state = "bluespace"
	desc = "Sadly, these don't seem to make you faster..."
	floor_tile = /obj/item/stack/tile/iron/bluespace

/turf/open/floor/iron/sepia
	icon_state = "sepia"
	base_icon_state = "sepia"
	desc = "Well, the flow of time is normal on these tiles, weird."
	floor_tile = /obj/item/stack/tile/iron/sepia

/turf/open/floor/iron/yellowsiding
	icon_state = "yellowsiding"
	base_icon_state = "yellowsiding"

/turf/open/floor/iron/yellowsiding/corner
	icon_state = "yellowcornersiding"
	base_icon_state = "yellowcornersiding"

/turf/open/floor/iron/tech
	icon_state = "techfloor_grey"
	base_icon_state = "techfloor_grey"
	floor_tile = /obj/item/stack/tile/

/turf/open/floor/iron/tech/grid
	icon_state = "techfloor_grid"
	base_icon_state = "techfloor_grid"
	floor_tile = /obj/item/stack/tile/

/turf/open/floor/iron/techmaint
	icon_state = "techmaint"
	base_icon_state = "techmaint"
	floor_tile = /obj/item/stack/tile/

/turf/open/floor/iron/techmaint/planetary
	baseturfs = /turf/open/floor/plating/asteroid
	planetary_atmos = TRUE

/turf/open/floor/iron/ridged
	icon_state = "ridged"
	base_icon_state = "ridged"
	floor_tile = /obj/item/stack/tile/ridge

/turf/open/floor/iron/ridged/steel
	icon_state = "steel_ridged"
	base_icon_state = "steel_ridged"

/turf/open/floor/iron/grid
	icon_state = "grid"
	base_icon_state = "grid"
	floor_tile = /obj/item/stack/tile/grid

/turf/open/floor/iron/grid/steel
	icon_state = "steel_grid"
	base_icon_state = "steel_grid"

/turf/open/floor/iron/ameridiner
	icon_state = "ameridiner_kitchen"
	base_icon_state = "ameridiner_kitchen"

/turf/open/floor/iron/tiled
	icon_state = "tiled"
	base_icon_state = "tiled"
/turf/open/floor/iron/tiled/light
	icon_state = "tiled_light"
	base_icon_state = "tiled_light"

/turf/open/floor/iron/tech
	icon_state = "techfloor_grey"
	base_icon_state = "techfloor_grey"
	floor_tile = /obj/item/stack/tile/techgrey

/turf/open/floor/iron/tech/grid
	icon_state = "techfloor_grid"
	base_icon_state = "techfloor_grid"
	floor_tile = /obj/item/stack/tile/techgrid

/turf/open/floor/iron/techmaint
	icon_state = "techmaint"
	base_icon_state = "techmaint"
	floor_tile = /obj/item/stack/tile/techmaint

/turf/open/floor/iron/cafeteria_red
	icon_state = "cafeteria_red"
	base_icon_state = "cafeteria_red"

/turf/open/floor/iron/greyish
	icon_state = "floor_light"

/turf/open/floor/iron/cafeteria_dark
	icon_state = "cafeteria_dark"
	base_icon_state = "cafeteria_dark"

/turf/open/floor/iron/smart_checker
	icon_state = "smart_checker"
	base_icon_state = "smart_checker"
