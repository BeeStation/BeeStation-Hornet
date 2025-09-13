/datum/map_template/shuttle
	name = "Base Shuttle Template"
	var/prefix = "_maps/shuttles/"
	var/suffix
	var/port_id
	var/shuttle_id

	var/description
	var/prerequisites
	var/admin_notes

	var/credit_cost = INFINITY
	var/can_be_bought = TRUE
	var/illegal_shuttle = FALSE	//makes you able to buy the shuttle at a hacked/emagged comms console even if can_be_bought is FALSE

	/// How dangerous this shuttle is, used for alerting foolish captains not to buy it (or traitors to buy it)
	var/danger_level = SHUTTLE_DANGER_SAFE

	var/list/movement_force // If set, overrides default movement_force on shuttle
	var/untowable = FALSE // If set, the shuttle becomes untowable

	var/port_x_offset
	var/port_y_offset
	var/extra_desc = ""

/datum/map_template/shuttle/proc/prerequisites_met()
	return TRUE

/datum/map_template/shuttle/New(path = null, rename = null, cache = FALSE, admin_load = null)
	if(admin_load)//This data must be populated for the system to not shit itself apparently
		suffix = admin_load
		port_id = "custom"
		can_be_bought = FALSE
	shuttle_id = "[port_id]_[suffix]"
	if(!admin_load)
		mappath = "[prefix][port_id]/[shuttle_id].dmm"
	. = ..()

/datum/map_template/shuttle/preload_size(path, cache)
	. = ..(path, TRUE) // Done this way because we still want to know if someone actualy wanted to cache the map
	if(!cached_map)
		return

	discover_port_offset()

	if(!cache)
		cached_map = null

/datum/map_template/shuttle/proc/discover_port_offset()
	var/key
	var/list/models = cached_map.grid_models
	for(key in models)
		if(findtext(models[key], "[/obj/docking_port/mobile]")) // Yay compile time checks
			break // This works by assuming there will ever only be one mobile dock in a template at most

	for(var/i in cached_map.gridSets)
		var/datum/grid_set/gset = i
		var/ycrd = gset.ycrd
		for(var/line in gset.gridLines)
			var/xcrd = gset.xcrd
			for(var/j in 1 to length(line) step cached_map.key_len)
				if(key == copytext(line, j, j + cached_map.key_len))
					port_x_offset = xcrd
					port_y_offset = ycrd
					return
				++xcrd
			--ycrd

/datum/map_template/shuttle/load(turf/T, centered, init_atmos, finalize = TRUE, register = TRUE)
	if(centered)
		T = locate(T.x - round(width/2) , T.y - round(height/2) , T.z)
		centered = FALSE
	//This assumes a non-multi-z shuttle. If you are making a multi-z shuttle, you'll need to change the z bounds for this block. Good luck.
	var/list/turfs = block(locate(max(T.x, 1), max(T.y, 1),  T.z),
							locate(min(T.x+width-1, world.maxx), min(T.y+height-1, world.maxy), T.z))
	for(var/turf/turf in turfs)
		turfs[turf] = turf.loc
	. = ..(T, centered, init_atmos, finalize, register, turfs)

/datum/map_template/shuttle/on_placement_completed(datum/async_map_generator/map_place/map_gen, turf/T, init_atmos, datum/parsed_map/parsed, finalize = TRUE, register = TRUE, list/turfs)
	. = ..(map_gen, T, TRUE, parsed, FALSE)
	if(!.)
		log_runtime("Failed to load shuttle [map_gen.get_name()].")
		return

	var/obj/docking_port/mobile/my_port
	for(var/turf/place in turfs)
		if(place.loc == turfs[place] || !istype(place.loc, /area/shuttle)) //If not part of the shuttle, ignore it
			turfs -= place
			continue
		for(var/obj/docking_port/mobile/port in place)
			my_port = port
			port.untowable = untowable
			if(register)
				port.register()
			if(isnull(port_x_offset))
				continue
			switch(port.dir) // Yeah this looks a little ugly but mappers had to do this in their head before
				if(NORTH)
					port.width = width
					port.height = height
					port.dwidth = port_x_offset - 1
					port.dheight = port_y_offset - 1
				if(EAST)
					port.width = height
					port.height = width
					port.dwidth = height - port_y_offset
					port.dheight = port_x_offset - 1
				if(SOUTH)
					port.width = width
					port.height = height
					port.dwidth = width - port_x_offset
					port.dheight = height - port_y_offset
				if(WEST)
					port.width = height
					port.height = width
					port.dwidth = port_y_offset - 1
					port.dheight = width - port_x_offset

	for(var/turf/shuttle_turf in turfs)
		var/area/shuttle/turf_loc = turfs[shuttle_turf]
		my_port.underlying_turf_area[shuttle_turf] = turf_loc
		if(istype(turf_loc) && turf_loc.mobile_port)
			turf_loc.mobile_port.towed_shuttles |= my_port

		//Getting the amount of baseturfs added
		var/z_offset = shuttle_turf.z - T.z
		var/y_offset = shuttle_turf.y - T.y
		var/x_offset = shuttle_turf.x - T.x
		//retrieving our cache
		var/line
		var/list/cache
		for(var/datum/grid_set/gset as() in cached_map.gridSets)
			if(gset.zcrd - 1 != z_offset) //Not our Z-level
				continue
			if((gset.ycrd - 1 < y_offset) || (gset.ycrd - length(gset.gridLines) > y_offset)) //Our y coord isn't in the bounds
				continue
			line = gset.gridLines[length(gset.gridLines) - y_offset] //Y goes from top to bottom
			if((gset.xcrd - 1 < x_offset) || (gset.xcrd + (length(line)/cached_map.key_len) - 2 > x_offset)) ///Our x coord isn't in the bounds
				continue
			cache = map_gen.placing_template.modelCache[copytext(line, 1+((x_offset-gset.xcrd+1)*cached_map.key_len), 1+((x_offset-gset.xcrd+2)*cached_map.key_len))]
			break
		if(!cache) //Our turf isn't in the cached map, something went very wrong
			continue

		//How many baseturfs were added to this turf by the mapload
		var/baseturf_length
		var/turf/P //Typecasted for the initial call
		for(P as() in cache[1])
			if(ispath(P, /turf))
				var/list/added_baseturfs = GLOB.created_baseturf_lists[initial(P.baseturfs)] //We can assume that our turf type will be included here because it was just generated in the mapload.
				if(!islist(added_baseturfs))
					added_baseturfs = list(added_baseturfs)
				baseturf_length = length(added_baseturfs - GLOB.blacklisted_automated_baseturfs)
				break
		if(ispath(P, /turf/template_noop)) //No turf was added, don't add a skipover
			continue

		if(!islist(shuttle_turf.baseturfs))
			shuttle_turf.baseturfs = list(shuttle_turf.baseturfs)

		var/list/sanity = shuttle_turf.baseturfs.Copy()
		sanity.Insert(shuttle_turf.baseturfs.len + 1 - baseturf_length, /turf/baseturf_skipover/shuttle)
		shuttle_turf.baseturfs = baseturfs_string_list(sanity, shuttle_turf)

	//If this is a superfunction call, we don't want to initialize atoms here, let the subfunction handle that
	if(finalize)
		maps_loading --

		//initialize things that are normally initialized after map load
		initTemplateBounds(., init_atmos)

		log_game("[name] loaded at [T.x],[T.y],[T.z]")


//Whatever special stuff you want
/datum/map_template/shuttle/proc/post_load(obj/docking_port/mobile/M)
	if(movement_force)
		M.movement_force = movement_force.Copy()

/datum/map_template/shuttle/emergency
	port_id = "emergency"
	name = "Base Shuttle Template (Emergency)"
	untowable = TRUE

/datum/map_template/shuttle/cargo
	port_id = "cargo"
	name = "Base Shuttle Template (Cargo)"
	can_be_bought = FALSE

/datum/map_template/shuttle/ferry
	port_id = "ferry"
	name = "Base Shuttle Template (Ferry)"

/datum/map_template/shuttle/whiteship
	port_id = "whiteship"

/datum/map_template/shuttle/labour
	port_id = "labour"
	can_be_bought = FALSE

/datum/map_template/shuttle/mining
	port_id = "mining"
	can_be_bought = FALSE

/datum/map_template/shuttle/arrival
	port_id = "arrival"
	can_be_bought = FALSE
	untowable = TRUE

/datum/map_template/shuttle/infiltrator
	port_id = "infiltrator"
	can_be_bought = FALSE

/datum/map_template/shuttle/aux_base
	port_id = "aux_base"
	can_be_bought = FALSE

/datum/map_template/shuttle/escape_pod
	port_id = "escape_pod"
	can_be_bought = FALSE

/datum/map_template/shuttle/assault_pod
	port_id = "assault_pod"
	can_be_bought = FALSE

/datum/map_template/shuttle/pirate
	port_id = "pirate"
	can_be_bought = FALSE

/datum/map_template/shuttle/hunter
	port_id = "hunter"
	can_be_bought = FALSE

/datum/map_template/shuttle/ruin //For random shuttles in ruins
	port_id = "ruin"
	can_be_bought = FALSE

/datum/map_template/shuttle/snowdin
	port_id = "snowdin"
	can_be_bought = FALSE

// Shuttles start here:

/datum/map_template/shuttle/emergency/backup
	suffix = "backup"
	name = "Backup Shuttle"
	can_be_bought = FALSE

/datum/map_template/shuttle/emergency/construction
	suffix = "construction"
	name = "Build your own shuttle kit"
	description = "For the enterprising shuttle engineer! The chassis will dock upon purchase, but launch will have to be authorized as usual via shuttle call. Comes stocked with construction materials."
	admin_notes = "No brig, no medical facilities, no shuttle console."
	credit_cost = -2500

/datum/map_template/shuttle/emergency/airless/prerequisites_met()
	// first 10 minutes only
	return world.time - SSticker.round_start_time < 6000

/datum/map_template/shuttle/emergency/airless/post_load()
	. = ..()
	//enable buying engines from cargo
	var/datum/supply_pack/P = SSsupply.supply_packs[/datum/supply_pack/engineering/shuttle_engine]
	P.special_enabled = TRUE


/datum/map_template/shuttle/emergency/asteroid
	suffix = "asteroid"
	name = "Asteroid Station Emergency Shuttle"
	description = "A respectable mid-sized shuttle that first saw service shuttling Nanotrasen crew to and from their asteroid belt embedded facilities."
	credit_cost = 3000

/datum/map_template/shuttle/emergency/bar
	suffix = "bar"
	name = "The Emergency Escape Bar"
	description = "Features include sentient bar staff (a Bardrone and a Barmaid), bathroom, a quality lounge for the heads, and a large gathering table."
	admin_notes = "Bardrone and Barmaid are GODMODE, will be automatically sentienced by the fun balloon at 60 seconds before arrival. \
	Has medical facilities."
	credit_cost = 5000

/datum/map_template/shuttle/emergency/theatre
	suffix = "theatre"
	name = "The Emergency Fancy Theatre"
	description = "Put on your best show with the emergency theatre on the couple minutes it takes you to get to CentCom! Includes a medbay, cockpit, brig and tons of fancy stuff for the crew"
	admin_notes = "Theatre with seats, brig, cockpit and medbay included, for shows or improvisation by the crewmembers"
	credit_cost = 5000

/datum/map_template/shuttle/emergency/pod
	suffix = "pod"
	name = "Emergency Pods"
	description = "We did not expect an evacuation this quickly. All we have available is two escape pods."
	admin_notes = "For player punishment."
	can_be_bought = FALSE

/datum/map_template/shuttle/emergency/russiafightpit
	suffix = "russiafightpit"
	name = "Mother Russia Bleeds"
	description = "Dis is a high-quality shuttle, da. Many seats, lots of space, all equipment! Even includes entertainment! Such as lots to drink, and a fighting arena for drunk crew to have fun! If arena not fun enough, simply press button of releasing bears. Do not worry, bears trained not to break out of fighting pit, so totally safe so long as nobody stupid or drunk enough to leave door open. Try not to let asimov babycons ruin fun!"
	admin_notes = "Includes a small variety of weapons. And bears. Only captain-access can release the bears. Bears won't smash the windows themselves, but they can escape if someone lets them."
	credit_cost = 5000 // While the shuttle is rusted and poorly maintained, trained bears are costly.
	danger_level = SHUTTLE_DANGER_SUBPAR

/datum/map_template/shuttle/emergency/meteor
	suffix = "meteor"
	name = "Asteroid With Engines Strapped To It"
	description = "A hollowed out asteroid with engines strapped to it, the hollowing procedure makes it very difficult to hijack but is very expensive. Due to its size and difficulty in steering it, this shuttle may damage the docking area."
	admin_notes = "This shuttle will likely crush escape, killing anyone there."
	credit_cost = 15000
	movement_force = list("KNOCKDOWN" = 3, "THROW" = 2)
	danger_level = SHUTTLE_DANGER_HIGH

/datum/map_template/shuttle/emergency/luxury
	suffix = "luxury"
	name = "Luxury Shuttle"
	description = "A luxurious golden shuttle complete with an indoor swimming pool. Each crewmember wishing to board must bring 500 credits, payable in cash and mineral coin."
	extra_desc = "This shuttle costs 500 credits to board."
	admin_notes = "Due to the limited space for non paying crew, this shuttle may cause a riot."
	credit_cost = 10000
	danger_level = SHUTTLE_DANGER_SUBPAR

/datum/map_template/shuttle/emergency/medbay
	suffix = "medbay"
	name = "Medical Emergencies Escape Shuttle"
	description = "The M.E.E.S. is a shuttle built for medical care, featuring a large, well-equipped medical center to tend to many crew members during the trip to Central Command."
	credit_cost = 10000

/datum/map_template/shuttle/emergency/funnypod
	suffix = "funnypod"
	name = "Comically Large Escape Pod"
	description = "A bunch of scrapped escape pods glued together."
	admin_notes = "This shuttle will 100% cause mayhem, as the space avaiable is 1x23 and anyone can open the door in the end."
	credit_cost = 2000
	danger_level = SHUTTLE_DANGER_SUBPAR

/datum/map_template/shuttle/emergency/discoinferno
	suffix = "discoinferno"
	name = "Disco Inferno"
	description = "The glorious results of centuries of plasma research done by Nanotrasen employees. This is the reason why you are here. Get on and dance like you're on fire, burn baby burn!"
	admin_notes = "Flaming hot. The main area has a dance machine as well as plasma floor tiles that will be ignited by players every single time."
	credit_cost = 10000
	danger_level = SHUTTLE_DANGER_HIGH

/datum/map_template/shuttle/emergency/arena
	suffix = "arena"
	name = "The Arena"
	description = "The crew must pass through an otherworldy arena to board this shuttle. Expect massive casualties. The source of the Bloody Signal must be tracked down and eliminated to unlock this shuttle."
	admin_notes = "RIP AND TEAR. Creates an entire internal Z-level where you have to kill each other in a massive battle royale to get to the actual shuttle."
	credit_cost = 10000
	danger_level = SHUTTLE_DANGER_HIGH
	/// Whether the arena z-level has been created
	var/arena_loaded = FALSE

/datum/map_template/shuttle/emergency/arena/prerequisites_met()
	if(SHUTTLE_UNLOCK_BUBBLEGUM in SSshuttle.shuttle_purchase_requirements_met)
		return TRUE
	return FALSE

/datum/map_template/shuttle/emergency/arena/post_load(obj/docking_port/mobile/M)
	. = ..()
	if(!arena_loaded)
		arena_loaded = TRUE
		var/datum/map_template/arena/arena_template = new()
		arena_template.load_new_z()

/datum/map_template/arena
	name = "The Arena"
	mappath = "_maps/templates/the_arena.dmm"

/datum/map_template/shuttle/emergency/birdboat
	suffix = "birdboat"
	name = "Birdboat Station Emergency Shuttle"
	description = "Though a little on the small side, this shuttle is feature complete, which is more than can be said for the pattern of station it was commissioned for."
	credit_cost = 1000

/datum/map_template/shuttle/emergency/shelter
	suffix = "shelter"
	name = "BSP Collapsable Emergency Shuttle"
	description = "A new product by a Nanotrasen subsidary, designed to be quick to construct and employ, with the amenities of a small emergency shuttle, including sleepers. Luckily, the shuttle is indeed deployed faster. Un-luckily, that time is supplemented by construction time, so it won't make the transit any faster."
	credit_cost = 2500

/datum/map_template/shuttle/emergency/box
	suffix = "box"
	name = "Box Station Emergency Shuttle"
	credit_cost = 2000
	description = "The gold standard in emergency exfiltration, this tried and true design is equipped with everything the crew needs for a safe flight home."

/datum/map_template/shuttle/emergency/card
	suffix = "card"
	name = "Card Station Emergency Shuttle"
	credit_cost = 4000
	description = "A standard pattern exfiltration shuttle, equipped with a medbay, brig and an aft engineering section. It's upgraded engines ensure the smoothest and quickest ride."

/datum/map_template/shuttle/emergency/clown
	suffix = "clown"
	name = "Snappop(tm)!"
	description = "Hey kids and grownups! \
	Are you bored of DULL and TEDIOUS shuttle journeys after you're evacuating for probably BORING reasons. Well then order the Snappop(tm) today! \
	We've got fun activities for everyone, an all access cockpit, and no boring security brig! Boo! Play dress up with your friends! \
	Collect all the bedsheets before your neighbour does! Check if the AI is watching you with our patent pending \"Peeping Tom AI Multitool Detector\" or PEEEEEETUR for short. \
	Have a fun ride!"
	admin_notes = "Brig is replaced by anchored greentext book surrounded by lavaland chasms, stationside door has been removed to prevent accidental dropping. No brig."
	credit_cost = 8000
	danger_level = SHUTTLE_DANGER_SUBPAR

/datum/map_template/shuttle/emergency/cramped
	suffix = "cramped"
	name = "Secure Transport Vessel 5 (STV5)"
	description = "Well, looks like CentCom only had this ship in the area, they probably weren't expecting you to need evac for a while. \
	Probably best if you don't rifle around in whatever equipment they were transporting. I hope you're friendly with your coworkers, because there is very little space in this thing.\n\
	\n\
	Contains contraband armory guns, some random stuff we found in maintenance, and potentially explosive abandoned crates!"
	admin_notes = "Due to origin as a solo piloted secure vessel, has an active GPS onboard labeled STV5. Has roughly as much space as Hi Daniel, except with explosive crates."
	danger_level = SHUTTLE_DANGER_HIGH

/datum/map_template/shuttle/emergency/meta
	suffix = "meta"
	name = "Meta Station Emergency Shuttle"
	credit_cost = 4000
	description = "A fairly standard shuttle, though larger and slightly better equipped than the Box Station variant."

/datum/map_template/shuttle/emergency/kilo
	suffix = "kilo"
	name = "Kilo Station Emergency Shuttle"
	credit_cost = 5000
	description = "A fully functional shuttle including a complete infirmary, storage facilties and regular amenities."

/datum/map_template/shuttle/emergency/corg
	suffix = "corg"
	name = "Corg Station Emergency Shuttle"
	credit_cost = 4000
	description = "A smaller shuttle with area for cargo, medical and security personnel."

/datum/map_template/shuttle/emergency/fland
	suffix = "fland"
	name = "Flandstation Wide shuttle"
	description = "It's a fat shuttle for a rather unusual station... huh..."
	admin_notes = "It's big to spawn, it may or may not collide with the surrounding stuff on other maps that don't have a massive emergency docking area."
	credit_cost = 8000

/datum/map_template/shuttle/emergency/mini
	suffix = "mini"
	name = "Ministation emergency shuttle"
	credit_cost = 1000
	description = "Despite its namesake, this shuttle is actually only slightly smaller than standard, and still complete with a brig and medbay."

/datum/map_template/shuttle/emergency/scrapheap
	suffix = "scrapheap"
	name = "Standby Evacuation Vessel \"Scrapheap Challenge\""
	credit_cost = -1000
	description = "Due to a lack of functional emergency shuttles, we bought this second hand from a scrapyard and pressed it into service. Please do not lean too heavily on the exterior windows, they are fragile."
	admin_notes = "An abomination with no functional medbay, sections missing, and some very fragile windows. Surprisingly airtight."
	movement_force = list("KNOCKDOWN" = 3, "THROW" = 2)
	danger_level = SHUTTLE_DANGER_SUBPAR

/datum/map_template/shuttle/emergency/narnar
	suffix = "narnar"
	name = "Shuttle 667"
	description = "Looks like this shuttle may have wandered into the darkness between the stars on route to the station. Let's not think too hard about where all the bodies came from."
	admin_notes = "Contains real cult ruins, mob eyeballs, and inactive constructs. Cult mobs will automatically be sentienced by fun balloon. \
	Cloning pods in 'medbay' area are showcases and nonfunctional."
	danger_level = SHUTTLE_DANGER_SUBPAR

/datum/map_template/shuttle/emergency/narnar/prerequisites_met()
	if(SHUTTLE_UNLOCK_NARNAR in SSshuttle.shuttle_purchase_requirements_met)
		return TRUE
	return FALSE

/datum/map_template/shuttle/emergency/pubby
	suffix = "pubby"
	name = "Pubby Station Emergency Shuttle"
	description = "A train but in space! Complete with a first, second class, brig and storage area."
	admin_notes = "Choo choo motherfucker!"
	credit_cost = 1000

/datum/map_template/shuttle/emergency/tiny
	suffix = "tiny"
	name = "Echo Station Emergency Shuttle"
	description = "A small emergancy escape shuttle"
	admin_notes = "A *very* small shuttle"
	credit_cost = 1000

/datum/map_template/shuttle/emergency/cere
	suffix = "cere"
	name = "Cere Station Emergency Shuttle"
	description = "The large, beefed-up version of the box-standard shuttle. Includes an expanded brig, fully stocked medbay, enhanced cargo storage with mech chargers, \
	an engine room stocked with various supplies, and a crew capacity of 80+ to top it all off. Live large, live Cere."
	admin_notes = "Seriously big, even larger than the Delta shuttle."
	credit_cost = 10000

/datum/map_template/shuttle/emergency/supermatter
	suffix = "supermatter"
	name = "Hyperfractal Gigashuttle"
	description = "\"I dunno, this seems kinda needlessly complicated.\"\n\
	\"This shuttle has very a very high safety record, according to CentCom Officer Cadet Yins.\"\n\
	\"Are you sure?\"\n\
	\"Yes, it has a safety record of N-A-N, which is apparently larger than 100%.\""
	admin_notes = "Supermatter that spawns on shuttle is special anchored 'hugbox' supermatter that cannot take damage and does not take in or emit gas. \
	Outside of admin intervention, it cannot explode. \
	It does, however, still dust anything on contact, emits high levels of radiation, and induce hallucinations in anyone looking at it without protective goggles. \
	Emitters spawn powered on, expect admin notices, they are harmless."
	credit_cost = 100000
	movement_force = list("KNOCKDOWN" = 3, "THROW" = 2)
	danger_level = SHUTTLE_DANGER_HIGH

/datum/map_template/shuttle/emergency/imfedupwiththisworld
	suffix = "imfedupwiththisworld"
	name = "Oh, Hi Daniel"
	description = "How was space work today? Oh, pretty good. We got a new space station and the company will make a lot of money. What space station? I cannot tell you; it's space confidential. \
	Aw, come space on. Why not? No, I can't. Anyway, how is your space life?"
	admin_notes = "Tiny, with a single airlock and wooden walls. What could go wrong?"
	credit_cost = -5000
	movement_force = list("KNOCKDOWN" = 3, "THROW" = 2)
	danger_level = SHUTTLE_DANGER_SUBPAR

/datum/map_template/shuttle/emergency/goon
	suffix = "goon"
	name = "NES Port"
	description = "The Nanotrasen Emergency Shuttle Port(NES Port for short) is a shuttle used at other less known Nanotrasen facilities and has a more open inside for larger crowds, but fewer onboard shuttle facilities."
	credit_cost = 500

/datum/map_template/shuttle/emergency/wabbajack
	suffix = "wabbajack"
	name = "NT Lepton Violet"
	description = "The research team based on this vessel went missing one day, and no amount of investigation could discover what happened to them. \
	The only occupants were a number of dead rodents, who appeared to have clawed each other to death. \
	Needless to say, no engineering team wanted to go near the thing, and it's only being used as an Emergency Escape Shuttle because there is literally nothing else available."
	admin_notes = "If the crew can solve the puzzle, they will wake the wabbajack statue. It will likely not end well. There's a reason it's boarded up. Maybe they should have just left it alone."
	credit_cost = 15000
	danger_level = SHUTTLE_DANGER_HIGH

/datum/map_template/shuttle/emergency/omega
	suffix = "omega"
	name = "Omegastation Emergency Shuttle"
	description = "On the smaller size with a modern design, this shuttle is for the crew who like the cosier things, while still being able to stretch their legs."
	credit_cost = 1000

/datum/map_template/shuttle/ferry/base
	suffix = "base"
	name = "transport ferry"
	description = "Standard issue Box/Metastation CentCom ferry."

/datum/map_template/shuttle/ferry/meat
	suffix = "meat"
	name = "\"meat\" ferry"
	description = "Ahoy! We got all kinds o' meat aft here. Meat from plant people, people who be dark, not in a racist way, just they're dark black. \
	Oh and lizard meat too,mighty popular that is. Definitely 100% fresh, just ask this guy here. *person on meatspike moans* See? \
	Definitely high quality meat, nothin' wrong with it, nothin' added, definitely no zombifyin' reagents!"
	admin_notes = "Meat currently contains no zombifying reagents, lizard on meatspike must be spawned in."

/datum/map_template/shuttle/ferry/standard
	suffix = "standard"
	name = "standard nanotrasen ferry"
	description = "The standard Nanotrasen ERT Ferry, comes with everything you need to assist the station!"

/datum/map_template/shuttle/ferry/lighthouse
	suffix = "lighthouse"
	name = "The Lighthouse(?)"
	description = "*static*... part of a much larger vessel, possibly military in origin. \
	The weapon markings aren't anything we've seen ...static... by almost never the same person twice, possible use of unknown storage ...static... \
	seeing ERT officers onboard, but no missions are on file for ...static...static...annoying jingle... only at The LIGHTHOUSE! \
	Fulfilling needs you didn't even know you had. We've got EVERYTHING, and something else!"
	admin_notes = "Currently larger than ferry docking port on Box, will not hit anything, but must be force docked. Trader and ERT bodyguards are not included."

/datum/map_template/shuttle/ferry/fancy
	suffix = "fancy"
	name = "fancy transport ferry"
	description = "At some point, someone upgraded the ferry to have fancier flooring... and fewer seats."

/datum/map_template/shuttle/ferry/kilo
	suffix = "kilo"
	name = "kilo transport ferry"
	description = "Standard issue CentCom Ferry for Kilo pattern stations. Includes additional equipment and rechargers."

/datum/map_template/shuttle/whiteship/box
	suffix = "box"
	name = "Hospital Ship"

/datum/map_template/shuttle/whiteship/meta
	suffix = "meta"
	name = "Salvage Ship"

/datum/map_template/shuttle/whiteship/pubby
	suffix = "pubby"
	name = "NT Personal Trader"

/datum/map_template/shuttle/whiteship/cere
	suffix = "cere"
	name = "Syndicate Probe Ship"

/datum/map_template/shuttle/whiteship/delta
	suffix = "delta"
	name = "NT Frigate"

/datum/map_template/shuttle/whiteship/pod
	suffix = "whiteship_pod"
	name = "Salvage Pod"

/datum/map_template/shuttle/cargo/box
	suffix = "box"
	name = "supply shuttle (Box)"

/datum/map_template/shuttle/cargo/kilo
	suffix = "kilo"
	name = "supply shuttle (Kilo)"

/datum/map_template/shuttle/cargo/corg
	suffix = "corg"
	name = "supply shuttle (Corg)"

/datum/map_template/shuttle/cargo/birdboat
	suffix = "birdboat"
	name = "supply shuttle (Birdboat)"

/datum/map_template/shuttle/emergency/delta
	suffix = "delta"
	name = "Delta Station Emergency Shuttle"
	description = "A large shuttle for a large station, this shuttle can comfortably fit all your overpopulation and crowding needs. Complete with all facilities plus additional equipment."
	admin_notes = "Go big or go home."
	credit_cost = 7500

/datum/map_template/shuttle/emergency/raven
	suffix = "raven"
	name = "CentCom Raven Cruiser"
	description = "The CentCom Raven Cruiser is a former high-risk salvage vessel, now repurposed into an emergency escape shuttle. \
	Once first to the scene to pick through warzones for valuable remains, it now serves as an excellent escape option for stations under heavy fire from outside forces. \
	This escape shuttle boasts shields and numerous anti-personnel turrets guarding its perimeter to fend off meteors and enemy boarding attempts."
	admin_notes = "Comes with turrets that will target anything without the neutral faction (nuke ops, xenos etc, but not pets)."
	credit_cost = 30000

/datum/map_template/shuttle/emergency/zeta
	suffix = "zeta"
	name = "Tr%nPo2r& Z3TA"
	description = "A glitch appears on your monitor, flickering in and out of the options laid before you. \
	It seems strange and alien, you may need a special technology to access the signal.."
	admin_notes = "Has an on-board experimental cloner that creates copies of its user, alien surgery tools, and a void core that provides unlimited power."
	credit_cost = 8000

/datum/map_template/shuttle/emergency/ragecage
	suffix = "ragecage"
	name = "THE RAGE CAGE"
	description = "An abandoned underground electrified fight arena turned into a shuttle. Comes with a Brig, Medbay and Cockpit included."
	admin_notes = "It's a normal shuttle but it has a rage cage with baseball bats in the middle powered by a PACMAN, plasma included."
	credit_cost = 7500
	danger_level = SHUTTLE_DANGER_SUBPAR


/datum/map_template/shuttle/emergency/zeta/prerequisites_met()
	if(SHUTTLE_UNLOCK_ALIENTECH in SSshuttle.shuttle_purchase_requirements_met)
		return TRUE
	return FALSE

/datum/map_template/shuttle/arrival/box
	suffix = "box"
	name = "arrival shuttle (Box)"

/datum/map_template/shuttle/cargo/box
	suffix = "box"
	name = "cargo ferry (Box)"

/datum/map_template/shuttle/mining/box
	suffix = "box"
	name = "mining shuttle (Box)"

/datum/map_template/shuttle/labour/box
	suffix = "box"
	name = "labour shuttle (Box)"

/datum/map_template/shuttle/arrival/corg
	suffix = "corg"
	name = "arrival shuttle (Corg)"

/datum/map_template/shuttle/infiltrator/basic
	suffix = "basic"
	name = "basic syndicate infiltrator"

/datum/map_template/shuttle/infiltrator/advanced
	suffix = "advanced"
	name = "advanced syndicate infiltrator"

/datum/map_template/shuttle/cargo/delta
	suffix = "delta"
	name = "cargo ferry (Delta)"

/datum/map_template/shuttle/mining/delta
	suffix = "delta"
	name = "mining shuttle (Delta)"

/datum/map_template/shuttle/mining/kilo
	suffix = "kilo"
	name = "mining shuttle (Kilo)"

/datum/map_template/shuttle/mining/large
	suffix = "large"
	name = "mining shuttle (Large)"

/datum/map_template/shuttle/mining/rad
	suffix = "rad"
	name = "mining shuttle (Rad)"

/datum/map_template/shuttle/mining/tiny
	suffix = "tiny"
	name = "mining shuttle (Tiny)"

/datum/map_template/shuttle/cargo/rad
	suffix = "rad"
	name = "cargo ferry (Rad)"

/datum/map_template/shuttle/cargo/tiny
	suffix = "tiny"
	name = "cargo ferry (Tiny)"

/datum/map_template/shuttle/science
	port_id = "science"
	suffix = "outpost"
	name = "science outpost shuttle"
	can_be_bought = FALSE

/datum/map_template/shuttle/exploration
	port_id = "exploration"
	suffix = "shuttle"
	name = "exploration shuttle"
	can_be_bought = FALSE

/datum/map_template/shuttle/exploration/card
	suffix = "card"
	name = "card exploration shuttle"

/datum/map_template/shuttle/exploration/corg
	suffix = "corg"
	name = "corg exploration shuttle"

/datum/map_template/shuttle/exploration/delta
	suffix = "delta"
	name = "delta exploration shuttle"

/datum/map_template/shuttle/exploration/kilo
	suffix = "kilo"
	name = "kilo exploration shuttle"

/datum/map_template/shuttle/exploration/rad
	suffix = "rad"
	name = "rad exploration shuttle"

/datum/map_template/shuttle/labour/delta
	suffix = "delta"
	name = "labour shuttle (Delta)"

/datum/map_template/shuttle/labour/kilo
	suffix = "kilo"
	name = "labour shuttle (Kilo)"

/datum/map_template/shuttle/labour/corg
	suffix = "corg"
	name = "labour shuttle (Corg)"

/datum/map_template/shuttle/arrival/delta
	suffix = "delta"
	name = "arrival shuttle (Delta)"

/datum/map_template/shuttle/arrival/card
	suffix = "card"
	name = "arrival shuttle (Card)"

/datum/map_template/shuttle/cargo/card
	suffix = "card"
	name = "cargo ferry (Card)"

/datum/map_template/shuttle/mining/card
	suffix = "card"
	name = "mining shuttle (Card)"

/datum/map_template/shuttle/labour/card
	suffix = "card"
	name = "labour shuttle (Card)"

/datum/map_template/shuttle/arrival/kilo
	suffix = "kilo"
	name = "arrival shuttle (Kilo)"

/datum/map_template/shuttle/arrival/pubby
	suffix = "pubby"
	name = "arrival shuttle (Pubby)"

/datum/map_template/shuttle/arrival/tiny
	suffix = "tiny"
	name = "arrival shuttle (Tiny)"

/datum/map_template/shuttle/arrival/omega
	suffix = "omega"
	name = "arrival shuttle (Omega)"

/datum/map_template/shuttle/aux_base/default
	suffix = "default"
	name = "auxilliary base (Default)"

/datum/map_template/shuttle/aux_base/small
	suffix = "small"
	name = "auxilliary base (Small)"

/datum/map_template/shuttle/escape_pod/default
	suffix = "default"
	name = "escape pod (Default)"

/datum/map_template/shuttle/escape_pod/large
	suffix = "large"
	name = "escape pod (Large)"

/datum/map_template/shuttle/assault_pod/default
	suffix = "default"
	name = "assault pod (Default)"

/datum/map_template/shuttle/pirate/default
	suffix = "default"
	name = "pirate ship (Default)"

/datum/map_template/shuttle/hunter/space_cop
	suffix = "space_cop"
	name = "Police Spacevan"

/datum/map_template/shuttle/hunter/russian
	suffix = "russian"
	name = "Russian Cargo Ship"

/datum/map_template/shuttle/hunter/bounty
	suffix = "bounty"
	name = "Bounty Hunter Ship"

/datum/map_template/shuttle/ruin/caravan_victim
	suffix = "caravan_victim"
	name = "Small Freighter"

/datum/map_template/shuttle/ruin/pirate_cutter
	suffix = "pirate_cutter"
	name = "Pirate Cutter"

/datum/map_template/shuttle/ruin/syndicate_dropship
	suffix = "syndicate_dropship"
	name = "Syndicate Dropship"

/datum/map_template/shuttle/ruin/syndicate_fighter_shiv
	suffix = "syndicate_fighter_shiv"
	name = "Syndicate Fighter"

/datum/map_template/shuttle/snowdin/mining
	suffix = "mining"
	name = "Snowdin Mining Elevator"

/datum/map_template/shuttle/snowdin/excavation
	suffix = "excavation"
	name = "Snowdin Excavation Elevator"

/datum/map_template/shuttle/tram
	port_id = "tram"
	can_be_bought = FALSE

/datum/map_template/shuttle/tram/corg
	suffix = "corg"
	name = "corgstation transport shuttle"

//---------cargo_fland.dmm
/datum/map_template/shuttle/cargo/fland
	suffix = "fland"
	name = "supply shuttle (fland)"

//---------labour_fland.dmm
/datum/map_template/shuttle/cargo/fland
	suffix = "fland"
	name = "cargo ferry (Fland)"

//---------mining_fland.dmm
/datum/map_template/shuttle/mining/fland
	suffix = "fland"
	name = "mining shuttle (fland)"

//---------labour_fland.dmm
/datum/map_template/shuttle/labour/fland
	suffix = "fland"
	name = "labour shuttle (Fland)"

//---------arrival_fland.dmm
/datum/map_template/shuttle/arrival/fland
	suffix = "fland"
	name = "arrival shuttle (Fland)"

//---------whiteship_fland.dmm
/datum/map_template/shuttle/whiteship/fland
	suffix = "fland"
	name = "Eden Whiteship"

//---------exploration_fland.dmm
/datum/map_template/shuttle/exploration/fland
	suffix = "fland"
	name = "Fland exploration shuttle"

//---------ferry_fland.dmm
/datum/map_template/shuttle/ferry/fland
	suffix = "fland"
	name = "fland transport ferry"
	description = "Standard issue CentCom Ferry for the fland station. Includes additional equipment and a recharger."
