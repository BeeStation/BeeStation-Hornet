/**
 * Display the attack message from the item used
 */
/atom/proc/display_attack_message(datum/damage_source/source)
	return

/obj/item/display_attack_message(datum/damage_source/source)
	if (isliving(source.target))
		var/mob/living/target = source.target
		target.send_item_attack_message(src, source.attacker, parse_zone(source.target_zone))

/mob/living/carbon/alien/humanoid/display_attack_message(datum/damage_source/source)
	playsound(loc, 'sound/weapons/slash.ogg', 25, 1, -1)
	source.target.visible_message("<span class='danger'>[src] slashes at [source.target]!</span>", \
		"<span class='userdanger'>[src] slashes at you!</span>")
