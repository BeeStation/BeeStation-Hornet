/obj/item/stack/cable_coil
	name = "cable coil"
	singular_name = "cable piece"
	desc = "A coil of insulated power cable."

	icon = 'icons/obj/power.dmi'
	icon_state = "coil"
	inhand_icon_state = "coil"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'

	gender = NEUTER //That's a cable coil sounds better than that's some cable coils

	obj_flags = CONDUCTS_ELECTRICITY
	slot_flags = ITEM_SLOT_BELT

	w_class = WEIGHT_CLASS_SMALL
	full_w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	throw_speed = 3
	throw_range = 5
	attack_verb_continuous = list("whips", "lashes", "disciplines", "flogs")
	attack_verb_simple = list("whip", "lash", "discipline", "flog")

	custom_price = 15

	max_amount = MAXCOIL
	amount = MAXCOIL
	merge_type = /obj/item/stack/cable_coil // This is here to let its children merge between themselves
	novariants = FALSE
	usesound = 'sound/items/deconstruct.ogg'
	cost = 1
	source = /datum/robot_energy_storage/wire

	mats_per_unit = list(/datum/material/iron = 10, /datum/material/glass = 5)
	grind_results = list(/datum/reagent/copper = 2)

	var/cable_color = "white"
	var/omni = TRUE

/obj/item/stack/cable_coil/Initialize(mapload, new_amount = amount, merge = TRUE, mob/user = null, param_color = null, param_omni = FALSE)
	if (param_color && !param_omni)
		cable_color = param_color
		omni = FALSE
	pixel_x = base_pixel_x + rand(-2,2)
	pixel_y = base_pixel_y + rand(-2,2)
	update_appearance(UPDATE_ICON)
	return ..()

#define OMNI_CABLE "Omni"
#define CABLE_TIES "Cable Ties"

/obj/item/stack/cable_coil/attack_self(mob/living/user)
	// Crafting options
	var/mutable_appearance/cable_ties = mutable_appearance('icons/obj/items_and_weapons.dmi', "cuff", color = GLOB.cable_colors[omni ? "red" : cable_color])
	cable_ties.maptext = MAPTEXT("<font color='white'>[amount]/15</font>")
	cable_ties.pixel_y = 4
	cable_ties.maptext_y = -2
	if(amount < 15)
		cable_ties.color = COLOR_SONIC_SILVER

	var/list/options = list(
		OMNI_CABLE = mutable_appearance('icons/obj/power.dmi', "omni-coil"),
		"Red" = mutable_appearance('icons/obj/power.dmi', "coil", color = GLOB.cable_colors["red"]),
		"Yellow" = mutable_appearance('icons/obj/power.dmi', "coil", color = GLOB.cable_colors["yellow"]),
		"Green" = mutable_appearance('icons/obj/power.dmi', "coil", color = GLOB.cable_colors["green"]),
		"Pink" = mutable_appearance('icons/obj/power.dmi', "coil", color = GLOB.cable_colors["pink"]),
		"Orange" = mutable_appearance('icons/obj/power.dmi', "coil", color = GLOB.cable_colors["orange"]),
		CABLE_TIES = cable_ties,
	)

	var/result = show_radial_menu(user, user, options, radius = 40, tooltips = TRUE)
	if(isnull(result))
		return

	switch(result)
		if(CABLE_TIES)
			if (!use(15))
				return
			var/obj/item/restraints/handcuffs/cable/created = new(user.loc)
			user.put_in_hands(created)
			return
		if(OMNI_CABLE)
			cable_color = "white"
			omni = TRUE
		else
			cable_color = LOWER_TEXT(result)
			omni = FALSE

	update_appearance(UPDATE_ICON_STATE | UPDATE_NAME)
	return TRUE

#undef OMNI_CABLE
#undef CABLE_TIES

/obj/item/stack/cable_coil/suicide_act(mob/living/user)
	if(locate(/obj/structure/chair/stool) in get_turf(user))
		user.visible_message(span_suicide("[user] is making a noose with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	else
		user.visible_message(span_suicide("[user] is strangling [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return OXYLOSS

/obj/item/stack/cable_coil/add_context_interaction(datum/screentip_context/context, mob/user, atom/target)
	if (isturf(target))
		context.add_left_click_action("Lay Cable")
	else
		context.add_right_click_action("Lay Cable")

CREATION_TEST_IGNORE_SUBTYPES(/obj/item/stack/cable_coil)

///////////////////////////////////
// General procedures
///////////////////////////////////

/obj/item/stack/cable_coil/update_name(updates)
	. = ..()
	if (omni)
		name = "omni-cable [amount < 3 ? "piece" : "coil"]"
	else
		name = "cable [amount < 3 ? "piece" : "coil"]"

/obj/item/stack/cable_coil/update_icon_state()
	. = ..()
	if (omni)
		icon_state = "omni-coil[amount < 3 ? amount : ""]"
		remove_atom_colour(FIXED_COLOUR_PRIORITY)
	else
		icon_state = "[initial(icon_state)][amount < 3 ? amount : ""]"
		add_atom_colour(GLOB.cable_colors[cable_color], FIXED_COLOUR_PRIORITY)

///////////////////////////////////////////////
// Cable laying procedures
//////////////////////////////////////////////

/obj/item/stack/cable_coil/attack_turf(turf/T, mob/living/user)
	place_on_turf(T, user)
	return TRUE

/obj/item/stack/cable_coil/pre_attack_secondary(atom/target, mob/living/user, params)
	place_on_turf(get_turf(target), user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/**
 * Attempts to place a cable structure on a turf. Called when we attack a turf with cable
 * Returns TRUE if a cable was placed
 */
/obj/item/stack/cable_coil/proc/place_on_turf(turf/targeted_turf, mob/user)
	// Cannot be placing from within a locker
	if(!isturf(user.loc))
		return
	if(!isturf(targeted_turf))
		return

	if(targeted_turf.underfloor_accessibility < UNDERFLOOR_INTERACTABLE || !targeted_turf.can_have_cabling())
		to_chat(user, span_warning("You can only lay cables on top of exterior catwalks and plating!"))
		return

	// Check if cable already exists on the turf
	for (var/obj/structure/cable/wire in targeted_turf)
		if (wire.cable_color != cable_color && !omni && !wire.omni)
			continue

		var/obj/structure/cable/resolved_wire = wire.resolve_ambiguous_target(user)
		if (isnull(resolved_wire))
			return

		if (resolved_wire.forced_power_node)
			to_chat(user, span_warning("There's already a cable at that position!"))
			return
		if (!use(1))
			to_chat(user, span_warning("There's no cable left!"))
			return

		to_chat(user, span_notice("You add a node to the [resolved_wire], allowing it to connect to machines and structures placed on top of it!"))
		resolved_wire.add_power_node()
		return TRUE

	// Try and link two cables between z-levels
	if (isopenspace(targeted_turf))
		var/turf/below_turf = GET_TURF_BELOW(targeted_turf)
		ASSERT(!isnull(below_turf), "Openspace exists without a turf below it.")

		// If there isn't a cable below us, make one
		if (locate(/obj/structure/cable) in below_turf)
			if (!use(1))
				to_chat(user, span_warning("There's no cable left!"))
				return
		else
			if (!use(2))
				to_chat(user, span_warning("You need at least 2 pieces of cable to wire between decks!"))
				return
			if (omni)
				new /obj/structure/cable/omni(below_turf, cable_color)
			else
				new /obj/structure/cable(below_turf, cable_color)
	else if(!use(1))
		to_chat(user, span_warning("There's no cable left!"))
		return

	if (omni)
		new /obj/structure/cable/omni(targeted_turf, cable_color)
	else
		new /obj/structure/cable(targeted_turf, cable_color)
	return TRUE

//////////////////////////////
// Misc.
/////////////////////////////

/obj/item/stack/cable_coil/cut
	amount = null
	icon_state = "coil2"
	worn_icon_state = "coil"

/obj/item/stack/cable_coil/cut/Initialize(mapload)
	if(!amount)
		amount = rand(1,2)
	. = ..()
	pixel_x = base_pixel_x + rand(-2, 2)
	pixel_y = base_pixel_y + rand(-2, 2)
	update_appearance(UPDATE_NAME | UPDATE_ICON_STATE)

/obj/item/stack/cable_coil/one
	amount = 1
