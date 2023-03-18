#define CUSTOM_SHUTTLE_ACCELERATION_SCALE 10
#define CUSTOM_SHUTTLE_MIN_THRUST_TO_WEIGHT 1

/obj/machinery/computer/shuttle_flight/custom_shuttle
	name = "nanotrasen shuttle flight controller"
	desc = "A terminal used to fly shuttles defined by the Shuttle Zoning Designator"
	circuit = /obj/item/circuitboard/computer/shuttle/flight_control
	icon_screen = "shuttle"
	icon_keyboard = "tech_key"
	light_color = LIGHT_COLOR_CYAN
	req_access = list( )
	possible_destinations = "whiteship_home"

	var/datum/weakref/designator_ref = null

/obj/machinery/computer/shuttle_flight/custom_shuttle/ui_data(mob/user)
	var/list/data = ..()

	var/obj/item/shuttle_creator/designator = designator_ref?.resolve()

	data["designatorInserted"] = !!designator
	data["designatorId"] = designator?.linkedShuttleId
	data["shuttleId"] = shuttleId

	return data

/obj/machinery/computer/shuttle_flight/custom_shuttle/ui_act(action, params)
	. = ..()
	if(.)
		return

	var/obj/item/shuttle_creator/designator = designator_ref?.resolve()
	switch(action)
		if("updateLinkedId")
			var/newId = designator?.linkedShuttleId
			if(newId)
				linkShuttle(newId)
		if("updateDesignatorId")
			var/obj/docking_port/mobile/port = SSshuttle.getShuttle(shuttleId)
			if(!port)
				return
			if(!designator)
				return
			designator.linkedShuttleId = shuttleId
			designator.recorded_shuttle_area = port.shuttle_areas[1] //This should be a custom shuttle, so it should only have 1 area
			//Reset the designator's buffer
			designator.update_origin()
			designator.reset_saved_area(FALSE)
			designator.icon_state = "rsd_used"

/obj/machinery/computer/shuttle_flight/custom_shuttle/proc/linkShuttle(var/new_id)
	set_shuttle_id(new_id)
	shuttlePortId = "[shuttleId]_custom_dock"

/obj/machinery/computer/shuttle_flight/custom_shuttle/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override=FALSE)
	if(port && (shuttleId == initial(shuttleId) || override))
		linkShuttle(port.id)

/obj/machinery/computer/shuttle_flight/custom_shuttle/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(istype(I, /obj/item/shuttle_creator) && !designator_ref)
		if(!user.transferItemToLoc(I,src))
			return
		designator_ref = WEAKREF(I)
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)

/obj/machinery/computer/shuttle_flight/custom_shuttle/AltClick(mob/user)
	var/obj/item/shuttle_creator/designator = designator_ref?.resolve()
	if(!designator)
		return
	if(!istype(user) || !Adjacent(user) || !user.put_in_active_hand(designator))
		designator.forceMove(drop_location())
	designator_ref = null
