/obj/item/gun/energy
	icon_state = "energy"
	name = "energy gun"
	desc = "A basic energy-based gun."
	icon = 'icons/obj/guns/energy.dmi'

	var/obj/item/stock_parts/cell/cell //What type of power cell this uses
	var/cell_type = /obj/item/stock_parts/cell
	var/modifystate = 0
	var/list/ammo_type = list(/obj/item/ammo_casing/energy)
	var/select = 1 //The state of the select fire switch. Determines from the ammo_type list what kind of shot is fired next.
	var/can_charge = TRUE //Can it be charged in a recharger?
	var/automatic_charge_overlays = TRUE	//Do we handle overlays with base update_icon()?
	var/charge_sections = 4
	ammo_x_offset = 2
	var/shaded_charge = FALSE //if this gun uses a stateful charge bar for more detail
	var/old_ratio = 0 // stores the gun's previous ammo "ratio" to see if it needs an updated icon
	var/selfcharge = 0
	var/charge_timer = 0
	var/charge_delay = 8
	var/use_cyborg_cell = FALSE //whether the gun's cell drains the cyborg user's cell to recharge
	var/dead_cell = FALSE //set to true so the gun is given an empty cell

/obj/item/gun/energy/emp_act(severity)
	. = ..()
	if(!(. & EMP_PROTECT_CONTENTS))
		cell.use(round(cell.charge / severity))
		chambered = null //we empty the chamber
		recharge_newshot() //and try to charge a new shot
		update_icon()

/obj/item/gun/energy/get_cell()
	return cell

/obj/item/gun/energy/Initialize()
	. = ..()
	if(cell_type)
		cell = new cell_type(src)
	else
		cell = new(src)
	if(dead_cell)	//this makes much more sense.
		cell.use(cell.maxcharge)
	update_ammo_types()
	recharge_newshot(TRUE)
	if(selfcharge)
		START_PROCESSING(SSobj, src)
	update_icon()

/obj/item/gun/energy/add_weapon_description()
	AddElement(/datum/element/weapon_description, attached_proc = .proc/add_notes_energy)

/**
 *
 * Outputs type-specific weapon stats for energy-based firearms based on its firing modes
 * and the stats of those firing modes. Esoteric firing modes like ion are currently not supported
 * but can be added easily
 *
 */
/obj/item/gun/energy/proc/add_notes_energy()
	var/list/readout = list()
	// Make sure there is something to actually retrieve
	if(!ammo_type.len)
		return
	var/obj/item/projectile/exam_proj
	readout += "\nStandard models of this projectile weapon have <span class='warning'>[ammo_type.len] mode\s</span>"
	readout += "Our heroic interns have shown that one can theoretically stay standing after..."
	for(var/obj/item/ammo_casing/energy/for_ammo as anything in ammo_type)
		exam_proj = GLOB.proj_by_path_key[for_ammo?.projectile_type]
		if(!istype(exam_proj))
			continue

		if(exam_proj.damage > 0) // Don't divide by 0!!!!!
			readout += "<span class='warning'>[HITS_TO_CRIT(exam_proj.damage)] shot\s</span> on <span class='warning'>[for_ammo.select_name]</span> mode before collapsing from [exam_proj.damage_type == STAMINA ? "immense pain" : "their wounds"]."
			if(exam_proj.stamina > 0) // In case a projectile does damage AND stamina damage (Energy Crossbow)
				readout += "<span class='warning'>[HITS_TO_CRIT(exam_proj.stamina)] shot\s</span> on <span class='warning'>[for_ammo.select_name]</span> mode before collapsing from immense pain."
		else
			readout += "a theoretically infinite number of shots on <span class='warning'>[for_ammo.select_name]</span> mode."

	return readout.Join("\n") // Sending over the singular string, rather than the whole list

/obj/item/gun/energy/proc/update_ammo_types()
	var/obj/item/ammo_casing/energy/shot
	for (var/i = 1, i <= ammo_type.len, i++)
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
		update_icon(FALSE, TRUE)
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
		update_icon()

/obj/item/gun/energy/attack_self(mob/living/user as mob)
	if(ammo_type.len > 1)
		select_fire(user)
		update_icon()

/obj/item/gun/energy/can_shoot()
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
	if (shot.select_name)
		balloon_alert(user, "Set to [shot.select_name]")
	chambered = null
	recharge_newshot(TRUE)
	update_icon(TRUE)
	return

/obj/item/gun/energy/update_icon(force_update)
	if(QDELETED(src))
		return
	..()
	if(!automatic_charge_overlays)
		return
	var/ratio = CEILING(CLAMP(cell.charge / cell.maxcharge, 0, 1) * charge_sections, 1)
	if(ratio == old_ratio && !force_update)
		return
	old_ratio = ratio
	cut_overlays()
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	var/iconState = "[icon_state]_charge"
	var/itemState = null
	if(!initial(item_state))
		itemState = icon_state
	if (modifystate)
		add_overlay("[icon_state]_[shot.select_name]")
		iconState += "_[shot.select_name]"
		if(itemState)
			itemState += "[shot.select_name]"
	if(cell.charge < shot.e_cost)
		add_overlay("[icon_state]_empty")
	else
		if(!shaded_charge)
			var/mutable_appearance/charge_overlay = mutable_appearance(icon, iconState)
			for(var/i = ratio, i >= 1, i--)
				charge_overlay.pixel_x = ammo_x_offset * (i - 1)
				charge_overlay.pixel_y = ammo_y_offset * (i - 1)
				add_overlay(charge_overlay)
		else
			add_overlay("[icon_state]_charge[ratio]")
	if(itemState)
		itemState += "[ratio]"
		item_state = itemState

/obj/item/gun/energy/suicide_act(mob/living/user)
	if (istype(user) && can_shoot() && can_trigger_gun(user) && user.get_bodypart(BODY_ZONE_HEAD))
		user.visible_message("<span class='suicide'>[user] is putting the barrel of [src] in [user.p_their()] mouth.  It looks like [user.p_theyre()] trying to commit suicide!</span>")
		sleep(25)
		if(user.is_holding(src))
			user.visible_message("<span class='suicide'>[user] melts [user.p_their()] face off with [src]!</span>")
			playsound(loc, fire_sound, 50, 1, -1)
			var/obj/item/ammo_casing/energy/shot = ammo_type[select]
			cell.use(shot.e_cost)
			update_icon()
			return(FIRELOSS)
		else
			user.visible_message("<span class='suicide'>[user] panics and starts choking to death!</span>")
			return(OXYLOSS)
	else
		user.visible_message("<span class='suicide'>[user] is pretending to melt [user.p_their()] face off with [src]! It looks like [user.p_theyre()] trying to commit suicide!</b></span>")
		playsound(src, dry_fire_sound, 30, TRUE)
		return (OXYLOSS)


/obj/item/gun/energy/vv_edit_var(var_name, var_value)
	switch(var_name)
		if("selfcharge")
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
		var/obj/item/projectile/energy/BB = E.BB
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
