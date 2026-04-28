//Misc Medal hub IDs
#define MEDAL_METEOR 			"Your Life Before Your Eyes"
#define MEDAL_PULSE 			"Jackpot"
#define MEDAL_TIMEWASTE 		"Overextended The Joke"
#define MEDAL_RODSUPLEX 		"Feat of Strength"
#define MEDAL_CLOWNCARKING 		"Round and Full"
#define MEDAL_THANKSALOT 		"The Best Driver"
#define MEDAL_SINGULARITY_DEATH       "Crossing the Horizon" // get eaten by a singularity
#define MEDAL_GET_CLUWNED             "KILLMEKILLMEKILLME" // get turned into a vile creature known as a cluwne
#define MEDAL_USE_WEIGHT_MACHINE      "Survival of the Fittest"
#define MEDAL_UNWRENCH_HIGH_PRESSURE  "WHOOSH!"
#define MEDAL_COMPLETE_ALL_OBJECTIVES "Greentext"
#define MEDAL_APPLY_REAGENT_METH      "NYOOOOM"
#define MEDAL_APPLY_REAGENT_SOYMILK   "Soyboy"
#define MEDAL_15_AI_LAW_CHANGES       "Dave, my mind is going"
#define MEDAL_DETONATE_WELDERBOMB     "That was stupid of you."
#define MEDAL_SUCCUMB                 "Please just end the pain"
#define MEDAL_GHOSTS                  "G-G-Ghosts?"

//Boss medals

// Medal hub IDs for boss medals (Pre-fixes)
#define BOSS_MEDAL_ANY		  "Killer"
#define BOSS_MEDAL_MINER	  "Blood-drunk Miner"
#define BOSS_MEDAL_BUBBLEGUM  "Bubblegum"
#define BOSS_MEDAL_COLOSSUS	  "Colossus"
#define BOSS_MEDAL_DRAKE	  "Drake"
#define BOSS_MEDAL_HIEROPHANT "Hierophant"
#define BOSS_MEDAL_LEGION	  "Legion"
#define BOSS_MEDAL_TENDRIL	  "Tendril"
#define BOSS_MEDAL_SWARMERS   "Swarmer Beacon"

// Medal hub IDs for boss-kill scores
#define BOSS_SCORE 	         "Bosses Killed"
#define BUBBLEGUM_SCORE 	 "Bubblegum Killed"
#define COLOSSUS_SCORE 	     "Colossus Killed"
#define DRAKE_SCORE 	     "Drakes Killed"
#define HIEROPHANT_SCORE 	 "Hierophants Killed"
#define LEGION_SCORE 	     "Legion Killed"
#define SWARMER_BEACON_SCORE "Swarmer Beacons Killed"
#define TENDRIL_CLEAR_SCORE	 "Tendrils Killed"



//Migration script generation
//Replace hub information and fire to generate hub_migration.sql script to use.
/mob/verb/generate_migration_script()
	set name = "Generate Hub Migration Script"

	var/hub_address = "REPLACEME"
	var/hub_password = "REPLACEME"

	var/list/valid_medals = list(
						MEDAL_METEOR,
						MEDAL_PULSE,
						MEDAL_TIMEWASTE,
						MEDAL_RODSUPLEX,
						MEDAL_CLOWNCARKING,
						MEDAL_THANKSALOT,
						MEDAL_SINGULARITY_DEATH,
						MEDAL_GET_CLUWNED,
						MEDAL_USE_WEIGHT_MACHINE,
						MEDAL_UNWRENCH_HIGH_PRESSURE,
						MEDAL_COMPLETE_ALL_OBJECTIVES,
						MEDAL_APPLY_REAGENT_METH,
						MEDAL_APPLY_REAGENT_SOYMILK,
						MEDAL_15_AI_LAW_CHANGES,
						MEDAL_DETONATE_WELDERBOMB,
						MEDAL_SUCCUMB,
						MEDAL_GHOSTS,
						BOSS_MEDAL_ANY,
						BOSS_MEDAL_MINER,
						BOSS_MEDAL_BUBBLEGUM,
						BOSS_MEDAL_COLOSSUS,
						BOSS_MEDAL_DRAKE,
						BOSS_MEDAL_HIEROPHANT,
						BOSS_MEDAL_LEGION,
						BOSS_MEDAL_TENDRIL,
						BOSS_MEDAL_SWARMERS)

	var/list/valid_scores = list(
						BOSS_SCORE,
						BUBBLEGUM_SCORE,
						COLOSSUS_SCORE,
						DRAKE_SCORE,
						HIEROPHANT_SCORE,
						LEGION_SCORE,
						SWARMER_BEACON_SCORE,
						TENDRIL_CLEAR_SCORE)

	var/ach = "achievements" //IMPORTANT : ADD PREFIX HERE IF YOU'RE USING PREFIXED SCHEMA

	var/outfile = file("hub_migration.sql")
	fdel(outfile)
	outfile << "BEGIN;"

	var/list/giant_list_of_ckeys = list()

	var/perpage = 100
	var/requested_page = 1
	var/hub_url = replacetext(hub_address,".","/")
	var/list/medal_data = list()
	var/regex/datepart_regex = regex(@"[/\s]")
	while(1)
		world << "Fetching page [requested_page]"
		var/list/result = world.Export("http://www.byond.com/games/[hub_url]?format=text&command=view_medals&per_page=[perpage]&page=[requested_page]")
		if(!result)
			return
		var/data = file2text(result["CONTENT"])
		var/regex/page_info = regex(@"page = (\d*)")
		page_info.Find(data)
		var/received_page = text2num(page_info.group[1])
		if(received_page != requested_page) //out of entries
			break
		else
			requested_page++
		var/regex/R = regex(@'medal\/\d+[\s\n]*key = "(.*)"[\s\n]*name = "(.*)"[\s\n]*desc = ".*"[\s\n]*earned = "(.*)"',"gm")
		while(R.Find(data))
			var/key = ckey(R.group[1])
			var/medal = R.group[2]
			var/list/dateparts = splittext(R.group[3],datepart_regex)
			var/list/out_date = list(dateparts[3],dateparts[1],dateparts[2]) // YYYY/MM/DD
			if(!valid_medals.Find(medal))
				continue
			if(!medal_data[key])
				medal_data[key] = list()
			medal_data[key][medal] = out_date.Join("/")
			if(!(giant_list_of_ckeys.Find(key))) //this is probably really slow
				giant_list_of_ckeys += key

	for(var/listkey in params2list(world.GetScores(null,null,hub_address,hub_password)))
		if(!(giant_list_of_ckeys.Find(listkey))) //this is probably really slow
			giant_list_of_ckeys += listkey

	world << "Found [giant_list_of_ckeys.len] as total entry count."

	var/list/scores_data = list()
	for(var/score in valid_scores)
		var/received_count = 0
		while(1)
			world << "Fetching [score] scores, offset :[received_count] of [score]"
			var/list/batch = params2list(world.GetScores(giant_list_of_ckeys.len,received_count,score,hub_address,hub_password))
			world << "Fetched [batch.len] scores for [score]."
			received_count += batch.len
			if(!batch.len)
				break
			for(var/value in batch)
				var/key = ckey(value)
				if(!scores_data[key])
					scores_data[key] = list()
				if(isnum(batch[value]))
					world << "NUMBER"
					return
				scores_data[key][score] = batch[value]
			if(batch.len < 1000) //Out of scores anyway
				break

	var/i = 1
	for(var/key in giant_list_of_ckeys)
		world << "Generating entries for [key] [i]/[giant_list_of_ckeys.len]"
		var/keyv = ckey(key) //Checkinf if you don't have any manually entered drop tables; juniors on your hub is good idea.
		var/list/values = list()
		for(var/cheevo in medal_data[keyv])
			values += "('[keyv]','[cheevo]',1, '[medal_data[keyv][cheevo]]')"
		for(var/score in scores_data[keyv])
			values += "('[keyv]','[score]',[scores_data[keyv][score]],now())"
		if(values.len)
			var/list/keyline = list("INSERT INTO [ach](ckey,achievement_key,value,last_updated) VALUES")
			keyline += values.Join(",")
			keyline += ";"
			outfile << keyline.Join()
		i++
	outfile << "END"
