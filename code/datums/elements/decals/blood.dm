/datum/element/decal/blood

/datum/element/decal/blood/Attach(datum/target, _icon, _icon_state, _dir, _cleanable = CLEAN_TYPE_BLOOD, _color, _layer = ABOVE_OBJ_LAYER)
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	. = ..()
	if(. == ELEMENT_INCOMPATIBLE)
		return
	var/obj/item/bloodied = target
	ADD_KEEP_TOGETHER(bloodied, type)
	RegisterSignal(target, COMSIG_ATOM_GET_EXAMINE_NAME, PROC_REF(get_examine_name), TRUE)

/datum/element/decal/blood/Detach(obj/item/source, force)
	UnregisterSignal(source, COMSIG_ATOM_GET_EXAMINE_NAME)
	REMOVE_KEEP_TOGETHER(source, type)
	return ..()

/datum/element/decal/blood/generate_appearance(_icon, _icon_state, _dir, _layer, _color, _alpha, source)
	if(!_icon || !_icon_state)
		return FALSE
	if(!_color)
		_color = BLOOD_COLOR_RED
	var/list/dimensions = get_icon_dimensions(_icon)
	var/width = dimensions["width"]
	var/height = dimensions["height"]
	pic = mutable_appearance('icons/effects/blood.dmi', "itemblood", appearance_flags = RESET_COLOR, color = _color)
	var/matrix/splatter_transform = matrix()
	splatter_transform.Scale(width / ICON_SIZE_X, height / ICON_SIZE_Y)
	// Scaling is around the 32x32 sprite's centre, so shift it back over the item's bottom-left-anchored icon
	splatter_transform.Translate((width - ICON_SIZE_X) / 2, (height - ICON_SIZE_Y) / 2)
	pic.transform = splatter_transform
	pic.blend_mode = BLEND_INSET_OVERLAY
	return TRUE

/datum/element/decal/blood/proc/get_examine_name(datum/source, mob/user, list/override)
	SIGNAL_HANDLER

	var/atom/A = source
	override[EXAMINE_POSITION_ARTICLE] = A.gender == PLURAL? "some" : "a"
	override[EXAMINE_POSITION_BEFORE] = "blood-stained"
	return COMPONENT_EXNAME_CHANGED
