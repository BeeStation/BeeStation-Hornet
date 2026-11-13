/obj/projectile/energy/graviton_particle
	name = "graviton particle"
	icon_state = "nuclear_particle"
	pass_flags = PASSTABLE | PASSTRANSPARENT | PASSGRILLE
	armor_flag = ENERGY
	damage_type = BRUTE
	damage = 1
	speed = 0.5
	hitsound = 'sound/weapons/graviton_impact.ogg'
	impact_type = /obj/effect/projectile/impact/xray

	var/carried_energy = 0
