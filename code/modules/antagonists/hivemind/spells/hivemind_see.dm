/obj/effect/proc_holder/spell/target_hive/hive_see
	name = "Hive Vision"
	desc = "We use the eyes of one of our vessels. Use again to look through our own eyes once more."
	action_icon_state = "see"
	var/mob/living/carbon/vessel
	var/mob/living/host //Didn't really have any other way to auto-reset the perspective if the other mob got qdeled

	charge_max = 20

/obj/effect/proc_holder/spell/target_hive/hive_see/on_lose(mob/living/user)
	user.reset_perspective()
	user.clear_fullscreen("hive_eyes")

/obj/effect/proc_holder/spell/target_hive/hive_see/cast(list/targets, mob/living/user = usr)
	if(!active)
		vessel = targets[1]
		if(vessel)
			vessel.apply_status_effect(STATUS_EFFECT_BUGGED, user)
			user.reset_perspective(vessel)
			active = TRUE
			host = user
			user.overlay_fullscreen("hive_eyes", /atom/movable/screen/fullscreen/hive_eyes)
		revert_cast()
	else
		vessel.remove_status_effect(STATUS_EFFECT_BUGGED)
		user.reset_perspective()
		user.clear_fullscreen("hive_eyes")
		active = FALSE
		revert_cast()

/obj/effect/proc_holder/spell/target_hive/hive_see/process()
	if(active && (!vessel || !is_hivemember(vessel) || QDELETED(vessel)))
		to_chat(host, "<span class='warning'>Our vessel is one of us no more!</span>")
		host.reset_perspective()
		host.clear_fullscreen("hive_eyes")
		active = FALSE
		if(!QDELETED(vessel))
			vessel.remove_status_effect(STATUS_EFFECT_BUGGED)
	..()

/obj/effect/proc_holder/spell/target_hive/hive_see/choose_targets(mob/user = usr)
	if(!active)
		..()
	else
		perform(null,user)
