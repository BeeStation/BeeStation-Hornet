/datum/component/enchantment/penetration
	max_level = 5

/datum/component/enchantment/penetration/apply_effect(obj/item/target)
	examine_description = "It has been blessed with the gift of armour penetration, allowing it to cut through targets with ease."
	target.sharpness = initial(target.sharpness) + 10 * level
