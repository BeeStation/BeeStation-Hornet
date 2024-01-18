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
	 * The (maximum) amount of bleed damage with each hit.
	 * This is premultiplied by 10, and then randomized between 50% and 100% of the value.
	 * We need to pre-multiply by 10, as BYOND's rand() doesn't support decimal ranges, so we just multiply the final random value by 0.1.
	 */
	var/premultiplied_bleed_rate = 40

/datum/holoparasite_ability/weapon/blade/apply()
	. = ..()
	owner.ranged = FALSE
	owner.melee_damage = master_stats.damage * 3
	owner.armour_penetration = max(master_stats.potential - 1, 0) * 15
	if(isnull(owner.theme.mob_info[HOLOPARA_THEME_ATTACK_SOUND]))
		owner.attack_sound = 'sound/weapons/bladeslice.ogg'
	owner.response_harm = "stabs"
	owner.attacktext = "stabs"
	premultiplied_bleed_rate = master_stats.damage * 8

/datum/holoparasite_ability/weapon/blade/remove()
	. = ..()
	owner.ranged = initial(owner.ranged)
	owner.melee_damage = initial(owner.melee_damage)
	owner.armour_penetration = initial(owner.armour_penetration)
	if(isnull(owner.theme.mob_info[HOLOPARA_THEME_ATTACK_SOUND]))
		owner.attack_sound = initial(owner.attack_sound)
	owner.response_harm = initial(owner.response_harm)
	owner.attacktext = initial(owner.attacktext)

/datum/holoparasite_ability/weapon/blade/attack_effect(atom/movable/target, successful)
	. = ..()
	if(successful && ishuman(target))
		var/mob/living/carbon/human/human_target = target
		if(human_target.bleed_rate < 15)
			var/randomized_bleed_rate = rand(round(premultiplied_bleed_rate * 0.5), premultiplied_bleed_rate) * 0.1
			human_target.bleed_rate = clamp(human_target.bleed_rate + randomized_bleed_rate, 0, 15)
