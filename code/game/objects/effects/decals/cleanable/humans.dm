/obj/effect/decal/cleanable/blood
	name = "blood"
	desc = "It's red and gooey. Perhaps it's the chef's cooking?"
	icon = 'icons/effects/blood.dmi'
	icon_state = "floor1"
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7")
	blood_state = BLOOD_STATE_HUMAN
	bloodiness = BLOOD_AMOUNT_PER_DECAL

/obj/effect/decal/cleanable/blood/replace_decal(obj/effect/decal/cleanable/blood/C)
	C.add_blood_DNA(return_blood_DNA())
	if (bloodiness)
		if (C.bloodiness < MAX_SHOE_BLOODINESS)
			C.bloodiness += bloodiness
	return ..()

/obj/effect/decal/cleanable/blood/old
	name = "dried blood"
	desc = "Looks like it's been here a while.  Eew."
	bloodiness = 0
	icon_state = "floor1-old"
	var/list/datum/disease/diseases = list()

/obj/effect/decal/cleanable/blood/old/Initialize(mapload, list/datum/disease/diseases)
	add_blood_DNA(list("Non-human DNA" = random_blood_type())) // Needs to happen before ..()
	. = ..()
	icon_state = "[icon_state]-old" //change from the normal blood icon selected from random_icon_states in the parent's Initialize to the old dried up blood.
	if(length(diseases))
		src.diseases += diseases
	if(prob(75))
		var/datum/disease/advance/new_disease = new /datum/disease/advance/random(rand(1, 4), rand(7, 9), 4)
		src.diseases += new_disease

/obj/effect/decal/cleanable/blood/old/extrapolator_act(mob/living/user, obj/item/extrapolator/extrapolator, dry_run = FALSE)
	. = ..()
	EXTRAPOLATOR_ACT_ADD_DISEASES(., diseases)

/obj/effect/decal/cleanable/blood/splatter
	icon_state = "gibbl1"
	random_icon_states = list("gibbl1", "gibbl2", "gibbl3", "gibbl4", "gibbl5")

/obj/effect/decal/cleanable/blood/tracks
	name = "tracks"
	desc = "They look like tracks left by wheels."
	icon_state = "tracks"
	random_icon_states = null

/obj/effect/decal/cleanable/trail_holder //not a child of blood on purpose
	name = "blood"
	icon = 'icons/effects/blood.dmi'
	desc = "Your instincts say you shouldn't be following these."
	var/list/existing_dirs = list()

/obj/effect/decal/cleanable/trail_holder/can_bloodcrawl_in()
	return TRUE

/obj/effect/decal/cleanable/blood/gibs
	name = "gibs"
	desc = "They look bloody and gruesome."
	icon = 'icons/effects/blood.dmi'
	icon_state = "gib1"
	layer = LOW_OBJ_LAYER
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6")
	mergeable_decal = FALSE
	turf_loc_check = FALSE

	var/already_rotting = FALSE
		///Information about the diseases our streaking spawns
	var/list/streak_diseases

/obj/effect/decal/cleanable/blood/gibs/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	reagents.add_reagent(/datum/reagent/liquidgibs, 5)
	RegisterSignal(src, COMSIG_MOVABLE_PIPE_EJECTING, PROC_REF(on_pipe_eject))
	if(already_rotting)
		start_rotting(rename=FALSE)
	else
		addtimer(CALLBACK(src, PROC_REF(start_rotting)), 2 MINUTES)

/obj/effect/decal/cleanable/blood/gibs/proc/start_rotting(rename=TRUE)
	if(rename)
		name = "rotting [initial(name)]"
		desc += " They smell terrible."

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
	SEND_SIGNAL(src, COMSIG_GIBS_STREAK, directions, streak_diseases)
	var/direction = pick(directions)
	streak_diseases = list()
	var/delay = 2
	var/range = pick(0, 200; 1, 150; 2, 50; 3, 17; 50) //the 3% chance of 50 steps is intentional and played for laughs.
	if(!step_to(src, get_step(src, direction), 0))
		return
	if(mapload)
		for (var/i = 1, i < range, i++)
			new /obj/effect/decal/cleanable/blood/splatter(loc, streak_diseases)
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
	bloodiness = 0
	already_rotting = TRUE
	var/list/datum/disease/diseases = list()

/obj/effect/decal/cleanable/blood/gibs/old/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	setDir(pick(1, 2, 4, 8))
	icon_state += "-old"
	add_blood_DNA(list("Non-human DNA" = random_blood_type()))
	if(length(diseases))
		src.diseases += diseases
	if(prob(80))
		var/datum/disease/advance/new_disease = new /datum/disease/advance/random(rand(3, 6), rand(8, 9), 4)
		src.diseases += new_disease

/obj/effect/decal/cleanable/blood/gibs/old/extrapolator_act(mob/living/user, obj/item/extrapolator/extrapolator, dry_run = FALSE)
	. = ..()
	EXTRAPOLATOR_ACT_ADD_DISEASES(., diseases)

/obj/effect/decal/cleanable/blood/drip
	name = "drips of blood"
	desc = "It's red."
	icon_state = "drip5" //using drip5 since the others tend to blend in with pipes & wires.
	random_icon_states = list("drip1","drip2","drip3","drip4","drip5")
	bloodiness = 0
	var/drips = 1

/obj/effect/decal/cleanable/blood/drip/can_bloodcrawl_in()
	return TRUE


//BLOODY FOOTPRINTS
/obj/effect/decal/cleanable/blood/footprints
	name = "footprints"
	icon = 'icons/effects/footprints.dmi'
	icon_state = "nothingwhatsoever"
	desc = "WHOSE FOOTPRINTS ARE THESE?"
	icon_state = "blood1"
	random_icon_states = null
	blood_state = BLOOD_STATE_HUMAN //the icon state to load images from
	var/entered_dirs = 0
	var/exited_dirs = 0
	var/list/shoe_types = list()

/obj/effect/decal/cleanable/blood/footprints/on_entered(datum/source, atom/movable/O)
	. = ..()
	if(ishuman(O))
		var/mob/living/carbon/human/H = O
		var/obj/item/clothing/shoes/S = H.shoes
		if(S && S.bloody_shoes[blood_state])
			S.bloody_shoes[blood_state] = max(S.bloody_shoes[blood_state] - BLOOD_LOSS_PER_STEP, 0)
			shoe_types |= S.type
			if (!(entered_dirs & H.dir))
				entered_dirs |= H.dir
				update_icon()

/obj/effect/decal/cleanable/blood/footprints/on_uncrossed(datum/source, atom/movable/O)
	. = ..()
	if(ishuman(O))
		var/mob/living/carbon/human/H = O
		var/obj/item/clothing/shoes/S = H.shoes
		if(S && S.bloody_shoes[blood_state])
			S.bloody_shoes[blood_state] = max(S.bloody_shoes[blood_state] - BLOOD_LOSS_PER_STEP, 0)
			shoe_types  |= S.type
			if (!(exited_dirs & H.dir))
				exited_dirs |= H.dir
				update_icon()

//Cache of bloody footprint images
//Key:
//"entered-[blood_state]-[dir_of_image]"
//or: "exited-[blood_state]-[dir_of_image]"
GLOBAL_LIST_EMPTY(bloody_footprints_cache)

/obj/effect/decal/cleanable/blood/footprints/update_icon()
	cut_overlays()

	for(var/Ddir in GLOB.cardinals)
		if(entered_dirs & Ddir)
			var/image/bloodstep_overlay = GLOB.bloody_footprints_cache["entered-[blood_state]-[Ddir]"]
			if(!bloodstep_overlay)
				GLOB.bloody_footprints_cache["entered-[blood_state]-[Ddir]"] = bloodstep_overlay = image(icon, "[blood_state]1", dir = Ddir)
			add_overlay(bloodstep_overlay)
		if(exited_dirs & Ddir)
			var/image/bloodstep_overlay = GLOB.bloody_footprints_cache["exited-[blood_state]-[Ddir]"]
			if(!bloodstep_overlay)
				GLOB.bloody_footprints_cache["exited-[blood_state]-[Ddir]"] = bloodstep_overlay = image(icon, "[blood_state]2", dir = Ddir)
			add_overlay(bloodstep_overlay)

	alpha = BLOODY_FOOTPRINT_BASE_ALPHA+bloodiness


/obj/effect/decal/cleanable/blood/footprints/examine(mob/user)
	. = ..()
	if(shoe_types.len)
		. += "You recognise the footprints as belonging to:\n"
		for(var/shoe in shoe_types)
			var/obj/item/clothing/shoes/S = shoe
			. += "[icon2html(initial(S.icon), user)] Some <B>[initial(S.name)]</B>.\n"

/obj/effect/decal/cleanable/blood/footprints/replace_decal(obj/effect/decal/cleanable/C)
	if(blood_state != C.blood_state) //We only replace footprints of the same type as us
		return
	..()

/obj/effect/decal/cleanable/blood/footprints/can_bloodcrawl_in()
	if((blood_state != BLOOD_STATE_OIL) && (blood_state != BLOOD_STATE_NOT_BLOODY))
		return 1
	return 0
