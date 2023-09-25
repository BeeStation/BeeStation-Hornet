/datum/holoparasite_ability/weapon/dextrous
	name = "Dextrous"
	desc = "The $theme itself is physically weak - instead, it relies on weapons to attack."
	ui_icon = "hands"
	cost = 0
	hidden = TRUE

/datum/holoparasite_ability/weapon/dextrous/can_buy()
	return ..() && istype(master_stats.ability, /datum/holoparasite_ability/major/dextrous)

/datum/holoparasite_ability/weapon/dextrous/apply()
	. = ..()
	owner.melee_damage = 6 + round((master_stats.damage - 1) * 0.8) // approximately the same as an average human's punch
	owner.obj_damage = 0
	owner.armour_penetration = 0
	owner.ranged = FALSE
	if(isnull(owner.theme.mob_info[HOLOPARA_THEME_ATTACK_SOUND]))
		owner.attack_sound = "punch"
	owner.response_harm = "weakly punches"
	owner.attacktext = "weakly punches"
	owner.environment_smash = NONE

/datum/holoparasite_ability/weapon/dextrous/remove()
	. = ..()
	owner.melee_damage = initial(owner.melee_damage)
	owner.obj_damage = initial(owner.obj_damage)
	owner.armour_penetration = initial(owner.armour_penetration)
	owner.ranged = initial(owner.ranged)
	if(isnull(owner.theme.mob_info[HOLOPARA_THEME_ATTACK_SOUND]))
		owner.attack_sound = initial(owner.attack_sound)
	owner.response_harm = initial(owner.response_harm)
	owner.attacktext = initial(owner.attacktext)
	owner.environment_smash = initial(owner.environment_smash)
