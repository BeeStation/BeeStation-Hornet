/// Applies damage to the target, specified by inputting damagetype and amount
/datum/smite/apply_damage
	name = "Apply Damage"

/datum/smite/apply_damage/effect(client/user, mob/living/target)
	. = ..()
	var/list/damage_list = subtypesof(/datum/damage)
	var/damage_punishment = tgui_input_list("Choose a damage type", sort_list(damage_list))
	var/damage_amount = tgui_input_number("Choose an amount")
	if(isnull(damage_punishment) || isnull(damage_amount)) //The user pressed "Cancel"
		return

	target.apply_damage(/datum/damage_source/magic/abstract, damage_amount, damage_punishment)
