/obj/structure/cat_house
	name = "cat house"
	desc = "Cozy home for cats."
	icon = 'icons/mob/pets.dmi'
	icon_state = "cat_house"
	density = TRUE
	anchored = TRUE
	///cat residing in this house
	var/mob/living/resident_cat
	/// The timer details
	var/exit_timer_id

/obj/structure/cat_house/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_ATTACK_BASIC_MOB, PROC_REF(enter_home))

/obj/structure/cat_house/proc/enter_home(datum/source, mob/living/attacker)
	SIGNAL_HANDLER

	if(isnull(resident_cat) && iscat(attacker))
		attacker.forceMove(src)
		update_appearance(UPDATE_OVERLAYS)

		if(attacker.client) //  The cat is a player, no need for a timer
			if(exit_timer_id)
				deltimer(exit_timer_id)
				exit_timer_id = null
			return
		if(exit_timer_id) // AI cat, timer to let them out
			deltimer(exit_timer_id)
			exit_timer_id = null
		exit_timer_id = addtimer(CALLBACK(src, PROC_REF(eject_cat)), rand(10 SECONDS, 20 SECONDS), TIMER_STOPPABLE)
		return
	if(resident_cat == attacker) // Clicking again? let them out.
		if(exit_timer_id)
			deltimer(exit_timer_id)
			exit_timer_id = null
		attacker.forceMove(drop_location())
		update_appearance(UPDATE_OVERLAYS)

/obj/structure/cat_house/proc/eject_cat()
	if(isnull(resident_cat))
		return
	resident_cat.forceMove(drop_location())

/obj/structure/cat_house/Entered(atom/movable/mover)
	. = ..()
	if(!iscat(mover))
		return
	if(isnull(resident_cat))
		resident_cat = mover
	update_appearance(UPDATE_OVERLAYS)

/obj/structure/cat_house/Exited(atom/movable/mover)
	. = ..()
	if(mover != resident_cat)
		return
	resident_cat = null
	if(exit_timer_id)
		deltimer(exit_timer_id)
		exit_timer_id = null
	update_appearance(UPDATE_OVERLAYS)

/obj/structure/cat_house/Destroy()
	if(!isnull(resident_cat))
		resident_cat.forceMove(loc)
		resident_cat = null
	if(exit_timer_id)
		deltimer(exit_timer_id)
		exit_timer_id = null
	return ..()

/obj/structure/cat_house/update_overlays()
	. = ..()
	if(isnull(resident_cat))
		return
	var/image/cat_icon = image(icon = resident_cat.icon, icon_state = resident_cat.icon_state, layer = LOW_ITEM_LAYER)
	cat_icon.transform = cat_icon.transform.Scale(0.7, 0.7)
	cat_icon.pixel_w = 0
	cat_icon.pixel_z = -9
	. += cat_icon
