/datum/unit_test/shuttle_checker/Run()
	if(!length(SSmapping.shuttle_templates))
		SSmapping.preloadShuttleTemplates()
	var/regex/typepath_regex = regex(@"(\/obj\/docking_port\/mobile[/\w]*)\{")
	var/regex/width_regex = regex(@"\/obj\/docking_port\/mobile[/\w]*\{[^\}]*[^d]width = (\d*)")
	var/regex/height_regex = regex(@"\/obj\/docking_port\/mobile[/\w]*\{[^\}]*[^d]height = (\d*)")
	var/regex/dir_regex = regex(@"\/obj\/docking_port\/mobile[/\w]*\{[^\}]*[^d]dir = (\d*)")
	var/obj/docking_port/mobile/default_port = null
	var/list/fail_reasons = list()
	for(var/shuttle_id in SSmapping.shuttle_templates)
		var/datum/map_template/shuttle/shuttle = SSmapping.shuttle_templates[shuttle_id]
		var/file_text = file2text(shuttle.mappath)
		if (!typepath_regex.Find(file_text))
			continue
		var/atom/typepath = text2path(typepath_regex.group[1])
		var/port_text = findtext(file_text, "/obj/docking_port/mobile")
		var/shuttle_dir = initial(typepath.dir)
		if	(dir_regex.Find(file_text))
			shuttle_dir = text2num(dir_regex.group[1])
		var/shuttle_horizontal_size = 0
		var/shuttle_vertical_size = 0
		//Do the dock width
		var/dock_width = initial(default_port.width)
		if (width_regex.Find(file_text))
			dock_width = text2num(width_regex.group[1])
		if (shuttle_dir == 4 || shuttle_dir == 8)
			shuttle_vertical_size = dock_width
		else
			shuttle_horizontal_size = dock_width
		//Do the dock height
		var/dock_height = initial(default_port.height)
		if (height_regex.Find(file_text))
			dock_height = text2num(height_regex.group[1])
		if (shuttle_dir == 4 || shuttle_dir == 8)
			shuttle_horizontal_size = dock_height
		else
			shuttle_vertical_size = dock_height
		//Width and height start from 0, so if the map is 5x5, shuttle max size is 4x4
		if (shuttle_horizontal_size > shuttle.width)
			fail_reasons += "Shuttle [shuttle.name] has a docking port that is too large ([shuttle_horizontal_size] > [shuttle.width]) (Shuttle width/height starts from 0)"
		if (shuttle_vertical_size > shuttle.height)
			fail_reasons += "Shuttle [shuttle.name] has a docking port that is too large ([shuttle_vertical_size] > [shuttle.height]) (Shuttle width/height starts from 0)"
	if (length(fail_reasons))
		Fail(fail_reasons.Join(";\n"))
