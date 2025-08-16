/// Applies damage to the target, specified by inputting damagetype and amount
/datum/smite/apply_damage
	name = "Apply Damage"

/datum/smite/apply_damage/effect(client/user, mob/living/target)
	. = ..()
	var/list/damage_list = list(BRUTE, BURN, CLONE, OXY, STAMINA, TOX)
	var/damage_punishment = tgui_input_list(user, "Choose a damage type", "", sort_list(damage_list))
	var/damage_amount = tgui_input_number(user, "Choose an amount")
	if(!damage_punishment || !damage_amount)
		return

	target.apply_damage(damage_amount, damage_punishment, spread_damage = TRUE)
