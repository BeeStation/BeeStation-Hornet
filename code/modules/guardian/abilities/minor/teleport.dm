/datum/guardian_ability/minor/teleport
	name = "Teleportation Pad"
	desc = "The guardian can prepare a teleportation pad, and teleport things to it afterwards."
	ui_icon = "shipping-fast"
	cost = 3
	spell_type = /obj/effect/proc_holder/spell/targeted/guardian/teleport

/datum/guardian_ability/minor/teleport/Apply()
	..()
	guardian.add_verb(/mob/living/simple_animal/hostile/guardian/proc/Beacon)

/datum/guardian_ability/minor/teleport/Remove()
	..()
	guardian.remove_verb(/mob/living/simple_animal/hostile/guardian/proc/Beacon)

/obj/effect/proc_holder/spell/targeted/guardian/teleport
	name = "Teleport"
	desc = "Teleport someone to your receiving pad."

/obj/effect/proc_holder/spell/targeted/guardian/teleport/InterceptClickOn(mob/living/caller, params, atom/movable/A)
	if(!istype(A))
		return
	if(!isguardian(caller))
		revert_cast()
		return
	var/mob/living/simple_animal/hostile/guardian/G = caller
	if(!G.is_deployed())
		to_chat(G, "<span class='danger'><B>You must be manifested to warp a target!</span></B>")
		return
	if(!G.can_use_abilities)
		to_chat(G, "<span class='danger'><B>You can't do that right now!</span></B>")
		return
	if(!G.beacon)
		to_chat(G, "<span class='danger'><B>You need a beacon placed to warp things!</span></B>")
		return
	if(!G.Adjacent(A))
		to_chat(G, "<span class='danger'><B>You must be adjacent to your target!</span></B>")
		return
	if(A.anchored)
		to_chat(G, "<span class='danger'><B>Your target cannot be anchored!</span></B>")
		return

	var/turf/T = get_turf(A)
	if(G.beacon.get_virtual_z_level() != T.get_virtual_z_level())
		to_chat(G, "<span class='danger'><B>The beacon is too far away to warp to!</span></B>")
		return
	remove_ranged_ability()

	to_chat(G, "<span class='danger'><B>You begin to warp [A].</span></B>")
	A.visible_message("<span class='danger'>[A] starts to glow faintly!</span>", \
	"<span class='userdanger'>You start to faintly glow, and you feel strangely weightless!</span>")
	G.do_attack_animation(A)

	if(!do_after(G, 6 SECONDS, A)) //now start the channel
		to_chat(G, "<span class='danger'><B>You need to hold still!</span></B>")
		return

	new /obj/effect/temp_visual/guardian/phase/out(T)
	if(isliving(A))
		var/mob/living/L = A
		L.flash_act()
	A.visible_message("<span class='danger'>[A] disappears in a flash of light!</span>", \
	"<span class='userdanger'>Your vision is obscured by a flash of light!</span>")
	do_teleport(A, G.beacon, 0, channel = TELEPORT_CHANNEL_BLUESPACE)
	new /obj/effect/temp_visual/guardian/phase(get_turf(A))

/mob/living/simple_animal/hostile/guardian/proc/Beacon()
	set name = "Place Bluespace Beacon"
	set category = "Guardian"
	set desc = "Mark a floor as your beacon point, allowing you to warp targets to it. Your beacon will not work at extreme distances."
	if(beacon_cooldown >= world.time)
		to_chat(src, "<span class='danger'><B>Your power is on cooldown. You must wait five minutes between placing beacons.</span></B>")
		return
	var/turf/beacon_loc = get_turf(src.loc)
	if(!isfloorturf(beacon_loc))
		return
	if(beacon)
		beacon.disappear()
		beacon = null
	beacon = new(beacon_loc, src)
	to_chat(src, "<span class='danger'><B>Beacon placed! You may now warp targets and objects to it, including your user, via the Teleport ability.</span></B>")
	beacon_cooldown = world.time + 3000


// the pad
/obj/structure/receiving_pad
	name = "bluespace receiving pad"
	icon = 'icons/turf/floors.dmi'
	desc = "A receiving zone for bluespace teleportations."
	icon_state = "light_on-w"
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	density = FALSE
	anchored = TRUE
	layer = ABOVE_OPEN_TURF_LAYER

/obj/structure/receiving_pad/Initialize(mapload, mob/living/simple_animal/hostile/guardian/G)
	. = ..()
	if(!istype(G))
		return INITIALIZE_HINT_QDEL
	add_atom_colour(G.guardiancolor, FIXED_COLOUR_PRIORITY)

/obj/structure/receiving_pad/proc/disappear()
	visible_message("[src] vanishes!")
	qdel(src)
