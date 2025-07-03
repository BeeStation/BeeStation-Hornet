/*
	Screen objects
	Todo: improve/re-implement

	Screen objects are only used for the hud and should not appear anywhere "in-game".
	They are used with the client/screen list and the screen_loc var.
	For more information, see the byond documentation on the screen_loc and screen vars.
*/

/atom/movable/screen
	name = ""
	icon = 'icons/hud/screen_gen.dmi'
	plane = HUD_PLANE
	layer = HUD_LAYER
	animate_movement = SLIDE_STEPS
	speech_span = SPAN_ROBOT
	vis_flags = VIS_INHERIT_PLANE
	appearance_flags = APPEARANCE_UI
	/// A reference to the owner HUD, if any.
	var/datum/hud/hud = null
	/**
	 * Map name assigned to this object.
	 * Automatically set by /client/proc/add_obj_to_map.
	 */
	var/assigned_map
	/**
	 * Mark this object as garbage-collectible after you clean the map
	 * it was registered on.
	 *
	 * This could probably be changed to be a proc, for conditional removal.
	 * But for now, this works.
	 */
	var/del_on_map_removal = TRUE
	///Can we throw things at this
	var/can_throw_target = FALSE

/atom/movable/screen/examine(mob/user)
	return list()

/atom/movable/screen/orbit()
	return

/atom/movable/screen/proc/component_click(atom/movable/screen/component_button/component, params)
	return

/atom/movable/screen/text
	icon = null
	icon_state = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = "CENTER-7,CENTER-7"
	maptext_height = 480
	maptext_width = 480

/atom/movable/screen/swap_hand
	plane = HUD_PLANE
	name = "swap hand"

/atom/movable/screen/swap_hand/Click()
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	if(world.time <= usr.next_move)
		return 1

	if(usr.incapacitated(IGNORE_STASIS))
		return 1

	if(ismob(usr))
		var/mob/M = usr
		M.swap_hand()
	return 1

/atom/movable/screen/navigate
	name = "navigate"
	icon = 'icons/hud/style/screen_midnight.dmi'
	icon_state = "navigate"
	screen_loc = ui_navigate_menu

/atom/movable/screen/navigate/Click()
	if(!isliving(usr))
		return TRUE
	var/mob/living/navigator = usr
	navigator.navigate()

/atom/movable/screen/craft
	name = "crafting menu"
	icon = 'icons/hud/style/screen_midnight.dmi'
	icon_state = "craft"
	screen_loc = ui_crafting

/atom/movable/screen/area_creator
	name = "create new area"
	icon = 'icons/hud/style/screen_midnight.dmi'
	icon_state = "area_edit"
	screen_loc = ui_building

/atom/movable/screen/area_creator/Click()
	if(usr.incapacitated() || (isobserver(usr) && !IsAdminGhost(usr)))
		return TRUE
	var/area/A = get_area(usr)
	if(!A.outdoors)
		to_chat(usr, span_warning("There is already a defined structure here."))
		return TRUE
	create_area(usr)

/atom/movable/screen/language_menu
	name = "language menu"
	icon = 'icons/hud/style/screen_midnight.dmi'
	icon_state = "talk_wheel"
	screen_loc = ui_language_menu

/atom/movable/screen/language_menu/Click()
	usr.get_language_holder().open_language_menu(usr)

/atom/movable/screen/inventory
	var/slot_id
	/// Icon when empty. For now used only by humans.
	var/icon_empty
	/// Icon when contains an item. For now used only by humans.
	var/icon_full
	/// The overlay when hovering over with an item in your hand
	var/image/object_overlay
	plane = HUD_PLANE

/atom/movable/screen/inventory/Click(location, control, params)
	//This is where putting stuff into hands is handled
	if(hud?.mymob && slot_id)
		var/obj/item/inv_item = hud.mymob.get_item_by_slot(slot_id)
		if(inv_item)
			return inv_item.Click(location, control, params)

	//Putting into something (if its not in us)
	if(usr.attack_ui(slot_id, params))
		usr.update_inv_hands()
	return TRUE

/atom/movable/screen/inventory/MouseEntered()
	..()
	add_overlays()
	//Apply the outline affect
	add_stored_outline()

/atom/movable/screen/inventory/MouseExited()
	..()
	cut_overlay(object_overlay)
	QDEL_NULL(object_overlay)
	remove_stored_outline()

/atom/movable/screen/inventory/proc/add_stored_outline()
	if(hud?.mymob && slot_id)
		var/obj/item/inv_item = hud.mymob.get_item_by_slot(slot_id)
		if(inv_item)
			if(hud?.mymob.incapacitated())
				inv_item.apply_outline(COLOR_RED_GRAY)
			else
				inv_item.apply_outline()

/atom/movable/screen/inventory/proc/remove_stored_outline()
	if(hud?.mymob && slot_id)
		var/obj/item/inv_item = hud.mymob.get_item_by_slot(slot_id)
		if(inv_item)
			inv_item.remove_outline()

/atom/movable/screen/inventory/update_icon_state()
	if(!icon_empty)
		icon_empty = icon_state

	if(hud?.mymob && slot_id && icon_full)
		icon_state = hud.mymob.get_item_by_slot(slot_id) ? icon_full : icon_empty
	return ..()

/atom/movable/screen/inventory/proc/add_overlays()
	var/mob/user = hud?.mymob

	if(!user || !slot_id)
		return

	var/obj/item/holding = user.get_active_held_item()

	if(!holding || user.get_item_by_slot(slot_id))
		return

	var/image/item_overlay = image(holding)
	item_overlay.alpha = 92

	if(!user.can_equip(holding, slot_id, TRUE, bypass_equip_delay_self = TRUE))
		item_overlay.color = "#FF0000"
	else
		item_overlay.color = "#00ff00"

	cut_overlay(object_overlay)
	object_overlay = item_overlay
	add_overlay(object_overlay)

/atom/movable/screen/inventory/hand
	var/mutable_appearance/handcuff_overlay
	var/static/mutable_appearance/blocked_overlay = mutable_appearance('icons/hud/screen_gen.dmi', "blocked")
	var/held_index = 0

/atom/movable/screen/inventory/hand/update_overlays()
	. = ..()

	if(!handcuff_overlay)
		var/state = (!(held_index % 2)) ? "markus" : "gabrielle"
		handcuff_overlay = mutable_appearance('icons/hud/screen_gen.dmi', state)

	if(!hud?.mymob)
		return

	if(iscarbon(hud.mymob))
		var/mob/living/carbon/C = hud.mymob
		if(C.handcuffed)
			. += handcuff_overlay

		if(held_index)
			if(!C.has_hand_for_held_index(held_index))
				. += blocked_overlay

	if(held_index == hud.mymob.active_hand_index)
		. += (held_index % 2) ? "lhandactive" : "rhandactive"

/atom/movable/screen/inventory/hand/Click(location, control, params)
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	var/mob/user = hud?.mymob
	if(usr != user)
		return TRUE
	if(world.time <= user.next_move)
		return TRUE
	if(user.incapacitated())
		return TRUE
	if (ismecha(user.loc)) // stops inventory actions in a mech
		return TRUE

	if(user.active_hand_index == held_index)
		var/obj/item/I = user.get_active_held_item()
		if(I)
			I.Click(location, control, params)
	else
		user.swap_hand(held_index)
	return TRUE

/atom/movable/screen/close
	name = "close"

	plane = ABOVE_HUD_PLANE
	icon_state = "backpack_close"

	/// A reference to the object in the slot. Grabs or items, generally.
	var/datum/component/master = null

CREATION_TEST_IGNORE_SUBTYPES(/atom/movable/screen/close)

/atom/movable/screen/close/Initialize(mapload, new_master)
	. = ..()
	master = new_master
	//if (master && !istype(master))
	//	CRASH("Attempting to create a backpack close without referencing a storage concrete component.")

/atom/movable/screen/close/Click()
	var/datum/storage/storage = master
	storage.hide_contents(usr)
	return TRUE

/atom/movable/screen/drop
	name = "drop"
	icon = 'icons/hud/style/screen_midnight.dmi'
	icon_state = "act_drop"
	plane = HUD_PLANE

/atom/movable/screen/drop/Click()
	if(usr.stat == CONSCIOUS)
		usr.dropItemToGround(usr.get_active_held_item())
		update_appearance()

/atom/movable/screen/drop/disappearing/update_icon_state()
	icon_state = usr.get_active_held_item() ? "act_drop" : null
	return ..()

/atom/movable/screen/combattoggle
	name = "toggle combat mode"
	icon = 'icons/hud/style/screen_midnight.dmi'
	icon_state = "combat_off"
	screen_loc = ui_combat_toggle

/atom/movable/screen/combattoggle/New(loc, ...)
	. = ..()
	update_appearance()

/atom/movable/screen/combattoggle/Click()
	if(isliving(usr))
		var/mob/living/owner = usr
		owner.set_combat_mode(!owner.combat_mode, FALSE)
		update_appearance()

/atom/movable/screen/combattoggle/update_icon_state()
	var/mob/living/user = hud?.mymob
	if(!istype(user) || !user.client)
		return
	icon_state = user.combat_mode ? "combat" : "combat_off" //Treats the combat_mode
	return ..()

//Version of the combat toggle with the flashy overlay
/atom/movable/screen/combattoggle/flashy
	///Mut appearance for flashy border
	var/mutable_appearance/flashy

/atom/movable/screen/combattoggle/flashy/update_overlays()
	. = ..()
	var/mob/living/user = hud?.mymob
	if(!istype(user) || !user.client)
		return

	if(!user.combat_mode)
		return

	if(!flashy)
		flashy = mutable_appearance('icons/hud/screen_gen.dmi', "togglefull_flash")
		flashy.color = "#C62727"
	. += flashy

/atom/movable/screen/combattoggle/robot
	icon = 'icons/hud/screen_cyborg.dmi'
	screen_loc = ui_borg_intents

/atom/movable/screen/spacesuit
	name = "Space suit cell status"
	icon_state = "spacesuit_0"
	screen_loc = ui_spacesuit

/atom/movable/screen/mov_intent
	name = "run/walk toggle"
	icon = 'icons/hud/style/screen_midnight.dmi'
	icon_state = "running"

/atom/movable/screen/mov_intent/Click()
	toggle(usr)

/atom/movable/screen/mov_intent/update_icon_state()
	switch(hud?.mymob?.m_intent)
		if(MOVE_INTENT_WALK)
			icon_state = "walking"
		if(MOVE_INTENT_RUN)
			icon_state = "running"
	return ..()

/atom/movable/screen/mov_intent/proc/toggle(mob/user)
	if(isobserver(user))
		return
	user.toggle_move_intent(user)

/atom/movable/screen/pull
	name = "stop pulling"
	icon = 'icons/hud/style/screen_midnight.dmi'
	icon_state = "pull"

/atom/movable/screen/pull/Click()
	if(isobserver(usr))
		return
	usr.stop_pulling()

/atom/movable/screen/pull/update_icon_state()
	if(hud?.mymob?.pulling)
		icon_state = "pull"
	else
		icon_state = "pull0"
	return ..()

/atom/movable/screen/resist
	name = "resist"
	icon = 'icons/hud/style/screen_midnight.dmi'
	icon_state = "act_resist"
	plane = HUD_PLANE

/atom/movable/screen/resist/Click()
	if(isliving(usr))
		var/mob/living/L = usr
		L.resist()

/atom/movable/screen/rest
	name = "rest"
	icon = 'icons/hud/style/screen_midnight.dmi'
	icon_state = "act_rest"
	plane = HUD_PLANE

/atom/movable/screen/rest/Click()
	if(isliving(usr))
		var/mob/living/L = usr
		L.toggle_resting()

/atom/movable/screen/rest/update_icon_state()
	var/mob/living/user = hud?.mymob
	if(!istype(user))
		return

	if(!user.resting)
		icon_state = "act_rest"
	else
		icon_state = "act_rest0"
	return ..()

/atom/movable/screen/storage
	name = "storage"
	icon_state = "block"
	screen_loc = "7,7 to 10,8"
	plane = HUD_PLANE
	/// A reference to the object in the slot. Grabs or items, generally.
	var/datum/storage/master = null

CREATION_TEST_IGNORE_SUBTYPES(/atom/movable/screen/storage)

/atom/movable/screen/storage/Initialize(mapload, new_master)
	. = ..()
	master = new_master
	if (master && !istype(master))
		CRASH("Attempting to create a backpack close without referencing a storage datum.")

/atom/movable/screen/storage/attackby(location, control, params)
	var/datum/storage/storage_master = master
	if(!istype(storage_master))
		return FALSE

	var/obj/item/inserted = usr.get_active_held_item()
	if(inserted)
		storage_master.attempt_insert(inserted, usr)

	return TRUE

/atom/movable/screen/throw_catch
	name = "throw/catch"
	icon = 'icons/hud/style/screen_midnight.dmi'
	icon_state = "act_throw_off"

/atom/movable/screen/throw_catch/Click()
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		C.toggle_throw_mode()

/atom/movable/screen/zone_sel
	name = "damage zone"
	icon_state = "zone_sel"
	screen_loc = ui_zonesel
	var/selecting = BODY_ZONE_CHEST
	var/static/list/hover_overlays_cache = list()
	var/hovering
	var/mutable_appearance/selecting_appearance

/atom/movable/screen/zone_sel/Click(location, control,params)
	if(isobserver(usr))
		return

	var/list/modifiers = params2list(params)
	var/icon_x = text2num(LAZYACCESS(modifiers, ICON_X))
	var/icon_y = text2num(LAZYACCESS(modifiers, ICON_Y))
	var/choice = get_zone_at(usr, icon_x, icon_y)
	if (!choice)
		return 1

	return set_selected_zone(choice, usr)

/atom/movable/screen/zone_sel/MouseEntered(location, control, params)
	..()
	MouseMove(location, control, params)

/atom/movable/screen/zone_sel/MouseMove(location, control, params)
	if(isobserver(usr))
		return

	var/list/modifiers = params2list(params)
	var/icon_x = text2num(LAZYACCESS(modifiers, ICON_X))
	var/icon_y = text2num(LAZYACCESS(modifiers, ICON_Y))
	var/choice = get_zone_at(usr, icon_x, icon_y)

	if(hovering == choice)
		return
	vis_contents -= hover_overlays_cache[hovering]
	hovering = choice

	var/obj/effect/overlay/zone_sel/overlay_object = hover_overlays_cache[choice]
	if(!overlay_object)
		overlay_object = new
		overlay_object.icon_state = "[choice]"
		hover_overlays_cache[choice] = overlay_object
	vis_contents += overlay_object

/obj/effect/overlay/zone_sel
	icon = 'icons/hud/screen_gen.dmi'
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = 128
	anchored = TRUE

	plane = ABOVE_HUD_PLANE

/atom/movable/screen/zone_sel/MouseExited(location, control, params)
	if(!isobserver(usr) && hovering)
		vis_contents -= hover_overlays_cache[hovering]
		hovering = null

/atom/movable/screen/zone_sel/proc/get_zone_at(mob/user, icon_x, icon_y)
	var/simple_mode = user.client?.prefs.read_player_preference(/datum/preference/choiced/zone_select) == PREFERENCE_BODYZONE_SIMPLIFIED
	switch(icon_y)
		if(1 to 9) //Legs
			switch(icon_x)
				if(10 to 15)
					return simple_mode ? BODY_GROUP_LEGS : BODY_ZONE_R_LEG
				if(17 to 22)
					return simple_mode ? BODY_GROUP_LEGS : BODY_ZONE_L_LEG
		if(10 to 13) //Hands and groin
			switch(icon_x)
				if(8 to 11)
					return simple_mode ? BODY_GROUP_ARMS : BODY_ZONE_R_ARM
				if(12 to 20)
					return simple_mode ? BODY_GROUP_ARMS : BODY_ZONE_PRECISE_GROIN
				if(21 to 24)
					return simple_mode ? BODY_GROUP_ARMS : BODY_ZONE_L_ARM
		if(14 to 22) //Chest and arms to shoulders
			switch(icon_x)
				if(8 to 11)
					return simple_mode ? BODY_GROUP_ARMS : BODY_ZONE_R_ARM
				if(12 to 20)
					return simple_mode ? BODY_GROUP_CHEST_HEAD : BODY_ZONE_CHEST
				if(21 to 24)
					return simple_mode ? BODY_GROUP_ARMS : BODY_ZONE_L_ARM
		if(23 to 30) //Head, but we need to check for eye or mouth
			if(icon_x in 12 to 20)
				switch(icon_y)
					if(23 to 24)
						if(icon_x in 15 to 17)
							return simple_mode ? BODY_GROUP_CHEST_HEAD : BODY_ZONE_PRECISE_MOUTH
					if(26) //Eyeline, eyes are on 15 and 17
						if(icon_x in 14 to 18)
							return simple_mode ? BODY_GROUP_CHEST_HEAD : BODY_ZONE_PRECISE_EYES
					if(25 to 27)
						if(icon_x in 15 to 17)
							return simple_mode ? BODY_GROUP_CHEST_HEAD : BODY_ZONE_PRECISE_EYES
				return simple_mode ? BODY_GROUP_CHEST_HEAD : BODY_ZONE_HEAD

/atom/movable/screen/zone_sel/proc/set_selected_zone(choice, mob/user)
	if(user != hud?.mymob)
		return

	if(choice != selecting)
		selecting = choice
		update_icon()

	return TRUE

/atom/movable/screen/zone_sel/update_icon()
	. = ..()
	cut_overlay(selecting_appearance)
	selecting_appearance = mutable_appearance('icons/hud/screen_gen.dmi', "[selecting]")
	add_overlay(selecting_appearance)
	hud?.mymob?._set_zone_selected(selecting)

/atom/movable/screen/zone_sel/alien
	icon = 'icons/hud/screen_alien.dmi'

/atom/movable/screen/zone_sel/alien/update_icon()
	. = ..()
	cut_overlay(selecting_appearance)
	selecting_appearance = mutable_appearance('icons/hud/screen_alien.dmi', "[selecting]")
	add_overlay(selecting_appearance)
	hud?.mymob?._set_zone_selected(selecting)

/atom/movable/screen/zone_sel/robot
	icon = 'icons/hud/screen_cyborg.dmi'


/atom/movable/screen/flash
	name = "flash"
	icon_state = "blank"
	blend_mode = BLEND_ADD
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	layer = FLASH_LAYER
	plane = FULLSCREEN_PLANE

/atom/movable/screen/damageoverlay
	icon = 'icons/hud/fullscreen/screen_full.dmi'
	icon_state = "oxydamageoverlay0"
	name = "dmg"
	blend_mode = BLEND_MULTIPLY
	screen_loc = "CENTER-7,CENTER-7"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = UI_DAMAGE_LAYER
	plane = FULLSCREEN_PLANE

/atom/movable/screen/healths
	name = "health"
	icon_state = "health0"
	screen_loc = ui_health

/atom/movable/screen/healths/alien
	icon = 'icons/hud/screen_alien.dmi'
	screen_loc = ui_alien_health

/atom/movable/screen/healths/robot
	icon = 'icons/hud/screen_cyborg.dmi'
	screen_loc = ui_borg_health

/atom/movable/screen/healths/minebot
	icon = 'icons/hud/screen_cyborg.dmi'
	screen_loc = ui_borg_health

/atom/movable/screen/healths/blob
	name = "blob health"
	icon_state = "block"
	screen_loc = ui_internal
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/healths/blob/naut
	name = "health"
	icon = 'icons/mob/blob.dmi'
	icon_state = "nauthealth"

/atom/movable/screen/healths/blob/naut/core
	name = "overmind health"
	icon_state = "corehealth"
	screen_loc = ui_health

/atom/movable/screen/healths/clock
	icon = 'icons/hud/actions/action_generic.dmi'
	icon_state = "bg_clock"
	screen_loc = ui_health
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/healths/clock/gear
	icon = 'icons/mob/clockwork_mobs.dmi'
	icon_state = "bg_gear"
	screen_loc = ui_internal

/atom/movable/screen/healths/revenant
	name = "essence"
	icon = 'icons/hud/actions/action_generic.dmi'
	icon_state = "bg_revenant"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/healthdoll
	name = "health doll"
	screen_loc = ui_healthdoll

/atom/movable/screen/healthdoll/Click()
	if (iscarbon(usr))
		var/mob/living/carbon/C = usr
		C.check_self_for_injuries()

/atom/movable/screen/healthdoll/living
	icon_state = "fullhealth0"
	screen_loc = ui_living_healthdoll
	var/filtered = FALSE //so we don't repeatedly create the mask of the mob every update

/atom/movable/screen/mood
	name = "mood"
	icon_state = "mood5"
	screen_loc = ui_mood

/atom/movable/screen/sanity
	name = "sanity"
	icon_state = "sanity3"
	screen_loc = ui_mood

/atom/movable/screen/splash
	icon = 'icons/blanks/blank_title.png'
	icon_state = ""
	screen_loc = "1,1"
	plane = SPLASHSCREEN_PLANE
	var/client/holder

INITIALIZE_IMMEDIATE(/atom/movable/screen/splash)

CREATION_TEST_IGNORE_SUBTYPES(/atom/movable/screen/splash)

/atom/movable/screen/splash/Initialize(mapload, client/C, visible, use_previous_title)
	. = ..()
	if(!istype(C))
		return

	holder = C

	if(!visible)
		alpha = 0

	if(!use_previous_title)
		if(SStitle.icon)
			icon = SStitle.icon
	else
		if(!SStitle.previous_icon)
			return INITIALIZE_HINT_QDEL
		icon = SStitle.previous_icon

	holder.screen += src

/atom/movable/screen/splash/proc/Fade(out, qdel_after = TRUE)
	if(QDELETED(src))
		return
	if(out)
		animate(src, alpha = 0, time = 30)
	else
		alpha = 0
		animate(src, alpha = 255, time = 30)
	if(qdel_after)
		QDEL_IN(src, 30)

/atom/movable/screen/splash/Destroy()
	if(holder)
		holder.screen -= src
		holder = null
	return ..()


/atom/movable/screen/component_button
	var/atom/movable/screen/parent

CREATION_TEST_IGNORE_SUBTYPES(/atom/movable/screen/component_button)

/atom/movable/screen/component_button/Initialize(mapload, atom/movable/screen/parent)
	. = ..()
	src.parent = parent

/atom/movable/screen/component_button/Click(params)
	if(parent)
		parent.component_click(src, params)

/atom/movable/screen/combo
	icon_state = ""
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = ui_combo
	plane = ABOVE_HUD_PLANE
	var/timerid

/atom/movable/screen/combo/proc/clear_streak()
	animate(src, alpha = 0, 2 SECONDS, SINE_EASING)
	timerid = addtimer(CALLBACK(src, PROC_REF(reset_icons)), 2 SECONDS, TIMER_UNIQUE | TIMER_STOPPABLE)

/atom/movable/screen/combo/proc/reset_icons()
	cut_overlays()
	icon_state = ""

/atom/movable/screen/combo/update_icon_state(streak = "", time = 2 SECONDS)
	reset_icons()
	if(timerid)
		deltimer(timerid)
	alpha = 255
	if(!streak)
		return ..()
	timerid = addtimer(CALLBACK(src, PROC_REF(clear_streak)), time, TIMER_UNIQUE | TIMER_STOPPABLE)
	icon_state = "combo"
	for(var/i = 1; i <= length(streak); ++i)
		var/intent_text = copytext(streak, i, i + 1)
		var/image/intent_icon = image(icon,src,"combo_[intent_text]")
		intent_icon.pixel_x = 16 * (i - 1) - 8 * length(streak)
		add_overlay(intent_icon)
	return ..()

/atom/movable/screen/stamina
	name = "stamina"
	icon_state = "stamina0"
	screen_loc = ui_stamina
