#define VV_HTML_ENCODE(thing) ( sanitize ? html_encode(thing) : thing )

// defines of hints for how a proc should build strings
#define STYLE_READ_ONLY (1)
#define STYLE_NORMAL (2)
#define STYLE_LIST (3)
#define STYLE_SPECIAL (4)
#define STYLE_EMPTY (5)

/// Get displayed variable in VV variable list
/proc/debug_variable(name, value, level, datum/owner, sanitize = TRUE, display_flags = NONE) //if D is a list, name will be index, and value will be assoc value.
	// variables to store values
	var/index
	var/list/owner_list
	var/datum/vv_ghost/vv_spectre

	// ------------------------------------------------------------
	// checks if a thing is /list, or /vv_ghost to deliver a special list, and then reassign name/value
	if(owner)
		if(istype(owner, /datum/vv_ghost))
			vv_spectre = owner
		if(islist(owner) || vv_spectre)
			index = name
			owner_list = vv_spectre?.dmlist_holder || owner
			if (value)
				name = owner_list[name] //name is really the index until this line
			else
				value = owner_list[name]

	// ------------------------------------------------------------
	// Builds hyperlink strings with edit options
	var/special_list_secure_level = (istext(name) && (isdatum(owner) || vv_spectre) ) ? GLOB.vv_special_lists[name] : null
	var/is_read_only = CHECK_BITFIELD(display_flags, VV_READ_ONLY) || (special_list_secure_level && (special_list_secure_level <= VV_LIST_READ_ONLY))
	var/hyperlink_style =\
		(is_read_only && level) ? STYLE_EMPTY \
		: is_read_only ? STYLE_READ_ONLY \
		: vv_spectre ? STYLE_SPECIAL \
		: owner_list ? STYLE_LIST \
		: owner ? STYLE_NORMAL \
		: STYLE_EMPTY

	switch(hyperlink_style)
		if(STYLE_READ_ONLY)
			. = "<li style='backgroundColor:white'>(Disabled) "
		if(STYLE_NORMAL)
			. = "<li style='backgroundColor:white'>([VV_HREF_TARGET_1V(owner, VV_HK_BASIC_EDIT, "E", name)]) ([VV_HREF_TARGET_1V(owner, VV_HK_BASIC_CHANGE, "C", name)]) ([VV_HREF_TARGET_1V(owner, VV_HK_BASIC_MASSEDIT, "M", name)]) "
		if(STYLE_LIST)
			. = "<li style='backgroundColor:white'>([VV_HREF_TARGET_1V(owner_list, VV_HK_LIST_EDIT, "E", index)]) ([VV_HREF_TARGET_1V(owner_list, VV_HK_LIST_CHANGE, "C", index)]) ([VV_HREF_TARGET_1V(owner_list, VV_HK_LIST_REMOVE, "-", index)]) "
		if(STYLE_SPECIAL)
			. = "<li style='backgroundColor:white'>([VV_HREF_SPECIAL(vv_spectre.dmlist_origin_ref, VV_HK_LIST_EDIT, "E", index, vv_spectre.dmlist_varname)]) ([VV_HREF_SPECIAL(vv_spectre.dmlist_origin_ref, VV_HK_LIST_CHANGE, "C", index, vv_spectre.dmlist_varname)]) ([VV_HREF_SPECIAL(vv_spectre.dmlist_origin_ref, VV_HK_LIST_REMOVE, "-", index, vv_spectre.dmlist_varname)]) "
		if(STYLE_EMPTY)
			. = "<li>"

	// ------------------------------------------------------------
	var/name_part = VV_HTML_ENCODE(name)
	if(level > 0 || islist(owner)) //handling keys in assoc lists
		if(istype(name,/datum))
			name_part = "<a href='byond://?_src_=vars;[HrefToken()];Vars=[REF(name)]'>[VV_HTML_ENCODE(name)] [REF(name)]</a>"
		else if(islist(name))
			var/list/list_value = name
			name_part = "<a href='byond://?_src_=vars;[HrefToken()];Vars=[REF(name)]'> /list ([length(list_value)]) [REF(name)]</a>"

	. = "[.][name_part] = "

	var/item = _debug_variable_value(name, value, level, owner, sanitize, display_flags)

	return "[.][item]</li>"

// This is split into a seperate proc mostly to make errors that happen not break things too much
/proc/_debug_variable_value(name, datum/value, level, datum/owner, sanitize, display_flags)
	. = "<font color='red'>DISPLAY_ERROR:</font> ([value] [REF(value)])" // Make sure this line can never runtime

	if(isnull(value))
		return span_value("null")

	if(iscolortext(value))
		return span_value("\"[value]\" <span class='colorbox' style='background-color:[("#" in value) ? "" : "#"][value]'>_________</span>")

	if(istext(value))
		return span_value("\"[VV_HTML_ENCODE(value)]\"")

	if(isicon(value))
		#ifdef VARSICON
		var/icon/icon_value = icon(value)
		var/rnd = rand(1,10000)
		var/rname = "tmp[REF(icon_value)][rnd].png"
		usr << browse_rsc(icon_value, rname)
		return "([span_value("[value]")]) <img class=icon src=\"[rname]\">"
		#else
		return "/icon ([span_value("[value]")])"
		#endif

	if(isappearance(value)) // Reminder: Do not replace this into /image/debug_variable_value() proc. /appearance can't do that.
		return "<a href='byond://?_src_=vars;[HrefToken()];Vars=[REF(value)]'>/appearance ([span_value("[get_appearance_vv_summary_name(value)]")]) [REF(value)]</a>"

	if(isimage(value))
		var/image/image = value
		return "<a href='byond://?_src_=vars;[HrefToken()];Vars=[REF(value)]'>[image.type] ([span_value("[get_appearance_vv_summary_name(image)]")]) [REF(value)]</a>"

	// fun fact: there are two types of /filters. `/filters(/filters(), /filters(), ...)`
	// isfilter() doesn't know if it's a parent filter(that has [/filters]s inside of itself), or a child filter
	var/isfilter = isfilter(value)
	var/is_child_filter = isfilter && !isdatum(owner) && !isappearance(owner) // 'child_filter' means each /filters in /atom.filters
	if(is_child_filter)
		return "/filters\[child\] ([span_value("[value.type]")])"

	if(isfile(value))
		return span_value("'[value]'")

	if(isdatum(value))
		var/datum/datum_value = value
		return datum_value.debug_variable_value(name, level, owner, sanitize, display_flags)

	var/special_list_secure_level = (istext(name) && isdatum(owner)) ? GLOB.vv_special_lists[name] : null
	var/islist = islist(value) || special_list_secure_level
	if(islist)
		var/list/list_value = value

		var/list_type = \
			isfilter ? "/filters\[parent\]" \
			: special_list_secure_level ? "/special_list" \
			: /list

		// Hyperlink to open a /list window.
		var/a_open = null
		var/a_close = null

		// some '/list' instance is dangerous to open.
		var/can_open_list_window = !( (special_list_secure_level == VV_LIST_PROTECTED) || isappearance(owner) )
		if(can_open_list_window)
			var/href_reference_string = \
				special_list_secure_level \
				? "dmlist_origin_ref=[REF(owner)];dmlist_varname=[name]" \
				: "Vars=[REF(value)]"
			a_open = "<a href='byond://?_src_=vars;[HrefToken()];[href_reference_string]'>"
			a_close = "</a>"

		var/should_fold_list_items = (display_flags & VV_ALWAYS_CONTRACT_LIST) || length(list_value) > VV_BIG_SIZED_LIST_THRESHOLD
		if(can_open_list_window && should_fold_list_items)
			return "[a_open][list_type] ([length(list_value)])[a_close]"
		else
			var/flag = (special_list_secure_level && (special_list_secure_level <= VV_LIST_READ_ONLY)) ? VV_READ_ONLY : null
			var/list/items = list()
			for (var/i in 1 to length(list_value))
				var/key = list_value[i]
				var/val
				if (IS_NORMAL_LIST(list_value) && !isnum(key))
					val = list_value[key]
				if (isnull(val)) // we still want to display non-null false values, such as 0 or ""
					val = key
					key = i

				items += debug_variable(key, val, level + 1, sanitize = sanitize, display_flags = flag)

			return "[a_open][list_type] ([length(list_value)])[a_close]<ul>[items.Join()]</ul>"

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
		return span_value("[VV_HTML_ENCODE(value)]")

/datum/proc/debug_variable_value(name, level, datum/owner, sanitize, display_flags)
	if("[src]" != "[type]") // If we have a name var, let's use it.
		return "<a href='byond://?_src_=vars;[HrefToken()];Vars=[REF(src)]'>[src] [type] [REF(src)]</a>"
	else
		return "<a href='byond://?_src_=vars;[HrefToken()];Vars=[REF(src)]'>[type] [REF(src)]</a>"

/datum/weakref/debug_variable_value(name, level, datum/owner, sanitize, display_flags)
	. = ..()
	return "[.] <a href='byond://?_src_=vars;[HrefToken()];Vars=[reference]'>(Resolve)</a>"

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
#undef STYLE_READ_ONLY
#undef STYLE_NORMAL
#undef STYLE_LIST
#undef STYLE_SPECIAL
#undef STYLE_EMPTY
