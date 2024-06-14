/obj/item/gun/energy
	icon_state = "energy"
	name = "energy gun"
	desc = "A basic energy-based gun."
	icon = 'icons/obj/guns/energy.dmi'

	///What type of power cell this uses
	var/obj/item/stock_parts/cell/cell
	var/cell_type = /obj/item/stock_parts/cell
	/// how much charge the cell will have, if we want the gun to have some abnormal charge level without making a new battery.
	var/gun_charge
	///if the weapon has custom icons for individual ammo types it can switch between. ie disabler beams, taser, laser/lethals, ect.
	var/modifystate = FALSE
	var/list/ammo_type = list(/obj/item/ammo_casing/energy)
	///The state of the select fire switch. Determines from the ammo_type list what kind of shot is fired next.
	var/select = 1
	///If the user can select the firemode through attack_self.
	var/can_select = TRUE
	///Can it be charged in a recharger?
	var/can_charge = TRUE
	///Do we handle overlays with base update_overlays()?
	var/automatic_charge_overlays = TRUE
	var/charge_sections = 4
	ammo_x_offset = 2
	///if this gun uses a stateful charge bar for more detail
	var/shaded_charge = FALSE
	///If this gun has a "this is loaded with X" overlay alongside chargebars and such
	var/single_shot_type_overlay = TRUE
	///Should we give an overlay to empty guns?
	var/display_empty = TRUE
	var/selfcharge = 0
	var/charge_timer = 0
	var/charge_delay = 8
	///whether the gun's cell drains the cyborg user's cell to recharge
	var/use_cyborg_cell = FALSE
	///set to true so the gun is given an empty cell
	var/dead_cell = FALSE
	/// Should the charge overlay be emissive?
	var/emissive_charge = TRUE

/obj/item/gun/energy/emp_act(severity)
	. = ..()
	if(!(. & EMP_PROTECT_CONTENTS))
		obj_flags |= OBJ_EMPED
		update_appearance()
		addtimer(CALLBACK(src, PROC_REF(emp_reset)), rand(1, 200 / severity))
		playsound(src, 'sound/machines/capacitor_discharge.ogg', 60, TRUE)

/obj/item/gun/energy/proc/emp_reset()
	obj_flags &= ~OBJ_EMPED
	//Update the icon
	update_appearance()
	//Play a sound to indicate re-activation
	playsound(src, 'sound/machines/capacitor_charge.ogg', 90, TRUE)

/obj/item/gun/energy/get_cell()
	return cell

/obj/item/gun/energy/Initialize(mapload)
	. = ..()
	if(cell_type)
		cell = new cell_type(src)
		if(gun_charge) //But we only use this if it is defined instead of overwriting every cell to 1000 by default like a dumbass
			cell.maxcharge = gun_charge
			cell.charge = gun_charge
	else
		cell = new(src)
	if(dead_cell)	//this makes much more sense.
		cell.use(cell.maxcharge)
	update_ammo_types()
	recharge_newshot(TRUE)
	if(selfcharge)
		START_PROCESSING(SSobj, src)
	update_appearance()
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/gun/energy/fire_sounds()
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	var/batt_percent = FLOOR(clamp(cell.charge / cell.maxcharge, 0, 1) * 100, 1)
	var/shot_cost_percent = 0
	var/max_shots = 0
	var/shots_left = 0
	var/frequency_to_use = 0

	if(shot.e_cost > 0)
		shot_cost_percent = FLOOR(clamp(shot.e_cost / cell.maxcharge, 0.01, 1) * 100, 1)
		max_shots = shot_cost_percent ? round(100/shot_cost_percent) : 0 //Division by 0 protection
		shots_left = shot_cost_percent  ? round(batt_percent/shot_cost_percent) : 0 //Division by 0 protection
		frequency_to_use = sin((90/max_shots) * shots_left)

	var/click_frequency_to_use = 1 - frequency_to_use * 0.75
	var/play_click = round(sqrt(max_shots * 4)) > shots_left

	if(suppressed)
		playsound(src, suppressed_sound, suppressed_volume, vary_fire_sound, ignore_walls = FALSE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_distance = 0, frequency = frequency_to_use)
		if(play_click)
			playsound(src, 'sound/weapons/effects/energy_click.ogg', suppressed_volume, vary_fire_sound, ignore_walls = FALSE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_distance = 0, frequency = click_frequency_to_use)
	else
		playsound(src, fire_sound, fire_sound_volume, vary_fire_sound, frequency = frequency_to_use)
		if(play_click)
			playsound(src, 'sound/weapons/effects/energy_click.ogg', fire_sound_volume, vary_fire_sound, frequency = click_frequency_to_use)

/obj/item/gun/energy/proc/update_ammo_types()
	var/obj/item/ammo_casing/energy/shot
	for(var/i in 1 to ammo_type.len)
		var/shottype = ammo_type[i]
		shot = new shottype(src)
		ammo_type[i] = shot
	shot = ammo_type[select]
	fire_sound = shot.fire_sound
	fire_delay = shot.delay

/obj/item/gun/energy/Destroy()
	if (cell)
		QDEL_NULL(cell)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/gun/energy/handle_atom_del(atom/A)
	if(A == cell)
		cell = null
		update_appearance()
	return ..()

/obj/item/gun/energy/process(delta_time)
	if(selfcharge && cell && cell.percent() < 100)
		charge_timer += delta_time
		if(charge_timer < charge_delay)
			return
		charge_timer = 0
		cell.give(100)
		if(!chambered) //if empty chamber we try to charge a new shot
			recharge_newshot(TRUE)
		update_appearance()

/obj/item/gun/energy/attack_self(mob/living/user as mob)
	if(ammo_type.len > 1 && can_select)
		select_fire(user)

/obj/item/gun/energy/can_shoot()
	//Cannot shoot while EMPed
	if(obj_flags & OBJ_EMPED)
		return FALSE
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	return !QDELETED(cell) ? (cell.charge >= shot.e_cost) : FALSE

/obj/item/gun/energy/recharge_newshot(no_cyborg_drain)
	if (!ammo_type || !cell)
		return
	if(use_cyborg_cell && !no_cyborg_drain)
		if(iscyborg(loc))
			var/mob/living/silicon/robot/R = loc
			if(R.cell)
				var/obj/item/ammo_casing/energy/shot = ammo_type[select] //Necessary to find cost of shot
				if(R.cell.use(shot.e_cost)) 		//Take power from the borg...
					cell.give(shot.e_cost)	//... to recharge the shot
	if(!chambered)
		var/obj/item/ammo_casing/energy/AC = ammo_type[select]
		if(cell.charge >= AC.e_cost) //if there's enough power in the cell cell...
			chambered = AC //...prepare a new shot based on the current ammo type selected
			if(!chambered.BB)
				chambered.newshot()

/obj/item/gun/energy/process_chamber()
	if(chambered && !chambered.BB) //if BB is null, i.e the shot has been fired...
		var/obj/item/ammo_casing/energy/shot = chambered
		cell.use(shot.e_cost)//... drain the cell cell
	chambered = null //either way, released the prepared shot
	recharge_newshot() //try to charge a new shot

/obj/item/gun/energy/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	if(!chambered && can_shoot())
		process_chamber()	// If the gun was drained and then recharged, load a new shot.
	return ..()

/obj/item/gun/energy/process_burst(mob/living/user, atom/target, message = TRUE, params = null, zone_override="", sprd = 0, randomized_gun_spread = 0, randomized_bonus_spread = 0, rand_spr = 0, iteration = 0)
	if(!chambered && can_shoot())
		process_chamber()	// Ditto.
	return ..()

/obj/item/gun/energy/proc/select_fire(mob/living/user)
	select++
	if (select > ammo_type.len)
		select = 1
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	fire_sound = shot.fire_sound
	fire_delay = shot.delay
	if (shot.select_name && user)
		balloon_alert(user, "You set [src]'s mode to [shot.select_name].")
	chambered = null
	recharge_newshot(TRUE)
	update_appearance()

/obj/item/gun/energy/update_icon_state()
	var/skip_inhand = initial(item_state) //only build if we aren't using a preset inhand icon
	var/skip_worn_icon = initial(worn_icon_state) //only build if we aren't using a preset worn icon

	if(skip_inhand && skip_worn_icon) //if we don't have either, don't do the math.
		return ..()

	if(QDELETED(src))
		return
	if(!automatic_charge_overlays)
		return ..()

	var/ratio = get_charge_ratio()
	var/temp_icon_to_use = initial(icon_state)
	if(modifystate)
		var/obj/item/ammo_casing/energy/shot = ammo_type[select]
		temp_icon_to_use += "[initial(shot.select_name)]"

	temp_icon_to_use += "[ratio]"
	if(!skip_inhand)
		item_state = temp_icon_to_use
	if(!skip_worn_icon)
		worn_icon_state = temp_icon_to_use
	return ..()

/obj/item/gun/energy/update_overlays()
	. = ..()
	if(!automatic_charge_overlays)
		return

	var/overlay_icon_state = "[icon_state]_charge"
	if(modifystate)
		var/obj/item/ammo_casing/energy/shot = ammo_type[select]
		if(single_shot_type_overlay)
			. += "[icon_state]_[initial(shot.select_name)]"
		overlay_icon_state += "_[initial(shot.select_name)]"

	var/ratio = get_charge_ratio()
	//Display no power if EMPed
	if(obj_flags & OBJ_EMPED)
		ratio = 0
	if(ratio == 0 && display_empty)
		. += "[icon_state]_empty"
		return
	else
		if(!shaded_charge)
			for(var/i = ratio, i >= 1, i--)
				var/mutable_appearance/charge_overlay = mutable_appearance(icon, overlay_icon_state)
				charge_overlay.pixel_x = ammo_x_offset * (i - 1)
				charge_overlay.pixel_y = ammo_y_offset * (i - 1)
				. += charge_overlay
				if (!emissive_charge)
					continue
				var/mutable_appearance/charge_overlay_emissive = emissive_appearance(icon, overlay_icon_state, layer = src.layer, alpha = 80)
				ADD_LUM_SOURCE(src, LUM_SOURCE_MANAGED_OVERLAY)
				charge_overlay_emissive.pixel_x = ammo_x_offset * (i - 1)
				charge_overlay_emissive.pixel_y = ammo_y_offset * (i - 1)
				. += charge_overlay_emissive
		else
			. += "[icon_state]_charge[ratio]"
			if (emissive_charge)
				. += emissive_appearance(icon, "[icon_state]_charge[ratio]", layer = src.layer, alpha = 80)
				ADD_LUM_SOURCE(src, LUM_SOURCE_MANAGED_OVERLAY)

///Used by update_icon_state() and update_overlays()
/obj/item/gun/energy/proc/get_charge_ratio()
	return can_shoot() ? CEILING(clamp(cell.charge / cell.maxcharge, 0, 1) * charge_sections, 1) : 0
	// Sets the ratio to 0 if the gun doesn't have enough charge to fire, or if its power cell is removed.

/obj/item/gun/energy/suicide_act(mob/living/user)
	if (istype(user) && can_shoot() && can_trigger_gun(user) && user.get_bodypart(BODY_ZONE_HEAD))
		user.visible_message("<span class='suicide'>[user] is putting the barrel of [src] in [user.p_their()] mouth.  It looks like [user.p_theyre()] trying to commit suicide!</span>")
		sleep(25)
		if(user.is_holding(src))
			user.visible_message("<span class='suicide'>[user] melts [user.p_their()] face off with [src]!</span>")
			playsound(loc, fire_sound, 50, 1, -1)
			var/obj/item/ammo_casing/energy/shot = ammo_type[select]
			cell.use(shot.e_cost)
			update_appearance()
			return(FIRELOSS)
		else
			user.visible_message("<span class='suicide'>[user] panics and starts choking to death!</span>")
			return OXYLOSS
	else
		user.visible_message("<span class='suicide'>[user] is pretending to melt [user.p_their()] face off with [src]! It looks like [user.p_theyre()] trying to commit suicide!</b></span>")
		playsound(src, dry_fire_sound, 30, TRUE)
		return OXYLOSS


/obj/item/gun/energy/vv_edit_var(var_name, var_value)
	switch(var_name)
		if(NAMEOF(src, selfcharge))
			if(var_value)
				START_PROCESSING(SSobj, src)
			else
				STOP_PROCESSING(SSobj, src)
	. = ..()


/obj/item/gun/energy/ignition_effect(atom/A, mob/living/user)
	if(!can_shoot() || !ammo_type[select])
		shoot_with_empty_chamber()
		. = ""
	else
		var/obj/item/ammo_casing/energy/E = ammo_type[select]
		var/obj/projectile/energy/BB = E.BB
		if(!BB)
			. = ""
		else if(BB.nodamage || !BB.damage || BB.damage_type == STAMINA)
			user.visible_message("<span class='danger'>[user] tries to light [A.loc == user ? "[user.p_their()] [A.name]" : A] with [src], but it doesn't do anything. Dumbass.</span>")
			playsound(user, E.fire_sound, 50, 1)
			playsound(user, BB.hitsound, 50, 1)
			cell.use(E.e_cost)
			. = ""
		else if(BB.damage_type != BURN)
			user.visible_message("<span class='danger'>[user] tries to light [A.loc == user ? "[user.p_their()] [A.name]" : A] with [src], but only succeeds in utterly destroying it. Dumbass.</span>")
			playsound(user, E.fire_sound, 50, 1)
			playsound(user, BB.hitsound, 50, 1)
			cell.use(E.e_cost)
			qdel(A)
			. = ""
		else
			playsound(user, E.fire_sound, 50, 1)
			playsound(user, BB.hitsound, 50, 1)
			cell.use(E.e_cost)
			. = "<span class='danger'>[user] casually lights [A.loc == user ? "[user.p_their()] [A.name]" : A] with [src]. Damn.</span>"
