/////SINGULARITY SPAWNER
/obj/machinery/the_singularitygen
	name = "Gravitational Singularity Generator"
	desc = "An odd device which produces a Gravitational Singularity when set up."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "TheSingGen"
	anchored = FALSE
	density = TRUE
	use_power = NO_POWER_USE
	resistance_flags = FIRE_PROOF
	processing_flags = START_PROCESSING_MANUALLY // lets not do any processing when we do not have anything to do

	// You can buckle someone to the singularity generator, then start the engine. Fun!
	can_buckle = TRUE
	buckle_lying = 0
	buckle_requires_restraints = TRUE

	var/energy = 0
	var/creation_type = /obj/anomaly/singularity

/obj/machinery/the_singularitygen/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_WRENCH)
		default_unfasten_wrench(user, W, 0)
	else
		return ..()

/obj/machinery/the_singularitygen/bullet_act(obj/projectile/energy/accelerated_particle/P, def_zone, piercing_hit = FALSE)
	if(istype(P))
		if(energy <= 0) // we want to first add the energy then start processing so we do not immidiatly stop processing again
			energy += P.energy
			begin_processing()
			return
		energy += P.energy
	else
		. = ..()

/obj/machinery/the_singularitygen/process(delta_time)
	if(energy > 0)
		if(energy >= 200)
			var/turf/T = get_turf(src)
			SSblackbox.record_feedback("tally", "engine_started", 1, type)
			var/obj/anomaly/singularity/S = new creation_type(T, 50)
			transfer_fingerprints_to(S)
			qdel(src)
		else
			energy -= delta_time * 0.5
	else
		end_processing()
		energy = 0
