/atom/movable/screen/dock_allocation
	var/obj/docking_port/mobile/M
	var/animated = FALSE
	var/visible = FALSE
	alpha = 0

/atom/movable/screen/dock_allocation/Initialize(mapload, mob/parent)
	. = ..()
	RegisterSignal(parent, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(owner_shuttle_moved))
	owner_shuttle_moved(parent)

/atom/movable/screen/dock_allocation/Destroy()
	STOP_PROCESSING(SSorbits, src)
	M = null
	. = ..()

/atom/movable/screen/dock_allocation/process(delta_time)
	if (QDELETED(M))
		M = null
		if (visible)
			animate(src, 50, alpha=0)
			visible = FALSE
		return PROCESS_KILL
	var/datum/dock_allocation_tracker/da = SSorbits.get_allocation(M.id)
	if (!da)
		if (visible)
			animate(src, 50, alpha=0)
			visible = FALSE
		return
	if (!visible)
		animate(src, 50, alpha=255)
		visible = TRUE
	maptext = "<span class='maptext center big'>Dock Allocation Time - [time2text(da.time_left, "mm:ss")]</span>"
	if (da.time_left <= 2 MINUTES)
		maptext += "<span class='maptext center'>Your ship will be deleted if you fail to leave the dock.</span>"
		if (!animated)
			animated = TRUE
			animate(src, color="red", time=5, loop=INFINITY, easing=SINE_EASING)
			animate(color="white", time=5, loop=INFINITY, easing=SINE_EASING)
	else if (animated)
		animated = FALSE
		animate(src, 1, color="white")

/atom/movable/screen/dock_allocation/proc/owner_shuttle_moved(mob/parent)
	SIGNAL_HANDLER
	var/turf/location = get_turf(parent)
	var/area/shuttle/shuttle_area = location.loc
	if (istype(shuttle_area) && shuttle_area.mobile_port)
		M = shuttle_area.mobile_port
		START_PROCESSING(SSorbits, src)
