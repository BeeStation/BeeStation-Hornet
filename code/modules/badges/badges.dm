/*

Loads all badges from the badge.json file.
Format should be
rank|icon
Where:
Rank - The name of the admin rank
Icon - The name of the icon state in the badges.dmi file

Special ranks:
- Donator: Matches clients in the donator list
- Mentor: Matches clients in the mentor list

*/

//Global list of badges
GLOBAL_LIST_EMPTY(badge_data)

/client/var/list/cached_badges = null

//Loads the badge ranks
/proc/load_badge_ranks()
	//No badges
	if(!CONFIG_GET(flag/badges))
		return
	//Load and parse data
	GLOB.badge_data = json_decode(rustg_file_read("[global.config.directory]/badges.json"))
	//Associate badges with admin ranks
	for(var/datum/admin_rank/rank as() in GLOB.admin_ranks)
		rank.badge_icon = GLOB.badge_data[rank.name]
	//Yay
	log_game("[LAZYLEN(GLOB.badge_data)] badges loaded successfully.")
	//Reset everyones badges so they get reloaded.
	for(var/client/C as() in GLOB.clients)
		C.reset_badges()

//Gets the badges attached to a client.
/client/proc/get_badges()
	//No badges
	if(!CONFIG_GET(flag/badges))
		if(key_is_external && istype(external_method))
			return list(external_method.get_badge_id())
		return
	//Send cached badges
	if(islist(cached_badges))
		return cached_badges
	var/list/badges = list()
	//Add the holder rank
	if(holder)
		//No badges when deadminned / fakeminned
		if(holder.deadmined || holder.fakekey)
			cached_badges = list()
			return list()
		//Admin badge otherwise
		if(holder?.rank?.badge_icon)
			badges += holder.rank.badge_icon
	//Add the mentor rank
	else
		if(mentor_datum && GLOB.badge_data["Mentor"])
			badges += GLOB.badge_data["Mentor"]
	//Add the donator rank
	if(IS_PATRON(ckey) && GLOB.badge_data["Donator"])
		badges += GLOB.badge_data["Donator"]
	//Add external auth tag
	if(key_is_external && istype(external_method))
		badges += external_method.get_badge_id()
	cached_badges = badges
	return badges

/client/proc/reset_badges()
	cached_badges = null

/proc/badge_parse(badges)
	if(!LAZYLEN(badges))
		return ""

	var/output = "<font style='vertical-align: -3px;'>"
	var/first_badge = TRUE

	if(!CONFIG_GET(flag/badges))
		if(!CONFIG_GET(flag/enable_guest_external_auth))
			return ""
		for(var/method_id in GLOB.login_methods)
			var/datum/external_login_method/method = GLOB.login_methods[method_id]
			if(!istype(method))
				continue
			var/badge_id = method.get_badge_id()
			if(badge_id in badges)
				// This is a must
				return "[output]<span class='chat16x16 badge-badge_[badge_id]'></span></font> "
		return ""

	for(var/badge in badges)
		var/datum/asset/spritesheet_batched/sheet = get_asset_datum(/datum/asset/spritesheet_batched/chat)
		var/tag = sheet.icon_tag("badge-badge_[badge]")
		if(tag)
			if(first_badge)
				output = "[output][tag]"
				first_badge = FALSE
			else
				output = "[output] [tag]"

	return "[output]</font> "
