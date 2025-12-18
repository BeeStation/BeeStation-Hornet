/datum/buildmode_mode/fill
	key = "fill"

	use_corner_selection = TRUE
	var/objholder = null

/datum/buildmode_mode/fill/show_help(client/c)
	to_chat(c, span_notice("***********************************************************"))
	to_chat(c, span_notice("Left Mouse Button on turf/obj/mob      = Select corner"))
	to_chat(c, span_notice("Left Mouse Button + Alt on turf/obj/mob = Delete region"))
	to_chat(c, span_notice("Right Mouse Button on buildmode button = Select object type"))
	to_chat(c, span_notice("***********************************************************"))

/datum/buildmode_mode/fill/change_settings(client/c)
	var/target_path = tgui_input_text(c, "Enter typepath:" ,"Typepath","/obj/structure/closet")
	objholder = text2path(target_path)
	if(!ispath(objholder))
		objholder = pick_closest_path(target_path)
		if(!objholder)
			alert("No path has been selected.")
			return
		else if(ispath(objholder, /area))
			objholder = null
			alert("Area paths are not supported for this mode, use the area edit mode instead.")
			return
	deselect_region()

/datum/buildmode_mode/fill/handle_click(client/c, params, obj/object)
	if(isnull(objholder))
		to_chat(c, span_warning("Select an object type first."))
		deselect_region()
		return
	..()

/datum/buildmode_mode/fill/handle_selected_area(client/c, params)
	var/list/modifiers = params2list(params)

	if(LAZYACCESS(modifiers, LEFT_CLICK)) //rectangular
		if(LAZYACCESS(modifiers, ALT_CLICK))
			var/list/deletion_area = block(get_turf(cornerA),get_turf(cornerB))
			for(var/beep in deletion_area)
				var/turf/T = beep
				for(var/atom/movable/AM in T)
					qdel(AM)
				// extreme haircut
				T.ScrapeAway(INFINITY, CHANGETURF_DEFER_CHANGE)
			for(var/beep in deletion_area)
				var/turf/T = beep
				T.AfterChange()
			log_admin("Build Mode: [key_name(c)] deleted turfs from [AREACOORD(cornerA)] through [AREACOORD(cornerB)]")
			// if there's an analogous proc for this on tg lmk
			// empty_region(block(get_turf(cornerA),get_turf(cornerB)))
		else
			for(var/turf/T in block(get_turf(cornerA),get_turf(cornerB)))
				if(ispath(objholder,/turf))
					T.PlaceOnTop(objholder)
				else
					var/obj/A = new objholder(T)
					A.setDir(BM.build_dir)
			log_admin("Build Mode: [key_name(c)] with path [objholder], filled the region from [AREACOORD(cornerA)] through [AREACOORD(cornerB)]")
