/obj/vehicle/ridden/scooter
	name = "scooter"
	desc = "A fun way to get around."
	icon_state = "scooter"
	are_legs_exposed = TRUE

/obj/vehicle/ridden/scooter/add_riding_element()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/scooter)

/obj/vehicle/ridden/scooter/wrench_act(mob/living/user, obj/item/I)
	to_chat(user, span_notice("You begin to remove the handlebars..."))
	if(I.use_tool(src, user, 40, volume=50))
		var/obj/vehicle/ridden/scooter/skateboard/S = new(drop_location())
		new /obj/item/stack/rods(drop_location(), 2)
		to_chat(user, span_notice("You remove the handlebars from [src]."))
		if(has_buckled_mobs())
			var/mob/living/carbon/H = buckled_mobs[1]
			unbuckle_mob(H)
			S.buckle_mob(H)
		qdel(src)
	return TRUE

/obj/vehicle/ridden/scooter/Moved()
	. = ..()
	for(var/m in buckled_mobs)
		var/mob/living/buckled_mob = m
		if(buckled_mob.num_legs > 0)
			buckled_mob.pixel_y = 5
		else
			buckled_mob.pixel_y = -4

/obj/vehicle/ridden/scooter/buckle_mob(mob/living/M, force = FALSE, check_loc = TRUE)
	if(!istype(M))
		return FALSE
	return ..()

/obj/vehicle/ridden/scooter/skateboard
	name = "improvised skateboard"
	desc = "An unfinished scooter which can only barely be called a skateboard. It's still rideable, but probably unsafe. Looks like you'll need to add a few rods to make handlebars."
	icon_state = "skateboard"
	density = FALSE
	var/datum/effect_system/spark_spread/sparks
	///Whether the board is currently grinding
	var/grinding = FALSE
	///Stores the time of the last crash plus a short cooldown, affects availability and outcome of certain actions
	var/next_crash
	///Stores the default icon state
	var/board_icon = "skateboard"
	///The handheld item counterpart for the board
	var/board_item_type = /obj/item/melee/skateboard
	///Stamina drain multiplier
	var/instability = 10

/obj/vehicle/ridden/scooter/skateboard/Initialize(mapload)
	. = ..()
	sparks = new
	sparks.set_up(1, 0, src)
	sparks.attach(src)

/obj/vehicle/ridden/scooter/skateboard/add_riding_element()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/scooter/skateboard)

/obj/vehicle/ridden/scooter/skateboard/Destroy()
	if(sparks)
		QDEL_NULL(sparks)
	. = ..()

/obj/vehicle/ridden/scooter/skateboard/relaymove(mob/living/user, direction)
	if (grinding || world.time < next_crash)
		return FALSE
	return ..()

/obj/vehicle/ridden/scooter/skateboard/generate_actions()
	. = ..()
	initialize_controller_action_type(/datum/action/vehicle/ridden/scooter/skateboard/ollie, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/ridden/scooter/skateboard/kflip, VEHICLE_CONTROL_DRIVE)

/obj/vehicle/ridden/scooter/skateboard/post_buckle_mob(mob/living/M)//allows skateboards to be non-dense but still allows 2 skateboarders to collide with each other
	set_density(TRUE)
	return ..()

/obj/vehicle/ridden/scooter/skateboard/post_unbuckle_mob(mob/living/M)
	if(!has_buckled_mobs())
		set_density(FALSE)
	return ..()

/obj/vehicle/ridden/scooter/skateboard/Bump(atom/A)
	. = ..()
	if(!A.density || !has_buckled_mobs())
		return

	var/mob/living/rider = buckled_mobs[1]
	var/multiplier = 1
	if(HAS_TRAIT(rider, TRAIT_PROSKATER))
		multiplier = 0.3 //70% reduction
	rider.adjustStaminaLoss(multiplier * instability * 6)
	playsound(src, 'sound/effects/bang.ogg', 40, TRUE)
	if(!iscarbon(rider) || rider.getStaminaLoss() >= 100 || grinding || world.time < next_crash)
		var/atom/throw_target = get_edge_target_turf(rider, pick(GLOB.cardinals))
		unbuckle_mob(rider)
		rider.throw_at(throw_target, 3, 2)
		var/head_slot = rider.get_item_by_slot(ITEM_SLOT_HEAD)
		if(!head_slot || !(istype(head_slot,/obj/item/clothing/head/helmet) || istype(head_slot,/obj/item/clothing/head/utility/hardhat)))
			if(prob(multiplier * 100)) //pro skaters get a 70% chance to not get the brain damage
				rider.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5)
				rider.updatehealth()
		visible_message("<span class='danger'>[src] crashes into [A], sending [rider] flying!</span>")
		rider.Paralyze(80 * multiplier)
	else
		var/backdir = turn(dir, 180)
		step(src, backdir)
		rider.spin(4, 1)
	next_crash = world.time + 10

///Moves the vehicle forward and if it lands on a table, repeats
/obj/vehicle/ridden/scooter/skateboard/proc/grind()
	step(src, dir)
	if(!has_buckled_mobs() || !(locate(/obj/structure/table) in loc.contents))
		grinding = FALSE
		icon_state = "[initial(icon_state)]"
		return

	var/mob/living/L = buckled_mobs[1]
	var/multiplier = 1
	if(HAS_TRAIT(L, TRAIT_PROSKATER))
		multiplier = 0.3 //70% reduction
	L.adjustStaminaLoss(multiplier * instability * 0.5)
	if (L.getStaminaLoss() >= 100)
		playsound(src, 'sound/effects/bang.ogg', 20, TRUE)
		unbuckle_mob(L)
		var/atom/throw_target = get_edge_target_turf(src, pick(GLOB.cardinals))
		L.throw_at(throw_target, 2, 2)
		visible_message("<span class='danger'>[L] loses [L.p_their()] footing and slams on the ground!</span>")
		L.Paralyze(multiplier * 40)
		grinding = FALSE
		icon_state = "[initial(icon_state)]"
	else
		playsound(src, 'sound/vehicles/skateboard_roll.ogg', 50, TRUE)
		if(prob (25))
			var/turf/location = get_turf(loc)
			if(location)
				location.hotspot_expose(1000,1000)
			sparks.start() //the most radical way to start plasma fires
		addtimer(CALLBACK(src, PROC_REF(grind)), 2)

/obj/vehicle/ridden/scooter/skateboard/MouseDrop(atom/over_object)
	. = ..()
	var/mob/living/carbon/skater = usr
	if(!istype(skater))
		return
	if (over_object == skater)
		pick_up_board(skater)


/obj/vehicle/ridden/scooter/skateboard/proc/pick_up_board(mob/living/carbon/skater)
	if (skater.incapacitated || !Adjacent(skater))
		return
	if(has_buckled_mobs())
		to_chat(skater, span_warning("You can't lift this up when somebody's on it."))
		return
	skater.put_in_hands(new board_item_type(get_turf(skater)))
	qdel(src)
/obj/vehicle/ridden/scooter/skateboard/pro
	name = "skateboard"
	desc = "A RaDSTORMz brand professional skateboard. Looks a lot more stable than the average board."
	icon_state = "skateboard2"
	board_icon = "skateboard2"
	board_item_type = /obj/item/melee/skateboard/pro
	instability = 6

/obj/vehicle/ridden/scooter/skateboard/hoverboard
	name = "hoverboard"
	desc = "A blast from the past, so retro!"
	board_item_type = /obj/item/melee/skateboard/hoverboard
	instability = 3
	icon_state = "hoverboard_red"
	board_icon = "hoverboard_red"

/obj/vehicle/ridden/scooter/skateboard/hoverboard/screwdriver_act(mob/living/user, obj/item/I)
	return FALSE

/obj/vehicle/ridden/scooter/skateboard/hoverboard/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/rods))
		return
	else
		return ..()

/obj/vehicle/ridden/scooter/skateboard/hoverboard/admin
	name = "\improper Board Of Directors"
	desc = "The engineering complexity of a spaceship concentrated inside of a board. Just as expensive, too."
	board_item_type = /obj/item/melee/skateboard/hoverboard/admin
	instability = 0
	icon_state = "hoverboard_nt"
	board_icon = "hoverboard_nt"

//CONSTRUCTION
/obj/item/scooter_frame
	name = "scooter frame"
	desc = "A metal frame for building a scooter. Looks like you'll need to add some iron to make wheels."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "scooter_frame"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/scooter_frame/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/sheet/iron))
		if(!I.tool_start_check(user, amount=5))
			return
		to_chat(user, span_notice("You begin to add wheels to [src]."))
		if(I.use_tool(src, user, 80, volume=50, amount=5))
			to_chat(user, span_notice("You finish making wheels for [src]."))
			new /obj/vehicle/ridden/scooter/skateboard(user.loc)
			qdel(src)
	else
		return ..()

/obj/item/scooter_frame/wrench_act(mob/living/user, obj/item/I)
	to_chat(user, span_notice("You deconstruct [src]."))
	new /obj/item/stack/rods(drop_location(), 10)
	I.play_tool_sound(src)
	qdel(src)
	return TRUE

/obj/vehicle/ridden/scooter/skateboard/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/rods))
		if(!I.tool_start_check(user, amount=2))
			return
		to_chat(user, span_notice("You begin making handlebars for [src]."))
		if(I.use_tool(src, user, 25, volume=50, amount=2))
			to_chat(user, span_notice("You add the rods to [src], creating handlebars."))
			var/obj/vehicle/ridden/scooter/S = new(loc)
			if(has_buckled_mobs())
				var/mob/living/carbon/H = buckled_mobs[1]
				unbuckle_mob(H)
				S.buckle_mob(H)
			qdel(src)
	else
		return ..()

/obj/vehicle/ridden/scooter/skateboard/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	to_chat(user, span_notice("You begin to deconstruct and remove the wheels on [src]..."))
	if(I.use_tool(src, user, 20, volume=50))
		to_chat(user, span_notice("You deconstruct the wheels on [src]."))
		new /obj/item/stack/sheet/iron(drop_location(), 5)
		new /obj/item/scooter_frame(drop_location())
		if(has_buckled_mobs())
			var/mob/living/carbon/H = buckled_mobs[1]
			unbuckle_mob(H)
		qdel(src)
	return TRUE

/obj/vehicle/ridden/scooter/skateboard/wrench_act(mob/living/user, obj/item/I)
	return

//Wheelys
/obj/vehicle/ridden/scooter/skateboard/wheelys
	name = "Wheely-Heels"
	desc = "Uses patented retractable wheel technology. Never sacrifice speed for style - not that this provides much of either."
	icon_state = null
	density = FALSE
	instability = 12
	///Stores the shoes associated with the vehicle
	var/obj/item/clothing/shoes/wheelys/shoes = null
	///Name of the wheels, for visible messages
	var/wheel_name = "wheels"
	///Component typepath to attach in [/obj/vehicle/ridden/scooter/skateboard/wheelys/proc/make_ridable()]
	var/component_type = /datum/component/riding/vehicle/scooter/skateboard/wheelys

/obj/vehicle/ridden/scooter/skateboard/wheelys/add_riding_element()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/scooter/skateboard/wheelys)

/obj/vehicle/ridden/scooter/skateboard/wheelys/post_unbuckle_mob(mob/living/M)
	if(!has_buckled_mobs())
		to_chat(M, "<span class='notice'>You pop the [wheel_name] back into place.</span>")
		moveToNullspace()
	return ..()

/obj/vehicle/ridden/scooter/skateboard/wheelys/pick_up_board(mob/living/carbon/Skater)
	return

/obj/vehicle/ridden/scooter/skateboard/wheelys/post_buckle_mob(mob/living/M)
	to_chat(M, "<span class='notice'>You pop out the [wheel_name].</span>")
	return ..()

///Sets the shoes that the vehicle is associated with, called when the shoes are initialized
/obj/vehicle/ridden/scooter/skateboard/wheelys/proc/link_shoes(newshoes)
	shoes = newshoes
