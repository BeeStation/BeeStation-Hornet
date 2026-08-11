/datum/component/height_filter
	///What textures we use for the displacement filter
	var/list/displacement_textures = list()
	///Strength of the displacement filter, generally you should set this on your species using their height variables
	var/intensity = 1

/datum/component/height_filter/Initialize(_icon, _state, _intensity)
	. = ..()
	intensity = _intensity || pick(list(BODY_SIZE_SHORT, BODY_SIZE_NORMAL, BODY_SIZE_TALL))
//Catch signals for dynamic updates
	RegisterSignal(parent, COMSIG_CARBON_HEIGHT_UPDATE, PROC_REF(update_displacement))
	RegisterSignal(parent, COMSIG_ATOM_DIR_CHANGE, PROC_REF(translate_dir))
//Populate textures
	for(var/direction as anything in GLOB.cardinals)
		//We have to convert the keys to strings because... keys
		displacement_textures["[direction]"] = icon(_icon, _state, direction)
//Apply effects
	var/mob/living/carbon/target = parent
	//Weird little fix - if height < 0, our guy gets cut off!! We can fix this by layering an invisible 64x64 icon, aka the displacement
	target.add_filter("height_cutoff_fix", 1, layering_filter(icon = displacement_textures["[NORTH]"], color = "#ffffff00"))
	update_displacement(src, intensity)

/datum/component/height_filter/Destroy()
	. = ..()
	var/mob/living/carbon/target = parent
	if(!target) //Stop a naughty runtime associated with ghosts > select equipment
		return
	UnregisterSignal(target, COMSIG_CARBON_HEIGHT_UPDATE)
	UnregisterSignal(target, COMSIG_ATOM_DIR_CHANGE)
	target.remove_filter("species_height_displacement")
	target.remove_filter("height_cutoff_fix")

/datum/component/height_filter/proc/update_displacement(datum/source, _intensity, _dir_override)
	SIGNAL_HANDLER

	intensity = _intensity || intensity
	var/mob/living/carbon/target = parent
	target.remove_filter("species_height_displacement")
	target.add_filter("species_height_displacement", 1.1, displacement_map_filter(icon = displacement_textures["[_dir_override || target.dir]"], y = 8, size = intensity))

/datum/component/height_filter/proc/translate_dir(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER

	if(!("[new_dir]" in displacement_textures)) //Stops directions unsupported by the icon getting through
		return
	update_displacement(src, intensity, _dir_override = new_dir)
