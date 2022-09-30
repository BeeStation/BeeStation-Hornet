/obj/effect/turf_decal/tile
	name = "tile decal"
	icon_state = "tile_corner"
	layer = TURF_PLATING_DECAL_LAYER
	alpha = 110

/obj/effect/turf_decal/tile/Initialize(mapload)
	if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
		color = "#[random_short_color()]"
	. = ..()

/obj/effect/turf_decal/tile/blue
	name = "blue corner"
	color = "#52B4E9"

/obj/effect/turf_decal/tile/blue/tile_marquee
	name = "blue marquee"
	icon_state = "tile_marquee"

/obj/effect/turf_decal/tile/blue/tile_side
	name = "blue side"
	icon_state = "tile_side"

/obj/effect/turf_decal/tile/blue/tile_full
	name = "blue tile"
	icon_state = "tile_full"

/obj/effect/turf_decal/tile/blue/flat_side
	name = "blue flat side"
	icon_state = "flat_side"

/obj/effect/turf_decal/tile/blue/flat_full
	name = "blue flat"
	icon_state = "flat_full"

/obj/effect/turf_decal/tile/white
	name = "white corner"
	color = "#ffffff"

/obj/effect/turf_decal/tile/white/tile_marquee
	name = "white marquee"
	icon_state = "tile_marquee"

/obj/effect/turf_decal/tile/white/tile_side
	name = "white side"
	icon_state = "tile_side"

/obj/effect/turf_decal/tile/white/tile_full
	name = "white tile"
	icon_state = "tile_full"

/obj/effect/turf_decal/tile/white/flat_side
	name = "white flat side"
	icon_state = "flat_side"

/obj/effect/turf_decal/tile/white/flat_full
	name = "white flat"
	icon_state = "flat_full"

/obj/effect/turf_decal/tile/black
	name = "black corner"
	color = "#000000"

/obj/effect/turf_decal/tile/black/tile_marquee
	name = "black marquee"
	icon_state = "tile_marquee"

/obj/effect/turf_decal/tile/black/tile_side
	name = "black side"
	icon_state = "tile_side"

/obj/effect/turf_decal/tile/black/tile_full
	name = "black tile"
	icon_state = "tile_full"

/obj/effect/turf_decal/tile/black/flat_side
	name = "black flat side"
	icon_state = "flat_side"

/obj/effect/turf_decal/tile/black/flat_full
	name = "black flat"
	icon_state = "flat_full"

/obj/effect/turf_decal/tile/green
	name = "green corner"
	color = "#9FED58"

/obj/effect/turf_decal/tile/green/tile_marquee
	name = "green marquee"
	icon_state = "tile_marquee"

/obj/effect/turf_decal/tile/green/tile_side
	name = "green side"
	icon_state = "tile_side"

/obj/effect/turf_decal/tile/green/tile_full
	name = "green tile"
	icon_state = "tile_full"

/obj/effect/turf_decal/tile/green/flat_side
	name = "green flat side"
	icon_state = "flat_side"

/obj/effect/turf_decal/tile/green/flat_full
	name = "green flat"
	icon_state = "flat_full"

/obj/effect/turf_decal/tile/yellow
	name = "yellow corner"
	color = "#EFB341"

/obj/effect/turf_decal/tile/yellow/tile_marquee
	name = "yellow marquee"
	icon_state = "tile_marquee"

/obj/effect/turf_decal/tile/yellow/tile_side
	name = "yellow side"
	icon_state = "tile_side"

/obj/effect/turf_decal/tile/yellow/tile_full
	name = "yellow tile"
	icon_state = "tile_full"

/obj/effect/turf_decal/tile/yellow/flat_side
	name = "yellow flat side"
	icon_state = "flat_side"

/obj/effect/turf_decal/tile/yellow/flat_full
	name = "yellow flat"
	icon_state = "flat_full"

/obj/effect/turf_decal/tile/red
	name = "red corner"
	color = "#DE3A3A"

/obj/effect/turf_decal/tile/red/tile_marquee
	name = "red marquee"
	icon_state = "tile_marquee"

/obj/effect/turf_decal/tile/red/tile_side
	name = "red side"
	icon_state = "tile_side"

/obj/effect/turf_decal/tile/red/tile_full
	name = "red tile"
	icon_state = "tile_full"

/obj/effect/turf_decal/tile/red/flat_side
	name = "red flat side"
	icon_state = "flat_side"

/obj/effect/turf_decal/tile/red/flat_full
	name = "red flat"
	icon_state = "flat_full"

/obj/effect/turf_decal/tile/bar
	name = "bar corner"
	color = "#791500"
	alpha = 130

/obj/effect/turf_decal/tile/bar/tile_marquee
	name = "bar marquee"
	icon_state = "tile_marquee"

/obj/effect/turf_decal/tile/bar/tile_side
	name = "bar side"
	icon_state = "tile_side"

/obj/effect/turf_decal/tile/bar/tile_full
	name = "bar tile"
	icon_state = "tile_full"

/obj/effect/turf_decal/tile/bar/flat_side
	name = "bar flat side"
	icon_state = "flat_side"

/obj/effect/turf_decal/tile/bar/flat_full
	name = "bar flat"
	icon_state = "flat_full"

/obj/effect/turf_decal/tile/purple
	name = "purple corner"
	color = "#D381C9"

/obj/effect/turf_decal/tile/purple/tile_marquee
	name = "purple marquee"
	icon_state = "tile_marquee"

/obj/effect/turf_decal/tile/purple/tile_side
	name = "purple side"
	icon_state = "tile_side"

/obj/effect/turf_decal/tile/purple/tile_full
	name = "purple tile"
	icon_state = "tile_full"

/obj/effect/turf_decal/tile/purple/flat_side
	name = "purple flat side"
	icon_state = "flat_side"

/obj/effect/turf_decal/tile/purple/flat_full
	name = "purple flat"
	icon_state = "flat_full"

/obj/effect/turf_decal/tile/brown
	name = "brown corner"
	color = "#A46106"

/obj/effect/turf_decal/tile/brown/tile_marquee
	name = "brown marquee"
	icon_state = "tile_marquee"

/obj/effect/turf_decal/tile/brown/tile_side
	name = "brown side"
	icon_state = "tile_side"

/obj/effect/turf_decal/tile/brown/tile_full
	name = "brown tile"
	icon_state = "tile_full"

/obj/effect/turf_decal/tile/brown/flat_side
	name = "brown flat side"
	icon_state = "flat_side"

/obj/effect/turf_decal/tile/brown/flat_full
	name = "brown flat"
	icon_state = "flat_full"

/obj/effect/turf_decal/tile/darkblue
	name = "dark blue corner"
	color = "#334E6D"

/obj/effect/turf_decal/tile/darkblue/tile_marquee
	name = "dark blue marquee"
	icon_state = "tile_marquee"

/obj/effect/turf_decal/tile/darkblue/tile_side
	name = "dark blue side"
	icon_state = "tile_side"

/obj/effect/turf_decal/tile/darkblue/tile_full
	name = "dark blue tile"
	icon_state = "tile_full"

/obj/effect/turf_decal/tile/darkblue/flat_side
	name = "darkblue flat side"
	icon_state = "flat_side"

/obj/effect/turf_decal/tile/darkblue/flat_full
	name = "darkblue flat"
	icon_state = "flat_full"

/obj/effect/turf_decal/tile/neutral
	name = "neutral corner"
	color = "#D4D4D4"
	alpha = 50

/obj/effect/turf_decal/tile/neutral/tile_marquee
	name = "neutral marquee"
	icon_state = "tile_marquee"

/obj/effect/turf_decal/tile/neutral/tile_side
	name = "neutral side"
	icon_state = "tile_side"

/obj/effect/turf_decal/tile/neutral/tile_full
	name = "neutral tile"
	icon_state = "tile_full"

/obj/effect/turf_decal/tile/neutral/flat_side
	name = "neutral flat side"
	icon_state = "flat_side"

/obj/effect/turf_decal/tile/neutral/flat_full
	name = "neutral flat"
	icon_state = "flat_full"

/obj/effect/turf_decal/tile/random // so many colors
	name = "colorful corner"
	color = "#E300FF" //bright pink as default for mapping

/obj/effect/turf_decal/tile/random/tile_marquee
	name = "colorful marquee"
	icon_state = "tile_marquee"

/obj/effect/turf_decal/tile/random/tile_side
	name = "colorful side"
	icon_state = "tile_side"

/obj/effect/turf_decal/tile/random/tile_full
	name = "colorful tile"
	icon_state = "tile_full"

/obj/effect/turf_decal/tile/random/flat_side
	name = "colorful flat side"
	icon_state = "flat_side"

/obj/effect/turf_decal/tile/random/flat_full
	name = "colorful flat"
	icon_state = "flat_full"

/obj/effect/turf_decal/tile/random/Initialize(mapload)
	color = "#[random_short_color()]"
	. = ..()

/obj/effect/turf_decal/trimline
	layer = TURF_PLATING_DECAL_LAYER
	alpha = 110
	icon_state = "trimline_box"

/obj/effect/turf_decal/trimline/Initialize(mapload)
	if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
		color = "#[random_short_color()]"
	. = ..()

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

/obj/effect/turf_decal/trimline/white/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/white/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"

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

/obj/effect/turf_decal/trimline/red/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/red/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"

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

/obj/effect/turf_decal/trimline/green/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/green/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"

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

/obj/effect/turf_decal/trimline/blue/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/blue/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"

/obj/effect/turf_decal/trimline/black
	color = "#000000"

/obj/effect/turf_decal/trimline/black/line
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

/obj/effect/turf_decal/trimline/black/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/black/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"

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

/obj/effect/turf_decal/trimline/yellow/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/yellow/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"

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

/obj/effect/turf_decal/trimline/purple/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/purple/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"

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

/obj/effect/turf_decal/trimline/brown/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/brown/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"

/obj/effect/turf_decal/trimline/darkblue
	color = "#334E6D"
	alpha = 150

/obj/effect/turf_decal/trimline/darkblue/line
	icon_state = "trimline"

/obj/effect/turf_decal/trimline/darkblue/corner
	icon_state = "trimline_corner"

/obj/effect/turf_decal/trimline/darkblue/end
	icon_state = "trimline_end"

/obj/effect/turf_decal/trimline/darkblue/arrow_cw
	icon_state = "trimline_arrow_cw"

/obj/effect/turf_decal/trimline/darkblue/arrow_ccw
	icon_state = "trimline_arrow_ccw"

/obj/effect/turf_decal/trimline/darkblue/warning
	icon_state = "trimline_warn"

/obj/effect/turf_decal/trimline/darkblue/filled
	icon_state = "trimline_box_fill"

/obj/effect/turf_decal/trimline/darkblue/filled/line
	icon_state = "trimline_fill"

/obj/effect/turf_decal/trimline/darkblue/filled/corner
	icon_state = "trimline_corner_fill"

/obj/effect/turf_decal/trimline/darkblue/filled/end
	icon_state = "trimline_end_fill"

/obj/effect/turf_decal/trimline/darkblue/filled/arrow_cw
	icon_state = "trimline_arrow_cw_fill"

/obj/effect/turf_decal/trimline/darkblue/filled/arrow_ccw
	icon_state = "trimline_arrow_ccw_fill"

/obj/effect/turf_decal/trimline/darkblue/filled/warning
	icon_state = "trimline_warn_fill"

/obj/effect/turf_decal/trimline/darkblue/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/darkblue/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"

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

/obj/effect/turf_decal/trimline/neutral/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/neutral/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"
