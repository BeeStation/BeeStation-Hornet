/// Applies damage to the target, specified by inputting damagetype and amount
/datum/smite/apply_damage
	name = "Apply Damage"

/datum/smite/apply_damage/effect(client/user, mob/living/target)
	. = ..()
	var/list/damage_list = list(BRUTE, BURN, CLONE, OXY, STAMINA, TOX)
	var/damage_punishment = input("Choose a damage type") as null|anything in sort_list(damage_list)
	var/damage_amount = input("Choose an amount") as null|num
	if(isnull(damage_punishment) || isnull(damage_amount)) //The user pressed "Cancel"
		return

	target.apply_damage_type(damage_amount, damage_punishment)
