///Wing base type. doesn't really do anything
/obj/item/organ/wings
	name = "wings"
	desc = "Spread your wings and FLLLLLLLLYYYYY!"

	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_EXTERNAL_WINGS

	use_mob_sprite_as_obj_sprite = TRUE
	bodypart_overlay = /datum/bodypart_overlay/mutant/wings

	organ_flags = parent_type::organ_flags | ORGAN_EXTERNAL

	///The flight action object
	var/datum/action/innate/flight/fly

	///Are our wings open or closed?
	var/wings_open = FALSE
	///We cant hide this wings in suit
	var/cant_hide = FALSE
	///The level of flight this organ provides, from letting one fly in 0G air to giving the flight action
	var/flight_level = WINGS_AIRWORTHY

	// grind_results = list(/datum/reagent/flightpotion = 5)
	food_reagents = list(/datum/reagent/flightpotion = 5)

///Checks if the wings can soften short falls
/obj/item/organ/wings/proc/can_soften_fall()
	return TRUE

///Implement as needed to play a sound effect on *flap emote
/obj/item/organ/wings/proc/make_flap_sound(mob/living/carbon/wing_owner)
	return

///hud action for starting and stopping flight
/datum/action/innate/flight
	name = "Toggle Flight"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_IMMOBILE|AB_CHECK_INCAPACITATED
	button_icon = 'icons/hud/actions/actions_items.dmi'
	//icon_icon = 'icons/hud/actions/actions_items.dmi'
	button_icon_state = "flight"

/datum/action/innate/flight/on_activate(mob/user, atom/target)
	var/mob/living/carbon/human/human = owner
	var/obj/item/organ/wings/wings = human.get_organ_slot(ORGAN_SLOT_EXTERNAL_WINGS)
	if(wings?.can_fly(human))
		wings.toggle_flight(human)
		if(!(human.movement_type & FLYING))
			to_chat(human, span_notice("You settle gently back onto the ground..."))
		else
			to_chat(human, span_notice("You beat your wings and begin to hover gently above the ground..."))
			human.set_resting(FALSE, TRUE)

/obj/item/organ/wings/Destroy()
	if(fly)
		QDEL_NULL(fly)
	return ..()

/obj/item/organ/wings/on_mob_insert(mob/living/carbon/receiver, special, movement_flags)
	. = ..()

	update_flight(receiver)

/obj/item/organ/wings/on_mob_insert(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	update_flight(null)

/obj/item/organ/wings/proc/set_flight(mob/living/carbon/organ_owner, state = null)
	if(!isnull(state))
		flight_level = state

	update_flight(organ_owner)

/obj/item/organ/wings/proc/update_flight(mob/living/carbon/organ_owner)
	// Remove any existing flight ability
	fly?.Remove(owner)
	if(wings_open)
		toggle_flight(owner)

	// Only add flight if we have an owner and sufficient flight level
	if(organ_owner && flight_level > WINGS_FLIGHTLESS)
		// Create a new flight action if needed
		if(QDELETED(fly))
			fly = new
		// Grant the flight action to the owner
		fly.Grant(organ_owner)

/obj/item/organ/wings/on_life(delta_time, times_fired)
	. = ..()
	handle_flight(owner)

///Called on_life(). Handle flight code and check if we're still flying
/obj/item/organ/wings/proc/handle_flight(mob/living/carbon/human/human)
	if(!(human.movement_type & FLYING))
		return FALSE
	if(!can_fly(human))
		toggle_flight(human)
		return FALSE
	return TRUE


///Check if we're still eligible for flight (wings covered, atmosphere too thin, etc)
/obj/item/organ/wings/proc/can_fly(mob/living/carbon/human/human)
	if(human.stat || human.body_position == LYING_DOWN)
		return FALSE
	if(flight_level < WINGS_AIRWORTHY)
		return FALSE
	//Jumpsuits have tail holes, so it makes sense they have wing holes too
	if(!cant_hide && human.wear_suit && ((human.wear_suit.flags_inv & HIDEJUMPSUIT) && (!human.wear_suit.species_exception || !is_type_in_list(src, human.wear_suit.species_exception))))
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
/obj/item/organ/wings/proc/fly_slip(mob/living/carbon/human/human)
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

///UNSAFE PROC, should only be called through the Activate or other sources that check for CanFly
/obj/item/organ/wings/proc/toggle_flight(mob/living/carbon/human/human)
	if(!HAS_TRAIT_FROM(human, TRAIT_MOVE_FLYING, SPECIES_FLIGHT_TRAIT))
		human.physiology.stun_mod *= 2
		human.add_traits(list(TRAIT_NO_FLOATING_ANIM, TRAIT_MOVE_FLYING), SPECIES_FLIGHT_TRAIT)
		passtable_on(human, SPECIES_FLIGHT_TRAIT)
		open_wings()
	else
		human.physiology.stun_mod *= 0.5
		human.remove_traits(list(TRAIT_NO_FLOATING_ANIM, TRAIT_MOVE_FLYING), SPECIES_FLIGHT_TRAIT)
		passtable_off(human, SPECIES_FLIGHT_TRAIT)
		close_wings()

	human.refresh_gravity()

///SPREAD OUR WINGS AND FLLLLLYYYYYY
/obj/item/organ/wings/proc/open_wings()
	var/datum/bodypart_overlay/mutant/wings/overlay = bodypart_overlay
	overlay.open_wings()
	wings_open = TRUE
	owner.update_body_parts()

///close our wings
/obj/item/organ/wings/proc/close_wings()
	var/datum/bodypart_overlay/mutant/wings/overlay = bodypart_overlay
	wings_open = FALSE
	overlay.close_wings()
	owner.update_body_parts()

	if(isturf(owner?.loc))
		var/turf/location = loc
		location.Entered(src, NONE)

///Bodypart overlay of default wings. Does not have any wing functionality
/datum/bodypart_overlay/mutant/wings
	layers = ALL_EXTERNAL_OVERLAYS
	feature_key = "wings"
	///Are our wings currently open? Change through open_wings or close_wings()
	VAR_PRIVATE/wings_open = FALSE
	///Feature render key for opened wings
	var/open_feature_key = "wingsopen"

/datum/bodypart_overlay/mutant/wings/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner)
	var/mob/living/carbon/human/human = bodypart_owner.owner
	if(!istype(human))
		return TRUE
	if(!human.wear_suit)
		return TRUE
	if(!(human.wear_suit.flags_inv & HIDEJUMPSUIT))
		return TRUE
	if(human.wear_suit.species_exception && is_type_in_list(src, human.wear_suit.species_exception))
		return TRUE
	return FALSE

/datum/bodypart_overlay/mutant/wings/get_global_feature_list()
	if(wings_open)
		return SSaccessories.wings_open_list
	else
		return SSaccessories.wings_list

///Update our wingsprite to the open wings variant
/datum/bodypart_overlay/mutant/wings/proc/open_wings()
	wings_open = TRUE
	feature_key = open_feature_key
	set_appearance_from_name(sprite_datum.name) //It'll look for the same name again, but this time from the open wings list

///Update our wingsprite to the closed wings variant
/datum/bodypart_overlay/mutant/wings/proc/close_wings()
	wings_open = FALSE
	feature_key = initial(feature_key)
	set_appearance_from_name(sprite_datum.name)

/datum/bodypart_overlay/mutant/wings/generate_icon_cache()
	. = ..()
	. += wings_open ? "open" : "closed"

///angel wings, which relate to humans. comes with holiness.
/obj/item/organ/wings/angel
	name = "angel wings"
	desc = "Holier-than-thou attitude not included."
	sprite_accessory_override = /datum/sprite_accessory/wings_open/angel

	organ_traits = list(TRAIT_HOLY)

///dragon wings, which relate to lizards.
/obj/item/organ/wings/dragon
	name = "dragon wings"
	desc = "Hey, HEY- NOT lizard wings. Dragon wings. Mighty dragon wings."
	sprite_accessory_override = /datum/sprite_accessory/wings/dragon

///robotic wings, which relate to androids.
/obj/item/organ/wings/robotic
	name = "robotic wings"
	desc = "Using microscopic hover-engines, or \"microwings,\" as they're known in the trade, these tiny devices are able to lift a few grams at a time. Gathering enough of them, and you can lift impressively large things."
	organ_flags = ORGAN_ROBOTIC
	sprite_accessory_override = /datum/sprite_accessory/wings/robotic

///skeletal wings, which relate to skeletal races.
/obj/item/organ/wings/skeleton
	name = "skeletal wings"
	desc = "Powered by pure edgy-teenager-notebook-scribblings. Just kidding. But seriously, how do these keep you flying?!"
	sprite_accessory_override = /datum/sprite_accessory/wings/skeleton

/obj/item/organ/wings/moth/make_flap_sound(mob/living/carbon/wing_owner)
	playsound(wing_owner, 'sound/emotes/moth/moth_flutter.ogg', 50, TRUE)

///fly wings, which relate to flies.
/obj/item/organ/wings/fly
	name = "fly wings"
	desc = "Fly as a fly."
	sprite_accessory_override = /datum/sprite_accessory/wings/fly
	//flight_level = WINGS_COSMETIC

///Bee wings with special dash ability
/obj/item/organ/wings/bee
	name = "pair of bee wings"
	desc = "A pair of bee wings. They seem tiny and undergrown."
	icon_state = "beewings"
	flight_level = WINGS_FLIGHTLESS
	actions_types = list(/datum/action/item_action/organ_action/use/bee_dash)
	sprite_accessory_override = /datum/sprite_accessory/wings/bee
	var/jumpdist = 3

/datum/action/item_action/organ_action/use/bee_dash
	name = "Bee Dash"
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_IMMOBILE
	cooldown_time = 10 SECONDS
	var/jumpspeed = 1

/datum/action/item_action/organ_action/use/bee_dash/on_activate(mob/user, atom/target)
	var/mob/living/carbon/human/H = owner
	var/obj/item/organ/wings/bee/wings = H.get_organ_slot(ORGAN_SLOT_EXTERNAL_WINGS)
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

///Cybernetic wings that can malfunction from EMP
/obj/item/organ/wings/cybernetic
	name = "cybernetic wingpack"
	desc = "A compact pair of mechanical wings, which use the atmosphere to create thrust."
	icon_state = "wingpack"
	color = "#FFFFFF"
	organ_flags = ORGAN_ROBOTIC

/obj/item/organ/wings/cybernetic/emp_act(severity)
	. = ..()
	if(owner && (organ_flags & ORGAN_ROBOTIC))
		fly_slip()

///Advanced alien wings that don't need atmosphere
/obj/item/organ/wings/cybernetic/ayy
	name = "advanced cybernetic wingpack"
	desc = "A compact pair of mechanical wings. They are equipped with miniaturized void engines, and can fly in any atmosphere, or lack thereof."
