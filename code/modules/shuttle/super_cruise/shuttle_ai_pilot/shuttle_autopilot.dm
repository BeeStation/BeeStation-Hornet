/datum/shuttle_ai_pilot/autopilot
	var/activated = FALSE
	/// Target orbital body of the autopilot.
	var/datum/orbital_object/shuttleTarget
	/// The target dock of the autopilot. If set to null, the shuttle will not automatically enter a port.
	var/targetPortId

/datum/shuttle_ai_pilot/autopilot/New(datum/orbital_object/_shuttleTarget, _targetPortId)
	. = ..()
	shuttleTarget = _shuttleTarget
	targetPortId = _targetPortId

///Called every shuttle tick, handles the action of the shuttle
/datum/shuttle_ai_pilot/autopilot/handle_ai_action(datum/orbital_object/shuttle/shuttle)
	if(!activated)
		return
	//Drive to the target location
	if(!shuttle.shuttleTargetPos)
		shuttle.shuttleTargetPos = new(shuttleTarget.position.x, shuttleTarget.position.y)
	else
		shuttle.shuttleTargetPos.x = shuttleTarget.position.x
		shuttle.shuttleTargetPos.y = shuttleTarget.position.y
	//Dock with the target location
	if(shuttle.can_dock_with == shuttleTarget)
		shuttle.commence_docking(shuttleTarget, TRUE)
	//Enter the target port

/datum/shuttle_ai_pilot/autopilot/proc/target_deleted(datum/source, force)
	shuttleTarget = null
	qdel(src)

/datum/shuttle_ai_pilot/autopilot/get_target_name()
	return shuttleTarget.name

/datum/shuttle_ai_pilot/autopilot/try_toggle()
	activated = !activated
	return TRUE

/datum/shuttle_ai_pilot/autopilot/is_active()
	return activated

/datum/shuttle_ai_pilot/autopilot/request
	activated = TRUE

/datum/shuttle_ai_pilot/autopilot/request/try_toggle()
	return FALSE
