/obj/structure/sacrificealtar
	name = "sacrificial altar"
	desc = "An altar designed to perform blood sacrifice for a deity."
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "sacrificealtar"
	anchored = TRUE
	density = FALSE
	can_buckle = 1

/obj/structure/sacrificealtar/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!has_buckled_mobs())
		return
	var/mob/living/L = locate() in buckled_mobs
	if(!L)
		return
	to_chat(user, "<span class='notice'>You attempt to sacrifice [L] by invoking the sacrificial ritual.</span>")
	L.gib()
	message_admins("[ADMIN_LOOKUPFLW(user)] has sacrificed [key_name_admin(L)] on the sacrificial altar at [AREACOORD(src)].")

/obj/structure/healingfountain
	name = "healing fountain"
	desc = "A fountain containing the waters of life."
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "fountain"
	anchored = TRUE
	density = TRUE
	var/time_between_uses = 1800
	var/last_process = 0

/obj/structure/healingfountain/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(last_process + time_between_uses > world.time)
		to_chat(user, "<span class='notice'>The fountain appears to be empty.</span>")
		return
	last_process = world.time
	to_chat(user, "<span class='notice'>The water feels warm and soothing as you touch it. The fountain immediately dries up shortly afterwards.</span>")
	user.reagents.add_reagent(/datum/reagent/medicine/omnizine/godblood,20)
	update_icon()
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon)), time_between_uses)


/obj/structure/healingfountain/update_icon()
	if(last_process + time_between_uses > world.time)
		icon_state = "fountain"
	else
		icon_state = "fountain-red"

//Event structures

/obj/structure/event_barrier
	name = "weakened barrier"
	desc = "An unholy barrier, this one seems to have been weakened by the passage of time."
	icon = 'icons/effects/cult_effects.dmi'
	icon_state = "weak_shield"
	max_integrity = 50
	density = TRUE
	anchored = TRUE
	light_range = 1
	light_color = LIGHT_COLOR_FIRE

/obj/structure/destructible/event_pylon
	name = "summoning pylon"
	desc = "An anchor to an extradimensional space. It would be wise to destroy this."
	icon = 'icons/obj/cult.dmi'
	icon_state = "pylon"
	density = TRUE
	anchored = TRUE
	max_integrity = 150
	light_range = 4
	light_power = 5
	light_color = LIGHT_COLOR_BLOOD_MAGIC
	break_sound = 'sound/effects/glassbr2.ogg'
	break_message = "<span class='warning'>The blood-red crystal falls to the floor and shatters!</span>"
	var/list/valid_mobs = list(/mob/living/simple_animal/hostile/netherworld/blankbody) //Placeholder mob
	var/trigger_delay = 100
	var/last_trigger = 0
	var/mobs_spawned = 0
	var/mobs_to_spawn = 3
	var/mob_spawn_chance = 25 //Don't set this higher than 100 or it runtimes
	var/do_tear_effect = TRUE //Used in subytypes
	var/damage_radius = 7

/obj/structure/destructible/event_pylon/Initialize(mapload)
	. = ..()
	if(mob_spawn_chance > 100)
		mob_spawn_chance = 100 //What did I say?
	return INITIALIZE_HINT_LATELOAD

/obj/structure/destructible/event_pylon/LateInitialize()
	. = ..()
	START_PROCESSING(SSfastprocess, src)

/obj/structure/destructible/event_pylon/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..(QDEL_HINT_QUEUE)

/obj/structure/destructible/event_pylon/process(delta_time)
	if(!anchored)
		return
	if(last_trigger <= world.time)
		last_trigger = world.time + trigger_delay
		var/has_spawned = FALSE // Prevents unintended duplicate spawns
		playsound(get_turf(src), 'sound/magic/magic_missile.ogg',35,1)
		new /obj/effect/temp_visual/cult/sparks(get_turf(src), "#960000")
		for(var/mob/living/L in oview(damage_radius, src))
			if(ishuman(L))
				L.adjustBruteLoss(25*delta_time, 0)
				L.updatehealth()
				to_chat(L, "<span class='danger'>Something saps your strength! </span>")
				new /obj/effect/temp_visual/cult/sparks(get_turf(L), "#960000")
		if(DT_PROB(mob_spawn_chance, delta_time) && mobs_spawned < mobs_to_spawn && !has_spawned)
			has_spawned = TRUE
			var/spawned_mob = pick(valid_mobs)
			if(do_tear_effect)
				new /obj/effect/temp_visual/cult/tear_full(get_turf(src))
			new spawned_mob(get_turf(src))
			playsound(get_turf(src), 'sound/magic/exit_blood.ogg',50,1)
			mobs_spawned++

/obj/structure/destructible/event_pylon/tear
	name = "tear"
	desc = "The boundary between worlds grows thin."
	icon = 'icons/effects/cult_effects.dmi'
	icon_state = "tear_open"
	break_message = "<span class='warning'>The tear begins to close!</span>"
	density = FALSE
	do_tear_effect = FALSE
	alpha = 200
	max_integrity = 50
	light_range = 2
	damage_radius = 3
	mobs_to_spawn = 2

/obj/structure/destructible/event_pylon/tear/Destroy()
	new /obj/effect/temp_visual/cult/tear_close(get_turf(src), "#960000")
	return ..()

/obj/structure/destructible/event_pylon/tear/process()
	. = ..()
	if(mobs_spawned >= mobs_to_spawn) //Temporary portal
		for(var/mob/living/L in oview(6, src))
			to_chat(L, "<span class='warning'>The tear begins to close!</span>")
		STOP_PROCESSING(SSfastprocess, src)
		qdel(src)

