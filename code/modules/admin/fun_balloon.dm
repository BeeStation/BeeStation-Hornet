/obj/effect/fun_balloon
	name = "fun balloon"
	desc = "This is going to be a laugh riot."
	icon = 'icons/obj/balloons.dmi'
	icon_state = "syndballoon"
	anchored = TRUE
	var/popped = FALSE

/obj/effect/fun_balloon/Initialize(mapload)
	. = ..()
	SSobj.processing |= src

/obj/effect/fun_balloon/Destroy()
	SSobj.processing -= src
	. = ..()

/obj/effect/fun_balloon/process()
	if(!popped && check() && !QDELETED(src))
		popped = TRUE
		effect()
		pop()

/obj/effect/fun_balloon/proc/check()
	return FALSE

/obj/effect/fun_balloon/proc/effect()
	return

/obj/effect/fun_balloon/proc/pop()
	visible_message("[src] pops!")
	playsound(get_turf(src), 'sound/items/party_horn.ogg', 50, 1, -1)
	qdel(src)

//ATTACK GHOST IGNORING PARENT RETURN VALUE
/obj/effect/fun_balloon/attack_ghost(mob/user)
	if(!user.client || !user.client.holder || popped)
		return
	var/confirmation = alert("Pop [src]?","Fun Balloon","Yes","No")
	if(confirmation == "Yes" && !popped)
		popped = TRUE
		effect()
		pop()

/obj/effect/fun_balloon/sentience
	name = "sentience fun balloon"
	desc = "When this pops, things are gonna get more aware around here."
	var/effect_range = 3
	var/group_name = "a bunch of giant spiders"

/obj/effect/fun_balloon/sentience/effect()
	var/list/bodies = list()
	for(var/mob/living/M in viewers(effect_range, get_turf(src)))
		bodies += M

	var/datum/poll_config/config = new()
	config.question = "Would you like to be [span_notice(group_name)]?"
	config.check_jobban = ROLE_SENTIENCE
	config.poll_time = 10 SECONDS
	config.role_name_text = "sentience fun balloon"
	config.alert_pic = src
	var/list/candidates = SSpolling.poll_ghosts_for_targets(config, bodies)
	while(LAZYLEN(candidates) && LAZYLEN(bodies))
		var/mob/dead/observer/candidate = pick_n_take(candidates)
		var/mob/living/body = pick_n_take(bodies)

		to_chat(body, "Your mob has been taken over by a ghost!")
		message_admins("[key_name_admin(candidate)] has taken control of ([key_name_admin(body)])")
		body.ghostize(FALSE)
		body.key = candidate.key
		new /obj/effect/temp_visual/gravpush(get_turf(body))

/obj/effect/fun_balloon/sentience/emergency_shuttle
	name = "shuttle sentience fun balloon"
	var/trigger_time = 60

/obj/effect/fun_balloon/sentience/emergency_shuttle/check()
	if(SSshuttle.emergency && (SSshuttle.emergency.timeLeft() <= trigger_time) && (SSshuttle.emergency.mode == SHUTTLE_CALL))
		return TRUE

	return FALSE

/obj/effect/fun_balloon/scatter
	name = "scatter fun balloon"
	desc = "When this pops, you're not going to be around here anymore."
	var/effect_range = 5

/obj/effect/fun_balloon/scatter/effect()
	for(var/mob/living/M in hearers(effect_range, get_turf(src)))
		var/turf/T = find_safe_turf()
		new /obj/effect/temp_visual/gravpush(get_turf(M))
		M.forceMove(T)
		to_chat(M, span_notice("Pop!"))

/obj/effect/station_crash
	name = "station crash"
	desc = "With no survivors!"
	icon = 'icons/obj/balloons.dmi'
	icon_state = "syndballoon"
	anchored = TRUE

/obj/effect/station_crash/Initialize(mapload)
	..()
	for(var/S in SSshuttle.stationary)
		var/obj/docking_port/stationary/SM = S
		if(SM.id == "emergency_home")
			var/new_dir = turn(SM.dir, 180)
			SM.forceMove(get_ranged_target_turf(SM, new_dir, rand(3,15)))
			break
	return INITIALIZE_HINT_QDEL


//Arena

/obj/effect/forcefield/arena_shuttle
	name = "portal"
	initial_duration = 0
	var/list/warp_points = list()

/obj/effect/forcefield/arena_shuttle/Initialize(mapload)
	. = ..()
	for(var/obj/effect/landmark/shuttle_arena_safe/exit in GLOB.landmarks_list)
		warp_points += exit

/obj/effect/forcefield/arena_shuttle/Bumped(atom/movable/AM)
	if(!isliving(AM))
		return

	var/mob/living/L = AM
	if(L.pulling && istype(L.pulling, /obj/item/bodypart/head))
		to_chat(L, "Your offering is accepted. You may pass.")
		qdel(L.pulling)
		var/turf/LA = get_turf(pick(warp_points))
		L.forceMove(LA)
		L.remove_status_effect(/datum/status_effect/hallucination)
		to_chat(L, span_reallybigredtext("The battle is won. Your bloodlust subsides."))
		for(var/obj/item/chainsaw/doomslayer/chainsaw in L)
			qdel(chainsaw)
	else
		to_chat(L, "You are not yet worthy of passing. Drag a severed head to the barrier to be allowed entry to the hall of champions.")

/obj/effect/landmark/shuttle_arena_safe
	name = "hall of champions"
	desc = "For the winners."

/obj/effect/landmark/shuttle_arena_entrance
	name = "\proper the arena"
	desc = "A lava filled battlefield."


/obj/effect/forcefield/arena_shuttle_entrance
	name = "portal"
	initial_duration = 0
	var/list/warp_points = list()

/obj/effect/forcefield/arena_shuttle_entrance/Bumped(atom/movable/AM)
	if(!isliving(AM))
		return

	if(!warp_points.len)
		for(var/obj/effect/landmark/shuttle_arena_entrance/S in GLOB.landmarks_list)
			warp_points |= S

	var/obj/effect/landmark/LA = pick(warp_points)
	var/mob/living/M = AM
	M.forceMove(get_turf(LA))
	to_chat(M, span_reallybigredtext("You're trapped in a deadly arena! To escape, you'll need to drag a severed head to the escape portals."))
	spawn()
		var/obj/effect/mine/pickup/bloodbath/B = new (M)
		B.mineEffect(M)


/area/shuttle_arena
	name = "arena"
	default_gravity = STANDARD_GRAVITY
	requires_power = FALSE
