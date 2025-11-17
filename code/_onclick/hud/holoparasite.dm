/datum/hud/holoparasite
	custom_hud_locs = TRUE
	var/mob/living/simple_animal/hostile/holoparasite/owner

/datum/hud/holoparasite/New(mob/living/simple_animal/hostile/holoparasite/_owner)
	..()
	if(!istype(_owner))
		CRASH("Attempted to initialize holoparasite HUD on non-holoparasite!")
	owner = _owner
	healths = new /atom/movable/screen/healths(null, src)
	infodisplay += healths

	pull_icon = new /atom/movable/screen/pull(null, src)
	pull_icon.icon = ui_style
	pull_icon.update_icon()
	pull_icon.screen_loc = owner.dextrous ? ui_holopara_pull_dex : ui_holopara_pull
	static_inventory += pull_icon

	var/list/huds_to_add = list(
		new /atom/movable/screen/holoparasite/info(null, src, owner),
		new /atom/movable/screen/holoparasite/communicate(null, src, owner),
		new /atom/movable/screen/holoparasite/manifest_recall(null, src, owner),
		new /atom/movable/screen/holoparasite/toggle_light(null, src, owner),
		new /atom/movable/screen/holoparasite/set_battlecry(null, src, owner)
	)
	build_hand_slots()
	SEND_SIGNAL(owner, COMSIG_HOLOPARA_SETUP_HUD, src, huds_to_add)
	add_inv_huds(huds_to_add)

/datum/hud/holoparasite/persistent_inventory_update(mob/viewer)
	if(!owner)
		return
	var/datum/holoparasite_ability/weapon/dextrous/dexterity = owner.stats.weapon
	if(!dexterity || !istype(dexterity))
		return
	if(hud_shown)
		if(dexterity.internal_storage)
			dexterity.internal_storage.screen_loc = ui_inventory
			owner.client.screen += dexterity.internal_storage
	else
		if(dexterity.internal_storage)
			dexterity.internal_storage.screen_loc = null

/datum/hud/holoparasite/proc/add_inv_huds(list/huds)
	var/toolbar_huds = 0
	for(var/atom/movable/screen/hud_object in huds)
		if(hud_object in static_inventory)
			continue
		toolbar_huds++
	owner.toolbar_element_count = toolbar_huds
	var/hud_loc = -(toolbar_huds / 2)
	for(var/atom/movable/screen/hud_object in huds)
		if(hud_object in static_inventory)
			continue
		hud_object.screen_loc = ui_holopara_button(hud_loc)
		hud_loc++
		static_inventory |= hud_object

/datum/hud/holoparasite/build_hand_slots()
	if(!owner.dextrous)
		return
	for(var/slot in hand_slots)
		var/atom/movable/screen/inventory/hand/hand_slot = hand_slots[slot]
		if(hand_slot)
			static_inventory -= hand_slot
	hand_slots = list()
	var/atom/movable/screen/inventory/hand/hand_box
	var/hands = length(owner.held_items)
	var/hand_loc = -(hands / 2) + 1
	for(var/i in 1 to hands)
		hand_box = new(null, src)
		hand_box.name = owner.get_held_index_name(i)
		hand_box.icon = ui_style
		hand_box.icon_state = "hand_[owner.held_index_to_dir(i)]"
		hand_box.screen_loc = ui_holopara_hand(hand_loc)
		hand_box.held_index = i
		hand_slots["[i]"] = hand_box
		static_inventory += hand_box
		hand_box.update_icon()
		hand_loc++

	var/atom/movable/screen/swap_hand/swap_hand = new(null, src)
	swap_hand.icon = ui_style
	swap_hand.icon_state = "swap_1_m"
	swap_hand.screen_loc = ui_holopara_swap_l
	static_inventory += swap_hand

	swap_hand = new(null, src)
	swap_hand.icon = ui_style
	swap_hand.icon_state = "swap_2"
	swap_hand.screen_loc = ui_holopara_swap_r
	static_inventory += swap_hand

	owner.client.screen = list()
	for(var/atom/movable/screen/inventory/inv in (static_inventory + toggleable_inventory))
		if(inv.slot_id)
			inv_slots[TOBITSHIFT(inv.slot_id) + 1] = inv
			inv.update_icon()

/atom/movable/screen/holoparasite
	icon = 'icons/mob/holoparasite.dmi'
	mouse_over_pointer = MOUSE_HAND_POINTER
	var/mob/living/simple_animal/hostile/holoparasite/owner
	var/can_toggle = FALSE
	var/last_params
	var/list/accent_overlay_states
	var/list/mutable_appearance/accent_overlays
	var/mutable_appearance/toggle_overlay
	var/mutable_appearance/text_overlay
	var/timer_length
	var/static/list/mutable_appearance/timer_fraction_overlays
	COOLDOWN_DECLARE(timer)

CREATION_TEST_IGNORE_SUBTYPES(/atom/movable/screen/holoparasite)

/atom/movable/screen/holoparasite/Initialize(mapload, datum/hud/hud_owner, mob/living/simple_animal/hostile/holoparasite/_owner)
	. = ..()
	if(!istype(_owner))
		CRASH("Tried to create a holoparasite HUD element without a parent holoparasite!")
	owner = _owner
	if(!timer_fraction_overlays)
		timer_fraction_overlays = list(
			"tbd" = mutable_appearance('icons/effects/cooldown.dmi', "second", alpha = 180, appearance_flags = APPEARANCE_UI_IGNORE_ALPHA)
		)
		for(var/fraction in 1 to 9)
			timer_fraction_overlays["[fraction]"] = mutable_appearance('icons/effects/cooldown.dmi', "second.[fraction]", alpha = 180, appearance_flags = APPEARANCE_UI_IGNORE_ALPHA)
	if(can_toggle)
		toggle_overlay = mutable_appearance(icon, "selected", appearance_flags = APPEARANCE_UI, color = owner.accent_color)
	for(var/overlay_state in accent_overlay_states)
		var/mutable_appearance/overlay = mutable_appearance(icon, overlay_state, appearance_flags = APPEARANCE_UI, color = owner.accent_color)
		add_overlay(overlay)
		LAZYADD(accent_overlays, overlay)
	RegisterSignal(owner, COMSIG_HOLOPARA_SET_ACCENT_COLOR, PROC_REF(on_set_accent_color))
	RegisterSignal(owner, COMSIG_MOB_LOGIN, PROC_REF(on_login))
	RegisterSignals(owner, list(COMSIG_HOLOPARA_POST_MANIFEST, COMSIG_HOLOPARA_RECALL, COMSIG_MOVABLE_MOVED), PROC_REF(_update_appearance))

/atom/movable/screen/holoparasite/Destroy()
	stop_timer()
	cut_overlays()
	if(toggle_overlay)
		cut_overlay(toggle_overlay)
		QDEL_NULL(toggle_overlay)
	if(LAZYLEN(accent_overlays))
		QDEL_LAZYLIST(accent_overlays)
	UnregisterSignal(owner, list(COMSIG_HOLOPARA_SET_ACCENT_COLOR, COMSIG_MOB_LOGIN, COMSIG_HOLOPARA_POST_MANIFEST, COMSIG_HOLOPARA_RECALL, COMSIG_MOVABLE_MOVED))
	return ..()

/atom/movable/screen/holoparasite/MouseEntered(location, control, params)
	..()
	if(QDELETED(src))
		return
	if(usr == owner)
		last_params = params
	openToolTip(usr, src, params, title = name, content = tooltip_content(), theme = "parasite")

/atom/movable/screen/holoparasite/MouseExited()
	closeToolTip(usr)
	if(usr == owner)
		last_params = null

/atom/movable/screen/holoparasite/update_icon(updates)
	cut_overlays()
	alpha = should_be_transparent() ? 100 : 255
	return ..()

/atom/movable/screen/holoparasite/update_overlays()
	. = ..()
	if(can_toggle && activated() && toggle_overlay)
		. |= toggle_overlay
	var/list/accent_overlays = accent_overlays()
	if(LAZYLEN(accent_overlays))
		. |= accent_overlays
	var/mutable_appearance/timer_overlay = timer_overlay()
	if(timer_overlay)
		. |= timer_overlay

/atom/movable/screen/holoparasite/update_appearance(updates)
	. = ..()
	reopen_tooltip()

/atom/movable/screen/holoparasite/process(delta_time)
	if(!timer || COOLDOWN_FINISHED(src, timer) || !text_overlay)
		stop_timer()
		return PROCESS_KILL
	cut_overlays()
	text_overlay.maptext = "<center><span class='chatOverhead' style='font-weight: bold;color: #eeeeee;'>[FLOOR(COOLDOWN_TIMELEFT(src, timer) * 0.1, 1)]s</span></center>"
	update_icon()

/atom/movable/screen/holoparasite/Click()
	if(usr == owner)
		use()

/**
 * Return TRUE if the HUD button should be transparent, like if it's on cooldown or something.
 */
/atom/movable/screen/holoparasite/proc/should_be_transparent()
	return !isnull(timer_overlay())

/**
 * Begins the timer, starting up the text+progress overlay.
 */
/atom/movable/screen/holoparasite/proc/begin_timer(length)
	if(!text_overlay)
		text_overlay = image(loc = src)
		text_overlay.maptext_width = 64
		text_overlay.maptext_height = 64
		text_overlay.maptext_x = -16
		text_overlay.maptext_y = 2
		text_overlay.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
		text_overlay.maptext = "<center><span class='chatOverhead' style='font-weight: bold;color: #eeeeee;'>[FLOOR(length * 0.1, 1)]s</span></center>"
	if(owner.client)
		owner.client.images |= text_overlay
	timer_length = length
	COOLDOWN_START(src, timer, length)
	update_appearance()
	START_PROCESSING(SSfastprocess, src)

/**
 * Stops the timer, disposing of the text overlay, stopping processing, and redoing the overlays.
 */
/atom/movable/screen/holoparasite/proc/stop_timer()
	cut_overlays()
	COOLDOWN_RESET(src, timer)
	timer_length = 0
	if(owner.client)
		owner.client.images -= text_overlay
	QDEL_NULL(text_overlay)
	update_icon()
	STOP_PROCESSING(SSfastprocess, src)

/atom/movable/screen/holoparasite/proc/on_login()
	SIGNAL_HANDLER
	if(!timer || !text_overlay || !owner?.client)
		return
	owner.client.images |= text_overlay

/atom/movable/screen/holoparasite/proc/on_set_accent_color(datum/_source, _old_accent_color, new_accent_color)
	SIGNAL_HANDLER
	if(toggle_overlay)
		toggle_overlay.color = new_accent_color
	for(var/mutable_appearance/overlay as() in accent_overlays)
		overlay.color = new_accent_color
	update_icon()

/**
 * Reopen the tooltip displayed to the user, if the tooltip is currently open.
 */
/atom/movable/screen/holoparasite/proc/reopen_tooltip()
	if(!last_params)
		return
	openToolTip(owner, src, last_params, title = name, content = tooltip_content(), theme = "parasite")

// Wrapper proc so we don't pass invalid arguments to the actual update_appearance
/atom/movable/screen/holoparasite/proc/_update_appearance()
	SIGNAL_HANDLER
	update_appearance()

/**
 * Get the text content to display in the tooltip, like, a description.
 */
/atom/movable/screen/holoparasite/proc/tooltip_content()
	return desc

/**
 * Whether a toggleable action is currently activated or not.
 */
/atom/movable/screen/holoparasite/proc/activated()
	return FALSE

/**
 * Whether the action is currently 'in use' or not.
 */
/atom/movable/screen/holoparasite/proc/in_use()
	return FALSE

/**
 * A list of accent overlays to apply to the HUD.
 */
/atom/movable/screen/holoparasite/proc/accent_overlays()
	return accent_overlays

/atom/movable/screen/holoparasite/proc/use()
	return

/**
 * The timer overlay to apply to the HUD.
 */
/atom/movable/screen/holoparasite/proc/timer_overlay()
	if(in_use())
		return timer_fraction_overlays["tbd"]
	if(!timer || !timer_length)
		return
	return timer_fraction_overlays["[10 - clamp(round((COOLDOWN_TIMELEFT(src, timer) / timer_length) * 10), 1, 9)]"]

/atom/movable/screen/holoparasite/info
	name = "Info"
	desc = "View information about yourself and your summoner."
	icon_state = "info"

/atom/movable/screen/holoparasite/info/use()
	var/datum/antagonist/holoparasite/holopara_antag = owner.mind?.has_antag_datum(/datum/antagonist/holoparasite)
	holopara_antag?.ui_interact(owner)

/atom/movable/screen/holoparasite/manifest_recall
	name = "Manifest"
	desc = "Manifest from your summoner, appearing behind them, allowing you to fight alongside them."
	icon_state = "manifest"
	var/static/recall_name = "Recall"
	var/static/recall_desc = "Return to your summoner, demanifesting from the world around you."
	var/static/recall_icon = "recall"

/atom/movable/screen/holoparasite/manifest_recall/update_name()
	name = owner.is_manifested() ? recall_name : initial(name)
	return ..()

/atom/movable/screen/holoparasite/manifest_recall/update_desc(updates)
	desc = owner.is_manifested() ? recall_desc : initial(desc)
	return ..()

/atom/movable/screen/holoparasite/manifest_recall/update_icon_state()
	icon_state = owner.is_manifested() ? recall_icon : initial(icon_state)
	return ..()

/atom/movable/screen/holoparasite/manifest_recall/use()
	if(owner.is_manifested())
		owner.recall()
	else
		owner.manifest()

/atom/movable/screen/holoparasite/manifest_recall/should_be_transparent()
	return ..() || owner.parent_holder.locked

/atom/movable/screen/holoparasite/communicate
	name = "Communicate"
	desc = "Communicate telepathically with your summoner. Nobody except yourself, your summoner, and any other holoparasites linked to your summoner can hear this communication.\nYou can also use :p / .p in order to communicate."
	icon_state = "communicate"

/atom/movable/screen/holoparasite/communicate/use()
	owner.communicate()

/atom/movable/screen/holoparasite/toggle_light
	name = "Enable Light"
	desc = "Turn on your internal crystalline light, allowing you to glow like star dust. This light will even work while recalled to your summoner."
	icon_state = "light"
	can_toggle = TRUE
	var/static/off_name = "Turn Off Light"
	var/static/off_desc = "Disable your internal crystalline light, allowing you to more easily hide amongst the darkness."

/atom/movable/screen/holoparasite/toggle_light/update_name()
	name = activated() ? off_name : initial(name)
	return ..()

/atom/movable/screen/holoparasite/toggle_light/update_desc(updates)
	desc = activated() ? off_desc : initial(desc)
	return ..()

/atom/movable/screen/holoparasite/toggle_light/use()
	owner.toggle_light()
	update_appearance()

/atom/movable/screen/holoparasite/toggle_light/activated()
	return owner.is_light_on()

/atom/movable/screen/holoparasite/set_battlecry
	icon_state = "ora"
	name = "Set Battlecry"
	desc = "Set (or disable) your battlecry - the phrase you shout out whenever you hit something."

/atom/movable/screen/holoparasite/set_battlecry/use()
	owner.set_battlecry_v()
	reopen_tooltip()

/atom/movable/screen/holoparasite/set_battlecry/tooltip_content()
	return "[desc]<br><b>Current battlecry</b>: [length(owner.battlecry) ? "\"<i>[owner.battlecry]!!</i>\"" : "<i>(none)</i>"]"
