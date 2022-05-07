/datum/component/enchantment/tiny
	max_level = 1

/datum/component/enchantment/tiny/apply_effect(obj/item/target)
	examine_description = "It has been blessed and distorts reality into a tiny space around it."
	target.w_class = WEIGHT_CLASS_TINY
