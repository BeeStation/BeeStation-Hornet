/// The carp rift is currently charging.
#define CHARGE_ONGOING			0
/// The carp rift is currently charging and has output a final warning.
#define CHARGE_FINALWARNING		1
/// The carp rift is now fully charged.
#define CHARGE_COMPLETED		2

/datum/action/innate/summon_rift
	name = "Summon Rift"
	desc = "Summon a rift to bring forth a horde of space carp."
	background_icon_state = "bg_default"
	icon_icon = 'icons/mob/actions/actions_space_dragon.dmi'
	button_icon_state = "carp_rift"

/datum/action/innate/summon_rift/Activate()
	var/datum/antagonist/space_dragon/dragon = owner.mind?.has_antag_datum(/datum/antagonist/space_dragon)
	if(!dragon)
		return
	var/mob/living/simple_animal/hostile/space_dragon/S = owner
	if(S.using_special)
		return
	if(!S.can_summon_rifts)
		to_chat(S, "<span class='warning'>You can't summon a rift right now!</span>")
		return
	var/area/A = get_area(S)
	if(!(A in dragon.chosen_rift_areas))
		to_chat(S, "<span class='warning'>You can't summon a rift here!</span>")
		return
	for(var/obj/structure/carp_rift/rift in dragon.rift_list)
		var/area/RA = get_area(rift)
		if(RA == A)
			to_chat(S, "<span class='warning'>You've already summoned a rift in this area! You have to summon again somewhere else!</span>")
			return
	var/turf/rift_spawn_turf = get_turf(S)
	if(istype(rift_spawn_turf, /turf/open/openspace))
		owner.balloon_alert(S, "needs stable ground!")
		return
	to_chat(S, "<span class='warning'>You begin to open a rift...</span>")
	if(do_after(S, 100, target = S))
		for(var/obj/structure/carp_rift/c in rift_spawn_turf.contents)
			return
		var/obj/structure/carp_rift/CR = new /obj/structure/carp_rift(rift_spawn_turf)
		playsound(S, 'sound/vehicles/rocketlaunch.ogg', 100, TRUE)
		S.can_summon_rifts = FALSE // the rift needs to finish charging before summoning another
		CR.dragon = dragon
		dragon.rift_list += CR
		to_chat(S, "<span class='boldwarning'>The rift has been summoned. Prevent the crew from destroying it at all costs!</span>")
		notify_ghosts("The Space Dragon has opened a rift!", source = CR, action = NOTIFY_ORBIT, flashwindow = FALSE, header = "Carp Rift Opened")
		qdel(src) // remove the action, a new one is granted if this rift charges or is destroyed

/**
  * # Carp Rift
  *
  * The portals Space Dragon summons to bring carp onto the station.
  *
  * The portals Space Dragon summons to bring carp onto the station.  His main objective is to summon 3 of them and protect them from being destroyed.
  * The portals can summon sentient space carp in limited amounts.  The portal also changes color based on whether or not a carp spawn is available.
  * Once it is fully charged, it becomes indestructible, and intermitently spawns non-sentient carp.  It is still destroyed if Space Dragon dies.
  */
/obj/structure/carp_rift
	name = "carp rift"
	desc = "A rift akin to the ones space carp use to travel long distances."
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 50, BIO = 100, RAD = 100, FIRE = 100, ACID = 100, STAMINA = 0)
	max_integrity = 300
	icon = 'icons/obj/carp_rift.dmi'
	icon_state = "carp_rift_carpspawn"
	light_color = LIGHT_COLOR_PURPLE
	light_range = 10
	anchored = TRUE
	density = TRUE
	plane = MASSIVE_OBJ_PLANE
	/// The amount of time the rift has charged for.
	var/time_charged = 0
	/// The maximum charge the rift can have.
	var/max_charge = 300
	/// How many carp spawns it has available.
	var/carp_stored = 1
	/// A reference to the Space Dragon that created it.
	var/datum/antagonist/space_dragon/dragon
	/// Current charge state of the rift.
	var/charge_state = CHARGE_ONGOING
	/// The interval for adding additional space carp spawns to the rift.
	var/carp_interval = 45
	/// The time since an extra carp was added to the ghost role spawning pool.
	var/last_carp_inc = 0
	/// A list of all the ckeys which have used this carp rift to spawn in as carps.
	var/list/ckey_list = list()

/obj/structure/carp_rift/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	AddComponent( \
		/datum/component/gravity_aura, \
		range = 15, \
		requires_visibility = FALSE, \
		gravity_strength = 1, \
	)

/obj/structure/carp_rift/examine(mob/user)
	. = ..()
	if(time_charged < max_charge)
		. += "<span class='notice'>It seems to be [(time_charged / max_charge) * 100]% charged.</span>"
	else
		. += "<span class='warning'>This one is fully charged. In this state, it is poised to transport a much larger amount of carp than normal.</span>"

	if(isobserver(user))
		. += "<span class='notice'>It has [carp_stored] carp available to spawn as.</span>"

/obj/structure/carp_rift/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	playsound(src, 'sound/magic/lightningshock.ogg', 50, TRUE)

/obj/structure/carp_rift/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(time_charged != max_charge + 1)
		if(dragon)
			restore_rift_ability()
			if(dragon.owner.current)
				to_chat(dragon.owner.current, "<span class='boldwarning'>A rift has been destroyed!</span>")
			dragon = null
	return ..()

/obj/structure/carp_rift/process(delta_time)
	// Heal carp around us
	for(var/mob/living/simple_animal/hostile/hostilehere in range(1))
		if("carp" in hostilehere.faction)
			hostilehere.adjustHealth(-10)
			var/obj/effect/temp_visual/heal/H = new /obj/effect/temp_visual/heal(get_turf(hostilehere))
			H.color = "#0000FF"

	// If we're fully charged, just start mass spawning carp and move around.
	if(charge_state == CHARGE_COMPLETED)
		if(DT_PROB(1.25, delta_time))
			new /mob/living/simple_animal/hostile/carp/advanced(loc)
		if(DT_PROB(1.5, delta_time))
			var/rand_dir = pick(GLOB.cardinals)
			Move(get_step(src, rand_dir), rand_dir)
		return

	// Increase time trackers and check for any updated states.
	time_charged = min(time_charged + delta_time, max_charge)
	last_carp_inc += delta_time
	update_check()

/obj/structure/carp_rift/attack_ghost(mob/user)
	. = ..()
	if(user?.client.canGhostRole(ROLE_SPACE_DRAGON, TRUE, flags_1))
		summon_carp(user)

/**
 * Does a series of checks based on the portal's status.
 *
 * Performs a number of checks based on the current charge of the portal, and triggers various effects accordingly.
 * If the current charge is a multiple of carp_interval, add an extra carp spawn.
 * If we're halfway charged, announce to the crew our location in a CENTCOM announcement.
 * If we're fully charged, tell the crew we are, change our color to yellow, become invulnerable, and give Space Dragon the ability to make another rift, if he hasn't summoned 3 total.
 */
/obj/structure/carp_rift/proc/update_check()
	// If the rift is fully charged, there's nothing to do here anymore.
	if(charge_state == CHARGE_COMPLETED)
		return

	// Can we increase the carp spawn pool size?
	if(last_carp_inc >= carp_interval)
		carp_stored++
		icon_state = "carp_rift_carpspawn"
		if(light_color != LIGHT_COLOR_PURPLE)
			set_light_color(LIGHT_COLOR_PURPLE)
			update_light()
		notify_ghosts("The carp rift can summon an additional carp!", source = src, action = NOTIFY_ORBIT, flashwindow = FALSE, header = "Carp Spawn Available")
		last_carp_inc -= carp_interval

	// Is the rift now fully charged?
	if(time_charged >= max_charge)
		charge_state = CHARGE_COMPLETED
		var/area/A = get_area(src)
		priority_announce("Spatial object has reached peak energy charge in [initial(A.name)], please stand-by.", "Central Command Wildlife Observations")
		obj_integrity = INFINITY
		icon_state = "carp_rift_charged"
		set_light_color(LIGHT_COLOR_YELLOW)
		update_light()
		resistance_flags = INDESTRUCTIBLE
		dragon.rifts_charged += 1
		if(dragon.rifts_charged != 3 && !dragon.objective_complete)
			restore_rift_ability()
			dragon.rift_empower()
		// Early return, nothing to do after this point.
		return

	// Do we need to give a final warning to the station at the halfway mark?
	if(charge_state < CHARGE_FINALWARNING && time_charged >= (max_charge * 0.5))
		charge_state = CHARGE_FINALWARNING
		var/area/A = get_area(src)
		priority_announce("A rift is causing an unnaturally large energy flux in [initial(A.name)]. Stop it at all costs!", "Central Command Wildlife Observations", ANNOUNCER_SPANOMALIES)

/obj/structure/carp_rift/proc/restore_rift_ability()
	if(!dragon)
		return
	dragon.rift_ability = new
	dragon.rift_ability.Grant(dragon.owner.current)
	if(istype(dragon.owner.current, /mob/living/simple_animal/hostile/space_dragon))
		var/mob/living/simple_animal/hostile/space_dragon/S = dragon.owner.current
		S.can_summon_rifts = TRUE

/**
  * Used to create carp controlled by ghosts when the option is available.
  *
  * Creates a carp for the ghost to control if we have a carp spawn available.
  * Gives them prompt to control a carp, and if our circumstances still allow if when they hit yes, spawn them in as a carp.
  * Also add them to the list of carps in Space Dragon's antgonist datum, so they'll be displayed as having assisted him on round end.
  * Arguments:
  * * mob/user - The ghost which will take control of the carp.
  */
/obj/structure/carp_rift/proc/summon_carp(mob/user)
	if(carp_stored <= 0)//Not enough carp points
		return FALSE
	var/is_listed = FALSE
	if (user.ckey in ckey_list)
		if(carp_stored == 1)
			to_chat(user, "<span class='warning'>You've already become a carp using this rift! Either wait for a backlog of carp spawns or until the next rift!</span>")
			return FALSE
		is_listed = TRUE
	var/carp_ask = alert("Become a carp?", "Help bring forth the horde?", "Yes", "No")
	if(carp_ask == "No" || !src || QDELETED(src) || QDELETED(user))
		return FALSE
	if(carp_stored <= 0)
		to_chat(user, "<span class='warning'>The rift already summoned enough carp!</span>")
		return FALSE
	var/mob/living/simple_animal/hostile/carp/advanced/newcarp = new(loc)
	var/datum/action/innate/wavespeak/wave_action = new
	wave_action.Grant(newcarp)
	if(!is_listed)
		ckey_list += user.ckey
	newcarp.key = user.key
	newcarp.unique_name = TRUE
	dragon.carp += newcarp.mind
	to_chat(newcarp, "<span class='boldwarning'>You have arrived in order to assist the space dragon with securing the rifts. Do not jeopardize the mission, and protect the rifts at all costs!</span>")
	carp_stored--
	if(carp_stored <= 0 && charge_state < CHARGE_COMPLETED)
		icon_state = "carp_rift"
		set_light_color(LIGHT_COLOR_BLUE)
		update_light()
	return TRUE

#undef CHARGE_ONGOING
#undef CHARGE_FINALWARNING
#undef CHARGE_COMPLETED
