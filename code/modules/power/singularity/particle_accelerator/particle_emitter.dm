/obj/structure/particle_accelerator/particle_emitter
	name = "EM Containment Grid"
	desc = "This launches the Alpha particles, might not want to stand near this end."
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	icon_state = "none"
	var/fire_delay = 50
	var/last_shot = 0

/obj/structure/particle_accelerator/particle_emitter/center
	icon_state = "emitter_center"
	reference = "emitter_center"

/obj/structure/particle_accelerator/particle_emitter/left
	icon_state = "emitter_left"
	reference = "emitter_left"

/obj/structure/particle_accelerator/particle_emitter/right
	icon_state = "emitter_right"
	reference = "emitter_right"

/obj/structure/particle_accelerator/particle_emitter/proc/set_delay(delay)
	if(delay >= 0)
		fire_delay = delay
		return 1
	return 0

/obj/structure/particle_accelerator/particle_emitter/proc/emit_particle(strength = 0)
	if((last_shot + fire_delay) <= world.time)
		last_shot = world.time
		var/obj/projectile/energy/accelerated_particle/P
		switch(strength)
			if(0)
				P = /obj/projectile/energy/accelerated_particle/weak
			if(1)
				P = /obj/projectile/energy/accelerated_particle
			if(2)
				P = /obj/projectile/energy/accelerated_particle/strong
			if(3)
				P = /obj/projectile/energy/accelerated_particle/powerful
		P = new P(src)
		P.fire(dir2angle(dir))
		return TRUE
	return FALSE
