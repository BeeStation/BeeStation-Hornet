/datum/element/cleaning/Attach(datum/target)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(Clean))

/datum/element/cleaning/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_MOVABLE_MOVED)

/datum/element/cleaning/proc/Clean(datum/source)
	SIGNAL_HANDLER
	var/atom/movable/AM = source
	var/turf/tile = AM.loc
	if(!isturf(tile))
		return

	tile.wash(CLEAN_WASH)
	for(var/A in tile)
		// Clean small items that are lying on the ground
		if(isitem(A))
			var/obj/item/I = A
			if(I.w_class <= WEIGHT_CLASS_SMALL && !ismob(I.loc))
				I.wash(CLEAN_WASH)
		// Clean humans that are lying down
		else if(ishuman(A))
			var/mob/living/carbon/human/cleaned_human = A
			if(cleaned_human.body_position == LYING_DOWN)
				cleaned_human.wash(CLEAN_WASH)
				cleaned_human.regenerate_icons()
				to_chat(cleaned_human, span_danger("[AM] cleans your face!"))

/datum/action/cleaning_toggle
	name = "Floor Cleaning Toggle"
	desc = "Toggles the automatic floor cleaning"
	button_icon = 'icons/obj/vehicles.dmi'
	button_icon_state = "upgrade"
	var/toggled = TRUE
	var/atom/movable/toggle_target = null

/datum/action/cleaning_toggle/Remove(mob/M)
	toggle_target = null
	. = ..()

/datum/action/cleaning_toggle/maid
	name = "Floor Polish Toggle"
	desc = "Toggles the automatic floor polishing"
	button_icon = 'icons/obj/clothing/gloves.dmi'
	button_icon_state = "maid_arms"

/datum/action/cleaning_toggle/Grant(mob/M)
	. = ..()
	if(isnull(toggle_target))
		toggle_target = M

/datum/action/cleaning_toggle/on_activate(mob/user, atom/target)
	if(!toggle_target)
		log_runtime("Floor Cleaning Toggle action triggered without a target.")
		return
	if(toggled)
		toggle_target.RemoveElement(/datum/element/cleaning)
		toggled = FALSE
	else
		toggle_target.AddElement(/datum/element/cleaning)
		toggled = TRUE
	owner.balloon_alert(owner, "Auto-cleaning is [toggled ? "ON" : "OFF"]")
	to_chat(owner, span_notice("The auto-cleaning is now [toggled ? "ON" : "OFF"]."))

