/*
	Each plant feature that uses needs implements it in its own way
	Typically, these are checked *every* tick, but stuff like roots probably don't
*/
/datum/plant_need
	///Daddy-o
	var/datum/plant_feature/parent
	///A brief insert of what this needs is - Essentially, this plant needs [need_description], and [need_description]
	var/need_description = ""
	///Can this need be a random overdraw need?
	var/overdraw_need = FALSE
//Buff stuff
	///is this need actually a buff? - Buff needs aren't needed to pass need checks
	var/buff = FALSE
	var/buff_applied = FALSE
	///Does this buff have negative effects when not met
	var/debuff = FALSE
	///Cooldown stuff for nectar buff toggle
	COOLDOWN_DECLARE(nectar_timer)
	var/nectar_buff_duration = 60 SECONDS
	///Buff overlay
	var/mutable_appearance/buff_appearance
	var/buff_color = "#f700ff"

/datum/plant_need/New(datum/plant_feature/_parent)
	. = ..()
	setup_parent(_parent)
	buff_appearance = mutable_appearance('icons/obj/hydroponics/features/generic.dmi', "buff", color = buff_color)
	var/matrix/n_transform = matrix()
	n_transform.Turn(rand(-90, 90))
	buff_appearance.transform = n_transform

/datum/plant_need/proc/setup_parent(_parent)
	parent = _parent
	if(!parent?.parent)
		RegisterSignal(parent, COMSIG_PF_ATTACHED_PARENT, PROC_REF(setup_component_parent))
	else
		setup_component_parent(parent.parent)

/datum/plant_need/proc/setup_component_parent(datum/source)
	SIGNAL_HANDLER

	if(!parent || !parent.parent)
		return
	RegisterSignal(parent.parent, COMSIG_PLANT_NECTAR_BUFF, PROC_REF(catch_nectar))

/datum/plant_need/proc/copy(datum/plant_feature/_parent, datum/plant_need/_need)
	var/datum/plant_need/new_need = _need || new type(_parent)
	return new_need

/datum/plant_need/proc/check_need(_delta_time)
	return

///Use this to give ourselves what we need to fufill our needs
/datum/plant_need/proc/fufill_need(atom/location)
	return

/datum/plant_need/proc/catch_nectar(datum/source)
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, nectar_timer))
		COOLDOWN_RESET(src, nectar_timer)
	COOLDOWN_START(src, nectar_timer, nectar_buff_duration)

/datum/plant_need/proc/apply_buff(__delta_time)
	//Buff visuals
	parent.parent?.plant_item.add_overlay(buff_appearance)
	return

/datum/plant_need/proc/remove_buff(__delta_time)
	parent.parent?.plant_item.cut_overlay(buff_appearance)
	return
