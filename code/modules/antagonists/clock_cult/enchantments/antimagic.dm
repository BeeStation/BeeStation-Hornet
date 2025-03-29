/datum/component/enchantment/anti_magic
	max_level = 1

/datum/component/enchantment/anti_magic/apply_effect(obj/item/target)
	examine_description = "It has been blessed with the gift of magic protection, preventing all magic from affecting the wielder."
	target.AddComponent(/datum/component/anti_magic, INNATE_TRAIT, (MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY))
