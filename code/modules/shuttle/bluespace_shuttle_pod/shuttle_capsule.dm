/obj/item/survivalcapsule/shuttle
	name = "bluespace shuttle capsule"
	desc = "An entire shuttle stored within a pocket of bluespace."
	var/datum/map_template/shuttle/shuttle_template
	//Static
	//Subtypes that change this will have to redefine these.
	var/static/list/blacklisted_turfs
	var/static/list/whitelisted_turfs
	var/static/list/whitelisted_areas

/obj/item/survivalcapsule/shuttle/Initialize()
	. = ..()
	if(!blacklisted_turfs)
		whitelisted_areas = typecacheof(list(
			/area/space,
			/area/lavaland
		))
		whitelisted_turfs = typecacheof(list(
			/turf/open/space,
			/turf/open/floor/plating/asteroid/basalt/lava_land_surface
		))
		blacklisted_turfs = typecacheof(list(
			/turf/open/space/bluespace,
			/turf/open/space/transit
		))

/obj/item/survivalcapsule/shuttle/get_template()
	if(shuttle_template)
		return
	shuttle_template = SSmapping.shuttle_templates[template_id]
	if(!shuttle_template)
		WARNING("Shuttle template ([template_id]) not found!")
		qdel(src)

/obj/item/survivalcapsule/shuttle/Destroy()
	shuttle_template = null
	. = ..()

/obj/item/survivalcapsule/shuttle/examine(mob/user)
	. = ..()
	get_template()
	. += "This capsule has the [shuttle_template.name] stored."
	. += shuttle_template.description

/obj/item/survivalcapsule/shuttle/attack_self()
	//Can't grab when capsule is New() because templates aren't loaded then
	get_template()
	if(!used)
		loc.visible_message("<span class='warning'>\The [src] begins to shake. Stand back!</span>")
		used = TRUE
		sleep(50)
		var/turf/deploy_location = get_turf(src)
		var/status = check_deploy(deploy_location)
		switch(status)
			if(SHELTER_DEPLOY_BAD_AREA)
				src.loc.visible_message("<span class='warning'>\The [src] will not function in this area.</span>")
			if(SHELTER_DEPLOY_BAD_TURFS, SHELTER_DEPLOY_ANCHORED_OBJECTS)
				var/width = shuttle_template.width
				var/height = shuttle_template.height
				src.loc.visible_message("<span class='warning'>\The [src] doesn't have room to deploy! You need to clear a [width]x[height] area!</span>")

		if(status != SHELTER_DEPLOY_ALLOWED)
			used = FALSE
			return

		playsound(src, 'sound/effects/phasein.ogg', 100, 1)

		var/turf/T = deploy_location
		if(!is_mining_level(T.z)) //only report capsules away from the mining/lavaland level
			message_admins("[ADMIN_LOOKUPFLW(usr)] activated a bluespace capsule away from the mining level! [ADMIN_VERBOSEJMP(T)]")
			log_admin("[key_name(usr)] activated a bluespace capsule away from the mining level at [AREACOORD(T)]")
		shuttle_template.load(deploy_location, centered = TRUE)
		new /obj/effect/particle_effect/smoke(get_turf(src))
		qdel(src)

/obj/item/survivalcapsule/shuttle/proc/check_deploy(turf/deploy_location)
	var/affected = shuttle_template.get_affected_turfs(deploy_location, centered=TRUE)
	for(var/turf/T in affected)
		var/area/A = get_area(T)
		if(!is_type_in_typecache(A, whitelisted_areas))
			return SHELTER_DEPLOY_BAD_AREA

		var/banned = is_type_in_typecache(T, blacklisted_turfs)
		var/permitted = is_type_in_typecache(T, whitelisted_turfs)
		if(banned && !permitted)
			return SHELTER_DEPLOY_BAD_TURFS

		for(var/obj/O in T)
			if((O.density && O.anchored))
				return SHELTER_DEPLOY_ANCHORED_OBJECTS
	return SHELTER_DEPLOY_ALLOWED
