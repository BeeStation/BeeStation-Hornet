/obj/projectile
	/// The last thing the projectile force-pierced due to holopara shenanigans.
	var/atom/movable/last_holopara_pierce

/obj/projectile/holoparasite
	name = "crystal spray"
	icon_state = "guardian"
	damage = 5
	damage_type = BRUTE

/obj/projectile/holoparasite/on_hit(atom/target, blocked = FALSE, pierce_hit)
	// Holoparasite projectiles will phase right through their summoner (or any of their summoner's other holoparasites)
	var/mob/living/simple_animal/hostile/holoparasite/holopara = firer
	if(istype(holopara) && holopara.has_matching_summoner(target))
		if(!last_holopara_pierce)
			SSblackbox.record_feedback("amount", "holoparasite_fired_projectile_phase", 1)
		if(last_holopara_pierce != target)
			last_holopara_pierce = target
			visible_message(span_holoparasite("\The [src] appears to degrade as it phases through [target]!"))
		// The projectile damage will degrade a bit when phasing through an ally, though.
		if(isholopara(target))
			var/mob/living/simple_animal/hostile/holoparasite/other_holopara = target
			other_holopara.degrade_projectile(src)
		else
			damage = max(FLOOR(damage * 0.8, 1), max(round(initial(damage) * 0.1), 1))
			armour_penetration = FLOOR(armour_penetration * 0.85, 1)
		return BULLET_ACT_FORCE_PIERCE
	return ..()

/**
 * Ensures all projectiles fired by the summoner phase through the holoparasite.
 */
/mob/living/simple_animal/hostile/holoparasite/bullet_act(obj/projectile/projectile)
	if(has_matching_summoner(projectile.firer))
		if(!projectile.last_holopara_pierce)
			SSblackbox.record_feedback("tally", "holoparasite_summoner_projectile_phase", 1, "[projectile.type]")
		if(projectile.last_holopara_pierce != src)
			projectile.last_holopara_pierce = src
			projectile.visible_message(span_holoparasite("\The [projectile] appears to degrade as it phases through [color_name]!"))
		degrade_projectile(projectile)
		return BULLET_ACT_FORCE_PIERCE
	return ..()

/**
 * Weakens a friendly projectile phasing through a holoparasite, proportional to the defense of the holoparasite.
 */
/mob/living/simple_animal/hostile/holoparasite/proc/degrade_projectile(obj/projectile/projectile)
	projectile.damage = max(FLOOR(projectile.damage * (stats.defense * 0.15), 1), max(round(initial(projectile.damage) * 0.1), 1))
	projectile.armour_penetration = FLOOR(projectile.armour_penetration * (stats.defense * 0.1), 1)
