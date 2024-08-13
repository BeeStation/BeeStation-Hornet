/datum/holoparasite_ability/weapon/ranged
	name = "Ranged"
	desc = "The $theme exchanges blunt force for the ability to fire powerful, sharp projectiles."
	ui_icon = "meteor"
	cost = 3
	thresholds = list(
		list(
			"stat" = "Damage",
			"desc" = "Increases the amount of damage dealt by projectiles, and how much bleeding is dealt with each attack."
		),
		list(
			"stat" = "Potential",
			"desc" = "Increases the armor penetration of projectiles."
		)
	)

/datum/holoparasite_ability/weapon/ranged/apply()
	. = ..()
	owner.ranged = TRUE
	owner.ranged_cooldown_time = 17.5 / master_stats.speed
	owner.melee_damage = 6 + round((master_stats.damage - 1) * 0.8) // barely stronger than a normal human punch
	owner.obj_damage = 6 + round((master_stats.damage - 1) * 0.8)
	owner.response_harm_continuous = "weakly punches"
	owner.response_harm_simple = "weakly punch"
	owner.attack_verb_continuous = "weakly punches"
	owner.attack_verb_simple = "weakly punch"

/datum/holoparasite_ability/weapon/ranged/remove()
	. = ..()
	owner.ranged = initial(owner.ranged)
	owner.ranged_cooldown_time = initial(owner.ranged_cooldown_time)
	owner.melee_damage = initial(owner.melee_damage)
	owner.obj_damage = initial(owner.obj_damage)
	owner.response_harm_continuous = initial(owner.response_harm_continuous)
	owner.response_harm_simple = initial(owner.response_harm_simple)
	owner.attack_verb_continuous = initial(owner.attack_verb_continuous)
	owner.attack_verb_simple = initial(owner.attack_verb_simple)
