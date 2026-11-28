/mob/living/simple_animal/friendly_fruit
	name = "hortus"
	desc = "A mischeveous forest 'spirit'."
	icon_state = "fruit_friend"
	icon_living = "fruit_friend"
	icon_dead = "fruit_friend_dead"
	gender = NEUTER
	speak_chance = 0
	turns_per_move = 5
	maxHealth = 15
	health = 15
	see_in_dark = 3
	response_help_continuous = "prods"
	response_help_simple = "prod"
	response_disarm_continuous = "pushes aside"
	response_disarm_simple = "push aside"
	response_harm_continuous = "pokes"
	response_harm_simple = "poke"
	melee_damage = 1
	attack_verb_continuous = "pokes"
	attack_verb_simple = "poke"
	pass_flags = PASSTABLE | PASSMOB
	density = FALSE
	faction = list(FACTION_PLANTS)
	speed = -1

	mobchatspan = "headofsecurity"
	discovery_points = 1000

	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 150
	maxbodytemp = 500
	gold_core_spawnable = FRIENDLY_SPAWN

/mob/living/simple_animal/friendly_fruit/Initialize(mapload)
	. = ..()
	color = pick(list("#FF4848", "#5DFF5D", "#FFFF00", "#66FFFF"))

/mob/living/simple_animal/friendly_fruit/proc/splat()
	apply_damage(maxHealth, BRUTE)

/mob/living/simple_animal/friendly_fruit/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	var/static/rotation_dir = 1
	var/matrix/o_transform = transform
	var/matrix/n_transform = matrix(transform)
	n_transform.Turn(45*(rotation_dir ? 1 : -1))
	n_transform.Translate(3*(rotation_dir ? 1 : -1), 5)
	animate(src, transform = n_transform, time = 0.068 SECONDS, easing = LINEAR_EASING)
	animate(transform = o_transform, time = 0.6 SECONDS, easing = ELASTIC_EASING)
	rotation_dir = !rotation_dir

/mob/living/simple_animal/friendly_fruit/attack_ghost(mob/dead/observer/user)
	if(client || key || ckey)
		to_chat(user, span_warning("\The [src] already has a player."))
		return
	if(stat == DEAD)
		to_chat(user, span_warning("\The [src] is not possessable!"))
		return
	var/control_ask = tgui_alert(usr, "Do you wish to take control of \the [src]", "Become [src]?", list("Yes", "No"))
	if(control_ask != "Yes" || QDELETED(src) || QDELETED(user))
		return
	key = user.key
	to_chat(src, span_boldwarning("Remember that you have forgotten all of your past lives and are a new person!"))

/mob/living/simple_animal/friendly_fruit/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	. = ..()
	var/datum/component/planter/plant_tray = attack_target.GetComponent(/datum/component/planter)
	if(!plant_tray || plant_tray.recent_bee_visit || !length(plant_tray.plants))
		return
	plant_tray.recent_bee_visit = TRUE
	addtimer(VARSET_CALLBACK(plant_tray, recent_bee_visit, FALSE), 10 SECONDS)
	for(var/datum/component/plant/plant_comp as anything in plant_tray.plants)
		SEND_SIGNAL(plant_comp, COMSIG_PLANT_BEE_BUFF)
