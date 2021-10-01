///Datum that handles
/datum/achievement_data
	///Ckey of this achievement data's owner
	var/key
	///Up to date list of all achievements and their info.
	var/data = list()
	///Original status of achievement.
	var/original_cached_data = list()
	///All icons for the UI of achievements
	var/list/AchievementIcons = null
	///Have we done our set-up yet?
	var/initialized = FALSE

/datum/achievement_data/New(key)
	src.key = key
	if(SSachievements.initialized && !initialized)
		InitializeData()

/datum/achievement_data/proc/InitializeData()
	initialized = TRUE
	load_all_achievements() //So we know which achievements we have unlocked so far.

	var/datum/asset/spritesheet/simple/assets = get_asset_datum(/datum/asset/spritesheet/simple/achievements)
	AchievementIcons = list()
	for(var/achievement_type in SSachievements.achievements)
		var/datum/award/achievement = SSachievements.achievements[achievement_type]
		var/list/SL = list()
		SL["htmltag"] = assets.icon_tag(achievement.icon)
		AchievementIcons[achievement.name] += list(SL)

///Saves any out-of-date achievements to the hub.
/datum/achievement_data/proc/save()
	for(var/T in data)
		var/datum/award/A = SSachievements.awards[T]

		if(data[T] != original_cached_data[T])//If our data from before is not the same as now, save it to the hub. This check prevents unnecesary polling.
			A.save(key,data[T])

///Loads data for all achievements to the caches.
/datum/achievement_data/proc/load_all()
	for(var/T in subtypesof(/datum/award))
		get_data(T)

/datum/achievement_data/proc/load_all_achievements()
	set waitfor = FALSE
	for(var/T in subtypesof(/datum/award/achievement))
		get_data(T)

///Gets the data for a specific achievement and caches it
/datum/achievement_data/proc/get_data(achievement_type)
	var/datum/award/A = SSachievements.awards[achievement_type]
	if(!A.name)
		return FALSE
	if(!data[achievement_type])
		data[achievement_type] = A.load(key)
		original_cached_data[achievement_type] = data[achievement_type]

///Unlocks an achievement of a specific type.
/datum/achievement_data/proc/unlock(achievement_type, mob/user)
	var/datum/award/A = SSachievements.awards[achievement_type]
	get_data(achievement_type) //Get the current status first
	if(istype(A, /datum/award/achievement))
		data[achievement_type] = TRUE
		A.on_unlock(user) //Only on default achievement, as scores keep going up.
	else if(istype(A, /datum/award/score))
		data[achievement_type] += 1

///Getter for the status/score of an achievement
/datum/achievement_data/proc/get_achievement_status(achievement_type)
	return data[achievement_type]

///Resets an achievement to default values.
/datum/achievement_data/proc/reset(achievement_type)
	var/datum/award/A = SSachievements.awards[achievement_type]
	get_data(achievement_type)
	if(istype(A, /datum/award/achievement))
		data[achievement_type] = FALSE
	else if(istype(A, /datum/award/score))
		data[achievement_type] = 0

/datum/achievement_data/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/simple/achievements),
	)

/datum/achievement_data/ui_state(mob/user)
	return GLOB.always_state

/datum/achievement_data/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Achievements")
		ui.open()

/datum/achievement_data/ui_data(mob/user)
	var/ret_data = list() // screw standards (qustinnus you must rename src.data ok)
	ret_data["categories"] = list("Bosses", "Jobs", "Misc", "Mafia", "Scores")
	ret_data["achievements"] = list()
	ret_data["user_key"] = user.ckey

	var/datum/asset/spritesheet/simple/assets = get_asset_datum(/datum/asset/spritesheet/simple/achievements)
	//This should be split into static data later
	for(var/achievement_type in SSachievements.awards)
		if(!SSachievements.awards[achievement_type].name) //No name? we a subtype.
			continue
		if(isnull(data[achievement_type])) //We're still loading
			continue
		var/list/this = list(
			"name" = SSachievements.awards[achievement_type].name,
			"desc" = SSachievements.awards[achievement_type].desc,
			"category" = SSachievements.awards[achievement_type].category,
			"icon_class" = assets.icon_class_name(SSachievements.awards[achievement_type].icon),
			"value" = data[achievement_type],
			"score" = ispath(achievement_type,/datum/award/score)
			)
		ret_data["achievements"] += list(this)

	return ret_data

/datum/achievement_data/ui_static_data(mob/user)
	. = ..()
	.["highscore"] = list()
	for(var/score in SSachievements.scores)
		var/datum/award/score/S = SSachievements.scores[score]
		if(!S.name || !S.track_high_scores || !S.high_scores.len)
			continue
		.["highscore"] += list(list("name" = S.name,"scores" = S.high_scores))

/client/verb/checkachievements()
	set category = "OOC"
	set name = "Check achievements"
	set desc = "See all of your achievements!"

	player_details.achievements.ui_interact(usr)
