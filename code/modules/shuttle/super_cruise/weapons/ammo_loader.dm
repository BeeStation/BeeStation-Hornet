/obj/machinery/ammo_loader
	name = "ammunition loader"
	desc = "An ammunition loader for shuttle mounted weaponry. Can be connected to a single mounted weapon with a multitool."
	icon = 'icons/obj/shuttle_32x64.dmi'
	icon_state = "ammo_loader"
	/// The amount of slots this loader has for ammunition crates
	var/slots = 2
	/// The weapon attached to us
	var/obj/machinery/shuttle_weapon/attached_weapon

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
			var/id = sanitize_integer(params["id"])
			if (id <= 0 || id > length(contents))
				return FALSE
			var/atom/movable/thing = contents[id]
			thing.forceMove(loc)
			usr.put_in_active_hand(thing)
			return TRUE

/obj/machinery/ammo_loader/attacked_by(obj/item/I, mob/living/user)
	if (!is_accepted(I) || user.a_intent == INTENT_HARM)
		return ..()
	if (length(contents) >= slots)
		to_chat(user, "<span class='warning'>[src] is full!</span>")
		return
	I.forceMove(src)
	to_chat(user, "<span class='notice'>You insert [I] into [src].</span>")

/obj/machinery/ammo_loader/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	ui_update()

/obj/machinery/ammo_loader/Exited(atom/movable/gone, direction)
	. = ..()
	ui_update()

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

/obj/machinery/ammo_loader/proc/is_accepted(atom/movable/input)
	return FALSE

// ========================
// Missile Ammo Loader
// ========================

/obj/machinery/ammo_loader/missile
	name = "missile auto-loader"
	desc = "A missile rack auto-loader for shuttle mounted rocket pods. Can be connected to a single mounted weapon using a multitool."
	// Holds individual missiles
	slots = 5

/obj/machinery/ammo_loader/missile/is_accepted(obj/item/ammo_casing/missile)
	if (!istype(missile))
		return FALSE
	return missile.caliber == "shuttle_missile"
