/datum/computer_file/program/ntnetdownload
	filename = "ntndownloader"
	filedesc = "Software Download Tool"
	program_icon_state = "generic"
	extended_desc = "This program allows downloads of software from official NT repositories"
	undeletable = TRUE
	size = 4
	requires_ntnet = TRUE
	requires_ntnet_feature = NTNET_SOFTWAREDOWNLOAD
	available_on_ntnet = FALSE
	ui_header = "downloader_finished.gif"
	tgui_id = "NtosNetDownloader"
	program_icon = "download"
	power_consumption = 80 WATT



	var/datum/computer_file/program/downloaded_file = null
	var/hacked_download = 0
	var/download_completion = 0 //GQ of downloaded data.
	var/download_netspeed = 0
	var/downloaderror = ""
	var/obj/item/modular_computer/my_computer = null
	var/emagged = FALSE
	var/list/main_repo
	var/list/antag_repo
	var/list/show_categories = list(
		PROGRAM_CATEGORY_CREW,
		PROGRAM_CATEGORY_ENGI,
		PROGRAM_CATEGORY_ROBO,
		PROGRAM_CATEGORY_SUPL,
		PROGRAM_CATEGORY_MISC,
	)

/datum/computer_file/program/ntnetdownload/on_start()
	. = ..()
	if(!.)
		return
	main_repo = SSnetworks.station_network.available_station_software
	antag_repo = SSnetworks.station_network.available_antag_software

/datum/computer_file/program/ntnetdownload/run_emag()
	if(emagged)
		return FALSE
	emagged = TRUE
	return TRUE


/datum/computer_file/program/ntnetdownload/proc/begin_file_download(filename)
	if(downloaded_file)
		return 0

	var/datum/computer_file/program/PRG = SSnetworks.station_network.find_ntnet_file_by_name(filename)

	if(!PRG || !istype(PRG))
		return 0

	// Attempting to download antag only program, but without having emagged/syndicate computer. No.
	if(PRG.available_on_syndinet && !emagged)
		return 0

	var/obj/item/computer_hardware/hard_drive/hard_drive = computer.all_components[MC_HDD]

	if(!computer || !hard_drive || !hard_drive.can_store_file(PRG))
		return 0

	ui_header = "downloader_running.gif"

	if(PRG in antag_repo)
		hacked_download = 1
	else
		hacked_download = 0

	downloaded_file = PRG.clone()

/datum/computer_file/program/ntnetdownload/proc/abort_file_download()
	if(!downloaded_file)
		return
	downloaded_file = null
	download_completion = 0
	ui_header = "downloader_finished.gif"

/datum/computer_file/program/ntnetdownload/proc/complete_file_download()
	if(!downloaded_file)
		return
	var/obj/item/computer_hardware/network_card/network_card = computer.all_components[MC_NET]
		// The following will be our only log for the downloading of files. Else it could flood the logger, which is now much more useful than it was before.
	computer.add_log("Completed download of file [hacked_download ? "**ENCRYPTED**" : "[downloaded_file.filename].[downloaded_file.filetype]"].", TRUE, network_card)
	var/obj/item/computer_hardware/hard_drive/hard_drive = computer.all_components[MC_HDD]
	if(!computer || !hard_drive || !hard_drive.store_file(downloaded_file))
		// The download failed
		downloaderror = "I/O ERROR - Unable to save file. Check whether you have enough free space on your hard drive and whether your hard drive is properly connected. If the issue persists contact your system administrator for assistance."
	downloaded_file = null
	download_completion = 0
	ui_header = "downloader_finished.gif"

/datum/computer_file/program/ntnetdownload/process_tick()
	if(!downloaded_file)
		return
	if(download_completion >= downloaded_file.size)
		complete_file_download()
	// Download speed according to connectivity state. NTNet server is assumed to be on unlimited speed so we're limited by our local connectivity
	download_netspeed = 0
	// Speed defines are found in misc.dm
	switch(ntnet_status)
		if(SIGNAL_LOW)
			download_netspeed = NTNETSPEED_LOWSIGNAL
		if(SIGNAL_HIGH)
			download_netspeed = NTNETSPEED_HIGHSIGNAL
		if(SIGNAL_NO_RELAY)
			download_netspeed = NTNETSPEED_ETHERNET
		if(SIGNAL_HACKED)
			download_netspeed = NTNETSPEED_ETHERNET
	download_completion += download_netspeed

/datum/computer_file/program/ntnetdownload/ui_act(action, params)
	if(..())
		return 1
	switch(action)
		if("PRG_downloadfile")
			if(!downloaded_file)
				begin_file_download(params["filename"])
			return 1
		if("PRG_reseterror")
			if(downloaderror)
				download_completion = 0
				download_netspeed = 0
				downloaded_file = null
				downloaderror = ""
			return 1
	return 0

/datum/computer_file/program/ntnetdownload/ui_data(mob/user)
	my_computer = computer

	if(!istype(my_computer))
		return
	var/obj/item/computer_hardware/card_slot/card_slot = computer.all_components[MC_CARD]
	var/list/access = card_slot?.GetAccess()

	var/list/data = list()

	data["downloading"] = !!downloaded_file
	data["error"] = downloaderror || FALSE
	data["id_inserted"] = !!card_slot?.GetID()

	// Download running. Wait please..
	if(downloaded_file)
		data["downloadname"] = downloaded_file.filename
		data["downloaddesc"] = downloaded_file.filedesc
		data["downloadsize"] = downloaded_file.size
		data["downloadspeed"] = download_netspeed
		data["downloadcompletion"] = round(download_completion, 0.1)

	var/obj/item/computer_hardware/hard_drive/hard_drive = my_computer.all_components[MC_HDD]
	data["disk_size"] = hard_drive.max_capacity
	data["disk_used"] = hard_drive.used_capacity
	data["emagged"] = emagged

	var/list/repo = antag_repo | main_repo
	var/list/program_categories = list()

	for(var/I in repo)
		var/datum/computer_file/program/P = I
		if(!(P.category in program_categories))
			program_categories.Add(P.category)
		data["programs"] += list(list(
			"icon" = P.program_icon,
			"filename" = P.filename,
			"filedesc" = P.filedesc,
			"fileinfo" = P.extended_desc,
			"category" = P.category,
			"installed" = !!hard_drive.find_file_by_name(P.filename),
			"size" = P.size,
			"access" = emagged && P.available_on_syndinet ? TRUE : P.can_download(user, access = access),
			"compatible" = P.is_supported_by_hardware(computer, user, loud = FALSE),
			"requiredhardware" = P.hardware_requirement,
			"verifiedsource" = P.available_on_ntnet,
		))

	data["categories"] = show_categories & program_categories

	return data

/datum/computer_file/program/ntnetdownload/kill_program(forced)
	abort_file_download()
	return ..(forced)

////////////////////////
//Syndicate Downloader//
////////////////////////

/// This app only lists programs normally found in the emagged section of the normal downloader app

/datum/computer_file/program/ntnetdownload/syndicate
	filename = "syndownloader"
	filedesc = "Software Download Tool"
	program_icon_state = "generic"
	extended_desc = "This program allows downloads of software from shared Syndicate repositories"
	ui_header = "downloader_finished.gif"
	tgui_id = "NtosNetDownloader"
	emagged = TRUE
	power_consumption = 10 WATT

/datum/computer_file/program/ntnetdownload/syndicate/on_start()
	. = ..()
	if(!.)
		return
	main_repo = SSnetworks.station_network.available_antag_software
	antag_repo = null
