/**
  * Can be applied to glasses to cause them to apply blurry vision and stuff
  */
/datum/element/dirty_glasses

/datum/element/dirty_glasses/Attach(datum/target)
	. = ..()
	if(!istype(target,/obj/item/clothing/glasses))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED), .proc/equippedChanged)

	RegisterSignal(target,COMSIG_COMPONENT_CLEAN_ACT,.proc/clean)

	RegisterSignal(target,COMSIG_PARENT_EXAMINE,.proc/examine)

	var/obj/item/clothing/glasses/glassies = target
	if(!ishuman(glassies.loc))
		return
	var/mob/user = glassies.loc
	var/list/screens = list(user.hud_used.plane_masters["[FLOOR_PLANE]"], user.hud_used.plane_masters["[GAME_PLANE]"], user.hud_used.plane_masters["[LIGHTING_PLANE]"])
	for(var/screen in screens)
		var/atom/movable/screen/plane_master/plane = screen
		plane.add_filter("dirty_glasses_ang_blur",10,list("type" = "angular_blur","x" = 0, "y" = 0,"size" = 7))
		plane.add_filter("dirty_glasses_blur",10,list("type" = "blur","size" = 2))

/datum/element/dirty_glasses/Detach(datum/source, force)
	var/obj/item/clothing/glasses/glassies = source
	if(!ishuman(glassies.loc))
		return
	var/mob/user = glassies.loc
	var/list/screens = list(user.hud_used.plane_masters["[FLOOR_PLANE]"], user.hud_used.plane_masters["[GAME_PLANE]"], user.hud_used.plane_masters["[LIGHTING_PLANE]"])
	for(var/screen in screens)
		var/atom/movable/screen/plane_master/plane = screen
		plane.remove_filter("dirty_glasses_ang_blur")
		plane.remove_filter("dirty_glasses_blur")

	UnregisterSignal(source, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED,COMSIG_COMPONENT_CLEAN_ACT))
	return ..()

/datum/element/dirty_glasses/proc/equippedChanged(datum/source, mob/living/carbon/user, slot)
	SIGNAL_HANDLER

	var/list/screens = list(user.hud_used.plane_masters["[FLOOR_PLANE]"], user.hud_used.plane_masters["[GAME_PLANE]"], user.hud_used.plane_masters["[LIGHTING_PLANE]"])
	for(var/screen in screens)
		var/atom/movable/screen/plane_master/plane = screen
		if(slot == SLOT_GLASSES && istype(user))
			plane.add_filter("dirty_glasses_ang_blur",10,list("type" = "angular_blur","x" = 0, "y" = 0,"size" = 7))
			plane.add_filter("dirty_glasses_blur",10,list("type" = "blur","size" = 2))
		else
			plane.remove_filter("dirty_glasses_ang_blur")
			plane.remove_filter("dirty_glasses_blur")

/datum/element/dirty_glasses/proc/clean(datum/source, clean_strength )
	SIGNAL_HANDLER

	source.RemoveElement(/datum/element/dirty_glasses)
	return

/datum/element/dirty_glasses/proc/examine(datum/source, mob/user, list/examine_list)

	examine_list += "<span class='notice'>[source] is very dirty, wash it in a sink!</span>"
