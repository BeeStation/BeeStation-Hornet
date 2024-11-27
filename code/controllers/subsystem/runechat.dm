TIMER_SUBSYSTEM_DEF(runechat)
	name = "Runechat"
	priority = FIRE_PRIORITY_RUNECHAT
	/// List of most characters in the font. Do not varedit it in game.
	/// Format of it is as follows: character, size when normal, size when small, size when big.
	var/list/letters = list()
	flags = SS_TICKER

/datum/controller/subsystem/timer/runechat/Initialize()
	load_character_list()
	initialized = TRUE
	return SS_INIT_SUCCESS

/datum/controller/subsystem/timer/runechat/proc/load_character_list()
	var/json_file = file("config/runechat_cache.json")
	if(!fexists(json_file))
		log_world("Missing runechat cache config file!")
		return
	var loaded_values = json_decode(rustg_file_read(json_file))
	for(var/values as() in loaded_values)
		var/list/widths = values["values"]
		letters[ascii2text(values["id"])] = list(widths[1], widths[2], widths[3])

// This is left to regenerate the file, if it ever gets lost
// /datum/myLetter
// 	var/list/values = list()
// 	var/id
// 	var/letter

// /datum/controller/subsystem/timer/runechat/proc/init_runechat_list(client/actor)
// 	var/ckey = actor.ckey
// 	var/list/list_letters = list()
// 	//This is the end of BMP plane of Unicode
// 	for(var/i = 0, i < 65535, i++)
// 		var/key = ascii2text(i)
// 		letters[key] = list(null, null, null)
// 		handle_single_letter(key, actor, NORMAL_FONT_INDEX)
// 		handle_single_letter(key, actor, SMALL_FONT_INDEX)
// 		handle_single_letter(key, actor, BIG_FONT_INDEX)
// 		var/datum/myLetter/letter = new()
// 		letter.id = i
// 		letter.letter = key
// 		letter.values = letters[key]
// 		list_letters.Add(letter)

// 	var/jsonpath = file("path")
// 	if(fexists(jsonpath))
// 		fdel(jsonpath)
// 	var/text = "\["
// 	for(var/datum/myLetter/L in list_letters)
// 		text+= "{ \"id\": [L.id], \"letter\": [json_encode(L.letter)], \"values\": [json_encode(L.values)] },"
// 	text += "]"
// 	WRITE_FILE(jsonpath, text)

// /datum/controller/subsystem/timer/runechat/proc/handle_single_letter(letter, client/measured_client, font_index)
// 	set waitfor = TRUE
// 	var/font_class
// 	if(font_index == NORMAL_FONT_INDEX)
// 		font_class = ""
// 	else if(font_index == SMALL_FONT_INDEX)
// 		font_class = "small"
// 	else
// 		font_class = "big"
// 	if(!measured_client)
// 		return FALSE
// 	var/response = WXH_TO_WIDTH(measured_client.MeasureText("<span class='[font_class]'>[letter]</span>"))
// 	letters[letter][font_index] = response
// 	return TRUE
