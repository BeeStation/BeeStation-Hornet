//Dead mobs can exist whenever. This is needful

INITIALIZE_IMMEDIATE(/mob/dead)

/mob/dead
	sight = SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
	move_resist = INFINITY
	throwforce = 0

/mob/dead/Initialize(mapload)
	SHOULD_CALL_PARENT(FALSE)
	if(flags_1 & INITIALIZED_1)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	flags_1 |= INITIALIZED_1
	tag = "mob_[next_mob_id++]"
	add_to_mob_list()

	prepare_huds()

	if(length(CONFIG_GET(keyed_list/server_hop)))
		add_verb(/mob/dead/proc/server_hop)
	set_focus(src)
	become_hearing_sensitive()
	return INITIALIZE_HINT_NORMAL

/mob/dead/canUseStorage()
	return FALSE

/mob/dead/get_stat_tab_status()
	var/list/tab_data = ..()

	if(SSticker.HasRoundStarted())
		return tab_data

	var/time_remaining = SSticker.GetTimeLeft()
	if(time_remaining > 0)
		tab_data["Time To Start"] = GENERATE_STAT_TEXT("[round(time_remaining/10)]s")
	else if(time_remaining == -10)
		tab_data["Time To Start"] = GENERATE_STAT_TEXT("DELAYED")
	else
		tab_data["Time To Start"] = GENERATE_STAT_TEXT("SOON")

	return tab_data

/mob/dead/proc/server_hop()
	set category = "OOC"
	set name = "Server Hop"
	set desc= "Jump to the other server"
	if(notransform)
		return
	var/list/csa = CONFIG_GET(keyed_list/server_hop)
	var/pick
	switch(csa.len)
		if(0)
			remove_verb(/mob/dead/proc/server_hop)
			to_chat(src, span_notice("Server Hop has been disabled."))
		if(1)
			pick = csa[1]
		else
			pick = tgui_input_list(src, "Pick a server to jump to", "Server Hop", csa)

	if(!pick)
		return

	var/addr = csa[pick]

	if(tgui_alert(src, "Jump to server [pick] ([addr])?", "Server Hop", list("Yes", "No")) != "Yes")
		return

	var/client/C = client
	to_chat(C, span_notice("Sending you to [pick]."))
	new /atom/movable/screen/splash(null, C)

	notransform = TRUE
	sleep(29)	//let the animation play
	notransform = FALSE

	if(!C)
		return

	winset(src, null, "command=.options") //other wise the user never knows if byond is downloading resources

	C << link("[addr]")

/**
 * updates the Z level for dead players
 * If they don't have a new z, we'll keep the old one, preventing bugs from ghosting and re-entering, among others
 */
/mob/dead/proc/update_z(new_z)
	if(registered_z == new_z)
		return
	if(registered_z)
		SSmobs.dead_players_by_zlevel[registered_z] -= src
	if(isnull(client))
		registered_z = null
		return
	registered_z = new_z
	SSmobs.dead_players_by_zlevel[new_z] += src

/mob/dead/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	var/turf/T = get_turf(src)
	if (isturf(T))
		update_z(T.z)
	// Update SSD indicator for ghost's body
	if(isliving(mind?.current))
		mind.current.med_hud_set_status()

/mob/dead/auto_deadmin_on_login()
	return

/mob/dead/Logout()
	update_z(null)
	return ..()

/mob/dead/onTransitZ(old_z,new_z)
	..()
	update_z(new_z)

// Ghosts cannot fall
/mob/dead/has_gravity(turf/T)
	return FALSE
