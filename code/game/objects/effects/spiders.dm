//generic procs copied from obj/effect/alien
/obj/structure/spider
	name = "web"
	icon = 'icons/effects/effects.dmi'
	desc = "It's stringy and sticky."
	anchored = TRUE
	density = FALSE
	max_integrity = 15



/obj/structure/spider/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	if(damage_type == BURN)//the stickiness of the web mutes all attack sounds except fire damage type
		playsound(loc, 'sound/items/welder.ogg', 100, 1)

/obj/structure/spider/attackby(obj/item/I, mob/living/user, params)
	if(I.damtype != BURN)
		if(prob(35))
			user.transferItemToLoc(I, drop_location())
			to_chat(user, "<span class='danger'>The [I] gets stuck in \the [src]!</span>")
	return ..()

/obj/structure/spider/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(damage_flag == MELEE)
		switch(damage_type)
			if(BURN)
				damage_amount *= 2
	. = ..()

/obj/structure/spider/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		take_damage(5, BURN, 0, 0)

/obj/structure/spider/stickyweb
	icon_state = "stickyweb1"

/obj/structure/spider/stickyweb/Initialize(mapload)
	if(prob(50))
		icon_state = "stickyweb2"
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/spider/stickyweb/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(isliving(AM) && !istype(AM, /mob/living/simple_animal/hostile/poison/giant_spider))
		var/mob/living/L = AM
		if(!L.IsImmobilized()) //Don't spam the shit out of them if they're being dragged by a spider
			to_chat(L, "<span class='danger'>You get stuck in \the [src] for a moment.</span>")
		L.Immobilize(1.5 SECONDS)
	if(ismecha(AM))
		var/obj/mecha/mech = AM
		mech.step_restricted += 1 SECONDS //unlike the above, this one stacks based on number of webs. Punch the webs to destroy them you dolt.
		if(mech.occupant && !mech.step_restricted)
			to_chat(mech.occupant, "<span class='danger'>\the [mech] gets stuck in \the [src]!</span>")

/obj/structure/spider/stickyweb/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(istype(mover, /obj/item/projectile))
		return prob(30)

/obj/structure/spider/eggcluster
	name = "egg cluster"
	desc = "They seem to pulse slightly with an inner life."
	icon_state = "eggs"
	var/amount_grown = 0
	// Spawn info
	var/spawns_remaining = 1
	var/enriched_spawns = 0
	var/using_enriched_spawn = FALSE
	// Probability (%) an egg cluster presenting enriched spawn choices
	var/enriched_spawn_prob = 25
	// Team info
	var/datum/team/spiders/spider_team
	var/list/faction = list("spiders")
	// Whether or not a ghost can use the cluster to become a spider.
	var/ghost_ready = FALSE
	var/grow_time = 60 // Grow time (in seconds because delta-time)
	// The types of spiders the egg sac can produce by default.
	var/list/mob/living/potential_spawns = list(/mob/living/simple_animal/hostile/poison/giant_spider/guard,
								/mob/living/simple_animal/hostile/poison/giant_spider/hunter,
								/mob/living/simple_animal/hostile/poison/giant_spider/nurse,
								/mob/living/simple_animal/hostile/poison/giant_spider/netcaster)
	// The types of spiders the egg sac produces when we proc an enriched spawn
	var/list/mob/living/potential_enriched_spawns = list(/mob/living/simple_animal/hostile/poison/giant_spider/guard,
								/mob/living/simple_animal/hostile/poison/giant_spider/hunter,
								/mob/living/simple_animal/hostile/poison/giant_spider/nurse,
								/mob/living/simple_animal/hostile/poison/giant_spider/netcaster,
								/mob/living/simple_animal/hostile/poison/giant_spider/hunter/viper,
								/mob/living/simple_animal/hostile/poison/giant_spider/broodmother)

/obj/structure/spider/eggcluster/Initialize(mapload)
	pixel_x = rand(3,-3)
	pixel_y = rand(3,-3)
	START_PROCESSING(SSobj, src)
	. = ..()

/obj/structure/spider/eggcluster/process(delta_time)
	amount_grown += delta_time
	if(amount_grown >= grow_time && !ghost_ready) // 1 minute to grow
		if(enriched_spawns && prob(enriched_spawn_prob))
			using_enriched_spawn = TRUE
		notify_ghosts("[src] is ready to hatch!", null, enter_link="<a href=?src=[REF(src)];activate=1>(Click to play)</a>", source=src, action=NOTIFY_ATTACK, ignore_key = POLL_IGNORE_SPIDER)
		ghost_ready = TRUE
		LAZYADD(GLOB.mob_spawners[name], src)
		SSmobs.update_spawners()
		GLOB.poi_list |= src
	if(amount_grown >= grow_time *3)
		make_AI_spider()

/obj/structure/spider/eggcluster/Topic(href, href_list)
	if(..())
		return
	if(href_list["activate"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			attack_ghost(ghost)

/obj/structure/spider/eggcluster/attack_ghost(mob/user)
	. = ..()
	if(!user?.client.canGhostRole(ROLE_SPIDER, TRUE, flags_1))
		return
	if(ghost_ready)
		make_spider(user)
	else
		to_chat(user, "<span class='warning'>[src] isn't ready yet!</span>")

/obj/structure/spider/eggcluster/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 500)
		take_damage(5, BURN, 0, 0)

/obj/structure/spider/eggcluster/Destroy()
	GLOB.poi_list -= src
	var/list/spawners = GLOB.mob_spawners[name]
	LAZYREMOVE(spawners, src)
	if(!LAZYLEN(spawners))
		GLOB.mob_spawners -= name
	SSmobs.update_spawners()
	return ..()

/**
  * Makes a ghost into a spider based on the type of egg cluster.
  *
  * Allows a ghost to get a prompt to use the egg cluster to become a spider.
  * Arguments:
  * * user - The ghost attempting to become a spider.
  */
/obj/structure/spider/eggcluster/proc/make_spider(mob/user)
	// Get what spiders the user can choose, and check to make sure their choice makes sense
	var/list/to_spawn = list()
	var/list/spider_list = list()
	if(!spider_team) // If this object is created by anything other than a broodmother, it will not have a team
		spider_team = new() //So we make one to keep all future spiders on the same team
	if(using_enriched_spawn)
		to_spawn = potential_enriched_spawns
	else
		to_spawn = potential_spawns
	for(var/choice in to_spawn)
		var/mob/living/simple_animal/spider = choice
		spider_list[initial(spider.name)] = choice
	var/chosen_spider = input("Spider Type", "Egg Cluster") as null|anything in spider_list
	//Player does not get to spawn if the eggs were destroyed or consumed, and we also want to return if no choice was made.
	if(QDELETED(src) || QDELETED(user) || !chosen_spider || !spawns_remaining)
		return FALSE
	//if spider chosen is not in the basic spawn list, it is special
	//turn off enriched spawns so only one special spider per proc activation
	if(using_enriched_spawn)
		if(!(spider_list[chosen_spider] in potential_spawns))
			using_enriched_spawn = FALSE
	//Failsafe to prevent chosing special spider spawns after someone else has already chosen one
	//Multiple players can be presented the dialogue box to choose enriched spawns at the same time
	//and we don't want them choosing a special spider after the spawn has already been consumed
	else if(!(spider_list[chosen_spider] in potential_spawns))
		to_chat(user, "<span class='warning'>Special spawn already used by another player!</span>")
		return FALSE
	spawns_remaining--
	// Setup our spooder
	var/spider_to_spawn = spider_list[chosen_spider]
	var/mob/living/simple_animal/hostile/poison/giant_spider/new_spider = new spider_to_spawn(get_turf(src))
	new_spider.faction = faction.Copy()
	new_spider.key = user.key
	var/datum/antagonist/spider/spider_antag = new_spider.mind.has_antag_datum(/datum/antagonist/spider)
	spider_antag.set_spider_team(spider_team)

	// Check to see if we need to delete ourselves
	if(!spawns_remaining)
		qdel(src)
	return TRUE

/obj/structure/spider/eggcluster/proc/make_AI_spider()
	var/mob/living/simple_animal/hostile/poison/giant_spider/random_spider
	if(using_enriched_spawn)
		random_spider = pick(potential_enriched_spawns)
		using_enriched_spawn = FALSE
	else
		random_spider = pick(potential_spawns)
	random_spider = new random_spider(get_turf(src))
	random_spider.faction = faction.Copy()
	random_spider.spider_team = spider_team
	random_spider.set_playable()
	spawns_remaining--
	if(!spawns_remaining)
		qdel(src)

/obj/structure/spider/spiderling
	name = "spiderling"
	desc = "It never stays still for long."
	icon_state = "spiderling"
	anchored = FALSE
	layer = PROJECTILE_HIT_THRESHOLD_LAYER
	max_integrity = 3
	var/amount_grown = 0
	var/grow_as = null
	var/obj/machinery/atmospherics/components/unary/vent_pump/entry_vent
	var/travelling_in_vent = 0
	var/list/faction = list("spiders")

/obj/structure/spider/spiderling/Destroy()
	new/obj/item/reagent_containers/food/snacks/spiderling(get_turf(src))
	. = ..()

/obj/structure/spider/spiderling/Initialize(mapload)
	. = ..()
	pixel_x = rand(6,-6)
	pixel_y = rand(6,-6)
	START_PROCESSING(SSobj, src)
	AddComponent(/datum/component/swarming)

/obj/structure/spider/spiderling/hunter
	grow_as = /mob/living/simple_animal/hostile/poison/giant_spider/hunter

/obj/structure/spider/spiderling/nurse
	grow_as = /mob/living/simple_animal/hostile/poison/giant_spider/nurse

/obj/structure/spider/spiderling/broodmother
	grow_as = /mob/living/simple_animal/hostile/poison/giant_spider/broodmother

/obj/structure/spider/spiderling/viper
	grow_as = /mob/living/simple_animal/hostile/poison/giant_spider/hunter/viper

/obj/structure/spider/spiderling/netcaster
	grow_as = /mob/living/simple_animal/hostile/poison/giant_spider/netcaster

/obj/structure/spider/spiderling/Bump(atom/user)
	if(istype(user, /obj/structure/table))
		forceMove(user.loc)
	else
		..()

/obj/structure/spider/spiderling/process()
	if(travelling_in_vent)
		if(isturf(loc))
			travelling_in_vent = 0
			entry_vent = null
	else if(entry_vent)
		if(get_dist(src, entry_vent) <= 1)
			var/list/vents = list()
			var/datum/pipeline/entry_vent_parent = entry_vent.parents[1]
			for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent in entry_vent_parent.other_atmosmch)
				vents.Add(temp_vent)
			if(!vents.len)
				entry_vent = null
				return
			var/obj/machinery/atmospherics/components/unary/vent_pump/exit_vent = pick(vents)
			if(prob(50))
				visible_message("<B>[src] scrambles into the ventilation ducts!</B>", \
								"<span class='italics'>You hear something scampering through the ventilation ducts.</span>")

			spawn(rand(20,60))
				forceMove(exit_vent)
				var/travel_time = round(get_dist(loc, exit_vent.loc) / 2)
				spawn(travel_time)

					if(!exit_vent || exit_vent.welded)
						forceMove(entry_vent)
						entry_vent = null
						return

					if(prob(50))
						audible_message("<span class='italics'>You hear something scampering through the ventilation ducts.</span>")
					sleep(travel_time)

					if(!exit_vent || exit_vent.welded)
						forceMove(entry_vent)
						entry_vent = null
						return
					forceMove(exit_vent.loc)
					entry_vent = null
					var/area/new_area = get_area(loc)
					if(new_area)
						new_area.Entered(src)
	//=================

	else if(prob(33))
		var/target_atom = pick(oview(10, src))
		if(target_atom)
			SSmove_manager.move_to(src, target_atom)
			if(prob(40))
				src.visible_message("<span class='notice'>\The [src] skitters[pick(" away"," around","")].</span>")
	else if(prob(10))
		//ventcrawl!
		for(var/obj/machinery/atmospherics/components/unary/vent_pump/v in view(7,src))
			if(!v.welded)
				entry_vent = v
				SSmove_manager.move_to(src, entry_vent, 1)
				break
	if(isturf(loc))
		amount_grown += rand(0,2)
		if(amount_grown >= 100)
			if(!grow_as)
				if(prob(3))
					grow_as = pick(/mob/living/simple_animal/hostile/poison/giant_spider/netcaster, /mob/living/simple_animal/hostile/poison/giant_spider/hunter/viper, /mob/living/simple_animal/hostile/poison/giant_spider/broodmother)
				else
					grow_as = pick(/mob/living/simple_animal/hostile/poison/giant_spider, /mob/living/simple_animal/hostile/poison/giant_spider/hunter, /mob/living/simple_animal/hostile/poison/giant_spider/nurse)
			var/mob/living/simple_animal/hostile/poison/giant_spider/S = new grow_as(src.loc)
			S.faction = faction.Copy()
			qdel(src)



/obj/structure/spider/cocoon
	name = "cocoon"
	desc = "Something wrapped in silky spider web."
	icon_state = "cocoon1"
	max_integrity = 60

/obj/structure/spider/cocoon/Initialize(mapload)
	icon_state = pick("cocoon1","cocoon2","cocoon3")
	. = ..()

/obj/structure/spider/cocoon/container_resist(mob/living/user)
	var/breakout_time = 600
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	to_chat(user, "<span class='notice'>You struggle against the tight bonds... (This will take about [DisplayTimeText(breakout_time)].)</span>")
	visible_message("You see something struggling and writhing in \the [src]!")
	if(do_after(user,(breakout_time), target = src))
		if(!user || user.stat != CONSCIOUS || user.loc != src)
			return
		qdel(src)



/obj/structure/spider/cocoon/Destroy()
	var/turf/T = get_turf(src)
	src.visible_message("<span class='warning'>\The [src] splits open.</span>")
	for(var/atom/movable/A in contents)
		A.forceMove(T)
	return ..()
