/mob/living/simple_animal/friendly_fruit
	name = "hortus"
	desc = "A mischeveous forest 'spirit'."
	icon_state = "fruit_friend"
	icon_living = "fruit_friend"
	icon_dead = "fruit_friend_dead"
	gender = NEUTER
	speak_chance = 0
	turns_per_move = 5
	maxHealth = 30
	health = 30
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

	mobchatspan = "headofsecurity"
	discovery_points = 1000

	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 150
	maxbodytemp = 500
	gold_core_spawnable = FRIENDLY_SPAWN

/mob/living/simple_animal/friendly_fruit/Initialize(mapload)
	. = ..()
	color = pick(list("#FF4848", "#5DFF5D", "#FFFF00", "#66FFFF"))

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
