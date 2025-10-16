/**
 * # Shell Item
 *
 * Printed out by protolathes. Screwdriver to complete the shell.
 */
/obj/item/shell
	name = "assembly"
	desc = "A shell assembly that can be completed by screwdrivering it."
	icon = 'icons/obj/wiremod.dmi'
	var/shell_to_spawn
	var/screw_delay = 3 SECONDS

/obj/item/shell/screwdriver_act(mob/living/user, obj/item/tool)
	user.visible_message(span_notice("[user] begins finishing [src]."), span_notice("You begin finishing [src]."))
	tool.play_tool_sound(src)
	if(!do_after(user, screw_delay, target = src))
		return
	user.visible_message(span_notice("[user] finishes [src]."), span_notice("You finish [src]."))

	var/turf/drop_loc = drop_location()

	qdel(src)
	if(drop_loc)
		new shell_to_spawn(drop_loc)

	return TRUE

/obj/item/shell/bot
	name = "bot assembly"
	icon_state = "setup_medium_box-open"
	shell_to_spawn = /obj/structure/bot
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/shell/money_bot
	name = "money bot assembly"
	icon_state = "setup_large-open"
	shell_to_spawn = /obj/structure/money_bot
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/shell/drone
	name = "drone assembly"
	icon_state = "setup_drone_arms-open"
	shell_to_spawn = /mob/living/circuit_drone
	w_class = WEIGHT_CLASS_NORMAL		// you should be able to fit these in your back pack

/obj/item/shell/server
	name = "server assembly"
	icon_state = "setup_stationary-open"
	shell_to_spawn = /obj/structure/server
	screw_delay = 6 SECONDS
	w_class = WEIGHT_CLASS_BULKY

/obj/item/shell/server/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands=TRUE)

/obj/item/shell/airlock
	name = "circuit airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/public.dmi'
	icon_state = "construction"
	shell_to_spawn = /obj/machinery/door/airlock/shell
	screw_delay = 10 SECONDS
	w_class = WEIGHT_CLASS_GIGANTIC

/obj/item/shell/airlock/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands=TRUE) // that you even are allowed to carry around an airlock frame is weird.

/obj/item/shell/bci
	name = "brain-computer interface assembly"
	icon_state = "bci-open"
	shell_to_spawn = /obj/item/organ/cyberimp/bci
	w_class = WEIGHT_CLASS_TINY

/obj/item/shell/scanner_gate
	name = "scanner gate assembly"
	icon = 'icons/obj/machines/scangate.dmi'
	icon_state = "scangate"
	shell_to_spawn = /obj/structure/scanner_gate_shell
	w_class = WEIGHT_CLASS_LARGE

/obj/item/shell/controller
	name = "controller assembly"
	icon_state = "setup_small_calc-open"
	shell_to_spawn = /obj/item/controller
	w_class = WEIGHT_CLASS_SMALL

/obj/item/shell/compact_remote
	name = "compact remote assembly"
	icon_state = "setup_small_simple-open"
	shell_to_spawn = /obj/item/compact_remote
	w_class = WEIGHT_CLASS_TINY

/obj/item/shell/wiremod_scanner
	name = "scanner assembly"
	icon_state = "setup_small-open"
	shell_to_spawn = /obj/item/wiremod_scanner
	w_class = WEIGHT_CLASS_SMALL
