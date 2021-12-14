//Migration script generation
//Fire to generate shop_migration.sql script to use.

/mob/verb/generate_metacoin_shop_migration_script()
	set name = "Generate Metacoin Shop Migration Script"

	var/ach = "metacoin_item_purchases" //IMPORTANT : ADD PREFIX HERE IF YOU'RE USING PREFIXED SCHEMA

	var/outfile = file("shop_migration.sql")
	fdel(outfile)
	outfile << "BEGIN;"

	var/path = "data/player_saves/"
	var/list/ckeys = list()
	var/list/ckey_prefpath = list()
	var/list/directory = flist(path)
	for(var/subdir in directory)
		var/list/subdirs = flist("data/player_saves/[subdir]")
		for(var/player in subdirs)
			var/key = copytext(player, 1, length(player))
			var/fullpath = "data/player_saves/[subdir][player]preferences.sav"
			if(!fexists(fullpath))
				world.log << "Failed to find [fullpath] for [key]"
				continue
			ckeys += key
			ckey_prefpath[key] = fullpath

	var/skipped_old = 0
	var/skipped_nogear = 0
	var/skipped_noload = 0
	var/passed = 0
	for(var/key in ckeys)
		var/savefile/S = new /savefile(ckey_prefpath[key])
		if(!S)
			world.log << "Failed to load savefile for [key]"
			skipped_noload += 1
			continue
		S.cd = "/"
		var/savefile_version
		S["version"] >> savefile_version
		if(savefile_version < 32)
			world.log << "Skipping [key] because savefile version is too old ([savefile_version], expected 32 or greater)"
			skipped_nogear += 1
			continue
		var/list/purchased_gear = list()
		S["purchased_gear"] >> purchased_gear
		if(!length(purchased_gear))
			world.log << "Skipping [key] because no purchased gear"
			skipped_nogear++
			continue

		var/list/values = list()
		for(var/gear in purchased_gear)
			values += "('[ckey(key)]','[gear]',1)"
		if(length(values))
			var/list/keyline = list("INSERT INTO [ach](ckey,item_id,amount) VALUES")
			keyline += values.Join(",")
			keyline += ";"
			outfile << keyline.Join()
			passed++
		else
			skipped_nogear += 1
	outfile << "END"

	world.log << "Converted [passed] of [length(ckeys)] keys successfully, failed to load [skipped_noload] keys, skipped [skipped_old] due to being too old, skipped [skipped_nogear] due to having no gear."
