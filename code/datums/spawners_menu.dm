/datum/spawners_menu/ui_state(mob/user)
	return GLOB.observer_state

/datum/spawners_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SpawnersMenu")
		ui.open()

/datum/spawners_menu/ui_static_data(mob/user)
	var/list/data = list()
	data["spawners"] = list()
	for(var/spawner in GLOB.mob_spawners)
		var/list/this = list()
		this["name"] = spawner
		this["you_are_text"] = ""
		this["flavor_text"] = ""
		this["important_warning"] = ""
		this["amount_left"] = 0
		for(var/spawner_obj in GLOB.mob_spawners[spawner])
			if(!this["desc"])
				if(istype(spawner_obj, /obj/effect/mob_spawn))
					var/obj/effect/mob_spawn/ghost_role/mob_spawner = spawner_obj
					if(!mob_spawner.allow_spawn(user, silent = TRUE))
						continue
					this["you_are_text"] = mob_spawner.you_are_text
					this["flavor_text"] = mob_spawner.flavour_text
					this["important_text"] = mob_spawner.important_text
				else if(istype(spawner_obj, /datum/candidate_poll))
					var/datum/candidate_poll/poll = spawner_obj
					this["desc"] = "Sign up to be a [poll.config.role_name_text]."
					this["you_are_text"] = "Sign up to be a [poll.config.role_name_text]."
				else
					var/atom/movable/O = spawner_obj //bruh "O" aint a fuckin object what you doin
					if(isslime(O))
						this["you_are_text"] = O.get_spawner_desc()
						this["flavor_text"] = O.get_spawner_flavour_text()
					else
						this["desc"] = O.desc

			this["amount_left"] += 1
		if(this["amount_left"] > 0)
			data["spawners"] += list(this)
	return data

/datum/spawners_menu/ui_state(mob/user)
	return GLOB.observer_state

/datum/spawners_menu/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	var/mob/dead/observer/owner = usr

	var/group_name = params["name"]
	if(!group_name || !(group_name in GLOB.mob_spawners))
		return
	var/list/spawnerlist = GLOB.mob_spawners[group_name]
	for(var/obj/effect/mob_spawn/ghost_role/current_spawner as anything in spawnerlist)
		if(!current_spawner.allow_spawn(usr, silent = TRUE))
			spawnerlist -= current_spawner

	if(!LAZYLEN(spawnerlist))
		return
	var/atom/mob_spawner = pick(spawnerlist)
	if(!(mob_spawner in GLOB.poi_list))
		if (istype(mob_spawner, /datum/candidate_poll) && action == "spawn")
			var/datum/candidate_poll/poll = mob_spawner
			poll.sign_up(usr, FALSE, skip_confirmation = TRUE)
			return TRUE
		return

	switch(action)
		if("jump")
			if(mob_spawner)
				if (isdatum(mob_spawner))
					return
				owner.forceMove(get_turf(mob_spawner))
				return TRUE
		if("spawn")
			if(mob_spawner)
				owner.check_orbitable(mob_spawner)
				ui.close()
				mob_spawner.attack_ghost(owner)
				return TRUE
