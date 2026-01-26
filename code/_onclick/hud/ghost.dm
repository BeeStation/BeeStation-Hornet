/atom/movable/screen/ghost
	icon = 'icons/hud/screen_ghost.dmi'
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/ghost/MouseEntered()
	..()
	flick(icon_state + "_anim", src)

/atom/movable/screen/ghost/observe
	name = "Observe"
	icon_state = "observe"

/atom/movable/screen/ghost/observe/Click()
	var/mob/dead/observer/G = usr
	G.observe()

/atom/movable/screen/ghost/jumptomob
	name = "Jump to mob"
	icon_state = "jumptomob"

/atom/movable/screen/ghost/jumptomob/Click()
	var/mob/dead/observer/G = usr
	G.jumptomob()

/atom/movable/screen/ghost/orbit
	name = "Orbit"
	icon_state = "orbit"

/atom/movable/screen/ghost/orbit/Click()
	var/mob/dead/observer/G = usr
	G.follow()

/atom/movable/screen/ghost/reenter_corpse
	name = "Reenter corpse"
	icon_state = "reenter_corpse"

/atom/movable/screen/ghost/reenter_corpse/Click()
	var/mob/dead/observer/G = usr
	G.reenter_corpse()

/atom/movable/screen/ghost/teleport
	name = "Teleport"
	icon_state = "teleport"

/atom/movable/screen/ghost/teleport/Click()
	var/mob/dead/observer/G = usr
	G.dead_tele()

/atom/movable/screen/ghost/pai
	name = "pAI Candidate"
	icon_state = "pai"

/atom/movable/screen/ghost/pai/Click()
	var/mob/dead/observer/G = usr
	G.register_pai()

/atom/movable/screen/ghost/spawners_menu
	name = "Spawners Menu"
	icon_state = "spawners_menu"

/atom/movable/screen/ghost/respawn
	name = "Respawn"
	icon_state = "respawn"

/atom/movable/screen/ghost/respawn/Click()
	var/mob/dead/observer/G = usr
	G.abandon_mob()

/atom/movable/screen/ghost/respawn/update_icon_state(mob/dead/observer/mymob)
	if(mymob)
		if(mymob.respawn_available)
			icon_state = "respawn_available"
		else
			icon_state = "respawn"
	return ..()

/atom/movable/screen/ghost/spawners_menu/Click()
	var/mob/dead/observer/G = usr
	G.open_spawners_menu()

/datum/hud/ghost/New(mob/owner)
	..()
	var/atom/movable/screen/using

	using = new /atom/movable/screen/ghost/observe(null, src)
	static_inventory += using

	using = new /atom/movable/screen/ghost/jumptomob(null, src)
	static_inventory += using

	using = new /atom/movable/screen/ghost/orbit(null, src)
	static_inventory += using

	using = new /atom/movable/screen/ghost/reenter_corpse(null, src)
	static_inventory += using

	if (isobserver(owner))
		var/mob/dead/observer/observer = owner
		if (observer.can_respawn)
			using = new /atom/movable/screen/ghost/respawn(null, src)
			static_inventory += using

	using = new /atom/movable/screen/ghost/teleport(null, src)
	static_inventory += using

	using = new /atom/movable/screen/ghost/pai(null, src)
	static_inventory += using

	using = new /atom/movable/screen/ghost/spawners_menu(null, src)
	static_inventory += using

	// Layout
	var/count = 0
	for (var/atom/movable/screen/ghost/auto_layout in static_inventory)
		count ++
	var/left_offset = -(count - 1) / 2
	var/index = 0
	for (var/atom/movable/screen/ghost/auto_layout in static_inventory)
		auto_layout.screen_loc = ui_ghost_center(left_offset + index)
		index ++

	// Always position this one at the end
	using = new /atom/movable/screen/language_menu
	using.icon = ui_style
	using.screen_loc = ui_ghost_center(left_offset + index)
	static_inventory += using

/datum/hud/ghost/show_hud(version = 0, mob/viewmob)
	// don't show this HUD if observing; show the HUD of the observee
	var/mob/dead/observer/O = mymob
	if (istype(O) && O.observetarget)
		plane_masters_update()
		return FALSE

	. = ..()
	if(!.)
		return
	var/mob/screenmob = viewmob || mymob
	if(isnull(screenmob.client.prefs) || screenmob.client.prefs.read_player_preference(/datum/preference/toggle/ghost_hud))
		screenmob.client.screen += static_inventory
	else
		screenmob.client.screen -= static_inventory

//We should only see observed mob alerts.
/datum/hud/ghost/reorganize_alerts(mob/viewmob)
	var/mob/dead/observer/O = mymob
	if (istype(O) && O.observetarget)
		return
	. = ..()

