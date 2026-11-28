#define TURTLE_SHELL_SOURCE "turtle_shell"

/mob/living/basic/turtle
	name = "Frank"
	desc = "An adorable, slow moving, Texas pal."
	icon = 'icons/mob/simple/pets.dmi'
	icon_state = "yeeslow"
	icon_living = "yeeslow"
	icon_dead = "yeeslow_dead"
	base_icon_state = "yeeslow"
	butcher_results = list(/obj/item/food/meat/slab = 1, /obj/item/clothing/head/franks_hat = 1)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	mobility_flags = MOBILITY_FLAGS_REST_CAPABLE_DEFAULT
	gold_core_spawnable = NO_SPAWN
	melee_damage = 0.5
	health = 2500
	maxHealth = 2500
	speed = 4
	can_be_held = TRUE
	chat_color = "#E7D26F"
	ai_controller = /datum/ai_controller/basic_controller/turtle

	/// If we're currently hiding in our shell or not
	var/hiding = FALSE
	/// How long we wait in our shell after being attacked
	var/hide_time = 25 SECONDS

/mob/living/basic/turtle/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/relay_attackers)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_SHOE)
	RegisterSignal(src, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))

/mob/living/basic/turtle/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state][hiding ? "_scared" : ""]"

/mob/living/basic/turtle/proc/on_attacked(mob/victim, atom/attacker)
	SIGNAL_HANDLER
	if(victim == attacker)
		return

	addtimer(CALLBACK(src, PROC_REF(emerge_from_shell)), hide_time, TIMER_UNIQUE | TIMER_OVERRIDE)
	if(hiding)
		return

	hiding = TRUE
	layer = MOB_LAYER
	manual_emote("hides in [p_their()] shell!")
	ADD_TRAIT(src, TRAIT_IMMOBILIZED, TURTLE_SHELL_SOURCE)
	update_appearance(UPDATE_ICON_STATE)

/mob/living/basic/turtle/proc/emerge_from_shell()
	hiding = FALSE
	layer = MOB_LAYER
	REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, TURTLE_SHELL_SOURCE)
	update_appearance(UPDATE_ICON_STATE)

//Bullets
/mob/living/basic/turtle/bullet_act(obj/projectile/hitting_projectile, def_zone, piercing_hit = FALSE)
	return hiding ? BULLET_ACT_FORCE_PIERCE : ..()

#undef TURTLE_SHELL_SOURCE
