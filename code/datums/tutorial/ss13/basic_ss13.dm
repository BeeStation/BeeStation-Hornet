/datum/tutorial/ss13/basic
	name = "Space Station 13 - Basic"
	desc = "Learn the very basics of Space Station 13. Recommended if you haven't played before."
	tutorial_id = "ss13_basic_1"
	tutorial_template = /datum/map_template/tutorial/s12x12

/datum/tutorial/ss13/basic/start_tutorial(mob/starting_mob)
	. = ..()
	init_mob()

	message_to_player("This is the tutorial for the basics of <b>Space Station 13</b>.")
	addtimer(CALLBACK(src, PROC_REF(require_move)), 4 SECONDS) // check if this is a good amount of time

/datum/tutorial/ss13/basic/proc/require_move()
	message_to_player("Now, move in any direction using <b>[retrieve_bind("move_north")]</b>, <b>[retrieve_bind("move_west")]</b>, <b>[retrieve_bind("move_south")]</b>, or <b>[retrieve_bind("move_east")]</b>.")

	RegisterSignal(tutorial_mob, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))

/datum/tutorial/ss13/basic/proc/on_move(datum/source, actually_moving, direction, specific_direction)
	SIGNAL_HANDLER

	UnregisterSignal(tutorial_mob, COMSIG_MOVABLE_MOVED)

	message_to_player("Good. Now, switch hands with <b>[retrieve_bind("swap_hands")]</b>.")
	RegisterSignal(tutorial_mob, COMSIG_MOB_SWAP_HANDS, PROC_REF(on_hand_swap))	

/datum/tutorial/ss13/basic/proc/on_hand_swap(datum/source)
	SIGNAL_HANDLER

	UnregisterSignal(tutorial_mob, COMSIG_MOB_SWAP_HANDS)

	message_to_player("Good. Now, pick up the <b>backpack</b> that just spawned and equip it with <b>[retrieve_bind("quick_equip")]</b>.")

	var/obj/item/storage/backpack/backpack = new(loc_from_corner(2, 2))
//	add_to_tracking_atoms(satchel)
//	add_highlight(satchel)

	RegisterSignal(tutorial_mob, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(on_backpack_equip))

/datum/tutorial/ss13/basic/proc/on_backpack_equip(datum/source, obj/item/equiped, slot)
	SIGNAL_HANDLER

	if(slot != ITEM_SLOT_BACK)
		return

	UnregisterSignal(tutorial_mob, COMSIG_MOB_EQUIPPED_ITEM)

	message_to_player("Nice, say anything by pressing <b>[retrieve_bind("say")]</b> and typing in the chat box.")
	RegisterSignal(tutorial_mob, COMSIG_MOB_SAY, PROC_REF(on_say))

/datum/tutorial/ss13/basic/proc/on_say(datum/source)
	SIGNAL_HANDLER

	UnregisterSignal(tutorial_mob, COMSIG_MOB_SAY)

	message_to_player("Good. The next tutorial will cover <b>intents</b>. The tutirial will end shortly.")
	tutorial_end_in(5 SECONDS, TRUE)

