// ============================================================================
// CLIENT VARS
// ============================================================================

/client/var/list/orbital_layers

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

	// Create bodies layer (non-tiled, vertical movement based on altitude)
	var/atom/movable/screen/orbital_layer/bodies/bodies_layer = new
	bodies_layer.set_new_hud(null)
	C.orbital_layers += bodies_layer

	C.screen |= C.orbital_layers

	// Set the space plane to white
	var/atom/movable/screen/plane_master/PM = screenmob.hud_used?.plane_masters["[PLANE_SPACE]"]
	if(PM)
		PM.color = list(
			0, 0, 0, 0,
			0, 0, 0, 0,
			0, 0, 0, 0,
			1, 1, 1, 1,
			0, 0, 0, 0
		)

	// Start any orbital scrolling animations
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

	// Apply scrolling animation only to layers marked for scrolling
	for(var/atom/movable/screen/orbital_layer/layer in C.orbital_layers)
		if(!layer.should_scroll)
			continue  // Skip layers that aren't marked for scrolling

		// Only apply scroll to tiled layers
		if(!layer.is_tiled)
			continue

		// scroll direction fall back to map's reentry direction if null
		var/scroll_dir = layer.scroll_direction

		if(isnull(scroll_dir))
			scroll_dir = SSmapping.current_map?.reentry_direction

		if(!scroll_dir)
			continue // Boohoo no scrolling for you.

		// Set up the transform matrices based on scroll direction
		var/matrix/start_transform
		var/matrix/end_transform

		switch(layer.scroll_direction)
			if(NORTH)
				start_transform = matrix()
				end_transform = matrix(1, 0, 0, 0, 1, 480)
			if(SOUTH)
				start_transform = matrix()
				end_transform = matrix(1, 0, 0, 0, 1, -480)
			if(EAST)
				start_transform = matrix()
				end_transform = matrix(1, 0, 480, 0, 1, 0)
			if(WEST)
				start_transform = matrix()
				end_transform = matrix(1, 0, -480, 0, 1, 0)

		// Start at starting position
		layer.transform = start_transform

		// Animate to the end position, then instantly reset to start and loop
		animate(layer, transform = end_transform, time = layer.scroll_time, loop = -1, easing = LINEAR_EASING)
		animate(transform = start_transform, time = 0, loop = -1, easing = LINEAR_EASING)

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
	/// Time for animate() to do one complete scroll cycle in deciseconds (lower = faster).
	var/scroll_time = 20 SECONDS
	/// Direction to scroll (NORTH, SOUTH, EAST, WEST). If null, uses map's reentry direction
	var/scroll_direction = null

	// Backend.
	/// Whether this layer uses tiling (repeating texture) or is a single sprite. Do not set this, call create_tiled_overlays. It will handle it.
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

/atom/movable/screen/orbital_layer/bodies
	icon_state = "bodies"
	blend_mode = BLEND_OVERLAY  // Opaque overlay, not additive
	should_scroll = FALSE  // Never set this! Only tiled layers scroll!
	/// Altitude at which body is at maximum height (moved upward, station at default altitude)
	var/altitude_max_height = ORBITAL_ALTITUDE_DEFAULT  // 110km
	/// Altitude at which body is at lowest position on screen (fully visible)
	var/altitude_lowest = ORBITAL_ALTITUDE_HIGH_CRITICAL  // 130km
	/// How far the body moves vertically (in pixels) between lowest and max height
	var/vertical_movement_distance = 500

/atom/movable/screen/orbital_layer/bodies/update_for_altitude(altitude, client/C)
	// Calculate vertical offset based on altitude
	var/vertical_offset = 0
	if(altitude >= altitude_lowest)
		vertical_offset = 0
	else if(altitude >= altitude_max_height)
		var/movement_range = altitude_lowest - altitude_max_height
		var/movement_progress = (altitude_lowest - altitude) / movement_range
		vertical_offset = movement_progress * vertical_movement_distance
	else
		vertical_offset = vertical_movement_distance

	// Use transform for vertical positioning if not scrolling
	if(!should_scroll)
		transform = matrix(1, 0, 0, 0, 1, vertical_offset)
