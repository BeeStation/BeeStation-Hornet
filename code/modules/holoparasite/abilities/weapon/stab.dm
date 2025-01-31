/datum/holoparasite_ability/weapon/blade
	name = "Bladed"
	desc = "The $theme's fists become equipped with sharp blades, reducing their damage, but allowing them to pierce armor and cause bleeding."
	ui_icon = "fan"
	cost = 2
	thresholds = list(
		list(
			"stat" = "Damage",
			"desc" = "Increases the amount of damage dealt by attacks, and how much bleeding is dealt with each attack."
		),
		list(
			"stat" = "Potential",
			"desc" = "Increases the amount of armor penetration from attacks."
		)
	)
	/**
	 * Randomised between 50% and 100%
	 */
	var/bleed_level = BLEED_SURFACE

/datum/holoparasite_ability/weapon/blade/apply()
	. = ..()
	owner.ranged = FALSE
	owner.melee_damage = master_stats.damage * 3
	owner.armour_penetration = max(master_stats.potential - 1, 0) * 15
	if(isnull(owner.theme.mob_info[HOLOPARA_THEME_ATTACK_SOUND]))
		owner.attack_sound = 'sound/weapons/bladeslice.ogg'
	owner.response_harm_continuous = "stabs"
	owner.response_harm_simple = "stab"
	owner.attack_verb_continuous = "stabs"
	owner.attack_verb_simple = "stab"
	bleed_level = (master_stats.damage / 5) * (BLEED_DEEP_WOUND - BLEED_SURFACE) + BLEED_SURFACE

/datum/holoparasite_ability/weapon/blade/remove()
	. = ..()
	owner.ranged = initial(owner.ranged)
	owner.melee_damage = initial(owner.melee_damage)
	owner.armour_penetration = initial(owner.armour_penetration)
	if(isnull(owner.theme.mob_info[HOLOPARA_THEME_ATTACK_SOUND]))
		owner.attack_sound = initial(owner.attack_sound)
	owner.response_harm_continuous = initial(owner.response_harm_continuous)
	owner.response_harm_simple = initial(owner.response_harm_simple)
	owner.attack_verb_continuous = initial(owner.attack_verb_continuous)
	owner.attack_verb_simple = initial(owner.attack_verb_simple)

/datum/holoparasite_ability/weapon/blade/attack_effect(atom/movable/target, successful)
	. = ..()
	if(successful && ishuman(target))
		var/mob/living/carbon/human/human_target = target
		human_target.add_bleeding((rand(500, 1000) / 1000) * bleed_level)
