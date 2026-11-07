#define BOUNCE_BOOST_TIME (2 SECONDS) // How Long A Speed Boost Applies After A Bounce
#define BOUNCE_WINDOW_TIME (1 SECONDS)
#define BOUNCE_TARGET_SCALE 0.5
#define BOUNCE_MAX_STREAK 3 // Cap for scaling features, wheelie tilt, speedboost, when random bounces start...
#define BOUNCE_WHEELIE_ANGLE 15 // Board Tilt For Wheelie
#define BOUNCE_YELLOW "#ffe066"
#define BOUNCE_GREEN "#4cff6a"
#define BOUNCE_ORANGE "#ff9500"
#define BOUNCE_RED "#ff3b30"
#define BOUNCE_FLOOR_TOP (0.5 SECONDS) // 0 Streak Minimum-Time
#define BOUNCE_FLOOR_MID (0.4 SECONDS) // 25+ Streak Minimum-Time
#define BOUNCE_FLOOR_BOT (0.3 SECONDS) // 40+ Streak Minimum-Time
#define PROSKATER_MULTIPLIER 0.3 // Stamina drain for Skate Trait Users - 70% reduction
#define REGSKATER_MULTIPLIER 1 // Stamina drain for regular skaters

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

/obj/vehicle/ridden/scooter/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
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
	///Handles the bounce mechanic
	var/datum/skate_bounce/bounce

/obj/vehicle/ridden/scooter/skateboard/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_IMMOBILIZE, INNATE_TRAIT)
	sparks = new
	sparks.set_up(1, 0, src)
	sparks.attach(src)

/obj/vehicle/ridden/scooter/skateboard/add_riding_element()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/scooter/skateboard)

/obj/vehicle/ridden/scooter/skateboard/Destroy()
	QDEL_NULL(bounce)
	if(sparks)
		QDEL_NULL(sparks)
	. = ..()

/obj/vehicle/ridden/scooter/skateboard/relaymove(mob/living/user, direction)
	if(bounce?.handle_press(direction)) // Let Bounce Handle Input When Triggered
		return FALSE
	if (grinding || world.time < next_crash)
		return FALSE
	return ..()

/obj/vehicle/ridden/scooter/skateboard/generate_actions()
	. = ..()
	initialize_controller_action_type(/datum/action/vehicle/ridden/scooter/skateboard/ollie, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/ridden/scooter/skateboard/kflip, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/ridden/scooter/skateboard/brace, VEHICLE_CONTROL_DRIVE)

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
	if(bounce?.on_bump(A))
		return
	crash(buckled_mobs[1], A)

/obj/vehicle/ridden/scooter/skateboard/proc/crash(mob/living/rider, atom/A, force = FALSE)
	var/multiplier = REGSKATER_MULTIPLIER
	if(HAS_TRAIT(rider, TRAIT_PROSKATER))
		multiplier = PROSKATER_MULTIPLIER
	rider.adjustStaminaLoss(multiplier * instability * 6)
	playsound(src, 'sound/effects/bang.ogg', 40, TRUE)
	if(force || !iscarbon(rider) || rider.getStaminaLoss() >= 100 || grinding || world.time < next_crash)
		var/atom/throw_target = get_edge_target_turf(rider, pick(GLOB.cardinals))
		unbuckle_mob(rider)
		rider.throw_at(throw_target, 3, 2)
		var/head_slot = rider.get_item_by_slot(ITEM_SLOT_HEAD)
		if(!head_slot || !(istype(head_slot,/obj/item/clothing/head/helmet) || istype(head_slot,/obj/item/clothing/head/utility/hardhat)))
			if(prob(multiplier * 100)) //pro skaters get a 70% chance to not get the brain damage
				rider.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5)
				rider.updatehealth()
		visible_message(span_danger("[src] crashes into [A ? A : "the wall"], sending [rider] flying!"))
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
	var/multiplier = REGSKATER_MULTIPLIER
	if(HAS_TRAIT(L, TRAIT_PROSKATER))
		multiplier = PROSKATER_MULTIPLIER
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

/datum/skate_bounce
	var/obj/vehicle/ridden/scooter/skateboard/board
	var/mob/living/carbon/rider
	var/pending = FALSE
	var/bounce_dir // Saved Direction Player Came From
	var/datum/weakref/obstacle //Reference To Whats Obj or Person Is Target of Bounce
	var/list/cue_images // List Of Icons For HUD Animation
	var/list/board_base // Saved pixel offset and location for the board
	var/list/rider_base // Saved pixel info for the rider
	var/window_start = 0
	var/immune_until = 0
	var/streak = 0 //Tracks How Many Bounces Have Been Landed In A Row!
	var/window_time = BOUNCE_WINDOW_TIME //Acceptable Hit Window For A Bounce
	var/perfect_time = 8 //Timing For A Perfect Bounce
	var/leeway = 2 // Buffer Time For How Long The Hit Window Is Valid
	var/base_multiplier
	var/expire_timer
	var/window_timer
	var/double = FALSE // Some Bounces Need Double Input
	var/double_gap = 0
	var/first_press_done = FALSE
	var/press_ignore_until = 0
	var/image/first_ring
	var/trail_timer
	var/turf/last_trail_turf

/datum/skate_bounce/New(obj/vehicle/ridden/scooter/skateboard/board, mob/living/carbon/rider)
	src.board = board
	src.rider = rider
	board.bounce = src
	RegisterSignal(board, COMSIG_MOVABLE_UNBUCKLE, PROC_REF(on_board_changed))
	expire_timer = addtimer(CALLBACK(src, PROC_REF(expire)), 3 SECONDS, TIMER_STOPPABLE) // Timer For How Long Bounce Is Active After Triggering
	tilt_board(BOUNCE_WHEELIE_ANGLE, 3) //Tilt the board into a wheelie for ready visual cue

/datum/skate_bounce/proc/tilt_board(angle, time)
	var/tilt = 0
	if(board.dir & EAST)
		tilt = -angle
	else if(board.dir & WEST)
		tilt = angle
	var/matrix/tilt_matrix = matrix()
	tilt_matrix.Turn(tilt)
	animate(board, transform = tilt_matrix, time = time, flags = ANIMATION_PARALLEL)

/datum/skate_bounce/Destroy()
	deltimer(expire_timer)
	deltimer(window_timer)
	deltimer(trail_timer)
	release_shift(1)
	if(board)
		UnregisterSignal(board, COMSIG_MOVABLE_UNBUCKLE)
		set_boost(1)
		tilt_board(0, 3)
		board.bounce = null
	clear_cues()
	board = null
	rider = null
	return ..()

/datum/skate_bounce/proc/on_board_changed(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/datum/skate_bounce/proc/expire()
	if(pending)
		return
	qdel(src)

/datum/skate_bounce/proc/set_boost(multiplier)
	var/datum/component/riding/riding = board.GetComponent(/datum/component/riding)
	if(!riding)
		return
	if(isnull(base_multiplier))
		base_multiplier = riding.vehicle_move_multiplier
	riding.vehicle_move_multiplier = base_multiplier * multiplier

/datum/skate_bounce/proc/obstacle_valid() //Targets, and People hit must be standing, unmoving, unbuckled/not sitting and exist within range for the duration of the bounce
	var/atom/hit = obstacle?.resolve()
	if(QDELETED(hit))
		return FALSE
	if(!isliving(hit))
		return TRUE
	var/mob/living/target = hit
	return target.body_position == STANDING_UP && get_dist(board, target) <= 1 && !target.buckled

/datum/skate_bounce/proc/end_window(flash_color)
	deltimer(window_timer)
	pending = FALSE
	clear_cues(flash_color)
	release_shift()
	immune_until = world.time + 5

/datum/skate_bounce/proc/cancel_window() //Invalid Targets Should Cause A Gentle Cancel
	end_window()
	tilt_board(BOUNCE_WHEELIE_ANGLE + 5 * min(streak, BOUNCE_MAX_STREAK), 2)
	deltimer(expire_timer)
	expire_timer = addtimer(CALLBACK(src, PROC_REF(expire)), BOUNCE_BOOST_TIME, TIMER_STOPPABLE)
	to_chat(rider, span_notice("There's nothing left to bounce off."))

/datum/skate_bounce/proc/handle_press(direction)
	if(!pending)
		return FALSE
	if(!obstacle_valid())
		cancel_window()
		return FALSE
	if(direction == REVERSE_DIR(bounce_dir))
		if(world.time < press_ignore_until)
			return TRUE
		var/elapsed = world.time - window_start
		if(double && !first_press_done)
			if(elapsed < perfect_time - leeway)
				resolve(FALSE)
				return TRUE
			first_press_done = TRUE
			press_ignore_until = world.time + 2 // Gives Window To Let Go Of Held Key Without Triggering Bounce Input
			animate(first_ring, color = bounce_tint(BOUNCE_GREEN), alpha = 0, time = 3, flags = ANIMATION_PARALLEL)
			board.balloon_alert(rider, "One More!", show_in_chat = FALSE)
			return TRUE
		resolve(elapsed >= perfect_time - leeway + double_gap)
	else if(direction != bounce_dir)
		deltimer(window_timer)
		fail()
	return TRUE

/datum/skate_bounce/proc/on_bump(atom/obstacle_hit)
	if(board.grinding)
		return FALSE
	if(pending || world.time < immune_until)
		return TRUE
	var/hit_dir = get_dir(board, obstacle_hit)
	if(!(hit_dir in GLOB.cardinals))
		hit_dir = board.dir
	obstacle = WEAKREF(obstacle_hit)
	var/hardest = BOUNCE_FLOOR_TOP
	if(streak >= 40)
		hardest = BOUNCE_FLOOR_BOT
	else if(streak >= 25)
		hardest = BOUNCE_FLOOR_MID
	if(isliving(obstacle_hit) || issilicon(obstacle_hit))
		window_time = hardest // Hitting a person ALWAYS uses the floor
	else if(streak < BOUNCE_MAX_STREAK)
		window_time = BOUNCE_WINDOW_TIME - 2 * streak
	else
		window_time = rand(hardest, BOUNCE_WINDOW_TIME)
	perfect_time = round(window_time * 0.8)
	leeway = max(1, round(window_time * 0.2))
	double = streak > 9 && prob(min(10 + 2 * streak, 40)) // Double Rings Start Appearing After The 9th Bounce
	double_gap = double ? rand(4, 8) : 0 //Second Ring Appears 4-8 Ticks After First
	first_press_done = FALSE
	press_ignore_until = 0
	pending = TRUE
	bounce_dir = hit_dir
	playsound(board, 'sound/effects/bang.ogg', 25, TRUE) //Play a sound on bounce
	tilt_board(0, 1) //Reset Board While Preparing to launch off
	board_base = list(board.pixel_x, board.pixel_y)
	rider_base = list(rider.pixel_x, rider.pixel_y)
	var/push_x = ((hit_dir & EAST) ? 1 : 0) - ((hit_dir & WEST) ? 1 : 0)
	var/push_y = ((hit_dir & NORTH) ? 1 : 0) - ((hit_dir & SOUTH) ? 1 : 0)
	shift_toward(push_x * 4, push_y * 4, 1) // Offsets Rider+Board Towards Whats Being Bounced Off Of
	window_start = world.time
	show_cues(REVERSE_DIR(hit_dir))
	to_chat(rider, span_notice("You hit [obstacle_hit]! Hit the arrow's direction as the rings overlap!"))
	window_timer = addtimer(CALLBACK(src, PROC_REF(fail)), window_time + double_gap, TIMER_STOPPABLE)
	return TRUE

/datum/skate_bounce/proc/shift_toward(dx, dy, time, easing = SINE_EASING)
	if(!board_base)
		return
	animate(board, pixel_x = board_base[1] + dx, pixel_y = board_base[2] + dy, time = time, easing = easing, flags = ANIMATION_PARALLEL)
	if(rider && rider_base)
		animate(rider, pixel_x = rider_base[1] + dx, pixel_y = rider_base[2] + dy, time = time, easing = easing, flags = ANIMATION_PARALLEL)

/datum/skate_bounce/proc/release_shift(time = 2) //Push Off/Reset Offset
	shift_toward(0, 0, time, BACK_EASING)
	board_base = null
	rider_base = null

/datum/skate_bounce/proc/show_cues(press_dir) //Creates UI for Bouncing Player
	clear_cues()
	var/image/target_ring = bounce_cue_image("bounce_ring", 1)
	target_ring.transform = matrix().Scale(BOUNCE_TARGET_SCALE)
	target_ring.alpha = 200

	var/image/closing_ring = closing_ring_image(BOUNCE_YELLOW, perfect_time)
	animate(closing_ring, color = bounce_tint(BOUNCE_YELLOW), time = perfect_time - leeway, flags = ANIMATION_PARALLEL)
	animate(color = bounce_tint(BOUNCE_GREEN), time = 1) //Changes To Green When Time Matches From Yellow
	first_ring = closing_ring

	//Doubles get a second, blue ring that lines up later
	var/image/second_ring = double ? closing_ring_image("#56b9ff", perfect_time + double_gap) : null

	var/image/arrow = bounce_cue_image("bounce_arrow", 3)
	var/matrix/arrow_matrix = matrix()
	arrow_matrix.Scale(0.7)
	arrow_matrix.Turn(dir2angle(press_dir))
	arrow.transform = arrow_matrix

	cue_images = list(target_ring, closing_ring, arrow)
	if(second_ring)
		cue_images += second_ring
	rider.client?.images += cue_images

/datum/skate_bounce/proc/closing_ring_image(ring_color, close_time)
	var/image/ring = bounce_cue_image("bounce_ring", 2)
	ring.color = bounce_tint(ring_color)
	animate(ring, transform = matrix().Scale(BOUNCE_TARGET_SCALE), time = close_time, easing = LINEAR_EASING)
	animate(transform = matrix().Scale(BOUNCE_TARGET_SCALE * 0.8), time = window_time - perfect_time, easing = LINEAR_EASING)
	return ring

/datum/skate_bounce/proc/bounce_cue_image(state, image_layer) // Rider Only Hud Next To Head
	var/image/cue = image(icon = 'icons/ui_icons/screentips/skateboard_bounce.dmi', loc = rider, icon_state = state)
	cue.plane = ABOVE_LIGHTING_PLANE
	cue.layer = image_layer
	cue.pixel_x = 22
	cue.pixel_y = -6
	return cue

//Tints The Wheel Icon For Bounce Cues
/datum/skate_bounce/proc/bounce_tint(hex)
	var/list/rgb = rgb2num(hex)
	return list(rgb[1] / 255, 0, 0, 0, rgb[2] / 255, 0, 0, 0, rgb[3] / 255)

/datum/skate_bounce/proc/clear_cues(flash_color)
	if(!cue_images)
		return
	var/list/old_cues = cue_images
	cue_images = null
	first_ring = null
	var/client/viewer = rider?.client
	if(!flash_color || !viewer)
		viewer?.images -= old_cues
		QDEL_LIST(old_cues)
		return
	for(var/image/cue as anything in old_cues)
		animate(cue, color = bounce_tint(flash_color), alpha = 0, time = 4, flags = ANIMATION_PARALLEL)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(remove_bounce_cues), viewer, old_cues), 4)

/proc/remove_bounce_cues(client/viewer, list/cues)
	viewer?.images -= cues
	QDEL_LIST(cues)

/datum/skate_bounce/proc/resolve(perfect)
	end_window(perfect ? BOUNCE_GREEN : BOUNCE_ORANGE)
	var/launch_dir = REVERSE_DIR(bounce_dir)
	board.setDir(launch_dir)
	step(board, launch_dir)
	rider.spin(4, 1)
	if(!perfect)
		var/multiplier = HAS_TRAIT(rider, TRAIT_PROSKATER) ? PROSKATER_MULTIPLIER : REGSKATER_MULTIPLIER
		rider.adjustStaminaLoss(multiplier * board.instability * 2)
		board.balloon_alert(rider, "too early!") //Too early means no crash, but the bounce costs stamina and ends the chain
		board.visible_message(span_notice("[rider] bounces off the wall, a little early."))
		qdel(src)
		return
	streak++
	var/capped_streak = min(streak, BOUNCE_MAX_STREAK)
	tilt_board(BOUNCE_WHEELIE_ANGLE + 5 * capped_streak, 2)
	board.balloon_alert(rider, streak > 1 ? "perfect! [streak_text()]" : "perfect!", show_in_chat = FALSE)
	if(streak % 3 == 0) // Every # of streaks, restore stamina loss
		rider.setStaminaLoss(0)
		to_chat(rider, span_notice("You catch your breath, your stamina is restored!"))
	var/mob/living/victim = obstacle?.resolve()
	if(istype(victim)) // Handles Victims End Of Being Hit By Bounce
		victim.throw_at(get_edge_target_turf(victim, bounce_dir), 3, 2) //Victim Knockback
		victim.Knockdown(2 SECONDS) // Victim Stun time
	set_boost(1 / (1 + 0.25 * capped_streak))
	if(!trail_timer)
		trail_tick()
	deltimer(expire_timer)
	expire_timer = addtimer(CALLBACK(src, PROC_REF(expire)), BOUNCE_BOOST_TIME, TIMER_STOPPABLE)
	playsound(board, 'sound/vehicles/skateboard_ollie.ogg', 60, TRUE)
	board.visible_message(span_notice("[rider] kicks off [victim ? victim : "the wall"]![streak > 1 ? " ([streak_text()])" : ""]"))

//Streaks have a afterimage trail effect using the streak color
/datum/skate_bounce/proc/trail_tick()
	trail_timer = null
	if(!board)
		return
	var/turf/here = get_turf(board)
	if(!pending && here != last_trail_turf)
		var/obj/effect/temp_visual/decoy/fading/halfsecond/trail = new(here, board)
		trail.color = streak_color()
		last_trail_turf = here
	trail_timer = addtimer(CALLBACK(src, PROC_REF(trail_tick)), 2, TIMER_STOPPABLE)

/datum/skate_bounce/proc/streak_color() //Streak Color Formatting
	if(streak > 18) // 18+ For A Red Streak Number
		return BOUNCE_RED
	if(streak > 9) // 9+ Sets The # To Orange
		return BOUNCE_ORANGE
	if(streak > 3) // 3+, A Full Combo Changes The # To Yellow
		return BOUNCE_YELLOW
	return "#ffffff"

/datum/skate_bounce/proc/streak_text(with_x = TRUE) //Streak Text Formatting
	var/color = streak_color()
	var/size = 100
	if(streak > 36)
		size = 140 // 40% Bigger Streak # Above 36
	else if(streak > 18)
		size = 120 // 20% Bigger Streak # Above 18
	var/excitement = ""
	if(streak > 50) // Streaks Hitting 50 Add 3 Exclamation Marks
		excitement = "!!!"
	else if(streak > 36) // 36+ Adds 2 Exclamation Marks
		excitement = "!!"
	else if(streak > 21) // 21+ Adds 1 Exclamation Mark
		excitement = "!"
	return "<span style='color:[color];font-size:[size]%;font-weight:bold'>[with_x ? "x" : ""][streak][excitement]</span>"

//Failing A Bounce Notifys The Rider Of Their Streak Total And Crashes Them
/datum/skate_bounce/proc/fail()
	if(!obstacle_valid())
		cancel_window()
		return
	var/obj/vehicle/ridden/scooter/skateboard/crashed_board = board
	var/mob/living/carbon/victim = rider
	var/atom/hit = obstacle?.resolve()
	if(victim && streak)
		to_chat(victim, span_notice("Your chain ended after [streak_text(FALSE)] bounce[streak == 1 ? "" : "s"]!"))
	clear_cues(BOUNCE_RED)
	qdel(src)
	if(!victim || !crashed_board.has_buckled_mobs())
		return
	crashed_board.crash(victim, hit, force = TRUE)

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

/obj/vehicle/ridden/scooter/skateboard/hoverboard/attackby(obj/item/I, mob/user, list/modifiers)
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

/obj/item/scooter_frame/attackby(obj/item/I, mob/user, list/modifiers)
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

/obj/vehicle/ridden/scooter/skateboard/attackby(obj/item/I, mob/user, list/modifiers)
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

#undef BOUNCE_BOOST_TIME
#undef BOUNCE_WINDOW_TIME
#undef BOUNCE_TARGET_SCALE
#undef BOUNCE_MAX_STREAK
#undef BOUNCE_WHEELIE_ANGLE
#undef BOUNCE_YELLOW
#undef BOUNCE_GREEN
#undef BOUNCE_ORANGE
#undef BOUNCE_RED
#undef BOUNCE_FLOOR_TOP
#undef BOUNCE_FLOOR_MID
#undef BOUNCE_FLOOR_BOT
#undef PROSKATER_MULTIPLIER
#undef REGSKATER_MULTIPLIER
