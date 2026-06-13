// WELCOME TO THE MIPPITY MINIMAL MORPH ZONE BUDDY BOY - Rasp B. Berry here to make life easier for the Blob Hunt Event

// Moth :)


#define MORPH_PIPE_WARN_TIME    12 // Time before morph players get a warning and start taking damage from being in the pipes
#define MORPH_PIPE_EJECT_TIME   25 // Time before morph's are force ejected from pipes
#define MORPH_PIPE_TICK_DAMAGE  3 // damage per tick while in pipes past warning

// Morph Mod Overwrites for da event
/mob/living/simple_animal/hostile/morph
	melee_damage = 2			// Base 20 - Damage begone
	var/pipe_time_elapsed = 0 // keeps track of how long morphs hide in vents
	var/pipe_warned = FALSE // tracks if a player has been warned before damage starts to come in

/mob/living/simple_animal/hostile/morph/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(!.)
		return

	if(HAS_TRAIT(src, TRAIT_MOVE_VENTCRAWLING) && istype(loc, /obj/machinery/atmospherics))
		pipe_time_elapsed += delta_time

		adjustHealth(MORPH_PIPE_TICK_DAMAGE)

		if(!pipe_warned && pipe_time_elapsed >= MORPH_PIPE_WARN_TIME)
			pipe_warned = TRUE
			to_chat(src, span_warning("The over-pressurized pipes begin to crush your form... you cannot remain in here much longer."))

		if(pipe_time_elapsed >= MORPH_PIPE_EJECT_TIME)
			to_chat(src, span_userdanger("The pressure rips you apart and ejects you from the pipes!"))
			adjustHealth(15)	// Damage for being ejected
			var/turf/eject_turf = get_turf(loc)
			if(eject_turf)
				forceMove(eject_turf)
				REMOVE_TRAIT(src, TRAIT_MOVE_VENTCRAWLING, VENTCRAWLING_TRAIT)
				update_pipe_vision()
			pipe_time_elapsed = 0
			pipe_warned = FALSE
	else
		// Reset counters as soon as they leave the pipe network
		pipe_time_elapsed = 0
		pipe_warned = FALSE

// Lesser toxin damage on hit
/mob/living/simple_animal/hostile/morph/morph_ambush(mob/living/L, touched_morph = FALSE)
	changeNext_move(CLICK_CD_MELEE)
	L.Stun(1 SECONDS)
	to_chat(L, span_userdanger("[src] bites you!"))
	visible_message(span_danger("[src] roughly bites [L]!"), \
		span_userdanger("You ambush [L]!"), null, COMBAT_MESSAGE_RANGE)

	restore(ambush = TRUE)

	if(touched_morph)
		L.Knockdown(5 SECONDS) // keeping knockdown time, just removing the damage aspect
		L.reagents.add_reagent(/datum/reagent/toxin/morphvenom, 1)	// base is 7u
	else
		L.Knockdown(3 SECONDS)

	if(issilicon(L))
		L.flash_act(affect_silicon = TRUE)

/obj/structure/closet/supplypod/morph_event //
	style = STYLE_SEETHROUGH		// See through pod, the no pod pod
	bluespace = TRUE			// Pod disappears after landing
	explosionSize = list(0,0,0,0)
	soundVolume = 25			// 80 is default
	delays = list(POD_TRANSIT = 20, POD_FALLING = 4, POD_OPENING = 30, POD_LEAVING = 30)

// Override morph objectives to use escape objective instead of eat_everything
/datum/antagonist/morph/forge_objectives()
	add_objective(new /datum/objective/escape())

// Makeship Late-Join Menu - No Job Select, only this...
/mob/dead/new_player/authenticated/LateChoices()
	var/datum/browser/popup = new(src, "latechoices", "Join as Morph", 380, 230)
	popup.add_stylesheet("playeroptions", 'html/browser/playeroptions.css')
	var/content = "<center>"
	content += "<div class='notice'><b>! The Blob Hunt Event Is In Progress !</b></div><br>"
	content += "<p>You will join the game as a <b>Morph</b>.</p>"
	content += "<p>You'll arrive via drop pod at a random location in the station's main hallway.</p>"
	content += "<p>No Announcement Will Be Made Of Your Arrival.</p>"
	content += "<p>Your Main Objective Is To Survive, and Evacuate. YOU HAVE DAMAGE DEBUFFS</p><br>"
	content += "<a class='job' href='byond://?src=[REF(src)];SelectedJob=MorphEvent'>Emerge as a Morph</a>"
	content += "</center>"
	popup.set_content(content)
	popup.open(FALSE)

/mob/dead/new_player/authenticated/AttemptLateSpawn(rank)
	AttemptMorphEventSpawn()

/mob/dead/new_player/authenticated/proc/AttemptMorphEventSpawn()
	if(SSticker.late_join_disabled)
		tgui_alert(src, "An administrator has disabled late join spawning.")
		return

	close_spawn_windows()
	SSticker.queued_players -= src
	SSticker.queue_delay = 4

	src.mind.late_joiner = TRUE
	src.mind.set_assigned_role(ROLE_MORPH)
	src.mind.special_role = ROLE_MORPH

	src.mind.active = FALSE
	var/mob/living/simple_animal/hostile/morph/morph_body = new(src.loc)
	morph_body.set_combat_mode(TRUE)
	src.mind.transfer_to(morph_body)
	morph_body.name = "morph"
	morph_body.real_name = "morph"

	morph_body.mind.add_antag_datum(/datum/antagonist/morph)

	var/turf/spawn_turf = get_safe_random_station_turfs(typesof(/area/station/hallway))
	if(spawn_turf)
		var/obj/structure/closet/supplypod/morph_event/pod = new()
		morph_body.forceMove(pod)
		new /obj/effect/pod_landingzone(spawn_turf, pod)
	else
		SSjob.SendToLateJoin(morph_body)

	SSticker.minds += morph_body.mind
	GLOB.joined_player_list += ckey
	log_manifest(morph_body.mind.key, morph_body.mind, morph_body, latejoin = TRUE)

	morph_body.key = key
	SEND_SOUND(morph_body, sound('sound/magic/mutate.ogg'))
	qdel(src)


#undef MORPH_PIPE_WARN_TIME
#undef MORPH_PIPE_EJECT_TIME
#undef MORPH_PIPE_TICK_DAMAGE
