/atom/movable/screen/plane_master
	screen_loc = "CENTER"
	icon_state = "blank"
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	blend_mode = BLEND_OVERLAY
	plane = LOWEST_EVER_PLANE
	var/show_alpha = 255
	var/hide_alpha = 0

	//--rendering relay vars--
	///integer: what plane we will relay this planes render to
	var/render_relay_plane = RENDER_PLANE_GAME
	///bool: Whether this plane should get a render target automatically generated
	var/generate_render_target = TRUE
	///integer: blend mode to apply to the render relay in case you dont want to use the plane_masters blend_mode
	var/blend_mode_override
	///reference: current relay this plane is utilizing to render
	var/atom/movable/render_plane_relay/relay

/atom/movable/screen/plane_master/proc/Show(override)
	alpha = override || show_alpha

/atom/movable/screen/plane_master/proc/Hide(override)
	alpha = override || hide_alpha

//Why do plane masters need a backdrop sometimes? Read https://secure.byond.com/forum/?post=2141928
//Trust me, you need one. Period. If you don't think you do, you're doing something extremely wrong.
/atom/movable/screen/plane_master/proc/backdrop(mob/mymob)
	SHOULD_CALL_PARENT(TRUE)
	filters = null
	if(!isnull(render_relay_plane))
		relay_render_to_plane(mymob, render_relay_plane)

///Contains just the floor
/atom/movable/screen/plane_master/floor
	name = "floor plane master"
	plane = FLOOR_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_OVERLAY

/atom/movable/screen/plane_master/floor/backdrop(mob/mymob)
	. = ..()
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

/atom/movable/screen/plane_master/game_world/backdrop(mob/mymob)
	. = ..()
	var/low_graphics_quality = mymob.client?.prefs?.read_player_preference(/datum/preference/toggle/low_graphics_quality)
	if(istype(mymob) && mymob.client?.prefs?.read_player_preference(/datum/preference/toggle/ambient_occlusion) && !low_graphics_quality)
		add_filter("AO", 1, drop_shadow_filter(x = 0, y = -2, size = 4, color = "#04080FAA"))

/atom/movable/screen/plane_master/data_hud
	name = "data_hud plane master"
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
	render_relay_plane = RENDER_PLANE_NON_GAME

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

///Contains all lighting objects
/atom/movable/screen/plane_master/lighting
	name = "lighting plane master"
	plane = LIGHTING_PLANE
	blend_mode_override = BLEND_MULTIPLY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/plane_master/lighting/backdrop(mob/mymob)
	. = ..()
	mymob.overlay_fullscreen("lighting_backdrop_lit", /atom/movable/screen/fullscreen/lighting_backdrop/lit)
	mymob.overlay_fullscreen("lighting_backdrop_unlit", /atom/movable/screen/fullscreen/lighting_backdrop/unlit)
	if (isliving(mymob))
		mymob.overlay_fullscreen("lighting_backdrop_seenear", /atom/movable/screen/fullscreen/see_through_darkness)
	var/low_graphics_quality = mymob.client?.prefs?.read_player_preference(/datum/preference/toggle/low_graphics_quality)
	if (!low_graphics_quality)
		add_filter("emissives", 1, layering_filter(render_source = EMISSIVE_RENDER_TARGET, blend_mode = BLEND_ADD))
	add_filter("lighting", 3, alpha_mask_filter(render_source = O_LIGHTING_VISUAL_RENDER_TARGET, flags = MASK_INVERSE))

/atom/movable/screen/plane_master/additive_lighting
	name = "additive lighting plane master"
	plane = LIGHTING_PLANE_ADDITIVE
	blend_mode_override = BLEND_ADD
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/plane_master/additive_lighting/backdrop(mob/mymob)
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
	render_relay_plane = LIGHTING_PLANE
	blend_mode_override = BLEND_OVERLAY
	color = COLOR_STARLIGHT

/atom/movable/screen/plane_master/starlight/backdrop(mob/mymob)
	. = ..()
	var/low_graphics_quality = mymob.client?.prefs?.read_player_preference(/datum/preference/toggle/low_graphics_quality)
	if (low_graphics_quality)
		add_filter("guassian_blur", 1, gauss_blur_filter(1))
	else
		add_filter("guassian_blur", 1, gauss_blur_filter(6))
	// Default the colour to whatever the parallax is currently
	transition_colour(src, GLOB.starlight_colour, 0, FALSE)
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
	render_relay_plane = null

/atom/movable/screen/plane_master/emissive/backdrop(mob/mymob)
	. = ..()
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

/atom/movable/screen/plane_master/parallax_white
	name = "parallax whitifier plane master"
	plane = PLANE_SPACE

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
	render_relay_plane = RENDER_PLANE_GAME

/atom/movable/screen/plane_master/runechat
	name = "runechat plane master"
	plane = RUNECHAT_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_OVERLAY
	render_relay_plane = RENDER_PLANE_NON_GAME

/atom/movable/screen/plane_master/runechat/backdrop(mob/mymob)
	. = ..()
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
	render_relay_plane = null

/atom/movable/screen/plane_master/area
	name = "area plane"
	plane = AREA_PLANE

/atom/movable/screen/plane_master/text_effect
	name = "text effect plane"
	plane = TEXT_EFFECT_PLANE
	render_relay_plane = RENDER_PLANE_NON_GAME

/atom/movable/screen/plane_master/balloon_chat
	name = "balloon alert plane"
	plane = BALLOON_CHAT_PLANE
	render_relay_plane = RENDER_PLANE_NON_GAME

/atom/movable/screen/plane_master/fullscreen
	name = "fullscreen alert plane"
	plane = FULLSCREEN_PLANE
	render_relay_plane = RENDER_PLANE_NON_GAME

//Psychic & Blind stuff
/atom/movable/screen/plane_master/psychic
	name = "psychic plane master"
	plane = PSYCHIC_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = PLANE_MASTER
	render_target = PSYCHIC_PLANE_RENDER_TARGET
	render_relay_plane = RENDER_PLANE_NON_GAME

/atom/movable/screen/plane_master/psychic/backdrop(mob/mymob)
	. = ..()
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
	render_relay_plane = null

/atom/movable/screen/plane_master/anti_psychic/backdrop(mob/mymob)
	. = ..()
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
	render_relay_plane = RENDER_PLANE_NON_GAME

/atom/movable/screen/plane_master/blind_feature/backdrop(mob/mymob)
	. = ..()
	var/low_graphics_quality = mymob.client?.prefs?.read_player_preference(/datum/preference/toggle/low_graphics_quality)
	if (low_graphics_quality)
		return
	add_filter("glow", 1, list(type = "bloom", threshold = rgb(128, 128, 128), size = 2, offset = 1, alpha = 255))
	add_filter("mask", 2, alpha_mask_filter(render_source = "blind_fullscreen_overlay"))

/obj/screen/plane_master/excited_turfs
	name = "atmos excited turfs"
	plane = ATMOS_GROUP_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_OVERLAY
	alpha = 0
