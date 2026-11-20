/obj/machinery/nanite_program_hub
	name = "nanite program hub"
	desc = "Compiles nanite programs from the techweb servers and downloads them into disks."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "nanite_program_hub"
	use_power = IDLE_POWER_USE
	anchored = TRUE
	density = TRUE
	circuit = /obj/item/circuitboard/machine/nanite_program_hub

	var/obj/item/disk/nanite_program/disk
	var/datum/techweb/linked_techweb
	var/detail_view = TRUE

/obj/machinery/nanite_program_hub/LateInitialize()
	. = ..()
	if(!linked_techweb)
		CONNECT_TO_RND_SERVER_ROUNDSTART(linked_techweb, src)

/obj/machinery/nanite_program_hub/attackby(obj/item/I, mob/user)
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		update_icon()
		return
	if(default_deconstruction_crowbar(I))
		return
	if(istype(I, /obj/item/disk/nanite_program))
		var/obj/item/disk/nanite_program/N = I
		if(user.transferItemToLoc(N, src))
			to_chat(user, span_notice("You insert [N] into [src]."))
			playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
			if(disk)
				eject(user)
			disk = N
			ui_update()
	else
		..()

/obj/machinery/nanite_program_hub/proc/eject(mob/living/user)
	if(!disk)
		return
	if(!istype(user) || !Adjacent(user) || !user.put_in_active_hand(disk))
		disk.forceMove(drop_location())
	disk = null
	ui_update()

/obj/machinery/nanite_program_hub/AltClick(mob/user)
	if(disk && user.canUseTopic(src, !issilicon(user)))
		to_chat(user, span_notice("You take out [disk] from [src]."))
		eject(user)
	return


/obj/machinery/nanite_program_hub/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/nanite_program_hub/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NaniteProgramHub")
		ui.open()

/obj/machinery/nanite_program_hub/ui_data()
	var/list/data = list()
	if(disk)
		data["has_disk"] = TRUE
		var/list/disk_data = list()
		var/datum/nanite_program/P = disk.program
		if(P)
			data["has_program"] = TRUE
			disk_data["name"] = P.name
			disk_data["desc"] = P.desc
		else
			data["has_program"] = FALSE

		data["disk"] = disk_data
	else
		data["has_disk"] = FALSE
		data["has_program"] = FALSE

	data["detail_view"] = detail_view

	return data

/obj/machinery/nanite_program_hub/ui_static_data(mob/user)
	var/list/data = list()
	data["programs"] = list()
	for(var/design_path in linked_techweb.researched_designs)
		if(!ispath(design_path, /datum/design/nanites))
			continue
		var/datum/design/nanites/design = SSresearch.techweb_designs[design_path]
		var/cat_name = design.category[1] //just put them in the first category fuck it
		data["programs"][cat_name] ||= list()
		data["programs"][cat_name] += list(list(
			"path" = design.type,
			"name" = design.name,
			"desc" = design.desc,
		))

	return data

/obj/machinery/nanite_program_hub/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("eject")
			eject(usr)
			return TRUE
		if("download")
			if(!disk)
				return FALSE

			var/design_path = text2path(params["program_id"])
			//check if it's a valid design
			if(!ispath(design_path, /datum/design/nanites))
				return FALSE
			var/datum/design/nanites/downloaded = SSresearch.techweb_designs[design_path]

			if(disk.program)
				qdel(disk.program)
			disk.program = new downloaded.program_type
			disk.name = "[initial(disk.name)] \[[disk.program.name]\]"
			playsound(src, 'sound/machines/terminal_prompt.ogg', 25, FALSE)
			return TRUE
		if("refresh")
			update_static_data(usr, bypass_cooldown = FALSE)
			return TRUE
		if("toggle_details")
			detail_view = !detail_view
			return TRUE
		if("clear")
			if(!disk?.program)
				return FALSE
			QDEL_NULL(disk.program)
			disk.name = initial(disk.name)
			return TRUE
