/// Datum that represents one "group" of plane masters
/// So all the main window planes would be in one, all the camera window planes in another
/// Etc
/datum/plane_master_group
	/// Our key in the group list on /datum/hud
	/// Should be unique for any group of plane masters in the world
	var/key
	/// Our parent hud
	var/datum/hud/our_hud
	/// List in the form "[plane]" = object, the plane masters we own
	var/list/atom/movable/screen/plane_master/plane_masters = list()
	/// What, if any, submap we render onto
	var/map = ""
	var/list/atom/movable/screen/plane_master/zmimic_shadow/zmimic_shadow_planes = list()

/datum/plane_master_group/New(key, map = "")
	. = ..()
	src.key = key
	src.map = map
	build_plane_masters()

/datum/plane_master_group/Destroy()
	set_hud(null)
	zmimic_shadow_planes.Cut()
	QDEL_LIST_ASSOC_VAL(plane_masters)
	return ..()

/// Hooks ourselves into the passed in hud, and shows our planes to its mob
/// Returns TRUE if meaningful, FALSE otherwise
/datum/plane_master_group/proc/set_hud(datum/hud/new_hud)
	if(new_hud == our_hud)
		return FALSE
	if(our_hud)
		hide_hud()
		our_hud.master_groups -= key
	our_hud = new_hud
	if(new_hud)
		if(new_hud.master_groups[key])
			stack_trace("Plane master group key [key] is already in use on the hud of [new_hud.mymob]")
		new_hud.master_groups[key] = src
		show_hud()
	return TRUE

/datum/plane_master_group/proc/show_hud()
	for(var/thing in plane_masters)
		var/atom/movable/screen/plane_master/plane = plane_masters[thing]
		plane.show_to(our_hud.mymob)

/datum/plane_master_group/proc/hide_hud()
	for(var/thing in plane_masters)
		var/atom/movable/screen/plane_master/plane = plane_masters[thing]
		plane.hide_from(our_hud.mymob)

/// Hides our planes from a client that may no longer be controlling our hud's mob
/datum/plane_master_group/proc/hide_from_client(client/viewer)
	for(var/thing in plane_masters)
		var/atom/movable/screen/plane_master/plane = plane_masters[thing]
		plane.hide_from_client(viewer)

/// Nice wrapper for the "[]"ing
/datum/plane_master_group/proc/get_plane(plane)
	return plane_masters["[plane]"]

/// Returns a list of all the plane master types we want to create
/datum/plane_master_group/proc/get_plane_types()
	return subtypesof(/atom/movable/screen/plane_master) - /atom/movable/screen/plane_master/rendering_plate

/datum/plane_master_group/proc/build_plane_masters()
	for(var/plane_type in get_plane_types() - list(/atom/movable/screen/plane_master/zmimic, /atom/movable/screen/plane_master/zmimic_shadow))
		var/atom/movable/screen/plane_master/instance = new plane_type(null, null, src)
		plane_masters["[instance.plane]"] = instance
	// One z-mimic plane per depth, each with a shadow plane
	for(var/plane in ZMIMIC_MAX_PLANE to ZMIMIC_MAX_PLANE - ZMIMIC_MAX_DEPTH step -1)
		var/atom/movable/screen/plane_master/instance = new /atom/movable/screen/plane_master/zmimic(null, null, src, plane)
		plane_masters["[instance.plane]"] = instance
		instance = new /atom/movable/screen/plane_master/zmimic_shadow(null, null, src, ZMIMIC_SHADOW_PLANE(plane))
		plane_masters["[instance.plane]"] = instance
		zmimic_shadow_planes += instance

/// Holds the main plane masters
/datum/plane_master_group/main

/// Holds plane masters for popups, like camera windows
/// Note: We do not scale this plane, even though we could
/// This is because it's annoying to get turfs to position inside it correctly
/// If you wanna try someday feel free, but I can't manage it
/datum/plane_master_group/popup

/datum/plane_master_group/popup/get_plane_types()
	return ..() - /atom/movable/screen/plane_master/blackness
