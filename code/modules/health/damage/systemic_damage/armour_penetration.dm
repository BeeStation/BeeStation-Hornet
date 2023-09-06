
/**
 * Get the armour penetration value of this item as the attacker
 * and mutate source with that.
 */
/atom/damage_get_armour_penetration(datum/damage_source/source)
	return

/obj/item/damage_get_armour_penetration(datum/damage_source/source)
	source.armour_penetration = armour_penetration

/mob/living/simple_animal/damage_get_armour_penetration(datum/damage_source/source)
	source.armour_penetration = armour_penetration
