
/mob/var/list/screens = list()

/mob/proc/overlay_fullscreen(category, type, severity)
	var/atom/movable/screen/fullscreen/screen = screens[category]
	if (!screen || screen.type != type)
		// needs to be recreated
		clear_fullscreen(category, FALSE)
		screens[category] = screen = new type()
	else if ((!severity || severity == screen.severity) && (!client || screen.screen_loc != "CENTER-7,CENTER-7" || screen.view == client.view))
		// doesn't need to be updated
		return screen

	screen.icon_state = "[initial(screen.icon_state)][severity]"
	screen.severity = severity
	if (client && screen.should_show_to(src))
		screen.update_for_view(client.view)
		client.screen += screen

	return screen

/mob/proc/clear_fullscreen(category, animated = 10)
	var/atom/movable/screen/fullscreen/screen = screens[category]
	if(!screen)
		return

	screens -= category

	if(animated)
		animate(screen, alpha = 0, time = animated)
		addtimer(CALLBACK(src, PROC_REF(clear_fullscreen_after_animate), screen), animated, TIMER_CLIENT_TIME)
	else
		if(client)
			client.screen -= screen
		qdel(screen)

/mob/proc/clear_fullscreen_after_animate(atom/movable/screen/fullscreen/screen)
	if(client)
		client.screen -= screen
	qdel(screen)

/mob/proc/clear_fullscreens()
	for(var/category in screens)
		clear_fullscreen(category)

/mob/proc/hide_fullscreens()
	if(client)
		for(var/category in screens)
			client.screen -= screens[category]

/mob/proc/reload_fullscreen()
	if(client)
		var/atom/movable/screen/fullscreen/screen
		for(var/category in screens)
			screen = screens[category]
			if(screen.should_show_to(src))
				screen.update_for_view(client.view)
				client.screen |= screen
			else
				client.screen -= screen

/atom/movable/screen/fullscreen
	icon = 'icons/hud/fullscreen/screen_full.dmi'
	icon_state = "default"
	screen_loc = "CENTER-7,CENTER-7"
	layer = FULLSCREEN_LAYER
	plane = FULLSCREEN_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/view = 7
	var/severity = 0
	var/show_when_dead = FALSE

/atom/movable/screen/fullscreen/proc/update_for_view(client_view)
	if (screen_loc == "CENTER-7,CENTER-7" && view != client_view)
		var/list/actualview = getviewsize(client_view)
		view = client_view
		transform = matrix(actualview[1]/FULLSCREEN_OVERLAY_RESOLUTION_X, 0, 0, 0, actualview[2]/FULLSCREEN_OVERLAY_RESOLUTION_Y, 0)

/atom/movable/screen/fullscreen/proc/should_show_to(mob/mymob)
	if(!show_when_dead && mymob.stat == DEAD)
		return FALSE
	return TRUE

/atom/movable/screen/fullscreen/Destroy()
	severity = 0
	. = ..()

/atom/movable/screen/fullscreen/brute
	icon_state = "brutedamageoverlay"
	layer = UI_DAMAGE_LAYER
	plane = FULLSCREEN_PLANE

/atom/movable/screen/fullscreen/oxy
	icon_state = "oxydamageoverlay"
	layer = UI_DAMAGE_LAYER
	plane = FULLSCREEN_PLANE

/atom/movable/screen/fullscreen/crit
	icon_state = "passage"
	layer = CRIT_LAYER
	plane = FULLSCREEN_PLANE

/atom/movable/screen/fullscreen/crit/vision
	icon_state = "oxydamageoverlay"
	layer = BLIND_LAYER

/atom/movable/screen/fullscreen/blind
	icon_state = "blackimageoverlay"
	render_target = "blind_fullscreen_overlay"
	layer = BLIND_LAYER
	plane = FULLSCREEN_PLANE

/atom/movable/screen/fullscreen/law_change
	icon_state = "law_change"
	layer = BLIND_LAYER
	plane = FULLSCREEN_PLANE

/atom/movable/screen/fullscreen/curse
	icon_state = "curse"
	layer = CURSE_LAYER
	plane = FULLSCREEN_PLANE

/atom/movable/screen/fullscreen/hive_mc
	icon_state = "hive_mc"
	layer = CURSE_LAYER
	plane = FULLSCREEN_PLANE

/atom/movable/screen/fullscreen/hive_eyes
	icon_state = "hive_eyes"
	layer = CURSE_LAYER
	plane = FULLSCREEN_PLANE

/atom/movable/screen/fullscreen/impaired
	icon_state = "impairedoverlay"

/atom/movable/screen/fullscreen/flash
	icon = 'icons/hud/screen_gen.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "flash"

/atom/movable/screen/fullscreen/flash/black
	icon = 'icons/hud/screen_gen.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "black"

/atom/movable/screen/fullscreen/flash/static
	icon = 'icons/hud/screen_gen.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "noise"

/atom/movable/screen/fullscreen/high
	icon = 'icons/hud/screen_gen.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "druggy"

/atom/movable/screen/fullscreen/color_vision
	icon = 'icons/hud/screen_gen.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "flash"
	alpha = 80

/atom/movable/screen/fullscreen/color_vision/green
	color = COLOR_VIBRANT_LIME

/atom/movable/screen/fullscreen/color_vision/red
	color = COLOR_RED

/atom/movable/screen/fullscreen/color_vision/blue
	color = COLOR_BLUE

/atom/movable/screen/fullscreen/lighting_backdrop
	icon = 'icons/hud/screen_gen.dmi'
	icon_state = "flash"
	transform = matrix(200, 0, 0, 0, 200, 0)
	plane = LIGHTING_PLANE
	blend_mode = BLEND_OVERLAY
	show_when_dead = TRUE

//Provides darkness to the back of the lighting plane
/atom/movable/screen/fullscreen/lighting_backdrop/lit
	invisibility = INVISIBILITY_LIGHTING
	layer = BACKGROUND_LAYER+21
	color = "#000"
	show_when_dead = TRUE

//Provides whiteness in case you don't see lights so everything is still visible
/atom/movable/screen/fullscreen/lighting_backdrop/unlit
	layer = BACKGROUND_LAYER+20
	show_when_dead = TRUE

/atom/movable/screen/fullscreen/lighting_backdrop/emissive_backdrop
	color = "#000"
	plane = EMISSIVE_PLANE
	layer = 0
	show_when_dead = TRUE

/atom/movable/screen/fullscreen/see_through_darkness
	invisibility = INVISIBILITY_LIGHTING
	icon_state = "nightvision"
	plane = LIGHTING_PLANE
	blend_mode = BLEND_ADD
	show_when_dead = TRUE

/atom/movable/screen/fullscreen/blind_context_disable
	name = "???"
	icon_state = "blackimageoverlay"
	layer = BLIND_LAYER+1
	mouse_opacity = MOUSE_OPACITY_ICON
	alpha = 1
	can_throw_target = TRUE
	///Who we're disabling from right clicking - handled elsewhere
	var/client/owner
	var/mob/mob_owner
	///How close can the mosue be before we disable it - extra check
	var/context_distance = 3 //tiles

/atom/movable/screen/fullscreen/blind_context_disable/Initialize(mapload)
	. = ..()
	var/icon/mask = icon('icons/hud/fullscreen/psychic.dmi', "click_mask")
	add_filter("click_mask", 1, alpha_mask_filter(icon = mask, flags = MASK_INVERSE))

/atom/movable/screen/fullscreen/blind_context_disable/Destroy()
	owner?.show_popup_menus = TRUE
	owner = null
	mob_owner = null
	return ..()

//disable & enable context menu
/atom/movable/screen/fullscreen/blind_context_disable/MouseEntered(location, control, params)
	//try and get owner from mob
	owner = owner || mob_owner?.client
	if(!owner)
		return
	owner?.show_popup_menus = FALSE
	return ..()

/atom/movable/screen/fullscreen/blind_context_disable/MouseExited(location, control, params)
	if(!owner)
		return
	owner?.show_popup_menus = TRUE
	loc = null
	return ..()

//Set the loc to the turf we're technically clicking - fix for shooting 'n throwing
/atom/movable/screen/fullscreen/blind_context_disable/proc/handle_loc(params)
	var/list/l_params = params2list(params)
	//Get mouse position in the icon
	var/xx = text2num(l_params["icon-x"])
	var/yy = text2num(l_params["icon-y"])
	//Calculate which tile coordinate that lies in from the middle of 480x80
	xx = round((xx - 240) / 32) + mob_owner.x
	yy = round((yy - 240) / 32) + mob_owner.y
	//Get turf at that location
	loc = locate(xx, yy, mob_owner?.z || 1)

/atom/movable/screen/fullscreen/blind_context_disable/Click(location, control, params)
	handle_loc(params)
	. = ..()
	loc = null
