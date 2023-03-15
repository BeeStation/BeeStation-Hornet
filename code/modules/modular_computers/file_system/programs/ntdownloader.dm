/datum/computer_file/program/ntnetdownload
	filename = "ntndownloader"
	filedesc = "Software Download Tool"
	program_icon_state = "generic"
	extended_desc = "This program allows downloads of software from official NT repositories"
	unsendable = 1
	undeletable = 1
	size = 4
	requires_ntnet = 1
	requires_ntnet_feature = NTNET_SOFTWAREDOWNLOAD
	available_on_ntnet = 0
	ui_header = "downloader_finished.gif"
	tgui_id = "NtosNetDownloader"
	program_icon = "download"



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

	if(PRG in main_repo)
		generate_network_log("Began downloading file [PRG.filename].[PRG.filetype] from NTNet Software Repository.")
		hacked_download = 0
	else if(PRG in antag_repo)
		generate_network_log("Began downloading file **ENCRYPTED**.[PRG.filetype] from unspecified server.")
		hacked_download = 1
	else
		generate_network_log("Began downloading file [PRG.filename].[PRG.filetype] from unspecified server.")
		hacked_download = 0

	downloaded_file = PRG.clone()

/datum/computer_file/program/ntnetdownload/proc/abort_file_download()
	if(!downloaded_file)
		return
	generate_network_log("Aborted download of file [hacked_download ? "**ENCRYPTED**" : "[downloaded_file.filename].[downloaded_file.filetype]"].")
	downloaded_file = null
	download_completion = 0
	ui_header = "downloader_finished.gif"

/datum/computer_file/program/ntnetdownload/proc/complete_file_download()
	if(!downloaded_file)
		return
	generate_network_log("Completed download of file [hacked_download ? "**ENCRYPTED**" : "[downloaded_file.filename].[downloaded_file.filetype]"].")
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
		if(1)
			download_netspeed = NTNETSPEED_LOWSIGNAL
		if(2)
			download_netspeed = NTNETSPEED_HIGHSIGNAL
		if(3)
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
			"compatible" = check_compatibility(P),
			"size" = P.size,
			"access" = emagged && P.available_on_syndinet ? TRUE : P.can_run(user,transfer = 1, access = access),
			"verifiedsource" = P.available_on_ntnet,
		))

	data["categories"] = show_categories & program_categories

	return data

/datum/computer_file/program/ntnetdownload/proc/check_compatibility(datum/computer_file/program/P)
	var/hardflag = computer.hardware_flag

	if(P?.is_supported_by_hardware(hardflag,0))
		return TRUE
	return FALSE

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
	requires_ntnet = 0
	ui_header = "downloader_finished.gif"
	tgui_id = "NtosNetDownloader"
	emagged = TRUE

/datum/computer_file/program/ntnetdownload/syndicate/on_start()
	. = ..()
	if(!.)
		return
	main_repo = SSnetworks.station_network.available_antag_software
	antag_repo = null
