/* Orbital reentry scanning subsystem
 * We are moving the raycasts into a separate subsystem from damage application to allow for more robust performance optimization.
 * We'll allot this subsystem a specific amount of raycasts per fire() depending on how well the game is running right now.
 *
 * We determine a direction from which we will start scanning based on the map config (generally the direction from which the station would be reentering),
 * and then assign all coordinates along that axis to a list randomly. Each fire, we iterate inside that list x number of entries and raycast from there.
 * We then save the results of those raycasts for use by the other subsystems.
 *
 * After we have finished scanning through the entire coordinate list, we move back to the beginning by resetting the counter.
 *
 * We additionally ensure that the target turf list is only as long as the axis is long, by culling the oldest entries once we exceed the max length.
 * Otherwise, we could end up with a huge list of target turfs that would cause performance issues when we try to iterate through it every fire.
 */

SUBSYSTEM_DEF(orbital_reentry_scanning)
	name = "Orbital Reentry Scanning"
	wait = 1 SECONDS
	dependencies = list(
		/datum/controller/subsystem/mapping,
		/datum/controller/subsystem/atoms,
		/datum/controller/subsystem/orbital_altitude,
	)
	// Only allowed to use small portions of tick
	priority = FIRE_PRIORITY_STATION_ALTITUDE
	runlevels = RUNLEVEL_GAME
	/// Station levels
	var/list/station_levels
	/// Record our current work position
	var/work_z
	var/work_coord
	/// Direction flames come from (based on map config)
	var/reentry_direction = EAST
	var/list/created_fires = list()
	/// Is the subsystem currently active (altitude-based)?
	var/erosion_active = FALSE



// TODO: MOVE RAYCAST LOGIC FROM orbital_reentry_erosion.dm TO HERE.
// WE ALSO MAKE SURE THE LOGIC FOR WHEN TO RUN THIS IS CONTAININED OVER IN orbital_altitude.dm, BUT HOW WE RUN THIS IS IN HERE.
// so we basically turn this puppy on/off based on altitude over there, and if we are on, we operate on the altitude provided to us accordingly.
