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
	var/list/faction = list(FACTION_SPIDER)
	// Whether or not a ghost can use the cluster to become a spider.
	var/ghost_ready = FALSE
	var/grow_time = 60 // Grow time (in seconds because delta-time)
	// The types of spiders the egg sac can produce by default.
	var/list/mob/living/potential_spawns = list(/mob/living/simple_animal/hostile/poison/giant_spider/guard,
								/mob/living/simple_animal/hostile/poison/giant_spider/hunter,
								/mob/living/simple_animal/hostile/poison/giant_spider/nurse,
								/mob/living/simple_animal/hostile/poison/giant_spider/netcaster,)
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
		notify_ghosts("[src] is ready to hatch!", null, enter_link="<a href='byond://?src=[REF(src)];activate=1'>(Click to play)</a>", source=src, action=NOTIFY_ATTACK, ignore_key = POLL_IGNORE_SPIDER)
		ghost_ready = TRUE
		LAZYADD(GLOB.mob_spawners[name], src)
		SSmobs.update_spawners()
		AddElement(/datum/element/point_of_interest)
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
	if(!user?.client?.can_take_ghost_spawner(ROLE_SPIDER, TRUE, is_ghost_role = FALSE))
		return
	if(ghost_ready)
		make_spider(user)
	else
		to_chat(user, span_warning("[src] isn't ready yet!"))

/obj/structure/spider/eggcluster/Destroy()
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
		to_chat(user, span_warning("Special spawn already used by another player!"))
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
	random_spider.set_playable(ROLE_SPIDER, POLL_IGNORE_SPIDER)
	spawns_remaining--
	if(!spawns_remaining)
		qdel(src)
