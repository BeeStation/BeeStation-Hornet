// update the APC icon to show the three base states
// also add overlays for indicator lights
/obj/machinery/power/apc/update_icon()
	var/update = check_updates()
	//returns 0 if no need to update icons.
	// 1 if we need to update the icon_state
	// 2 if we need to update the overlays
	if(!update)
		icon_update_needed = FALSE
		return

	if(update & 1) // Updating the icon state
		if(update_state & UPSTATE_ALLGOOD)
			icon_state = "apc0"
		else if(update_state & (UPSTATE_OPENED1|UPSTATE_OPENED2))
			var/basestate = "apc[ cell ? "2" : "1" ]"
			if(update_state & UPSTATE_OPENED1)
				if(update_state & (UPSTATE_MAINT|UPSTATE_BROKE))
					icon_state = "apcmaint" //disabled APC cannot hold cell
				else
					icon_state = basestate
			else if(update_state & UPSTATE_OPENED2)
				if (update_state & UPSTATE_BROKE || malfhack)
					icon_state = "[basestate]-b-nocover"
				else
					icon_state = "[basestate]-nocover"
		else if(update_state & UPSTATE_BROKE)
			icon_state = "apc-b"
		else if(update_state & UPSTATE_BLUESCREEN)
			icon_state = "apcemag"
		else if(update_state & UPSTATE_WIREEXP)
			icon_state = "apcewires"
		else if(update_state & UPSTATE_MAINT)
			icon_state = "apc0"

	if(!(update_state & UPSTATE_ALLGOOD))
		SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)

	if(update & 2)
		SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)
		if(!(machine_stat & (BROKEN|MAINT)) && update_state & UPSTATE_ALLGOOD)
			SSvis_overlays.add_vis_overlay(src, icon, "apcox-[locked]", layer, plane, dir)
			SSvis_overlays.add_vis_overlay(src, icon, "apcox-[locked]", layer, EMISSIVE_PLANE, dir)
			SSvis_overlays.add_vis_overlay(src, icon, "apco3-[charging]", layer, plane, dir)
			SSvis_overlays.add_vis_overlay(src, icon, "apco3-[charging]", layer, EMISSIVE_PLANE, dir)
			if(operating)
				SSvis_overlays.add_vis_overlay(src, icon, "apco0-[equipment]", layer, plane, dir)
				SSvis_overlays.add_vis_overlay(src, icon, "apco0-[equipment]", layer, EMISSIVE_PLANE, dir)
				SSvis_overlays.add_vis_overlay(src, icon, "apco1-[lighting]", layer, plane, dir)
				SSvis_overlays.add_vis_overlay(src, icon, "apco1-[lighting]", layer, EMISSIVE_PLANE, dir)
				SSvis_overlays.add_vis_overlay(src, icon, "apco2-[environ]", layer, plane, dir)
				SSvis_overlays.add_vis_overlay(src, icon, "apco2-[environ]", layer, EMISSIVE_PLANE, dir)

	// And now, separately for cleanness, the lighting changing
	if(update_state & UPSTATE_ALLGOOD)
		switch(charging)
			if(APC_NOT_CHARGING)
				light_color = LIGHT_COLOR_RED
			if(APC_CHARGING)
				light_color = LIGHT_COLOR_BLUE
			if(APC_FULLY_CHARGED)
				light_color = LIGHT_COLOR_GREEN
		set_light(lon_range)
	else if(update_state & UPSTATE_BLUESCREEN)
		light_color = LIGHT_COLOR_BLUE
		set_light(lon_range)
	else
		set_light(0)

	icon_update_needed = FALSE

/obj/machinery/power/apc/proc/check_updates()
	var/last_update_state = update_state
	var/last_update_overlay = update_overlay
	update_state = 0
	update_overlay = 0

	if(cell)
		update_state |= UPSTATE_CELL_IN
	if(machine_stat & BROKEN)
		update_state |= UPSTATE_BROKE
	if(machine_stat & MAINT)
		update_state |= UPSTATE_MAINT
	if(opened)
		if(opened==APC_COVER_OPENED)
			update_state |= UPSTATE_OPENED1
		if(opened==APC_COVER_REMOVED)
			update_state |= UPSTATE_OPENED2
	else if((obj_flags & EMAGGED) || malfai)
		update_state |= UPSTATE_BLUESCREEN
	else if(panel_open)
		update_state |= UPSTATE_WIREEXP
	if(update_state <= 1)
		update_state |= UPSTATE_ALLGOOD

	if(operating)
		update_overlay |= APC_UPOVERLAY_OPERATING

	if(update_state & UPSTATE_ALLGOOD)
		if(locked)
			update_overlay |= APC_UPOVERLAY_LOCKED

		if(!charging)
			update_overlay |= APC_UPOVERLAY_CHARGEING0
		else if(charging == APC_CHARGING)
			update_overlay |= APC_UPOVERLAY_CHARGEING1
		else if(charging == APC_FULLY_CHARGED)
			update_overlay |= APC_UPOVERLAY_CHARGEING2

		if (!equipment)
			update_overlay |= APC_UPOVERLAY_EQUIPMENT0
		else if(equipment == 1)
			update_overlay |= APC_UPOVERLAY_EQUIPMENT1
		else if(equipment == 2)
			update_overlay |= APC_UPOVERLAY_EQUIPMENT2

		if(!lighting)
			update_overlay |= APC_UPOVERLAY_LIGHTING0
		else if(lighting == 1)
			update_overlay |= APC_UPOVERLAY_LIGHTING1
		else if(lighting == 2)
			update_overlay |= APC_UPOVERLAY_LIGHTING2

		if(!environ)
			update_overlay |= APC_UPOVERLAY_ENVIRON0
		else if(environ==1)
			update_overlay |= APC_UPOVERLAY_ENVIRON1
		else if(environ==2)
			update_overlay |= APC_UPOVERLAY_ENVIRON2


	var/results = 0
	if(last_update_state == update_state && last_update_overlay == update_overlay)
		return 0
	if(last_update_state != update_state)
		results += 1
	if(last_update_overlay != update_overlay)
		results += 2
	return results

// Used in process so it doesn't update the icon too much
/obj/machinery/power/apc/proc/queue_icon_update()
	icon_update_needed = TRUE
