#define DRONE_MINIMUM_AGE 14

///////////////////
//DRONES AS ITEMS//
///////////////////
//Drone shells

//DRONE SHELL
/obj/effect/mob_spawn/drone
	name = "drone shell"
	desc = "A shell of a maintenance drone, an expendable robot built to perform station repairs."
	icon = 'icons/mob/drone.dmi'
	icon_state = "drone_maint_hat"//yes reuse the _hat state.
	layer = BELOW_MOB_LAYER
	density = FALSE
	death = FALSE
	roundstart = FALSE
	short_desc = "You are a drone."
	flavour_text = "You are a drone, a tiny insect-like creature. Follow your assigned laws to the best of your ability."
	mob_type = /mob/living/simple_animal/drone
	ban_type = ROLE_DRONE
	byond_account_age_required = DRONE_MINIMUM_AGE
	var/seasonal_hats = TRUE //If TRUE, and there are no default hats, different holidays will grant different hats
	var/static/list/possible_seasonal_hats //This is built automatically in build_seasonal_hats() but can also be edited by admins!

/obj/effect/mob_spawn/drone/Initialize(mapload)
	. = ..()
	var/area/A = get_area(src)
	if(A)
		notify_ghosts("A drone shell has been created in \the [A.name].", source = src, action=NOTIFY_ATTACK, flashwindow = FALSE, ignore_key = POLL_IGNORE_DRONE, notify_suiciders = FALSE)
	if(isnull(possible_seasonal_hats))
		build_seasonal_hats()

/obj/effect/mob_spawn/drone/proc/build_seasonal_hats()
	possible_seasonal_hats = list()
	if(!length(SSevents.holidays))
		return //no holidays, no hats; we'll keep the empty list so we never call this proc again
	for(var/V in SSevents.holidays)
		var/datum/holiday/holiday = SSevents.holidays[V]
		if(holiday.drone_hat)
			possible_seasonal_hats += holiday.drone_hat

/obj/effect/mob_spawn/drone/proc/special(datum/source, mob/living/new_spawn)
	if(!isdrone(new_spawn))
		return
	var/mob/living/simple_animal/drone/D = new_spawn
	if(!D.default_hatmask && seasonal_hats && possible_seasonal_hats.len)
		var/hat_type = pick(possible_seasonal_hats)
		var/obj/item/new_hat = new hat_type(D)
		D.equip_to_slot_or_del(new_hat, ITEM_SLOT_HEAD)

