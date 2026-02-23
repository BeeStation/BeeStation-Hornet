/datum/element/height_filter
	var/list/displacement_textures = list(NORTH, SOUTH, EAST, WEST)
	var/intensity = 1

/datum/element/height_filter/Attach(datum/_target, _icon, _state, _intensity)
	. = ..()
	if(!iscarbon(_target))
		return ELEMENT_INCOMPATIBLE
	intensity = _intensity || pick(list(BODY_SIZE_SHORT, BODY_SIZE_NORMAL, BODY_SIZE_TALL))
//Catch signals for dynamic updates
	RegisterSignal(_target, COMSIG_CARBON_HEIGHT_UPDATE, PROC_REF(update_displacement))
	RegisterSignal(_target, COMSIG_ATOM_DIR_CHANGE, PROC_REF(translate_dir))
//Populate textures
	for(var/direction as anything in displacement_textures)
		displacement_textures[direction] = icon(_icon, _state, direction)
//Apply effects
	var/mob/living/carbon/target = _target
	//Weird little fix - if height < 0, our guy gets cut off!! We can fix this by layering an invisible 64x64 icon, aka the displacement
	target.add_filter("height_cutoff_fix", 1, layering_filter(icon = displacement_textures[target.dir], color = "#ffffff00"))
	update_displacement(src, target)

/datum/element/height_filter/Detach(datum/_target)
	. = ..()
	var/mob/living/carbon/target = _target
	UnregisterSignal(target, COMSIG_CARBON_HEIGHT_UPDATE)
	UnregisterSignal(target, COMSIG_ATOM_DIR_CHANGE)
	target.remove_filter("species_height_displacement")
	target.remove_filter("height_cutoff_fix")

/datum/element/height_filter/proc/update_displacement(datum/source, mob/living/carbon/_target, _intensity, _dir_override)
	SIGNAL_HANDLER

	intensity = _intensity || intensity
	_target.remove_filter("species_height_displacement")
	_target.add_filter("species_height_displacement", 1.1, displacement_map_filter(icon = displacement_textures[_dir_override || _target.dir], y = 8, size = intensity))

/datum/element/height_filter/proc/translate_dir(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER

	if(!(new_dir in displacement_textures)) //Stops directions unsupported by the icon getting through
		return
	update_displacement(src, source, _dir_override = new_dir)
