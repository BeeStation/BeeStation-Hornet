/obj/effect/turf_decal/guideline
	name = "guideline decal"
	icon_state = "tile_corner"
	layer = TURF_PLATING_DECAL_LAYER
	alpha = 180
	pixel_x = 0
	pixel_y = 0

//guideline_in
/obj/effect/turf_decal/guideline/guideline_in
	name = "guideline inward decal"
	icon_state = "guideline_in"
	layer = TURF_PLATING_DECAL_LAYER

/obj/effect/turf_decal/guideline/guideline_in/Initialize(mapload)
	if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
		color = "#[random_short_color()]"
	. = ..()

/obj/effect/turf_decal/guideline/guideline_in/blue
	name = "blue in guideline"
	color = "#52B4E9"

/obj/effect/turf_decal/guideline/guideline_in/green
	name = "green in guideline"
	color = "#9FED58"

/obj/effect/turf_decal/guideline/guideline_in/yellow
	name = "yellow in guideline"
	color = "#EFB341"

/obj/effect/turf_decal/guideline/guideline_in/red
	name = "red in guideline"
	color = "#DE3A3A"

/obj/effect/turf_decal/guideline/guideline_in/bar
	name = "bar in guideline"
	color = "#791500"
	alpha = 130

/obj/effect/turf_decal/guideline/guideline_in/purple
	name = "purple in guideline"
	color = "#D381C9"

/obj/effect/turf_decal/guideline/guideline_in/brown
	name = "brown in guideline"
	color = "#A46106"

/obj/effect/turf_decal/guideline/guideline_in/neutral
	name = "neutral in guideline"
	color = "#D4D4D4"
	alpha = 50

/obj/effect/turf_decal/guideline/guideline_in/darkblue
	name = "dark blue in guideline"
	color = "#334E6D"

/obj/effect/turf_decal/guideline/guideline_in/random // so many colors
	name = "colorful in guideline"
	color = "#E300FF" //bright pink as default for mapping

/obj/effect/turf_decal/guideline/guideline_in/random/Initialize(mapload)
	color = "#[random_short_color()]"
	. = ..()

//guideline_half_in
/obj/effect/turf_decal/guideline/guideline_half_in
	name = "guideline half inward decal"
	icon_state = "guideline_half_in"
	layer = TURF_PLATING_DECAL_LAYER

/obj/effect/turf_decal/guideline/guideline_half_in/Initialize(mapload)
	if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
		color = "#[random_short_color()]"
	. = ..()

/obj/effect/turf_decal/guideline/guideline_half_in/blue
	name = "blue in guideline"
	color = "#52B4E9"

/obj/effect/turf_decal/guideline/guideline_half_in/green
	name = "green in guideline"
	color = "#9FED58"

/obj/effect/turf_decal/guideline/guideline_half_in/yellow
	name = "yellow in guideline"
	color = "#EFB341"

/obj/effect/turf_decal/guideline/guideline_half_in/red
	name = "red in guideline"
	color = "#DE3A3A"

/obj/effect/turf_decal/guideline/guideline_half_in/bar
	name = "bar in guideline"
	color = "#791500"
	alpha = 130

/obj/effect/turf_decal/guideline/guideline_half_in/purple
	name = "purple in guideline"
	color = "#D381C9"

/obj/effect/turf_decal/guideline/guideline_half_in/brown
	name = "brown in guideline"
	color = "#A46106"

/obj/effect/turf_decal/guideline/guideline_half_in/neutral
	name = "neutral in guideline"
	color = "#D4D4D4"
	alpha = 50

/obj/effect/turf_decal/guideline/guideline_half_in/darkblue
	name = "dark blue in guideline"
	color = "#334E6D"

/obj/effect/turf_decal/guideline/guideline_half_in/random // so many colors
	name = "colorful in guideline"
	color = "#E300FF" //bright pink as default for mapping

/obj/effect/turf_decal/guideline/guideline_half_in/random/Initialize(mapload)
	color = "#[random_short_color()]"
	. = ..()

//guideline_half_edge
/obj/effect/turf_decal/guideline/guideline_half_edge
	name = "guideline half inward decal"
	icon_state = "guideline_half_edge"
	layer = TURF_PLATING_DECAL_LAYER

/obj/effect/turf_decal/guideline/guideline_half_edge/Initialize(mapload)
	if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
		color = "#[random_short_color()]"
	. = ..()

/obj/effect/turf_decal/guideline/guideline_half_edge/blue
	name = "blue in guideline"
	color = "#52B4E9"

/obj/effect/turf_decal/guideline/guideline_half_edge/green
	name = "green in guideline"
	color = "#9FED58"

/obj/effect/turf_decal/guideline/guideline_half_edge/yellow
	name = "yellow in guideline"
	color = "#EFB341"

/obj/effect/turf_decal/guideline/guideline_half_edge/red
	name = "red in guideline"
	color = "#DE3A3A"

/obj/effect/turf_decal/guideline/guideline_half_edge/bar
	name = "bar in guideline"
	color = "#791500"
	alpha = 130

/obj/effect/turf_decal/guideline/guideline_half_edge/purple
	name = "purple in guideline"
	color = "#D381C9"

/obj/effect/turf_decal/guideline/guideline_half_edge/brown
	name = "brown in guideline"
	color = "#A46106"

/obj/effect/turf_decal/guideline/guideline_half_edge/neutral
	name = "neutral in guideline"
	color = "#D4D4D4"
	alpha = 50

/obj/effect/turf_decal/guideline/guideline_half_edge/darkblue
	name = "dark blue in guideline"
	color = "#334E6D"

/obj/effect/turf_decal/guideline/guideline_half_edge/random // so many colors
	name = "colorful in guideline"
	color = "#E300FF" //bright pink as default for mapping

/obj/effect/turf_decal/guideline/guideline_half_edge/random/Initialize(mapload)
	color = "#[random_short_color()]"
	. = ..()

//guideline_half_ramp
/obj/effect/turf_decal/guideline/guideline_half_ramp
	name = "guideline half inward decal"
	icon_state = "guideline_half_ramp"
	layer = TURF_PLATING_DECAL_LAYER

/obj/effect/turf_decal/guideline/guideline_half_ramp/Initialize(mapload)
	if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
		color = "#[random_short_color()]"
	. = ..()

/obj/effect/turf_decal/guideline/guideline_half_ramp/blue
	name = "blue in guideline"
	color = "#52B4E9"

/obj/effect/turf_decal/guideline/guideline_half_ramp/green
	name = "green in guideline"
	color = "#9FED58"

/obj/effect/turf_decal/guideline/guideline_half_ramp/yellow
	name = "yellow in guideline"
	color = "#EFB341"

/obj/effect/turf_decal/guideline/guideline_half_ramp/red
	name = "red in guideline"
	color = "#DE3A3A"

/obj/effect/turf_decal/guideline/guideline_half_ramp/bar
	name = "bar in guideline"
	color = "#791500"
	alpha = 130

/obj/effect/turf_decal/guideline/guideline_half_ramp/purple
	name = "purple in guideline"
	color = "#D381C9"

/obj/effect/turf_decal/guideline/guideline_half_ramp/brown
	name = "brown in guideline"
	color = "#A46106"

/obj/effect/turf_decal/guideline/guideline_half_ramp/neutral
	name = "neutral in guideline"
	color = "#D4D4D4"
	alpha = 50

/obj/effect/turf_decal/guideline/guideline_half_ramp/darkblue
	name = "dark blue in guideline"
	color = "#334E6D"

/obj/effect/turf_decal/guideline/guideline_half_ramp/random // so many colors
	name = "colorful in guideline"
	color = "#E300FF" //bright pink as default for mapping

/obj/effect/turf_decal/guideline/guideline_half_ramp/random/Initialize(mapload)
	color = "#[random_short_color()]"
	. = ..()

//guideline_half_ramp/_inverted
/obj/effect/turf_decal/guideline/guideline_half_ramp/_inverted
	name = "guideline half inward decal"
	icon_state = "guideline_half_ramp_inverted"
	layer = TURF_PLATING_DECAL_LAYER

/obj/effect/turf_decal/guideline/guideline_half_ramp/_inverted/Initialize(mapload)
	if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
		color = "#[random_short_color()]"
	. = ..()

/obj/effect/turf_decal/guideline/guideline_half_ramp/_inverted/blue
	name = "blue in guideline"
	color = "#52B4E9"

/obj/effect/turf_decal/guideline/guideline_half_ramp/_inverted/green
	name = "green in guideline"
	color = "#9FED58"

/obj/effect/turf_decal/guideline/guideline_half_ramp/_inverted/yellow
	name = "yellow in guideline"
	color = "#EFB341"

/obj/effect/turf_decal/guideline/guideline_half_ramp/_inverted/red
	name = "red in guideline"
	color = "#DE3A3A"

/obj/effect/turf_decal/guideline/guideline_half_ramp/_inverted/bar
	name = "bar in guideline"
	color = "#791500"
	alpha = 130

/obj/effect/turf_decal/guideline/guideline_half_ramp/_inverted/purple
	name = "purple in guideline"
	color = "#D381C9"

/obj/effect/turf_decal/guideline/guideline_half_ramp/_inverted/brown
	name = "brown in guideline"
	color = "#A46106"

/obj/effect/turf_decal/guideline/guideline_half_ramp/_inverted/neutral
	name = "neutral in guideline"
	color = "#D4D4D4"
	alpha = 50

/obj/effect/turf_decal/guideline/guideline_half_ramp/_inverted/darkblue
	name = "dark blue in guideline"
	color = "#334E6D"

/obj/effect/turf_decal/guideline/guideline_half_ramp/_inverted/random // so many colors
	name = "colorful in guideline"
	color = "#E300FF" //bright pink as default for mapping

/obj/effect/turf_decal/guideline/guideline_half_ramp/_inverted/random/Initialize(mapload)
	color = "#[random_short_color()]"
	. = ..()

//guideline_ramp
/obj/effect/turf_decal/guideline/guideline_ramp
	name = "guideline half inward decal"
	icon_state = "guideline_ramp"
	layer = TURF_PLATING_DECAL_LAYER

/obj/effect/turf_decal/guideline/guideline_ramp/Initialize(mapload)
	if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
		color = "#[random_short_color()]"
	. = ..()

/obj/effect/turf_decal/guideline/guideline_ramp/blue
	name = "blue in guideline"
	color = "#52B4E9"

/obj/effect/turf_decal/guideline/guideline_ramp/green
	name = "green in guideline"
	color = "#9FED58"

/obj/effect/turf_decal/guideline/guideline_ramp/yellow
	name = "yellow in guideline"
	color = "#EFB341"

/obj/effect/turf_decal/guideline/guideline_ramp/red
	name = "red in guideline"
	color = "#DE3A3A"

/obj/effect/turf_decal/guideline/guideline_ramp/bar
	name = "bar in guideline"
	color = "#791500"
	alpha = 130

/obj/effect/turf_decal/guideline/guideline_ramp/purple
	name = "purple in guideline"
	color = "#D381C9"

/obj/effect/turf_decal/guideline/guideline_ramp/brown
	name = "brown in guideline"
	color = "#A46106"

/obj/effect/turf_decal/guideline/guideline_ramp/neutral
	name = "neutral in guideline"
	color = "#D4D4D4"
	alpha = 50

/obj/effect/turf_decal/guideline/guideline_ramp/darkblue
	name = "dark blue in guideline"
	color = "#334E6D"

/obj/effect/turf_decal/guideline/guideline_ramp/random // so many colors
	name = "colorful in guideline"
	color = "#E300FF" //bright pink as default for mapping

/obj/effect/turf_decal/guideline/guideline_ramp/random/Initialize(mapload)
	color = "#[random_short_color()]"
	. = ..()

//guideline_edge
/obj/effect/turf_decal/guideline/guideline_edge
	name = "guideline half inward decal"
	icon_state = "guideline_edge"
	layer = TURF_PLATING_DECAL_LAYER

/obj/effect/turf_decal/guideline/guideline_edge/Initialize(mapload)
	if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
		color = "#[random_short_color()]"
	. = ..()

/obj/effect/turf_decal/guideline/guideline_edge/blue
	name = "blue in guideline"
	color = "#52B4E9"

/obj/effect/turf_decal/guideline/guideline_edge/green
	name = "green in guideline"
	color = "#9FED58"

/obj/effect/turf_decal/guideline/guideline_edge/yellow
	name = "yellow in guideline"
	color = "#EFB341"

/obj/effect/turf_decal/guideline/guideline_edge/red
	name = "red in guideline"
	color = "#DE3A3A"

/obj/effect/turf_decal/guideline/guideline_edge/bar
	name = "bar in guideline"
	color = "#791500"
	alpha = 130

/obj/effect/turf_decal/guideline/guideline_edge/purple
	name = "purple in guideline"
	color = "#D381C9"

/obj/effect/turf_decal/guideline/guideline_edge/brown
	name = "brown in guideline"
	color = "#A46106"

/obj/effect/turf_decal/guideline/guideline_edge/neutral
	name = "neutral in guideline"
	color = "#D4D4D4"
	alpha = 50

/obj/effect/turf_decal/guideline/guideline_edge/darkblue
	name = "dark blue in guideline"
	color = "#334E6D"

/obj/effect/turf_decal/guideline/guideline_edge/random // so many colors
	name = "colorful in guideline"
	color = "#E300FF" //bright pink as default for mapping

/obj/effect/turf_decal/guideline/guideline_edge/random/Initialize(mapload)
	color = "#[random_short_color()]"
	. = ..()

//guideline_edge_alt
/obj/effect/turf_decal/guideline/guideline_edge_alt
	name = "guideline half inward decal"
	icon_state = "guideline_edge_alt"
	layer = TURF_PLATING_DECAL_LAYER

/obj/effect/turf_decal/guideline/guideline_edge_alt/Initialize(mapload)
	if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
		color = "#[random_short_color()]"
	. = ..()

/obj/effect/turf_decal/guideline/guideline_edge_alt/blue
	name = "blue in guideline"
	color = "#52B4E9"

/obj/effect/turf_decal/guideline/guideline_edge_alt/green
	name = "green in guideline"
	color = "#9FED58"

/obj/effect/turf_decal/guideline/guideline_edge_alt/yellow
	name = "yellow in guideline"
	color = "#EFB341"

/obj/effect/turf_decal/guideline/guideline_edge_alt/red
	name = "red in guideline"
	color = "#DE3A3A"

/obj/effect/turf_decal/guideline/guideline_edge_alt/bar
	name = "bar in guideline"
	color = "#791500"
	alpha = 130

/obj/effect/turf_decal/guideline/guideline_edge_alt/purple
	name = "purple in guideline"
	color = "#D381C9"

/obj/effect/turf_decal/guideline/guideline_edge_alt/brown
	name = "brown in guideline"
	color = "#A46106"

/obj/effect/turf_decal/guideline/guideline_edge_alt/neutral
	name = "neutral in guideline"
	color = "#D4D4D4"
	alpha = 50

/obj/effect/turf_decal/guideline/guideline_edge_alt/darkblue
	name = "dark blue in guideline"
	color = "#334E6D"

/obj/effect/turf_decal/guideline/guideline_edge_alt/random // so many colors
	name = "colorful in guideline"
	color = "#E300FF" //bright pink as default for mapping

/obj/effect/turf_decal/guideline/guideline_edge_alt/random/Initialize(mapload)
	color = "#[random_short_color()]"
	. = ..()

//guideline_edge_alt/_offset
/obj/effect/turf_decal/guideline/guideline_edge_alt/_offset
	name = "guideline half inward decal"
	icon_state = "guideline_edge_alt_offset"
	layer = TURF_PLATING_DECAL_LAYER

/obj/effect/turf_decal/guideline/guideline_edge_alt/_offset/Initialize(mapload)
	if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
		color = "#[random_short_color()]"
	. = ..()

/obj/effect/turf_decal/guideline/guideline_edge_alt/_offset/blue
	name = "blue in guideline"
	color = "#52B4E9"

/obj/effect/turf_decal/guideline/guideline_edge_alt/_offset/green
	name = "green in guideline"
	color = "#9FED58"

/obj/effect/turf_decal/guideline/guideline_edge_alt/_offset/yellow
	name = "yellow in guideline"
	color = "#EFB341"

/obj/effect/turf_decal/guideline/guideline_edge_alt/_offset/red
	name = "red in guideline"
	color = "#DE3A3A"

/obj/effect/turf_decal/guideline/guideline_edge_alt/_offset/bar
	name = "bar in guideline"
	color = "#791500"
	alpha = 130

/obj/effect/turf_decal/guideline/guideline_edge_alt/_offset/purple
	name = "purple in guideline"
	color = "#D381C9"

/obj/effect/turf_decal/guideline/guideline_edge_alt/_offset/brown
	name = "brown in guideline"
	color = "#A46106"

/obj/effect/turf_decal/guideline/guideline_edge_alt/_offset/neutral
	name = "neutral in guideline"
	color = "#D4D4D4"
	alpha = 50

/obj/effect/turf_decal/guideline/guideline_edge_alt/_offset/darkblue
	name = "dark blue in guideline"
	color = "#334E6D"

/obj/effect/turf_decal/guideline/guideline_edge_alt/_offset/random // so many colors
	name = "colorful in guideline"
	color = "#E300FF" //bright pink as default for mapping

/obj/effect/turf_decal/guideline/guideline_edge_alt/_offset/random/Initialize(mapload)
	color = "#[random_short_color()]"
	. = ..()

//guideline_mid
/obj/effect/turf_decal/guideline/guideline_mid
	name = "guideline outward decal"
	icon_state = "guideline_mid"
	layer = TURF_PLATING_DECAL_LAYER

/obj/effect/turf_decal/guideline/guideline_mid/Initialize(mapload)
	if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
		color = "#[random_short_color()]"
	. = ..()

/obj/effect/turf_decal/guideline/guideline_mid/blue
	name = "blue mid guideline"
	color = "#52B4E9"

/obj/effect/turf_decal/guideline/guideline_mid/green
	name = "green mid guideline"
	color = "#9FED58"

/obj/effect/turf_decal/guideline/guideline_mid/yellow
	name = "yellow mid guideline"
	color = "#EFB341"

/obj/effect/turf_decal/guideline/guideline_mid/red
	name = "red mid guideline"
	color = "#DE3A3A"

/obj/effect/turf_decal/guideline/guideline_mid/bar
	name = "bar mid guideline"
	color = "#791500"
	alpha = 130

/obj/effect/turf_decal/guideline/guideline_mid/purple
	name = "purple mid guideline"
	color = "#D381C9"

/obj/effect/turf_decal/guideline/guideline_mid/brown
	name = "brown mid guideline"
	color = "#A46106"

/obj/effect/turf_decal/guideline/guideline_mid/neutral
	name = "neutral mid guideline"
	color = "#D4D4D4"
	alpha = 50

/obj/effect/turf_decal/guideline/guideline_mid/darkblue
	name = "dark blue mid guideline"
	color = "#334E6D"

/obj/effect/turf_decal/guideline/guideline_mid/random // so many colors
	name = "colorful mid guideline"
	color = "#E300FF" //bright pink as default for mapping

/obj/effect/turf_decal/guideline/guideline_mid/random/Initialize(mapload)
	color = "#[random_short_color()]"
	. = ..()

//guideline_out
/obj/effect/turf_decal/guideline/guideline_out
	name = "guideline outward decal"
	icon_state = "guideline_out"
	layer = TURF_PLATING_DECAL_LAYER

/obj/effect/turf_decal/guideline/guideline_out/Initialize(mapload)
	if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
		color = "#[random_short_color()]"
	. = ..()

/obj/effect/turf_decal/guideline/guideline_out/blue
	name = "blue out guideline"
	color = "#52B4E9"

/obj/effect/turf_decal/guideline/guideline_out/green
	name = "green out guideline"
	color = "#9FED58"

/obj/effect/turf_decal/guideline/guideline_out/yellow
	name = "yellow out guideline"
	color = "#EFB341"

/obj/effect/turf_decal/guideline/guideline_out/red
	name = "red out guideline"
	color = "#DE3A3A"

/obj/effect/turf_decal/guideline/guideline_out/bar
	name = "bar out guideline"
	color = "#791500"
	alpha = 140

/obj/effect/turf_decal/guideline/guideline_out/purple
	name = "purple out guideline"
	color = "#D381C9"

/obj/effect/turf_decal/guideline/guideline_out/brown
	name = "brown out guideline"
	color = "#A46106"

/obj/effect/turf_decal/guideline/guideline_out/darkblue
	name = "dark blue out guideline"
	color = "#334E6D"

/obj/effect/turf_decal/guideline/guideline_out/neutral
	name = "neutral out guideline"
	color = "#D4D4D4"
	alpha = 50

/obj/effect/turf_decal/guideline/guideline_out/random // so many colors
	name = "colorful out guideline"
	color = "#E300FF" //bright pink as default for mapping

/obj/effect/turf_decal/guideline/guideline_out/random/Initialize(mapload)
	color = "#[random_short_color()]"
	. = ..()

//guideline_in_alt
/obj/effect/turf_decal/guideline/guideline_in_alt
	name = "guideline inward decal alt"
	icon_state = "guideline_in_alt"
	layer = TURF_PLATING_DECAL_LAYER

/obj/effect/turf_decal/guideline/guideline_in_alt/Initialize(mapload)
	if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
		color = "#[random_short_color()]"
	. = ..()

/obj/effect/turf_decal/guideline/guideline_in_alt/blue
	name = "blue in alt guideline"
	color = "#52B4E9"

/obj/effect/turf_decal/guideline/guideline_in_alt/green
	name = "green in alt guideline"
	color = "#9FED58"

/obj/effect/turf_decal/guideline/guideline_in_alt/yellow
	name = "yellow in alt guideline"
	color = "#EFB341"

/obj/effect/turf_decal/guideline/guideline_in_alt/red
	name = "red in alt guideline"
	color = "#DE3A3A"

/obj/effect/turf_decal/guideline/guideline_in_alt/bar
	name = "bar in alt guideline"
	color = "#791500"
	alpha = 130

/obj/effect/turf_decal/guideline/guideline_in_alt/purple
	name = "purple in alt guideline"
	color = "#D381C9"

/obj/effect/turf_decal/guideline/guideline_in_alt/brown
	name = "brown in alt guideline"
	color = "#A46106"

/obj/effect/turf_decal/guideline/guideline_in_alt/neutral
	name = "neutral in alt guideline"
	color = "#D4D4D4"
	alpha = 50

/obj/effect/turf_decal/guideline/guideline_in_alt/darkblue
	name = "dark blue in alt guideline"
	color = "#334E6D"

/obj/effect/turf_decal/guideline/guideline_in_alt/random // so many colors
	name = "colorful in alt guideline"
	color = "#E300FF" //bright pink as default for mapping

/obj/effect/turf_decal/guideline/guideline_in_alt/random/Initialize(mapload)
	color = "#[random_short_color()]"
	. = ..()

//guideline_mid_alt
/obj/effect/turf_decal/guideline/guideline_mid_alt
	name = "guideline mid decal alt"
	icon_state = "guideline_mid_alt"
	layer = TURF_PLATING_DECAL_LAYER

/obj/effect/turf_decal/guideline/guideline_mid_alt/Initialize(mapload)
	if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
		color = "#[random_short_color()]"
	. = ..()

/obj/effect/turf_decal/guideline/guideline_mid_alt/blue
	name = "blue mid alt guideline"
	color = "#52B4E9"

/obj/effect/turf_decal/guideline/guideline_mid_alt/green
	name = "green mid alt guideline"
	color = "#9FED58"

/obj/effect/turf_decal/guideline/guideline_mid_alt/yellow
	name = "yellow mid alt guideline"
	color = "#EFB341"

/obj/effect/turf_decal/guideline/guideline_mid_alt/red
	name = "red mid alt guideline"
	color = "#DE3A3A"

/obj/effect/turf_decal/guideline/guideline_mid_alt/bar
	name = "bar mid alt guideline"
	color = "#791500"
	alpha = 130

/obj/effect/turf_decal/guideline/guideline_mid_alt/purple
	name = "purple mid alt guideline"
	color = "#D381C9"

/obj/effect/turf_decal/guideline/guideline_mid_alt/brown
	name = "brown mid alt guideline"
	color = "#A46106"

/obj/effect/turf_decal/guideline/guideline_mid_alt/neutral
	name = "neutral mid alt guideline"
	color = "#D4D4D4"
	alpha = 50

/obj/effect/turf_decal/guideline/guideline_mid_alt/darkblue
	name = "dark blue mid alt guideline"
	color = "#334E6D"

/obj/effect/turf_decal/guideline/guideline_mid_alt/random // so many colors
	name = "colorful mid alt guideline"
	color = "#E300FF" //bright pink as default for mapping

/obj/effect/turf_decal/guideline/guideline_mid_alt/random/Initialize(mapload)
	color = "#[random_short_color()]"
	. = ..()

//guideline_out_alt
/obj/effect/turf_decal/guideline/guideline_out_alt
	name = "guideline out decal alt"
	icon_state = "guideline_out_alt"
	layer = TURF_PLATING_DECAL_LAYER

/obj/effect/turf_decal/guideline/guideline_out_alt/Initialize(mapload)
	if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
		color = "#[random_short_color()]"
	. = ..()

/obj/effect/turf_decal/guideline/guideline_out_alt/blue
	name = "blue out alt guideline"
	color = "#52B4E9"

/obj/effect/turf_decal/guideline/guideline_out_alt/green
	name = "green out alt guideline"
	color = "#9FED58"

/obj/effect/turf_decal/guideline/guideline_out_alt/yellow
	name = "yellow out alt guideline"
	color = "#EFB341"

/obj/effect/turf_decal/guideline/guideline_out_alt/red
	name = "red out alt guideline"
	color = "#DE3A3A"

/obj/effect/turf_decal/guideline/guideline_out_alt/bar
	name = "bar out alt guideline"
	color = "#791500"
	alpha = 130

/obj/effect/turf_decal/guideline/guideline_out_alt/purple
	name = "purple out alt guideline"
	color = "#D381C9"

/obj/effect/turf_decal/guideline/guideline_out_alt/brown
	name = "brown out alt guideline"
	color = "#A46106"

/obj/effect/turf_decal/guideline/guideline_out_alt/neutral
	name = "neutral out alt guideline"
	color = "#D4D4D4"
	alpha = 50

/obj/effect/turf_decal/guideline/guideline_out_alt/darkblue
	name = "dark blue out alt guideline"
	color = "#334E6D"

/obj/effect/turf_decal/guideline/guideline_out_alt/random // so many colors
	name = "colorful out alt guideline"
	color = "#E300FF" //bright pink as default for mapping

/obj/effect/turf_decal/guideline/guideline_out_alt/random/Initialize(mapload)
	color = "#[random_short_color()]"
	. = ..()

//guideline_tri
/obj/effect/turf_decal/guideline/guideline_tri
	name = "guideline out decal alt"
	icon_state = "guideline_tri"
	layer = TURF_PLATING_DECAL_LAYER

/obj/effect/turf_decal/guideline/guideline_tri/Initialize(mapload)
	if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
		color = "#[random_short_color()]"
	. = ..()

/obj/effect/turf_decal/guideline/guideline_tri/blue
	name = "blue out alt guideline"
	color = "#52B4E9"

/obj/effect/turf_decal/guideline/guideline_tri/green
	name = "green out alt guideline"
	color = "#9FED58"

/obj/effect/turf_decal/guideline/guideline_tri/yellow
	name = "yellow out alt guideline"
	color = "#EFB341"

/obj/effect/turf_decal/guideline/guideline_tri/red
	name = "red out alt guideline"
	color = "#DE3A3A"

/obj/effect/turf_decal/guideline/guideline_tri/bar
	name = "bar out alt guideline"
	color = "#791500"
	alpha = 130

/obj/effect/turf_decal/guideline/guideline_tri/purple
	name = "purple out alt guideline"
	color = "#D381C9"

/obj/effect/turf_decal/guideline/guideline_tri/brown
	name = "brown out alt guideline"
	color = "#A46106"

/obj/effect/turf_decal/guideline/guideline_tri/neutral
	name = "neutral out alt guideline"
	color = "#D4D4D4"
	alpha = 50

/obj/effect/turf_decal/guideline/guideline_tri/darkblue
	name = "dark blue out alt guideline"
	color = "#334E6D"

/obj/effect/turf_decal/guideline/guideline_tri/random // so many colors
	name = "colorful out alt guideline"
	color = "#E300FF" //bright pink as default for mapping

/obj/effect/turf_decal/guideline/guideline_tri/random/Initialize(mapload)
	color = "#[random_short_color()]"
	. = ..()

//guideline_tri/_corner
/obj/effect/turf_decal/guideline/guideline_tri/_corner
	name = "guideline out decal alt"
	icon_state = "guideline_corner_tri"
	layer = TURF_PLATING_DECAL_LAYER

/obj/effect/turf_decal/guideline/guideline_tri/_corner/Initialize(mapload)
	if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
		color = "#[random_short_color()]"
	. = ..()

/obj/effect/turf_decal/guideline/guideline_tri/_corner/blue
	name = "blue out alt guideline"
	color = "#52B4E9"

/obj/effect/turf_decal/guideline/guideline_tri/_corner/green
	name = "green out alt guideline"
	color = "#9FED58"

/obj/effect/turf_decal/guideline/guideline_tri/_corner/yellow
	name = "yellow out alt guideline"
	color = "#EFB341"

/obj/effect/turf_decal/guideline/guideline_tri/_corner/red
	name = "red out alt guideline"
	color = "#DE3A3A"

/obj/effect/turf_decal/guideline/guideline_tri/_corner/bar
	name = "bar out alt guideline"
	color = "#791500"
	alpha = 130

/obj/effect/turf_decal/guideline/guideline_tri/_corner/purple
	name = "purple out alt guideline"
	color = "#D381C9"

/obj/effect/turf_decal/guideline/guideline_tri/_corner/brown
	name = "brown out alt guideline"
	color = "#A46106"

/obj/effect/turf_decal/guideline/guideline_tri/_corner/neutral
	name = "neutral out alt guideline"
	color = "#D4D4D4"
	alpha = 50

/obj/effect/turf_decal/guideline/guideline_tri/_corner/darkblue
	name = "dark blue out alt guideline"
	color = "#334E6D"

/obj/effect/turf_decal/guideline/guideline_tri/_corner/random // so many colors
	name = "colorful out alt guideline"
	color = "#E300FF" //bright pink as default for mapping

/obj/effect/turf_decal/guideline/guideline_tri/_corner/random/Initialize(mapload)
	color = "#[random_short_color()]"
	. = ..()

//guideline_tri/_offset
/obj/effect/turf_decal/guideline/guideline_tri/_offset
	name = "guideline out decal alt"
	icon_state = "guideline_corner_offset_tri"
	layer = TURF_PLATING_DECAL_LAYER

/obj/effect/turf_decal/guideline/guideline_tri/_offset/Initialize(mapload)
	if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
		color = "#[random_short_color()]"
	. = ..()

/obj/effect/turf_decal/guideline/guideline_tri/_offset/blue
	name = "blue out alt guideline"
	color = "#52B4E9"

/obj/effect/turf_decal/guideline/guideline_tri/_offset/green
	name = "green out alt guideline"
	color = "#9FED58"

/obj/effect/turf_decal/guideline/guideline_tri/_offset/yellow
	name = "yellow out alt guideline"
	color = "#EFB341"

/obj/effect/turf_decal/guideline/guideline_tri/_offset/red
	name = "red out alt guideline"
	color = "#DE3A3A"

/obj/effect/turf_decal/guideline/guideline_tri/_offset/bar
	name = "bar out alt guideline"
	color = "#791500"
	alpha = 130

/obj/effect/turf_decal/guideline/guideline_tri/_offset/purple
	name = "purple out alt guideline"
	color = "#D381C9"

/obj/effect/turf_decal/guideline/guideline_tri/_offset/brown
	name = "brown out alt guideline"
	color = "#A46106"

/obj/effect/turf_decal/guideline/guideline_tri/_offset/neutral
	name = "neutral out alt guideline"
	color = "#D4D4D4"
	alpha = 50

/obj/effect/turf_decal/guideline/guideline_tri/_offset/darkblue
	name = "dark blue out alt guideline"
	color = "#334E6D"

/obj/effect/turf_decal/guideline/guideline_tri/_offset/random // so many colors
	name = "colorful out alt guideline"
	color = "#E300FF" //bright pink as default for mapping

/obj/effect/turf_decal/guideline/guideline_tri/_offset/random/Initialize(mapload)
	color = "#[random_short_color()]"
	. = ..()

//guideline_in_T
/obj/effect/turf_decal/guideline/guideline_in_T
	name = "guideline in T decal alt"
	icon_state = "guideline_in_T"
	layer = TURF_PLATING_DECAL_LAYER

/obj/effect/turf_decal/guideline/guideline_in_T/Initialize(mapload)
	if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
		color = "#[random_short_color()]"
	. = ..()

/obj/effect/turf_decal/guideline/guideline_in_T/blue
	name = "blue in T guideline"
	color = "#52B4E9"

/obj/effect/turf_decal/guideline/guideline_in_T/green
	name = "green in T guideline"
	color = "#9FED58"

/obj/effect/turf_decal/guideline/guideline_in_T/yellow
	name = "yellow in T guideline"
	color = "#EFB341"

/obj/effect/turf_decal/guideline/guideline_in_T/red
	name = "red in T guideline"
	color = "#DE3A3A"

/obj/effect/turf_decal/guideline/guideline_in_T/bar
	name = "bar in T guideline"
	color = "#791500"
	alpha = 130

/obj/effect/turf_decal/guideline/guideline_in_T/purple
	name = "purple in T guideline"
	color = "#D381C9"

/obj/effect/turf_decal/guideline/guideline_in_T/brown
	name = "brown in T guideline"
	color = "#A46106"

/obj/effect/turf_decal/guideline/guideline_in_T/neutral
	name = "neutral in T guideline"
	color = "#D4D4D4"
	alpha = 50

/obj/effect/turf_decal/guideline/guideline_in_T/darkblue
	name = "dark blue in T guideline"
	color = "#334E6D"

/obj/effect/turf_decal/guideline/guideline_in_T/random // so many colors
	name = "colorful in T guideline"
	color = "#E300FF" //bright pink as default for mapping

/obj/effect/turf_decal/guideline/guideline_in_T/random/Initialize(mapload)
	color = "#[random_short_color()]"
	. = ..()

//guideline_mid_T
/obj/effect/turf_decal/guideline/guideline_mid_T
	name = "guideline mid T decal alt"
	icon_state = "guideline_mid_T"
	layer = TURF_PLATING_DECAL_LAYER

/obj/effect/turf_decal/guideline/guideline_mid_T/Initialize(mapload)
	if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
		color = "#[random_short_color()]"
	. = ..()

/obj/effect/turf_decal/guideline/guideline_mid_T/blue
	name = "blue mid T guideline"
	color = "#52B4E9"

/obj/effect/turf_decal/guideline/guideline_mid_T/green
	name = "green mid T guideline"
	color = "#9FED58"

/obj/effect/turf_decal/guideline/guideline_mid_T/yellow
	name = "yellow mid T guideline"
	color = "#EFB341"

/obj/effect/turf_decal/guideline/guideline_mid_T/red
	name = "red mid T guideline"
	color = "#DE3A3A"

/obj/effect/turf_decal/guideline/guideline_mid_T/bar
	name = "bar mid T guideline"
	color = "#791500"
	alpha = 130

/obj/effect/turf_decal/guideline/guideline_mid_T/purple
	name = "purple mid T guideline"
	color = "#D381C9"

/obj/effect/turf_decal/guideline/guideline_mid_T/brown
	name = "brown mid T guideline"
	color = "#A46106"

/obj/effect/turf_decal/guideline/guideline_mid_T/neutral
	name = "neutral mid T guideline"
	color = "#D4D4D4"
	alpha = 50

/obj/effect/turf_decal/guideline/guideline_mid_T/darkblue
	name = "dark blue mid T guideline"
	color = "#334E6D"

/obj/effect/turf_decal/guideline/guideline_mid_T/random // so many colors
	name = "colorful mid T guideline"
	color = "#E300FF" //bright pink as default for mapping

/obj/effect/turf_decal/guideline/guideline_out_T/random/Initialize(mapload)
	color = "#[random_short_color()]"
	. = ..()

//guideline_out_T
/obj/effect/turf_decal/guideline/guideline_out_T
	name = "guideline out T decal alt"
	icon_state = "guideline_out_T"
	layer = TURF_PLATING_DECAL_LAYER

/obj/effect/turf_decal/guideline/guideline_out_T/Initialize(mapload)
	if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
		color = "#[random_short_color()]"
	. = ..()

/obj/effect/turf_decal/guideline/guideline_out_T/blue
	name = "blue out T guideline"
	color = "#52B4E9"

/obj/effect/turf_decal/guideline/guideline_out_T/green
	name = "green out T guideline"
	color = "#9FED58"

/obj/effect/turf_decal/guideline/guideline_out_T/yellow
	name = "yellow out T guideline"
	color = "#EFB341"

/obj/effect/turf_decal/guideline/guideline_out_T/red
	name = "red out T guideline"
	color = "#DE3A3A"

/obj/effect/turf_decal/guideline/guideline_out_T/bar
	name = "bar out T guideline"
	color = "#791500"
	alpha = 130

/obj/effect/turf_decal/guideline/guideline_out_T/purple
	name = "purple out T guideline"
	color = "#D381C9"

/obj/effect/turf_decal/guideline/guideline_out_T/brown
	name = "brown out T guideline"
	color = "#A46106"

/obj/effect/turf_decal/guideline/guideline_out_T/neutral
	name = "neutral out T guideline"
	color = "#D4D4D4"
	alpha = 50

/obj/effect/turf_decal/guideline/guideline_out_T/darkblue
	name = "dark blue out T guideline"
	color = "#334E6D"

/obj/effect/turf_decal/guideline/guideline_out_T/random // so many colors
	name = "colorful out T guideline"
	color = "#E300FF" //bright pink as default for mapping

/obj/effect/turf_decal/guideline/guideline_out_T/random/Initialize(mapload)
	color = "#[random_short_color()]"
	. = ..()

//guideline_in_arrow
/obj/effect/turf_decal/guideline/guideline_in_arrow
	name = "guideline in Arrow decal alt"
	icon_state = "guideline_in_arrow"
	layer = TURF_PLATING_DECAL_LAYER

/obj/effect/turf_decal/guideline/guideline_in_arrow/Initialize(mapload)
	if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
		color = "#[random_short_color()]"
	. = ..()

/obj/effect/turf_decal/guideline/guideline_in_arrow/blue
	name = "blue in Arrow guideline"
	color = "#52B4E9"

/obj/effect/turf_decal/guideline/guideline_in_arrow/green
	name = "green in Arrow guideline"
	color = "#9FED58"

/obj/effect/turf_decal/guideline/guideline_in_arrow/yellow
	name = "yellow in Arrow guideline"
	color = "#EFB341"

/obj/effect/turf_decal/guideline/guideline_in_arrow/red
	name = "red in Arrow guideline"
	color = "#DE3A3A"

/obj/effect/turf_decal/guideline/guideline_in_arrow/bar
	name = "bar in Arrow guideline"
	color = "#791500"
	alpha = 130

/obj/effect/turf_decal/guideline/guideline_in_arrow/purple
	name = "purple in Arrow guideline"
	color = "#D381C9"

/obj/effect/turf_decal/guideline/guideline_in_arrow/brown
	name = "brown in Arrow guideline"
	color = "#A46106"

/obj/effect/turf_decal/guideline/guideline_in_arrow/neutral
	name = "neutral in Arrow guideline"
	color = "#D4D4D4"
	alpha = 50

/obj/effect/turf_decal/guideline/guideline_in_arrow/darkblue
	name = "dark blue in Arrow guideline"
	color = "#334E6D"

/obj/effect/turf_decal/guideline/guideline_in_arrow/random // so many colors
	name = "colorful in Arrow guideline"
	color = "#E300FF" //bright pink as default for mapping

/obj/effect/turf_decal/guideline/guideline_in_arrow/random/Initialize(mapload)
	color = "#[random_short_color()]"
	. = ..()

//guideline_mid_arrow
/obj/effect/turf_decal/guideline/guideline_mid_arrow
	name = "guideline mid arrow decal alt"
	icon_state = "guideline_mid_arrow"
	layer = TURF_PLATING_DECAL_LAYER

/obj/effect/turf_decal/guideline/guideline_mid_arrow/Initialize(mapload)
	if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
		color = "#[random_short_color()]"
	. = ..()

/obj/effect/turf_decal/guideline/guideline_mid_arrow/blue
	name = "blue mid arrow guideline"
	color = "#52B4E9"

/obj/effect/turf_decal/guideline/guideline_mid_arrow/green
	name = "green mid arrow guideline"
	color = "#9FED58"

/obj/effect/turf_decal/guideline/guideline_mid_arrow/yellow
	name = "yellow mid arrow guideline"
	color = "#EFB341"

/obj/effect/turf_decal/guideline/guideline_mid_arrow/red
	name = "red mid arrow guideline"
	color = "#DE3A3A"

/obj/effect/turf_decal/guideline/guideline_mid_arrow/bar
	name = "bar mid arrow guideline"
	color = "#791500"
	alpha = 130

/obj/effect/turf_decal/guideline/guideline_mid_arrow/purple
	name = "purple mid arrow guideline"
	color = "#D381C9"

/obj/effect/turf_decal/guideline/guideline_mid_arrow/brown
	name = "brown mid arrow guideline"
	color = "#A46106"

/obj/effect/turf_decal/guideline/guideline_mid_arrow/neutral
	name = "neutral mid arrow guideline"
	color = "#D4D4D4"
	alpha = 50

/obj/effect/turf_decal/guideline/guideline_mid_arrow/darkblue
	name = "dark blue mid arrow guideline"
	color = "#334E6D"

/obj/effect/turf_decal/guideline/guideline_mid_arrow/random // so many colors
	name = "colorful mid arrow guideline"
	color = "#E300FF" //bright pink as default for mapping

/obj/effect/turf_decal/guideline/guideline_mid_arrow/random/Initialize(mapload)
	color = "#[random_short_color()]"
	. = ..()

//guideline_out_arrow
/obj/effect/turf_decal/guideline/guideline_out_arrow
	name = "guideline out arrow decal alt"
	icon_state = "guideline_out_arrow"
	layer = TURF_PLATING_DECAL_LAYER

/obj/effect/turf_decal/guideline/guideline_out_arrow/Initialize(mapload)
	if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
		color = "#[random_short_color()]"
	. = ..()

/obj/effect/turf_decal/guideline/guideline_out_arrow/blue
	name = "blue out arrow guideline"
	color = "#52B4E9"

/obj/effect/turf_decal/guideline/guideline_out_arrow/green
	name = "green out arrow guideline"
	color = "#9FED58"

/obj/effect/turf_decal/guideline/guideline_out_arrow/yellow
	name = "yellow out arrow guideline"
	color = "#EFB341"

/obj/effect/turf_decal/guideline/guideline_out_arrow/red
	name = "red out arrow guideline"
	color = "#DE3A3A"

/obj/effect/turf_decal/guideline/guideline_out_arrow/bar
	name = "bar out arrow guideline"
	color = "#791500"
	alpha = 130

/obj/effect/turf_decal/guideline/guideline_out_arrow/purple
	name = "purple out arrow guideline"
	color = "#D381C9"

/obj/effect/turf_decal/guideline/guideline_out_arrow/brown
	name = "brown out arrow guideline"
	color = "#A46106"

/obj/effect/turf_decal/guideline/guideline_out_arrow/neutral
	name = "neutral out arrow guideline"
	color = "#D4D4D4"
	alpha = 50

/obj/effect/turf_decal/guideline/guideline_out_arrow/darkblue
	name = "dark blue out arrow guideline"
	color = "#334E6D"

/obj/effect/turf_decal/guideline/guideline_out_arrow/random // so many colors
	name = "colorful out arrow guideline"
	color = "#E300FF" //bright pink as default for mapping

/obj/effect/turf_decal/guideline/guideline_out_arrow/random/Initialize(mapload)
	color = "#[random_short_color()]"
	. = ..()

//guideline_in_arrow_con
/obj/effect/turf_decal/guideline/guideline_in_arrow_con
	name = "guideline continuous in Arrow decal alt"
	icon_state = "guideline_in_arrow_con"
	layer = TURF_PLATING_DECAL_LAYER

/obj/effect/turf_decal/guideline/guideline_in_arrow_con/Initialize(mapload)
	if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
		color = "#[random_short_color()]"
	. = ..()

/obj/effect/turf_decal/guideline/guideline_in_arrow_con/blue
	name = "continuous blue in Arrow guideline"
	color = "#52B4E9"

/obj/effect/turf_decal/guideline/guideline_in_arrow_con/green
	name = "continuousgreen in Arrow guideline"
	color = "#9FED58"

/obj/effect/turf_decal/guideline/guideline_in_arrow_con/yellow
	name = "continuous yellow in Arrow guideline"
	color = "#EFB341"

/obj/effect/turf_decal/guideline/guideline_in_arrow_con/red
	name = "continuous red in Arrow guideline"
	color = "#DE3A3A"

/obj/effect/turf_decal/guideline/guideline_in_arrow_con/bar
	name = "continuous bar in Arrow guideline"
	color = "#791500"
	alpha = 130

/obj/effect/turf_decal/guideline/guideline_in_arrow_con/purple
	name = "continuous purple in Arrow guideline"
	color = "#D381C9"

/obj/effect/turf_decal/guideline/guideline_in_arrow_con/brown
	name = "continuous brown in Arrow guideline"
	color = "#A46106"

/obj/effect/turf_decal/guideline/guideline_in_arrow_con/neutral
	name = "continuous neutral in Arrow guideline"
	color = "#D4D4D4"
	alpha = 50

/obj/effect/turf_decal/guideline/guideline_in_arrow_con/darkblue
	name = "continuous dark blue in Arrow guideline"
	color = "#334E6D"

/obj/effect/turf_decal/guideline/guideline_in_arrow_con/random // so many colors
	name = "continuous colorful in Arrow guideline"
	color = "#E300FF" //bright pink as default for mapping

/obj/effect/turf_decal/guideline/guideline_in_arrow_con/random/Initialize(mapload)
	color = "#[random_short_color()]"
	. = ..()

//guideline_mid_arrow_con
/obj/effect/turf_decal/guideline/guideline_mid_arrow_con
	name = "continuous guideline mid arrow decal alt"
	icon_state = "guideline_mid_arrow_con"
	layer = TURF_PLATING_DECAL_LAYER

/obj/effect/turf_decal/guideline/guideline_mid_arrow_con/Initialize(mapload)
	if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
		color = "#[random_short_color()]"
	. = ..()

/obj/effect/turf_decal/guideline/guideline_mid_arrow_con/blue
	name = "continuous blue mid arrow guideline"
	color = "#52B4E9"

/obj/effect/turf_decal/guideline/guideline_mid_arrow_con/green
	name = "continuous green mid arrow guideline"
	color = "#9FED58"

/obj/effect/turf_decal/guideline/guideline_mid_arrow_con/yellow
	name = "continuous yellow mid arrow guideline"
	color = "#EFB341"

/obj/effect/turf_decal/guideline/guideline_mid_arrow_con/red
	name = "continuous red mid arrow guideline"
	color = "#DE3A3A"

/obj/effect/turf_decal/guideline/guideline_mid_arrow_con/bar
	name = "continuous bar mid arrow guideline"
	color = "#791500"
	alpha = 130

/obj/effect/turf_decal/guideline/guideline_mid_arrow_con/purple
	name = "continuous purple mid arrow guideline"
	color = "#D381C9"

/obj/effect/turf_decal/guideline/guideline_mid_arrow_con/brown
	name = "continuous brown mid arrow guideline"
	color = "#A46106"

/obj/effect/turf_decal/guideline/guideline_mid_arrow_con/neutral
	name = "continuous neutral mid arrow guideline"
	color = "#D4D4D4"
	alpha = 50

/obj/effect/turf_decal/guideline/guideline_mid_arrow_con/darkblue
	name = "continuous dark blue mid arrow guideline"
	color = "#334E6D"

/obj/effect/turf_decal/guideline/guideline_mid_arrow_con/random // so many colors
	name = "continuous colorful mid arrow guideline"
	color = "#E300FF" //bright pink as default for mapping

/obj/effect/turf_decal/guideline/guideline_mid_arrow_con/random/Initialize(mapload)
	color = "#[random_short_color()]"
	. = ..()

//guideline_out_arrow
/obj/effect/turf_decal/guideline/guideline_out_arrow_con
	name = "continuous guideline out arrow decal alt"
	icon_state = "guideline_out_arrow_con"
	layer = TURF_PLATING_DECAL_LAYER

/obj/effect/turf_decal/guideline/guideline_out_arrow_con/Initialize(mapload)
	if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
		color = "#[random_short_color()]"
	. = ..()

/obj/effect/turf_decal/guideline/guideline_out_arrow_con/blue
	name = "continuous blue out arrow guideline"
	color = "#52B4E9"

/obj/effect/turf_decal/guideline/guideline_out_arrow_con/green
	name = "continuous green out arrow guideline"
	color = "#9FED58"

/obj/effect/turf_decal/guideline/guideline_out_arrow_con/yellow
	name = "continuous yellow out arrow guideline"
	color = "#EFB341"

/obj/effect/turf_decal/guideline/guideline_out_arrow_con/red
	name = "continuous red out arrow guideline"
	color = "#DE3A3A"

/obj/effect/turf_decal/guideline/guideline_out_arrow_con/bar
	name = "continuous bar out arrow guideline"
	color = "#791500"
	alpha = 130

/obj/effect/turf_decal/guideline/guideline_out_arrow_con/purple
	name = "continuous purple out arrow guideline"
	color = "#D381C9"

/obj/effect/turf_decal/guideline/guideline_out_arrow_con/brown
	name = "continuous brown out arrow guideline"
	color = "#A46106"

/obj/effect/turf_decal/guideline/guideline_out_arrow_con/neutral
	name = "continuous neutral out arrow guideline"
	color = "#D4D4D4"
	alpha = 50

/obj/effect/turf_decal/guideline/guideline_out_arrow_con/darkblue
	name = "continuous dark blue out arrow guideline"
	color = "#334E6D"

/obj/effect/turf_decal/guideline/guideline_out_arrow_con/random // so many colors
	name = "colorful out arrow guideline"
	color = "#E300FF" //bright pink as default for mapping

/obj/effect/turf_decal/guideline/guideline_out_arrow_con/random/Initialize(mapload)
	color = "#[random_short_color()]"
	. = ..()
