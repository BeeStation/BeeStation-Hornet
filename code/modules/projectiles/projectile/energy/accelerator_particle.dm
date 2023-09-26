/obj/projectile/energy/accelerated_particle
	name = "Accelerated Particles"
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	icon_state = "particle"
	range = 10
	speed = 1
	projectile_piercing = PASSMOB | PASSANOMALY | PASSMACHINE
	projectile_phasing = (ALL & (~PASSMOB) & (~PASSBLOB) & (~PASSANOMALY) & (~PASSMACHINE))
	suppressed = SUPPRESSED_VERY //we don't want every machine that gets hit to spam chat
	hitsound = null
	irradiate = 60
	var/energy = 10
	var/stop_dissipate = FALSE

/obj/projectile/energy/accelerated_particle/singularity_pull()
	return

/obj/projectile/energy/accelerated_particle/weak
	range = 8
	energy = 5
	irradiate = 30
	stop_dissipate = TRUE //because its supposed to keep the singu/tesla stable at the same size

/obj/projectile/energy/accelerated_particle/strong
	range = 15
	energy = 15
	irradiate = 90
/obj/projectile/energy/accelerated_particle/powerful
	range = 20
	energy = 50
	irradiate = 300
