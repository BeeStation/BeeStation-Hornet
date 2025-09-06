/**********************Mining Scanners**********************/
/obj/item/mining_scanner
	desc = "A scanner that checks surrounding rock for useful minerals; it can also be used to stop gibtonite detonations.\nIt has a speaker that can be toggled with <b>alt+click</b>"
	name = "manual mining scanner"
	icon = 'icons/obj/device.dmi'
	icon_state = "miningmanual"
	inhand_icon_state = "analyzer"
	worn_icon_state = "analyzer"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	var/cooldown = 35
	var/current_cooldown = 0
	var/speaker = TRUE // Speaker that plays a sound when pulsed.

/obj/item/mining_scanner/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	speaker = !speaker
	to_chat(user, span_notice("You toggle [src]'s speaker to [speaker ? "<b>ON</b>" : "<b>OFF</b>"]."))

/obj/item/mining_scanner/attack_self(mob/user)
	if(!user.client)
		return
	if(current_cooldown <= world.time)
		current_cooldown = world.time + cooldown
		mineral_scan_pulse(get_turf(user))
		if(speaker)
			playsound(src, 'sound/effects/ping.ogg', 15)

//Debug item to identify all ore spread quickly
/obj/item/mining_scanner/admin

/obj/item/mining_scanner/admin/attack_self(mob/user)
	for(var/area/A as() in get_areas(/area, user.z))
		for(var/turf/closed/mineral/M in A)
			if(M.scan_state)
				var/obj/effect/temp_visual/mining_overlay/C = new /obj/effect/temp_visual/mining_overlay(M)
				C.icon_state = M.scan_state
	//qdel(src)

/obj/item/t_scanner/adv_mining_scanner
	desc = "A scanner that automatically checks surrounding rock for useful minerals; it can also be used to stop gibtonite detonations. This one has an extended range.\nIt has a speaker that can be toggled with <b>alt+click</b>"
	name = "advanced automatic mining scanner"
	icon_state = "adv_mining0"
	inhand_icon_state = "analyzer"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	var/cooldown = 35
	var/current_cooldown = 0
	var/range = 7
	var/speaker = FALSE // Speaker that plays a sound when pulsed.

/obj/item/t_scanner/adv_mining_scanner/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	speaker = !speaker
	to_chat(user, span_notice("You toggle [src]'s speaker to [speaker ? "<b>ON</b>" : "<b>OFF</b>"]."))

/obj/item/t_scanner/adv_mining_scanner/cyborg/Initialize(mapload)
	. = ..()
	toggle_on()

/obj/item/t_scanner/adv_mining_scanner/lesser
	name = "automatic mining scanner"
	icon_state = "mining0"
	desc = "A scanner that automatically checks surrounding rock for useful minerals; it can also be used to stop gibtonite detonations."
	range = 4
	cooldown = 50

/obj/item/t_scanner/adv_mining_scanner/scan()
	if(current_cooldown <= world.time)
		current_cooldown = world.time + cooldown
		var/turf/t = get_turf(src)
		mineral_scan_pulse(t, range)
		if(speaker)
			playsound(src, 'sound/effects/ping.ogg', 15)

/proc/mineral_scan_pulse(turf/T, range = world.view)
	var/list/parsedrange = getviewsize(range)
	var/xrange = (parsedrange[1] - 1) / 2
	var/yrange = (parsedrange[2] - 1) / 2
	var/cx = T.x
	var/cy = T.y
	for(var/r in 1 to max(xrange, yrange))
		var/xr = min(xrange, r)
		var/yr = min(yrange, r)
		var/turf/TL = locate(cx - xr, cy + yr, T.z)
		var/turf/BL = locate(cx - xr, cy - yr, T.z)
		var/turf/TR = locate(cx + xr, cy + yr, T.z)
		var/turf/BR = locate(cx + xr, cy - yr, T.z)
		var/list/turfs = list()
		turfs += block(TL, TR)
		turfs += block(TL, BL)
		turfs |= block(BL, BR)
		turfs |= block(BR, TR)
		for(var/turf/closed/mineral/M in turfs)
			new /obj/effect/temp_visual/mining_scanner(M)
			if(M.scan_state)
				var/obj/effect/temp_visual/mining_overlay/oldC = locate(/obj/effect/temp_visual/mining_overlay) in M
				if(oldC)
					qdel(oldC)
				var/obj/effect/temp_visual/mining_overlay/C = new /obj/effect/temp_visual/mining_overlay(M)
				C.icon_state = M.scan_state
		sleep(1)

/proc/pulse_effect(turf/T, range = world.view)
	var/list/parsedrange = getviewsize(range)
	var/xrange = (parsedrange[1] - 1) / 2
	var/yrange = (parsedrange[2] - 1) / 2
	var/cx = T.x
	var/cy = T.y
	for(var/r in 1 to max(xrange, yrange))
		var/xr = min(xrange, r)
		var/yr = min(yrange, r)
		var/turf/TL = locate(cx - xr, cy + yr, T.z)
		var/turf/BL = locate(cx - xr, cy - yr, T.z)
		var/turf/TR = locate(cx + xr, cy + yr, T.z)
		var/turf/BR = locate(cx + xr, cy - yr, T.z)
		var/list/turfs = list()
		turfs += block(TL, TR)
		turfs += block(TL, BL)
		turfs |= block(BL, BR)
		turfs |= block(BR, TR)
		for(var/turf/M in turfs)
			new /obj/effect/temp_visual/mining_scanner(M)
		sleep(1)

/obj/effect/temp_visual/mining_overlay
	plane = FULLSCREEN_PLANE
	layer = FLASH_LAYER
	icon = 'icons/effects/ore_visuals.dmi'
	appearance_flags = NONE //to avoid having TILE_BOUND in the flags, so that the 480x480 icon states let you see it no matter where you are
	duration = 35
	pixel_x = -224
	pixel_y = -224

/obj/effect/temp_visual/mining_overlay/Initialize(mapload)
	. = ..()
	animate(src, alpha = 0, time = duration, easing = EASE_IN)

/obj/effect/temp_visual/mining_scanner
	plane = FULLSCREEN_PLANE
	layer = FLASH_LAYER
	icon = 'icons/effects/mining_scanner.dmi'
	appearance_flags = NONE
	pixel_x = -224
	pixel_y = -224
	duration = 3
	alpha = 100
	icon_state = "mining_scan"

/obj/effect/temp_visual/mining_scanner/Initialize(mapload)
	. = ..()
	animate(src, alpha = 0, time = duration, easing = EASE_IN)
