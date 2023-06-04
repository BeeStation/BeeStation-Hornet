/obj/effect/turf_decal/tile
	name = "tile decal"
	icon_state = "tile_corner"
	layer = TURF_PLATING_DECAL_LAYER
	alpha = 110

/obj/effect/turf_decal/tile/Initialize(mapload)
	if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
		color = "#[random_short_color()]"
	return ..()

/// White tiles

/obj/effect/turf_decal/tile/white
	name = "white corner"

/obj/effect/turf_decal/tile/white/corner_ramp
	icon_state = "tile_corner_ramp"
	name = "white corner ramp"

/obj/effect/turf_decal/tile/white/corner_ramp/offset
	icon_state = "tile_corner_ramp_offset"
	name = "white corner ramp offset"

/obj/effect/turf_decal/tile/white/opposingcorners //Two corners on opposite ends of each other (i.e. Top Right to Bottom Left). Allows for faster mapping and less complicated turf decal storage.
	icon_state = "tile_opposing_corners"
	name = "opposing white corners"

/obj/effect/turf_decal/tile/white/half
	icon_state = "tile_half"
	name = "white half"

/obj/effect/turf_decal/tile/white/half/contrasted
	icon_state = "tile_half_contrasted"
	name = "contrasted white half"

/obj/effect/turf_decal/tile/white/anticorner
	icon_state = "tile_anticorner"
	name = "white anticorner"

/obj/effect/turf_decal/tile/white/anticorner/contrasted
	icon_state = "tile_anticorner_contrasted"
	name = "contrasted white anticorner"

/obj/effect/turf_decal/tile/white/fourcorners/contrasted
	icon_state = "tile_fourcorners_contrasted"
	name = "white fourcorners"

/obj/effect/turf_decal/tile/white/fourcorners
	icon_state = "tile_fourcorners"
	name = "white full"

/obj/effect/turf_decal/tile/white/diagonal_centre
	icon_state = "diagonal_centre"
	name = "white diagonal centre"

/obj/effect/turf_decal/tile/white/diagonal_edge
	icon_state = "diagonal_edge"
	name = "white diagonal edge"

/obj/effect/turf_decal/tile/white/carat
	icon_state = "tile_carat"
	name = "white carat decal"

/obj/effect/turf_decal/tile/white/anticorner_ramp
	icon_state = "tile_anticorner_ramp"
	name = "white anticorner ramp"

/obj/effect/turf_decal/tile/white/anticorner_ramp/contrasted
	icon_state = "tile_anticorner_contrasted_ramp"
	name = "contrasted white anticorner ramp"

/// Blue tiles

/obj/effect/turf_decal/tile/blue
	name = "blue corner"
	color = "#52B4E9"

/obj/effect/turf_decal/tile/blue/corner_ramp
	icon_state = "tile_corner_ramp"
	name = "blue corner ramp"

/obj/effect/turf_decal/tile/blue/corner_ramp/offset
	icon_state = "tile_corner_ramp_offset"
	name = "blue corner ramp offset"

/obj/effect/turf_decal/tile/blue/opposingcorners //Two corners on opposite ends of each other (i.e. Top Right to Bottom Left). Allows for faster mapping and less complicated turf decal storage.
	icon_state = "tile_opposing_corners"
	name = "opposing blue corners"

/obj/effect/turf_decal/tile/blue/half
	icon_state = "tile_half"
	name = "blue half"

/obj/effect/turf_decal/tile/blue/half/contrasted
	icon_state = "tile_half_contrasted"
	name = "contrasted blue half"

/obj/effect/turf_decal/tile/blue/anticorner
	icon_state = "tile_anticorner"
	name = "blue anticorner"

/obj/effect/turf_decal/tile/blue/anticorner/contrasted
	icon_state = "tile_anticorner_contrasted"
	name = "contrasted blue anticorner"

/obj/effect/turf_decal/tile/blue/fourcorners/contrasted
	icon_state = "tile_fourcorners_contrasted"
	name = "blue fourcorners"

/obj/effect/turf_decal/tile/blue/fourcorners
	icon_state = "tile_fourcorners"
	name = "blue full"

/obj/effect/turf_decal/tile/blue/diagonal_centre
	icon_state = "diagonal_centre"
	name = "blue diagonal centre"

/obj/effect/turf_decal/tile/blue/diagonal_edge
	icon_state = "diagonal_edge"
	name = "blue diagonal edge"

/obj/effect/turf_decal/tile/blue/carat
	icon_state = "tile_carat"
	name = "blue carat decal"

/obj/effect/turf_decal/tile/blue/anticorner_ramp
	icon_state = "tile_anticorner_ramp"
	name = "blue anticorner ramp"

/obj/effect/turf_decal/tile/blue/anticorner_ramp/contrasted
	icon_state = "tile_anticorner_contrasted_ramp"
	name = "contrasted blue anticorner ramp"

/// Dark blue tiles

/obj/effect/turf_decal/tile/dark_blue
	name = "dark blue corner"
	color = "#486091"

/obj/effect/turf_decal/tile/dark_blue/corner_ramp
	icon_state = "tile_corner_ramp"
	name = "dark blue corner ramp"

/obj/effect/turf_decal/tile/dark_blue/corner_ramp/offset
	icon_state = "tile_corner_ramp_offset"
	name = "dark blue corner ramp offset"

/obj/effect/turf_decal/tile/dark_blue/opposingcorners
	icon_state = "tile_opposing_corners"
	name = "opposing dark blue corners"

/obj/effect/turf_decal/tile/dark_blue/half
	icon_state = "tile_half"
	name = "dark blue half"

/obj/effect/turf_decal/tile/dark_blue/half/contrasted
	icon_state = "tile_half_contrasted"
	name = "contrasted dark blue half"

/obj/effect/turf_decal/tile/dark_blue/anticorner
	icon_state = "tile_anticorner"
	name = "dark blue anticorner"

/obj/effect/turf_decal/tile/dark_blue/anticorner/contrasted
	icon_state = "tile_anticorner_contrasted"
	name = "contrasted dark blue anticorner"

/obj/effect/turf_decal/tile/dark_blue/fourcorners/contrasted
	icon_state = "tile_fourcorners_contrasted"
	name = "dark blue fourcorners"

/obj/effect/turf_decal/tile/dark_blue/fourcorners
	icon_state = "tile_fourcorners"
	name = "dark blue full"

/obj/effect/turf_decal/tile/dark_blue/diagonal_centre
	icon_state = "diagonal_centre"
	name = "dark blue diagonal centre"

/obj/effect/turf_decal/tile/dark_blue/diagonal_edge
	icon_state = "diagonal_edge"
	name = "dark blue diagonal edge"

/obj/effect/turf_decal/tile/dark_blue/carat
	icon_state = "tile_carat"
	name = "dark blue carat decal"
/obj/effect/turf_decal/tile/dark_blue/anticorner_ramp
	icon_state = "tile_anticorner_ramp"
	name = "dark blue anticorner ramp"

/obj/effect/turf_decal/tile/dark_blue/anticorner_ramp/contrasted
	icon_state = "tile_anticorner_contrasted_ramp"
	name = "contrasted dark blue anticorner ramp"

// Black tiles

/obj/effect/turf_decal/tile/black
	name = "black corner"
	color = "#000000"

/obj/effect/turf_decal/tile/black/corner_ramp
	icon_state = "tile_corner_ramp"
	name = "black corner ramp"

/obj/effect/turf_decal/tile/black/corner_ramp/offset
	icon_state = "tile_corner_ramp_offset"
	name = "black corner ramp offset"

/obj/effect/turf_decal/tile/black/opposingcorners
	icon_state = "tile_opposing_corners"
	name = "opposing black corners"

/obj/effect/turf_decal/tile/black/half
	icon_state = "tile_half"
	name = "black half"

/obj/effect/turf_decal/tile/black/half/contrasted
	icon_state = "tile_half_contrasted"
	name = "contrasted black half"

/obj/effect/turf_decal/tile/black/anticorner
	icon_state = "tile_anticorner"
	name = "black anticorner"

/obj/effect/turf_decal/tile/black/anticorner/contrasted
	icon_state = "tile_anticorner_contrasted"
	name = "contrasted black anticorner"

/obj/effect/turf_decal/tile/black/fourcorners/contrasted
	icon_state = "tile_fourcorners_contrasted"
	name = "black fourcorners"

/obj/effect/turf_decal/tile/black/fourcorners
	icon_state = "tile_fourcorners"
	name = "black full"

/obj/effect/turf_decal/tile/black/diagonal_centre
	icon_state = "diagonal_centre"
	name = "black diagonal centre"

/obj/effect/turf_decal/tile/black/diagonal_edge
	icon_state = "diagonal_edge"
	name = "black diagonal edge"

/obj/effect/turf_decal/tile/black/carat
	icon_state = "tile_carat"
	name = "black carat decal"

/obj/effect/turf_decal/tile/black/anticorner_ramp
	icon_state = "tile_anticorner_ramp"
	name = "black anticorner ramp"

/obj/effect/turf_decal/tile/black/anticorner_ramp/contrasted
	icon_state = "tile_anticorner_contrasted_ramp"
	name = "contrasted black anticorner ramp"

/// Green tiles

/obj/effect/turf_decal/tile/green
	name = "green corner"
	color = "#9FED58"

/obj/effect/turf_decal/tile/green/corner_ramp
	icon_state = "tile_corner_ramp"
	name = "green corner ramp"

/obj/effect/turf_decal/tile/green/corner_ramp/offset
	icon_state = "tile_corner_ramp_offset"
	name = "green corner ramp offset"

/obj/effect/turf_decal/tile/green/opposingcorners
	icon_state = "tile_opposing_corners"
	name = "opposing green corners"

/obj/effect/turf_decal/tile/green/half
	icon_state = "tile_half"
	name = "green half"

/obj/effect/turf_decal/tile/green/half/contrasted
	icon_state = "tile_half_contrasted"
	name = "contrasted green half"

/obj/effect/turf_decal/tile/green/anticorner
	icon_state = "tile_anticorner"
	name = "green anticorner"

/obj/effect/turf_decal/tile/green/anticorner/contrasted
	icon_state = "tile_anticorner_contrasted"
	name = "contrasted green anticorner"

/obj/effect/turf_decal/tile/green/fourcorners/contrasted
	icon_state = "tile_fourcorners_contrasted"
	name = "green fourcorners"

/obj/effect/turf_decal/tile/green/fourcorners
	icon_state = "tile_fourcorners"
	name = "green full"

/obj/effect/turf_decal/tile/green/diagonal_centre
	icon_state = "diagonal_centre"
	name = "green diagonal centre"

/obj/effect/turf_decal/tile/green/diagonal_edge
	icon_state = "diagonal_edge"
	name = "green diagonal edge"

/obj/effect/turf_decal/tile/green/carat
	icon_state = "tile_carat"
	name = "green carat decal"

/obj/effect/turf_decal/tile/green/anticorner_ramp
	icon_state = "tile_anticorner_ramp"
	name = "green anticorner ramp"

/obj/effect/turf_decal/tile/green/anticorner_ramp/contrasted
	icon_state = "tile_anticorner_contrasted_ramp"
	name = "contrasted green anticorner ramp"

/// Dark green tiles

/obj/effect/turf_decal/tile/dark_green
	name = "dark green corner"
	color = "#439C1E"

/obj/effect/turf_decal/tile/dark_green/corner_ramp
	icon_state = "tile_corner_ramp"
	name = "dark green corner ramp"

/obj/effect/turf_decal/tile/dark_green/corner_ramp/offset
	icon_state = "tile_corner_ramp_offset"
	name = "dark green corner ramp offset"

/obj/effect/turf_decal/tile/dark_green/opposingcorners
	icon_state = "tile_opposing_corners"
	name = "opposing dark green corners"

/obj/effect/turf_decal/tile/dark_green/half
	icon_state = "tile_half"
	name = "dark green half"

/obj/effect/turf_decal/tile/dark_green/half/contrasted
	icon_state = "tile_half_contrasted"
	name = "contrasted dark green half"

/obj/effect/turf_decal/tile/dark_green/anticorner
	icon_state = "tile_anticorner"
	name = "dark green anticorner"

/obj/effect/turf_decal/tile/dark_green/anticorner/contrasted
	icon_state = "tile_anticorner_contrasted"
	name = "contrasted dark green anticorner"

/obj/effect/turf_decal/tile/dark_green/fourcorners/contrasted
	icon_state = "tile_fourcorners_contrasted"
	name = "dark green fourcorners"

/obj/effect/turf_decal/tile/dark_green/fourcorners
	icon_state = "tile_fourcorners"
	name = "dark green full"

/obj/effect/turf_decal/tile/dark_green/diagonal_centre
	icon_state = "diagonal_centre"
	name = "dark green diagonal centre"

/obj/effect/turf_decal/tile/dark_green/diagonal_edge
	icon_state = "diagonal_edge"
	name = "dark green diagonal edge"

/obj/effect/turf_decal/tile/dark_green/carat
	icon_state = "tile_carat"
	name = "dark green carat decal"

/obj/effect/turf_decal/tile/dark_green/anticorner_ramp
	icon_state = "tile_anticorner_ramp"
	name = "dark green anticorner ramp"

/obj/effect/turf_decal/tile/dark_green/anticorner_ramp/contrasted
	icon_state = "tile_anticorner_contrasted_ramp"
	name = "contrasted dark green anticorner ramp"

/// Yellow tiles

/obj/effect/turf_decal/tile/yellow
	name = "yellow corner"
	color = "#EFB341"

/obj/effect/turf_decal/tile/yellow/corner_ramp
	icon_state = "tile_corner_ramp"
	name = "yellow corner ramp"

/obj/effect/turf_decal/tile/yellow/corner_ramp/offset
	icon_state = "tile_corner_ramp_offset"
	name = "yellow corner ramp offset"

/obj/effect/turf_decal/tile/yellow/opposingcorners
	icon_state = "tile_opposing_corners"
	name = "opposing yellow corners"

/obj/effect/turf_decal/tile/yellow/half
	icon_state = "tile_half"
	name = "yellow half"

/obj/effect/turf_decal/tile/yellow/half/contrasted
	icon_state = "tile_half_contrasted"
	name = "contrasted yellow half"

/obj/effect/turf_decal/tile/yellow/anticorner
	icon_state = "tile_anticorner"
	name = "yellow anticorner"

/obj/effect/turf_decal/tile/yellow/anticorner/contrasted
	icon_state = "tile_anticorner_contrasted"
	name = "contrasted yellow anticorner"

/obj/effect/turf_decal/tile/yellow/fourcorners/contrasted
	icon_state = "tile_fourcorners_contrasted"
	name = "yellow fourcorners"

/obj/effect/turf_decal/tile/yellow/fourcorners
	icon_state = "tile_fourcorners"
	name = "yellow full"

/obj/effect/turf_decal/tile/yellow/diagonal_centre
	icon_state = "diagonal_centre"
	name = "yellow diagonal centre"

/obj/effect/turf_decal/tile/yellow/diagonal_edge
	icon_state = "diagonal_edge"
	name = "yellow diagonal edge"

/obj/effect/turf_decal/tile/yellow/carat
	icon_state = "tile_carat"
	name = "yellow carat decal"

/obj/effect/turf_decal/tile/yellow/anticorner_ramp
	icon_state = "tile_anticorner_ramp"
	name = "yellow anticorner ramp"

/obj/effect/turf_decal/tile/yellow/anticorner_ramp/contrasted
	icon_state = "tile_anticorner_contrasted_ramp"
	name = "contrasted yellow anticorner ramp"

/// Red tiles

/obj/effect/turf_decal/tile/red
	name = "red corner"
	color = "#DE3A3A"

/obj/effect/turf_decal/tile/red/corner_ramp
	icon_state = "tile_corner_ramp"
	name = "red corner ramp"

/obj/effect/turf_decal/tile/red/corner_ramp/offset
	icon_state = "tile_corner_ramp_offset"
	name = "red corner ramp offset"

/obj/effect/turf_decal/tile/red/opposingcorners
	icon_state = "tile_opposing_corners"
	name = "opposing red corners"

/obj/effect/turf_decal/tile/red/half
	icon_state = "tile_half"
	name = "red half"

/obj/effect/turf_decal/tile/red/half/contrasted
	icon_state = "tile_half_contrasted"
	name = "contrasted red half"

/obj/effect/turf_decal/tile/red/anticorner
	icon_state = "tile_anticorner"
	name = "red anticorner"

/obj/effect/turf_decal/tile/red/anticorner/contrasted
	icon_state = "tile_anticorner_contrasted"
	name = "contrasted red anticorner"

/obj/effect/turf_decal/tile/red/fourcorners/contrasted
	icon_state = "tile_fourcorners_contrasted"
	name = "red fourcorners"

/obj/effect/turf_decal/tile/red/fourcorners
	icon_state = "tile_fourcorners"
	name = "red full"

/obj/effect/turf_decal/tile/red/diagonal_centre
	icon_state = "diagonal_centre"
	name = "red diagonal centre"

/obj/effect/turf_decal/tile/red/diagonal_edge
	icon_state = "diagonal_edge"
	name = "red diagonal edge"

/obj/effect/turf_decal/tile/red/carat
	icon_state = "tile_carat"
	name = "red carat decal"

/obj/effect/turf_decal/tile/red/anticorner_ramp
	icon_state = "tile_anticorner_ramp"
	name = "red anticorner ramp"

/obj/effect/turf_decal/tile/red/anticorner_ramp/contrasted
	icon_state = "tile_anticorner_contrasted_ramp"
	name = "contrasted red anticorner ramp"

/// Dark red tiles

/obj/effect/turf_decal/tile/dark_red
	name = "dark red corner"
	color = "#B11111"

/obj/effect/turf_decal/tile/dark_red/corner_ramp
	icon_state = "tile_corner_ramp"
	name = "dark red corner ramp"

/obj/effect/turf_decal/tile/dark_red/corner_ramp/offset
	icon_state = "tile_corner_ramp_offset"
	name = "dark red corner ramp_offset"

/obj/effect/turf_decal/tile/dark_red/opposingcorners
	icon_state = "tile_opposing_corners"
	name = "opposing dark_red corners"

/obj/effect/turf_decal/tile/dark_red/half
	icon_state = "tile_half"
	name = "dark red half"

/obj/effect/turf_decal/tile/dark_red/half/contrasted
	icon_state = "tile_half_contrasted"
	name = "contrasted dark red half"

/obj/effect/turf_decal/tile/dark_red/anticorner
	icon_state = "tile_anticorner"
	name = "dark red anticorner"

/obj/effect/turf_decal/tile/dark_red/anticorner/contrasted
	icon_state = "tile_anticorner_contrasted"
	name = "contrasted dark red anticorner"

/obj/effect/turf_decal/tile/dark_red/fourcorners/contrasted
	icon_state = "tile_fourcorners_contrasted"
	name = "dark red fourcorners"

/obj/effect/turf_decal/tile/dark_red/fourcorners
	icon_state = "tile_fourcorners"
	name = "dark red full"

/obj/effect/turf_decal/tile/dark_red/diagonal_centre
	icon_state = "diagonal_centre"
	name = "dark red diagonal centre"

/obj/effect/turf_decal/tile/dark_red/diagonal_edge
	icon_state = "diagonal_edge"
	name = "dark red diagonal edge"

/obj/effect/turf_decal/tile/dark_red/carat
	icon_state = "tile_carat"
	name = "dark red carat decal"

/obj/effect/turf_decal/tile/dark_red/anticorner_ramp
	icon_state = "tile_anticorner_ramp"
	name = "dark red anticorner ramp"

/obj/effect/turf_decal/tile/dark_red/anticorner_ramp/contrasted
	icon_state = "tile_anticorner_contrasted_ramp"
	name = "contrasted dark red anticorner ramp"

/// Bar tiles

/obj/effect/turf_decal/tile/bar
	name = "bar corner"
	color = "#791500"
	alpha = 130

/obj/effect/turf_decal/tile/bar/corner_ramp
	icon_state = "tile_corner_ramp"
	name = "bar corner ramp"

/obj/effect/turf_decal/tile/bar/corner_ramp/offset
	icon_state = "tile_corner_ramp_offset"
	name = "bar corner ramp_offset"

/obj/effect/turf_decal/tile/bar/opposingcorners
	icon_state = "tile_opposing_corners"
	name = "opposing bar corners"

/obj/effect/turf_decal/tile/bar/half
	icon_state = "tile_half"
	name = "bar half"

/obj/effect/turf_decal/tile/bar/half/contrasted
	icon_state = "tile_half_contrasted"
	name = "contrasted bar half"

/obj/effect/turf_decal/tile/bar/anticorner
	icon_state = "tile_anticorner"
	name = "bar anticorner"

/obj/effect/turf_decal/tile/bar/anticorner/contrasted
	icon_state = "tile_anticorner_contrasted"
	name = "contrasted bar anticorner"

/obj/effect/turf_decal/tile/bar/fourcorners/contrasted
	icon_state = "tile_fourcorners_contrasted"
	name = "bar fourcorners"

/obj/effect/turf_decal/tile/bar/fourcorners
	icon_state = "tile_fourcorners"
	name = "bar full"

/obj/effect/turf_decal/tile/bar/diagonal_centre
	icon_state = "diagonal_centre"
	name = "bar diagonal centre"

/obj/effect/turf_decal/tile/bar/diagonal_edge
	icon_state = "diagonal_edge"
	name = "bar diagonal edge"

/obj/effect/turf_decal/tile/bar/carat
	icon_state = "tile_carat"
	name = "bar carat decal"

/obj/effect/turf_decal/tile/bar/anticorner_ramp
	icon_state = "tile_anticorner_ramp"
	name = "bar anticorner ramp"

/obj/effect/turf_decal/tile/bar/anticorner_ramp/contrasted
	icon_state = "tile_anticorner_contrasted_ramp"
	name = "contrasted bar anticorner ramp"

/// Purple tiles

/obj/effect/turf_decal/tile/purple
	name = "purple corner"
	color = "#D381C9"

/obj/effect/turf_decal/tile/purple/corner_ramp
	icon_state = "tile_corner_ramp"
	name = "purple corner ramp"

/obj/effect/turf_decal/tile/purple/corner_ramp/offset
	icon_state = "tile_corner_ramp_offset"
	name = "purple corner ramp_offset"

/obj/effect/turf_decal/tile/purple/opposingcorners
	icon_state = "tile_opposing_corners"
	name = "opposing purple corners"

/obj/effect/turf_decal/tile/purple/half
	icon_state = "tile_half"
	name = "purple half"

/obj/effect/turf_decal/tile/purple/half/contrasted
	icon_state = "tile_half_contrasted"
	name = "contrasted purple half"

/obj/effect/turf_decal/tile/purple/anticorner
	icon_state = "tile_anticorner"
	name = "purple anticorner"

/obj/effect/turf_decal/tile/purple/anticorner/contrasted
	icon_state = "tile_anticorner_contrasted"
	name = "contrasted purple anticorner"

/obj/effect/turf_decal/tile/purple/fourcorners/contrasted
	icon_state = "tile_fourcorners_contrasted"
	name = "purple fourcorners"

/obj/effect/turf_decal/tile/purple/fourcorners
	icon_state = "tile_fourcorners"
	name = "purple full"

/obj/effect/turf_decal/tile/purple/diagonal_centre
	icon_state = "diagonal_centre"
	name = "purple diagonal centre"

/obj/effect/turf_decal/tile/purple/diagonal_edge
	icon_state = "diagonal_edge"
	name = "bar diagonal edge"

/obj/effect/turf_decal/tile/purple/carat
	icon_state = "tile_carat"
	name = "purple carat decal"

/obj/effect/turf_decal/tile/purple/anticorner_ramp
	icon_state = "tile_anticorner_ramp"
	name = "purple anticorner ramp"

/obj/effect/turf_decal/tile/purple/anticorner_ramp/contrasted
	icon_state = "tile_anticorner_contrasted_ramp"
	name = "contrasted purple anticorner ramp"

/// Brown tiles

/obj/effect/turf_decal/tile/brown
	name = "brown corner"
	color = "#A46106"

/obj/effect/turf_decal/tile/brown/corner_ramp
	icon_state = "tile_corner_ramp"
	name = "brown corner ramp"

/obj/effect/turf_decal/tile/brown/corner_ramp/offset
	icon_state = "tile_corner_ramp_offset"
	name = "brown corner ramp_offset"

/obj/effect/turf_decal/tile/brown/opposingcorners
	icon_state = "tile_opposing_corners"
	name = "opposing brown corners"

/obj/effect/turf_decal/tile/brown/half
	icon_state = "tile_half"
	name = "brown half"

/obj/effect/turf_decal/tile/brown/half/contrasted
	icon_state = "tile_half_contrasted"
	name = "contrasted brown half"

/obj/effect/turf_decal/tile/brown/anticorner
	icon_state = "tile_anticorner"
	name = "brown anticorner"
/obj/effect/turf_decal/tile/brown/anticorner/contrasted
	icon_state = "tile_anticorner_contrasted"
	name = "contrasted brown anticorner"

/obj/effect/turf_decal/tile/brown/fourcorners/contrasted
	icon_state = "tile_fourcorners_contrasted"
	name = "brown fourcorners"

/obj/effect/turf_decal/tile/brown/fourcorners
	icon_state = "tile_fourcorners"
	name = "brown full"

/obj/effect/turf_decal/tile/brown/diagonal_centre
	icon_state = "diagonal_centre"
	name = "brown diagonal centre"

/obj/effect/turf_decal/tile/brown/diagonal_edge
	icon_state = "diagonal_edge"
	name = "brown diagonal edge"

/obj/effect/turf_decal/tile/brown/carat
	icon_state = "tile_carat"
	name = "brown carat decal"

/obj/effect/turf_decal/tile/brown/anticorner_ramp
	icon_state = "tile_anticorner_ramp"
	name = "brown anticorner ramp"

/obj/effect/turf_decal/tile/brown/anticorner_ramp/contrasted
	icon_state = "tile_anticorner_contrasted_ramp"
	name = "contrasted brown anticorner ramp"

/// Neutral tiles

/obj/effect/turf_decal/tile/neutral
	name = "neutral corner"
	color = "#D4D4D4"
	alpha = 50

/obj/effect/turf_decal/tile/neutral/corner_ramp
	icon_state = "tile_corner_ramp"
	name = "neutral corner ramp"

/obj/effect/turf_decal/tile/neutral/corner_ramp/offset
	icon_state = "tile_corner_ramp_offset"
	name = "neutral corner ramp_offset"

/obj/effect/turf_decal/tile/neutral/opposingcorners
	icon_state = "tile_opposing_corners"
	name = "opposing neutral corners"

/obj/effect/turf_decal/tile/neutral/half
	icon_state = "tile_half"
	name = "neutral half"

/obj/effect/turf_decal/tile/neutral/half/contrasted
	icon_state = "tile_half_contrasted"
	name = "contrasted neutral half"

/obj/effect/turf_decal/tile/neutral/anticorner
	icon_state = "tile_anticorner"
	name = "neutral anticorner"

/obj/effect/turf_decal/tile/neutral/anticorner/contrasted
	icon_state = "tile_anticorner_contrasted"
	name = "contrasted neutral anticorner"

/obj/effect/turf_decal/tile/neutral/fourcorners/contrasted
	icon_state = "tile_fourcorners_contrasted"
	name = "neutral fourcorners"

/obj/effect/turf_decal/tile/neutral/fourcorners
	icon_state = "tile_fourcorners"
	name = "neutral full"

/obj/effect/turf_decal/tile/neutral/diagonal_centre
	icon_state = "diagonal_centre"
	name = "neutral diagonal centre"

/obj/effect/turf_decal/tile/neutral/diagonal_edge
	icon_state = "diagonal_edge"
	name = "neutral diagonal edge"

/obj/effect/turf_decal/tile/neutral/carat
	icon_state = "tile_carat"
	name = "neutral carat decal"

/obj/effect/turf_decal/tile/neutral/anticorner_ramp
	icon_state = "tile_anticorner_ramp"
	name = "neutral anticorner ramp"

/obj/effect/turf_decal/tile/neutral/anticorner_ramp/contrasted
	icon_state = "tile_anticorner_contrasted_ramp"
	name = "contrasted neutral anticorner ramp"

/// Dark tiles

/obj/effect/turf_decal/tile/dark
	name = "dark corner"
	color = "#0e0f0f"

/obj/effect/turf_decal/dark/white/corner_ramp
	icon_state = "dark_corner_ramp"
	name = "white corner ramp"

/obj/effect/turf_decal/tile/dark/opposingcorners
	icon_state = "tile_opposing_corners"
	name = "opposing dark corners"

/obj/effect/turf_decal/tile/dark/half
	icon_state = "tile_half"
	name = "dark half"

/obj/effect/turf_decal/tile/dark/half/contrasted
	icon_state = "tile_half_contrasted"
	name = "contrasted dark half"

/obj/effect/turf_decal/tile/dark/anticorner
	icon_state = "tile_anticorner"
	name = "dark anticorner"

/obj/effect/turf_decal/tile/dark/anticorner/contrasted
	icon_state = "tile_anticorner_contrasted"
	name = "contrasted dark anticorner"

/obj/effect/turf_decal/tile/dark/fourcorners/contrasted
	icon_state = "tile_fourcorners_contrasted"
	name = "dark fourcorners"

/obj/effect/turf_decal/tile/dark/fourcorners
	icon_state = "tile_fourcorners"
	name = "dark full"

/obj/effect/turf_decal/tile/dark/diagonal_centre
	icon_state = "diagonal_centre"
	name = "dark diagonal centre"

/obj/effect/turf_decal/tile/dark/diagonal_edge
	icon_state = "diagonal_edge"
	name = "dark diagonal edge"

/obj/effect/turf_decal/tile/dark/carat
	icon_state = "tile_carat"
	name = "dark carat decal"

/obj/effect/turf_decal/tile/dark/anticorner_ramp
	icon_state = "tile_anticorner_ramp"
	name = "dark anticorner ramp"

/obj/effect/turf_decal/tile/dark/anticorner_ramp/contrasted
	icon_state = "tile_anticorner_contrasted_ramp"
	name = "contrasted dark anticorner ramp"

/// Random tiles

/obj/effect/turf_decal/tile/random // so many colors
	name = "colorful corner"
	color = "#E300FF" //bright pink as default for mapping

/obj/effect/turf_decal/tile/random/corner_ramp
	icon_state = "tile_corner_ramp"
	name = "colorful corner ramp"

/obj/effect/turf_decal/tile/random/corner_ramp/offset
	icon_state = "tile_corner_ramp_offset"
	name = "colorful corner ramp_offset"

/obj/effect/turf_decal/tile/random/opposingcorners
	icon_state = "tile_opposing_corners"
	name = "opposing colorful corners"

/obj/effect/turf_decal/tile/random/half
	icon_state = "tile_half"
	name = "colorful half"

/obj/effect/turf_decal/tile/random/half/contrasted
	icon_state = "tile_half_contrasted"
	name = "contrasted colorful half"

/obj/effect/turf_decal/tile/random/anticorner
	icon_state = "tile_anticorner"
	name = "colorful anticorner"

/obj/effect/turf_decal/tile/random/anticorner/contrasted
	icon_state = "tile_anticorner_contrasted"
	name = "contrasted colorful anticorner"

/obj/effect/turf_decal/tile/random/fourcorners/contrasted
	icon_state = "tile_fourcorners_contrasted"
	name = "colorful fourcorners"

/obj/effect/turf_decal/tile/random/fourcorners
	icon_state = "tile_fourcorners"
	name = "colorful full"

/obj/effect/turf_decal/tile/random/diagonal_centre
	icon_state = "diagonal_centre"
	name = "colorful diagonal centre"

/obj/effect/turf_decal/tile/random/diagonal_edge
	icon_state = "diagonal_edge"
	name = "colorful diagonal edge"

/obj/effect/turf_decal/tile/random/carat
	icon_state = "tile_carat"
	name = "dark carat decal"

/obj/effect/turf_decal/tile/random/anticorner_ramp
	icon_state = "tile_anticorner_ramp"
	name = "colorful anticorner ramp"

/obj/effect/turf_decal/tile/random/anticorner_ramp/contrasted
	icon_state = "tile_anticorner_contrasted_ramp"
	name = "contrasted colorful anticorner ramp"

/obj/effect/turf_decal/tile/random/Initialize(mapload)
	color = "#[random_short_color()]"
	return ..()

/// Trimlines

/obj/effect/turf_decal/trimline
	layer = TURF_PLATING_DECAL_LAYER
	alpha = 110
	icon_state = "trimline_box"

/obj/effect/turf_decal/trimline/Initialize(mapload)
	if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
		color = "#[random_short_color()]"
	return ..()

/// White trimlines

/obj/effect/turf_decal/trimline/white
	color = "#FFFFFF"

/obj/effect/turf_decal/trimline/white/line
	name = "trim decal"
	icon_state = "trimline"

/obj/effect/turf_decal/trimline/white/corner
	icon_state = "trimline_corner"

/obj/effect/turf_decal/trimline/white/end
	icon_state = "trimline_end"

/obj/effect/turf_decal/trimline/white/arrow_cw
	icon_state = "trimline_arrow_cw"

/obj/effect/turf_decal/trimline/white/arrow_ccw
	icon_state = "trimline_arrow_ccw"

/obj/effect/turf_decal/trimline/white/warning
	icon_state = "trimline_warn"

/obj/effect/turf_decal/trimline/white/mid_joiner
	icon_state = "trimline_mid"

/obj/effect/turf_decal/trimline/white/filled
	icon_state = "trimline_box_fill"

/obj/effect/turf_decal/trimline/white/filled/line
	icon_state = "trimline_fill"

/obj/effect/turf_decal/trimline/white/filled/corner
	icon_state = "trimline_corner_fill"

/obj/effect/turf_decal/trimline/white/filled/end
	icon_state = "trimline_end_fill"

/obj/effect/turf_decal/trimline/white/filled/arrow_cw
	icon_state = "trimline_arrow_cw_fill"

/obj/effect/turf_decal/trimline/white/filled/arrow_ccw
	icon_state = "trimline_arrow_ccw_fill"

/obj/effect/turf_decal/trimline/white/filled/warning
	icon_state = "trimline_warn_fill"

/obj/effect/turf_decal/trimline/white/filled/mid_joiner
	icon_state = "trimline_mid_fill"

/obj/effect/turf_decal/trimline/white/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/white/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"

/// Red trimlines

/obj/effect/turf_decal/trimline/red
	color = "#DE3A3A"

/obj/effect/turf_decal/trimline/red/line
	icon_state = "trimline"

/obj/effect/turf_decal/trimline/red/corner
	icon_state = "trimline_corner"

/obj/effect/turf_decal/trimline/red/end
	icon_state = "trimline_end"

/obj/effect/turf_decal/trimline/red/arrow_cw
	icon_state = "trimline_arrow_cw"

/obj/effect/turf_decal/trimline/red/arrow_ccw
	icon_state = "trimline_arrow_ccw"

/obj/effect/turf_decal/trimline/red/warning
	icon_state = "trimline_warn"

/obj/effect/turf_decal/trimline/red/mid_joiner
	icon_state = "trimline_mid"

/obj/effect/turf_decal/trimline/red/filled
	icon_state = "trimline_box_fill"

/obj/effect/turf_decal/trimline/red/filled/line
	icon_state = "trimline_fill"

/obj/effect/turf_decal/trimline/red/filled/corner
	icon_state = "trimline_corner_fill"

/obj/effect/turf_decal/trimline/red/filled/end
	icon_state = "trimline_end_fill"

/obj/effect/turf_decal/trimline/red/filled/arrow_cw
	icon_state = "trimline_arrow_cw_fill"

/obj/effect/turf_decal/trimline/red/filled/arrow_ccw
	icon_state = "trimline_arrow_ccw_fill"

/obj/effect/turf_decal/trimline/red/filled/warning
	icon_state = "trimline_warn_fill"

/obj/effect/turf_decal/trimline/red/filled/mid_joiner
	icon_state = "trimline_mid_fill"

/obj/effect/turf_decal/trimline/red/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/red/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"

/// Dark red trimlines

/obj/effect/turf_decal/trimline/dark_red
	color = "#B11111"

/obj/effect/turf_decal/trimline/dark_red/line
	icon_state = "trimline"

/obj/effect/turf_decal/trimline/dark_red/corner
	icon_state = "trimline_corner"

/obj/effect/turf_decal/trimline/dark_red/end
	icon_state = "trimline_end"

/obj/effect/turf_decal/trimline/dark_red/arrow_cw
	icon_state = "trimline_arrow_cw"

/obj/effect/turf_decal/trimline/dark_red/arrow_ccw
	icon_state = "trimline_arrow_ccw"

/obj/effect/turf_decal/trimline/dark_red/warning
	icon_state = "trimline_warn"

/obj/effect/turf_decal/trimline/dark_red/mid_joiner
	icon_state = "trimline_mid"

/obj/effect/turf_decal/trimline/dark_red/filled
	icon_state = "trimline_box_fill"

/obj/effect/turf_decal/trimline/dark_red/filled/line
	icon_state = "trimline_fill"

/obj/effect/turf_decal/trimline/dark_red/filled/corner
	icon_state = "trimline_corner_fill"

/obj/effect/turf_decal/trimline/dark_red/filled/end
	icon_state = "trimline_end_fill"

/obj/effect/turf_decal/trimline/dark_red/filled/arrow_cw
	icon_state = "trimline_arrow_cw_fill"

/obj/effect/turf_decal/trimline/dark_red/filled/arrow_ccw
	icon_state = "trimline_arrow_ccw_fill"

/obj/effect/turf_decal/trimline/dark_red/filled/warning
	icon_state = "trimline_warn_fill"

/obj/effect/turf_decal/trimline/dark_red/filled/mid_joiner
	icon_state = "trimline_mid_fill"

/obj/effect/turf_decal/trimline/dark_red/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/dark_red/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"

/// Green trimlines

/obj/effect/turf_decal/trimline/green
	color = "#9FED58"

/obj/effect/turf_decal/trimline/green/line
	icon_state = "trimline"

/obj/effect/turf_decal/trimline/green/corner
	icon_state = "trimline_corner"

/obj/effect/turf_decal/trimline/green/end
	icon_state = "trimline_end"

/obj/effect/turf_decal/trimline/green/arrow_cw
	icon_state = "trimline_arrow_cw"

/obj/effect/turf_decal/trimline/green/arrow_ccw
	icon_state = "trimline_arrow_ccw"

/obj/effect/turf_decal/trimline/green/warning
	icon_state = "trimline_warn"

/obj/effect/turf_decal/trimline/green/mid_joiner
	icon_state = "trimline_mid"

/obj/effect/turf_decal/trimline/green/filled
	icon_state = "trimline_box_fill"

/obj/effect/turf_decal/trimline/green/filled/line
	icon_state = "trimline_fill"

/obj/effect/turf_decal/trimline/green/filled/corner
	icon_state = "trimline_corner_fill"

/obj/effect/turf_decal/trimline/green/filled/end
	icon_state = "trimline_end_fill"

/obj/effect/turf_decal/trimline/green/filled/arrow_cw
	icon_state = "trimline_arrow_cw_fill"

/obj/effect/turf_decal/trimline/green/filled/arrow_ccw
	icon_state = "trimline_arrow_ccw_fill"

/obj/effect/turf_decal/trimline/green/filled/warning
	icon_state = "trimline_warn_fill"

/obj/effect/turf_decal/trimline/green/filled/mid_joiner
	icon_state = "trimline_mid_fill"

/obj/effect/turf_decal/trimline/green/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/green/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"

/// Dark green Trimlines

/obj/effect/turf_decal/trimline/dark_green
	color = "#439C1E"

/obj/effect/turf_decal/trimline/dark_green/line
	icon_state = "trimline"

/obj/effect/turf_decal/trimline/dark_green/corner
	icon_state = "trimline_corner"

/obj/effect/turf_decal/trimline/dark_green/end
	icon_state = "trimline_end"

/obj/effect/turf_decal/trimline/dark_green/arrow_cw
	icon_state = "trimline_arrow_cw"

/obj/effect/turf_decal/trimline/dark_green/arrow_ccw
	icon_state = "trimline_arrow_ccw"

/obj/effect/turf_decal/trimline/dark_green/warning
	icon_state = "trimline_warn"

/obj/effect/turf_decal/trimline/dark_green/mid_joiner
	icon_state = "trimline_mid"

/obj/effect/turf_decal/trimline/dark_green/filled
	icon_state = "trimline_box_fill"

/obj/effect/turf_decal/trimline/dark_green/filled/line
	icon_state = "trimline_fill"

/obj/effect/turf_decal/trimline/dark_green/filled/corner
	icon_state = "trimline_corner_fill"

/obj/effect/turf_decal/trimline/dark_green/filled/end
	icon_state = "trimline_end_fill"

/obj/effect/turf_decal/trimline/dark_green/filled/arrow_cw
	icon_state = "trimline_arrow_cw_fill"

/obj/effect/turf_decal/trimline/dark_green/filled/arrow_ccw
	icon_state = "trimline_arrow_ccw_fill"

/obj/effect/turf_decal/trimline/dark_green/filled/warning
	icon_state = "trimline_warn_fill"

/obj/effect/turf_decal/trimline/dark_green/filled/mid_joiner
	icon_state = "trimline_mid_fill"

/obj/effect/turf_decal/trimline/dark_green/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/dark_green/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"

/// Blue trimlines

/obj/effect/turf_decal/trimline/blue
	color = "#52B4E9"

/obj/effect/turf_decal/trimline/blue/line
	icon_state = "trimline"

/obj/effect/turf_decal/trimline/blue/corner
	icon_state = "trimline_corner"

/obj/effect/turf_decal/trimline/blue/end
	icon_state = "trimline_end"

/obj/effect/turf_decal/trimline/blue/arrow_cw
	icon_state = "trimline_arrow_cw"

/obj/effect/turf_decal/trimline/blue/arrow_ccw
	icon_state = "trimline_arrow_ccw"

/obj/effect/turf_decal/trimline/blue/warning
	icon_state = "trimline_warn"

/obj/effect/turf_decal/trimline/blue/mid_joiner
	icon_state = "trimline_mid"

/obj/effect/turf_decal/trimline/blue/filled
	icon_state = "trimline_box_fill"

/obj/effect/turf_decal/trimline/blue/filled/line
	icon_state = "trimline_fill"

/obj/effect/turf_decal/trimline/blue/filled/corner
	icon_state = "trimline_corner_fill"

/obj/effect/turf_decal/trimline/blue/filled/end
	icon_state = "trimline_end_fill"

/obj/effect/turf_decal/trimline/blue/filled/arrow_cw
	icon_state = "trimline_arrow_cw_fill"

/obj/effect/turf_decal/trimline/blue/filled/arrow_ccw
	icon_state = "trimline_arrow_ccw_fill"

/obj/effect/turf_decal/trimline/blue/filled/warning
	icon_state = "trimline_warn_fill"

/obj/effect/turf_decal/trimline/blue/filled/mid_joiner
	icon_state = "trimline_mid_fill"

/obj/effect/turf_decal/trimline/blue/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/blue/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"

/// Dark blue trimlines

/obj/effect/turf_decal/trimline/dark_blue
	color = "#486091"

/obj/effect/turf_decal/trimline/dark_blue/line
	icon_state = "trimline"

/obj/effect/turf_decal/trimline/dark_blue/corner
	icon_state = "trimline_corner"

/obj/effect/turf_decal/trimline/dark_blue/end
	icon_state = "trimline_end"

/obj/effect/turf_decal/trimline/dark_blue/arrow_cw
	icon_state = "trimline_arrow_cw"

/obj/effect/turf_decal/trimline/dark_blue/arrow_ccw
	icon_state = "trimline_arrow_ccw"

/obj/effect/turf_decal/trimline/dark_blue/warning
	icon_state = "trimline_warn"

/obj/effect/turf_decal/trimline/dark_blue/mid_joiner
	icon_state = "trimline_mid"

/obj/effect/turf_decal/trimline/dark_blue/filled
	icon_state = "trimline_box_fill"

/obj/effect/turf_decal/trimline/dark_blue/filled/line
	icon_state = "trimline_fill"

/obj/effect/turf_decal/trimline/dark_blue/filled/corner
	icon_state = "trimline_corner_fill"

/obj/effect/turf_decal/trimline/dark_blue/filled/end
	icon_state = "trimline_end_fill"

/obj/effect/turf_decal/trimline/dark_blue/filled/arrow_cw
	icon_state = "trimline_arrow_cw_fill"

/obj/effect/turf_decal/trimline/dark_blue/filled/arrow_ccw
	icon_state = "trimline_arrow_ccw_fill"

/obj/effect/turf_decal/trimline/dark_blue/filled/warning
	icon_state = "trimline_warn_fill"

/obj/effect/turf_decal/trimline/dark_blue/filled/mid_joiner
	icon_state = "trimline_mid_fill"

/obj/effect/turf_decal/trimline/dark_blue/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/dark_blue/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"

/// Yellow trimlines

/obj/effect/turf_decal/trimline/yellow
	color = "#EFB341"

/obj/effect/turf_decal/trimline/yellow/line
	icon_state = "trimline"

/obj/effect/turf_decal/trimline/yellow/corner
	icon_state = "trimline_corner"

/obj/effect/turf_decal/trimline/yellow/end
	icon_state = "trimline_end"

/obj/effect/turf_decal/trimline/yellow/arrow_cw
	icon_state = "trimline_arrow_cw"

/obj/effect/turf_decal/trimline/yellow/arrow_ccw
	icon_state = "trimline_arrow_ccw"

/obj/effect/turf_decal/trimline/yellow/warning
	icon_state = "trimline_warn"

/obj/effect/turf_decal/trimline/yellow/mid_joiner
	icon_state = "trimline_mid"

/obj/effect/turf_decal/trimline/yellow/filled
	icon_state = "trimline_box_fill"

/obj/effect/turf_decal/trimline/yellow/filled/line
	icon_state = "trimline_fill"

/obj/effect/turf_decal/trimline/yellow/filled/corner
	icon_state = "trimline_corner_fill"

/obj/effect/turf_decal/trimline/yellow/filled/end
	icon_state = "trimline_end_fill"

/obj/effect/turf_decal/trimline/yellow/filled/arrow_cw
	icon_state = "trimline_arrow_cw_fill"

/obj/effect/turf_decal/trimline/yellow/filled/arrow_ccw
	icon_state = "trimline_arrow_ccw_fill"

/obj/effect/turf_decal/trimline/yellow/filled/warning
	icon_state = "trimline_warn_fill"

/obj/effect/turf_decal/trimline/yellow/filled/mid_joiner
	icon_state = "trimline_mid_fill"

/obj/effect/turf_decal/trimline/yellow/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/yellow/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"

/// Purple trimlines

/obj/effect/turf_decal/trimline/purple
	color = "#D381C9"

/obj/effect/turf_decal/trimline/purple/line
	icon_state = "trimline"

/obj/effect/turf_decal/trimline/purple/corner
	icon_state = "trimline_corner"

/obj/effect/turf_decal/trimline/purple/end
	icon_state = "trimline_end"

/obj/effect/turf_decal/trimline/purple/arrow_cw
	icon_state = "trimline_arrow_cw"

/obj/effect/turf_decal/trimline/purple/arrow_ccw
	icon_state = "trimline_arrow_ccw"

/obj/effect/turf_decal/trimline/purple/warning
	icon_state = "trimline_warn"

/obj/effect/turf_decal/trimline/purple/mid_joiner
	icon_state = "trimline_mid"

/obj/effect/turf_decal/trimline/purple/filled
	icon_state = "trimline_box_fill"

/obj/effect/turf_decal/trimline/purple/filled/line
	icon_state = "trimline_fill"

/obj/effect/turf_decal/trimline/purple/filled/corner
	icon_state = "trimline_corner_fill"

/obj/effect/turf_decal/trimline/purple/filled/end
	icon_state = "trimline_end_fill"

/obj/effect/turf_decal/trimline/purple/filled/arrow_cw
	icon_state = "trimline_arrow_cw_fill"

/obj/effect/turf_decal/trimline/purple/filled/arrow_ccw
	icon_state = "trimline_arrow_ccw_fill"

/obj/effect/turf_decal/trimline/purple/filled/warning
	icon_state = "trimline_warn_fill"

/obj/effect/turf_decal/trimline/purple/filled/mid_joiner
	icon_state = "trimline_mid_fill"

/obj/effect/turf_decal/trimline/purple/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/purple/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"

/// Brown trimlines

/obj/effect/turf_decal/trimline/brown
	color = "#A46106"

/obj/effect/turf_decal/trimline/brown/line
	icon_state = "trimline"

/obj/effect/turf_decal/trimline/brown/corner
	icon_state = "trimline_corner"

/obj/effect/turf_decal/trimline/brown/end
	icon_state = "trimline_end"

/obj/effect/turf_decal/trimline/brown/arrow_cw
	icon_state = "trimline_arrow_cw"

/obj/effect/turf_decal/trimline/brown/arrow_ccw
	icon_state = "trimline_arrow_ccw"

/obj/effect/turf_decal/trimline/brown/warning
	icon_state = "trimline_warn"

/obj/effect/turf_decal/trimline/brown/mid_joiner
	icon_state = "trimline_mid"

/obj/effect/turf_decal/trimline/brown/filled
	icon_state = "trimline_box_fill"

/obj/effect/turf_decal/trimline/brown/filled/line
	icon_state = "trimline_fill"

/obj/effect/turf_decal/trimline/brown/filled/corner
	icon_state = "trimline_corner_fill"

/obj/effect/turf_decal/trimline/brown/filled/end
	icon_state = "trimline_end_fill"

/obj/effect/turf_decal/trimline/brown/filled/arrow_cw
	icon_state = "trimline_arrow_cw_fill"

/obj/effect/turf_decal/trimline/brown/filled/arrow_ccw
	icon_state = "trimline_arrow_ccw_fill"

/obj/effect/turf_decal/trimline/brown/filled/warning
	icon_state = "trimline_warn_fill"

/obj/effect/turf_decal/trimline/brown/filled/mid_joiner
	icon_state = "trimline_mid_fill"

/obj/effect/turf_decal/trimline/brown/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/brown/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"

/// Neutral trimlines

/obj/effect/turf_decal/trimline/neutral
	color = "#D4D4D4"
	alpha = 50

/obj/effect/turf_decal/trimline/neutral/line
	icon_state = "trimline"

/obj/effect/turf_decal/trimline/neutral/corner
	icon_state = "trimline_corner"

/obj/effect/turf_decal/trimline/neutral/end
	icon_state = "trimline_end"

/obj/effect/turf_decal/trimline/neutral/arrow_cw
	icon_state = "trimline_arrow_cw"

/obj/effect/turf_decal/trimline/neutral/arrow_ccw
	icon_state = "trimline_arrow_ccw"

/obj/effect/turf_decal/trimline/neutral/warning
	icon_state = "trimline_warn"

/obj/effect/turf_decal/trimline/neutral/mid_joiner
	icon_state = "trimline_mid"

/obj/effect/turf_decal/trimline/neutral/filled
	icon_state = "trimline_box_fill"

/obj/effect/turf_decal/trimline/neutral/filled/line
	icon_state = "trimline_fill"

/obj/effect/turf_decal/trimline/neutral/filled/corner
	icon_state = "trimline_corner_fill"

/obj/effect/turf_decal/trimline/neutral/filled/end
	icon_state = "trimline_end_fill"

/obj/effect/turf_decal/trimline/neutral/filled/arrow_cw
	icon_state = "trimline_arrow_cw_fill"

/obj/effect/turf_decal/trimline/neutral/filled/arrow_ccw
	icon_state = "trimline_arrow_ccw_fill"

/obj/effect/turf_decal/trimline/neutral/filled/warning
	icon_state = "trimline_warn_fill"

/obj/effect/turf_decal/trimline/neutral/filled/mid_joiner
	icon_state = "trimline_mid_fill"

/obj/effect/turf_decal/trimline/neutral/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/neutral/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"

/// Dark trimlines

/obj/effect/turf_decal/trimline/dark
	color = "#0e0f0f"

/obj/effect/turf_decal/trimline/dark/line
	icon_state = "trimline"

/obj/effect/turf_decal/trimline/dark/corner
	icon_state = "trimline_corner"

/obj/effect/turf_decal/trimline/dark/end
	icon_state = "trimline_end"

/obj/effect/turf_decal/trimline/dark/arrow_cw
	icon_state = "trimline_arrow_cw"

/obj/effect/turf_decal/trimline/dark/arrow_ccw
	icon_state = "trimline_arrow_ccw"

/obj/effect/turf_decal/trimline/dark/warning
	icon_state = "trimline_warn"

/obj/effect/turf_decal/trimline/dark/mid_joiner
	icon_state = "trimline_mid"

/obj/effect/turf_decal/trimline/dark/filled
	icon_state = "trimline_box_fill"

/obj/effect/turf_decal/trimline/dark/filled/line
	icon_state = "trimline_fill"

/obj/effect/turf_decal/trimline/dark/filled/corner
	icon_state = "trimline_corner_fill"

/obj/effect/turf_decal/trimline/dark/filled/end
	icon_state = "trimline_end_fill"

/obj/effect/turf_decal/trimline/dark/filled/arrow_cw
	icon_state = "trimline_arrow_cw_fill"

/obj/effect/turf_decal/trimline/dark/filled/arrow_ccw
	icon_state = "trimline_arrow_ccw_fill"

/obj/effect/turf_decal/trimline/dark/filled/warning
	icon_state = "trimline_warn_fill"

/obj/effect/turf_decal/trimline/dark/filled/mid_joiner
	icon_state = "trimline_mid_fill"

/obj/effect/turf_decal/trimline/dark/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/dark/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"

/// Black trimlines

/obj/effect/turf_decal/trimline/black
	color = "#000000"

/obj/effect/turf_decal/trimline/black/line
	name = "trim decal"
	icon_state = "trimline"

/obj/effect/turf_decal/trimline/black/corner
	icon_state = "trimline_corner"

/obj/effect/turf_decal/trimline/black/end
	icon_state = "trimline_end"

/obj/effect/turf_decal/trimline/black/arrow_cw
	icon_state = "trimline_arrow_cw"

/obj/effect/turf_decal/trimline/black/arrow_ccw
	icon_state = "trimline_arrow_ccw"

/obj/effect/turf_decal/trimline/black/warning
	icon_state = "trimline_warn"

/obj/effect/turf_decal/trimline/black/mid_joiner
	icon_state = "trimline_mid"

/obj/effect/turf_decal/trimline/black/filled
	icon_state = "trimline_box_fill"

/obj/effect/turf_decal/trimline/black/filled/line
	icon_state = "trimline_fill"

/obj/effect/turf_decal/trimline/black/filled/corner
	icon_state = "trimline_corner_fill"

/obj/effect/turf_decal/trimline/black/filled/end
	icon_state = "trimline_end_fill"

/obj/effect/turf_decal/trimline/black/filled/arrow_cw
	icon_state = "trimline_arrow_cw_fill"

/obj/effect/turf_decal/trimline/black/filled/arrow_ccw
	icon_state = "trimline_arrow_ccw_fill"

/obj/effect/turf_decal/trimline/black/filled/warning
	icon_state = "trimline_warn_fill"

/obj/effect/turf_decal/trimline/black/filled/mid_joiner
	icon_state = "trimline_mid_fill"

/obj/effect/turf_decal/trimline/black/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/black/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"
