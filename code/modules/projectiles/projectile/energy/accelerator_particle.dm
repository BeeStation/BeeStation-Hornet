/obj/projectile/energy/accelerated_particle
	name = "Accelerated Particles"
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	icon_state = "particle"
	range = 10
	speed = 1
	projectile_piercing = PASSMOB | PASSANOMALY | PASSMACHINE
	projectile_phasing = (ALL & ~(PASSMOB | PASSBLOB | PASSANOMALY | PASSMACHINE))
	suppressed = SUPPRESSED_VERY //we don't want every machine that gets hit to spam chat
	hitsound = null
	damage = 10
	damage_type = TOX
	var/energy = 10
	var/stop_dissipate = FALSE

/obj/projectile/energy/accelerated_particle/singularity_pull(obj/anomaly/singularity/singularity, current_size)
	return

/obj/projectile/energy/accelerated_particle/weak
	range = 8
	energy = 5
	stop_dissipate = TRUE //because its supposed to keep the singu/tesla stable at the same size

/obj/projectile/energy/accelerated_particle/strong
	range = 15
	energy = 15
	damage = 20

/obj/projectile/energy/accelerated_particle/powerful
	range = 20
	energy = 50
	damage = 30
