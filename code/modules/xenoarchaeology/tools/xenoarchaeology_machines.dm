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
	if(user.combat_mode || (I.item_flags & ABSTRACT))
		return ..()
	if(move_inside && length(held_contents) >= max_contents)
		return
	var/list/modifiers = params2list(params)
	var/atom/target = get_target()
	///Move the item to our target, so we can work with it, like we're a table
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

/obj/machinery/xenoarchaeology_machine/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(modifiers && modifiers["right"])
		return
	activate_machine()

/// Does a machine thing when you 'click' the machine. Typically called by 'attack_hand'.
/obj/machinery/xenoarchaeology_machine/proc/activate_machine()
	return

/obj/machinery/xenoarchaeology_machine/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	alt_activate_machine(user)

/// Does a machine thing when you 'alt+click' the machine.
/obj/machinery/xenoarchaeology_machine/proc/alt_activate_machine(mob/user)
	return

/obj/machinery/xenoarchaeology_machine/proc/register_contents(atom/atom_target)
	RegisterSignal(atom_target, COMSIG_QDELETING, PROC_REF(unregister_contents))
	RegisterSignal(atom_target, COMSIG_MOVABLE_MOVED, PROC_REF(unregister_contents))
	held_contents += atom_target

/obj/machinery/xenoarchaeology_machine/proc/unregister_contents(datum/source)
	SIGNAL_HANDLER

	held_contents -= source
	UnregisterSignal(source, COMSIG_QDELETING)
	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)

/obj/machinery/xenoarchaeology_machine/proc/get_target()
	return move_inside ? src : drop_location()

/obj/machinery/xenoarchaeology_machine/proc/empty_contents(atom/movable/target, force)
	if(target && (list(target) & held_contents || force))
		target.forceMove(get_turf(src))
		unregister_contents(target)
		return
	for(var/atom/movable/AM in held_contents)
		AM.forceMove(get_turf(src))
		unregister_contents(AM)

//Circuitboard
/obj/item/circuitboard/machine/xenoarchaeology_machine
	name = "place holder (Machine Board)"
	icon_state = "science"
	build_path = /obj/machinery/xenoarchaeology_machine
	req_components = list(
		/obj/item/stack/ore/bluespace_crystal = 5,
		/obj/item/stock_parts/matter_bin = 1)

// ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*
	Scale, measures artifact weight
*/
/obj/machinery/xenoarchaeology_machine/scale
	name = "industrial scale"
	desc = "A piece of industrial equipment, designed to weigh thousands of kilograms."
	icon_state = "scale"
	circuit = /obj/item/circuitboard/machine/xenoarchaeology_machine/scale

/obj/machinery/xenoarchaeology_machine/scale/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Interact to measure artifact weight.\nLabeled artifacts will also show label weights, against the total.</span>"

/obj/machinery/xenoarchaeology_machine/scale/activate_machine(mob/living/user)
	empty_contents()
	///Get the combined weight of all artifacts in our target
	var/atom/target = get_target()
	var/total_weight = 0
	var/label_weight = 0
	for(var/atom/atom_target in target)
		var/datum/component/xenoartifact/artifact_component = atom_target.GetComponent(/datum/component/xenoartifact)
		if(artifact_component)
			total_weight += artifact_component.get_material_weight()
		//If there's a label and we're obliged to 'help' the player
		var/obj/item/sticker/xenoartifact_label/label = locate(/obj/item/sticker/xenoartifact_label) in atom_target.contents
		if(label)
			for(var/datum/xenoartifact_trait/T as() in label.traits)
				say("[initial(T.label_name)] - Weight: [initial(T.weight)]")
				label_weight += initial(T.weight)
		else if(isitem(atom_target) || isliving(atom_target))
			if(isliving(atom_target))
				if(prob(1))
					say("Unexpected Fatass Detected!")
					say("Get the fuck off me, lardass!")
					playsound(get_turf(src), 'sound/vehicles/clowncar_fart.ogg', 100)
				else
					say("Unexpected Item Detected!")
				return
	if(total_weight)
		say("Total Mass: [total_weight] KG.\n[label_weight ? "Label Mass: [label_weight] KG." : ""]")
	else
		say("No Mass Detected!")
	playsound(src, 'sound/machines/uplinkpurchase.ogg', 50, TRUE)

//Circuitboard
/obj/item/circuitboard/machine/xenoarchaeology_machine/scale
	name = "industrial scale (Machine Board)"
	icon_state = "science"
	build_path = /obj/machinery/xenoarchaeology_machine/scale

// ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*
	Conductor, measures artifact conductivty
*/
/obj/machinery/xenoarchaeology_machine/conductor
	name = "conducting plate"
	desc = "A piece of industrial equipment for measuring material conductivity."
	icon_state = "conductor"
	circuit = /obj/item/circuitboard/machine/xenoarchaeology_machine/conductor

/obj/machinery/xenoarchaeology_machine/conductor/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Interact to measure artifact conductivity.\nLabeled artifacts will also show label conductivity, against the total.</span>"

/obj/machinery/xenoarchaeology_machine/conductor/activate_machine(mob/living/user)
	empty_contents()

	///Get the combined conductivity of all artifacts in our target
	var/atom/target = get_target()
	var/total_conductivity = 0
	var/label_conductivity = 0
	for(var/atom/atom_target in target)
		var/datum/component/xenoartifact/artifact_component = atom_target.GetComponent(/datum/component/xenoartifact)
		if(artifact_component)
			total_conductivity += artifact_component.get_material_conductivity()
		//If there's a label and we're obliged to 'help' the player
		var/obj/item/sticker/xenoartifact_label/label = locate(/obj/item/sticker/xenoartifact_label) in atom_target.contents
		if(label)
			for(var/datum/xenoartifact_trait/T as() in label.traits)
				say("[initial(T.label_name)] - conductivity: [initial(T.conductivity)]")
				label_conductivity += initial(T.conductivity)
		else if(isitem(atom_target) || isliving(atom_target))
			if(isliving(atom_target))
				if(prob(1))
					say("Unexpected Fatass Detected!")
					say("Get the fuck off me, lardass!")
					playsound(get_turf(src), 'sound/vehicles/clowncar_fart.ogg', 100)
				else
					say("Unexpected Item Detected!")
				return
	if(total_conductivity)
		say("Total Conductivity: [total_conductivity] MPC.\n[label_conductivity ? "Label Conductivity: [label_conductivity] MPC." : ""]")
	else
		say("No Conductivity Detected!")
	playsound(src, 'sound/machines/uplinkpurchase.ogg', 50, TRUE)

//Circuitboard
/obj/item/circuitboard/machine/xenoarchaeology_machine/conductor
	name = "conducting plate (Machine Board)"
	icon_state = "science"
	build_path = /obj/machinery/xenoarchaeology_machine/conductor

// ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*
	Calibrator, calibrates artifacts
*/
/obj/machinery/xenoarchaeology_machine/calibrator
	name = "anomalous material calibrator"
	desc = "An experimental piece of scientific equipment, designed to calibrate anomalous materials."
	icon_state = "calibrator"
	move_inside = TRUE
	circuit = /obj/item/circuitboard/machine/xenoarchaeology_machine/calibrator
	///Which science server receives points
	var/datum/techweb/linked_techweb
	///radio used by the console to send messages on science channel
	var/obj/item/radio/headset/radio
	///Cooking logic
	var/cooking_time = 4 SECONDS
	var/cooking_timer
	///How effective are our parts, for making DP
	var/reward_rate = 0.25

/obj/machinery/xenoarchaeology_machine/calibrator/Initialize(mapload, _artifact_type)
	. = ..()
	//Link relevant stuff
	linked_techweb = SSresearch.science_tech
	//Radio setup
	radio = new /obj/item/radio/headset/headset_sci(src)

/obj/machinery/xenoarchaeology_machine/calibrator/tutorial/Initialize(mapload, _artifact_type)
	. = ..()
	var/obj/item/sticker/sticky_note/calibrator_tutorial/label = new(loc)
	label.afterattack(src, src, TRUE)
	unregister_contents(label)
	label.pixel_y = rand(-8, 8)
	label.pixel_x = rand(-8, 8)

/obj/machinery/xenoarchaeology_machine/calibrator/Destroy()
	. = ..()
	QDEL_NULL(radio)
	if(cooking_timer)
		deltimer(cooking_timer)

/obj/machinery/xenoarchaeology_machine/calibrator/RefreshParts()
	//Should only be one, but I'm lazy and this seems safe
	for(var/obj/item/stock_parts/manipulator/part in component_parts)
		reward_rate = part.rating / 4

/obj/machinery/xenoarchaeology_machine/calibrator/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Right-Click to calibrate inserted artifacts.\nArtifacts can be calibrated by labeling them 100% correctly, excluding malfunctions.</span>"

/obj/machinery/xenoarchaeology_machine/calibrator/activate_machine(mob/living/user)
	if(length(held_contents))
		empty_contents()
		return

	var/turf/turf = get_turf(src)
	for(var/obj/item/item in turf.contents)
		if(move_inside && length(held_contents) >= max_contents)
			return
		item.forceMove(src)
		register_contents(item)

/obj/machinery/xenoarchaeology_machine/calibrator/alt_activate_machine(mob/user)
	if(!length(held_contents) || cooking_timer)
		playsound(get_turf(src), 'sound/machines/uplinkerror.ogg', 60)
		return
	playsound(src, 'sound/machines/uplinkpurchase.ogg', 50, TRUE)
	for(var/atom/atom_target as anything in contents-radio)
		var/solid_as = TRUE
		//Once we find an artifact-
		var/datum/component/xenoartifact/artifact_component = atom_target.GetComponent(/datum/component/xenoartifact)
		//We then want to find a sticker attached to it-
		var/obj/item/sticker/xenoartifact_label/label = locate(/obj/item/sticker/xenoartifact_label) in atom_target.contents
		//Early checks
		if(!artifact_component || !label || artifact_component?.calibrated || artifact_component?.calcified)
			var/decision = "No"
			if(!label && artifact_component)
				say("No label detected!")
				if(!artifact_component.calcified)
					decision = tgui_alert(user, "Do you want to continue, this will destroy [atom_target]?", "Calcify Artifact", list("Yes", "No"))
			if(decision == "No")
				//This stops us from spitting out stuff we shouldn't, mostly
				if(atom_target in held_contents)
					empty_contents(atom_target)
				continue
			else
				solid_as = FALSE
		//Loop through traits and see if we're fucked or not
		var/score = 0
		var/max_score = 0
		if(solid_as) //This is kinda wacky but it's for a player option so idc
			for(var/trait in artifact_component.traits_catagories)
				for(var/datum/xenoartifact_trait/trait_datum in artifact_component.traits_catagories[trait])
					if(trait_datum.contribute_calibration)
						if(!(locate(trait_datum) in label.traits))
							solid_as = FALSE
						else
							score += 1
					max_score = trait_datum.contribute_calibration ?  max_score + 1 : max_score
		//Check against label length, for extra labeled traits
		var/label_length = 0
		for(var/datum/xenoartifact_trait/trait_datum as() in label?.traits)
			if(initial(trait_datum.contribute_calibration))
				label_length += 1
		if(label_length != max_score)
			solid_as = FALSE
		//FX
		INVOKE_ASYNC(src, PROC_REF(do_cooking_sounds), solid_as)
		cooking_timer = addtimer(CALLBACK(src, PROC_REF(finish_cooking), atom_target, artifact_component, score, max_score, solid_as), cooking_time, TIMER_STOPPABLE)

/obj/machinery/xenoarchaeology_machine/calibrator/proc/do_cooking_sounds(status)
	playsound(src, 'sound/machines/capacitor_charge.ogg', 50, TRUE)
	sleep(2 SECONDS)
	playsound(src, 'sound/machines/capacitor_discharge.ogg', 50, TRUE)
	sleep(2 SECONDS)
	playsound(src, status ? 'sound/machines/microwave/microwave-end.ogg' : 'sound/machines/buzz-two.ogg', 50, TRUE)

/obj/machinery/xenoarchaeology_machine/calibrator/proc/finish_cooking(atom/atom_target, datum/component/xenoartifact/artifact_component, score, max_score, solid_as)
	//Timer
	if(cooking_timer)
		deltimer(cooking_timer)
	cooking_timer = null
	empty_contents(atom_target)
	//If we're cooked
	if(!solid_as)
		artifact_component.calcify()
		return
	//Scoring & success
	if(score)
		var/success_rate = score / max_score
		var/dp_reward = max(0, (atom_target.item_price*artifact_component.artifact_material.dp_rate)*success_rate) * reward_rate
		linked_techweb?.add_point_type(TECHWEB_POINT_TYPE_DISCOVERY, dp_reward)
		//Announce this, for honor or shame
		var/message = "[atom_target] has been calibrated, and generated [dp_reward] Discovery Points!"
		say(message)
		radio?.talk_into(src, message, RADIO_CHANNEL_SCIENCE)
	//Calibrate the artifact
	artifact_component.calibrate()
	//Prompt user to delete or keep malfunctions
	var/decision = tgui_alert(usr, "Do you want to calcify [atom_target]'s malfunctions?", "Remove Malfunctions", list("Yes", "No"))
	if(decision == "Yes")
		for(var/i in artifact_component.traits_catagories)
			for(var/datum/xenoartifact_trait/trait_datum in artifact_component.traits_catagories[i])
				if(istype(trait_datum, /datum/xenoartifact_trait/malfunction))
					qdel(trait_datum)

//Circuitboard
/obj/item/circuitboard/machine/xenoarchaeology_machine/calibrator
	name = "anomalous material calibrator (Machine Board)"
	icon_state = "science"
	build_path = /obj/machinery/xenoarchaeology_machine/calibrator
	req_components = list(/obj/item/stock_parts/matter_bin = 3, /obj/item/stock_parts/manipulator = 1)
