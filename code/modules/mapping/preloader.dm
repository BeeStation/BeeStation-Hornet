// global datum that will preload variables on atoms instanciation
GLOBAL_VAR_INIT(use_preloader, FALSE)
GLOBAL_LIST_INIT(_preloader_attributes, null)
GLOBAL_LIST_INIT(_preloader_path, null)

/// Preloader datum
/datum/map_preloader
	parent_type = /datum
	var/list/attributes
	var/target_path

/world/proc/preloader_setup(list/the_attributes, path)
	if(the_attributes.len)
		GLOB.use_preloader = TRUE
		GLOB._preloader_attributes = the_attributes
		GLOB._preloader_path = path

/world/proc/preloader_load(atom/what)
	GLOB.use_preloader = FALSE
	var/list/attributes = GLOB._preloader_attributes
	for(var/attribute in attributes)
		var/value = attributes[attribute]
		if(islist(value))
			value = deep_copy_list(value)
		#ifdef TESTING
		if(what.vars[attribute] == value)
			var/message = "<font color=green>[what.type]</font> at [AREACOORD(what)] - <b>VAR:</b> <font color=red>[attribute] = [isnull(value) ? "null" : (isnum_safe(value) ? value : "\"[value]\"")]</font>"
			log_mapping("DIRTY VAR: [message]")
			GLOB.dirty_vars += message
		#endif
		what.vars[attribute] = value

/area/template_noop
	name = "Area Passthrough"

/turf/template_noop
	name = "Turf Passthrough"
	icon_state = "noop"
	bullet_bounce_sound = null

//The following two turfs can be used to hint if any genturfs below should be generated as closed or open
/turf/template_noop/closed
	name = "Area Passthrough (prefer closed)"
	icon_state = "noop_closed"

/turf/template_noop/open
	name = "Area Passthrough (prefer open)"
	icon_state = "noop_open"
