#define VV_HTML_ENCODE(thing) ( sanitize ? html_encode(thing) : thing )
/// Get displayed variable in VV variable list
/proc/debug_variable(name, value, level, datum/owner, sanitize = TRUE, display_flags = NONE) //if D is a list, name will be index, and value will be assoc value.
	// variables to store values
	var/index
	var/list/owner_list
	var/datum/vv_ghost/vv_spectre

	// checks if a thing is /list, or /vv_ghost to deliver a special list, and then reassign name/value
	if(owner)
		if(istype(owner, /datum/vv_ghost))
			vv_spectre = owner
		if(islist(owner) || vv_spectre)
			index = name
			owner_list = vv_spectre.special_ref || owner
			if (value)
				name = owner_list[name] //name is really the index until this line
			else
				value = owner_list[name]

	// Builds text for single letter actions
	if(CHECK_BITFIELD(display_flags, VV_READ_ONLY))
		. = "<li style='backgroundColor:white'>(READ ONLY) "
	else if(vv_spectre)
		. = "<li style='backgroundColor:white'>([VV_HREF_SPECIAL(vv_spectre.special_owner, VV_HK_LIST_EDIT, "E", index, vv_spectre.special_varname)]) ([VV_HREF_SPECIAL(vv_spectre.special_owner, VV_HK_LIST_CHANGE, "C", index, vv_spectre.special_varname)]) ([VV_HREF_SPECIAL(vv_spectre.special_owner, VV_HK_LIST_REMOVE, "-", index, vv_spectre.special_varname)]) "
	else if(owner_list)
		. = "<li style='backgroundColor:white'>([VV_HREF_TARGET_1V(owner_list, VV_HK_LIST_EDIT, "E", index)]) ([VV_HREF_TARGET_1V(owner_list, VV_HK_LIST_CHANGE, "C", index)]) ([VV_HREF_TARGET_1V(owner_list, VV_HK_LIST_REMOVE, "-", index)]) "
	else if(owner)
		. = "<li style='backgroundColor:white'>([VV_HREF_TARGET_1V(owner, VV_HK_BASIC_EDIT, "E", name)]) ([VV_HREF_TARGET_1V(owner, VV_HK_BASIC_CHANGE, "C", name)]) ([VV_HREF_TARGET_1V(owner, VV_HK_BASIC_MASSEDIT, "M", name)]) "
	else
		. = "<li>"

	var/name_part = VV_HTML_ENCODE(name)
	if(level > 0 || islist(owner)) //handling keys in assoc lists
		if(istype(name,/datum))
			name_part = "<a href='?_src_=vars;[HrefToken()];Vars=[REF(name)]'>[VV_HTML_ENCODE(name)] [REF(name)]</a>"
		else if(islist(name))
			var/list/list_value = name
			name_part = "<a href='?_src_=vars;[HrefToken()];Vars=[REF(name)]'> /list ([length(list_value)]) [REF(name)]</a>"

	. = "[.][name_part] = "

	var/item = _debug_variable_value(name, value, level, owner, sanitize, display_flags)

	return "[.][item]</li>"

// This is split into a seperate proc mostly to make errors that happen not break things too much
/proc/_debug_variable_value(name, value, level, datum/owner, sanitize, display_flags)
	. = "<font color='red'>DISPLAY_ERROR:</font> ([value] [REF(value)])" // Make sure this line can never runtime

	if(isnull(value))
		return "<span class='value'>null</span>"

	if(istext(value))
		return "<span class='value'>\"[VV_HTML_ENCODE(value)]\"</span>"

	if(isicon(value))
		#ifdef VARSICON
		var/icon/icon_value = icon(value)
		var/rnd = rand(1,10000)
		var/rname = "tmp[REF(icon_value)][rnd].png"
		usr << browse_rsc(icon_value, rname)
		return "(<span class='value'>[value]</span>) <img class=icon src=\"[rname]\">"
		#else
		return "/icon (<span class='value'>[value]</span>)"
		#endif

	if(isappearance(value)) // Reminder: Do not replace this into /image/debug_variable_value() proc. /appearance can't do that.
		return "<a href='?_src_=vars;[HrefToken()];Vars=[REF(value)]'>/appearance (<span class='value'>[get_appearance_vv_summary_name(value)]</span>) [REF(value)]</a>"

	if(isimage(value))
		var/image/image = value
		return "<a href='?_src_=vars;[HrefToken()];Vars=[REF(value)]'>[image.type] (<span class='value'>[get_appearance_vv_summary_name(image)]</span>) [REF(value)]</a>"

	var/isfilter = isfilter(value)
	if(isfilter && !isdatum(owner) && !isappearance(owner)) // each filter in atom.filters
		return "/[value] (<span class='value'>[value:type]</span>)"

	if(isfile(value))
		return "<span class='value'>'[value]'</span>"

	if(isdatum(value))
		var/datum/datum_value = value
		return datum_value.debug_variable_value(name, level, owner, sanitize, display_flags)

	// list debug
	var/special_list_level = (istext(name) && isdatum(owner)) ? GLOB.vv_special_lists[name] : null
	if(islist(value) || special_list_level) // Some special lists arent detectable as a list through istype
		var/list/list_value = value
		var/list/items = list()

		// Saves a list name format
		var/list_name
		if(isnull(special_list_level))
			list_name = "list"
		else if(isfilter)
			list_name = "[value]"
		else
			list_name = "special_list"

		// checks if a list is safe to open. Some special list does very weird thing
		var/is_unsafe_list = (special_list_level == VV_LIST_PROTECTED) || isappearance(owner)
		// This is becuse some lists either dont count as lists or a locate on their ref will return null
		var/link_vars = is_unsafe_list ? null : (special_list_level ? "special_owner=[REF(owner)];special_varname=[name]" : "Vars=[REF(value)]")
		// do not make a href hyperlink to open a list if it's not safe. filters aren't recommended to open
		var/a_open = is_unsafe_list ? null : "<a href='?_src_=vars;[HrefToken()];[link_vars]'>"
		var/a_close = is_unsafe_list ? null : "</a>"

		// Checks if it's too big to open, so it's gonna be folded, or not. If is_unsafe_list, it's always unfolded.
		if (!(display_flags & VV_ALWAYS_CONTRACT_LIST) && length(list_value) > 0 && length(list_value) <= (IS_NORMAL_LIST(list_value) ? VV_NORMAL_LIST_NO_EXPAND_THRESHOLD : VV_SPECIAL_LIST_NO_EXPAND_THRESHOLD) || is_unsafe_list)
			for (var/i in 1 to length(list_value))
				var/key = list_value[i]
				var/val
				if (IS_NORMAL_LIST(list_value) && !isnum(key))
					val = list_value[key]
				if (isnull(val)) // we still want to display non-null false values, such as 0 or ""
					val = key
					key = i

				items += debug_variable(key, val, level + 1, sanitize = sanitize)

			return "[a_open]/[list_name] ([length(list_value)])[a_close]<ul>[items.Join()]</ul>"
		else
			return "[a_open]/[list_name] ([length(list_value)])[a_close]"

	if(name in GLOB.bitfields)
		var/list/flags = list()
		for (var/i in GLOB.bitfields[name])
			if (value & GLOB.bitfields[name][i])
				flags += i
		if(length(flags))
			return "[VV_HTML_ENCODE(jointext(flags, ", "))]"
		else
			return "NONE"
	else
		return "<span class='value'>[VV_HTML_ENCODE(value)]</span>"

/datum/proc/debug_variable_value(name, level, datum/owner, sanitize, display_flags)
	if("[src]" != "[type]") // If we have a name var, let's use it.
		return "<a href='?_src_=vars;[HrefToken()];Vars=[REF(src)]'>[src] [type] [REF(src)]</a>"
	else
		return "<a href='?_src_=vars;[HrefToken()];Vars=[REF(src)]'>[type] [REF(src)]</a>"

/datum/weakref/debug_variable_value(name, level, datum/owner, sanitize, display_flags)
	. = ..()
	return "[.] <a href='?_src_=vars;[HrefToken()];Vars=[reference]'>(Resolve)</a>"

/matrix/debug_variable_value(name, level, datum/owner, sanitize, display_flags)
	return {"<span class='value'>
			<table class='matrixbrak'><tbody><tr><td class='lbrak'>&nbsp;</td><td>
			<table class='matrix'>
			<tbody>
				<tr><td>[a]</td><td>[d]</td><td>0</td></tr>
				<tr><td>[b]</td><td>[e]</td><td>0</td></tr>
				<tr><td>[c]</td><td>[f]</td><td>1</td></tr>
			</tbody>
			</table></td><td class='rbrak'>&nbsp;</td></tr></tbody></table></span>"} //TODO link to modify_transform wrapper for all matrices

#undef VV_HTML_ENCODE
