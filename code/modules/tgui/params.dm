/datum/params
	VAR_PRIVATE/_unsafe_params

/datum/params/New(unsafe_params)
	. = ..()
	_unsafe_params = unsafe_params

/datum/params/Destroy(force, ...)
	_unsafe_params = null
	. = ..()

/datum/params/can_vv_get(var_name)
	// You can't look at this variable as it contains potentially unsafe to render things
	// which may be poorly handled by VV or rendered in chat if someone attempts to edit it.
	// It's safer if we just leave this alone.
	if (var_name == "_unsafe_params")
		return FALSE
	return ..()

// =============================
// Boolean Handling
// =============================

/// Returns true if the requested parameter is equal to the value
/// Returns false otherwise
/datum/params/proc/is_param_equal_to(param, value)
	return _unsafe_params[param] == value

/// Returns the requested parameter as either a true or false value depending
/// on the truthyness of the parameter.
/datum/params/proc/get_boolean(param)
	return !!_unsafe_params[param]

// =============================
// Text Handling
// =============================

/// Returns the requested parameter as fully sanitised text, removing \n and \t as well as encoding HTML.
/datum/params/proc/get_sanitised_text(param)
	return sanitize(_unsafe_params[param])

/// Returns the requested parameter as HTML encoded text.
/datum/params/proc/get_encoded_text(param)
	return html_encode(_unsafe_params[param])

/// Returns the requested parameter as an unsanitised message holder which
/// can be used to pass messages back into TGUI without encoding and then
/// decoding the message to protect it while it is within byond-space.
/datum/params/proc/get_unsanitised_message_container(param)
	RETURN_TYPE(/datum/unsafe_message)
	var/unsafe_message = _unsafe_params[param]
	if (isnull(unsafe_message))
		return null
	return new /datum/unsafe_message(unsafe_message)

// =============================
// Numeric Handling
// =============================

/// Returns the requested parameter as a number
/datum/params/proc/get_num(param, min = -INFINITY, max = INFINITY)
	var/num = text2num(_unsafe_params[param])
	if (num == null)
		return null
	if (num < min)
		return min
	if (num > max)
		return max
	return num

/// Returns the requested parameter as an integer
/datum/params/proc/get_int(param, min = -INFINITY, max = INFINITY)
	var/num = round(text2num(_unsafe_params[param]))
	if (num == null)
		return null
	if (num < min)
		return min
	if (num > max)
		return max
	return num

// =============================
// Path Handling
// =============================

/// Returns the requested parameter as a path, so long as that
/// path is a subpath of the root_type.
/datum/params/proc/get_subtype_path(param, root_type)
	var/selected_path = text2path(_unsafe_params[param])
	if (!ispath(selected_path, root_type))
		return null
	return selected_path

// =============================
// List Handling
// =============================

/// Locates the parameter by byond reference.
/// References are generates using the \ref tag in text and can be
/// used to lookup specific entities within lists.
/datum/params/proc/locate_param(param, list/source_list)
	return locate(_unsafe_params[param]) in source_list

/// Returns the requested parameter as text.
/// If the text is not present inside of source_list, then null is returned instead.
/datum/params/proc/get_text_in_list(param, list/source_list)
	var/requested = _unsafe_params[param]
	// Check to see if the list contains the href we asked for
	if (requested in source_list)
		return requested
	// The href asked for was not present inside of the list
	return null

// =============================
// Dictionary Handling
// =============================

/// Uses the parameter as a key lookup for a dictionary and returns
/// the value from that dictionary, if it exists.
/// May return null
/datum/params/proc/get_from_lookup(param, list/dictionary)
	var/key = _unsafe_params[param]
	if (!key)
		return null
	return dictionary[key]

/// Returns the requested parameter as a parameter list protected by /datum/params
/// May return null
/datum/params/proc/get_param_dict(param)
	var/list/sub_params = _unsafe_params[param]
	if (!islist(sub_params))
		return null
	return new /datum/params(sub_params)
