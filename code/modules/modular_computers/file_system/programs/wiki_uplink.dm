/datum/computer_file/program/databank_uplink
	filename = "databank"
	filedesc = "Central Command Databank Uplink"
	extended_desc = "An application used to connect to the Central Commands Databanks in order to access all the guides you could ever need!"
	category = PROGRAM_CATEGORY_CREW
	program_icon_state = "generic"
	tgui_id = "NtosDatabank"
	program_icon = "book"
	size = 2
	power_consumption = 10 WATT

/datum/computer_file/program/databank_uplink/ui_data(mob/user)
	var/list/data = list()
	var/wikiurl = CONFIG_GET(string/wikiurl)

	data["src"] = wikiurl
	return data
