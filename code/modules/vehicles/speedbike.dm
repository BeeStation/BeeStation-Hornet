
/obj/vehicle/ridden/space
	name = "Generic Space Vehicle!"

/obj/vehicle/ridden/space/Initialize(mapload)
	. = ..()
	//TODO: Space subtyping is deprecated. Kill space subtyping

/obj/vehicle/ridden/space/speedbike
	name = "Speedbike"
	icon = 'icons/obj/bike.dmi'
	icon_state = "speedbike_blue"
	layer = LYING_MOB_LAYER
	var/overlay_state = "cover_blue"
	var/mutable_appearance/overlay

/obj/vehicle/ridden/space/speedbike/Initialize(mapload)
	. = ..()
	overlay = mutable_appearance(icon, overlay_state, ABOVE_MOB_LAYER)
	add_overlay(overlay)

/obj/vehicle/ridden/space/speedbike/add_riding_element()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/speedbike)

/obj/vehicle/ridden/space/speedbike/Move(newloc,move_dir)
	if(has_buckled_mobs())
		new /obj/effect/temp_visual/dir_setting/speedbike_trail(loc,move_dir)
	. = ..()

/obj/vehicle/ridden/space/speedbike/red
	icon_state = "speedbike_red"
	overlay_state = "cover_red"

//BM SPEEDWAGON

/obj/vehicle/ridden/space/speedwagon
	name = "BM Speedwagon"
	desc = "Push it to the limit, walk along the razor's edge."
	icon = 'icons/obj/car.dmi'
	icon_state = "speedwagon"
	layer = LYING_MOB_LAYER
	var/static/mutable_appearance/overlay
	max_buckled_mobs = 4
	var/crash_all = FALSE //CHAOS
	pixel_y = -48
	pixel_x = -48

/obj/vehicle/ridden/space/speedwagon/Initialize(mapload)
	. = ..()
	if(isnull(overlay))
		overlay = mutable_appearance(icon, "speedwagon_cover", ABOVE_MOB_LAYER)
	add_overlay(overlay)

/obj/vehicle/ridden/space/speedwagon/add_riding_element()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/speedwagon)

/obj/vehicle/ridden/space/speedwagon/Bump(atom/movable/A)
	. = ..()
	if(A.density && has_buckled_mobs())
		var/atom/throw_target = get_edge_target_turf(A, dir)
		if(crash_all)
			A.throw_at(throw_target, 4, 3)
			visible_message(span_danger("[src] crashes into [A]!"))
			playsound(src, 'sound/effects/bang.ogg', 50, 1)
		if(ishuman(A))
			var/mob/living/carbon/human/H = A
			var/multiplier = 1
			if(HAS_TRAIT(H, TRAIT_PROSKATER))
				multiplier = 0.3 //70% reduction
			H.Paralyze(multiplier * 100)
			H.adjustStaminaLoss(multiplier * 30)
			if(prob(multiplier * 100))
				H.apply_damage(rand(20,35), BRUTE)
			if(!crash_all)
				H.throw_at(throw_target, 4, 3)
				visible_message(span_danger("[src] crashes into [H]!"))
				playsound(src, 'sound/effects/bang.ogg', 50, 1)

/obj/vehicle/ridden/space/speedwagon/Moved()
	. = ..()
	if(!has_buckled_mobs())
		return
	for(var/atom/A as anything in range(2, src))
		if(!(A in buckled_mobs))
			Bump(A)
