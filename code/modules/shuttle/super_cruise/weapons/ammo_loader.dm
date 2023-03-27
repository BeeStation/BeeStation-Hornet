/obj/machinery/ammo_loader
	name = "ammunition loader"
	desc = "An ammunition loader for shuttle mounted weaponry. Can be connected to a single mounted weapon with a multitool."
	icon = 'icons/obj/shuttle_32x64.dmi'
	icon_state = "ammo_loader"
	density = TRUE
	/// The amount of slots this loader has for ammunition crates
	var/slots = 2
	/// The weapon attached to us
	var/obj/machinery/shuttle_weapon/attached_weapon

	/// The linkup ID for auto-linking to ammo loaders
	var/mapload_linkup_id = 0

/obj/machinery/ammo_loader/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/ammo_loader/LateInitialize()
	. = ..()
	if (!mapload_linkup_id)
		return
	for (var/obj/machinery/shuttle_weapon/weapon in GLOB.machines)
		if (weapon.ammunition_loader)
			continue
		if (!weapon.mapload_linkup_id)
			continue
		if (weapon.mapload_linkup_id != mapload_linkup_id)
			continue
		if (weapon.get_virtual_z_level() != get_virtual_z_level())
			continue
		weapon.try_link_to(null, src)

/obj/machinery/ammo_loader/Destroy()
	if (attached_weapon)
		attached_weapon.ammunition_loader = null
	return ..()

/obj/machinery/ammo_loader/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "AmmoLoader")
		ui.open()

/obj/machinery/ammo_loader/ui_data(mob/user)
	var/list/data = list()
	data["loaded"] = list()
	var/id = 0
	for (var/atom/movable/thing in contents)
		var/obj/item/ammo_box/ammo_box = thing
		data["loaded"] += list(list(
			"name" = thing.name,
			"count" = istype(ammo_box) ? length(ammo_box.stored_ammo) : 1,
			"id" = id++,
		))
	return data

/obj/machinery/ammo_loader/ui_act(action, params)
	. = ..()
	if (.)
		return

	switch (action)
		if ("eject")
			var/id = text2num(params["id"])
			if (id <= 0 || id > length(contents))
				return FALSE
			var/atom/movable/thing = contents[id]
			thing.forceMove(loc)
			usr.put_in_active_hand(thing)
			return TRUE

/obj/machinery/ammo_loader/attackby(obj/item/I, mob/user)
	if (user.a_intent == INTENT_HARM)
		return ..()
	if (istype(I, /obj/item/multitool))
		var/datum/component/buffer/buff = I.GetComponent(/datum/component/buffer)
		if (buff && istype(buff.referenced_machine, /obj/machinery/shuttle_weapon))
			var/obj/machinery/shuttle_weapon/weapon = buff.referenced_machine
			weapon.try_link_to(user, src)
			return
		I.AddComponent(/datum/component/buffer, src)
		to_chat(user, "<span class='notice'>You add [src] to the buffer of [I].</span>")
		return
	if (!is_accepted(I))
		return ..()
	if (length(contents) >= slots)
		to_chat(user, "<span class='warning'>[src] is full!</span>")
		return
	I.forceMove(src)
	to_chat(user, "<span class='notice'>You insert [I] into [src].</span>")

/obj/machinery/ammo_loader/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	ui_update()
	update_appearance(UPDATE_ICON)

/obj/machinery/ammo_loader/Exited(atom/movable/gone, direction)
	. = ..()
	ui_update()
	update_appearance(UPDATE_ICON)

/obj/machinery/ammo_loader/update_icon(updates)
	. = ..()
	cut_overlays()
	var/index = 1
	var/list/valid_icons = icon_states(icon)
	for (var/atom/movable/thing in contents)
		var/overlay_state = "[thing.icon_state][index]"
		if (overlay_state in valid_icons)
			add_overlay(icon(icon, overlay_state))
		index ++

/// Take a bullet with the desired caliber.
/// Will return an ammo casing
/obj/machinery/ammo_loader/proc/take_bullet(desired_caliber)
	RETURN_TYPE(/obj/item/ammo_casing)
	// Check ammo boxes
	for (var/obj/item/ammo_box/ammo_box in contents)
		// Incorrect ammo box caliber
		if (ammo_box.caliber != desired_caliber)
			continue
		// Try and take a bullet from the ammo box
		var/taken = ammo_box.get_round()
		if (taken)
			return taken
	// Check projectiles
	for (var/obj/item/ammo_casing/casing in contents)
		if (casing.caliber != desired_caliber)
			continue
		// Take the bullet from the casing
		return casing
	// Nothing found
	return null

/obj/machinery/ammo_loader/proc/has_ammo(desired_caliber)
	// Check ammo boxes
	for (var/obj/item/ammo_box/ammo_box in contents)
		// Incorrect ammo box caliber
		if (ammo_box.caliber != desired_caliber)
			continue
		// Try and take a bullet from the ammo box
		if (ammo_box.stored_ammo.len)
			return TRUE
	// Check projectiles
	for (var/obj/item/ammo_casing/casing in contents)
		if (casing.caliber != desired_caliber)
			continue
		// Take the bullet from the casing
		return TRUE
	// Nothing found
	return FALSE

/obj/machinery/ammo_loader/proc/is_accepted(atom/movable/input)
	return FALSE

// ========================
// Laser Charger
// ========================

/obj/machinery/ammo_loader/laser
	name = "laser charging unit"
	desc = "A unit for charging laser weapons."
	slots = 1
	icon = 'icons/obj/shuttle_weapons.dmi'
	icon_state = "loader_charge"
	circuit = /obj/item/circuitboard/machine/loader_laser
	// APC cells start with 2500 power, so this will drain it fast
	var/power_per_shot = 60

/obj/machinery/ammo_loader/laser/Initialize(mapload)
	. = ..()
	power_per_shot /= GLOB.CELLRATE

/obj/machinery/ammo_loader/laser/is_accepted(obj/item/ammo_casing/rail)
	return FALSE

/obj/machinery/ammo_loader/laser/take_bullet(desired_caliber)
	if (!powered())
		return null
	use_power(power_per_shot)
	return new /obj/item/ammo_casing/caseless/laser/shuttle(loc)

/obj/machinery/ammo_loader/laser/has_ammo(desired_caliber)
	return is_operational && powered()

/obj/item/circuitboard/machine/loader_laser
	name = "laser charging unit (Machine Board)"
	icon_state = "security"
	build_path = /obj/machinery/ammo_loader/laser
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/capacitor = 3,
		)

// ========================
// Railgun Shell Loader
// ========================

/obj/machinery/ammo_loader/railgun
	name = "railgun auto-loader"
	desc = "An ammunition rack for loading rails into railguns. Can be connected to a single mounted weapon using a multitool."
	slots = 5
	icon = 'icons/obj/shuttle_weapons.dmi'
	icon_state = "loader_box"
	circuit = /obj/item/circuitboard/machine/loader_railgun

/obj/machinery/ammo_loader/railgun/is_accepted(obj/item/ammo_casing/rail)
	if (!istype(rail))
		return FALSE
	return rail.caliber == "shuttle_railgun"

/obj/item/circuitboard/machine/loader_railgun
	name = "railgun auto-loader (Machine Board)"
	icon_state = "security"
	build_path = /obj/machinery/ammo_loader/railgun
	req_components = list(
		/obj/item/stock_parts/manipulator = 2
		)

// ========================
// Box Ammo Loader
// ========================

/obj/machinery/ammo_loader/ballistic
	name = "ballistic auto-loader"
	desc = "An ammunition rack for loading ammo boxes into shuttle-mounted ballistic weapons. Can be connected to a single mounted weapon using a multitool."
	slots = 2
	icon = 'icons/obj/shuttle_weapons.dmi'
	icon_state = "loader_box"
	circuit = /obj/item/circuitboard/machine/loader_ballistic

/obj/machinery/ammo_loader/ballistic/is_accepted(obj/item/ammo_box/box)
	if (!istype(box))
		return FALSE
	return box.caliber == "shuttle_chaingun" || box.caliber == "shuttle_flak"

/obj/item/circuitboard/machine/loader_ballistic
	name = "ballistic auto-loader (Machine Board)"
	icon_state = "security"
	build_path = /obj/machinery/ammo_loader/ballistic
	req_components = list(
		/obj/item/stock_parts/manipulator = 2
		)

// ========================
// Missile Ammo Loader
// ========================

/obj/machinery/ammo_loader/missile
	name = "missile auto-loader"
	desc = "A missile rack auto-loader for shuttle mounted rocket pods. Can be connected to a single mounted weapon using a multitool."
	// Holds individual missiles
	slots = 5
	icon = 'icons/obj/shuttle_weapons_large.dmi'
	icon_state = "loader_missile"
	circuit = /obj/item/circuitboard/machine/loader_missile

/obj/machinery/ammo_loader/missile/is_accepted(obj/item/ammo_casing/missile)
	if (!istype(missile))
		return FALSE
	return missile.caliber == "shuttle_missile"

/obj/item/circuitboard/machine/loader_missile
	name = "missile auto-loader (Machine Board)"
	icon_state = "security"
	build_path = /obj/machinery/ammo_loader/missile
	req_components = list(
		/obj/item/stock_parts/manipulator = 2
		)

// ========================
// Linkup
// ========================

/datum/component/buffer
	dupe_mode = COMPONENT_DUPE_HIGHLANDER
	var/referenced_machine

/datum/component/buffer/Initialize(machine)
	if (!machine)
		return COMPONENT_INCOMPATIBLE
	referenced_machine = machine
	RegisterSignal(referenced_machine, COMSIG_PARENT_QDELETING, PROC_REF(unlink))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(unlink_mob))

/datum/component/buffer/proc/unlink_mob(datum/source, mob/user)
	SIGNAL_HANDLER
	if (istype(user))
		to_chat(user, "<span class='notice'>You unlink [parent] from [referenced_machine].<span>")
	qdel(src)

/datum/component/buffer/proc/unlink()
	SIGNAL_HANDLER
	qdel(src)
