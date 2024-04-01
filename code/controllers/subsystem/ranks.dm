/// What rank do you start at?
#define INITIAL_RANK 1000
/// How many rounds you need to play before you can see your rank
#define GAMES_REQUIRED 3
/// Max rank change
#define MAX_RANK_CHANGE 400

/**
 * Ranking algorithm.
 * Ranks are split between each role, so for every role you play
 * you will have a different rank. Your final rank is weighted based on
 * a weighted average of your ranks depending on how much you played that
 * role.
 */
SUBSYSTEM_DEF(ranks)
	name = "Ranks"
	wait = 1 SECONDS
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_RANKS
	var/list/needs_rank = list()
	var/list/assoc_ranks

/datum/controller/subsystem/ranks/vv_edit_var(var_name, var_value)
	if (var_name == NAMEOF(src, assoc_ranks))
		message_admins("[key_name_admin(usr)] IS TRYING TO CHEAT THE RANK SYSTEM.")
		return
	. = ..()

/datum/controller/subsystem/ranks/Initialize(start_timeofday)
	// Since this is temporary, I am using a json file and not fucking up the database
	assoc_ranks = json_decode(file2text("data/ranks.json") || "{}")
	if (!islist(assoc_ranks))
		assoc_ranks = list()
	for (var/client/desperate in needs_rank)
		var/image/rank_image = SSranks.get_rank_icon(desperate.ckey)
		rank_image.loc = SStitle.splash_turf
		rank_image.transform = matrix(
			5, 0, (((16 / 2) * 32)),
			0, 5, (((14 / 2) * 32))
		)
		desperate.images += rank_image
	return ..()

/datum/controller/subsystem/ranks/proc/update_ranks(popcount)
	if (IsAdminAdvancedProcCall())
		message_admins("For fucks sake, stop pissing about with my rank system")
		return
	// Calculate the survival rate of the crew
	var/total_players = GLOB.joined_player_list.len
	if (total_players == 0)
		return
	var/expected_survival = popcount[POPCOUNT_SURVIVORS] + popcount[POPCOUNT_ESCAPEES] / (total_players * 2)
	// Ckey to mind
	var/list/ckey_to_mind = list()
	for (var/datum/mind/mind in SSticker.minds)
		if (!mind.key)
			return
		ckey_to_mind[ckey(mind.key)] = mind
	// Update the rankings for all players based on their survival rating
	// Who cares about nuance such as being a nukie, am I right it'll probably average out over a number of rounds?
	// If you want to account for individual combat, then calculate the elo of items using blackbox combat stats
	// and weight them into the expected win condition equation (How much skill matters compared to item is up to you to find out)
	for (var/joiner_ckey in GLOB.joined_player_list)
		var/datum/mind/mind = ckey_to_mind[ckey(joiner_ckey)]
		// 0.5 for stranded, 1 for escaped, 0 for death
		var/outcome = (mind?.current && mind.current.stat < DEAD) ? (istype(get_area(mind.current), /area/shuttle) ? 1 : 0.5) : 0
		// Leaving counts as dying
		var/datum/player_rank/rank = get_ranks(ckey(joiner_ckey))
		var/new_elo = elo_adjust(rank.crew_rank, MAX_RANK_CHANGE, outcome, expected_survival)
		update_rank(ckey(joiner_ckey), new_elo)
	// Save to file
	text2file(json_encode(assoc_ranks), "data/ranks.json")

/datum/controller/subsystem/ranks/proc/get_ranks(ckey)
	RETURN_TYPE(/datum/player_rank)
	if (!assoc_ranks.Find(ckey))
		assoc_ranks[ckey] = list(
			"crew_rank" = INITIAL_RANK,
			"crew_count" = 0
		)
	var/list/player_rank = assoc_ranks[ckey]
	return new /datum/player_rank(player_rank["crew_rank"], player_rank["crew_count"])

/datum/controller/subsystem/ranks/proc/update_rank(ckey, new_rank)
	if (IsAdminAdvancedProcCall())
		message_admins("For fucks sake, stop pissing about with my rank system")
		return
	if (!assoc_ranks[ckey])
		assoc_ranks[ckey] = list(
			"crew_rank" = new_rank,
			"crew_count" = 1
		)
		return
	assoc_ranks[ckey]["crew_rank"] = new_rank
	assoc_ranks[ckey]["crew_count"] = assoc_ranks[ckey]["crew_count"] + 1

/datum/controller/subsystem/ranks/proc/get_rank_icon(ckey)
	RETURN_TYPE(/image)
	var/datum/player_rank/prank = get_ranks(ckey(ckey))
	var/datum/rank/rank = elo_to_rank(prank.crew_rank)
	if (prank.crew_count < GAMES_REQUIRED)
		rank = new /datum/rank("Unranked", "#666666", 0, "")
	var/image/image = get_rank_icon_from_rank(rank)
	image.maptext = MAPTEXT(rank.name)
	image.maptext_width = 96
	image.maptext_height = 32
	image.maptext_y = -16
	return image

/datum/controller/subsystem/ranks/proc/get_rank_icon_from_rank(datum/rank/rank)
	RETURN_TYPE(/image)
	var/image/image = image('icons/effects/ranks.dmi', null, "base", 999999)
	image.plane = SPLASHSCREEN_PLANE
	var/mutable_appearance/colour = mutable_appearance('icons/effects/ranks.dmi', "colour")
	colour.color = rank.colour
	image.overlays += colour
	image.overlays += icon('icons/effects/ranks.dmi', "highlight")
	image.overlays += icon('icons/effects/ranks.dmi', "[rank.number]")
	image.appearance_flags |= PIXEL_SCALE
	return image

/proc/elo_expected(your_rank, enemy_rank, sensitivity = 400)
	return 1 / (1 + 10 ** ((your_rank - enemy_rank) / sensitivity))

/proc/elo_adjust(current_elo, max_change, outcome, expected)
	return current_elo + max_change * (outcome - expected)

/proc/elo_to_badge(elo)
	var/datum/rank/rank = elo_to_rank(elo)
	return rank.badge

/proc/elo_to_rank(elo)
	switch (elo)
		if (-INFINITY to 100)
			return new /datum/rank("Glass IV","#7d9493", 4, "glass4")
		if (100 to 200)
			return new /datum/rank("Glass III", "#7d9493", 3, "glass3")
		if (200 to 300)
			return new /datum/rank("Glass II", "#7d9493", 2, "glass2")
		if (300 to 400)
			return new /datum/rank("Glass I", "#7d9493", 1, "glass1")
		if (400 to 500)
			return new /datum/rank("Iron IV", "#bb987c", 4, "iron4")
		if (500 to 600)
			return new /datum/rank("Iron III", "#bb987c", 3, "iron3")
		if (600 to 700)
			return new /datum/rank("Iron II", "#bb987c", 2, "iron2")
		if (700 to 800)
			return new /datum/rank("Iron I", "#bb987c", 1, "iron1")
		if (900 to 1000)
			return new /datum/rank("Silver IV", "#d0c7b9", 4, "silver4")
		if (1000 to 1100)
			return new /datum/rank("Silver III", "#d0c7b9", 3, "silver3")
		if (1100 to 1200)
			return new /datum/rank("Silver II", "#d0c7b9", 2, "silver2")
		if (1200 to 1300)
			return new /datum/rank("Silver I", "#d0c7b9", 1, "silver1")
		if (1300 to 1400)
			return new /datum/rank("Gold IV", "#ffcd6f", 4, "gold4")
		if (1400 to 1500)
			return new /datum/rank("Gold III", "#ffcd6f", 3, "gold3")
		if (1500 to 1600)
			return new /datum/rank("Gold II", "#ffcd6f", 2, "gold2")
		if (1600 to 1700)
			return new /datum/rank("Gold I", "#ffcd6f", 1, "gold1")
		if (1700 to 1800)
			return new /datum/rank("Uranium IV", "#55f15c", 4, "uranium4")
		if (1800 to 1900)
			return new /datum/rank("Uranium III", "#55f15c", 3, "uranium3")
		if (1900 to 2000)
			return new /datum/rank("Uranium II", "#55f15c", 2, "uranium2")
		if (2000 to 2100)
			return new /datum/rank("Uranium I", "#55f15c", 1, "uranium1")
		if (2100 to 2200)
			return new /datum/rank("Diamond III", "#89ffe5", 3, "diamond3")
		if (2200 to 2300)
			return new /datum/rank("Diamond II", "#89ffe5", 2, "diamond2")
		if (2300 to 2400)
			return new /datum/rank("Diamond I", "#89ffe5", 1, "diamond1")
		if (2400 to INFINITY)
			return new /datum/rank("Bluespace", "#2127bc", 1, "bluespace")

/datum/rank
	var/name
	var/colour
	var/number
	var/badge

/datum/rank/New(a, b, c, d)
	name = a
	colour = b
	number = c
	badge = d

/datum/player_rank
	// Rank delta depends on survival
	// Expected win rate is calculate based off of the survival rating
	// of the crew. If you are the only survivor, you get a lot of rank points
	// but if survives and only you die, you lose a lot of rank points.
	var/crew_rank
	var/crew_count

/datum/player_rank/New(rank, count)
	crew_rank = rank
	crew_count = count
	return ..()
