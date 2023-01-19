/obj/structure/popout_cake
	name = "towering cake"
	desc = "A humongous multi-tiered cake."
	icon = 'icons/obj/structures.dmi'
	icon_state = "popout_cake"
	density = TRUE
	anchored = FALSE
	can_buckle = 1
	buckle_lying = 0 //you sit in a chair, not lay
	resistance_flags = NONE
	max_integrity = 100
	integrity_failure = 10
	move_resist = MOVE_FORCE_WEAK
	layer = OBJ_LAYER
	var/mob/living/occupant = null
	var/datum/action/item_action/pull_string/string //Action for pulling the string for a surprise reveal
	var/used_string = FALSE //If the string for a surprise reveal has been pulled from inside
	var/amount_of_slices = 16 //How many cake slices will appear once it's cut up
	var/slice_path  = /obj/item/reagent_containers/food/snacks/cakeslice/plain/full //What kind of cake slice will appear
	var/strong_surprise = FALSE //If the surprise reveal has an extra oomph to it, used for the newcop exclusive cake

/obj/structure/popout_cake/newcop
	strong_surprise = TRUE

/obj/structure/popout_cake/Initialize(mapload)
	. = ..()
	if(!string)
		var/datum/action/item_action/pull_string/S = new()
		string = S
		string.cake = src

/obj/structure/popout_cake/MouseDrop_T(mob/living/target, mob/user)
	if(!istype(target) || user.incapacitated() || !target.Adjacent(user) || !Adjacent(user) || !ismob(target) || (!ishuman(user) && !iscyborg(user)) || !istype(user.loc, /turf) || target.buckled)
		return

	if(occupant)
		to_chat(user, "<span class='warning'>There's already someone inside!</span>")
		return

	if(obj_integrity <= integrity_failure)
		to_chat(user, "<span class='warning'>The [src] is too damaged to hold anyone inside!</span>")
		return

	if(target == user)
		visible_message("[user] starts climbing into [src].")
	else
		visible_message("[user] starts putting [target] into [src].")

	if(do_after(user, 60, TRUE, src))
		if(occupant)
			to_chat(user, "<span class='warning'>There's already someone inside!</span>")
			return
		target.forceMove(src)
		occupant = target
		if(target != user)
			log_combat(user, occupant, "stuffed ", null, "into [src]")
		string.Grant(occupant)
		to_chat(user, "<span class='notice'>You are now inside the cake! When you're ready to emerge from the cake in a blaze of confetti and party horns, \
		pull on the string(<b>this can only be done once</b>). If you wish to leave without setting off the confetti, just attempt to move out of the cake!</span>")
	add_fingerprint(target)

/obj/structure/popout_cake/relaymove(mob/user, direction)
	if(!istype(user))
		return
	else if(contents.Find(user))
		to_chat(user, "<span class='info'>You begin climbing out of the [src]...</span>")
		if(do_after(user, 20))
			user.forceMove(get_turf(src))

/obj/structure/popout_cake/attackby(obj/item/W, mob/user, params)
	if(W.is_sharp())
		visible_message("[user] begins cutting into [src] with [W]!")
		if(do_after(user, 60, FALSE, src))
			do_popout()
			if(!strong_surprise)
				for(var/i=1 to (amount_of_slices))
					var/obj/item/reagent_containers/food/snacks/slice = new slice_path (loc)
					slice.initialize_slice(slice, 0)
			qdel(src)
	else
		..()

/obj/structure/popout_cake/proc/do_popout()
	if(isnull(occupant))
		return
	visible_message("Loud shuffling can be heard from inside [src]!")
	if(!used_string)
		used_string = TRUE
		playsound(src, 'sound/items/party_horn.ogg', 50, 1)
		var/datum/effect_system/spark_spread/s = new()
		s.set_up(6, FALSE, src)
		s.start()
	if(strong_surprise) //This is the extra OOMPH, a mini flashbang plus a small explosion that scatters all the pie slices around!
		var/flashing_turf = get_turf(src)
		for(var/mob/living/M in viewers(5, flashing_turf))
			if(M != occupant) //So that the guy hiding inside doesn't get flashed
				flash_and_bang(get_turf(M), M)
				for(var/i=1 to (amount_of_slices))
					var/obj/item/reagent_containers/food/snacks/slice = new slice_path (loc)
					slice.initialize_slice(slice, 0)
					slice.throw_at(get_edge_target_turf(src,pick(GLOB.alldirs)),rand(1,3),5)
	string.Remove(occupant)
	occupant.forceMove(get_turf(src))
	occupant = null
	if(strong_surprise)
		qdel(src)

/obj/structure/popout_cake/proc/flash_and_bang(turf/T, mob/living/M)
	if(M.stat == DEAD)	//They're dead!
		return
	var/distance = max(0,get_dist(get_turf(src),T))
	//When distance is 0, will be 1
	//When distance is 5, will be 0
	//Can be less than 0 due to hearers being a circular radius.
	var/distance_proportion = max(1 - (distance / 5), 0)
	M.show_message("<span class='warning'>BANG!</span>", MSG_AUDIBLE)
	if(M.flash_act(intensity = 1, affect_silicon = 1))
		if(distance_proportion)
			M.Paralyze(20 * distance_proportion)
			M.Knockdown(200 * distance_proportion)
	else
		M.flash_act(intensity = 2)
	if(!distance || loc == M || loc == M.loc)	//Stop allahu akbarring rooms with this.
		M.Paralyze(20)
		M.Knockdown(200)
		M.soundbang_act(1, 200, 10, 15)
	else
		if(distance <= 1)
			M.Paralyze(5)
			M.Knockdown(30)
		distance_proportion = max(1 - (distance / 5), 0)
		if(distance_proportion)
			M.soundbang_act(1, 200 * distance_proportion, rand(0, 5))

/obj/structure/popout_cake/Destroy()
	if(occupant)
		do_popout()
	..()

/datum/action/item_action/pull_string
	name = "String Tug"
	desc = "Pull the string and pop out of the cake in a surprising fashion, with confetti and everything!"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUN|AB_CHECK_CONSCIOUS
	button_icon_state = "pull_string"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	var/obj/structure/popout_cake/cake = null


/datum/action/item_action/pull_string/IsAvailable()
	if(..())
		if(!cake.used_string)
			return TRUE
		return FALSE

/datum/action/item_action/pull_string/Trigger()
	if(cake.used_string)
		to_chat(usr, "<span class ='notice'>The string is loose, it's already been used!</span>")
		return
	cake.do_popout()



