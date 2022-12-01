/obj/effect/proc_holder/spell/knock
	name = "Knock"
	desc = "This spell opens nearby doors and closets and uncuffs nearby people. if it uncuffs someone, its cooldown time gets doubled."

	school = "transmutation"
	charge_max = 100
	clothes_req = FALSE
	invocation = "AULIE OXIN FIERA"
	invocation_type = "whisper"
	range = 3
	cooldown_min = 20 //20 deciseconds reduction per rank

	action_icon_state = "knock"
	var/open_cuffs = TRUE

/obj/effect/proc_holder/spell/knock/lesser
	name = "Lesser Knock"
	desc = "This spell opens nearby doors and closets."
	open_cuffs = FALSE

/obj/effect/proc_holder/spell/knock/choose_targets(mob/user = usr)
	// Knock has 'targeted' and 'aoe_turf' at the same time, so it should have custom target proc.
	var/list/targets = list()

	for(var/turf/target in view_or_range(range, user, selection_type))
		if(!can_target(target))
			continue
		targets += target

	if(open_cuffs)
		for(var/mob/living/carbon/target in view_or_range(range, user, selection_type))
			if(!can_target(target))
				continue
			targets += target

	if(!targets.len)
		revert_cast()
		return

	perform(targets,user=user)

/obj/effect/proc_holder/spell/knock/cast(list/targets,mob/user = usr)
	SEND_SOUND(user, sound('sound/magic/knock.ogg'))
	for(var/turf/T in targets)
		for(var/obj/machinery/door/door in T.contents)
			INVOKE_ASYNC(src, .proc/open_door, door)
		for(var/obj/structure/closet/C in T.contents)
			INVOKE_ASYNC(src, .proc/open_closet, C)

	if(open_cuffs)
		var/uncuff_cooldown_check = FALSE
		for(var/mob/living/carbon/C in targets)
			if(C.uncuff())
				uncuff_cooldown_check = TRUE
			var/mob/living/carbon/human/H = ishuman(C) ? C : null
			if(H?.wear_suit?.breakouttime)
				H.dropItemToGround(H.wear_suit, TRUE)
				uncuff_cooldown_check = TRUE
		if(uncuff_cooldown_check && charge_type == "recharge")
			charge_counter -= charge_max // If you uncuff someone, cooldown time gets doubled


/obj/effect/proc_holder/spell/knock/proc/open_door(var/obj/machinery/door/door)
	if(istype(door, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = door
		A.locked = FALSE
		A.wires.ui_update()
	door.open()

/obj/effect/proc_holder/spell/knock/proc/open_closet(var/obj/structure/closet/C)
	C.locked = FALSE
	C.open()
