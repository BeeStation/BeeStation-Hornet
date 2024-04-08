/datum/circuit_datatype/entity
	datatype = PORT_TYPE_ATOM
	color = "purple"
	datatype_flags = DATATYPE_FLAG_ALLOW_MANUAL_INPUT

/datum/circuit_datatype/entity/convert_value(datum/port/port, value_to_convert)
	var/atom/object = value_to_convert
	if(QDELETED(object))
		return null
	return object
