#define CHECK_NULL(thing) isnull(thing) ? #thing+" = null" : #thing+" = [istext(thing) ? "\"[thing]\"" : thing]"
/icon
	/// Just used for reference purpose to record which dmi file /icon used uppn creation
	var/file_reference
	/// Just used to record which state the /icon was made with
	var/state_reference
	/// Used to track when something did icon(icon(icon(icon('some.dmi'))))
	var/revise_count

// Usually, this is not a good idea to do this, but it's for putting a hint when /icon is created, so that we can investigate what /icon a thing holds.
/icon/New(icon/icon, icon_state, dir, frame, moving)
	. = ..()
	if(isicon_datum(icon) && icon.file_reference)
		revise_count = icon.revise_count+1 // when /icon was created through an /icon, we might want to check the recursive count
		file_reference = icon.file_reference || "UNKNOWN"
		state_reference = "<li>[CHECK_NULL(icon_state)]</li><li>[CHECK_NULL(dir)]</li><li>[CHECK_NULL(frame)]</li><li>[CHECK_NULL(moving)]</li>"
	else if(icon_state || dir || frame || moving) // If any of these value is given, DM refuses to save 'something
dmi', and it decides to make a new /icon instance.
		file_reference = "[icon]"
		state_reference = "<li>[CHECK_NULL(icon_state)]</li><li>[CHECK_NULL(dir)]</li><li>[CHECK_NULL(frame)]</li><li>[CHECK_NULL(moving)]</li>"

/icon/proc/get_vv_data()
	return "<ul class='data-column'><li>FileRef: '[file_reference]'</li>[revise_count ? "<li>revise_count = [revise_count]<li>" : ""]</li>[state_reference]</ul>"

#undef CHECK_NULL
