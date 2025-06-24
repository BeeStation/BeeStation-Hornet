/obj/item/organ/external/wings
	name = "Pair of wings"
	desc = "A pair of wings. They look skinny and useless"
	icon_state = "angelwings"
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_EXTERNAL_WINGS
	layers = ALL_EXTERNAL_OVERLAYS

	feature_key = "wings"
	/// The flight level determines flight capabilities
	var/flight_level = WINGS_COSMETIC
	/// Are the wings open or closed?
	var/wings_open = FALSE
	///The flight action object
	var/datum/action/innate/flight/fly

	///The preference type for opened wings
	var/wings_open_feature_key = "wingsopen"
	///The preference type for closed wings
	var/wings_closed_feature_key = "wings"

/obj/item/organ/external/wings/can_draw_on_bodypart(mob/living/carbon/human/human)
	if(!human.wear_suit)
		return TRUE
	if(!(human.wear_suit.flags_inv & HIDEJUMPSUIT))
		return TRUE
	if(human.wear_suit.species_exception && is_type_in_list(src, human.wear_suit.species_exception))
		return TRUE
	return FALSE

/obj/item/organ/external/wings/Insert(mob/living/carbon/reciever, special, drop_if_replaced)
	. = ..()

	Refresh(reciever)

	RegisterSignal(reciever, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(update_float_move))

/obj/item/organ/external/wings/proc/Refresh(mob/living/carbon/human/H)
	if(flight_level >= WINGS_FLYING)
		fly = new
		fly.Grant(H)
	else if(fly)
		fly.Remove(H)
		QDEL_NULL(fly)
		if(H.movement_type & FLYING)
			toggle_flight(H)

/obj/item/organ/external/wings/Remove(mob/living/carbon/organ_owner, special, pref_load)
	. = ..()

	for(fly in organ_owner.actions)
		fly.Remove(organ_owner)

	if(organ_owner.movement_type & FLYING)
		toggle_flight(organ_owner)

	UnregisterSignal(organ_owner, COMSIG_MOVABLE_PRE_MOVE)
	REMOVE_TRAIT(organ_owner, TRAIT_FREE_FLOAT_MOVEMENT, REF(src))

/obj/item/organ/external/wings/on_life(delta_time, times_fired)
	. = ..()

	if(owner && flight_level >= WINGS_FLYING)
		handle_flight(owner)

///Called on_life(). Handle flight code and check if we're still flying
/obj/item/organ/external/wings/proc/handle_flight(mob/living/carbon/human/human)
	if(!(human.movement_type & FLYING))
		return FALSE
	if(!can_fly(human))
		toggle_flight(human)
		return FALSE
	return TRUE

///Check if we're still eligible for flight (wings covered, atmosphere too thin, etc)
/obj/item/organ/external/wings/proc/can_fly(mob/living/carbon/human/human)
	if(human.stat || human.body_position == LYING_DOWN)
		return FALSE
	//Jumpsuits have tail holes, so it makes sense they have wing holes too
	if(human.wear_suit && ((human.wear_suit.flags_inv & HIDEJUMPSUIT) && (!human.wear_suit.species_exception || !is_type_in_list(src, human.wear_suit.species_exception))))
		to_chat(human, span_warning("Your suit blocks your wings from extending!"))
		return FALSE
	var/turf/location = get_turf(human)
	if(!location)
		return FALSE

	var/datum/gas_mixture/environment = location.return_air()
	if(environment?.return_pressure() < HAZARD_LOW_PRESSURE + 10)
		to_chat(human, span_warning("The atmosphere is too thin for you to fly!"))
		return FALSE
	else
		return TRUE

///Slipping but in the air?
/obj/item/organ/external/wings/proc/fly_slip(mob/living/carbon/human/human)
	var/obj/buckled_obj
	if(human.buckled)
		buckled_obj = human.buckled

	to_chat(human, span_notice("Your wings spazz out and launch you!"))

	playsound(human.loc, 'sound/misc/slip.ogg', 50, TRUE, -3)

	for(var/obj/item/choking_hazard in human.held_items)
		human.accident(choking_hazard)

	var/olddir = human.dir

	human.stop_pulling()
	if(buckled_obj)
		buckled_obj.unbuckle_mob(human)
		step(buckled_obj, olddir)
	else
		human.AddComponent(/datum/component/force_move, get_ranged_target_turf(human, olddir, 4), TRUE)
	return TRUE

///Check if we can float around in low-grav environments
/obj/item/organ/external/wings/proc/update_float_move()
	SIGNAL_HANDLER

	if(!isspaceturf(owner.loc))
		var/datum/gas_mixture/current = owner.loc.return_air()
		if(current && (current.return_pressure() >= ONE_ATMOSPHERE*0.85) && flight_level >= WINGS_FLYING) //reasonable pressure and capable wings
			ADD_TRAIT(owner, TRAIT_FREE_FLOAT_MOVEMENT, REF(src))
			return

	REMOVE_TRAIT(owner, TRAIT_FREE_FLOAT_MOVEMENT, REF(src))

///UNSAFE PROC, should only be called through the Activate or other sources that check for CanFly
/obj/item/organ/external/wings/proc/toggle_flight(mob/living/carbon/human/human)
	if(!HAS_TRAIT_FROM(human, TRAIT_MOVE_FLYING, SPECIES_FLIGHT_TRAIT))
		human.physiology.stun_mod *= 2
		ADD_TRAIT(human, TRAIT_NO_FLOATING_ANIM, SPECIES_FLIGHT_TRAIT)
		ADD_TRAIT(human, TRAIT_MOVE_FLYING, SPECIES_FLIGHT_TRAIT)
		passtable_on(human, SPECIES_TRAIT)
		open_wings()
	else
		human.physiology.stun_mod *= 0.5
		REMOVE_TRAIT(human, TRAIT_NO_FLOATING_ANIM, SPECIES_FLIGHT_TRAIT)
		REMOVE_TRAIT(human, TRAIT_MOVE_FLYING, SPECIES_FLIGHT_TRAIT)
		passtable_off(human, SPECIES_TRAIT)
		close_wings()

///Opens wings appearance
/obj/item/organ/external/wings/proc/open_wings()
	feature_key = wings_open_feature_key
	wings_open = TRUE

	cache_key = generate_icon_cache() //we've changed preference to open, so we only need to update the key and ask for an update to change our sprite
	owner.update_body_parts()

///Closes wings appearance
/obj/item/organ/external/wings/proc/close_wings()
	feature_key = wings_closed_feature_key
	wings_open = FALSE

	cache_key = generate_icon_cache()
	owner.update_body_parts()
	if(isturf(owner?.loc))
		var/turf/location = loc
		location.Entered(src, NONE)

///Cybernetic wings that can malfunction from EMP
/obj/item/organ/external/wings/cybernetic
	name = "cybernetic wingpack"
	desc = "A compact pair of mechanical wings, which use the atmosphere to create thrust."
	icon_state = "wingpack"
	color = "#FFFFFF"
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC
	flight_level = WINGS_FLYING

/obj/item/organ/external/wings/cybernetic/emp_act(severity)
	. = ..()
	if(owner && (organ_flags & ORGAN_SYNTHETIC))
		var/mob/living/carbon/human/H = owner
		var/outofcontrol = ((rand(1, 10)) * severity)
		to_chat(H, span_userdanger("You lose control of your [src]!"))
		while(outofcontrol)
			if(can_fly(H))
				if(H.movement_type & FLYING)
					var/throw_dir = pick(GLOB.alldirs)
					var/atom/throw_target = get_edge_target_turf(H, throw_dir)
					H.throw_at(throw_target, 5, 4)
					if(prob(10))
						toggle_flight(H)
				else
					toggle_flight(H)
					if(prob(50))
						stoplag(5)
						toggle_flight(H)
			else
				H.Togglewings()
			outofcontrol--
			stoplag(5)

///Advanced alien wings that don't need atmosphere
/obj/item/organ/external/wings/cybernetic/ayy
	name = "advanced cybernetic wingpack"
	desc = "A compact pair of mechanical wings. They are equipped with miniaturized void engines, and can fly in any atmosphere, or lack thereof."
	flight_level = WINGS_MAGIC

///Moth wings
/obj/item/organ/external/wings/moth
	name = "pair of moth wings"
	desc = "A pair of moth wings."

	feature_key = "moth_wings"
	preference = "feature_moth_wings"
	icon_state = "mothwings"
	layers = EXTERNAL_BEHIND | EXTERNAL_FRONT

	dna_block = DNA_MOTH_WINGS_BLOCK
	flight_level = WINGS_FLIGHTLESS

	/// Are the wings burned?
	var/burnt = FALSE
	/// Store original wing feature for when wings are healed
	var/original_sprite = ""

/obj/item/organ/external/wings/moth/get_global_feature_list()
	return GLOB.moth_wings_list

/obj/item/organ/external/wings/moth/can_draw_on_bodypart(mob/living/carbon/human/human)
	return TRUE

/obj/item/organ/external/wings/moth/Insert(mob/living/carbon/reciever, special, drop_if_replaced)
	. = ..()

	RegisterSignal(reciever, COMSIG_HUMAN_BURNING, PROC_REF(try_burn_wings))
	RegisterSignal(reciever, COMSIG_LIVING_POST_FULLY_HEAL, PROC_REF(heal_wings))

/obj/item/organ/external/wings/moth/Remove(mob/living/carbon/organ_owner, special, pref_load)
	. = ..()

	UnregisterSignal(organ_owner, list(COMSIG_HUMAN_BURNING, COMSIG_LIVING_POST_FULLY_HEAL))
	REMOVE_TRAIT(organ_owner, TRAIT_MOTH_BURNT, "fire")

///check if our wings can burn off
/obj/item/organ/external/wings/moth/proc/try_burn_wings(mob/living/carbon/human/human)
	SIGNAL_HANDLER

	if(!burnt && human.bodytemperature >= 800 && human.fire_stacks > 0) //do not go into the extremely hot light. you will not survive
		to_chat(human, span_danger("Your precious wings burn to a crisp!"))
		SEND_SIGNAL(human, COMSIG_ADD_MOOD_EVENT, "burnt_wings", /datum/mood_event/burnt_wings)

		burn_wings()
		human.update_body_parts()

///burn the wings off
/obj/item/organ/external/wings/moth/proc/burn_wings()
	burnt = TRUE
	original_sprite = sprite_datum.name
	set_sprite("Burnt Off")

	// Disable flight if we're flying
	flight_level = WINGS_COSMETIC
	if((owner.movement_type & FLYING))
		toggle_flight(owner)

	ADD_TRAIT(owner, TRAIT_MOTH_BURNT, "fire")
	owner.dna.species.handle_mutant_bodyparts(owner)
	owner.dna.species.handle_body(owner)

///heal our wings back up
/obj/item/organ/external/wings/moth/proc/heal_wings()
	SIGNAL_HANDLER

	if(burnt)
		burnt = FALSE
		set_sprite(original_sprite)

		if(istype(src, /obj/item/organ/external/wings/moth/robust))
			flight_level = WINGS_FLYING
		else
			flight_level = WINGS_FLIGHTLESS

		REMOVE_TRAIT(owner, TRAIT_MOTH_BURNT, "fire")
		SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "burnt_wings")
		to_chat(owner, span_notice("Your wings have regenerated!"))

		owner.dna.species.handle_mutant_bodyparts(owner)
		owner.dna.species.handle_body(owner)

///Robust moth wings that can fly
/obj/item/organ/external/wings/moth/robust
	name = "robust moth wings"
	desc = "A pair of robust moth wings, capable of limited flight."
	flight_level = WINGS_FLYING

///Standard angel wings
/obj/item/organ/external/wings/angel
	name = "pair of feathered wings"
	desc = "A pair of feathered wings. They seem robust enough for flight."
	color = "#FFFFFF"
	flight_level = WINGS_FLYING

///Dragon wings
/obj/item/organ/external/wings/dragon
	name = "pair of dragon wings"
	desc = "A pair of dragon wings. They seem robust enough for flight."
	color = "#FFFFFF"
	icon_state = "dragonwings"
	flight_level = WINGS_FLYING

///Decorative dragon wings
/obj/item/organ/external/wings/dragon/fake
	desc = "A pair of fake dragon wings. They're purely decorative."
	flight_level = WINGS_COSMETIC

///Bee wings with special dash ability
/obj/item/organ/external/wings/bee
	name = "pair of bee wings"
	desc = "A pair of bee wings. They seem tiny and undergrown."
	color = "#FFFF00"
	icon_state = "beewings"
	flight_level = WINGS_COSMETIC
	actions_types = list(/datum/action/item_action/organ_action/use/bee_dash)
	var/jumpdist = 3

/datum/action/item_action/organ_action/use/bee_dash
	name = "Bee Dash"
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_IMMOBILE
	cooldown_time = 10 SECONDS
	var/jumpspeed = 1

/datum/action/item_action/organ_action/use/bee_dash/on_activate(mob/user, atom/target)
	var/mob/living/carbon/human/H = owner
	var/obj/item/organ/external/wings/bee/wings = H.get_organ_slot(ORGAN_SLOT_EXTERNAL_WINGS)
	var/jumpdistance = wings.jumpdist

	if(H.buckled)
		return
	var/datum/gas_mixture/environment = H.loc.return_air()
	if(environment?.return_pressure() < HAZARD_LOW_PRESSURE + 10)
		to_chat(H, span_warning("The atmosphere is too thin for you to dash!"))
		return

	var/turf/dash_target = get_edge_target_turf(H, H.dir)
	var/hoppingtable = FALSE
	var/jumpdistancemoved = jumpdistance
	var/turf/checkjump = get_turf(H)

	for(var/i in 1 to jumpdistance)
		var/turf/T = get_step(checkjump, H.dir)
		if(T.density || !T.ClickCross(invertDir(H.dir), border_only = 1))
			break
		if(locate(/obj/structure/table) in T)
			hoppingtable = TRUE
			jumpdistancemoved = i
			break
		if(!T.ClickCross(H.dir))
			break
		checkjump = get_step(checkjump, H.dir)

	var/datum/callback/crashcallback
	if(hoppingtable)
		crashcallback = CALLBACK(src, PROC_REF(crash_into_table), get_step(checkjump, H.dir))
	if(H.throw_at(dash_target, jumpdistancemoved, jumpspeed, spin = FALSE, diagonals_first = TRUE, callback = crashcallback, force = MOVE_FORCE_WEAK))
		playsound(H, 'sound/creatures/bee.ogg', 50, 1, 1)
		H.visible_message(span_warning("[H] dashes forward into the air!"))
		start_cooldown()
	else
		to_chat(H, span_warning("Something prevents you from dashing forward!"))

/datum/action/item_action/organ_action/use/bee_dash/proc/crash_into_table(turf/tableturf)
	if(owner.loc == tableturf)
		var/mob/living/carbon/human/H = owner
		H.take_bodypart_damage(10, check_armor = TRUE)
		H.Paralyze(40)
		H.visible_message(span_danger("[H] crashes into a table, falling over!"),
			span_userdanger("You violently crash into a table!"))
		playsound(src,'sound/weapons/punch1.ogg', 50, TRUE)

///HUD action for toggling flight
/datum/action/innate/flight
	name = "Toggle Flight"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_IMMOBILE
	icon_icon = 'icons/hud/actions/actions_items.dmi'
	button_icon_state = "flight"

/datum/action/innate/flight/on_activate()
	var/mob/living/carbon/human/H = owner
	var/obj/item/organ/external/wings/wings = H.get_organ_slot(ORGAN_SLOT_EXTERNAL_WINGS)
	if(wings && wings.can_fly(H))
		wings.toggle_flight(H)
		if(!(H.movement_type & FLYING))
			to_chat(H, span_notice("You settle gently back onto the ground..."))
		else
			to_chat(H, span_notice("You beat your wings and begin to hover gently above the ground..."))
			H.set_resting(FALSE, TRUE)
