/////////////////////
// Tile reskinning //
/////////////////////
// Q: What is this?
// A: A simple function to allow you to change what tiles you place with a stack of tiles.
// Q: Why do it this way?
// A: This allows players more freedom to do beautiful-looking builds. Having five types of titanium tile would be clunky as heck.
// Q: Great! Can I use this for all floors?
// A: Unfortunately, this does not work on subtypes of plasteel and instead we must change the icon_state of these turfs instead, as the icon_regular_floor var that "saves" what type of floor a plasteel subtype turf was so once repaired...
// ... it'll go back to the floor it was instead of grey (medical floors turn white even after crowbaring the tile and putting it back). This stops changing turf_type from working.

/obj/item/stack/tile/mineral/titanium/attack_self(mob/user)
	var/static/list/choices = list(
			"Titanium Tile" = image(icon = 'icons/obj/tiles.dmi', icon_state = "tile_shuttle"),
			"Yellow Titanium Tile" = image(icon = 'icons/obj/tiles.dmi', icon_state = "tile_shuttle_yellow"),
			"Blue Titanium Tile" = image(icon = 'icons/obj/tiles.dmi', icon_state = "tile_shuttle_blue"),
			"White Titanium Tile" = image(icon = 'icons/obj/tiles.dmi', icon_state = "tile_shuttle_white"),
			"Purple Titanium Tile" = image(icon = 'icons/obj/tiles.dmi', icon_state = "tile_shuttle_purple"),
			"Titanium" = image(icon = 'icons/obj/tiles.dmi', icon_state = "tile_shuttle_alt"),
			"Yellow Titanium" = image(icon = 'icons/obj/tiles.dmi', icon_state = "tile_shuttle_alt_yellow"),
			"Blue Titanium" = image(icon = 'icons/obj/tiles.dmi', icon_state = "tile_shuttle_alt_blue"),
			"White Titanium" = image(icon = 'icons/obj/tiles.dmi', icon_state = "tile_shuttle_alt_white"),
			"Purple Titanium" = image(icon = 'icons/obj/tiles.dmi', icon_state = "tile_shuttle_alt_purple"),
		)
	var/choice = show_radial_menu(user, src, choices, radius = 48, require_near = TRUE)
	switch(choice)
		if("Titanium Tile")
			turf_type = /turf/open/floor/mineral/titanium
			icon_state = "tile_shuttle"
			desc = "Titanium floor tiles."
		if("Yellow Titanium Tile")
			turf_type = /turf/open/floor/mineral/titanium/yellow
			icon_state = "tile_shuttle_yellow"
			desc = "Yellow titanium floor tiles."
		if("Blue Titanium Tile")
			turf_type = /turf/open/floor/mineral/titanium/blue
			icon_state = "tile_shuttle_blue"
			desc = "Blue titanium floor tiles."
		if("White Titanium Tile")
			turf_type = /turf/open/floor/mineral/titanium/white
			icon_state = "tile_shuttle_white"
			desc = "White titanium floor tiles."
		if("Purple Titanium Tile")
			turf_type = /turf/open/floor/mineral/titanium/purple
			icon_state = "tile_shuttle_purple"
			desc = "Purple titanium floor tiles."
		if("Titanium")
			turf_type = /turf/open/floor/mineral/titanium/alt
			icon_state = "tile_shuttle_alt"
			desc = "Sleek titanium tiles."
		if("Yellow Titanium")
			turf_type = /turf/open/floor/mineral/titanium/alt/yellow
			icon_state = "tile_shuttle_alt_yellow"
			desc = "Sleek yellow titanium tiles."
		if("Blue Titanium")
			turf_type = /turf/open/floor/mineral/titanium/alt/blue
			icon_state = "tile_shuttle_alt_blue"
			desc = "Sleek blue titanium tiles."
		if("White Titanium")
			turf_type = /turf/open/floor/mineral/titanium/alt/white
			icon_state = "tile_shuttle_alt_white"
			desc = "Sleek white titanium tiles."
		if("Purple Titanium")
			turf_type = /turf/open/floor/mineral/titanium/alt/purple
			icon_state = "tile_shuttle_alt_purple"
			desc = "Sleek purple titanium tiles."
