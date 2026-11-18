// Plane masters take their group and plane through Initialize, which would be delayed without this
INITIALIZE_IMMEDIATE(/atom/movable/screen/plane_master)
/atom/movable/screen/plane_master
	screen_loc = "CENTER"
	icon_state = "blank"
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	blend_mode = BLEND_OVERLAY
	plane = LOWEST_EVER_PLANE
	var/show_alpha = 255
	var/hide_alpha = 0

	/// The plane master group we're a member of, our "home"
	var/datum/plane_master_group/home

	//--rendering relay vars--
	/// list of planes we will relay this plane's render to
	var/list/render_relay_planes = list(RENDER_PLANE_GAME)
	/// blend mode to apply to the render relay in case you dont want to use the plane_masters blend_mode
	var/blend_mode_override
	/// list of current relays this plane is utilizing to render
	var/list/atom/movable/render_plane_relay/relays = list()

/atom/movable/screen/plane_master/Initialize(mapload, datum/hud/hud_owner, datum/plane_master_group/home, plane_override)
	. = ..()
	// Set before the relays exist, the generated render target is named after us
	if(!isnull(plane_override))
		plane = plane_override
		name = "[name] [plane]"
	set_home(home)
	generate_render_relays()

/atom/movable/screen/plane_master/Destroy()
	if(home)
		// NOTE! We do not clear ourselves from client screens
		// We relay on whoever qdel'd us to reset our hud, and properly purge us
		home.plane_masters -= "[plane]"
		home = null
	QDEL_LIST(relays)
	return ..()

/// Sets the plane group that owns us, it also determines what screen we render to
/atom/movable/screen/plane_master/proc/set_home(datum/plane_master_group/home)
	src.home = home
	if(home.map)
		assigned_map = home.map
		screen_loc = "[home.map]:[screen_loc]"

/atom/movable/screen/plane_master/proc/Show(override)
	alpha = override || show_alpha

/atom/movable/screen/plane_master/proc/Hide(override)
	alpha = override || hide_alpha

/// Shows this plane master and its relays to the passed in mob, and applies its effects
/// Override this to apply unique effects and such
/atom/movable/screen/plane_master/proc/show_to(mob/mymob)
	SHOULD_CALL_PARENT(TRUE)
	update_effects(mymob)
	var/client/our_client = mymob?.client
	if(!our_client)
		return
	var/relay_loc = get_relay_loc(our_client)
	for(var/atom/movable/render_plane_relay/relay as anything in relays)
		relay.screen_loc = relay_loc
	our_client.screen += src
	our_client.screen += relays

/// Hides a plane master from the passeed in mob
/// Do your effect cleanup here
/atom/movable/screen/plane_master/proc/hide_from(mob/oldmob)
	SHOULD_CALL_PARENT(TRUE)
	hide_from_client(oldmob?.client)

/// Removes this plane master and its relays from the passed in client's screen
/atom/movable/screen/plane_master/proc/hide_from_client(client/their_client)
	if(!their_client)
		return
	their_client.screen -= src
	their_client.screen -= relays

/// Returns the screen_loc our relays should use for the passed in client
/atom/movable/screen/plane_master/proc/get_relay_loc(client/viewer)
	if(home.map)
		return "[home.map]:1,1"
	return (viewer.byond_version > 515) ? "1,1" : "CENTER"

/// Applies the filters and other effects that depend on the viewer's preferences.
/// Preference toggles call this directly, to refresh effects without reshowing anything.
/atom/movable/screen/plane_master/proc/update_effects(mob/mymob)
	SHOULD_CALL_PARENT(TRUE)
	return

///Contains just the floor
/atom/movable/screen/plane_master/floor
	name = "floor plane master"
	plane = FLOOR_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_OVERLAY

/atom/movable/screen/plane_master/floor/update_effects(mob/mymob)
	. = ..()
	remove_filter("openspace_shadow")
	var/low_graphics_quality = mymob.client?.prefs?.read_player_preference(/datum/preference/toggle/low_graphics_quality)
	if (low_graphics_quality)
		return
	if(istype(mymob) && mymob.client?.prefs?.read_player_preference(/datum/preference/toggle/ambient_occlusion))
		add_filter("openspace_shadow", 2, drop_shadow_filter(color = "#04080FAA", size = 10))

///Contains most things in the game world
/atom/movable/screen/plane_master/game_world
	name = "game world plane master"
	plane = GAME_PLANE
	render_target = GAME_PLANE_RENDER_TARGET
	appearance_flags = PLANE_MASTER //should use client color
	blend_mode = BLEND_OVERLAY

/atom/movable/screen/plane_master/game_world/update_effects(mob/mymob)
	. = ..()
	remove_filter("AO")
	var/low_graphics_quality = mymob.client?.prefs?.read_player_preference(/datum/preference/toggle/low_graphics_quality)
	if(istype(mymob) && mymob.client?.prefs?.read_player_preference(/datum/preference/toggle/ambient_occlusion) && !low_graphics_quality)
		add_filter("AO", 1, drop_shadow_filter(x = 0, y = -2, size = 4, color = "#04080FAA"))

/atom/movable/screen/plane_master/game_world_above
	name = "above game world plane master"
	plane = ABOVE_GAME_PLANE
	render_relay_planes = list(GAME_PLANE)
	appearance_flags = PLANE_MASTER //should use client color
	blend_mode = BLEND_OVERLAY

/atom/movable/screen/plane_master/data_hud
	name = "data hud plane master"
	plane = DATA_HUD_PLANE
	appearance_flags = PLANE_MASTER //should use client color
	blend_mode = BLEND_OVERLAY

/atom/movable/screen/plane_master/massive_obj
	name = "massive object plane master"
	plane = MASSIVE_OBJ_PLANE
	appearance_flags = PLANE_MASTER //should use client color
	blend_mode = BLEND_OVERLAY

/atom/movable/screen/plane_master/ghost
	name = "ghost plane master"
	plane = GHOST_PLANE
	appearance_flags = PLANE_MASTER //should use client color
	blend_mode = BLEND_OVERLAY
	render_relay_planes = list(RENDER_PLANE_NON_GAME)

/atom/movable/screen/plane_master/point
	name = "point plane master"
	plane = POINT_PLANE
	appearance_flags = PLANE_MASTER //should use client color
	blend_mode = BLEND_OVERLAY

/**
 * Plane master handling byond internal blackness
 * vars are set as to replicate behavior when rendering to other planes
 * do not touch this unless you know what you are doing
 */
/atom/movable/screen/plane_master/blackness
	name = "darkness plane master"
	plane = BLACKNESS_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	blend_mode = BLEND_MULTIPLY
	appearance_flags = PLANE_MASTER | NO_CLIENT_COLOR | PIXEL_SCALE
	//byond internal end
	// Hides space and z-mimic outside our view too
	render_relay_planes = list(RENDER_PLANE_GAME, RENDER_PLANE_BELOW_GAME)

///Contains all lighting objects
/atom/movable/screen/plane_master/lighting
	name = "lighting plane master"
	plane = LIGHTING_PLANE
	blend_mode_override = BLEND_MULTIPLY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	// Space is rendered apart from the game plate but still needs lighting
	render_relay_planes = list(RENDER_PLANE_GAME, RENDER_PLANE_SPACE)

/atom/movable/screen/plane_master/lighting/show_to(mob/mymob)
	. = ..()
	// Fullscreens only exist on the main map
	if(home.map)
		return
	mymob.overlay_fullscreen("lighting_backdrop_lit", /atom/movable/screen/fullscreen/lighting_backdrop/lit)
	mymob.overlay_fullscreen("lighting_backdrop_unlit", /atom/movable/screen/fullscreen/lighting_backdrop/unlit)
	if (isliving(mymob))
		mymob.overlay_fullscreen("lighting_backdrop_seenear", /atom/movable/screen/fullscreen/see_through_darkness)

/atom/movable/screen/plane_master/lighting/update_effects(mob/mymob)
	. = ..()
	remove_filter("emissives")
	var/low_graphics_quality = mymob.client?.prefs?.read_player_preference(/datum/preference/toggle/low_graphics_quality)
	if (!low_graphics_quality)
		add_filter("emissives", 1, layering_filter(render_source = EMISSIVE_RENDER_TARGET, blend_mode = BLEND_ADD))
	add_filter("lighting", 3, alpha_mask_filter(render_source = O_LIGHTING_VISUAL_RENDER_TARGET, flags = MASK_INVERSE))

/atom/movable/screen/plane_master/additive_lighting
	name = "additive lighting plane master"
	plane = LIGHTING_PLANE_ADDITIVE
	blend_mode_override = BLEND_ADD
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = ADDITIVE_LIGHTING_PLANE_ALPHA_NORMAL

/atom/movable/screen/plane_master/additive_lighting/update_effects(mob/mymob)
	. = ..()
	// Disable this as a plane master when using low graphics quality, the stuff does not render at all
	var/low_graphics_quality = mymob.client?.prefs?.read_player_preference(/datum/preference/toggle/low_graphics_quality)
	if (low_graphics_quality)
		appearance_flags &= ~PLANE_MASTER
	else
		appearance_flags |= PLANE_MASTER

/**
 * Renders extremely blurred white stuff over space to give the effect of starlight lighting.
 */

/atom/movable/screen/plane_master/starlight
	name = "starlight plane master"
	plane = STARLIGHT_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_relay_planes = list(LIGHTING_PLANE)
	blend_mode_override = BLEND_OVERLAY
	color = COLOR_STARLIGHT

/atom/movable/screen/plane_master/starlight/show_to(mob/mymob)
	. = ..()
	// Default the colour to whatever the parallax is currently
	transition_colour(src, GLOB.starlight_colour, 0.1 SECONDS)
	// Transition the colour to whatever the global tells us to go to
	RegisterSignal(SSdcs, COMSIG_GLOB_STARLIGHT_COLOUR_CHANGE, PROC_REF(transition_colour), override = TRUE)

/atom/movable/screen/plane_master/starlight/proc/transition_colour(datum/source, new_colour, transition_time = 5 SECONDS)
	SIGNAL_HANDLER
	animate(src, time = transition_time, color = new_colour)

/**
  * Things placed on this mask the lighting plane. Doesn't render directly.
  *
  * Gets masked by blocking plane. Use for things that you want blocked by
  * mobs, items, etc.
  */
/atom/movable/screen/plane_master/emissive
	name = "emissive plane master"
	plane = EMISSIVE_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_target = EMISSIVE_RENDER_TARGET
	render_relay_planes = list()

/atom/movable/screen/plane_master/emissive/show_to(mob/mymob)
	. = ..()
	if(home.map)
		return
	mymob.overlay_fullscreen("emissive_backdrop", /atom/movable/screen/fullscreen/lighting_backdrop/emissive_backdrop)

/atom/movable/screen/plane_master/above_lighting
	name = "above lighting plane master"
	plane = ABOVE_LIGHTING_PLANE
	appearance_flags = PLANE_MASTER //should use client color
	blend_mode = BLEND_OVERLAY

///Contains space parallax
/atom/movable/screen/plane_master/parallax
	name = "parallax plane master"
	plane = PLANE_SPACE_PARALLAX
	blend_mode = BLEND_MULTIPLY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_relay_planes = list(RENDER_PLANE_SPACE)

/atom/movable/screen/plane_master/parallax_white
	name = "parallax whitifier plane master"
	plane = PLANE_SPACE
	render_relay_planes = list(RENDER_PLANE_SPACE)

/// Kept off the game plate, its lighting would light lower levels twice
/atom/movable/screen/plane_master/zmimic
	name = "zmimic plane master"
	plane = ZMIMIC_MAX_PLANE
	appearance_flags = PLANE_MASTER //should use client color
	render_relay_planes = list(RENDER_PLANE_BELOW_GAME)

/// Holds the lighting copied from below for one z-mimic plane.
/// Multiplied over that plane and everything deeper, since each z-mimic plane is composited on its own.
/atom/movable/screen/plane_master/zmimic_shadow
	name = "zmimic shadow plane master"
	plane = ZMIMIC_SHADOW_PLANE(ZMIMIC_MAX_PLANE)
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	blend_mode_override = BLEND_MULTIPLY
	render_relay_planes = list(RENDER_PLANE_BELOW_GAME)

/atom/movable/screen/plane_master/zmimic_shadow/get_relay_layer()
	// Just above the z-mimic plane we darken
	return ..() - ZMIMIC_SHADOW_PLANE_OFFSET * 0.5 + 0.25

/// Fades copied lighting, but keeps depth darkening
/atom/movable/screen/plane_master/zmimic_shadow/proc/set_lighting_alpha(lighting_alpha)
	if(lighting_alpha >= 255)
		color = null
		return
	var/lit = lighting_alpha / 255
	var/dark = (1 - lit) * SHADOWER_DARKENING_FACTOR
	color = list(lit,0,0,0, 0,lit,0,0, 0,0,lit,0, dark,dark,dark,1, 0,0,0,0)

/atom/movable/screen/plane_master/pipecrawl
	name = "pipecrawl plane master"
	plane = PIPECRAWL_IMAGES_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_OVERLAY

/atom/movable/screen/plane_master/pipecrawl/Initialize(mapload)
	. = ..()
	// Makes everything on this plane slightly brighter
	// Has a nice effect, makes thing stand out
	color = list(1.2,0,0,0, 0,1.2,0,0, 0,0,1.2,0, 0,0,0,1, 0,0,0,0)

/atom/movable/screen/plane_master/pipecrawl/update_effects(mob/mymob)
	. = ..()
	remove_filter("pipe_dropshadow")
	if (mymob.client?.prefs?.read_player_preference(/datum/preference/toggle/low_graphics_quality))
		return
	// This serves a similar purpose, I want the pipes to pop
	add_filter("pipe_dropshadow", 1, drop_shadow_filter(x = -1, y= -1, size = 1, color = "#0000007A"))

/atom/movable/screen/plane_master/camera_static
	name = "camera static plane master"
	plane = CAMERA_STATIC_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_OVERLAY

/atom/movable/screen/plane_master/o_light_visual
	name = "overlight light visual plane master"
	plane = O_LIGHTING_VISUAL_PLANE
	render_target = O_LIGHTING_VISUAL_RENDER_TARGET
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	blend_mode = BLEND_MULTIPLY
	blend_mode_override = BLEND_MULTIPLY
	render_relay_planes = list(RENDER_PLANE_GAME, RENDER_PLANE_SPACE)

/atom/movable/screen/plane_master/runechat
	name = "runechat plane master"
	plane = RUNECHAT_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_OVERLAY
	render_relay_planes = list(RENDER_PLANE_NON_GAME)

/atom/movable/screen/plane_master/runechat/update_effects(mob/mymob)
	. = ..()
	remove_filter("AO")
	var/low_graphics_quality = mymob.client?.prefs?.read_player_preference(/datum/preference/toggle/low_graphics_quality)
	if (low_graphics_quality)
		return
	if(istype(mymob) && mymob.client?.prefs?.read_player_preference(/datum/preference/toggle/ambient_occlusion))
		add_filter("AO", 1, drop_shadow_filter(x = 0, y = -2, size = 4, color = "#04080FAA"))

/atom/movable/screen/plane_master/gravpulse
	name = "gravpulse plane"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = GRAVITY_PULSE_PLANE
	blend_mode = BLEND_ADD
	blend_mode_override = BLEND_ADD
	render_target = GRAVITY_PULSE_RENDER_TARGET
	render_relay_planes = list()

/atom/movable/screen/plane_master/area
	name = "area plane"
	plane = AREA_PLANE

/atom/movable/screen/plane_master/text_effect
	name = "text effect plane"
	plane = TEXT_EFFECT_PLANE
	render_relay_planes = list(RENDER_PLANE_NON_GAME)

/atom/movable/screen/plane_master/balloon_chat
	name = "balloon alert plane"
	plane = BALLOON_CHAT_PLANE
	render_relay_planes = list(RENDER_PLANE_NON_GAME)

/atom/movable/screen/plane_master/fullscreen
	name = "fullscreen alert plane"
	plane = FULLSCREEN_PLANE
	render_relay_planes = list(RENDER_PLANE_NON_GAME)

//Psychic & Blind stuff
/atom/movable/screen/plane_master/psychic
	name = "psychic plane master"
	plane = PSYCHIC_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = PLANE_MASTER
	render_target = PSYCHIC_PLANE_RENDER_TARGET
	render_relay_planes = list(RENDER_PLANE_NON_GAME)

/atom/movable/screen/plane_master/psychic/update_effects(mob/mymob)
	. = ..()
	remove_filter(list("psychic_bloom", "psychic_alpha_mask", "psychic_radial_blur", "psychic_blur"))
	var/low_graphics_quality = mymob.client?.prefs?.read_player_preference(/datum/preference/toggle/low_graphics_quality)
	if (low_graphics_quality)
		return
	add_filter("psychic_bloom", 1, list(type = "bloom", size = 2, threshold = rgb(85,85,85)))
	add_filter("psychic_alpha_mask", 1, alpha_mask_filter(render_source = "psychic_mask"))
	add_filter("psychic_radial_blur", 1, radial_blur_filter(size = 0.0125))
	add_filter("psychic_blur", 1, gauss_blur_filter(size = 1.5))

/atom/movable/screen/plane_master/anti_psychic
	name = "anti psychic plane master"
	plane = ANTI_PSYCHIC_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = PLANE_MASTER
	render_target = ANTI_PSYCHIC_PLANE_RENDER_TARGET
	render_relay_planes = list()

/atom/movable/screen/plane_master/anti_psychic/update_effects(mob/mymob)
	. = ..()
	remove_filter("hide_outline")
	var/low_graphics_quality = mymob.client?.prefs?.read_player_preference(/datum/preference/toggle/low_graphics_quality)
	if (low_graphics_quality)
		return
	//fixes issue with bloom outlines
	add_filter("hide_outline", 1, outline_filter(5, "#fff"))

/atom/movable/screen/plane_master/blind_feature
	name = "blind feature plane master"
	plane = BLIND_FEATURE_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = PLANE_MASTER
	render_relay_planes = list(RENDER_PLANE_NON_GAME)

/atom/movable/screen/plane_master/blind_feature/update_effects(mob/mymob)
	. = ..()
	remove_filter(list("glow", "mask"))
	var/low_graphics_quality = mymob.client?.prefs?.read_player_preference(/datum/preference/toggle/low_graphics_quality)
	if (low_graphics_quality)
		return
	add_filter("glow", 1, list(type = "bloom", threshold = rgb(128, 128, 128), size = 2, offset = 1, alpha = 255))
	add_filter("mask", 2, alpha_mask_filter(render_source = "blind_fullscreen_overlay"))

/atom/movable/screen/plane_master/excited_turfs
	name = "atmos excited turfs"
	plane = ATMOS_GROUP_PLANE
	appearance_flags = PLANE_MASTER
	alpha = 0
