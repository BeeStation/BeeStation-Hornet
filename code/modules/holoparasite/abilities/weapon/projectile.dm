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
			"desc" = "Increases the armor pentration of projectiles."
		)
	)

/datum/holoparasite_ability/weapon/ranged/apply()
	. = ..()
	owner.ranged = TRUE
	owner.melee_damage = 6 + round((master_stats.damage - 1) * 0.8) // barely stronger than a normal human punch
	owner.obj_damage = 6 + round((master_stats.damage - 1) * 0.8)
	owner.response_harm = "weakly punches"
	owner.attacktext = "weakly punches"

/datum/holoparasite_ability/weapon/ranged/remove()
	. = ..()
	owner.ranged = initial(owner.ranged)
	owner.melee_damage = initial(owner.melee_damage)
	owner.obj_damage = initial(owner.obj_damage)
	owner.response_harm = initial(owner.response_harm)
	owner.attacktext = initial(owner.attacktext)
