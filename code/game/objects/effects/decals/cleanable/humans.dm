/obj/effect/decal/cleanable/blood
	name = "blood"
	desc = "It's weird and gooey. Perhaps it's the chef's cooking?"
	icon = 'icons/effects/blood.dmi'
	icon_state = "floor1"
	color = BLOOD_COLOR_RED
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7")
	blood_state = BLOOD_STATE_HUMAN
	bloodiness = BLOOD_AMOUNT_PER_DECAL
	//beauty = -100
	clean_type = CLEAN_TYPE_BLOOD
	var/should_dry = TRUE
	var/dryname = "dried blood" //when the blood lasts long enough, it becomes dry and gets a new name
	var/drydesc = "Looks like it's been here a while. Eew." //as above
	var/drytime = 0
	/// If FALSE, blood dripped or smeared onto tile makes its own pool instead of adding
	var/pools_blood = TRUE

/obj/effect/decal/cleanable/blood/Initialize(mapload)
	. = ..()
	if(!should_dry)
		return
	if(bloodiness)
		start_drying()
	else
		dry()

/obj/effect/decal/cleanable/blood/process()
	if(world.time > drytime)
		dry()

/obj/effect/decal/cleanable/blood/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/decal/cleanable/blood/add_blood_DNA(list/blood_dna, list/datum/disease/diseases)
	. = ..()
	if(blood_dna)
		color = get_blood_dna_color(blood_dna)

/obj/effect/decal/cleanable/blood/proc/get_timer()
	drytime = world.time + 3 MINUTES

/obj/effect/decal/cleanable/blood/proc/start_drying()
	get_timer()
	START_PROCESSING(SSobj, src)

/obj/effect/decal/cleanable/blood/proc/dry()
	if(bloodiness > 20)
		bloodiness -= BLOOD_AMOUNT_PER_DECAL
		get_timer()
	else
		name = dryname
		desc = drydesc
		bloodiness = 0
		var/list/temp_color = rgb2hsv(color || COLOR_WHITE)
		temp_color[3] = max(temp_color[3] - 100, min(temp_color[3], 10))
		color = hsv2rgb(temp_color)
		if(blood_state == "LE")
			set_light(0)   // remove glow when dry
		STOP_PROCESSING(SSobj, src)

/obj/effect/decal/cleanable/blood/replace_decal(obj/effect/decal/cleanable/blood/C)
	C.add_blood_DNA(GET_ATOM_BLOOD_DNA(src))
	if (bloodiness)
		C.bloodiness = min((C.bloodiness + bloodiness), BLOOD_AMOUNT_PER_DECAL)
	return ..()

/obj/effect/decal/cleanable/blood/old
	name = "dried blood"
	desc = "Looks like it's been here a while.  Eew."
	bloodiness = 0
	icon_state = "floor1-old"
	var/list/datum/disease/diseases = list()

CREATION_TEST_IGNORE_SUBTYPES(/obj/effect/decal/cleanable/blood/old)

/obj/effect/decal/cleanable/blood/old/Initialize(mapload, list/datum/disease/diseases)
	add_blood_DNA(list("Non-human DNA" = random_blood_type())) // Needs to happen before ..()
	. = ..()
	if(length(diseases))
		src.diseases += diseases
	if(prob(75))
		var/datum/disease/advance/new_disease = new /datum/disease/advance/random(rand(1, 4), rand(7, 9), 4)
		src.diseases += new_disease

/obj/effect/decal/cleanable/blood/splatter
	icon_state = "gibbl1"
	random_icon_states = list("gibbl1", "gibbl2", "gibbl3", "gibbl4", "gibbl5")

/// Blood blown out behind someone who was shot
/obj/effect/decal/cleanable/blood/splatter/directional
	icon_state = "dir_splatter_1"
	random_icon_states = list("dir_splatter_1", "dir_splatter_2")
	pools_blood = FALSE

/// streak left on each tile blood flies over
/obj/effect/decal/cleanable/blood/squirt
	icon_state = "squirt"
	random_icon_states = null
	bloodiness = BLOOD_AMOUNT_PER_DECAL * 0.34
	pools_blood = FALSE

/// Splatter left on a wall from the adjacent floor
/obj/effect/decal/cleanable/blood/splatter/over_window
	layer = ABOVE_WINDOW_LAYER
	plane = GAME_PLANE
	vis_flags = VIS_INHERIT_PLANE | VIS_INHERIT_ID
	alpha = 180
	turf_loc_check = FALSE
	// One tile can border several walls
	mergeable_decal = FALSE
	pools_blood = FALSE

// out of reach of anything on the floor
/obj/effect/decal/cleanable/blood/splatter/over_window/on_entered(datum/source, atom/movable/AM)
	return

/obj/effect/decal/cleanable/blood/splatter/over_window/can_bloodcrawl_in()
	return FALSE

/// Blood flying through the air, painting what it passes and landing on the floor, a wall or a window
/obj/effect/decal/cleanable/blood/hitsplatter
	name = "blood splatter"
	pass_flags = PASSTABLE | PASSGRILLE
	icon_state = "hitsplatter1"
	random_icon_states = list("hitsplatter1", "hitsplatter2", "hitsplatter3")
	plane = GAME_PLANE
	layer = ABOVE_WINDOW_LAYER
	mergeable_decal = FALSE
	should_dry = FALSE
	pools_blood = FALSE
	/// turf we were on before the last step
	var/turf/prev_loc
	/// how many tiles to fly
	var/splatter_strength = 3
	var/splatter_speed = 0.1 SECONDS

/obj/effect/decal/cleanable/blood/hitsplatter/Initialize(mapload, list/datum/disease/diseases, splatter_strength)
	. = ..()
	if(. == INITIALIZE_HINT_QDEL)
		return
	if(splatter_strength)
		src.splatter_strength = splatter_strength

/obj/effect/decal/cleanable/blood/hitsplatter/proc/expire()
	if(isturf(loc))
		playsound(src, 'sound/effects/wounds/splatter.ogg', 60, TRUE, -1)
		loc.add_blood_DNA(GET_ATOM_BLOOD_DNA(src))
	qdel(src)

/obj/effect/decal/cleanable/blood/hitsplatter/proc/fly_towards(turf/target_turf, range)
	var/datum/move_loop/loop = SSmove_manager.move_towards(src, target_turf, splatter_speed, timeout = splatter_speed * range, priority = MOVEMENT_ABOVE_SPACE_PRIORITY, flags = MOVEMENT_LOOP_START_FAST)
	RegisterSignal(loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, PROC_REF(pre_move))
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(post_move))
	RegisterSignal(loop, COMSIG_QDELETING, PROC_REF(loop_done))

/obj/effect/decal/cleanable/blood/hitsplatter/proc/pre_move(datum/move_loop/source)
	SIGNAL_HANDLER
	prev_loc = loc

/obj/effect/decal/cleanable/blood/hitsplatter/proc/post_move(datum/move_loop/source)
	SIGNAL_HANDLER
	if(loc == prev_loc || !isturf(loc))
		return

	var/caught = FALSE
	for(var/atom/movable/iter_atom in loc)
		if(iter_atom == src || iter_atom.invisibility || iter_atom.alpha <= 0)
			continue
		if(isliving(iter_atom))
			var/mob/living/splashed = iter_atom
			splashed.add_blood_DNA(GET_ATOM_BLOOD_DNA(src))
			SEND_SIGNAL(splashed, COMSIG_ADD_MOOD_EVENT, "splattered_with_blood", /datum/mood_event/splattered_with_blood)
			if(splashed.body_position == STANDING_UP)
				caught = TRUE
				if(ishuman(splashed))
					splash_face(splashed)
		else if(isitem(iter_atom) || (isobj(iter_atom) && iter_atom.density))
			iter_atom.add_blood_DNA(GET_ATOM_BLOOD_DNA(src))

	splatter_strength--
	if(caught || splatter_strength <= 0)
		expire()
		return

	var/obj/effect/decal/cleanable/blood/squirt/fly_trail = new(loc)
	if(QDELETED(fly_trail))
		return
	fly_trail.add_blood_DNA(GET_ATOM_BLOOD_DNA(src))
	fly_trail.setDir(get_dir(prev_loc, loc))

/obj/effect/decal/cleanable/blood/hitsplatter/proc/splash_face(mob/living/carbon/human/splashed)
	if(splashed.is_eyes_covered())
		to_chat(splashed, span_danger("You're hit by a spray of blood!"))
		return
	to_chat(splashed, span_userdanger("You're blinded by a spray of blood!"))
	splashed.set_eye_blur_if_lower(6 SECONDS)
	if(prob(10))
		splashed.set_temp_blindness_if_lower(5 SECONDS)

/obj/effect/decal/cleanable/blood/hitsplatter/proc/loop_done(datum/source)
	SIGNAL_HANDLER
	if(!QDELETED(src))
		expire()

/obj/effect/decal/cleanable/blood/hitsplatter/Bump(atom/bumped_atom)
	var/obj/effect/decal/cleanable/blood/splatter/over_window/final_splatter
	if(iswallturf(bumped_atom))
		var/offset_x = (bumped_atom.x - x) * ICON_SIZE_X
		var/offset_y = (bumped_atom.y - y) * ICON_SIZE_Y
		for(var/obj/effect/decal/cleanable/blood/splatter/over_window/existing in loc)
			if(existing.pixel_x == offset_x && existing.pixel_y == offset_y)
				final_splatter = existing
				break
		if(!final_splatter)
			final_splatter = new(loc)
			if(!QDELETED(final_splatter))
				final_splatter.pixel_x = offset_x
				final_splatter.pixel_y = offset_y
	else if(istype(bumped_atom, /obj/structure/window))
		var/obj/structure/window/bumped_window = bumped_atom
		if(bumped_window.fulltile)
			// so it can't merge with floor splatter
			final_splatter = new(bumped_window)
			bumped_window.vis_contents += final_splatter
	if(QDELETED(final_splatter))
		expire()
		return
	final_splatter.add_blood_DNA(GET_ATOM_BLOOD_DNA(src))
	qdel(src)

/obj/effect/decal/cleanable/blood/tracks
	name = "tracks"
	desc = "They look like tracks left by wheels."
	icon_state = "tracks"
	random_icon_states = null
	//beauty = -50
	dryname = "dried tracks"
	drydesc = "Some old bloody tracks left by wheels. Machines are evil, perhaps."

/obj/effect/decal/cleanable/blood/trail_holder //not a child of blood on purpose //nice fucking descriptive comment jackass, fuck you //hello fikou //terrible
	name = "blood"
	icon = 'icons/effects/blood.dmi'
	desc = "Your instincts say you shouldn't be following these."
	//beauty = -50
	icon_state = null
	random_icon_states = null
	var/list/existing_dirs = list()

/obj/effect/decal/cleanable/blood/trail_holder/glowy
	light_power = 0.5
	light_range = 0.25
	light_color = BLOOD_COLOR_ETHEREAL

/obj/effect/decal/cleanable/blood/gibs
	name = "gibs"
	desc = "They look bloody and gruesome."
	icon = 'icons/effects/blood.dmi'
	icon_state = "gib1"
	layer = LOW_OBJ_LAYER
	plane = GAME_PLANE
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6")
	mergeable_decal = FALSE
	turf_loc_check = FALSE

	dryname = "rotting gibs"
	drydesc = "They look bloody and gruesome while some terrible smell fills the air."
	decal_reagent = /datum/reagent/liquidgibs
	reagent_amount = 5
	///Information about the diseases our streaking spawns
	var/list/streak_diseases

CREATION_TEST_IGNORE_SUBTYPES(/obj/effect/decal/cleanable/blood/gibs)

/obj/effect/decal/cleanable/blood/gibs/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	var/mutable_appearance/gib_overlay = mutable_appearance(icon, "[icon_state]-overlay", appearance_flags = RESET_COLOR)
	add_overlay(gib_overlay)
	RegisterSignal(src, COMSIG_MOVABLE_PIPE_EJECTING, PROC_REF(on_pipe_eject))

/obj/effect/decal/cleanable/blood/gibs/Destroy()
	LAZYNULL(streak_diseases)
	return ..()

/obj/effect/decal/cleanable/blood/gibs/dry()
	. = ..()
	if(!.)
		return

/obj/effect/decal/cleanable/blood/gibs/replace_decal(obj/effect/decal/cleanable/C)
	return FALSE //Never fail to place us

/obj/effect/decal/cleanable/blood/gibs/ex_act(severity, target)
	return

/obj/effect/decal/cleanable/blood/gibs/on_entered(datum/source, atom/movable/L)
	if(isliving(L) && has_gravity(loc))
		playsound(loc, 'sound/effects/gib_step.ogg', HAS_TRAIT(L, TRAIT_LIGHT_STEP) ? 20 : 50, TRUE)
	. = ..()

/obj/effect/decal/cleanable/blood/gibs/proc/on_pipe_eject(atom/source, direction)
	SIGNAL_HANDLER

	var/list/dirs
	if(direction)
		dirs = list(direction, turn(direction, -45), turn(direction, 45))
	else
		dirs = GLOB.alldirs.Copy()

	streak(dirs)

/obj/effect/decal/cleanable/blood/gibs/proc/streak(list/directions, mapload = FALSE)
	LAZYINITLIST(streak_diseases)
	SEND_SIGNAL(src, COMSIG_GIBS_STREAK, directions, streak_diseases)
	var/direction = pick(directions)
	streak_diseases = list()
	var/delay = 2
	var/range = pick(0, 200; 1, 150; 2, 50; 3, 17; 50) //the 3% chance of 50 steps is intentional and played for laughs.
	if(!step_to(src, get_step(src, direction), 0))
		return
	if(mapload)
		for (var/i = 1, i < range, i++)
			var/obj/effect/decal/cleanable/blood/splatter/splat = new /obj/effect/decal/cleanable/blood/splatter(loc, streak_diseases)
			if(!QDELETED(splat) && GET_ATOM_BLOOD_DNA_LENGTH(src))
				splat.add_blood_DNA(GET_ATOM_BLOOD_DNA(src))
			if (!step_to(src, get_step(src, direction), 0))
				break
		return

	var/datum/move_loop/loop = SSmove_manager.move_to(src, get_step(src, direction), delay = delay, timeout = range * delay, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(spread_movement_effects))

/obj/effect/decal/cleanable/blood/gibs/proc/spread_movement_effects(datum/move_loop/has_target/source)
	SIGNAL_HANDLER
	new /obj/effect/decal/cleanable/blood/splatter(loc, streak_diseases)

/obj/effect/decal/cleanable/blood/gibs/up
	icon_state = "gibup1"
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6","gibup1","gibup1","gibup1")

/obj/effect/decal/cleanable/blood/gibs/down
	icon_state = "gibdown1"
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6","gibdown1","gibdown1","gibdown1")

/obj/effect/decal/cleanable/blood/gibs/body
	icon_state = "gibtorso"
	random_icon_states = list("gibhead", "gibtorso")

/obj/effect/decal/cleanable/blood/gibs/torso
	icon_state = "gibtorso"
	random_icon_states = null

/obj/effect/decal/cleanable/blood/gibs/limb
	icon_state = "gibleg"
	random_icon_states = list("gibleg", "gibarm")

/obj/effect/decal/cleanable/blood/gibs/core
	icon_state = "gibmid1"
	random_icon_states = list("gibmid1", "gibmid2", "gibmid3")

/obj/effect/decal/cleanable/blood/gibs/old
	name = "old rotting gibs"
	desc = "Space Jesus, why didn't anyone clean this up? They smell terrible."
	icon_state = "gib1-old"
	bloodiness = 0
	should_dry = FALSE
	dryname = "old rotting gibs"
	drydesc = "Space Jesus, why didn't anyone clean this up? They smell terrible."
	var/list/datum/disease/diseases = list()

CREATION_TEST_IGNORE_SUBTYPES(/obj/effect/decal/cleanable/blood/gibs/old)

/obj/effect/decal/cleanable/blood/gibs/old/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	setDir(pick(1, 2, 4, 8))
	add_blood_DNA(list("Non-human DNA" = random_blood_type()))
	if(length(diseases))
		src.diseases += diseases
	if(prob(80))
		var/datum/disease/advance/new_disease = new /datum/disease/advance/random(rand(3, 6), rand(8, 9), 4)
		src.diseases += new_disease
	dry()

/obj/effect/decal/cleanable/blood/drip
	name = "drips of blood"
	desc = "It's red."
	icon_state = "drip5" //using drip5 since the others tend to blend in with pipes & wires.
	random_icon_states = list("drip1","drip2","drip3","drip4","drip5")
	bloodiness = 0
	var/drips = 1
	dryname = "drips of blood"
	drydesc = "It's red."

/obj/effect/decal/cleanable/blood/drip/can_bloodcrawl_in()
	return TRUE


//BLOODY FOOTPRINTS
/obj/effect/decal/cleanable/blood/footprints
	name = "footprints"
	desc = "WHOSE FOOTPRINTS ARE THESE?"
	icon = 'icons/effects/footprints.dmi'
	icon_state = "blood1"
	random_icon_states = null
	blood_state = BLOOD_STATE_HUMAN //the icon state to load images from
	var/entered_dirs = 0
	var/exited_dirs = 0

	/// List of shoe or other clothing that covers feet types that have made footprints here.
	var/list/shoe_types = list()

	/// List of species that have made footprints here.
	var/list/species_types = list()

	dryname = "dried footprints"
	drydesc = "HMM... SOMEONE WAS HERE!"

/obj/effect/decal/cleanable/blood/footprints/Initialize(mapload)
	. = ..()
	icon_state = "" //All of the footprint visuals come from overlays
	if(mapload)
		entered_dirs |= dir //Keep the same appearance as in the map editor
		update_appearance()

//Rotate all of the footprint directions too
/obj/effect/decal/cleanable/blood/footprints/setDir(newdir)
	if(dir == newdir)
		return ..()

	var/ang_change = dir2angle(newdir) - dir2angle(dir)
	var/old_entered_dirs = entered_dirs
	var/old_exited_dirs = exited_dirs
	entered_dirs = 0
	exited_dirs = 0

	for(var/Ddir in GLOB.cardinals)
		if(old_entered_dirs & Ddir)
			entered_dirs |= turn_cardinal(Ddir, ang_change)
		if(old_exited_dirs & Ddir)
			exited_dirs |= turn_cardinal(Ddir, ang_change)

	update_appearance()
	return ..()

/obj/effect/decal/cleanable/blood/footprints/update_icon()
	. = ..()
	alpha = min(BLOODY_FOOTPRINT_BASE_ALPHA + (255 - BLOODY_FOOTPRINT_BASE_ALPHA) * bloodiness / (BLOOD_ITEM_MAX / 2), 255)

//Cache of bloody footprint images
//Key:
//"entered-[blood_state]-[dir_of_image]"
//or: "exited-[blood_state]-[dir_of_image]"
GLOBAL_LIST_EMPTY(bloody_footprints_cache)

/obj/effect/decal/cleanable/blood/footprints/update_overlays()
	. = ..()
	var/print_state = blood_state
	if(BODYPART_ID_DIGITIGRADE in species_types)
		print_state += "claw"
	else if(SPECIES_MONKEY in species_types)
		print_state += "paw"
	if(!icon_exists(icon, "[print_state]1"))
		print_state = blood_state

	for(var/Ddir in GLOB.cardinals)
		if(entered_dirs & Ddir)
			var/image/bloodstep_overlay = GLOB.bloody_footprints_cache["entered-[print_state]-[Ddir]"]
			if(!bloodstep_overlay)
				GLOB.bloody_footprints_cache["entered-[print_state]-[Ddir]"] = bloodstep_overlay = image(icon, "[print_state]1", dir = Ddir)
			. += bloodstep_overlay

		if(exited_dirs & Ddir)
			var/image/bloodstep_overlay = GLOB.bloody_footprints_cache["exited-[print_state]-[Ddir]"]
			if(!bloodstep_overlay)
				GLOB.bloody_footprints_cache["exited-[print_state]-[Ddir]"] = bloodstep_overlay = image(icon, "[print_state]2", dir = Ddir)
			. += bloodstep_overlay


/obj/effect/decal/cleanable/blood/footprints/examine(mob/user)
	. = ..()
	if((shoe_types.len + species_types.len) > 0)
		. += "You recognise the footprints as belonging to:"
		for(var/sole in shoe_types)
			var/obj/item/clothing/item = sole
			var/article = initial(item.gender) == PLURAL ? "Some" : "A"
			. += "[icon2html(initial(item.icon), user, initial(item.icon_state))] [article] <B>[initial(item.name)]</B>."
		for(var/species in species_types)
			// god help me
			if(species == "unknown")
				. += "Some <B>feet</B>."
			else if(species == SPECIES_MONKEY)
				. += "[icon2html('icons/mob/monkey.dmi', user, "monkey1")] Some <B>monkey feet</B>."
			else if(species == SPECIES_HUMAN)
				. += "[icon2html('icons/mob/human/bodyparts.dmi', user, "default_human_l_leg")] Some <B>human feet</B>."
			else
				. += "[icon2html('icons/mob/human/bodyparts.dmi', user, "[species]_l_leg")] Some <B>[species] feet</B>."

/obj/effect/decal/cleanable/blood/footprints/replace_decal(obj/effect/decal/cleanable/C)
	if(blood_state != C.blood_state) //We only replace footprints of the same type as us
		return FALSE
	return ..()

/obj/effect/decal/cleanable/blood/footprints/can_bloodcrawl_in()
	if((blood_state != BLOOD_STATE_OIL) && (blood_state != BLOOD_STATE_NOT_BLOODY))
		return TRUE
	return FALSE
