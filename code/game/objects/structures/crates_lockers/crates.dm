/obj/structure/closet/crate
	name = "crate"
	desc = "A rectangular steel crate."
	icon = 'icons/obj/crates.dmi'
	icon_state = "crate"
	req_access = null
	can_weld_shut = FALSE
	horizontal = TRUE
	allow_objects = TRUE
	allow_dense = TRUE
	dense_when_open = TRUE
	climbable = TRUE
	climb_time = 10 //real fast, because let's be honest stepping into or onto a crate is easy
	climb_stun = 0 //climbing onto crates isn't hard, guys
	delivery_icon = "deliverycrate"
	door_anim_time = 3
	door_anim_angle = 180
	door_hinge = 3.5
	open_sound = 'sound/machines/crate_open.ogg'
	close_sound = 'sound/machines/crate_close.ogg'
	open_sound_volume = 35
	close_sound_volume = 50
	drag_slowdown = 0
	var/azimuth_angle_2 = 138 //in this context the azimuth angle for over 90 degree
	var/obj/item/paper/fluff/jobs/cargo/manifest/manifest
	var/radius_2 = 1.35
	var/static/list/animation_math //assoc list with pre calculated values

/obj/structure/closet/crate/Initialize()
	. = ..()
	if(animation_math == null) //checks if there is already a list for animation_math if not creates one to avoid runtimes
		animation_math = new/list()
	if(!door_anim_time == 0 && !animation_math["[door_anim_time]-[door_anim_angle]-[azimuth_angle_2]-[radius_2]-[door_hinge]"])
		animation_list()

/obj/structure/closet/crate/CanPass(atom/movable/mover, turf/target)
	if(!istype(mover, /obj/structure/closet))
		var/obj/structure/closet/crate/locatedcrate = locate(/obj/structure/closet/crate) in get_turf(mover)
		if(locatedcrate) //you can walk on it like tables, if you're not in an open crate trying to move to a closed crate
			if(opened) //if we're open, allow entering regardless of located crate openness
				return 1
			if(!locatedcrate.opened) //otherwise, if the located crate is closed, allow entering
				return 1
	return !density

/obj/structure/closet/crate/update_icon()
	cut_overlays()
	if(!opened)
		layer = OBJ_LAYER
		if(!is_animating_door)
			if(icon_door)
				add_overlay("[icon_door]_door")
			else
				add_overlay("[icon_state]_door")
	else
		layer = BELOW_OBJ_LAYER
		if(!is_animating_door)
			if(icon_door_override)
				add_overlay("[icon_door]_open")
			else
				add_overlay("[icon_state]_open")

/obj/structure/closet/crate/animate_door(var/closing = FALSE)
	if(!door_anim_time)
		return
	if(!door_obj) door_obj = new
	vis_contents |= door_obj
	door_obj.icon = icon
	door_obj.icon_state = "[icon_door || icon_state]_door"
	is_animating_door = TRUE
	var/num_steps = door_anim_time / world.tick_lag
	var/list/animation_math_list = animation_math["[door_anim_time]-[door_anim_angle]-[azimuth_angle_2]-[radius_2]-[door_hinge]"]
	for(var/I in 0 to num_steps)
		var/door_state = I == (closing ? num_steps : 0) ? "[icon_door || icon_state]_door" : animation_math_list[closing ? 2 * num_steps - I : num_steps + I] <= 0 ? "[icon_door_override ? icon_door : icon_state]_back" : "[icon_door || icon_state]_door"
		var/door_layer = I == (closing ? num_steps : 0) ? ABOVE_MOB_LAYER : animation_math_list[closing ? 2 * num_steps - I : num_steps + I] <= 0 ? FLOAT_LAYER : ABOVE_MOB_LAYER
		var/matrix/M = get_door_transform(I == (closing ? num_steps : 0) ? 0 : animation_math_list[closing ? num_steps - I : I], I == (closing ? num_steps : 0) ? 1 : animation_math_list[closing ?  2 * num_steps - I : num_steps + I])
		if(I == 0)
			door_obj.transform = M
			door_obj.icon_state = door_state
			door_obj.layer = door_layer
		else if(I == 1)
			animate(door_obj, transform = M, icon_state = door_state, layer = door_layer, time = world.tick_lag, flags = ANIMATION_END_NOW)
		else
			animate(transform = M, icon_state = door_state, layer = door_layer, time = world.tick_lag)
	addtimer(CALLBACK(src,.proc/end_door_animation),door_anim_time,TIMER_UNIQUE|TIMER_OVERRIDE)

/obj/structure/closet/crate/end_door_animation()
	is_animating_door = FALSE
	vis_contents -= door_obj
	update_icon()
	COMPILE_OVERLAYS(src)

/obj/structure/closet/crate/get_door_transform(crateanim_1, crateanim_2)
	var/matrix/M = matrix()
	M.Translate(0, -door_hinge)
	M.Multiply(matrix(1, crateanim_1, 0, 0, crateanim_2, 0))
	M.Translate(0, door_hinge)
	return M

/obj/structure/closet/crate/proc/animation_list() //pre calculates a list of values for the crate animation cause byond not like math
	var/num_steps_1 = door_anim_time / world.tick_lag
	var/list/new_animation_math_sublist[num_steps_1 * 2]
	for(var/I in 1 to num_steps_1) //loop to save the animation values into the lists
		var/angle_1 = door_anim_angle * (I / num_steps_1)
		var/polar_angle = abs(arcsin(cos(angle_1)))
		var/azimuth_angle = angle_1 >= 90 ? azimuth_angle_2 : 0
		var/radius_cr = angle_1 >= 90 ? radius_2 : 1
		new_animation_math_sublist[I] = -sin(polar_angle) * sin(azimuth_angle) * radius_cr
		new_animation_math_sublist[num_steps_1 + I] = cos(azimuth_angle) * sin(polar_angle) * radius_cr
	animation_math["[door_anim_time]-[door_anim_angle]-[azimuth_angle_2]-[radius_2]-[door_hinge]"] = new_animation_math_sublist

/obj/structure/closet/crate/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(manifest)
		tear_manifest(user)

/obj/structure/closet/crate/open(mob/living/user)
	. = ..()
	if(. && manifest)
		to_chat(user, "<span class='notice'>The manifest is torn off [src].</span>")
		playsound(src, 'sound/items/poster_ripped.ogg', 75, 1)
		manifest.forceMove(get_turf(src))
		manifest = null
		update_icon()

/obj/structure/closet/crate/proc/tear_manifest(mob/user)
	to_chat(user, "<span class='notice'>You tear the manifest off of [src].</span>")
	playsound(src, 'sound/items/poster_ripped.ogg', 75, 1)

	manifest.forceMove(loc)
	if(ishuman(user))
		user.put_in_hands(manifest)
	manifest = null
	update_icon()

/obj/structure/closet/crate/coffin
	name = "coffin"
	desc = "It's a burial receptacle for the dearly departed."
	icon_state = "coffin"
	resistance_flags = FLAMMABLE
	max_integrity = 70
	material_drop = /obj/item/stack/sheet/mineral/wood
	material_drop_amount = 5
	open_sound = 'sound/machines/wooden_closet_open.ogg'
	close_sound = 'sound/machines/wooden_closet_close.ogg'
	open_sound_volume = 25
	close_sound_volume = 50
	door_anim_angle = 140
	azimuth_angle_2 = 180
	door_anim_time = 5
	door_hinge = 5

/obj/structure/closet/crate/internals
	desc = "An internals crate."
	name = "internals crate"
	icon_state = "o2_crate"

/obj/structure/closet/crate/trashcart
	desc = "A heavy, metal trashcart with wheels."
	name = "trash cart"
	icon_state = "trashcart"
	door_anim_time = 0

/obj/structure/closet/crate/medical
	desc = "A medical crate."
	name = "medical crate"
	icon_state = "medical_crate"

/obj/structure/closet/crate/freezer
	desc = "A freezer."
	name = "freezer"
	icon_state = "freezer"
	door_hinge = 5
	door_anim_angle = 165
	azimuth_angle_2 = 145

//Snowflake organ freezer code
//Order is important, since we check source, we need to do the check whenever we have all the organs in the crate

/obj/structure/closet/crate/freezer/open()
	recursive_organ_check(src)
	..()

/obj/structure/closet/crate/freezer/close()
	..()
	recursive_organ_check(src)

/obj/structure/closet/crate/freezer/Destroy()
	recursive_organ_check(src)
	return ..()

/obj/structure/closet/crate/freezer/Initialize()
	..()
	recursive_organ_check(src)



/obj/structure/closet/crate/freezer/blood
	name = "blood freezer"
	desc = "A freezer containing packs of blood."

/obj/structure/closet/crate/freezer/blood/PopulateContents()
	. = ..()
	new /obj/item/reagent_containers/blood(src)
	new /obj/item/reagent_containers/blood(src)
	new /obj/item/reagent_containers/blood/AMinus(src)
	new /obj/item/reagent_containers/blood/BMinus(src)
	new /obj/item/reagent_containers/blood/BPlus(src)
	new /obj/item/reagent_containers/blood/OMinus(src)
	new /obj/item/reagent_containers/blood/OPlus(src)
	new /obj/item/reagent_containers/blood/lizard(src)
	new /obj/item/reagent_containers/blood/ethereal(src)
	new /obj/item/reagent_containers/blood/oozeling(src)
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/blood/random(src)

/obj/structure/closet/crate/freezer/surplus_limbs
	name = "surplus prosthetic limbs"
	desc = "A crate containing an assortment of cheap prosthetic limbs."

/obj/structure/closet/crate/freezer/surplus_limbs/PopulateContents()
	. = ..()
	new /obj/item/bodypart/l_arm/robot/surplus(src)
	new /obj/item/bodypart/l_arm/robot/surplus(src)
	new /obj/item/bodypart/r_arm/robot/surplus(src)
	new /obj/item/bodypart/r_arm/robot/surplus(src)
	new /obj/item/bodypart/l_leg/robot/surplus(src)
	new /obj/item/bodypart/l_leg/robot/surplus(src)
	new /obj/item/bodypart/r_leg/robot/surplus(src)
	new /obj/item/bodypart/r_leg/robot/surplus(src)

/obj/structure/closet/crate/radiation
	desc = "A crate with a radiation sign on it."
	name = "radiation crate"
	icon_state = "radiation_crate"

/obj/structure/closet/crate/hydroponics
	name = "hydroponics crate"
	desc = "All you need to destroy those pesky weeds and pests."
	icon_state = "hydro_crate"

/obj/structure/closet/crate/engineering
	name = "engineering crate"
	icon_state = "engi_crate"

/obj/structure/closet/crate/engineering/electrical
	icon_state = "engi_e_crate"
	icon_door = "engi_crate"

/obj/structure/closet/crate/rcd
	desc = "A crate for the storage of an RCD."
	name = "\improper RCD crate"
	icon_state = "engi_crate"

/obj/structure/closet/crate/rcd/PopulateContents()
	..()
	for(var/i in 1 to 4)
		new /obj/item/rcd_ammo(src)
	new /obj/item/construction/rcd(src)

/obj/structure/closet/crate/science
	name = "science crate"
	desc = "A science crate."
	icon_state = "sci_crate"

/obj/structure/closet/crate/solarpanel_small
	name = "budget solar panel crate"
	icon_state = "engi_e_crate"

/obj/structure/closet/crate/solarpanel_small/PopulateContents()
	..()
	for(var/i in 1 to 13)
		new /obj/item/solar_assembly(src)
	new /obj/item/circuitboard/computer/solar_control(src)
	new /obj/item/paper/guides/jobs/engi/solars(src)
	new /obj/item/electronics/tracker(src)

/obj/structure/closet/crate/goldcrate
	name = "gold crate"

/obj/structure/closet/crate/goldcrate/PopulateContents()
	..()
	for(var/i in 1 to 3)
		new /obj/item/stack/sheet/mineral/gold(src, 1, FALSE)
	new /obj/item/storage/belt/champion(src)

/obj/structure/closet/crate/silvercrate
	name = "silver crate"

/obj/structure/closet/crate/silvercrate/PopulateContents()
	..()
	for(var/i in 1 to 5)
		new /obj/item/coin/silver(src)
