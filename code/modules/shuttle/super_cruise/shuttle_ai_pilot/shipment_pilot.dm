/datum/shuttle_ai_pilot/shipment
	/// Target orbital body of the autopilot.
	var/datum/orbital_object/shuttleTarget

/datum/shuttle_ai_pilot/shipment/New(datum/orbital_object/_shuttleTarget)
	. = ..()
	shuttleTarget = _shuttleTarget

///Called every shuttle tick, handles the action of the shuttle
/datum/shuttle_ai_pilot/shipment/handle_ai_action(datum/orbital_object/shuttle/shuttle)
	//Check if there are hostiles nearby, if so fly away and request backup
	//Drive to the target location
	if(!shuttle.shuttleTargetPos)
		shuttle.shuttleTargetPos = new(shuttleTarget.position.x, shuttleTarget.position.y)
	else
		shuttle.shuttleTargetPos.x = shuttleTarget.position.x
		shuttle.shuttleTargetPos.y = shuttleTarget.position.y

/datum/shuttle_ai_pilot/shipment/proc/target_deleted(datum/source, force)
	shuttleTarget = null
	qdel(src)

/datum/shuttle_ai_pilot/shipment/get_target_name()
	return shuttleTarget.name

/datum/shuttle_ai_pilot/shipment/try_toggle()
	return FALSE

/datum/shuttle_ai_pilot/shipment/is_active()
	return TRUE
