/obj/structure/closet/crate/critter
	name = "critter crate"
	desc = "A crate designed for safe transport of animals. It has an oxygen tank for safe transport in space."
	icon_state = "critter_crate"
	horizontal = FALSE
	allow_objects = FALSE
	breakout_time = 600
	material_drop = /obj/item/stack/sheet/wood
	material_drop_amount = 4
	delivery_icon = "deliverybox"
	open_sound = 'sound/machines/wooden_closet_open.ogg'
	close_sound = 'sound/machines/wooden_closet_close.ogg'
	open_sound_volume = 25
	close_sound_volume = 50
	var/obj/item/tank/internals/emergency_oxygen/tank
	door_hinge = 5.5
	door_anim_angle = 90
	azimuth_angle_2 = 0.35
	door_anim_time = 0 // no animation

/obj/structure/closet/crate/critter/Initialize(mapload)
	. = ..()
	tank = new

/obj/structure/closet/crate/critter/Destroy()
	var/turf/T = get_turf(src)
	if(tank)
		tank.forceMove(T)
		tank = null

	return ..()

/obj/structure/closet/crate/critter/update_icon()
	. = ..()

/obj/structure/closet/crate/critter/animate_door(closing = FALSE)
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
		var/matrix/M = get_door_transform(I == (closing ? num_steps : 0) ? 1 : animation_math_list[closing ? num_steps - I : I], I == (closing ? num_steps : 0) ? 0 : animation_math_list[closing ? 2 * num_steps - I : num_steps + I])

		if(I == 0)
			door_obj.transform = M
		else if(I == 1)
			animate(door_obj, transform = M, time = world.tick_lag, flags = ANIMATION_END_NOW)
		else
			animate(transform = M, time = world.tick_lag)
	addtimer(CALLBACK(src,PROC_REF(end_door_animation)),door_anim_time,TIMER_UNIQUE|TIMER_OVERRIDE)

/obj/structure/closet/crate/critter/end_door_animation()
	is_animating_door = FALSE
	vis_contents -= door_obj
	update_icon()
	COMPILE_OVERLAYS(src)

/obj/structure/closet/crate/critter/get_door_transform(crateanim_1, crateanim_2)
	var/matrix/M = matrix()
	M.Translate(-door_hinge, 0)
	M.Multiply(matrix(crateanim_1, 0, 0, crateanim_2, 1, 0))
	M.Translate(door_hinge, 0)
	return M

/obj/structure/closet/crate/critter/return_air()
	if(tank)
		return tank.return_air()
	else
		return loc.return_air()

/obj/structure/closet/crate/critter/return_analyzable_air()
	if(tank)
		return tank.return_analyzable_air()
	else
		return null

/obj/structure/closet/crate/critter/animation_list()
	var/num_steps_1 = door_anim_time / world.tick_lag
	var/list/new_animation_math_sublist[num_steps_1 * 2]
	for(var/I in 1 to num_steps_1) //loop to save the animation values into the lists
		var/angle_1 = door_anim_angle * (I / num_steps_1)
		new_animation_math_sublist[I] = cos(angle_1)
		new_animation_math_sublist[num_steps_1+I] = sin(angle_1) * azimuth_angle_2
	animation_math["[door_anim_time]-[door_anim_angle]-[azimuth_angle_2]-[radius_2]-[door_hinge]"] = new_animation_math_sublist
