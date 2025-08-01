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
	var/seasonal_hats = TRUE //If TRUE, and there are no default hats, different holidays will grant different hats
	var/static/list/possible_seasonal_hats //This is built automatically in build_seasonal_hats() but can also be edited by admins!

/obj/effect/mob_spawn/drone/Initialize(mapload)
	. = ..()
	var/area/A = get_area(src)
	if(A)
		notify_ghosts("A drone shell has been created in \the [A.name].", source = src, action=NOTIFY_ATTACK, flashwindow = FALSE, ignore_key = POLL_IGNORE_DRONE, notify_suiciders = FALSE)
	AddElement(/datum/element/point_of_interest)
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

//ATTACK GHOST IGNORING PARENT RETURN VALUE
/obj/effect/mob_spawn/drone/attack_ghost(mob/user)
	if(is_banned_from(user.ckey, ROLE_DRONE) || QDELETED(src) || QDELETED(user))
		return
	if(!SSticker.HasRoundStarted())
		to_chat(user, "Can't become a drone before the game has started.")
		return
	var/be_drone = alert("Become a drone? (Warning, You can no longer be cloned!)",,"Yes","No")
	if(be_drone != "Yes" || QDELETED(src) || !isobserver(user))
		return
	var/mob/living/simple_animal/drone/D = new mob_type(get_turf(loc))
	if(!D.default_hatmask && seasonal_hats && possible_seasonal_hats.len)
		var/hat_type = pick(possible_seasonal_hats)
		var/obj/item/new_hat = new hat_type(D)
		D.equip_to_slot_or_del(new_hat, ITEM_SLOT_HEAD)
	D.flags_1 |= (flags_1 & ADMIN_SPAWNED_1)
	D.key = user.key
	message_admins("[ADMIN_LOOKUPFLW(user)] has taken possession of \a [src] in [AREACOORD(src)].")
	log_game("[key_name(user)] has taken possession of \a [src] in [AREACOORD(src)].")
	qdel(src)

#undef DRONE_MINIMUM_AGE
