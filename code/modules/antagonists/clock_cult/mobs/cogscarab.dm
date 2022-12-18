#define CLOCKDRONE	"drone_clock"

GLOBAL_LIST_INIT(cogscarabs, list())

//====Cogscarab====

/mob/living/simple_animal/drone/cogscarab
	name = "Cogscarab"
	desc = "A mechanical device, filled with twisting cogs and mechanical parts, built to maintain Reebe."
	icon_state = "drone_clock"
	icon_living = "drone_clock"
	icon_dead = "drone_clock_dead"
	health = 30
	maxHealth = 30
	faction = list("neutral", "silicon", "turret", "ratvar")
	default_storage = /obj/item/storage/belt/utility/servant/drone
	visualAppearence = CLOCKDRONE
	bubble_icon = "clock"
	picked = TRUE
	flavortext = "<span class=brass>You are a cogscarab, an intricate machine that has been granted sentient by Rat'var.<br>\
		After a long and destructive conflict, Reebe has been left mostly empty; you and the other cogscarabs like you were bought into existence to construct Reebe into the image of Rat'var.<br>\
		Construct defences, traps and forgeries, for opening the Ark requires an unimaginable amount of power which is bound to get the attention of selfish lifeforms interested only in their own self-preservation.</span>"
	laws = "You are have been granted the gift of sentience from Rat'var.<br>\
		You are not bound by any laws, do whatever you must to serve Rat'var!"
	chat_color = LIGHT_COLOR_CLOCKWORK
	mobchatspan = "brassmobsay"
	initial_language_holder = /datum/language_holder/clockmob
	discovery_points = 2000

//No you can't go wielding guns like that.
/mob/living/simple_animal/drone/cogscarab/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NOGUNS, "cogscarab")
	GLOB.cogscarabs += src
	add_actionspeed_modifier(/datum/actionspeed_modifier/cogscarab)

/mob/living/simple_animal/drone/cogscarab/death(gibbed)
	GLOB.cogscarabs -= src
	. = ..()

/mob/living/simple_animal/drone/cogscarab/Life(seconds, times_fired)
	if(!is_reebe(z) && !GLOB.ratvar_risen)
		var/turf/T = get_turf(pick(GLOB.servant_spawns))
		try_warp_servant(src, T, FALSE)
	. = ..()

/mob/living/simple_animal/drone/cogscarab/force_hit_projectile(obj/item/projectile/projectile)
	if(isliving(projectile.fired_from) && is_servant_of_ratvar(projectile.fired_from))
		return FALSE
	return TRUE

//====Shell====

/obj/effect/mob_spawn/cogscarab
	name = "cogscarab construct"
	desc = "The shell of an ancient construction drone, loyal to Ratvar."
	icon = 'icons/mob/drone.dmi'
	layer = BELOW_MOB_LAYER
	icon_state = "drone_clock_hat"
	mob_name = "cogscarab"
	mob_type = /mob/living/simple_animal/drone/cogscarab
	short_desc = "You are a cogscarab!"
	flavour_text = "You are a cogscarab, a tiny building construct of Ratvar. While you're weak and can't leave Reebe, \
	you have a set of quick tools, as well as a replica fabricator that can create brass for construction. Work with the servants of Ratvar \
	to construct and maintain defenses at the City of Cogs."
	ban_type = ROLE_SERVANT_OF_RATVAR

/obj/effect/mob_spawn/cogscarab/pre_configure()
	RegisterSignal(src, COMSIG_MOB_SPAWNER_DOSPECIAL, .proc/special)

/obj/effect/mob_spawn/cogscarab/proc/special(datum/source, mob/living/new_spawn, name)
	SIGNAL_HANDLER

	add_servant_of_ratvar(new_spawn, silent=TRUE)
