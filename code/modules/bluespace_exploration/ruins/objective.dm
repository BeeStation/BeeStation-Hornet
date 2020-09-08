#define OBJECTIVE_HOSTILE_TYPE_NONE "none"
#define OBJECTIVE_HOSTILE_TYPE_SYNDICATE "syndicate"
#define OBJECTIVE_HOSTILE_TYPE_NANOTRASEN "nanotrasen"
#define OBJECTIVE_HOSTILE_TYPE_LAVALAND "lavaland"
#define OBJECTIVE_HOSTILE_TYPE_ASTEROID "asteroid"

#define OBJECTIVE_HOSTILE_LIST_NONE list()
#define OBJECTIVE_HOSTILE_LIST_SYNDICATE list(/mob/living/simple_animal/hostile/syndicate/ranged/smg/space=4, /mob/living/simple_animal/hostile/syndicate/ranged/shotgun/space/stormtrooper=3, /mob/living/simple_animal/hostile/syndicate/melee/sword/space/stormtrooper=10, /mob/living/simple_animal/hostile/syndicate/mecha_pilot=1)
#define OBJECTIVE_HOSTILE_LIST_NANOTRASEN list()
#define OBJECTIVE_HOSTILE_LIST_LAVALAND list(/mob/living/simple_animal/hostile/asteroid/basilisk/watcher=2, /mob/living/simple_animal/hostile/asteroid/goliath/beast=3,/mob/living/simple_animal/hostile/asteroid/hivelord/legion=5)
#define OBJECTIVE_HOSTILE_LIST_ASTEROID list(/mob/living/simple_animal/hostile/asteroid/fugu=2, /mob/living/simple_animal/hostile/asteroid/basilisk=4, /mob/living/simple_animal/hostile/asteroid/goliath=3, /mob/living/simple_animal/hostile/asteroid/basilisk=4)

#define MOB_DICTIONARY list(\
	OBJECTIVE_HOSTILE_TYPE_NONE = OBJECTIVE_HOSTILE_LIST_NONE,\
	OBJECTIVE_HOSTILE_TYPE_SYNDICATE = OBJECTIVE_HOSTILE_LIST_SYNDICATE,\
	OBJECTIVE_HOSTILE_TYPE_NANOTRASEN = OBJECTIVE_HOSTILE_LIST_NANOTRASEN,\
	OBJECTIVE_HOSTILE_TYPE_LAVALAND = OBJECTIVE_HOSTILE_LIST_LAVALAND,\
	OBJECTIVE_HOSTILE_TYPE_ASTEROID = OBJECTIVE_HOSTILE_LIST_ASTEROID,\
)

/*
 * Objective machine
 * ==================
 * One of the reasons to be on a z-level
 * Can grant research powers and other goodies, but needs to be protected for a while
*/

/obj/structure/destructible/exploration/objective
	name = "bluespace analyser"
	desc = "A large device with multiple blinking lights."
	icon = 'icons/obj/machines/dominator.dmi'
	icon_state = "dominator"
	density = TRUE
	anchored = TRUE
	layer = HIGH_OBJ_LAYER
	max_integrity = 200
	move_resist = INFINITY
	armor = list("melee" = 20, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = 10, "bio" = 100, "rad" = 100, "fire" = 10, "acid" = 70)
	var/completed = FALSE
	var/active = FALSE
	var/collected = FALSE
	var/activation_tick = 0
	var/completion_time = 600
	var/hostile_type = OBJECTIVE_HOSTILE_TYPE_NONE

/obj/structure/destructible/exploration/objective/pre_completed
	completed = TRUE

/obj/structure/destructible/exploration/objective/examine(mob/user)
	. = ..()
	if(collected)
		. += "Whatever it was doing it isn't doing anymore, as it seems to contain no data and be devoid of life.\n"
	else if(completed)
		. += "Its intended purpose has been served and the data inside can be extracted with a <b>TBD</b>.\n"
	else if(active)
		. += "It is working on something, better keep it running.\n"
		. += "It will be done in <b>[get_ticks_until_done() / 10]</b> seconds.\n"
	else
		. += "It seems like it could still work, just needs someone to get it started.\n"

/obj/structure/destructible/exploration/objective/attack_hand(mob/user)
	. = ..()
	if(active || completed)
		to_chat(user, "<span class='notice'>There is nothing you can do with [src]!</span>")
		return
	activation_tick = world.time
	active = TRUE
	START_PROCESSING(SSobj, src)

/obj/structure/destructible/exploration/objective/proc/get_ticks_until_done()
	return max((activation_tick + completion_time) - world.time, 0)
