// How much "space" we give the edge of the map
GLOBAL_LIST_INIT(potentialRandomZlevels, generateMapList(filename = "awaymissionconfig.txt"))

/proc/createRandomZlevel()
	if(GLOB.awaydestinations.len)	//crude, but it saves another var!
		return

	if(GLOB.potentialRandomZlevels?.len)
		to_chat(world, span_boldannounce("Loading away mission..."))
		var/map = pick(GLOB.potentialRandomZlevels)
		load_new_z_level(map, "Away Mission")
		to_chat(world, span_boldannounce("Away mission loaded."))

/obj/effect/landmark/awaystart
	name = "away mission spawn"
	desc = "Randomly picked away mission spawn points."

/obj/effect/landmark/awaystart/New()
	GLOB.awaydestinations += src
	..()

/obj/effect/landmark/awaystart/Destroy()
	GLOB.awaydestinations -= src
	return ..()

/proc/generateMapList(filename)
	filename = "[global.config.directory]/[SANITIZE_FILENAME(filename)]"
	. = list()
	var/list/Lines = world.file2list(filename)

	if(!length(Lines))
		return
	for (var/t in Lines)
		if (!t)
			continue

		t = trim(t)
		if (length(t) == 0)
			continue
		else if (t[1] == "#")
			continue

		var/pos = findtext(t, " ")
		var/name = null

		if (pos)
			name = LOWER_TEXT(copytext(t, 1, pos))

		else
			name = LOWER_TEXT(t)

		if (!name)
			continue

		. += t
