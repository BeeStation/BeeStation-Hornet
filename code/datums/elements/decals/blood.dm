/datum/element/decal/blood

/**
  * If you are annoyed by lack of blood decal visuals?
  * Then here's a TODO for you: rework the entire update_icon() family to make COMSIG_ATOM_UPDATE_OVERLAYS and update_overlays() work!
  * Until the rework, blood decal visuals might not work on some items... (but the name change will work, though)
  */

/datum/element/decal/blood/Attach(datum/target, _icon, _icon_state, _dir, _cleanable=CLEAN_STRENGTH_BLOOD, _color, _layer=ABOVE_OBJ_LAYER)
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	. = ..()

	RegisterSignal(target, COMSIG_ATOM_GET_EXAMINE_NAME, PROC_REF(get_examine_name), TRUE)

/datum/element/decal/blood/Detach(atom/source)
	UnregisterSignal(source, COMSIG_ATOM_GET_EXAMINE_NAME)
	return ..()

/datum/element/decal/blood/generate_appearance(_icon, _icon_state, _dir, _layer, _color, _alpha, source)
	var/obj/item/I = source
	if(!_icon)
		_icon = 'icons/effects/blood.dmi'
	if(!_icon_state)
		_icon_state = "itemblood"
	var/icon = I.icon
	var/icon_state = I.icon_state
	var/static/list/blood_splatter_appearances = list()
	//try to find a pre-processed blood-splatter. otherwise, make a new one
	var/index = "[REF(icon)]-[icon_state]"
	pic = blood_splatter_appearances[index]

	if(!pic)
		var/icon/blood_splatter_icon = icon(I.icon, I.icon_state, null, 1)
		blood_splatter_icon.Blend("#fff", ICON_ADD) 			//fills the icon_state with white (except where it's transparent)
		blood_splatter_icon.Blend(icon(_icon, _icon_state), ICON_MULTIPLY) //adds blood and the remaining white areas become transparant
		pic = mutable_appearance(blood_splatter_icon, I.icon_state)
		blood_splatter_appearances[index] = pic
	return TRUE

/datum/element/decal/blood/proc/get_examine_name(datum/source, mob/user, list/override)
	SIGNAL_HANDLER

	var/atom/A = source
	override[EXAMINE_POSITION_ARTICLE] = A.gender == PLURAL? "some" : "a"
	override[EXAMINE_POSITION_BEFORE] = " <span class='warning'>blood-stained</span> "
	return COMPONENT_EXNAME_CHANGED
