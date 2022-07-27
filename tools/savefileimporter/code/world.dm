/world/New()
	// Load config
	if(!fexists("config.json"))
		log_info("config.json not found. Please setup the project")
		del(src)

	GLOB.config = json_decode(file2text("config.json"))
	// Connect to DB
	establish_db_connection()

	log_info("ALL EXISTING ENTRIES IN THE PREFERENCES AND CHARACTERS TABLE WILL BE WIPED")
	log_info("EXIT THIS PROGRAM NOW IF YOU DO NOT WANT THIS")
	log_info("Savefile import will start in 10 seconds")
	log_info("The process WILL lock up DD, but rest assured, it is working")
	sleep(100)

	// Remove old entries
	var/datum/DBQuery/q1 = NewDBQuery("DELETE FROM SS13_preferences", list())
	var/datum/DBQuery/q2 = NewDBQuery("DELETE FROM SS13_characters", list())
	q1.Execute()
	q2.Execute()

	// Begin the import
	var/savepath = GLOB.config["savefile_dir"] // Cache this to prevent a ton of list lookups


	for(var/outerpath in flist(savepath))
		var/list/innerlist = flist("[savepath][outerpath]")
		for(var/ckey_path in innerlist)
			var/real_ckey = ckey(ckey_path)
			var/sf_path = "[savepath][outerpath][ckey_path]preferences.sav"
			var/savefile/S = new /savefile(sf_path)
			parse_savefile(real_ckey, S)
		log_info("Finished processing [outerpath]")
		sleep(1)

	log_info("Finished all conversions")

/proc/log_info(txt)
	world.log << "[txt]"
