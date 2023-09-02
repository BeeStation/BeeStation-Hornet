/datum/damage_source

/datum/damage_source/proc/apply_direct(mob/living/target, damage_type, damage_amount, target_zone = null, update_health = TRUE, forced = FALSE)
	if (target_zone)
		// Apply the damage
		var/datum/damage/damage = GET_DAMAGE(damage_type)
		// Target a specific bodypart
		var/obj/item/bodypart/targetted_bodypart = target.get_bodypart(check_zone(target_zone))
		if (!targetted_bodypart)
			if (iscarbon(target))
				var/mob/living/carbon/carbon_target = target
				if (!length(carbon_target.bodyparts))
					damage.apply_living(target, damage_amount, update_health, forced)
					return
				targetted_bodypart = pick(carbon_target.bodyparts)
			else
				// Apply globally
				damage.apply_living(target, damage_amount, update_health, forced)
				return
		damage.apply_bodypart(targetted_bodypart, damage_amount, update_health, forced)
	else
		// Target the whole body and apply the damage
		var/datum/damage/damage = GET_DAMAGE(damage_type)
		damage.apply_living(target, damage_amount, update_health, forced)

/datum/damage_source/proc/deal_attack(mob/living/attacker, obj/item/sttacking_item, atom/target, damage_type, damage_amount, target_zone = null, update_health = TRUE, forced = FALSE)
