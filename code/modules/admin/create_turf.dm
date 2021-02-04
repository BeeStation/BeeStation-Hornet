/datum/admins/proc/create_turf(mob/user)
	var/static/create_turf_html
	if (!create_turf_html)
		var/turfjs = null
		turfjs = jointext(typesof(/turf), ";")
		create_turf_html = rustg_file_read('html/create_object.html')
		create_turf_html = replacetext(create_turf_html, "Create Object", "Create Turf")
		create_turf_html = replacetext(create_turf_html, "null /* object types */", "\"[turfjs]\"")

	user << browse(create_panel_helper(create_turf_html), "window=create_turf;size=425x475")
