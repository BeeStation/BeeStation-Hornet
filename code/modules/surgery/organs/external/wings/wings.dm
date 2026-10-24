///Wing base type. can do things :>
/obj/item/organ/wings
	abstract_type = /obj/item/organ/wings
	name = "Pair of wings"
	desc = "A pair of wings. They look skinny and useless"
	icon_state = "angelwings"

	gender = PLURAL
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_EXTERNAL_WINGS

	use_mob_sprite_as_obj_sprite = TRUE
	bodypart_overlay = /datum/bodypart_overlay/mutant/wings

	organ_flags = parent_type::organ_flags | ORGAN_EXTERNAL
	abstract_type = /obj/item/organ/wings

	///The flight action object
	var/datum/action/innate/flight/fly

	///Are our wings open or closed?
	var/wings_open = FALSE
	///We cant hide these wings in suit
	var/cant_hide = FALSE
	///The level of flight this organ provides, from passive 0G drift to magic flight
	var/flight_level = WINGS_AIRWORTHY
	///Does this wing type have open/close sprite variants
	var/has_open_sprite = TRUE
	///Sound played on the *flap emote, if any
	var/flap_sound

///Checks if the wings can soften short falls
/obj/item/organ/wings/proc/can_soften_fall()
	return TRUE

///Set flap_sound to play the sound when emoting *flap
/obj/item/organ/wings/proc/make_flap_sound(mob/living/carbon/wing_owner)
	if(isnull(flap_sound))
		return
	playsound(wing_owner, flap_sound, 50, TRUE)

/obj/item/organ/wings/Initialize(mapload)
	if(flight_level > WINGS_FLIGHTLESS)
		// only flightful wings get orange juice
		food_reagents = list(/datum/reagent/flightpotion = 5)
		grind_results = list(/datum/reagent/flightpotion = 5)
	. = ..()

/obj/item/organ/wings/Destroy()
	QDEL_NULL(fly)
	return ..()

/obj/item/organ/wings/on_mob_insert(mob/living/carbon/receiver, special, movement_flags)
	. = ..()
	update_flight(receiver)

/obj/item/organ/wings/on_mob_remove(mob/living/carbon/organ_owner, special, movement_flags)
	if(HAS_TRAIT_FROM(organ_owner, TRAIT_MOVE_FLOATING, SPECIES_FLIGHT_TRAIT))
		toggle_flight(organ_owner)
	else if(wings_open)
		close_wings()
	fly?.Remove(organ_owner)
	return ..()

//If some goober tries to varedit the flight_level instead of running the set_flight() proc, we take care of that
/obj/item/organ/wings/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, flight_level))
		set_flight(owner, var_value)
		return TRUE
	return ..()

/obj/item/organ/wings/proc/set_flight(mob/living/carbon/organ_owner, state = null)
	organ_owner ||= owner
	if(!isnull(state) && state != flight_level)
		//Force landing while old binds are still live
		if(!isnull(organ_owner) && HAS_TRAIT_FROM(organ_owner, TRAIT_MOVE_FLOATING, SPECIES_FLIGHT_TRAIT))
			toggle_flight(organ_owner)
		flight_level = state
	update_flight(organ_owner)

/obj/item/organ/wings/proc/update_flight(mob/living/carbon/organ_owner)
	organ_owner ||= owner
	if(isnull(organ_owner))
		return

	fly?.Remove(organ_owner)
	if(HAS_TRAIT_FROM(organ_owner, TRAIT_MOVE_FLOATING, SPECIES_FLIGHT_TRAIT))
		toggle_flight(organ_owner)

	if(flight_level <= WINGS_FLIGHTLESS)
		return
	if(QDELETED(fly))
		fly = new
	fly.Grant(organ_owner)

/obj/item/organ/wings/on_life(delta_time)
	. = ..()
	handle_flight(owner)

///Called on_life(). Handle flight code and check if we're still flying
/obj/item/organ/wings/proc/handle_flight(mob/living/carbon/human/human)
	if(!HAS_TRAIT_FROM(human, TRAIT_MOVE_FLOATING, SPECIES_FLIGHT_TRAIT))
		return FALSE
	if(!can_fly(human))
		toggle_flight(human)
		return FALSE
	return TRUE

///Check if we're still eligible for flight (wings covered, atmosphere too thin, etc)
/obj/item/organ/wings/proc/can_fly(mob/living/carbon/human/human)
	if(human.stat || human.body_position == LYING_DOWN)
		return FALSE
	if(flight_level < WINGS_AIRWORTHY) //Them wings are useless!
		return FALSE
	//Jumpsuits have tail holes, so it makes sense they have wing holes too
	var/datum/bodypart_overlay/mutant/wings/wing_overlay = bodypart_overlay
	if(!cant_hide && wing_overlay && (human.obscured_slots  & wing_overlay.slot_blocker) && !is_type_in_list(src, human.wear_suit?.species_exception))
		to_chat(human, span_warning("Your suit blocks your wings from extending!"))
		return FALSE
	var/turf/location = get_turf(human)
	if(!location)
		return FALSE
	if(flight_level < WINGS_MAGIC)
		var/datum/gas_mixture/environment = location.return_air()
		if(environment?.return_pressure() < HAZARD_LOW_PRESSURE + 10)
			to_chat(human, span_warning("The atmosphere is too thin for you to fly!"))
			return FALSE
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
	if(!HAS_TRAIT_FROM(human, TRAIT_MOVE_FLOATING, SPECIES_FLIGHT_TRAIT))
		human.physiology.stun_mod *= 2
		human.add_traits(list(TRAIT_MOVE_FLOATING, TRAIT_IGNORING_GRAVITY), SPECIES_FLIGHT_TRAIT)
		human.add_movespeed_modifier(/datum/movespeed_modifier/jetpack/wings)
		human.AddElement(/datum/element/forced_gravity, 0)
		passtable_on(human, SPECIES_FLIGHT_TRAIT)
		open_wings()
		to_chat(human, span_notice("You beat your wings and begin to hover gently above the ground..."))
		human.set_resting(FALSE, TRUE)
		human.refresh_gravity()
		return

	human.physiology.stun_mod *= 0.5
	human.remove_traits(list(TRAIT_MOVE_FLOATING, TRAIT_IGNORING_GRAVITY), SPECIES_FLIGHT_TRAIT)
	human.remove_movespeed_modifier(/datum/movespeed_modifier/jetpack/wings)
	human.RemoveElement(/datum/element/forced_gravity, 0)
	passtable_off(human, SPECIES_FLIGHT_TRAIT)
	to_chat(human, span_notice("You settle gently back onto the ground..."))
	close_wings()
	human.refresh_gravity()

///Spread wings
/obj/item/organ/wings/proc/open_wings()
	wings_open = TRUE
	if(has_open_sprite)
		var/datum/bodypart_overlay/mutant/wings/overlay = bodypart_overlay
		overlay?.open_wings()
		owner.update_body_parts()
	SEND_SIGNAL(src, COMSIG_WINGS_OPENED, owner)

///Close wings
/obj/item/organ/wings/proc/close_wings()
	wings_open = FALSE
	if(has_open_sprite)
		var/datum/bodypart_overlay/mutant/wings/overlay = bodypart_overlay
		overlay?.close_wings()
		owner.update_body_parts()
	if(isturf(owner?.loc))
		var/turf/location = owner.loc
		location.Entered(owner, NONE)
	SEND_SIGNAL(src, COMSIG_WINGS_CLOSED, owner)

///hud action for starting and stopping flight
/datum/action/innate/flight
	name = "Toggle Flight"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_IMMOBILE|AB_CHECK_INCAPACITATED
	button_icon = 'icons/hud/actions/actions_items.dmi'
	button_icon_state = "flight"

/datum/action/innate/flight/on_activate()
	var/mob/living/carbon/human/human = owner
	var/obj/item/organ/wings/wings = human.get_organ_slot(ORGAN_SLOT_EXTERNAL_WINGS)
	if(wings?.can_fly(human))
		wings.toggle_flight(human)

///Bodypart overlay of default wings. Does not have any wing functionality
/datum/bodypart_overlay/mutant/wings
	layers = ALL_EXTERNAL_OVERLAYS
	feature_key = FEATURE_WINGS
	///Are our wings currently open? Change through open_wings or close_wings()
	VAR_PRIVATE/wings_open = FALSE
	/// Slot we check against
	var/slot_blocker = HIDEJUMPSUIT|HIDEMUTWINGS

/datum/bodypart_overlay/mutant/wings/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner, mob/living/carbon/owner, is_husked = FALSE)
	return ..() && !(bodypart_owner.owner?.obscured_slots  & slot_blocker)

/datum/bodypart_overlay/mutant/wings/get_global_feature_list()
	if(wings_open)
		return GLOB.wings_open_list
	else
		return GLOB.wings_list

///Update our wingsprite to the open wings variant
/datum/bodypart_overlay/mutant/wings/proc/open_wings()
	wings_open = TRUE
	feature_key = FEATURE_WINGS_OPEN
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

///fly wings, which relate to flies.
/obj/item/organ/wings/fly
	name = "fly wings"
	desc = "Fly as a fly."
	sprite_accessory_override = /datum/sprite_accessory/wings/fly
	//flight_level = WINGS_COSMETIC

///Bee wings with special dash ability
/obj/item/organ/wings/bee
	name = "pair of bee wings"
	desc = "A pair of bee wings."
	icon_state = "beewings"
	flight_level = WINGS_FLIGHTLESS
	actions_types = list(/datum/action/item_action/organ_action/use/bee_dash)
	sprite_accessory_override = /datum/sprite_accessory/wings/bee
	var/jumpdist = 3

/obj/item/organ/wings/bee/make_flap_sound(mob/living/carbon/wing_owner)
	playsound(wing_owner, 'sound/emotes/moth/moth_flutter.ogg', 50, TRUE)

/datum/action/item_action/organ_action/use/bee_dash
	name = "Bee Dash"
	check_flags = AB_CHECK_IMMOBILE | AB_CHECK_CONSCIOUS | AB_CHECK_HANDS_BLOCKED
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
	sprite_accessory_override = /datum/sprite_accessory/wings/robot
	flap_sound = 'sound/items/change_jaws.ogg'

/obj/item/organ/wings/cybernetic/emp_act(severity)
	. = ..()
	if(owner && (organ_flags & ORGAN_ROBOTIC))
		fly_slip(owner)

///Advanced alien wings that don't need atmosphere
/obj/item/organ/wings/cybernetic/ayy
	name = "advanced cybernetic wingpack"
	desc = "A compact pair of mechanical wings. They are equipped with miniaturized void engines, and can fly in any atmosphere, or lack thereof."
	flight_level = WINGS_MAGIC
