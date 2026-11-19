/datum/element/decal/blood
	/// Emissive alpha of our parent
	var/emissive_alpha = null

/datum/element/decal/blood/Attach(datum/target, _icon, _icon_state, _dir, _cleanable = CLEAN_TYPE_BLOOD, _color, _layer = ABOVE_OBJ_LAYER, _emissive)
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	emissive_alpha = _emissive
	. = ..(target, _icon, _icon_state, _dir, _cleanable, _color, _layer)
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
	if(!_icon)
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
	if(emissive_alpha)
		var/mutable_appearance/emissive_splatter = emissive_appearance('icons/effects/blood.dmi', "itemblood", alpha = emissive_alpha)
		emissive_splatter.blend_mode = BLEND_INSET_OVERLAY
		pic.overlays += emissive_splatter
	return TRUE

/datum/element/decal/blood/proc/get_examine_name(datum/source, mob/user, list/override)
	SIGNAL_HANDLER

	var/atom/A = source
	var/list/blood_stains = GET_ATOM_BLOOD_DECALS(A)
	if(!length(blood_stains))
		return
	var/datum/blood_type/blood_type = blood_stains[blood_stains[length(blood_stains)]]
	var/blood_descriptor = "blood"
	if(istype(blood_type))
		blood_descriptor = LOWER_TEXT(blood_type.get_blood_name())
	override[EXAMINE_POSITION_ARTICLE] = A.gender == PLURAL? "some" : "a"
	override[EXAMINE_POSITION_BEFORE] = "[blood_descriptor]-stained"
	return COMPONENT_EXNAME_CHANGED
