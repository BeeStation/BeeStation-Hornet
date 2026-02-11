GLOBAL_VAR(cult_ratvar)

#define RATVAR_CONSUME_RANGE 12
#define RATVAR_GRAV_PULL 10
#define RATVAR_SINGULARITY_SIZE 11

/obj/eldritch/ratvar
	name = "ratvar, the Clockwork Justicar"
	desc = "Oh, that's ratvar!"
	icon = 'icons/effects/512x512.dmi'
	icon_state = "ratvar"
	density = FALSE
	pixel_x = -236
	pixel_y = -256
	var/range = 1
	var/ratvar_target
	var/next_attack_tick

CREATION_TEST_IGNORE_SUBTYPES(/obj/eldritch/ratvar)

/obj/eldritch/ratvar/Initialize(mapload, starting_energy = 50)
	. = ..()
	singularity = WEAKREF(AddComponent(
		/datum/component/singularity, \
		bsa_targetable = FALSE, \
		consume_callback = CALLBACK(src, PROC_REF(consume)), \
		consume_range = RATVAR_CONSUME_RANGE, \
		disregard_failed_movements = TRUE, \
		grav_pull = RATVAR_GRAV_PULL, \
		roaming = TRUE,\
		singularity_size = RATVAR_SINGULARITY_SIZE, \
	))
	log_game("!!! RATVAR HAS RISEN. !!!")
	GLOB.cult_ratvar = src

	desc = text2ratvar("That's Ratvar, the Clockwork Justicar. The great one has risen.")
	sound_to_playing_players('sound/effects/ratvar_reveal.ogg')
	send_to_playing_players(span_ratvar("The bluespace veil gives way to Ratvar, his light shall shine upon all mortals!"))
	UnregisterSignal(src, COMSIG_ATOM_BSA_BEAM)
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(trigger_clockcult_victory), src)
	check_gods_battle()

//tasty
/obj/eldritch/ratvar/process(delta_time)
	var/datum/component/singularity/singularity_component = singularity.resolve()
	if(ratvar_target)
		singularity_component?.target = ratvar_target
		if(get_dist(src, ratvar_target) < 5)
			if(next_attack_tick < world.time)
				next_attack_tick = world.time + rand(50, 100)
				to_chat(world, span_danger("[pick("Reality shudders around you.","You hear the tearing of flesh.","The sound of bones cracking fills the air.")]"))
				SEND_SOUND(world, 'sound/magic/clockwork/ratvar_attack.ogg')
				SpinAnimation(4, 0)
				for(var/mob/living/M in GLOB.player_list)
					shake_camera(M, 25, 6)
					M.Knockdown(5 * delta_time)
				if(prob(max(GLOB.servants_of_ratvar.len/2, 15)))
					SEND_SOUND(world, 'sound/magic/demon_dies.ogg')
					to_chat(world, span_ratvar("You were a fool for underestimating me..."))
					qdel(ratvar_target)
					for(var/datum/mind/cult_mind as anything in get_antag_minds(/datum/antagonist/cult))
						to_chat(cult_mind, span_userdanger("You feel a stabbing pain in your chest... This can't be happening!"))
						cult_mind.current?.dust()
				return

/obj/eldritch/ratvar/consume(atom/A)
	A.ratvar_act()

/obj/eldritch/ratvar/Bump(atom/A)
	var/turf/T = get_turf(A)
	if(T == loc)
		T = get_step(A, A.dir) //please don't slam into a window like a bird, Ratvar
	forceMove(T)

/obj/eldritch/ratvar/attack_ghost(mob/user)
	. = ..()
	var/mob/living/simple_animal/drone/scarab = new /mob/living/simple_animal/drone/cogscarab(get_turf(src))
	scarab.flags_1 |= (flags_1 & ADMIN_SPAWNED_1)
	scarab.key = user.key
	add_servant_of_ratvar(scarab, silent=TRUE)

#undef RATVAR_CONSUME_RANGE
#undef RATVAR_GRAV_PULL
#undef RATVAR_SINGULARITY_SIZE
