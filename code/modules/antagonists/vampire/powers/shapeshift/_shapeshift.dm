/datum/action/vampire/shapeshift
	power_flags = BP_AM_TOGGLE

	/// The shapeshift action linked to this power
	var/datum/action/spell/shapeshift/shapeshift_action

/datum/action/vampire/shapeshift/New()
	. = ..()
	if(shapeshift_action)
		shapeshift_action = new shapeshift_action.type(src)
		shapeshift_action.owner = owner

/datum/action/vampire/shapeshift/activate_power()
	. = ..()
	shapeshift_action.shapeshift_type = pick(shapeshift_action.possible_shapes)
	shapeshift_action?.on_cast(owner)

/datum/action/vampire/shapeshift/deactivate_power()
	. = ..()
	shapeshift_action?.on_cast(owner)
