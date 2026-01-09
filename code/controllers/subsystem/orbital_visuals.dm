// Orbital visual states
#define ORBITAL_STATE_NORMAL "normal"
#define ORBITAL_STATE_ATMOSPHERIC_DESCENT "atmospheric_descent"
#define ORBITAL_STATE_REENTRY_WARNING "reentry_warning"
#define ORBITAL_STATE_REENTRY "reentry"

SUBSYSTEM_DEF(orbital_visuals)
	name = "Orbital Visuals"
	can_fire = TRUE
	wait = 0.1
	flags = SS_POST_FIRE_TIMING | SS_BACKGROUND | SS_NO_INIT
	priority = FIRE_PRIORITY_SPACE_BACKGROUND
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT

	// ============================================================================
	// STARLIGHT STATE SYSTEM
	// ============================================================================

	/// Current visual state
	var/current_state = ORBITAL_STATE_NORMAL
	/// Whether starlight control is overridden (like aurora caelus)
	var/starlight_override = FALSE
	/// Target color for starlight in current state
	var/target_starlight_color = COLOR_STARLIGHT

	// Re-entry effects
	/// Current intensity of re-entry flicker (0-1)
	var/reentry_flicker_intensity = 0
	/// Whether we're currently flickering (for re-entry effects)
	var/is_flickering = FALSE

/datum/controller/subsystem/orbital_visuals/fire(resumed = FALSE)
	// Get current altitude
	var/current_altitude = SSorbital_altitude.orbital_altitude

	// Update state based on altitude (unless overridden)
	if(!starlight_override)
		update_visual_state(current_altitude)

	// Update all connected clients' orbital visual layers based on altitude
	for(var/client/C in GLOB.clients)
		if(!C?.mob?.hud_used)
			continue

		// Update orbital visuals - each layer adjusts its alpha based on altitude
		C.mob.hud_used.update_orbital_visuals()

// ============================================================================
// STATE MANAGEMENT
// ============================================================================

/// Updates the current visual state based on altitude
/datum/controller/subsystem/orbital_visuals/proc/update_visual_state(altitude)
	var/new_state = current_state

	// Determine state based on altitude thresholds
	if(altitude >= ORBITAL_ALTITUDE_HIGH)
		// Above 120km - normal starlight
		new_state = ORBITAL_STATE_NORMAL
	else if(altitude >= ORBITAL_ALTITUDE_LOW)
		// 95km - 120km - atmospheric descent with brightening
		new_state = ORBITAL_STATE_ATMOSPHERIC_DESCENT
	else if(altitude >= ORBITAL_ALTITUDE_LOW_CRITICAL)
		// 90km - 95km - pre-reentry warning, start flickering
		new_state = ORBITAL_STATE_REENTRY_WARNING
	else
		// Below 90km - full re-entry
		new_state = ORBITAL_STATE_REENTRY

	// State changed - trigger transition
	if(new_state != current_state)
		current_state = new_state
		on_state_change(altitude)
	else
		// Update effects within current state
		update_state_effects(altitude)

/// Called when the visual state changes
/datum/controller/subsystem/orbital_visuals/proc/on_state_change(altitude)
	switch(current_state)
		if(ORBITAL_STATE_NORMAL)
			start_normal_starlight()
		if(ORBITAL_STATE_ATMOSPHERIC_DESCENT)
			start_atmospheric_descent(altitude)
		if(ORBITAL_STATE_REENTRY_WARNING)
			start_reentry_warning(altitude)
		if(ORBITAL_STATE_REENTRY)
			start_reentry(altitude)

/// Updates effects continuously within the current state
/datum/controller/subsystem/orbital_visuals/proc/update_state_effects(altitude)
	switch(current_state)
		if(ORBITAL_STATE_NORMAL)
			// Normal starlight can be tied to time of day here if desired
			update_normal_starlight()
		if(ORBITAL_STATE_ATMOSPHERIC_DESCENT)
			// Gradually increase brightness as we descend
			update_atmospheric_descent(altitude)
		if(ORBITAL_STATE_REENTRY_WARNING)
			// Increase flicker intensity as we approach 90km
			update_reentry_warning(altitude)
		if(ORBITAL_STATE_REENTRY)
			// Violent flickering during re-entry
			update_reentry(altitude)

// ============================================================================
// NORMAL STARLIGHT STATE
// ============================================================================

/datum/controller/subsystem/orbital_visuals/proc/start_normal_starlight()
	is_flickering = FALSE
	reentry_flicker_intensity = 0
	// Could integrate with time of day here if desired
	set_orbital_starlight_colour(COLOR_STARLIGHT, 3 SECONDS)

/datum/controller/subsystem/orbital_visuals/proc/update_normal_starlight()
	// Optional: Tie to time of day by checking SSnatural_light_cycle
	// For now, just maintain normal starlight
	return

// ============================================================================
// ATMOSPHERIC DESCENT STATE (95km - 120km)
// ============================================================================

/datum/controller/subsystem/orbital_visuals/proc/start_atmospheric_descent(altitude)
	is_flickering = FALSE
	reentry_flicker_intensity = 0
	// Start transitioning to atmosphere-tinted starlight
	update_atmospheric_descent(altitude)

/datum/controller/subsystem/orbital_visuals/proc/update_atmospheric_descent(altitude)
	// Calculate descent progress (0 to 1, where 0 is at 120km and 1 is at 110km)
	var/descent_range = ORBITAL_ALTITUDE_HIGH - ORBITAL_ALTITUDE_DEFAULT // 120km - 110km
	var/descent_progress = clamp((ORBITAL_ALTITUDE_HIGH - altitude) / descent_range, 0, 1)

	// Blend from normal starlight to brighter, atmosphere-tinted starlight
	var/atmospheric_tint = "#A8C5E8" // Light blue atmospheric tint
	var/blended_color = BlendRGB(COLOR_STARLIGHT, atmospheric_tint, descent_progress)

	// Increase brightness as we descend (simulating more atmospheric scattering)
	// We do this by lightening the color
	var/brightness_boost = descent_progress * 0.3 // Up to 30% brighter
	blended_color = LightenRGB(blended_color, brightness_boost)

	set_orbital_starlight_colour(blended_color, 1 SECONDS)

// ============================================================================
// REENTRY WARNING STATE (95km - 90km)
// ============================================================================

/datum/controller/subsystem/orbital_visuals/proc/start_reentry_warning(altitude)
	is_flickering = TRUE
	update_reentry_warning(altitude)

/datum/controller/subsystem/orbital_visuals/proc/update_reentry_warning(altitude)
	// Calculate warning progress (0 to 1, where 0 is at 95km and 1 is at 90km)
	var/warning_range = ORBITAL_ALTITUDE_LOW - ORBITAL_ALTITUDE_LOW_CRITICAL
	var/warning_progress = clamp((ORBITAL_ALTITUDE_LOW - altitude) / warning_range, 0, 1)

	reentry_flicker_intensity = warning_progress

	// Flicker between atmospheric blue and orange/red
	var/base_color = "#A8C5E8" // Atmospheric blue
	var/flicker_color = pick("#FFA500", "#FF6B00", "#FF4500") // Orange to red-orange

	// Blend based on random flicker and intensity
	var/flicker_amount = warning_progress * prob(50 + (warning_progress * 50)) // Increasingly frequent flickers
	var/current_color = flicker_amount ? flicker_color : base_color

	set_orbital_starlight_colour(current_color, 0.3 SECONDS)

// ============================================================================
// FULL REENTRY STATE (below 90km)
// ============================================================================

/datum/controller/subsystem/orbital_visuals/proc/start_reentry(altitude)
	is_flickering = TRUE
	reentry_flicker_intensity = 1.0
	update_reentry(altitude)

/datum/controller/subsystem/orbital_visuals/proc/update_reentry(altitude)
	// Calculate how deep into re-entry we are (0 to 1, where 0 is at 90km and 1 is at 80km)
	var/reentry_depth = clamp((ORBITAL_ALTITUDE_LOW_CRITICAL - altitude) / (ORBITAL_ALTITUDE_LOW_CRITICAL - ORBITAL_ALTITUDE_LOW_BOUND), 0, 1)

	// Violent flickering between different intensities of orange and red
	var/list/reentry_colors = list(
		"#FF4500", // Red-orange
		"#FF6B00", // Orange-red
		"#FF8C00", // Dark orange
		"#FFA500", // Orange
		"#FF0000", // Pure red (rare, intense moments)
	)

	// Pick more intense colors as we descend deeper
	var/color_index = clamp(round(reentry_depth * (length(reentry_colors) - 1)) + 1, 1, length(reentry_colors))
	var/current_color = reentry_colors[color_index]

	// Add some random variation for violence
	if(prob(30 + (reentry_depth * 40))) // Increasingly chaotic
		current_color = pick(reentry_colors)

	set_orbital_starlight_colour(current_color, 0.2 SECONDS)

// ============================================================================
// OVERRIDE CONTROLS (for events like aurora caelus)
// ============================================================================

/// Enable starlight override - prevents the subsystem from changing starlight
/datum/controller/subsystem/orbital_visuals/proc/enable_starlight_override()
	starlight_override = TRUE

/// Disable starlight override - allows the subsystem to control starlight again
/datum/controller/subsystem/orbital_visuals/proc/disable_starlight_override()
	starlight_override = FALSE
	// Immediately update to current state
	update_visual_state(SSorbital_altitude.orbital_altitude)

// Helper proc to lighten a color
/proc/LightenRGB(color, amount)
	var/r = GETREDPART(color)
	var/g = GETGREENPART(color)
	var/b = GETBLUEPART(color)

	// Lighten by moving towards white (255)
	r = clamp(r + ((255 - r) * amount), 0, 255)
	g = clamp(g + ((255 - g) * amount), 0, 255)
	b = clamp(b + ((255 - b) * amount), 0, 255)

	return rgb(r, g, b)

#undef ORBITAL_STATE_NORMAL
#undef ORBITAL_STATE_ATMOSPHERIC_DESCENT
#undef ORBITAL_STATE_REENTRY_WARNING
#undef ORBITAL_STATE_REENTRY
