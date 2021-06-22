/datum/component/spybug
	var/obj/item/clothing/glasses/sunglasses/spy/linked_glasses
	var/atom/movable/screen/map_view/cam_screen
	var/list/cam_plane_masters
	// Ranges higher than one can be used to see through walls.
	var/cam_range = 1
	var/datum/movement_detector/tracker

/datum/component/spybug/Initialize()
	. = ..()
	tracker = new /datum/movement_detector(parent, CALLBACK(src, .proc/update_view))

	cam_screen = new
	cam_screen.name = "screen"
	cam_screen.assigned_map = "spypopup_map"
	cam_screen.del_on_map_removal = FALSE
	cam_screen.set_position(1, 1)

	// We need to add planesmasters to the popup, otherwise
	// blending fucks up massively. Any planesmaster on the main screen does
	// NOT apply to map popups. If there's ever a way to make planesmasters
	// omnipresent, then this wouldn't be needed.
	cam_plane_masters = list()
	for(var/plane in subtypesof(/atom/movable/screen/plane_master))
		var/atom/movable/screen/instance = new plane()
		instance.assigned_map = "spypopup_map"
		instance.del_on_map_removal = FALSE
		instance.screen_loc = "spypopup_map:CENTER"
		cam_plane_masters += instance

/datum/component/spybug/Destroy()
	if(linked_glasses)
		linked_glasses.linked_bug = null
	qdel(cam_screen)
	QDEL_LIST(cam_plane_masters)
	qdel(tracker)
	return ..()

/datum/component/spybug/proc/update_view()//this doesn't do anything too crazy, just updates the vis_contents of its screen obj
	cam_screen.vis_contents.Cut()
	for(var/turf/visible_turf in view(1,get_turf(parent)))//fuck you usr
		cam_screen.vis_contents += visible_turf