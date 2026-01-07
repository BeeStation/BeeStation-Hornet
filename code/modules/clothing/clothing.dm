#define SENSORS_OFF 0
#define SENSORS_BINARY 1
#define SENSORS_VITALS 2
#define SENSORS_TRACKING 3
#define SENSOR_CHANGE_DELAY 1.5 SECONDS

#define MOTH_EATING_CLOTHING_DAMAGE 15

/obj/item/clothing
	name = "clothing"
	resistance_flags = FLAMMABLE
	max_integrity = 200
	integrity_failure = 0.4
	custom_price = 20 // Basic costum price for clothing. If it does not fit anything else.
	max_demand = 15 // Demand shouldn't be too big for clothing or else you can just sell clothing like crazy
	var/damaged_clothes = CLOTHING_PRISTINE //similar to machine's BROKEN stat and structure's broken var
	var/flash_protect = FLASH_PROTECTION_NONE 		//What level of bright light protection item has. 1 = Flashers, Flashes, & Flashbangs | 2 = Welding | -1 = OH GOD WELDING BURNT OUT MY RETINAS
	var/bang_protect = 0		//what level of sound protection the item has. 1 is the level of a normal bowman.
	var/tint = 0				//Sets the item's level of visual impairment tint, normally set to the same as flash_protect
	var/up = 0					//but separated to allow items to protect but not impair vision, like space helmets
	var/visor_flags = 0			//flags that are added/removed when an item is adjusted up/down
	var/visor_flags_inv = 0		//same as visor_flags, but for flags_inv
	var/visor_flags_cover = 0	//same as above, but for flags_cover
//what to toggle when toggled with weldingvisortoggle()
	var/visor_vars_to_toggle = VISOR_FLASHPROTECT | VISOR_TINT | VISOR_VISIONFLAGS | VISOR_DARKNESSVIEW | VISOR_INVISVIEW
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'
	var/alt_desc = null
	var/cooldown = 0
	var/envirosealed = FALSE //is it safe for plasmamen

	var/clothing_flags = NONE

	/// What items can be consumed to repair this clothing (must by an /obj/item/stack)
	var/repairable_by = /obj/item/stack/sheet/cotton/cloth

	var/can_be_bloody = TRUE

	//Var modification - PLEASE be careful with this I know who you are and where you live
	var/list/user_vars_to_edit //VARNAME = VARVALUE eg: "name" = "butts"
	var/list/user_vars_remembered //Auto built by the above + dropped() + equipped()

	/// Trait modification, lazylist of traits to add/take away, on equipment/drop in the correct slot

	/// Trait modification, lazylist of traits to add/take away, on equipment/drop in the correct slot
	var/list/clothing_traits
	//These allow head/mask items to dynamically alter the user's hair
	// and facial hair, checking hair_extensions.dmi and facialhair_extensions.dmi
	// for a state matching hair_state+dynamic_hair_suffix
	// THESE OVERRIDE THE HIDEHAIR FLAGS
	var/dynamic_hair_suffix = ""//head > mask for head hair
	var/dynamic_fhair_suffix = ""//mask > head for facial hair

	var/high_pressure_multiplier = 1
	var/static/list/high_pressure_multiplier_types = list(MELEE, BULLET, LASER, ENERGY, BOMB)

	/// How much clothing damage has been dealt to each of the limbs of the clothing, assuming it covers more than one limb
	var/list/damage_by_parts
	/// How much integrity is in a specific limb before that limb is disabled (for use in [/obj/item/clothing/proc/take_damage_zone], and only if we cover multiple zones.) Set to 0 to disable shredding.
	var/limb_integrity = 0
	/// How many zones (body parts, not precise) we have disabled so far, for naming purposes
	var/zones_disabled

	/// A lazily initiated "food" version of the clothing for moths
	var/obj/item/food/clothing/moth_snack

/obj/item/clothing/Initialize(mapload)
	if(clothing_flags & VOICEBOX_TOGGLABLE)
		actions_types += /datum/action/item_action/toggle_voice_box
	. = ..()
	if(can_be_bloody && ((body_parts_covered & FEET) || (flags_inv & HIDESHOES)))
		LoadComponent(/datum/component/bloodysoles)

	if(!icon_state)
		item_flags |= ABSTRACT

/obj/item/clothing/MouseDrop(atom/over_object)
	. = ..()
	var/mob/M = usr

	if(ismecha(M.loc)) // stops inventory actions in a mech
		return

	if(!M.incapacitated() && loc == M && istype(over_object, /atom/movable/screen/inventory/hand))
		var/atom/movable/screen/inventory/hand/H = over_object
		if(M.putItemFromInventoryInHandIfPossible(src, H.held_index))
			add_fingerprint(usr)

/obj/item/food/clothing // fuck you
	name = "temporary moth clothing snack item"
	desc = "If you're reading this it means I messed up. This is related to moths eating clothes and I didn't know a better way to do it than making a new food object." // die
	bite_consumption = 1
	// sigh, ok, so it's not ACTUALLY infinite nutrition. this is so you can eat clothes more than...once.
	// bite_consumption limits how much you actually get, and the take_damage in after eat makes sure you can't abuse this.
	// ...maybe this was a mistake after all.
	food_reagents = list(/datum/reagent/consumable/nutriment/cloth = INFINITY)
	tastes = list("dust" = 1, "lint" = 1)
	foodtypes = CLOTH

	/// A weak reference to the clothing that created us
	var/datum/weakref/clothing

/obj/item/food/clothing/make_edible()
	AddComponent(/datum/component/edible,\
		initial_reagents = food_reagents,\
		food_flags = food_flags,\
		foodtypes = foodtypes,\
		volume = max_volume,\
		eat_time = eat_time,\
		tastes = tastes,\
		eatverbs = eatverbs,\
		bite_consumption = bite_consumption,\
		microwaved_type = microwaved_type,\
		junkiness = junkiness,\
		after_eat = CALLBACK(src, PROC_REF(after_eat)))

/obj/item/food/clothing/proc/after_eat(mob/eater)
	var/resolved_item = clothing.resolve()

	if(istype(resolved_item, /obj/item/clothing))
		var/obj/item/clothing/resolved_clothing = resolved_item
		resolved_clothing.take_damage(MOTH_EATING_CLOTHING_DAMAGE, sound_effect = FALSE, damage_flag = CONSUME)
		return
	else if(istype(resolved_item, /obj/item/stack/sheet))
		var/obj/item/stack/sheet/resolved_stack = resolved_item
		if(resolved_stack.amount > 1)
			resolved_stack.amount-- //Each bite removes one from the stack.
			return
	qdel(resolved_item)

/obj/item/clothing/attack(mob/living/target, mob/living/user, params)
	if(user.combat_mode)
		return //combat mode doesnt eat
	var/obj/item/organ/tongue/tongue = target.get_organ_slot(ORGAN_SLOT_TONGUE)
	if(!istype(tongue, /obj/item/organ/tongue/moth) && !istype(tongue, /obj/item/organ/tongue/psyphoza))
		return ..() //Not a clotheater tongue? No Clotheating!
	if((clothing_flags & NOTCONSUMABLE) && (resistance_flags & INDESTRUCTIBLE) && (get_armor_rating(MELEE) != 0))
		return ..() //Any remaining flags that make eating it impossible?

	if (isnull(moth_snack))
		moth_snack = new
		moth_snack.name = name
		moth_snack.clothing = WEAKREF(src)
	moth_snack.attack(target, user, params)

/obj/item/clothing/attackby(obj/item/W, mob/user, params)
	if(!istype(W, repairable_by))
		return ..()

	switch(damaged_clothes)
		if(CLOTHING_PRISTINE)
			return..()
		if(CLOTHING_DAMAGED)
			var/obj/item/stack/cloth_repair = W
			cloth_repair.use(1)
			repair(user, params)
			return TRUE
		if(CLOTHING_SHREDDED)
			var/obj/item/stack/cloth_repair = W
			if(cloth_repair.amount < 3)
				to_chat(user, span_warning("You require 3 [cloth_repair.name] to repair [src]."))
				return TRUE
			to_chat(user, span_notice("You begin fixing the damage to [src] with [cloth_repair]..."))
			if(!do_after(user, 6 SECONDS, src) || !cloth_repair.use(3))
				return TRUE
			repair(user, params)
			return TRUE

	return ..()

/// Set the clothing's integrity back to 100%, remove all damage to bodyparts, and generally fix it up
/obj/item/clothing/proc/repair(mob/user, params)
	update_clothes_damaged_state(CLOTHING_PRISTINE)
	atom_integrity = max_integrity
	name = initial(name) // remove "tattered" or "shredded" if there's a prefix
	body_parts_covered = initial(body_parts_covered)
	slot_flags = initial(slot_flags)
	damage_by_parts = null
	if(user)
		UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
		to_chat(user, span_notice("You fix the damage on [src]."))
	update_appearance()

/**
  * take_damage_zone() is used for dealing damage to specific bodyparts on a worn piece of clothing, meant to be called from [/obj/item/bodypart/proc/check_woundings_mods()]
  *
  *	This proc only matters when a bodypart that this clothing is covering is harmed by a direct attack (being on fire or in space need not apply), and only if this clothing covers
  * more than one bodypart to begin with. No point in tracking damage by zone for a hat, and I'm not cruel enough to let you fully break them in a few shots.
  * Also if limb_integrity is 0, then this clothing doesn't have bodypart damage enabled so skip it.
  *
  * Arguments:
  * * def_zone: The bodypart zone in question
  * * damage_amount: Incoming damage
  * * damage_type: BRUTE or BURN
  * * armour_penetration: If the attack had armour_penetration
  */
/obj/item/clothing/proc/take_damage_zone(def_zone, damage_amount, damage_type, armour_penetration)
	if(!def_zone || !limb_integrity || (initial(body_parts_covered) in GLOB.bitflags)) // the second check sees if we only cover one bodypart anyway and don't need to bother with this
		return
	var/list/covered_limbs = body_parts_covered2organ_names(body_parts_covered) // what do we actually cover?
	if(!(def_zone in covered_limbs))
		return

	var/damage_dealt = take_damage(damage_amount * 0.1, damage_type, armour_penetration, FALSE) * 10 // only deal 10% of the damage to the general integrity damage, then multiply it by 10 so we know how much to deal to limb
	LAZYINITLIST(damage_by_parts)
	damage_by_parts[def_zone] += damage_dealt
	if(damage_by_parts[def_zone] > limb_integrity)
		disable_zone(def_zone, damage_type)

/**
  * disable_zone() is used to disable a given bodypart's protection on our clothing item, mainly from [/obj/item/clothing/proc/take_damage_zone()]
  *
  * This proc disables all protection on the specified bodypart for this piece of clothing: it'll be as if it doesn't cover it at all anymore (because it won't!)
  * If every possible bodypart has been disabled on the clothing, we put it out of commission entirely and mark it as shredded, whereby it will have to be repaired in
  * order to equip it again. Also note we only consider it damaged if there's more than one bodypart disabled.
  *
  * Arguments:
  * * def_zone: The bodypart zone we're disabling
  * * damage_type: Only really relevant for the verb for describing the breaking, and maybe obj_destruction()
  */
/obj/item/clothing/proc/disable_zone(def_zone, damage_type)
	var/list/covered_limbs = body_parts_covered2organ_names(body_parts_covered)
	if(!(def_zone in covered_limbs))
		return

	var/zone_name = parse_zone(def_zone)
	var/break_verb = ((damage_type == BRUTE) ? "torn" : "burned")

	if(iscarbon(loc))
		var/mob/living/carbon/C = loc
		C.visible_message(span_danger("The [zone_name] on [C]'s [src.name] is [break_verb] away!"), span_userdanger("The [zone_name] on your [src.name] is [break_verb] away!"), vision_distance = COMBAT_MESSAGE_RANGE)
		RegisterSignal(C, COMSIG_MOVABLE_MOVED, PROC_REF(bristle))

	zones_disabled++
	body_parts_covered &= ~body_zone2cover_flags(def_zone)

	if(body_parts_covered == NONE) // if there are no more parts to break then the whole thing is kaput
		atom_destruction((damage_type == BRUTE ? MELEE : LASER)) // melee/laser is good enough since this only procs from direct attacks anyway and not from fire/bombs
		return

	switch(zones_disabled)
		if(1)
			name = "damaged [initial(name)]"
		if(2)
			name = "mangy [initial(name)]"
		if(3 to INFINITY) // take better care of your shit, dude
			name = "tattered [initial(name)]"

	update_clothes_damaged_state(CLOTHING_DAMAGED)
	update_appearance()

/obj/item/clothing/Destroy()
	user_vars_remembered = null //Oh god somebody put REFERENCES in here? not to worry, we'll clean it up
	QDEL_NULL(moth_snack)
	return ..()

/obj/item/clothing/dropped(mob/user)
	..()
	if(!istype(user))
		return
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	for(var/trait in clothing_traits)
		REMOVE_TRAIT(user, trait, "[CLOTHING_TRAIT] [REF(src)]")

	if(LAZYLEN(user_vars_remembered))
		for(var/variable in user_vars_remembered)
			if(variable in user.vars)
				if(user.vars[variable] == user_vars_to_edit[variable]) //Is it still what we set it to? (if not we best not change it)
					user.vars[variable] = user_vars_remembered[variable]
		user_vars_remembered = initial(user_vars_remembered) // Effectively this sets it to null.

/obj/item/clothing/equipped(mob/user, slot)
	. = ..()
	if (!istype(user))
		return
	if(slot_flags & slot) //Was equipped to a valid slot for this item?
		if(iscarbon(user) && LAZYLEN(zones_disabled))
			RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(bristle))
		for(var/trait in clothing_traits)
			ADD_TRAIT(user, trait, "[CLOTHING_TRAIT] [REF(src)]")
		if (LAZYLEN(user_vars_to_edit))
			for(var/variable in user_vars_to_edit)
				if(variable in user.vars)
					LAZYSET(user_vars_remembered, variable, user.vars[variable])
					user.vv_edit_var(variable, user_vars_to_edit[variable])

// If the item is a piece of clothing and is being worn, make sure it updates on the player
/obj/item/clothing/update_greyscale()
	. = ..()

	var/mob/living/carbon/human/wearer = loc

	if(!istype(wearer))
		return

	wearer.update_clothing(slot_flags)

/obj/item/clothing/examine(mob/user)
	. = ..()
	if(damaged_clothes == CLOTHING_SHREDDED)
		. += span_warning("<b>[p_Theyre()] completely shredded and require[p_s()] mending before [p_they()] can be worn again!</b>")
		return

	for(var/zone in damage_by_parts)
		var/pct_damage_part = damage_by_parts[zone] / limb_integrity * 100
		var/zone_name = parse_zone(zone)
		switch(pct_damage_part)
			if(100 to INFINITY)
				. += span_warning("<b>The [zone_name] is useless and requires mending!</b>")
			if(60 to 99)
				. += span_warning("The [zone_name] is heavily shredded!")
			if(30 to 59)
				. += span_warning("The [zone_name] is partially shredded.")

	if(atom_storage)
		var/list/how_cool_are_your_threads = list("<span class='notice'>")
		if(atom_storage.attack_hand_interact)
			how_cool_are_your_threads += "[src]'s storage opens when clicked.\n"
		else
			how_cool_are_your_threads += "[src]'s storage opens when dragged to yourself.\n"
		if (atom_storage.can_hold?.len) // If pocket type can hold anything, vs only specific items
			how_cool_are_your_threads += "[src] can store [atom_storage.max_slots] item\s.\n"
		else
			how_cool_are_your_threads += "[src] can store [atom_storage.max_slots] item\s that are [weight_class_to_text(atom_storage.max_specific_storage)] or smaller.\n"
		if(atom_storage.quickdraw)
			how_cool_are_your_threads += "You can quickly remove an item from [src] using Right-Click.\n"
		if(atom_storage.silent)
			how_cool_are_your_threads += "Adding or removing items from [src] makes no noise.\n"
		how_cool_are_your_threads += "</span>"
		. += how_cool_are_your_threads.Join()

	if(get_armor().has_any_armor() || (flags_cover & (HEADCOVERSMOUTH)) || (clothing_flags & STOPSPRESSUREDAMAGE) || (visor_flags & STOPSPRESSUREDAMAGE))
		. += span_notice("It has a <a href='byond://?src=[REF(src)];list_armor=1'>tag</a> listing its protection classes.")

/obj/item/clothing/examine_tags(mob/user)
	. = ..()
	if (clothing_flags & THICKMATERIAL)
		.["thick"] = "Extremely thick, protecting from piercing injections and sprays."
	else if (get_armor().get_rating(MELEE) >= 20 || get_armor().get_rating(BULLET) >= 20)
		.["rigid"] = "Protects from some injections and sprays."
	if (clothing_flags & CASTING_CLOTHES)
		.["magical"] = "Allows magical beings to cast spells when wearing [src]."
	if((clothing_flags & STOPSPRESSUREDAMAGE) || (visor_flags & STOPSPRESSUREDAMAGE))
		.["pressureproof"] = "Protects the wearer from extremely low or high pressure, such as vacuum of space."
	//if(flags_cover & PEPPERPROOF)
	//	.["pepperproof"] = "Protects the wearer from the effects of pepperspray."
	if (heat_protection || cold_protection)
		var/heat_desc
		var/cold_desc
		switch (max_heat_protection_temperature)
			if (400 to 1000)
				heat_desc = "high"
			if (1001 to 1600)
				heat_desc = "very high"
			if (1601 to 35000)
				heat_desc = "extremely high"
		switch (min_cold_protection_temperature)
			if (160 to 272)
				cold_desc = "low"
			if (72 to 159)
				cold_desc = "very low"
			if (0 to 71)
				cold_desc = "extremely low"
		.["thermally insulated"] = "Protects the wearer from [jointext(list(heat_desc, cold_desc), " and ")] temperatures."

/obj/item/clothing/examine_descriptor(mob/user)
	return "clothing"

/obj/item/clothing/Topic(href, href_list)
	. = ..()

	if(href_list["list_armor"])
		var/obj/item/clothing/compare_to = null
		for (var/flag in bitfield_to_list(slot_flags))
			var/thing = usr.get_item_by_slot(flag)
			if (istype(thing, /obj/item/clothing))
				compare_to = thing
				break
		to_chat(usr, examine_block("[generate_armor_readout(compare_to)]"))

/obj/item/clothing/proc/generate_armor_readout(obj/item/clothing/compare_to)
	var/list/readout = list("<span class='notice'><u><b>PROTECTION CLASSES</u></b>")

	var/datum/armor/armor = get_armor()
	var/datum/armor/compare_armor = compare_to ? compare_to.get_armor() : null

	var/added_damage_header = FALSE
	for(var/damage_key in ARMOR_LIST_DAMAGE)
		var/rating = armor.get_rating(damage_key)
		var/compare_rating = compare_armor ? compare_armor.get_rating(damage_key) : null
		if(!rating && !compare_rating)
			continue
		if(!added_damage_header)
			readout += "\n<b>ARMOR (I-X)</b>"
			added_damage_header = TRUE
		readout += "\n[armor_to_protection_name(damage_key)] [armor_to_protection_class(rating, compare_rating)]"

	var/added_durability_header = FALSE
	for(var/durability_key in ARMOR_LIST_DURABILITY)
		var/rating = armor.get_rating(durability_key)
		var/compare_rating = compare_armor ? compare_armor.get_rating(durability_key) : null
		if(!rating && !compare_rating)
			continue
		if(!added_durability_header)
			readout += "\n<b>DURABILITY (I-X)</b>"
			added_durability_header = TRUE
		readout += "\n[armor_to_protection_name(durability_key)] [armor_to_protection_class(rating, compare_rating)]"

	if(flags_cover & HEADCOVERSMOUTH)
		var/list/things_blocked = list()
		if(flags_cover & HEADCOVERSMOUTH)
			things_blocked += span_tooltip("Because this item is worn on the head and is covering the mouth, it will block facehugger proboscides, killing facehuggers.", "facehuggers")
		if(length(things_blocked))
			readout += "<br /><b>COVERAGE</b>"
			readout += "\nIt will block [english_list(things_blocked)]."

	if((clothing_flags & STOPSPRESSUREDAMAGE) || (visor_flags & STOPSPRESSUREDAMAGE))
		var/list/parts_covered = list()
		var/output_string = "It"
		if(!(clothing_flags & STOPSPRESSUREDAMAGE))
			output_string = "When sealed, it"
		if(body_parts_covered & HEAD)
			parts_covered += "head"
		if(body_parts_covered & CHEST)
			parts_covered += "torso"
		if(length(parts_covered)) // Just in case someone makes spaceproof gloves or something
			readout += "\n[output_string] will protect the wearer's [english_list(parts_covered)] from [span_tooltip("The extremely low pressure is the biggest danger posed by the vacuum of space.", "low pressure")]."

	var/heat_prot
	switch (max_heat_protection_temperature)
		if (400 to 1000)
			heat_prot = "minor"
		if (1001 to 1600)
			heat_prot = "some"
		if (1601 to 35000)
			heat_prot = "extreme"
	if (heat_prot)
		. += "[src] offers the wearer [heat_protection] protection from heat, up to [max_heat_protection_temperature] kelvin."

	if(min_cold_protection_temperature)
		readout += "\nIt will insulate the wearer from [min_cold_protection_temperature <= SPACE_SUIT_MIN_TEMP_PROTECT ? span_tooltip("While not as dangerous as the lack of pressure, the extremely low temperature of space is also a hazard.", "the cold of space, down to [min_cold_protection_temperature] kelvin") : "cold, down to [min_cold_protection_temperature] kelvin"]."

	readout += "</span>"

	return readout.Join()

/**
 * Rounds armor_value down to the nearest 10, divides it by 10 and then converts it to Roman numerals.
 *
 * Arguments:
 * * armor_value - Number we're converting
 */
/obj/item/clothing/proc/armor_to_protection_class(armor_value, compare_value)
	if (armor_value < 0)
		. = "-"
	if (armor_value == 0)
		. += "None"
	else
		. += "\Roman[round(abs(armor_value), 10) / 10]"
	if (!isnull(compare_value))
		if (armor_value > compare_value)
			. = span_green("[.]")
		else if (armor_value < compare_value)
			. = span_red("[.]")

/obj/item/clothing/atom_break(damage_flag)
	. = ..()
	update_clothes_damaged_state(CLOTHING_DAMAGED)

	if(isliving(loc)) //It's not important enough to warrant a message if it's not on someone
		var/mob/living/M = loc
		if(src in M.get_equipped_items(FALSE))
			to_chat(M, span_warning("Your [name] start[p_s()] to fall apart!"))
		else
			to_chat(M, span_warning("[src] start[p_s()] to fall apart!"))


//This mostly exists so subtypes can call appriopriate update icon calls on the wearer.
/obj/item/clothing/proc/update_clothes_damaged_state(damaged_state = CLOTHING_DAMAGED)
	damaged_clothes = damaged_state

/obj/item/clothing/update_overlays()
	. = ..()
	if(!damaged_clothes)
		return

	var/index = "[REF(icon)]-[icon_state]"
	var/static/list/damaged_clothes_icons = list()
	var/icon/damaged_clothes_icon = damaged_clothes_icons[index]
	if(!damaged_clothes_icon)
		damaged_clothes_icon = icon(icon, icon_state, , 1)
		damaged_clothes_icon.Blend("#fff", ICON_ADD) //fills the icon_state with white (except where it's transparent)
		damaged_clothes_icon.Blend(icon('icons/effects/item_damage.dmi', "itemdamaged"), ICON_MULTIPLY) //adds damage effect and the remaining white areas become transparant
		damaged_clothes_icon = fcopy_rsc(damaged_clothes_icon)
		damaged_clothes_icons[index] = damaged_clothes_icon
	. += damaged_clothes_icon


/*
SEE_SELF  // can see self, no matter what
SEE_MOBS  // can see all mobs, no matter what
SEE_OBJS  // can see all objs, no matter what
SEE_TURFS // can see all turfs (and areas), no matter what
SEE_PIXELS// if an object is located on an unlit area, but some of its pixels are
		// in a lit area (via pixel_x,y or smooth movement), can see those pixels
BLIND	 // can't see anything
*/

/proc/generate_female_clothing(index,t_color,icon,type)
	var/icon/female_clothing_icon = icon("icon"=icon, "icon_state"=t_color)
	var/female_icon_state = "female[type == FEMALE_UNIFORM_FULL ? "_full" : ((!type || type & FEMALE_UNIFORM_TOP_ONLY) ? "_top" : "")][type & FEMALE_UNIFORM_NO_BREASTS ? "_no_breasts" : ""]"
	var/icon/female_cropping_mask = icon("icon" = 'icons/mob/clothing/under/masking_helpers.dmi', "icon_state" = female_icon_state)
	female_clothing_icon.Blend(female_cropping_mask, ICON_MULTIPLY)
	female_clothing_icon = fcopy_rsc(female_clothing_icon)
	GLOB.female_clothing_icons[index] = female_clothing_icon

/obj/item/clothing/under/proc/set_sensors(mob/user)
	var/mob/M = user
	if(M.stat)
		return
	if(!can_use(M))
		return
	if(src.has_sensor == LOCKED_SENSORS)
		to_chat(user, span_warning("The controls are locked."))
		return FALSE
	if(src.has_sensor == BROKEN_SENSORS)
		to_chat(user, span_warning("The sensors have shorted out!"))
		return FALSE
	if(src.has_sensor <= NO_SENSORS)
		to_chat(user, span_warning("This suit does not have any sensors."))
		return FALSE

	var/list/modes = list("Off", "Binary vitals", "Exact vitals", "Tracking beacon")
	var/switchMode = tgui_input_list(M, "Select a sensor mode", "Suit Sensors", modes, modes[sensor_mode + 1])
	if(isnull(switchMode))
		return
	if(get_dist(user, src) > 1)
		to_chat(user, span_warning("You have moved too far away!"))
		return

	var/sensor_selection = modes.Find(switchMode) - 1
	if (src.loc == user)
		switch(sensor_selection)
			if(SENSORS_OFF)
				to_chat(user, span_notice("You disable your suit's remote sensing equipment."))
			if(SENSORS_BINARY)
				to_chat(user, span_notice("Your suit will now only report whether you are alive or dead."))
			if(SENSORS_VITALS)
				to_chat(user, span_notice("Your suit will now only report your exact vital lifesigns."))
			if(SENSORS_TRACKING)
				to_chat(user, span_notice("Your suit will now report your exact vital lifesigns as well as your coordinate position."))
		update_sensors(sensor_selection)
	else if(istype(src.loc, /mob))
		var/mob/living/carbon/human/wearer = src.loc
		wearer.visible_message(span_notice("[user] tries to set [wearer]'s sensors."), \
						span_warning("[user] is trying to set your sensors."), null, COMBAT_MESSAGE_RANGE)
		if(do_after(user, SENSOR_CHANGE_DELAY, wearer))
			switch(sensor_selection)
				if(SENSORS_OFF)
					wearer.visible_message(span_warning("[user] disables [wearer]'s remote sensing equipment."), \
						span_warning("[user] disables your remote sensing equipment."), null, COMBAT_MESSAGE_RANGE)
				if(SENSORS_BINARY)
					wearer.visible_message(span_notice("[user] turns [wearer]'s remote sensors to binary."), \
						span_notice("[user] turns your remote sensors to binary."), null, COMBAT_MESSAGE_RANGE)
				if(SENSORS_VITALS)
					wearer.visible_message(span_notice("[user] turns [wearer]'s remote sensors to track vitals."), \
						span_notice("[user] turns your remote sensors to track vitals."), null, COMBAT_MESSAGE_RANGE)
				if(SENSORS_TRACKING)
					wearer.visible_message(span_notice("[user] turns [wearer]'s remote sensors to maximum."), \
						span_notice("[user] turns your remote sensors to maximum."), null, COMBAT_MESSAGE_RANGE)
			update_sensors(sensor_selection)
			log_combat(user, wearer, "changed sensors to [switchMode]")
	if(ishuman(loc) || ismonkey(loc))
		var/mob/living/carbon/human/H = loc
		if(H.w_uniform == src)
			H.update_suit_sensors()

/obj/item/clothing/proc/weldingvisortoggle(mob/user) //proc to toggle welding visors on helmets, masks, goggles, etc.
	if(!can_use(user))
		return FALSE

	visor_toggling()

	to_chat(user, span_notice("You adjust \the [src] [up ? "up" : "down"]."))

	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.head_update(src, forced = TRUE)
	update_action_buttons()
	return TRUE

/obj/item/clothing/proc/visor_toggling() //handles all the actual toggling of flags
	up = !up
	clothing_flags ^= visor_flags
	flags_inv ^= visor_flags_inv
	flags_cover ^= initial(flags_cover)
	icon_state = "[initial(icon_state)][up ? "up" : ""]"
	if(visor_vars_to_toggle & VISOR_FLASHPROTECT)
		flash_protect ^= initial(flash_protect)
	if(visor_vars_to_toggle & VISOR_TINT)
		tint ^= initial(tint)

/obj/item/clothing/head/helmet/space/plasmaman/visor_toggling() //handles all the actual toggling of flags
	up = !up
	clothing_flags ^= visor_flags
	flags_inv ^= visor_flags_inv
	icon_state = "[initial(icon_state)]"
	if(visor_vars_to_toggle & VISOR_FLASHPROTECT)
		flash_protect ^= initial(flash_protect)
	if(visor_vars_to_toggle & VISOR_TINT)
		tint ^= initial(tint)

/obj/item/clothing/proc/can_use(mob/user)
	if(user && ismob(user))
		if(!user.incapacitated())
			return 1
	return 0

/obj/item/clothing/proc/_spawn_shreds()
	new /obj/effect/decal/cleanable/shreds(get_turf(src), name)

/obj/item/clothing/atom_destruction(damage_flag)
	if(damage_flag in list(ACID, FIRE))
		return ..()
	if(damage_flag == BOMB)
		//so the shred survives potential turf change from the explosion.
		addtimer(CALLBACK(src, PROC_REF(_spawn_shreds)), 1)
		deconstruct(FALSE)
	if(damage_flag == CONSUME) //This allows for moths to fully consume clothing, rather than damaging it like other sources like brute
		var/turf/current_position = get_turf(src)
		new /obj/effect/decal/cleanable/shreds(current_position, name)
		if(isliving(loc))
			var/mob/living/possessing_mob = loc
			possessing_mob.visible_message(span_danger("[src] is consumed until naught but shreds remains!"), span_boldwarning("[src] falls apart into little bits!"))
		deconstruct(FALSE)
	else
		body_parts_covered = NONE
		slot_flags = NONE
		update_clothes_damaged_state(CLOTHING_SHREDDED)
		if(isliving(loc))
			var/mob/living/M = loc
			if(src in M.get_equipped_items(FALSE)) //make sure they were wearing it and not attacking the item in their hands
				M.visible_message(span_danger("[M]'s [src.name] fall[p_s()] off, [p_theyre()] completely shredded!"), span_warning("<b>Your [src.name] fall[p_s()] off, [p_theyre()] completely shredded!</b>"), vision_distance = COMBAT_MESSAGE_RANGE)
				M.dropItemToGround(src)
			else
				M.visible_message(span_danger("[src] fall[p_s()] apart, completely shredded!"), vision_distance = COMBAT_MESSAGE_RANGE)
		name = "shredded [initial(name)]" // change the name -after- the message, not before.
		update_appearance()

/// If we're a clothing with at least 1 shredded/disabled zone, give the wearer a periodic heads up letting them know their clothes are damaged
/obj/item/clothing/proc/bristle(mob/living/L)
	SIGNAL_HANDLER

	if(!istype(L))
		return
	if(prob(0.2))
		to_chat(L, span_warning("The damaged threads on your [src.name] chafe!"))

/obj/item/clothing/get_armor_rating(d_type)
	. = ..()
	if(high_pressure_multiplier == 1)
		return
	var/turf/T = get_turf(src)
	if(!T || !(d_type in high_pressure_multiplier_types))
		return
	if (!is_mining_level(T.z))
		return . * high_pressure_multiplier

#undef SENSORS_OFF
#undef SENSORS_BINARY
#undef SENSORS_VITALS
#undef SENSORS_TRACKING
#undef SENSOR_CHANGE_DELAY

#undef MOTH_EATING_CLOTHING_DAMAGE
