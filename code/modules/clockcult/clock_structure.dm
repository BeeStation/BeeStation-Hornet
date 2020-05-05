//The base clockwork structure. Can have an alternate desc and will show up in the list of clockwork objects.
/obj/structure/destructible/clockwork
	name = "meme structure"
	desc = "Some frog or something, the fuck?"
	var/clockwork_desc //Shown to servants when they examine
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "rare_pepe"
	var/unanchored_icon //icon for when this structure is unanchored, doubles as the var for if it can be unanchored
	anchored = TRUE
	density = TRUE
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/can_be_repaired = TRUE //if a fabricator can repair it
	break_message = "<span class='warning'>The frog isn't a meme after all!</span>" //The message shown when a structure breaks
	break_sound = 'sound/magic/clockwork/anima_fragment_death.ogg' //The sound played when a structure breaks
	debris = list(/obj/item/clockwork/alloy_shards/large = 1, \
	/obj/item/clockwork/alloy_shards/medium = 2, \
	/obj/item/clockwork/alloy_shards/small = 3) //Parts left behind when a structure breaks
	var/construction_value = 0 //How much value the structure contributes to the overall "power" of the structures on the station
	var/immune_to_servant_attacks = FALSE //if we ignore attacks from servants of ratvar instead of taking damage

/obj/structure/destructible/clockwork/narsie_act()
	if(take_damage(rand(25, 50), BRUTE) && src) //if we still exist
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 8)
		addtimer(CALLBACK(src, /atom/proc/update_atom_colour), 8)

/obj/structure/destructible/clockwork/examine(mob/user)
	. = ..()
	if(unanchored_icon)
		. += "<span class='notice'>[src] is [anchored ? "":"not "]secured to the floor.</span>"

/obj/structure/destructible/clockwork/hulk_damage()
	return 20

/obj/structure/destructible/clockwork/proc/get_efficiency_mod()
	. = max(sqrt(obj_integrity/max(max_integrity, 1)), 0.5)
	. = round(., 0.01)

/obj/structure/destructible/clockwork/proc/update_anchored(mob/user, do_damage)
	if(anchored)
		icon_state = initial(icon_state)
	else
		icon_state = unanchored_icon
		if(do_damage)
			playsound(src, break_sound, 10 * (40 * (1 - get_efficiency_mod())), 1)
			take_damage(round(max_integrity * 0.25, 1), BRUTE)
			to_chat(user, "<span class='warning'>As you unsecure [src] from the floor, you see cracks appear in its surface!</span>")

/obj/structure/destructible/clockwork/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(anchored && unanchored_icon)
		anchored = FALSE
		update_anchored(null, obj_integrity > max_integrity * 0.25)
		new /obj/effect/temp_visual/emp(loc)
