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
/datum/params/proc/are_equal(param, value)
	return _unsafe_params[param] == value

/// Checks if a param is inside a list, or is a key of a dictionary
/datum/params/proc/is_in_list(param, list/source)
	return _unsafe_params[param] in source

/// Returns the requested parameter as either a true or false value depending
/// on the truthyness of the parameter.
/datum/params/proc/get_truthy(param)
	return !!_unsafe_params[param]

/// Returns true if the requested parameter is equal to "1"
/datum/params/proc/as_boolean(param)
    return text2num(_unsafe_params[param]) == 1

// =============================
// Text Handling
// =============================

/// Returns the requested parameter as a ref
/datum/params/proc/get_ref(param)
	var/static/regex/ref_regex = new(@"^\[(.*)\]$")
	if (!ref_regex.Find(_unsafe_params[param]))
		return
	// Refs are either hex codes (0x010A...) or are url encoded tags [tag]
	return "\[[url_encode(ref_regex.group[1])]\]"

/// Returns the requested parameter as a name
/datum/params/proc/get_name(param)
	return reject_bad_name(_unsafe_params[param], TRUE, MAX_NAME_LEN, TRUE)

/// Returns the requested parameter as fully sanitised text, removing \n and \t as well as encoding HTML.
/// Use this when recieving text for the sake of checking it against UI components when it will not be displayed
/// to other players in any way.
/datum/params/proc/get_sanitised_text(param)
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

/// Returns the requested parameter as a ckey
/datum/params/proc/get_ckey(param)
    return ckey(_unsafe_params[param])

/// Gets a spoken message, with IC words such as 'admins' stripped away.
/// The filter may be applied liberally, so computer text speech should use get_message
/// Messages through this may only be single line messages.
/datum/params/proc/get_spoken_message(param, max_length = MAX_MESSAGE_LEN)
	var/message = trim(get_sanitised_text(param), max_length)
	if (!message)
		return null
	if (CHAT_FILTER_CHECK(message))
		if (usr)
			to_chat(usr, "<span class='warning'>Your message was rejected for containing words that violate our in-character speech policy.</span>")
		return null
	return message

/// Returns a message for UIs that are utilising non-IC things such as ghost/pAI descriptions.
/// Allows for multi-line text.
/datum/params/proc/get_message(param, max_length = MAX_MESSAGE_LEN)
	var/message = trim(html_encode(_unsafe_params[param]), max_length)
	if (!message)
		return null
	if (OOC_FILTER_CHECK(message))
		if (usr)
			to_chat(usr, "<span class='warning'>Your message was rejected for containing words that violate our server's allows content policy.</span>")
		return null
	return message


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

/// Removes the requested parameter from the list, or from a dictionary by key
/datum/params/proc/remove_from_list(param, list/source)
	source -= _unsafe_params[param]

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

// =============================
// Default Behaviour
// =============================

/// Default operator that shouldn't be used, but is included for compatability sake
/datum/params/proc/operator[](idx)
	// Log this, as it may break
	if (Debugger?.enabled)
		stack_trace("Attempting to access /datum/params by index. This should be updated to use an explicit call to one of the getter functions as the default behaviour may not be the intended behaviour.")
	// Use a relatively strong thing by default
	return get_message(idx)
