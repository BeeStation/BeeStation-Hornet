/datum/element/decal/blood

/datum/element/decal/blood/Attach(datum/target, _icon, _icon_state, _dir, _cleanable=CLEAN_TYPE_BLOOD, _color, _layer=ABOVE_OBJ_LAYER)
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	. = ..()
	RegisterSignal(target, COMSIG_ATOM_GET_EXAMINE_NAME, PROC_REF(get_examine_name), TRUE)

/datum/element/decal/blood/Detach(atom/source, force)
	UnregisterSignal(source, COMSIG_ATOM_GET_EXAMINE_NAME)
	return ..()

/datum/element/decal/blood/generate_appearance(_icon, _icon_state, _dir, _layer, _color, _alpha, source)
	if(!_icon || !_icon_state)
		return FALSE
	if(!_color)
		_color = COLOR_BLOOD
	var/icon/blood_splatter_icon = icon(_icon, _icon_state, , 1) //we only want to apply blood-splatters to the initial icon_state for each object
	blood_splatter_icon.Blend("#fff", ICON_ADD) //fills the icon_state with white (except where it's transparent)
	blood_splatter_icon.Blend(icon('icons/effects/blood.dmi', "itemblood"), ICON_MULTIPLY) //adds blood and the remaining white areas become transparant
	pic = mutable_appearance(blood_splatter_icon)
	pic.color = _color
	return TRUE

/datum/element/decal/blood/proc/get_examine_name(datum/source, mob/user, list/override)
	SIGNAL_HANDLER

	var/atom/A = source
	override[EXAMINE_POSITION_ARTICLE] = A.gender == PLURAL? "some" : "a"
	override[EXAMINE_POSITION_BEFORE] = "blood-stained"
	return COMPONENT_EXNAME_CHANGED
