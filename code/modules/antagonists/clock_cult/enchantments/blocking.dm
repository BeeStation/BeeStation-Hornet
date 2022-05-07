/datum/component/enchantment/blocking
	max_level = 3

/datum/component/enchantment/blocking/apply_effect(obj/item/target)
	examine_description = "It has been blessed with the gift of blocking."
	target.block_level = min(level - 1, 1)
	target.block_power = level * 10
	target.block_upgrade_walk = 0
