/**
 * The action button given by the weight machine's buckle.
 * This allows users to manually trigger working out.
 */
/datum/action/push_weights
	name = "Work out"
	desc = "Start working out"
	button_icon = 'icons/obj/fitness.dmi'
	button_icon_state = "stacklifter"
	///Reference to the weightpress we are created inside of.
	var/obj/structure/weightmachine/weightpress

/datum/action/push_weights/is_available(feedback = FALSE)
	if(DOING_INTERACTION_WITH_TARGET(owner, weightpress))
		return FALSE
	return TRUE

/datum/action/push_weights/on_activate(mob/user, atom/target)
	weightpress.perform_workout(owner)

