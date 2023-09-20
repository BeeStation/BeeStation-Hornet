/datum/holoparasite_ability/weapon/punch
	name = "Punch"
	desc = "The $theme simply attacks with blunt force, using its fists."
	ui_icon = "hand-rock"
	cost = 0
	thresholds = list(
		list(
			"stat" = "Damage",
			"desc" = "Increases the amount of damage dealt by punches."
		),
		list(
			"stat" = "Damage",
			"minimum" = 5,
			"desc" = "The $theme is capable of punching down non-reinforced walls. Can also be met with Damage 3 + Potential 4."
		),
		list(
			"stats" = list(
				list(
					"name" = "Damage",
					"minimum" = 3
				),
				list(
					"name" = "Potential",
					"minimum" = 4
				)
			),
			"desc" = "The $theme is capable of punching down non-reinforced walls. Can also be met with Damage 5."
		),
		list(
			"stats" = list(
				list(
					"name" = "Damage",
					"minimum" = 5
				),
				list(
					"name" = "Potential",
					"minimum" = 5
				)
			),
			"desc" = "The $theme is capable of punching down reinforced walls."
		)
	)

/datum/holoparasite_ability/weapon/punch/apply()
	. = ..()
	owner.melee_damage = master_stats.damage * 5
	owner.obj_damage = master_stats.damage * 16
	owner.armour_penetration = 0
	owner.ranged = FALSE
	if(isnull(owner.theme.mob_info[HOLOPARA_THEME_ATTACK_SOUND]))
		owner.attack_sound = "punch"
	if(master_stats.damage >= 5 || (master_stats.damage >= 3 && master_stats.potential >= 4))
		owner.environment_smash |= ENVIRONMENT_SMASH_WALLS
	if(master_stats.damage >= 5 && master_stats.potential >= 5)
		owner.environment_smash |= ENVIRONMENT_SMASH_RWALLS

/datum/holoparasite_ability/weapon/punch/remove()
	. = ..()
	owner.melee_damage = initial(owner.melee_damage)
	owner.obj_damage = initial(owner.obj_damage)
	owner.armour_penetration = initial(owner.armour_penetration)
	owner.ranged = initial(owner.ranged)
	if(isnull(owner.theme.mob_info[HOLOPARA_THEME_ATTACK_SOUND]))
		owner.attack_sound = initial(owner.attack_sound)
	owner.environment_smash = initial(owner.environment_smash)
