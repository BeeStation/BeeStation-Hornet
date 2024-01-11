/*
	Misc machines used to interact with artifact traits
*/

/obj/machinery/xenoarchaeology_machine
	icon = 'icons/obj/xenoarchaeology/xenoartifact_tech.dmi'
	///Do we move the artifact to our turf, or inside us?
	var/move_inside = FALSE
	///List of things we need to spit out
	var/list/held_contents = list()
	var/max_contents = 1

/obj/machinery/xenoarchaeology_machine/attackby(obj/item/I, mob/living/user, params)
	var/list/modifiers = params2list(params)
	var/atom/target = get_target()
	//Prechecks
	if(move_inside && length(held_contents) >= max_contents)
		return
	///Move the item to our target, so we can work with it, like we're a table
	if(user.a_intent != INTENT_HARM && !(I.item_flags & ABSTRACT))
		if(user.transferItemToLoc(I, target, silent = FALSE))
			//Center the icon where the user clicked.
			if(!LAZYACCESS(modifiers, ICON_X) || !LAZYACCESS(modifiers, ICON_Y))
				return
			//Clamp it so that the icon never moves more than 16 pixels in either direction (thus leaving the table turf)
			I.pixel_x = clamp(text2num(LAZYACCESS(modifiers, ICON_X)) - 16, -(world.icon_size/2), world.icon_size/2)
			I.pixel_y = clamp(text2num(LAZYACCESS(modifiers, ICON_Y)) - 16, -(world.icon_size/2), world.icon_size/2)
			//Handle contents
			if(move_inside)
				register_contents(I)
	else
		return ..()
	
/obj/machinery/xenoarchaeology_machine/attack_hand(mob/living/user)
	. = ..()
	for(var/atom/movable/A in held_contents)
		A.forceMove(get_turf(src))
		unregister_contents(A)

/obj/machinery/xenoarchaeology_machine/proc/register_contents(atom/A)
	RegisterSignal(A, COMSIG_PARENT_QDELETING, PROC_REF(unregister_contents))
	held_contents += A

/obj/machinery/xenoarchaeology_machine/proc/unregister_contents(datum/source)
	SIGNAL_HANDLER

	held_contents -= source
	UnregisterSignal(source, COMSIG_PARENT_QDELETING)

/obj/machinery/xenoarchaeology_machine/proc/get_target()
	return move_inside ? src : drop_location()

/*
	Scale, measures artifact weight
*/
/obj/machinery/xenoarchaeology_machine/scale
	icon_state = "scale"

/obj/machinery/xenoarchaeology_machine/scale/attack_hand(mob/living/user)
	. = ..()
	///Get the combined weight of all artifacts in our target
	var/atom/target = get_target()
	var/total_weight = 0
	for(var/atom/A in target)
		var/datum/component/xenoartifact/X = A.GetComponent(/datum/component/xenoartifact)
		if(X)
			total_weight += X.get_material_weight()
		else if(isitem(A) || isliving(A))
			if(isliving(A) && prob(1))
				say("Unexpected Fatass Detected!")
				say("Get the fuck off me, lardass!")
			else
				say("Unexpected Item Detected!")
	if(total_weight)
		say("Total Mass: [total_weight] KG.")
	else
		say("No Mass Detected!")

/*
	Conductor, measures artifact conductivty
*/
/obj/machinery/xenoarchaeology_machine/conductor
	icon_state = "conductor"

/obj/machinery/xenoarchaeology_machine/conductor/attack_hand(mob/living/user)
	. = ..()
	///Get the combined conductivity of all artifacts in our target
	var/atom/target = get_target()
	var/total_conductivity = 0
	for(var/atom/A in target)
		var/datum/component/xenoartifact/X = A.GetComponent(/datum/component/xenoartifact)
		if(X)
			total_conductivity += X.get_material_conductivity()
		else if(isitem(A) || isliving(A))
			say("Unexpected Item Detected!")
			return
	if(total_conductivity)
		say("Total Conductivity: [total_conductivity] MPC.")
	else
		say("No Conductivity Detected!")


/*
	Calibrator, calibrates artifacts
*/
/obj/machinery/xenoarchaeology_machine/calibrator
	icon_state = "calibrator"
	move_inside = TRUE
