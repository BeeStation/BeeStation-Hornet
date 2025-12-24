// Orbital Visuals HUD System
// Static background system that displays layers based on station altitude

// ============================================================================
// CLIENT VARS
// ============================================================================

/client/var/list/orbital_layers
/client/var/orbital_scroll_direction = 0  // Current scroll direction based on map config

// ============================================================================
// HUD PROCS
// ============================================================================

/datum/hud/proc/create_orbital_visuals(mob/viewmob)
	var/mob/screenmob = viewmob || mymob
	var/client/C = screenmob.client
	if(!C)
		return

	// Clean up any existing layers first
	if(C.orbital_layers)
		C.screen -= C.orbital_layers

	C.orbital_layers = list()

	// Get orbital direction from map config (defaults to EAST if not set)
	if(!C.orbital_scroll_direction)
		C.orbital_scroll_direction = SSmapping.current_map.reentry_direction || EAST

	// Create base space background layer (always visible)
	var/atom/movable/screen/orbital_layer/space_background/base_layer = new
	base_layer.set_new_hud(null)
	base_layer.create_tiled_overlays(C.view)
	C.orbital_layers += base_layer

	// Create stars layer (fades in at high altitudes)
	var/atom/movable/screen/orbital_layer/stars/stars_layer = new
	stars_layer.set_new_hud(null)
	stars_layer.create_tiled_overlays(C.view)
	C.orbital_layers += stars_layer

	// Create atmosphere layer (fades in at high altitudes)
	var/atom/movable/screen/orbital_layer/atmosphere/atmosphere_layer = new
	atmosphere_layer.set_new_hud(null)
	atmosphere_layer.create_tiled_overlays(C.view)
	C.orbital_layers += atmosphere_layer

	// Create fire layer (fades in at high altitudes)
	var/atom/movable/screen/orbital_layer/fire/fire_layer = new
	fire_layer.set_new_hud(null)
	fire_layer.create_tiled_overlays(C.view)
	C.orbital_layers += fire_layer

	// Create auri layer (non-tiled, static horizontal position)
	var/atom/movable/screen/orbital_layer/body/auri/auri_layer = new
	auri_layer.set_new_hud(null)
	C.orbital_layers += auri_layer

	// Create the planets layer (non-tiled, scrolls horizontally across entire screen)
	var/atom/movable/screen/orbital_layer/body/planets/planets_layer = new
	planets_layer.set_new_hud(null)
	C.orbital_layers += planets_layer

	C.screen |= C.orbital_layers

	// Set the space plane to white for visibility
	var/atom/movable/screen/plane_master/PM = screenmob.hud_used?.plane_masters["[PLANE_SPACE]"]
	if(PM)
		PM.color = list(
			0, 0, 0, 0,
			0, 0, 0, 0,
			0, 0, 0, 0,
			1, 1, 1, 1,
			0, 0, 0, 0
		)

	// Start the orbital scrolling animation
	start_orbital_scroll(C)

/datum/hud/proc/update_orbital_visuals(mob/viewmob)
	var/mob/screenmob = viewmob || mymob
	var/client/C = screenmob.client
	if(!C || !C.orbital_layers)
		return

	// Get current altitude from the orbital altitude subsystem
	var/current_altitude = SSorbital_altitude.orbital_altitude

	// Update each layer based on altitude
	for(var/atom/movable/screen/orbital_layer/layer in C.orbital_layers)
		layer.update_for_altitude(current_altitude, C)

/// Starts the continuous scrolling animation for orbital layers
/datum/hud/proc/start_orbital_scroll(client/C)
	if(!C || !C.orbital_layers)
		return

	// Calculate screen dimensions for non-tiled scrolling
	var/list/viewscales = getviewsize(C.view)
	var/screen_width = viewscales[1] * world.icon_size
	var/screen_height = viewscales[2] * world.icon_size

	// Apply scrolling animation only to layers marked for scrolling
	var/scrolling_layers = 0
	for(var/atom/movable/screen/orbital_layer/layer in C.orbital_layers)
		if(!layer.should_scroll)
			continue  // Skip layers that aren't marked for scrolling

		scrolling_layers++

		// Determine scroll direction (use layer's direction, or fall back to reentry direction)
		var/layer_scroll_direction = layer.scroll_direction || C.orbital_scroll_direction
		if(!layer_scroll_direction)
			continue

		// Tiled layers scroll by one tile (480px), non-tiled scroll across entire screen
		var/scroll_distance
		if(layer.is_tiled)
			scroll_distance = 480  // One tile width
		else
			// Non-tiled: scroll from completely offscreen on one side to completely offscreen on the other
			// For a 960px sprite: screen_width + (sprite_width on left) + (sprite_width on right)
			// This ensures the sprite enters from one edge and exits completely on the other before looping
			scroll_distance = (layer_scroll_direction & (NORTH|SOUTH)) ? (screen_height + 960) : (screen_width + 960)

		// Get vertical offset for body layers (they need to maintain altitude-based positioning)
		var/vertical_offset = 0
		if(istype(layer, /atom/movable/screen/orbital_layer/body))
			var/atom/movable/screen/orbital_layer/body/body_layer = layer
			vertical_offset = body_layer.current_vertical_offset

		// Set up the transform matrices based on scroll direction
		var/matrix/start_transform
		var/matrix/end_transform

		if(layer.is_tiled)
			// Tiled layers: scroll from base to offset, then instantly reset
			switch(layer_scroll_direction)
				if(NORTH)
					start_transform = matrix(1, 0, 0, 0, 1, vertical_offset)
					end_transform = matrix(1, 0, 0, 0, 1, scroll_distance + vertical_offset)
				if(SOUTH)
					start_transform = matrix(1, 0, 0, 0, 1, vertical_offset)
					end_transform = matrix(1, 0, 0, 0, 1, -scroll_distance + vertical_offset)
				if(EAST)
					start_transform = matrix(1, 0, 0, 0, 1, vertical_offset)
					end_transform = matrix(1, 0, scroll_distance, 0, 1, vertical_offset)
				if(WEST)
					start_transform = matrix(1, 0, 0, 0, 1, vertical_offset)
					end_transform = matrix(1, 0, -scroll_distance, 0, 1, vertical_offset)
		else
			// Non-tiled layers: scroll from -offset (offscreen on one side) to +offset (offscreen on other side)
			// This makes the sprite appear from one edge, cross the screen, and disappear on the other edge
			switch(layer_scroll_direction)
				if(NORTH)
					start_transform = matrix(1, 0, 0, 0, 1, -(scroll_distance/2) + vertical_offset)
					end_transform = matrix(1, 0, 0, 0, 1, (scroll_distance/2) + vertical_offset)
				if(SOUTH)
					start_transform = matrix(1, 0, 0, 0, 1, (scroll_distance/2) + vertical_offset)
					end_transform = matrix(1, 0, 0, 0, 1, -(scroll_distance/2) + vertical_offset)
				if(EAST)
					start_transform = matrix(1, 0, -(scroll_distance/2), 0, 1, vertical_offset)
					end_transform = matrix(1, 0, (scroll_distance/2), 0, 1, vertical_offset)
				if(WEST)
					start_transform = matrix(1, 0, (scroll_distance/2), 0, 1, vertical_offset)
					end_transform = matrix(1, 0, -(scroll_distance/2), 0, 1, vertical_offset)

		// Start at starting position
		layer.transform = start_transform

		// Animate to the end position, then instantly reset to start and loop
		animate(layer, transform = end_transform, time = layer.scroll_time, loop = -1, easing = LINEAR_EASING)
		animate(transform = start_transform, time = 0, loop = -1, easing = LINEAR_EASING)

	// Debug output
	if(scrolling_layers > 0)
		to_chat(C, "<span class='notice'>Started orbital scrolling on [scrolling_layers] layer(s)</span>")

// ============================================================================
// ORBITAL LAYER BASE CLASS
// ============================================================================

/atom/movable/screen/orbital_layer
	icon = 'icons/effects/space_background.dmi'
	blend_mode = BLEND_ADD
	plane = PLANE_SPACE_BACKGROUND
	screen_loc = "CENTER-7,CENTER-7"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	/// Whether this layer should scroll based on orbital direction
	var/should_scroll = FALSE
	/// Time for one complete scroll cycle in deciseconds (lower = faster)
	var/scroll_time = 20 SECONDS  // 20 seconds for one complete cycle
	/// Direction to scroll (NORTH, SOUTH, EAST, WEST). If null, uses map's reentry direction
	var/scroll_direction = null
	/// Whether this layer uses tiling (repeating texture) or is a single sprite
	var/is_tiled = FALSE

CREATION_TEST_IGNORE_SUBTYPES(/atom/movable/screen/orbital_layer)

/atom/movable/screen/orbital_layer/Initialize(mapload, hud_owner)
	. = ..()
	// Don't call create_tiled_overlays here - it will be called manually after creation

/// Creates tiled overlays to make the sprite repeat across the entire screen
/// This takes a single 480x480 sprite and tiles it to fill the client's view
/atom/movable/screen/orbital_layer/proc/create_tiled_overlays(view)
	if(!view)
		view = world.view

	// Mark this layer as tiled
	is_tiled = TRUE

	// Calculate how many tiles we need in each direction based on view size
	var/list/viewscales = getviewsize(view)
	var/countx = CEILING((viewscales[1]/2)/(480/world.icon_size), 1) + 1
	var/county = CEILING((viewscales[2]/2)/(480/world.icon_size), 1) + 1

	// Set icon and icon_state explicitly to ensure they render
	icon = initial(icon)
	icon_state = initial(icon_state)

	// Create overlays for each tile position (skip center as base icon_state handles it)
	var/list/new_overlays = list()
	for(var/x in -countx to countx)
		for(var/y in -county to county)
			if(x == 0 && y == 0)
				continue // Skip center tile (that's the base icon_state)
			var/mutable_appearance/texture_overlay = mutable_appearance(icon, icon_state)
			texture_overlay.transform = matrix(1, 0, x * 480, 0, 1, y * 480)
			new_overlays += texture_overlay

	cut_overlays()
	add_overlay(new_overlays)

/// Updates the layer's appearance based on current orbital altitude
/// Override this in subtypes to define altitude-based behavior
/atom/movable/screen/orbital_layer/proc/update_for_altitude(altitude, client/C)
	return

/// Restarts the scrolling animation with updated vertical offset (for body layers)
/atom/movable/screen/orbital_layer/proc/restart_scroll_animation(client/C)
	if(!should_scroll || !C)
		return

	// Determine scroll direction
	var/layer_scroll_direction = scroll_direction || C.orbital_scroll_direction
	if(!layer_scroll_direction)
		return

	// Get vertical offset for body layers
	var/vertical_offset = 0
	if(istype(src, /atom/movable/screen/orbital_layer/body))
		var/atom/movable/screen/orbital_layer/body/body_layer = src
		vertical_offset = body_layer.current_vertical_offset

	// Calculate scroll distance based on whether layer is tiled
	var/scroll_distance
	if(is_tiled)
		scroll_distance = 480  // One tile width
	else
		// Non-tiled: scroll across screen width/height only (sprite starts offscreen on one side, ends offscreen on other)
		// The distance should be screen dimension + (2 * sprite size) to account for starting and ending offscreen
		var/list/viewscales = getviewsize(C.view)
		var/screen_width = viewscales[1] * world.icon_size
		var/screen_height = viewscales[2] * world.icon_size
		scroll_distance = (layer_scroll_direction & (NORTH|SOUTH)) ? (screen_height + 960) : (screen_width + 960)

	// Set up the transform matrices based on scroll direction
	var/matrix/start_transform
	var/matrix/end_transform

	if(is_tiled)
		// Tiled layers: scroll from base to offset, then instantly reset
		switch(layer_scroll_direction)
			if(NORTH)
				start_transform = matrix(1, 0, 0, 0, 1, vertical_offset)
				end_transform = matrix(1, 0, 0, 0, 1, scroll_distance + vertical_offset)
			if(SOUTH)
				start_transform = matrix(1, 0, 0, 0, 1, vertical_offset)
				end_transform = matrix(1, 0, 0, 0, 1, -scroll_distance + vertical_offset)
			if(EAST)
				start_transform = matrix(1, 0, 0, 0, 1, vertical_offset)
				end_transform = matrix(1, 0, scroll_distance, 0, 1, vertical_offset)
			if(WEST)
				start_transform = matrix(1, 0, 0, 0, 1, vertical_offset)
				end_transform = matrix(1, 0, -scroll_distance, 0, 1, vertical_offset)
	else
		// Non-tiled layers: scroll from -offset to +offset
		switch(layer_scroll_direction)
			if(NORTH)
				start_transform = matrix(1, 0, 0, 0, 1, -(scroll_distance/2) + vertical_offset)
				end_transform = matrix(1, 0, 0, 0, 1, (scroll_distance/2) + vertical_offset)
			if(SOUTH)
				start_transform = matrix(1, 0, 0, 0, 1, (scroll_distance/2) + vertical_offset)
				end_transform = matrix(1, 0, 0, 0, 1, -(scroll_distance/2) + vertical_offset)
			if(EAST)
				start_transform = matrix(1, 0, -(scroll_distance/2), 0, 1, vertical_offset)
				end_transform = matrix(1, 0, (scroll_distance/2), 0, 1, vertical_offset)
			if(WEST)
				start_transform = matrix(1, 0, (scroll_distance/2), 0, 1, vertical_offset)
				end_transform = matrix(1, 0, -(scroll_distance/2), 0, 1, vertical_offset)

	// Stop any existing animation
	animate(src)

	// Start at starting position
	transform = start_transform

	// Animate to the end position, then instantly reset to start and loop
	animate(src, transform = end_transform, time = scroll_time, loop = -1, easing = LINEAR_EASING)
	animate(transform = start_transform, time = 0, loop = -1, easing = LINEAR_EASING)

// ============================================================================
// SPACE BACKGROUND LAYER
// ============================================================================

/atom/movable/screen/orbital_layer/space_background
	icon_state = "space_background"
	blend_mode = BLEND_DEFAULT

/atom/movable/screen/orbital_layer/space_background/update_for_altitude(altitude, client/C)
	// Space background is always fully visible
	alpha = 255

// ============================================================================
// STARS LAYER
// ============================================================================

/atom/movable/screen/orbital_layer/stars
	icon_state = "stars"
	blend_mode = BLEND_ADD

/atom/movable/screen/orbital_layer/stars/update_for_altitude(altitude, client/C)
	// Stars layer: fully visible from ORBITAL_ALTITUDE_HIGH_BOUND down to ORBITAL_ALTITUDE_HIGH
	// Fades out below ORBITAL_ALTITUDE_HIGH

	if(altitude >= ORBITAL_ALTITUDE_HIGH)
		// Above HIGH altitude, stars are fully visible
		alpha = 255
	else if(altitude >= ORBITAL_ALTITUDE_DEFAULT)
		// Between DEFAULT and HIGH, fade out stars
		// Calculate fade percentage (0 to 1)
		var/fade_range = ORBITAL_ALTITUDE_HIGH - ORBITAL_ALTITUDE_DEFAULT
		var/fade_progress = (altitude - ORBITAL_ALTITUDE_DEFAULT) / fade_range
		alpha = fade_progress * 255
	else
		// Below DEFAULT altitude, stars are invisible
		alpha = 0

// ============================================================================
// ATMOSPHERIC LAYER
// ============================================================================

/atom/movable/screen/orbital_layer/atmosphere
	icon_state = "atmosphere"
	blend_mode = BLEND_ADD
	should_scroll = TRUE
	scroll_time = 5 SECONDS  // Faster scroll for testing/visibility

/atom/movable/screen/orbital_layer/atmosphere/update_for_altitude(altitude, client/C)
	// Atmosphere layer: fully visible from ORBITAL_ALTITUDE_LOW_BOUND up to ORBITAL_ALTITUDE_LOW
	// Fades out above ORBITAL_ALTITUDE_LOW
	if(altitude <= ORBITAL_ALTITUDE_LOW)
		// Below LOW altitude, atmosphere is fully visible
		alpha = 255
	else if(altitude <= ORBITAL_ALTITUDE_DEFAULT)
		// Between LOW and DEFAULT, fade out atmosphere
		// Calculate fade percentage (0 to 1, where 1 is fully visible)
		var/fade_range = ORBITAL_ALTITUDE_DEFAULT - ORBITAL_ALTITUDE_LOW
		var/fade_progress = (altitude - ORBITAL_ALTITUDE_LOW) / fade_range
		alpha = (1 - fade_progress) * 255  // Invert so it fades OUT as altitude increases
	else
		// Above DEFAULT altitude, atmosphere is invisible
		alpha = 0

// ============================================================================
// RE-ENTRY FLAME LAYER
// ============================================================================

/atom/movable/screen/orbital_layer/fire
	icon_state = "fire"
	blend_mode = BLEND_OVERLAY  // Opaque overlay, not additive

/atom/movable/screen/orbital_layer/fire/update_for_altitude(altitude, client/C)
	// Fire layer: fully visible below ORBITAL_ALTITUDE_LOW_CRITICAL
	// Fades out above ORBITAL_ALTITUDE_LOW_CRITICAL
	if(altitude <= ORBITAL_ALTITUDE_LOW_CRITICAL)
		// Below LOW_CRITICAL altitude, fire is fully visible
		alpha = 255
	else if(altitude <= ORBITAL_ALTITUDE_LOW)
		// Between LOW_CRITICAL and LOW, fade out fire
		// Calculate fade percentage (0 to 1, where 1 is fully visible)
		var/fade_range = ORBITAL_ALTITUDE_LOW - ORBITAL_ALTITUDE_LOW_CRITICAL
		var/fade_progress = (altitude - ORBITAL_ALTITUDE_LOW_CRITICAL) / fade_range
		alpha = (1 - fade_progress) * 255  // Invert so it fades OUT as altitude increases
	else
		// Above LOW altitude, fire is invisible
		alpha = 0

// ============================================================================
// CELESTIAL BODY BASE LAYER (NON-TILED, DISAPPEARS INTO TOP)
// ============================================================================

/atom/movable/screen/orbital_layer/body
	blend_mode = BLEND_OVERLAY  // Opaque overlay, not additive
	should_scroll = FALSE  // Override in subtypes if scrolling is desired
	/// Altitude at which body is at maximum height (moved upward, station at default altitude)
	var/altitude_max_height = ORBITAL_ALTITUDE_DEFAULT  // 110km
	/// Altitude at which body is at lowest position on screen (fully visible at bottom)
	var/altitude_lowest = ORBITAL_ALTITUDE_HIGH_CRITICAL  // 130km
	/// How far the body moves vertically (in pixels) between lowest and max height
	var/vertical_movement_distance = 500
	/// Cached vertical offset for use when scrolling is enabled
	var/current_vertical_offset = 0

/atom/movable/screen/orbital_layer/body/update_for_altitude(altitude, client/C)
	// Body is always visible (alpha = 255), but moves vertically based on altitude
	alpha = 255

	// Store the previous vertical offset to check if it changed
	var/old_vertical_offset = current_vertical_offset

	// Calculate vertical offset based on altitude
	if(altitude >= altitude_lowest)
		// At or above altitude_lowest (130km) - body is at lowest position (0 offset)
		current_vertical_offset = 0
	else if(altitude >= altitude_max_height)
		// Between altitude_max_height (110km) and altitude_lowest (130km) - body is moving upward
		var/movement_range = altitude_lowest - altitude_max_height
		var/movement_progress = (altitude_lowest - altitude) / movement_range
		// movement_progress goes from 0 (at altitude_lowest) to 1 (at altitude_max_height)
		// Interpolate from 0 (lowest position) to vertical_movement_distance (maximum height)
		current_vertical_offset = movement_progress * vertical_movement_distance
	else
		// Below altitude_max_height (110km) - body is at maximum height
		current_vertical_offset = vertical_movement_distance

	// If scrolling and vertical offset changed, restart the animation
	if(should_scroll && old_vertical_offset != current_vertical_offset && C)
		restart_scroll_animation(C)
	// Only update transform if we're not scrolling (scrolling animation handles transform)
	else if(!should_scroll)
		transform = matrix(1, 0, 0, 0, 1, current_vertical_offset)

// ============================================================================
// SUN LAYER (STATIC POSITION)
// ============================================================================

/atom/movable/screen/orbital_layer/body/auri
	icon_state = "auri"
	should_scroll = FALSE  // Auri doesn't scroll

// ============================================================================
// PLANETS LAYER (SCROLLS HORIZONTALLY)
// ============================================================================

/atom/movable/screen/orbital_layer/body/planets
	icon_state = "planets"
	should_scroll = TRUE  // Planet scrolls across the sky
	scroll_time = 200 SECONDS  // Slow, majestic scroll across the sky
	scroll_direction = EAST  // Scrolls horizontally to the east
