/obj/machinery/computer/camera_advanced/abductor
	name = "Human Observation Console"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "camera"
	base_icon_state = null

	lock_override = TRUE
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

	reveal_camera_mob = TRUE
	networks = list("ss13", "abductor")
	camera_mob_icon_state = "abductor_camera"

	// Set in 'console.dm'
	var/obj/machinery/abductor/console/console
	var/team_number = 0

	var/datum/action/innate/teleport_in/tele_in_action
	var/datum/action/innate/teleport_out/tele_out_action
	var/datum/action/innate/teleport_self/tele_self_action
	var/datum/action/innate/vest_mode_swap/vest_mode_action
	var/datum/action/innate/vest_disguise_swap/vest_disguise_action
	var/datum/action/innate/set_droppoint/set_droppoint_action

/obj/machinery/computer/camera_advanced/abductor/Destroy()
	if(console)
		console.camera = null
		console = null
	. = ..()

/obj/machinery/computer/camera_advanced/abductor/GrantActions(mob/living/carbon/user)
	. = ..()

	tele_in_action = new(console.pad)
	tele_out_action = new(console)
	tele_self_action = new(console.pad)
	vest_mode_action = new(console)
	vest_disguise_action = new(console)
	set_droppoint_action = new(console)

	if(tele_in_action)
		tele_in_action.Grant(user)
		actions += tele_in_action

	if(tele_out_action)
		tele_out_action.Grant(user)
		actions += tele_out_action

	if(tele_self_action)
		tele_self_action.Grant(user)
		actions += tele_self_action

	if(vest_mode_action)
		vest_mode_action.Grant(user)
		actions += vest_mode_action

	if(vest_disguise_action)
		vest_disguise_action.Grant(user)
		actions += vest_disguise_action

	if(set_droppoint_action)
		set_droppoint_action.Grant(user)
		actions += set_droppoint_action

/obj/machinery/computer/camera_advanced/abductor/proc/IsScientist(mob/living/carbon/human/H)
	return HAS_TRAIT(H, TRAIT_ABDUCTOR_SCIENTIST_TRAINING)

/datum/action/innate/teleport_in
	name = "Send To"
	button_icon = 'icons/hud/actions/actions_minor_antag.dmi'
	button_icon_state = "beam_down"

/datum/action/innate/teleport_in/on_activate()
	if(!master || !iscarbon(owner))
		return
	var/mob/living/carbon/human/C = owner
	var/mob/camera/ai_eye/remote/remote_eye = C.remote_control
	var/obj/machinery/abductor/pad/P = master
	var/turf/target_loc = get_turf(remote_eye)

	if(istype(get_area(target_loc), /area/ai_monitored))
		to_chat(owner, span_warning("Due to significant interference, this area cannot be warped to!"))
		return

	var/specimin_nearby = FALSE
	var/agent_nearby = FALSE
	for(var/mob/living/carbon/human/specimin in view(5, target_loc))
		//They are an abductor agent, we can always go near them
		if (isabductor(specimin))
			agent_nearby = TRUE
			break
		var/obj/item/organ/heart/gland/temp = locate() in specimin.internal_organs
		//Not a specimin
		if(istype(temp))
			continue
		//No heart, not considered a specimin
		if (!specimin.get_organ_slot(ORGAN_SLOT_HEART))
			continue
		//Technically a specimin, however we should avoid meta tactics
		if (!specimin.client)
			continue
		specimin_nearby = TRUE

	if (specimin_nearby && !agent_nearby)
		to_chat(owner, span_warning("You cannot warp to this location, an unprocessed specimen might spot you, tampering with the experiment!"))
		return

	if(GLOB.cameranet.checkTurfVis(remote_eye.loc))
		P.PadToLoc(remote_eye.loc)

/datum/action/innate/teleport_out
	name = "Retrieve"
	button_icon = 'icons/hud/actions/actions_minor_antag.dmi'
	button_icon_state = "beam_up"

/datum/action/innate/teleport_out/on_activate()
	if(!master || !iscarbon(owner))
		return
	var/obj/machinery/abductor/console/console = master

	console.TeleporterRetrieve()

/datum/action/innate/teleport_self
	name = "Send Self"
	button_icon = 'icons/hud/actions/actions_minor_antag.dmi'
	button_icon_state = "beam_down"

/datum/action/innate/teleport_self/on_activate()
	if(!master || !iscarbon(owner))
		return
	var/mob/living/carbon/human/C = owner
	var/mob/camera/ai_eye/remote/remote_eye = C.remote_control
	var/obj/machinery/abductor/pad/P = master
	var/turf/target_loc = get_turf(remote_eye)

	if(istype(get_area(target_loc), /area/ai_monitored))
		to_chat(owner, span_warning("Due to significant interference, this area cannot be warped to!"))
		return

	var/specimin_nearby = FALSE
	var/agent_nearby = FALSE
	for(var/mob/living/carbon/human/specimin in view(5, target_loc))
		//They are an abductor agent, we can always go near them
		if (isabductor(specimin))
			agent_nearby = TRUE
			break
		var/obj/item/organ/heart/gland/temp = locate() in specimin.internal_organs
		//Not a specimin
		if(istype(temp))
			continue
		//No heart, not considered a specimin
		if (!specimin.get_organ_slot(ORGAN_SLOT_HEART))
			continue
		//Technically a specimin, however we should avoid meta tactics
		if (!specimin.client)
			continue
		specimin_nearby = TRUE

	if (specimin_nearby && !agent_nearby)
		to_chat(owner, span_warning("You cannot warp to this location, an unprocessed specimen might spot you, tampering with the experiment!"))
		return

	if(GLOB.cameranet.checkTurfVis(remote_eye.loc))
		P.MobToLoc(remote_eye.loc,C)

/datum/action/innate/vest_mode_swap
	name = "Switch Vest Mode"
	button_icon = 'icons/hud/actions/actions_minor_antag.dmi'
	button_icon_state = "vest_mode"

/datum/action/innate/vest_mode_swap/on_activate()
	if(!master || !iscarbon(owner))
		return
	var/obj/machinery/abductor/console/console = master
	console.FlipVest()


/datum/action/innate/vest_disguise_swap
	name = "Switch Vest Disguise"
	button_icon = 'icons/hud/actions/actions_minor_antag.dmi'
	button_icon_state = "vest_disguise"

/datum/action/innate/vest_disguise_swap/on_activate()
	if(!master || !iscarbon(owner))
		return
	var/obj/machinery/abductor/console/console = master
	console.SelectDisguise(remote=1)

/datum/action/innate/set_droppoint
	name = "Set Experiment Release Point"
	button_icon = 'icons/hud/actions/actions_minor_antag.dmi'
	button_icon_state = "set_drop"

/datum/action/innate/set_droppoint/on_activate()
	if(!master || !iscarbon(owner))
		return

	var/mob/living/carbon/human/C = owner
	var/mob/camera/ai_eye/remote/remote_eye = C.remote_control

	var/obj/machinery/abductor/console/console = master
	console.SetDroppoint(remote_eye.loc,owner)
