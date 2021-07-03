/obj/singularity/narsie //Moving narsie to a child object of the singularity so it can be made to function differently. --NEO
	name = "Nar'Sie's Avatar"
	desc = "Your mind begins to bubble and ooze as it tries to comprehend what it sees."
	icon = 'icons/obj/magic_terror.dmi'
	pixel_x = -89
	pixel_y = -85
	density = FALSE
	current_size = 9 //It moves/eats like a max-size singulo, aside from range. --NEO
	contained = 0 //Are we going to move around?
	dissipate = 0 //Do we lose energy over time?
	move_self = 1 //Do we move on our own?
	grav_pull = 5 //How many tiles out do we pull?
	consume_range = 6 //How many tiles out do we eat
	light_power = 0.7
	light_range = 15
	light_color = rgb(255, 0, 0)
	gender = FEMALE
	var/clashing = FALSE //If Nar'Sie is fighting Ratvar
	var/next_attack_tick

/obj/singularity/narsie/large
	name = "Nar'Sie"
	icon = 'icons/obj/narsie.dmi'
	// Pixel stuff centers Narsie.
	pixel_x = -236
	pixel_y = -256
	current_size = 12
	grav_pull = 10
	consume_range = 12 //How many tiles out do we eat

/obj/singularity/narsie/large/Initialize()
	. = ..()
	send_to_playing_players("<span class='narsie'>NAR'SIE HAS RISEN</span>")
	sound_to_playing_players('sound/creatures/narsie_rises.ogg')

	var/area/A = get_area(src)
	if(A)
		var/mutable_appearance/alert_overlay = mutable_appearance('icons/effects/cult_effects.dmi', "ghostalertsie")
		notify_ghosts("Nar'Sie has risen in \the [A.name]. Reach out to the Geometer to be given a new shell for your soul.", source = src, alert_overlay = alert_overlay, action=NOTIFY_ATTACK)
	INVOKE_ASYNC(src, .proc/narsie_spawn_animation)
	UnregisterSignal(src, COMSIG_ATOM_BSA_BEAM) //set up in /singularity/Initialize()

/obj/singularity/narsie/large/cult  // For the new cult ending, guaranteed to end the round within 3 minutes
	var/list/souls_needed = list()
	var/soul_goal = 0
	var/souls = 0
	var/resolved = FALSE

/obj/singularity/narsie/large/cult/Initialize()
	. = ..()
	GLOB.cult_narsie = src
	var/list/all_cults = list()
	for(var/datum/antagonist/cult/C in GLOB.antagonists)
		if(!C.owner)
			continue
		all_cults |= C.cult_team
	for(var/datum/team/cult/T in all_cults)
		deltimer(T.blood_target_reset_timer)
		T.blood_target = src
		var/datum/objective/eldergod/summon_objective = locate() in T.objectives
		if(summon_objective)
			summon_objective.summoned = TRUE
	for(var/datum/mind/cult_mind in SSticker.mode.cult)
		if(isliving(cult_mind.current))
			var/mob/living/L = cult_mind.current
			L.narsie_act()
	for(var/mob/living/player in GLOB.player_list)
		if(player.stat != DEAD && player.loc && is_station_level(player.loc.z) && !iscultist(player) && !isanimal(player))
			souls_needed[player] = TRUE
	soul_goal = round(1 + LAZYLEN(souls_needed) * 0.75)
	INVOKE_ASYNC(src, .proc/begin_the_end)
	check_gods_battle()

/obj/singularity/narsie/large/cult/proc/begin_the_end()
	sleep(50)
	priority_announce("An acausal dimensional event has been detected in your sector. Event has been flagged EXTINCTION-CLASS. Directing all available assets toward simulating solutions. SOLUTION ETA: 60 SECONDS.","Central Command Higher Dimensional Affairs", 'sound/misc/airraid.ogg')
	sleep(500)
	priority_announce("Simulations on acausal dimensional event complete. Deploying solution package now. Deployment ETA: ONE MINUTE. ","Central Command Higher Dimensional Affairs")
	sleep(50)
	set_security_level("delta")
	SSshuttle.registerHostileEnvironment(src)
	SSshuttle.lockdown = TRUE
	sleep(600)
	if(resolved == FALSE)
		resolved = TRUE
		sound_to_playing_players('sound/machines/alarm.ogg')
		addtimer(CALLBACK(GLOBAL_PROC, .proc/cult_ending_helper), 120)

/obj/singularity/narsie/large/cult/Destroy()
	GLOB.cult_narsie = null
	return ..()

/proc/ending_helper()
	SSticker.force_ending = 1

/proc/cult_ending_helper(var/no_explosion = 0)
	if(no_explosion)
		Cinematic(CINEMATIC_CULT,world,CALLBACK(GLOBAL_PROC,/proc/ending_helper))
	else
		Cinematic(CINEMATIC_CULT_NUKE,world,CALLBACK(GLOBAL_PROC,/proc/ending_helper))

//ATTACK GHOST IGNORING PARENT RETURN VALUE
/obj/singularity/narsie/large/attack_ghost(mob/dead/observer/user as mob)
	makeNewConstruct(/mob/living/simple_animal/hostile/construct/harvester, user, cultoverride = TRUE, loc_override = src.loc)

/obj/singularity/narsie/process(delta_time)
	eat()
	if(clashing)
		//Oh god what is it doing...
		target = clashing
		if(get_dist(src, clashing) < 5)
			if(next_attack_tick < world.time)
				next_attack_tick = world.time + rand(50, 100)
				to_chat(world, "<span class='danger'>[pick("You hear the scratching of cogs.","You hear the clanging of pipes.","You feel your bones start to rust...")]</span>")
				SEND_SOUND(world, 'sound/magic/clockwork/narsie_attack.ogg')
				SpinAnimation(4, 0)
				for(var/mob/living/M in GLOB.player_list)
					shake_camera(M, 25, 6)
					M.Knockdown(10)
				if(DT_PROB(max(SSticker.mode?.cult.len/2, 15), delta_time))
					SEND_SOUND(world, 'sound/magic/clockwork/anima_fragment_death.ogg')
					SEND_SOUND(world, 'sound/effects/explosionfar.ogg')
					to_chat(world, "<span class='narsie'>You really thought you could best me twice?</span>")
					QDEL_NULL(clashing)
					for(var/datum/mind/M as() in GLOB.servants_of_ratvar)
						to_chat(M, "<span class='userdanger'>You feel a stabbing pain in your chest... This can't be happening!</span>")
						M.current?.dust()
				return
		move()
		return
	if(!target || DT_PROB(5, delta_time))
		pickcultist()
	else
		move()
	if(DT_PROB(25, delta_time))
		mezzer()


/obj/singularity/narsie/Process_Spacemove()
	return clashing


/obj/singularity/narsie/Bump(atom/A)
	var/turf/T = get_turf(A)
	if(T == loc)
		T = get_step(A, A.dir) //please don't slam into a window like a bird, Nar'Sie
	forceMove(T)


/obj/singularity/narsie/mezzer()
	for(var/mob/living/carbon/M in hearers(consume_range, src))
		if(M.stat || iscultist(M))
			continue
		to_chat(M, "<span class='cultsmall'>You feel conscious thought crumble away in an instant as you gaze upon [src.name].</span>")
		M.apply_effect(60, EFFECT_STUN)


/obj/singularity/narsie/consume(atom/A)
	if(isturf(A))
		A.narsie_act()


/obj/singularity/narsie/ex_act() //No throwing bombs at her either.
	return


/obj/singularity/narsie/proc/pickcultist() //Narsie rewards her cultists with being devoured first, then picks a ghost to follow.
	var/list/cultists = list()
	var/list/noncultists = list()

	for(var/mob/living/carbon/food in GLOB.alive_mob_list) //we don't care about constructs or cult-Ians or whatever. cult-monkeys are fair game i guess
		var/turf/pos = get_turf(food)
		if(!pos || (pos.get_virtual_z_level() != get_virtual_z_level()))
			continue

		if(iscultist(food))
			cultists += food
		else
			noncultists += food

		if(cultists.len) //cultists get higher priority
			acquire(pick(cultists))
			return

		if(noncultists.len)
			acquire(pick(noncultists))
			return

	//no living humans, follow a ghost instead.
	for(var/mob/dead/observer/ghost in GLOB.player_list)
		if(!ghost.client)
			continue
		var/turf/pos = get_turf(ghost)
		if(!pos || (pos.get_virtual_z_level() != get_virtual_z_level()))
			continue
		cultists += ghost
	if(cultists.len)
		acquire(pick(cultists))
		return


/obj/singularity/narsie/proc/acquire(atom/food)
	if(food == target)
		return
	to_chat(target, "<span class='cultsmall'>NAR'SIE HAS LOST INTEREST IN YOU.</span>")
	target = food
	if(ishuman(target))
		to_chat(target, "<span class ='cult'>NAR'SIE HUNGERS FOR YOUR SOUL.</span>")
	else
		to_chat(target, "<span class ='cult'>NAR'SIE HAS CHOSEN YOU TO LEAD HER TO HER NEXT MEAL.</span>")

//Wizard narsie
/obj/singularity/narsie/wizard
	grav_pull = 0

/obj/singularity/narsie/wizard/eat()
//	if(defer_powernet_rebuild != 2)
//		defer_powernet_rebuild = 1
	for(var/turf/T as() in RANGE_TURFS(consume_range, src))
		consume(T)
	for(var/atom/movable/AM in urange(consume_range,src,1))
		consume(AM)
//	if(defer_powernet_rebuild != 2)
//		defer_powernet_rebuild = 0
	return


/obj/singularity/narsie/proc/narsie_spawn_animation()
	icon = 'icons/obj/narsie_spawn_anim.dmi'
	setDir(SOUTH)
	move_self = 0
	flick("narsie_spawn_anim",src)
	sleep(11)
	move_self = 1
	icon = initial(icon)


