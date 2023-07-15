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

	SEND_SIGNAL(tile, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
	for(var/A in tile)
		if(is_cleanable(A))
			qdel(A)
		else if(istype(A, /obj/item))
			var/obj/item/I = A
			SEND_SIGNAL(I, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
			if(ismob(I.loc))
				var/mob/M = I.loc
				M.regenerate_icons()
		else if(ishuman(A))
			var/mob/living/carbon/human/cleaned_human = A
			if(!(cleaned_human.mobility_flags & MOBILITY_STAND))
				if(cleaned_human.head)
					SEND_SIGNAL(cleaned_human.head, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
				if(cleaned_human.wear_suit)
					SEND_SIGNAL(cleaned_human.wear_suit, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
				else if(cleaned_human.w_uniform)
					SEND_SIGNAL(cleaned_human.w_uniform, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
				if(cleaned_human.shoes)
					SEND_SIGNAL(cleaned_human.shoes, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
				SEND_SIGNAL(cleaned_human, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
				cleaned_human.regenerate_icons()
				to_chat(cleaned_human, "<span class='danger'>[AM] cleans your face!</span>")

/datum/action/cleaning_toggle
	name = "Floor Cleaning Toggle"
	desc = "Toggles the automatic floor cleaning"
	icon_icon = 'icons/obj/vehicles.dmi'
	button_icon_state = "upgrade"
	var/toggled = TRUE
	var/atom/movable/toggle_target = null

/datum/action/cleaning_toggle/Remove(mob/M)
	toggle_target = null
	. = ..()

/datum/action/cleaning_toggle/maid
	name = "Floor Polish Toggle"
	desc = "Toggles the automatic floor polishing"
	icon_icon = 'icons/obj/clothing/gloves.dmi'
	button_icon_state = "maid_arms"

/datum/action/cleaning_toggle/Grant(mob/M)
	. = ..()
	if(isnull(toggle_target))
		toggle_target = M

/datum/action/cleaning_toggle/Trigger()
	. = ..()
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
	to_chat(owner, "<span class='notice'>The auto-cleaning is now [toggled ? "ON" : "OFF"].</span>")

