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

/obj/machinery/xenoarchaeology_machine/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_ARTIFACT_IGNORE, GENERIC_ITEM_TRAIT)

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
	empty_contents()

/obj/machinery/xenoarchaeology_machine/proc/register_contents(atom/A)
	RegisterSignal(A, COMSIG_PARENT_QDELETING, PROC_REF(unregister_contents))
	held_contents += A

/obj/machinery/xenoarchaeology_machine/proc/unregister_contents(datum/source)
	SIGNAL_HANDLER

	held_contents -= source
	UnregisterSignal(source, COMSIG_PARENT_QDELETING)

/obj/machinery/xenoarchaeology_machine/proc/get_target()
	return move_inside ? src : drop_location()

/obj/machinery/xenoarchaeology_machine/proc/empty_contents()
	for(var/atom/movable/A in held_contents)
		A.forceMove(get_turf(src))
		unregister_contents(A)

/*
	Scale, measures artifact weight
*/
/obj/machinery/xenoarchaeology_machine/scale
	icon_state = "scale"

/obj/machinery/xenoarchaeology_machine/scale/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Interact to measure artifact weight.\nLabeled artifacts will also show label weights, against the total.</span>"

/obj/machinery/xenoarchaeology_machine/scale/attack_hand(mob/living/user)
	. = ..()
	///Get the combined weight of all artifacts in our target
	var/atom/target = get_target()
	var/total_weight = 0
	for(var/atom/A in target)
		var/datum/component/xenoartifact/X = A.GetComponent(/datum/component/xenoartifact)
		if(X)
			total_weight += X.get_material_weight()
		//If there's a label and we're obliged to 'help' the player
		var/obj/item/sticker/xenoartifact_label/L = locate(/obj/item/sticker/xenoartifact_label) in A.contents
		if(L)
			for(var/datum/xenoartifact_trait/T as() in L.traits)
				say("[initial(T.label_name)] - Weight: [initial(T.weight)]")
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

/obj/machinery/xenoarchaeology_machine/conductor/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Interact to measure artifact conductivity.\nLabeled artifacts will also show label conductivity, against the total.</span>"

/obj/machinery/xenoarchaeology_machine/conductor/attack_hand(mob/living/user)
	. = ..()
	///Get the combined conductivity of all artifacts in our target
	var/atom/target = get_target()
	var/total_conductivity = 0
	for(var/atom/A in target)
		var/datum/component/xenoartifact/X = A.GetComponent(/datum/component/xenoartifact)
		if(X)
			total_conductivity += X.get_material_conductivity()
		var/obj/item/sticker/xenoartifact_label/L = locate(/obj/item/sticker/xenoartifact_label) in A.contents
		if(L)
			for(var/datum/xenoartifact_trait/T as() in L.traits)
				say("[initial(T.label_name)] - Conductivity: [initial(T.conductivity)]")
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

/obj/machinery/xenoarchaeology_machine/calibrator/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-Click to calibrate inserted artifacts.\nArtifacts can be calibrated by labeling them 100% correctly, excluding malfunctions.</span>"

/obj/machinery/xenoarchaeology_machine/calibrator/attack_hand(mob/living/user)
	if(length(contents))
		return ..()
	else
		var/turf/T = get_turf(src)
		for(var/obj/item/I in T.contents)
			if(move_inside && length(held_contents) >= max_contents)
				return
			I.forceMove(src)
			register_contents(I)

/obj/machinery/xenoarchaeology_machine/calibrator/AltClick(mob/user)
	. = ..()
	if(!length(held_contents))
		playsound(get_turf(src), 'sound/machines/uplinkerror.ogg', 60)
		return
	for(var/atom/A as() in contents)
		var/solid_as = TRUE
		//Once we find an artifact-
		var/datum/component/xenoartifact/X = A.GetComponent(/datum/component/xenoartifact)
		//We then want to find a sticker attached to it-
		var/obj/item/sticker/xenoartifact_label/L = locate(/obj/item/sticker/xenoartifact_label) in A.contents
		//Early checks
		if(!X || !L || X?.calibrated || X?.calcified)
			var/decision = "No"
			if(!L)
				say("No label detected!")
				if(X && !X.calcified)
					decision = tgui_alert(user, "Do you want to continue, this will destroy [A]?", "Calcify Artifact", list("Yes", "No"))
			if(decision == "No")
				playsound(get_turf(src), 'sound/machines/uplinkerror.ogg', 60)
				empty_contents()
				continue
			else
				solid_as = FALSE
		//Loop through traits and see if we're fucked or not
		if(solid_as) //This is kinda wacky but it's for a player option so idc
			for(var/i in X.artifact_traits)
				for(var/datum/xenoartifact_trait/T in X.artifact_traits[i])
					if(!(locate(T) in L.traits))
						if(T.contribute_calibration)
							solid_as = FALSE
		//If we're cooked
		if(!solid_as)
			X.calcify()
			playsound(get_turf(src), 'sound/machines/uplinkerror.ogg', 60)
			empty_contents()
			return
		playsound(get_turf(src), 'sound/machines/ding.ogg', 60)
		//Calibrate the artifact
		X.calibrate()
		//Prompt user to delete or keep malfunctions
		var/decision = tgui_alert(user, "Do you want to calcify [A]'s malfunctions?", "Remove Malfunctions", list("Yes", "No"))
		if(decision == "Yes")
			for(var/i in X.artifact_traits)
				for(var/datum/xenoartifact_trait/T in X.artifact_traits[i])
					if(istype(T, /datum/xenoartifact_trait/malfunction))
						qdel(T)
		empty_contents()
