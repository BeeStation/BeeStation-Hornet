/datum/component/crilium
	var/time_alive
	var/stored_energy

/datum/component/crilium/Initialize(...)
	. = ..()
	START_PROCESSING(SSprocessing, src)
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(release_energy))
	RegisterSignal(parent, COMSIG_MOVABLE_THROW_LANDED, PROC_REF(release_energy))
	RegisterSignal(parent, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(release_energy))
	RegisterSignal(parent, COMSIG_PROJECTILE_PREHIT, PROC_REF(release_energy))
	RegisterSignal(parent, COMSIG_OBJ_DECONSTRUCT, PROC_REF(release_energy))

/datum/component/crilium/process(delta_time)
	var/turf/location = get_turf(parent)
	var/datum/gas_mixture/air = location.return_air()
	// Oxygen is its catalyst
	if (air.get_moles(GAS_O2) < 4)
		return
	var/atom/parent_atom = parent
	time_alive ++
	stored_energy += (time_alive * time_alive) * 0.001 * delta_time
	if (stored_energy > 150 && prob(5))
		parent_atom.visible_message("[parent_atom] briefly pulses, energising in the presence of oxygen.")
	if (stored_energy > 500000)
		// You are screwed
		release_energy()

/datum/component/crilium/proc/release_energy()
	SIGNAL_HANDLER
	var/atom/parent_atom = parent
	if (stored_energy < 100)
		return
	if (stored_energy < 300)
		parent_atom.visible_message("[parent_atom] releases a burst of energy!")
		do_sparks(CEILING(stored_energy/150, 1), FALSE, parent_atom)
		stored_energy = 0
		return
	if (stored_energy < 8000)
		parent_atom.visible_message("[parent_atom] releases a powerful burst of energy!")
		INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(empulse), parent_atom, (stored_energy / 8000) * 10, (stored_energy / 8000) * 15)
		stored_energy = 0
		time_alive = 0
		return
	explosion(parent_atom.loc, stored_energy < 400000 ? 0 : (stored_energy / 500000) * 6, (stored_energy / 500000) * 14, (stored_energy / 500000) * 20, (stored_energy / 500000) * 30)
	stored_energy = 0
	time_alive = 0
