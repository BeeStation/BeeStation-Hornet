#define DELAY_BETWEEN_RADIATION_PULSES (3 SECONDS)

/// This atom will regularly pulse radiation.
/datum/element/radioactive
	element_flags = ELEMENT_DETACH | ELEMENT_BESPOKE
	id_arg_index = 2
	/// Range of our wave in tiles
	var/range
	/// Threshold for radioactive permeance
	var/threshold
	/// Intensity per radiation pulse
	var/intensity
	/// Minimum time needed in order to be irradiated
	var/minimum_exposure_time

	var/list/radioactive_objects = list()

/datum/element/radioactive/New()
	START_PROCESSING(SSdcs, src)

/datum/element/radioactive/Attach(
	datum/target,
	range = 3,
	threshold = RAD_LIGHT_INSULATION,
	intensity = URANIUM_IRRADIATION_INTENSITY,
	minimum_exposure_time = URANIUM_RADIATION_MINIMUM_EXPOSURE_TIME,
	)

	. = ..()

	radioactive_objects[target] = world.time

	src.range = range
	src.threshold = threshold
	src.intensity = intensity
	src.minimum_exposure_time = minimum_exposure_time

/datum/element/radioactive/Detach(datum/source, ...)
	radioactive_objects -= source
	return ..()

/datum/element/radioactive/process(delta_time)
	for (var/radioactive_object in radioactive_objects)
		if (world.time - radioactive_objects[radioactive_object] < DELAY_BETWEEN_RADIATION_PULSES)
			continue

		radiation_pulse(
			radioactive_object,
			max_range = range,
			threshold = threshold,
			intensity = intensity,
			minimum_exposure_time = minimum_exposure_time,
		)

		radioactive_objects[radioactive_object] = world.time

#undef DELAY_BETWEEN_RADIATION_PULSES
