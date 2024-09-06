/obj/projectile/energy/declone
	name = "radiation beam"
	icon_state = "declone"
	damage = 20
	damage_type = CLONE
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser

	/// The chance to be irradiated on hit
	var/radiation_chance = 30

/obj/projectile/energy/declone/on_hit(atom/target, blocked, pierce_hit)
	if (ishuman(target) && prob(radiation_chance))
		radiation_pulse(target, max_range = 0, threshold = RAD_FULL_INSULATION)

	..()

/obj/projectile/energy/declone/weak
	damage = 9
	radiation_chance = 10

/obj/projectile/energy/dart //ninja throwing dart
	name = "dart"
	icon_state = "toxin"
	damage = 5
	damage_type = TOX
	paralyze = 100
	range = 7
