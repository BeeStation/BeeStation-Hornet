/*
April 3rd, 2014 marks the day this machine changed the face of the kitchen on NTStation13
God bless America.
*/

/// The deep fryer pings after this long, letting people know it's "perfect"
#define DEEPFRYER_COOKTIME 50
/// The deep fryer pings after this long, reminding people that there's a very burnt object inside
#define DEEPFRYER_BURNTIME 120

/// Global typecache of things which should never be fried.
GLOBAL_LIST_INIT(oilfry_blacklisted_items, typecacheof(list(
	/obj/item/reagent_containers/glass,
	/obj/item/reagent_containers/syringe,
	/obj/item/reagent_containers/food/condiment,
	/obj/item/small_delivery,
	/obj/item/his_grace,
)))

/obj/machinery/deepfryer
	name = "deep fryer"
	desc = "Deep fried <i>everything</i>."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "fryer_off"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	layer = BELOW_OBJ_LAYER
	circuit = /obj/item/circuitboard/machine/deep_fryer

	/// What's being fried RIGHT NOW?
	var/obj/item/frying
	/// How long the current object has been cooking for
	var/cook_time = 0
	/// How much cooking oil is used per process
	var/oil_use = 0.025
	/// How quickly we fry food - modifier applied per process tick
	var/fry_speed = 1
	/// Has our currently frying object been fried?
	var/frying_fried = FALSE
	/// Has our currently frying object been burnt?
	var/frying_burnt = FALSE

	/// Our sound loop for the frying sounde effect.
	var/datum/looping_sound/deep_fryer/fry_loop
	/// Static typecache of things we can't fry.
	var/static/list/deepfry_blacklisted_items = typecacheof(list(
		/obj/item/screwdriver,
		/obj/item/crowbar,
		/obj/item/wrench,
		/obj/item/wirecutters,
		/obj/item/multitool,
		/obj/item/weldingtool,
		/obj/item/powertool,
	))

/obj/machinery/deepfryer/Initialize(mapload)
	. = ..()
	create_reagents(50, OPENCONTAINER)
	reagents.add_reagent(/datum/reagent/consumable/cooking_oil, 25)
	fry_loop = new(src, FALSE)

/obj/machinery/deepfryer/Destroy()
	QDEL_NULL(fry_loop)
	QDEL_NULL(frying)
	return ..()

/obj/machinery/deepfryer/deconstruct(disassembled)
	// This handles nulling out frying via exited
	if(frying)
		frying.forceMove(drop_location())

/obj/machinery/deepfryer/RefreshParts()
	var/oil_efficiency = 0
	for(var/obj/item/stock_parts/micro_laser/laser in component_parts)
		oil_efficiency += laser.rating
	oil_use = initial(oil_use) - (oil_efficiency * 0.00475)
	fry_speed = oil_efficiency

/obj/machinery/deepfryer/examine(mob/user)
	. = ..()
	if(frying)
		. += "You can make out \a [frying] in the oil."
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>The status display reads: Frying at <b>[fry_speed*100]%</b> speed.<br>Using <b>[oil_use]</b> units of oil per second.</span>"

/obj/machinery/deepfryer/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/deepfryer/attackby(obj/item/weapon, mob/user, params)
	// Dissolving pills into the frier
	if(istype(weapon, /obj/item/reagent_containers/pill))
		if(!reagents.total_volume)
			to_chat(user, "<span class='warning'>There's nothing to dissolve [weapon] in!</span>")
			return
		user.visible_message("<span class='notice'>[user] drops [weapon] into [src].</span>", "<span class='notice'>You dissolve [weapon] in [src].</span>")
		weapon.reagents.trans_to(src, weapon.reagents.total_volume, transfered_by = user)
		qdel(weapon)
		return
	// Make sure we have cooking oil
	if(!reagents.has_reagent(/datum/reagent/consumable/cooking_oil))
		to_chat(user, "<span class='warning'>[src] has no cooking oil to fry with!</span>")
		return
	// Don't deep fry indestructible things, for sanity reasons
	if(weapon.resistance_flags & INDESTRUCTIBLE)
		to_chat(user, "<span class='warning'>You don't feel it would be wise to fry [weapon]...</span>")
		return
	// No fractal frying
	if(HAS_TRAIT(weapon, TRAIT_FOOD_FRIED))
		to_chat(user, "<span class='userdanger'>Your cooking skills are not up to the legendary Doublefry technique.</span>")
		return
	// Handle pets
	if(istype(weapon, /obj/item/clothing/head/mob_holder))
		var/obj/item/clothing/head/mob_holder/P = weapon
		QDEL_NULL(P.held_mob)	//just so the pet doesn't escape his incoming death
	// Handle opening up the fryer with tools
	if(default_deconstruction_screwdriver(user, "fryer_off", "fryer_off", weapon)) //where's the open maint panel icon?!
		return
	else
		// So we skip the attack animation
		if(weapon.is_drainable())
			return
		// Check for stuff we certainly shouldn't fry
		else if(is_type_in_typecache(weapon, deepfry_blacklisted_items) \
			|| is_type_in_typecache(weapon, GLOB.oilfry_blacklisted_items) \
			|| weapon.GetComponent(/datum/component/storage) \
			|| HAS_TRAIT(weapon, TRAIT_NODROP) \
			|| (weapon.item_flags & (ABSTRACT|DROPDEL)))
			return ..()
		// Do the frying.
		else if(!frying && user.transferItemToLoc(weapon, src))
			to_chat(user, "<span class='notice'>You put [weapon] into [src].</span>")
			log_game("[key_name(user)] deep fried [weapon.name] ([weapon.type]) at [AREACOORD(src)].")
			user.log_message("deep fried [weapon.name] ([weapon.type]) at [AREACOORD(src)].", LOG_GAME)
			start_fry(weapon, user)
			return

	return ..()

/obj/machinery/deepfryer/process(delta_time)
	..()
	var/datum/reagent/consumable/cooking_oil/frying_oil = reagents.has_reagent(/datum/reagent/consumable/cooking_oil)
	if(!frying_oil)
		return
	reagents.chem_temp = frying_oil.fry_temperature
	if(!frying)
		return

	reagents.trans_to(frying, oil_use * delta_time, multiplier = fry_speed * 3) //Fried foods gain more of the reagent thanks to space magic
	cook_time += fry_speed * delta_time
	if(cook_time >= DEEPFRYER_COOKTIME && !frying_fried)
		frying_fried = TRUE //frying... frying... fried
		playsound(src.loc, 'sound/machines/ding.ogg', 50, TRUE)
		audible_message("<span class='notice'>[src] dings!</span>")
	else if (cook_time >= DEEPFRYER_BURNTIME && !frying_burnt)
		frying_burnt = TRUE
		visible_message("<span class='warning'>[src] emits an acrid smell!</span>")

	use_power(active_power_usage)

/obj/machinery/deepfryer/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == frying)
		reset_frying()

/obj/machinery/deepfryer/handle_atom_del(atom/deleting_atom)
	. = ..()
	if(deleting_atom == frying)
		reset_frying()

/obj/machinery/deepfryer/proc/reset_frying()
	if(!QDELETED(frying))
		frying.AddElement(/datum/element/fried_item, cook_time)

	frying = null
	frying_fried = FALSE
	frying_burnt = FALSE
	fry_loop.stop()
	cook_time = 0
	icon_state = "fryer_off"

/obj/machinery/deepfryer/proc/start_fry(obj/item/frying_item, mob/user)
	to_chat(user, "<span class='notice'>You put [frying_item] into [src].</span>")

	frying = frying_item
	// Give them reagents to put frying oil in
	if(isnull(frying.reagents))
		frying.create_reagents(50, INJECTABLE)
	//ADD_TRAIT(frying, TRAIT_FOOD_CHEF_MADE, REF(user)) //Attaching behavior to if the food is made by a chef, later newfood
	SEND_SIGNAL(frying, COMSIG_ITEM_ENTERED_FRYER)

	icon_state = "fryer_on"
	fry_loop.start()

/obj/machinery/deepfryer/proc/blow_up()
	visible_message("<span class='userdanger'>[src] blows up from the entropic reaction!</span>")
	explosion(src, devastation_range = 1, heavy_impact_range = 3, light_impact_range = 5, flame_range = 7)
	deconstruct(FALSE)

/obj/machinery/deepfryer/attack_ai(mob/user)
	return

/obj/machinery/deepfryer/attack_hand(mob/user)
	if(frying)
		to_chat(user, "<span class='notice'>You eject [frying] from [src].</span>")
		frying.forceMove(drop_location())
		if(Adjacent(user) && !issilicon(user))
			user.put_in_hands(frying)
		return

	else if(user.pulling && user.a_intent == "grab" && iscarbon(user.pulling) && reagents.total_volume)
		if(user.grab_state < GRAB_AGGRESSIVE)
			to_chat(user, "<span class='warning'>You need a better grip to do that!</span>")
			return
		var/mob/living/carbon/C = user.pulling
		user.visible_message("<span class = 'danger'>[user] dunks [C]'s face in [src]!</span>")
		reagents.reaction(C, TOUCH)
		log_combat(user, C, "fryer slammed")
		var/permeability = 1 - C.get_permeability_protection(list(HEAD))
		C.apply_damage(min(30 * permeability, reagents.total_volume), BURN, BODY_ZONE_HEAD)
		reagents.remove_any((reagents.total_volume/2))
		C.Paralyze(60)
		user.changeNext_move(CLICK_CD_MELEE)
	return ..()

#undef DEEPFRYER_COOKTIME
#undef DEEPFRYER_BURNTIME
