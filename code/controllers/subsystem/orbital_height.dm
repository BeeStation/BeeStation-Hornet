// Even higher orbit, causing extreme radiation outside, and more frequent radstorms.
#define ORBITAL_ALTITUDE_HIGH_CRITICAL 130000
// High orbit, radiation starts here
#define ORBITAL_ALTITUDE_HIGH 120000
// The altitude at which the station orbits the planet at roundstart. This is where we want it to be normally. In meters.
#define ORBITAL_ALTITUDE_DEFAULT 110000
// The altitude at which the station is considered to be in low orbit, causing light structural damage.
#define ORBITAL_ALTITUDE_LOW 95000
// Critical orbit altitude, causing heavy structural damage. If you spend 10 minutes here without raising your orbit, goodbye station.
#define ORBITAL_ALTITUDE_LOW_CRITICAL 90000

/**
 * Orbital Altitude Subsystem
 * Handles the orbital altitude of the station, causing various effects based on altitude.
 * critical_failure() is called when the station experiences a game over condition due to low orbit.
 * This can be the case for a station that remains below 70km for 10 minutes, or a station that falls below 60km.
 */
SUBSYSTEM_DEF(orbital_altitude)
	name = "Orbital Altitude"
	can_fire = TRUE
	wait = 1 SECONDS
	flags = SS_NO_INIT | SS_KEEP_TIMING

	var/orbital_altitude = ORBITAL_ALTITUDE_DEFAULT

	var/velocity_index = 0 // Used for the consoles to tell the crew if we are gaining or losing altitude.

	// All below are meters per second, based on fire running every second. This might not be the case, please advise.
	var/thrust // Positive values raise orbit, negative values lower it.
	var/decay_rate // Scales with altitude.

	// Resistance, scales with altitude, reduces the effect of all vertical movement, decay and thrust alike. Caps at 0.5 at 70km, 1.0 at 90km.
	var/resistance = 1.0

	var/critical_orbit_timer = 0 // Timer for how long we've been in critical orbit.

/datum/controller/subsystem/orbital_altitude/fire(resumed = FALSE)
	if(SSmapping.current_map.planetary_station)
		can_fire = FALSE
		return // If we do this in initialize it yells at us about calling fire on a ss that doesn't fire, which this does.

	// Apply orbital altitude changes.
	orbital_altitude_change()

/datum/controller/subsystem/orbital_altitude/proc/orbital_altitude_change()
	var/orbital_altitude_change = 0

	// Determine decay rate and resistance based on current orbital altitude. Plug this mess into desmos if you want to see how it works.
	decay_rate = min( max( (-orbital_altitude * 0.0008) + 96, 0), 30)
	resistance = min( max( (orbital_altitude * 0.0001) - 8.5, 0.5), 1)

	// Thrust is set by the consoles separately, so we just use the current value.
	// We now have everything we need to update the orbital altitude.
	orbital_altitude_change -= decay_rate
	orbital_altitude_change += thrust
	orbital_altitude_change += rand(-5,5) / 10 // Small random fluctuation to make things less static.

	var/atmospheric_turbulence_chance = min( max( (-orbital_altitude * 0.01) +1000, 5), 100)
	if(prob(atmospheric_turbulence_chance)) // increasing chance with depth to have a bigger orbital fluctuation.
		var/fluctuation = rand(-(atmospheric_turbulence_chance / 20), atmospheric_turbulence_chance / 20)
		orbital_altitude_change += fluctuation

	// Update velocity index for consoles. We do this here to avoid including any kind of resistance effects.
	var/temp_index
	temp_index = orbital_altitude_change / 3 // Scale to a 10 point scale.
	velocity_index = temp_index //+ ( rand(-10,10) / 10 ) // Add a bit of randomness to make it less static.
	velocity_index = clamp(velocity_index, -10, 10)

	// Apply resistances to the change in orbital altitude.
	orbital_altitude_change *= resistance
	if(orbital_altitude <= 85000) // We are actually falling all the way. Make sure we go slower so we can't ever go below 70km for immersion
		orbital_altitude_change /= 2

	// We cap the maximum change to 30 m/s up or down to prevent extreme jumps.
	orbital_altitude_change = clamp(orbital_altitude_change, -30, 30)

	// Update orbital altitude
	orbital_altitude += orbital_altitude_change

	// Clamp orbital altitude to reasonable values.
	orbital_altitude = clamp(orbital_altitude, 80000, 140000)

#undef ORBITAL_ALTITUDE_HIGH_CRITICAL
#undef ORBITAL_ALTITUDE_HIGH
#undef ORBITAL_ALTITUDE_DEFAULT
#undef ORBITAL_ALTITUDE_LOW
#undef ORBITAL_ALTITUDE_LOW_CRITICAL
