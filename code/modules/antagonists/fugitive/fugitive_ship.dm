//works similar to the experiment machine (experiment.dm) except it just holds more and more prisoners

/obj/machinery/fugitive_capture
	name = "bluespace capture machine"
	desc = "Much, MUCH bigger on the inside to transport prisoners safely."
	icon = 'icons/obj/machines/teleporter.dmi'
	icon_state = "bluespace-prison"
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF //ha ha no getting out!!

/obj/machinery/fugitive_capture/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Add a prisoner by dragging them into the machine.</span>"

/obj/machinery/fugitive_capture/MouseDrop_T(mob/target, mob/user)
	var/mob/living/L = user
	if(user.stat || (isliving(user) && (!(L.mobility_flags & MOBILITY_STAND) || !(L.mobility_flags & MOBILITY_UI))) || !Adjacent(user) || !target.Adjacent(user) || !ishuman(target))
		return
	var/datum/antagonist/fugitive/fug = L.mind.has_antag_datum(/datum/antagonist/fugitive)
	if(!fug)
		to_chat(user, "<span class='warning'>This is not a wanted fugitive!</span>")
	if(do_after(user, 50, target = src))
		add_prisoner(target)

/obj/machinery/fugitive_capture/proc/add_prisoner(mob/target, datum/antagonist/fugitive/fug)
	target.forceMove(src)
	fug.is_captured = TRUE
	to_chat(target, "<span class='userdanger'>You are thrown into a vast void of bluespace, and as you fall further into oblivion the comparatively small entrance to reality gets smaller and smaller until you cannot see it anymore. You have failed to avoid capture.</span>")
	target.ghostize(TRUE) //so they cannot suicide, round end stuff.

/datum/map_template/space_cop_ship
	name = "Police Spacevan"
	mappath = "_maps/shuttles/fugitive_hunter_space_cop.dmm"

/datum/map_template/russian_ship
	name = "Russian Cargo Ship"
	mappath = "_maps/shuttles/fugitive_hunter_russian.dmm"
