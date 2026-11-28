/datum/spawners_menu/ui_state(mob/user)
	return GLOB.observer_state

/datum/spawners_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SpawnersMenu")
		ui.open()

/datum/spawners_menu/ui_data(mob/user)
	var/list/data = list()
	data["spawners"] = list()
	for(var/spawner in GLOB.mob_spawners)
		var/list/this = list()
		this["name"] = spawner
		this["short_desc"] = ""
		this["flavor_text"] = ""
		this["important_warning"] = ""
		this["refs"] = list()
		var/amount_left = 0
		for(var/datum/spawner_obj in GLOB.mob_spawners[spawner])
			if(QDELETED(spawner_obj))
				continue
			amount_left++
			this["refs"] += "[REF(spawner_obj)]"
			if(!this["desc"])
				if(istype(spawner_obj, /obj/effect/mob_spawn))
					var/obj/effect/mob_spawn/MS = spawner_obj
					this["short_desc"] = MS.short_desc
					this["flavor_text"] = MS.flavour_text
					this["important_info"] = MS.important_info
				else if(istype(spawner_obj, /datum/candidate_poll))
					var/datum/candidate_poll/poll = spawner_obj
					this["desc"] = "Sign up to be a [poll.config.role_name_text]."
					this["short_desc"] = "Sign up to be a [poll.config.role_name_text]."
				else
					var/atom/movable/O = spawner_obj
					if(isslime(O))
						this["short_desc"] = O.get_spawner_desc()
						this["flavor_text"] = O.get_spawner_flavour_text()
					else
						this["desc"] = O.desc

		if(!amount_left)
			continue
		this["amount_left"] = amount_left
		data["spawners"] += list(this)

	return data

/datum/spawners_menu/ui_state(mob/user)
	return GLOB.observer_state

/datum/spawners_menu/ui_act(action, params)
	if(..())
		return

	var/group_name = params["name"]
	if(!group_name || !(group_name in GLOB.mob_spawners))
		return
	var/list/spawnerlist = GLOB.mob_spawners[group_name]
	if(!LAZYLEN(spawnerlist))
		return
	var/datum/spawner = pick(spawnerlist)
	if(istype(spawner, /datum/candidate_poll))
		if(action == "spawn")
			var/datum/candidate_poll/poll = spawner
			poll.sign_up(usr, FALSE, skip_confirmation = TRUE)
			return TRUE
		return

	var/atom/movable/mob_spawner = spawner
	if(!istype(mob_spawner) || !SSpoints_of_interest.is_valid_poi(mob_spawner))
		return

	switch(action)
		if("jump")
			usr.forceMove(get_turf(mob_spawner))
			return TRUE
		if("spawn")
			mob_spawner.attack_ghost(usr)
			return TRUE
