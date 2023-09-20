/**
 * The action button given by the weight machine's buckle.
 * This allows users to manually trigger working out.
 */
/datum/action/push_weights
	name = "Work out"
	desc = "Start working out"
	icon_icon = 'icons/obj/fitness.dmi'
	button_icon_state = "stacklifter"
	///Reference to the weightpress we are created inside of.
	var/obj/structure/weightmachine/weightpress

/datum/action/push_weights/IsAvailable(feedback = FALSE)
	if(INTERACTING_WITH(owner, weightpress))
		return FALSE
	return TRUE

/datum/action/push_weights/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return FALSE
	weightpress.perform_workout(owner)

