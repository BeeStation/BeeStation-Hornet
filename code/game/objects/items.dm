GLOBAL_VAR_INIT(stickpocalypse, FALSE) // if true, all non-embeddable items will be able to harmlessly stick to people when thrown

GLOBAL_VAR_INIT(embedpocalypse, FALSE) // if true, all items will be able to embed in people, takes precedence over stickpocalypse

GLOBAL_DATUM_INIT(fire_overlay, /mutable_appearance, mutable_appearance('icons/effects/fire.dmi', "fire"))

GLOBAL_DATUM_INIT(welding_sparks, /mutable_appearance, mutable_appearance('icons/effects/welding_effect.dmi', "welding_sparks", GASFIRE_LAYER, ABOVE_LIGHTING_PLANE))

GLOBAL_VAR_INIT(rpg_loot_items, FALSE)
// if true, everyone item when created will have its name changed to be
// more... RPG-like.

/obj/item
	name = "item"
	icon = 'icons/obj/items_and_weapons.dmi'
	blocks_emissive = EMISSIVE_BLOCK_GENERIC
	/// The icon state for the icons that appear in the players hand while holding it. Gotten from /client/var/lefthand_file and /client/var/righthand_file
	var/inhand_icon_state = null
	/// The icon for holding in hand icon states for the left hand.
	var/lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	/// The icon for holding in hand icon states for the right hand.
	var/righthand_file = 'icons/mob/inhands/items_righthand.dmi'

	//Dimensions of the icon file used when this item is worn, eg: hats.dmi
	//eg: 32x32 sprite, 64x64 sprite, etc.
	//allows inhands/worn sprites to be of any size, but still centered on a mob properly
	/// x dimension of the worn sprite
	var/worn_x_dimension = 32
	/// y dimension of the worn sprite
	var/worn_y_dimension = 32

	//Same as above but for inhands, uses the lefthand_ and righthand_ file vars
	/// x dimension of the inhand sprite
	var/inhand_x_dimension = 32
	/// y dimension of the inhand sprite
	var/inhand_y_dimension = 32
	/// Worn overlay will be shifted by this along y axis
	var/worn_y_offset = 0

	//Not on /clothing because for some reason any /obj/item can technically be "worn" with enough fuckery.
	/// If this is set, update_icons() will find on mob (WORN, NOT INHANDS) states in this file instead, primary use: badminnery/events
	var/icon/worn_icon = null
	//Icon state for mob worn overlays. If not set falls back to inhand_icon_state, then icon_state
	var/worn_icon_state
	/// If this is set, update_icons() will force the on mob state (WORN, NOT INHANDS) onto this layer, instead of it's default
	var/alternate_worn_layer
	///The config type to use for greyscaled worn sprites. Both this and greyscale_colors must be assigned to work.
	var/greyscale_config_worn
	///The config type to use for greyscaled left inhand sprites. Both this and greyscale_colors must be assigned to work.
	var/greyscale_config_inhand_left
	///The config type to use for greyscaled right inhand sprites. Both this and greyscale_colors must be assigned to work.
	var/greyscale_config_inhand_right
	///The config type to use for greyscaled belt overlays. Both this and greyscale_colors must be assigned to work.
	var/greyscale_config_belt

	max_integrity = 200

	obj_flags = NONE

	/// See _DEFINES/obj_flags.dm for a list of item flags
	var/item_flags = NONE

	/// The sound played when you hit things with it.
	var/hitsound = null
	/// If it's a tool, this is the sound played when the tool is used. For example when you use a wrench it goes *ccTCTHCHHTHCHT*
	var/usesound = null
	/// The sound played when you throw it at something and it hits that something.
	var/throwhitsound = null
	///Used when yate into a mob
	var/mob_throw_hit_sound
	///Sound used when equipping the item into a valid slot
	var/equip_sound
	///Sound uses when picking the item up (into your hands)
	var/pickup_sound
	///Sound uses when dropping the item, or when its thrown.
	var/drop_sound
	///Whether or not we use stealthy audio levels for this item's attack sounds
	var/stealthy_audio = FALSE

	/// The weight class of an object. Used to determine tons of things, like if it's too cumbersome for you to drag, if it can fit in certain storage items, how long it takes to burn, and more. See _DEFINES/inventory.dm to see all weight classes.
	var/w_class = WEIGHT_CLASS_NORMAL
	/// This is used to determine on which inventory slots an item can fit.
	var/slot_flags = 0

	pass_flags = PASSTABLE
	pressure_resistance = 4

	/// Used for attaching items to other items. An item's master is the item it's attached to.
	var/obj/item/master = null

	/// Flags which determine which body parts are protected from heat. Use the HEAD, CHEST, GROIN, etc. flags. See setup.dm
	var/heat_protection = 0
	/// Flags which determine which body parts are protected from cold. Use the HEAD, CHEST, GROIN, etc. flags. See setup.dm
	var/cold_protection = 0
	/// Set this variable to determine up to which temperature (IN KELVIN) the item protects against heat damage. Keep at null to disable protection. Only protects areas set by heat_protection flags
	var/max_heat_protection_temperature
	/// Set this variable to determine down to which temperature (IN KELVIN) the item protects against cold damage. 0 is NOT an acceptable number due to if(varname) tests!! Keep at null to disable protection. Only protects areas set by cold_protection flags
	var/min_cold_protection_temperature

	/// List of /datum/action's that this item has.
	var/list/actions
	/// List of paths of action datums to give to the item on New().
	var/list/actions_types

	/// This flag is used to determine when items in someone's inventory cover others. IE helmets making it so you can't see glasses, etc.
	var/flags_inv
	/// This flag is used to determine when items in someone's inventory cover others, however you can still see through that item and know what it covers. ex: You can see someone's mask through their transparent visor, but you can't reach it.
	var/transparent_protection = NONE

	/// Flags for clicking the item with your hand. See _DEFINES/interaction_flags.dm
	var/interaction_flags_item = INTERACT_ITEM_ATTACK_HAND_PICKUP

	///Icon state for the belt overlay, if null the normal icon_state will be used.
	var/belt_icon_state

	/// The body parts this item covers when worn. Used mostly for armor. See _DEFINES/setup.dm
	var/body_parts_covered = NONE
	/// For leaking gas from turf to mask and vice-versa (for masks right now, but at some point, i'd like to include space helmets)
	var/gas_transfer_coefficient = 1

	/// For electrical admittance/conductance (electrocution checks and shit)
	var/siemens_coefficient = 1
	/// How much clothing is slowing you down. Negative values speeds you up
	var/slowdown = 0
	/// Percentage of armour effectiveness to remove
	var/armour_penetration = 0
	/// The click cooldown given after attacking. Lower numbers means faster attacks
	var/attack_speed = CLICK_CD_MELEE
	/// The click cooldown on secondary attacks. Lower numbers mean faster attacks. Will use attack_speed if undefined.
	var/secondary_attack_speed
	/// A list of items that can be put in this item for like suit storage or something?? I honestly have no idea.
	var/list/allowed = null
	/// In deciseconds, how long an item takes to equip; counts only for normal clothing slots, not pockets etc.
	var/equip_delay_self = 0
	/// In deciseconds, how long an item takes to put on another person
	var/equip_delay_other = 20
	/// In deciseconds, how long an item takes to remove from another person
	var/strip_delay = 40
	/// In deciseconds, how long it takes to break out of an item by using resist. ex: handcuffs
	var/breakouttime = 0

	/// Used in attackby() to say how something was attacked "[x] has been [z.attack_verb] by [y] with [z]"
	var/list/attack_verb_continuous
	var/list/attack_verb_simple
	/// list() of species types, if a species cannot put items in a certain slot, but species type is in list, it will be able to wear that item
	var/list/species_exception = null
	///This is a bitfield that defines what variations exist for bodyparts like Digi legs. See: code\_DEFINES\inventory.dm
	var/supports_variations_flags = NONE

	///A weakref to the mob who threw the item
	var/datum/weakref/thrownby = null

	mouse_drag_pointer = MOUSE_ACTIVE_POINTER //the icon to indicate this object is being dragged

	/// Used for when things get stuck in you and need to be surgically removed. See [/datum/embedding_behavior]
	var/list/embedding = NONE

	/// For flags such as GLASSESCOVERSEYES to show which slots this item can cover. See _DEFINES/inventory.dm
	var/flags_cover = 0
	/// Used to define how hot it's flame will be when lit. Used it igniters, lighters, flares, candles, etc.
	var/heat = 0
	/// BLUNT | SHARP | SHARP_DISMEMBER | SHARP_DISMEMBER_EASY Used to define whether the item is sharp or blunt. SHARP is used if the item is supposed to be able to cut open things. See _DEFINES/combat.dm
	var/sharpness = BLUNT
	//this multiplies an attacks force for secondary effects like attacking blocking implements, dismemberment, and knocking a target silly
	var/attack_weight = 1

	/// What this thing does when used like a tool. NONE if it isn't a tool. If I give a piece of paper TOOL_WRENCH I can use it to unwrench tables. See _DEFINES/tools.dm
	var/tool_behaviour = NONE
	/// The tool speed multiplier of how long it takes to do the tool action.
	var/toolspeed = 1

	/// Whether or not an item can block attacks
	var/canblock = FALSE
	//blocking flags
	var/block_flags = BLOCKING_ACTIVE
	//reduces stamina damage taken whilst blocking. block power of 0 means it takes the full force of the attacking weapon
	var/block_power = 0
	//what sound does blocking make
	var/block_sound = 'sound/weapons/parry.ogg'
	//if a mob hits this barehanded, are they in trouble?
	var/hit_reaction_chance = 0 //If you want to have something unrelated to blocking/armour piercing etc. Maybe not needed, but trying to think ahead/allow more freedom

	/// In tiles, how far this weapon can reach; 1 for adjacent, which is default
	var/reach = 1

	/// The list of slots by priority. equip_to_appropriate_slot() uses this list. Doesn't matter if a mob type doesn't have a slot. For default list, see /mob/proc/equip_to_appropriate_slot()
	var/list/slot_equipment_priority = null

	// Needs to be in /obj/item because corgis can wear a lot of
	// non-clothing items
	var/datum/dog_fashion/dog_fashion = null

	/// For when wizards use rpg loot. See [/datum/rpg_loot]
	var/datum/rpg_loot/rpg_loot = null


	//Tooltip vars
	/// String form of an item's force. This appears in the tooltip of the item. Edit this var only to set a custom force string. For example toolboxes are "robust"
	var/force_string
	/// When the force_string was last updated so we know when it's time to update it again. In my opinion this is dumb and uneeded. - qwerty
	var/last_force_string_check = 0
	/// Used for tracking the callback timer for the delay it takes for the tooltip to appear after hovering over the item in your inventory.
	var/tip_timer

	/// Seemingly used only for guns so I'm not sure why it's here. Basically used to see whether you are able to pull the gun trigger. See _DEFINES/combat.dm
	var/trigger_guard = TRIGGER_GUARD_NONE

	///Used as the dye color source in the washing machine only (at the moment). Can be a hex color or a key corresponding to a registry entry, see washing_machine.dm
	var/dye_color
	///Whether the item is unaffected by standard dying.
	var/undyeable = FALSE
	///What dye registry should be looked at when dying this item; see washing_machine.dm
	var/dying_key

	//Grinder vars
	/// A reagent list containing the reagents this item produces when ground up in a grinder - this can be an empty list to allow for reagent transferring only
	var/list/grind_results
	///A reagent the nutriments are converted into when the item is juiced.
	var/datum/reagent/consumable/juice_typepath

	///Icon for monkey
	var/icon/monkey_icon

	var/canMouseDown = FALSE

	/// Used in obj/item/examine to give additional notes on what the weapon does, separate from the predetermined output variables
	var/offensive_notes
	/// Used in obj/item/examine to determines whether or not to detail an item's statistics even if it does not meet the force requirements
	var/override_notes = FALSE

	///Icons used to show the item in vendors instead of the item's actual icon, drawn from the item's icon file (just chemical.dm for now)
	//var/icon_state_preview = null

	// If the item is able to be used as a seed in a hydroponics tray.
	var/obj/item/seeds/fake_seed

	/// Used if we want to have a custom verb text for throwing. "John Spaceman flicks the ciggerate" for example.
	var/throw_verb
	/// How many charges get restored, when using this item to restore shield
	var/added_shield = 0

/obj/item/Initialize(mapload)
	if(attack_verb_continuous)
		attack_verb_continuous = typelist("attack_verb_continuous", attack_verb_continuous)
	if(attack_verb_simple)
		attack_verb_simple = typelist("attack_verb_simple", attack_verb_simple)

	if(sharpness && force > 5) //give sharp objects butchering functionality, for consistency
		AddComponent(/datum/component/butchering, _speed = 8 SECONDS * toolspeed)

	. = ..()
	for(var/path in actions_types)
		add_item_action(path)
	actions_types = null

	if(force_string)
		item_flags |= FORCE_STRING_OVERRIDE

	if(istype(loc, /obj/item/storage))
		item_flags |= IN_STORAGE

	if(istype(loc, /obj/item/robot_model))
		var/obj/item/robot_model/parent_module = loc
		var/mob/living/silicon/parent_robot = parent_module.loc
		if (istype(parent_robot))
			pickup(parent_robot)

	if(!hitsound)
		if(damtype == BURN)
			hitsound = 'sound/items/welder.ogg'
		if(damtype == BRUTE)
			hitsound = "swing_hit"

	add_weapon_description()

	// this code is stupid, i know, i don't care, this is what it was equivalent to before i touched it
	if(!LAZYLEN(embedding))
		if(GLOB.embedpocalypse)
			embedding = EMBED_POINTY
			name = "pointy [name]"
		else if(GLOB.stickpocalypse)
			embedding = EMBED_HARMLESS
			name = "sticky [name]"
	updateEmbedding()

	if(sharpness) //give sharp objects butchering functionality, for consistency
		AddComponent(/datum/component/butchering, 80 * toolspeed)

/obj/item/Destroy(force)
	master = null
	if(ismob(loc))
		var/mob/m = loc
		m.temporarilyRemoveItemFromInventory(src, TRUE)

	// Handle cleaning up our actions list
	for(var/datum/action/action as anything in actions)
		remove_item_action(action)
	QDEL_NULL(rpg_loot)
	return ..()

/// Called when an action associated with our item is deleted
/obj/item/proc/on_action_deleted(datum/source)
	SIGNAL_HANDLER

	if(!(source in actions))
		CRASH("An action ([source.type]) was deleted that was associated with an item ([src]), but was not found in the item's actions list.")

	LAZYREMOVE(actions, source)

/// Adds an item action to our list of item actions.
/// Item actions are actions linked to our item, that are granted to mobs who equip us.
/// This also ensures that the actions are properly tracked in the actions list and removed if they're deleted.
/// Can be be passed a typepath of an action or an instance of an action.
/obj/item/proc/add_item_action(action_or_action_type)

	var/datum/action/action
	if(ispath(action_or_action_type, /datum/action))
		action = new action_or_action_type(src)
	else if(istype(action_or_action_type, /datum/action))
		action = action_or_action_type
	else
		CRASH("item add_item_action got a type or instance of something that wasn't an action.")

	LAZYADD(actions, action)
	RegisterSignal(action, COMSIG_QDELETING, PROC_REF(on_action_deleted))
	grant_action_to_bearer(action)
	return action

/// Grant the action to anyone who has this item equipped to an appropriate slot
/obj/item/proc/grant_action_to_bearer(datum/action/action)
	if(!ismob(loc))
		return
	var/mob/holder = loc
	give_item_action(action, holder, holder.get_slot_by_item(src))

/// Removes an instance of an action from our list of item actions.
/obj/item/proc/remove_item_action(datum/action/action)
	if(!action)
		return

	UnregisterSignal(action, COMSIG_QDELETING)
	LAZYREMOVE(actions, action)
	qdel(action)

/// Adds the weapon_description element, which shows the 'warning label' for especially dangerous objects. Override this for item types with special notes.
/obj/item/proc/add_weapon_description()
	AddElement(/datum/element/weapon_description)

/**
 * Checks if an item is allowed to be used on an atom/target
 * Returns TRUE if allowed.
 *
 * Args:
 * target_self - Whether we will check if we (src) are in target, preventing people from using items on themselves.
 * not_inside - Whether target (or target's loc) has to be a turf.
 */
/obj/item/proc/check_allowed_items(atom/target, not_inside = FALSE, target_self = FALSE)
	if(!target_self && (src in target))
		return FALSE
	if(not_inside && !isturf(target.loc) && !isturf(target))
		return FALSE
	return TRUE

/obj/item/blob_act(obj/structure/blob/B)
	if(B.loc == loc && !(resistance_flags & INDESTRUCTIBLE))
		atom_destruction(MELEE)

//user: The mob that is suiciding
//damagetype: The type of damage the item will inflict on the user
//BRUTELOSS = 1
//FIRELOSS = 2
//TOXLOSS = 4
//OXYLOSS = 8
//Output a creative message and then return the damagetype done
/obj/item/proc/suicide_act(mob/living/user)
	return

/obj/item/set_greyscale(list/colors, new_config, new_worn_config, new_inhand_left, new_inhand_right)
	if(new_worn_config)
		greyscale_config_worn = new_worn_config
	if(new_inhand_left)
		greyscale_config_inhand_left = new_inhand_left
	if(new_inhand_right)
		greyscale_config_inhand_right = new_inhand_right
	return ..()

/// Checks if this atom uses the GAGS system and if so updates the worn and inhand icons
/obj/item/update_greyscale()
	. = ..()
	if(!greyscale_colors)
		return
	if(greyscale_config_worn)
		worn_icon = SSgreyscale.GetColoredIconByType(greyscale_config_worn, greyscale_colors)
	if(greyscale_config_inhand_left)
		lefthand_file = SSgreyscale.GetColoredIconByType(greyscale_config_inhand_left, greyscale_colors)
	if(greyscale_config_inhand_right)
		righthand_file = SSgreyscale.GetColoredIconByType(greyscale_config_inhand_right, greyscale_colors)

/obj/item/verb/move_to_top()
	set name = "Move To Top"
	set category = "Object"
	set src in oview(1)

	if(!isturf(loc) || usr.stat != CONSCIOUS || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return

	if(isliving(usr))
		var/mob/living/L = usr
		if(!(L.mobility_flags & MOBILITY_PICKUP))
			return

	var/turf/T = loc
	abstract_move(null)
	forceMove(T)

/obj/item/examine_tags(mob/user)
	var/list/parent_tags = ..()
	parent_tags.Insert(1, weight_class_to_text(w_class)) // To make size display first, otherwise it looks goofy
	. = parent_tags
	.[weight_class_to_text(w_class)] = weight_class_to_tooltip(w_class)

	if (siemens_coefficient == 0)
		.["insulated"] = "It is made from a robust electrical insulator and will block any electricity passing through it!"
	else if (siemens_coefficient <= 0.5)
		.["partially insulated"] = "It is made from a poor insulator that will dampen (but not fully block) electric shocks passing through it."

	if(resistance_flags & INDESTRUCTIBLE)
		.["indestructible"] = "It is extremely robust! It'll probably withstand anything that could happen to it!"
		return

	if(resistance_flags & LAVA_PROOF)
		.["lavaproof"] = "It is made of an extremely heat-resistant material, it'd probably be able to withstand lava!"
	if(resistance_flags & (ACID_PROOF | UNACIDABLE))
		.["acidproof"] = "It looks pretty robust! It'd probably be able to withstand acid!"
	if(resistance_flags & FREEZE_PROOF)
		.["freezeproof"] = "It is made of cold-resistant materials."
	if(resistance_flags & FIRE_PROOF)
		.["fireproof"] = "It is made of fire-retardant materials."

	if(!(item_flags & NOBLUDGEON) && !(item_flags & ISWEAPON) && force != 0)
		.["hesitant"] = "You'll have to apply a conscious effort to harm someone with [src]."

	if(!user.research_scanner)
		return

	// Research prospects, including boostable nodes and point values.
	// Deliver to a console to know whether the boosts have already been used.
	var/list/research_msg = list("<font color='purple'>Research prospects:</font> ")
	var/sep = ""
	var/list/boostable_nodes = techweb_item_boost_check(src)
	if (boostable_nodes)
		for(var/id in boostable_nodes)
			var/datum/techweb_node/node = SSresearch.techweb_node_by_id(id)
			if(!node)
				continue
			research_msg += sep
			research_msg += node.display_name
			sep = ", "
	var/list/points = techweb_item_point_check(src)
	if (length(points))
		sep = ", "
		research_msg += techweb_point_display_generic(points)

	if (!sep) // nothing was shown
		research_msg += "None"

	// Extractable materials. Only shows the names, not the amounts.
	research_msg += ".<br><font color='purple'>Extractable materials:</font> "
	if (length(custom_materials))
		sep = ""
		for(var/mat in custom_materials)
			research_msg += sep
			research_msg += CallMaterialName(mat)
			sep = ", "
	else
		research_msg += "None"
	research_msg += "."
	. += research_msg.Join()

/obj/item/examine_descriptor(mob/user)
	return "item"

/obj/item/interact(mob/user)
	if(SEND_SIGNAL(src, COMSIG_ATOM_INTERACT, user))
		. = TRUE
	add_fingerprint(user)
	ui_interact(user)

/obj/item/ui_act(action, params)
	add_fingerprint(usr)
	return ..()

/obj/item/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(. || !user || anchored)
		return
	return attempt_pickup(user)

/obj/item/proc/attempt_pickup(mob/user)
	. = TRUE

	if(resistance_flags & ON_FIRE)
		var/mob/living/carbon/C = user
		var/can_handle_hot = FALSE
		if(!istype(C))
			can_handle_hot = TRUE
		else if(C.gloves && (C.gloves.max_heat_protection_temperature > 360))
			can_handle_hot = TRUE
		else if(HAS_TRAIT(C, TRAIT_RESISTHEAT) || HAS_TRAIT(C, TRAIT_RESISTHEATHANDS))
			can_handle_hot = TRUE

		if(can_handle_hot)
			extinguish()
			to_chat(user, span_notice("You put out the fire on [src]."))
		else
			to_chat(user, span_warning("You burn your hand on [src]!"))
			var/obj/item/bodypart/affecting = C.get_bodypart("[(user.active_hand_index % 2 == 0) ? "r" : "l" ]_arm")
			if(affecting && affecting.receive_damage( 0, 5 ))		// 5 burn damage
				C.update_damage_overlays()
			return

	if(acid_level > 20 && !ismob(loc))// so we can still remove the clothes on us that have acid.
		var/mob/living/carbon/C = user
		if(istype(C))
			if(!C.gloves || (!(C.gloves.resistance_flags & (UNACIDABLE|ACID_PROOF))))
				to_chat(user, span_warning("The acid on [src] burns your hand!"))
				var/obj/item/bodypart/affecting = C.get_bodypart("[(user.active_hand_index % 2 == 0) ? "r" : "l" ]_arm")
				if(affecting && affecting.receive_damage( 0, 5 ))		// 5 burn damage
					C.update_damage_overlays()

	if(!(interaction_flags_item & INTERACT_ITEM_ATTACK_HAND_PICKUP))		//See if we're supposed to auto pickup.
		return

	//Heavy gravity makes picking up things very slow.
	var/grav = user.has_gravity()
	if(grav > STANDARD_GRAVITY)
		var/grav_power = min(3,grav - STANDARD_GRAVITY)
		to_chat(user,span_notice("You start picking up [src]..."))
		if(!do_after(user, 30*grav_power, src))
			return


	//If the item is in a storage item, take it out
	var/outside_storage = !loc.atom_storage
	var/turf/storage_turf
	if(loc.atom_storage)
		//We want the pickup animation to play even if we're moving the item between movables. Unless the mob is not located on a turf.
		if(isturf(user.loc))
			storage_turf = get_turf(loc)
		if(!loc.atom_storage.remove_single(user, src, user, silent = TRUE))
			return
	if(QDELETED(src)) //moving it out of the storage destroyed it.
		return

	if(storage_turf)
		do_pickup_animation(user, storage_turf)

	if(throwing)
		throwing.finalize(FALSE)
	if(loc == user && outside_storage)
		if(!allow_attack_hand_drop(user) || !user.temporarilyRemoveItemFromInventory(src))
			return

	. = FALSE
	remove_outline()
	add_fingerprint(user)
	if(!user.put_in_active_hand(src, FALSE, FALSE))
		user.dropItemToGround(src)
		return TRUE

/obj/item/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	// Do not pickup items on a right click action
	if (. == SECONDARY_ATTACK_CALL_NORMAL)
		. = SECONDARY_ATTACK_CONTINUE_CHAIN

/obj/item/proc/allow_attack_hand_drop(mob/user)
	return TRUE

/obj/item/attack_paw(mob/user, list/modifiers)
	. = ..()
	if(. || !user || anchored)
		return
	return attempt_pickup(user)

/obj/item/attack_alien(mob/user)
	var/mob/living/carbon/alien/A = user

	if(!user.can_hold_items(src))
		if(src in A.contents) // To stop Aliens having items stuck in their pockets
			A.dropItemToGround(src)
		to_chat(user, span_warning("Your claws aren't capable of such fine manipulation!"))
		return
	attack_paw(A)

/obj/item/attack_robot(mob/living/user)
	. = ..()
	if(.)
		return
	if(istype(src.loc, /obj/item/robot_model))
		//If the item is part of a cyborg module, equip it
		var/mob/living/silicon/robot/R = user
		if(!R.low_power_mode) //can't equip modules with an empty cell.
			R.activate_module(src)
			R.hud_used.update_robot_modules_display()

/obj/item/proc/GetDeconstructableContents()
	return GetAllContents() - src

// afterattack() and attack() prototypes moved to _onclick/item_attack.dm for consistency
/obj/item/proc/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	SHOULD_NOT_SLEEP(TRUE)

	//First and foremost, check for unblockable flags
	if(isitem(hitby))
		var/obj/item/item_hitby = hitby
		if((item_hitby.block_flags & BLOCKING_UNBLOCKABLE) && !(block_flags & BLOCKING_UNBLOCKABLE))
			return FALSE

	if(SEND_SIGNAL(src, COMSIG_ITEM_HIT_REACT, owner, hitby, attack_text, damage, attack_type) & COMPONENT_HIT_REACTION_BLOCK)
		return TRUE
	var/relative_dir = (dir2angle(get_dir(hitby, owner)) - dir2angle(owner.dir)) //shamelessly stolen from mech code
	var/obj/item/bodypart/blockhand = null
	if(owner.stat) //can't block if you're dead
		return FALSE
	if(HAS_TRAIT(owner, TRAIT_NOBLOCK))
		to_chat(owner, span_danger("You fumble when trying to block the attack, you're too jittery!")) //No blocking while under the influence of certain drugs
		return FALSE
	if(owner.get_active_held_item() == src) //copypaste of this code for an edgecase-nodrops
		if(owner.active_hand_index == 1)
			blockhand = (locate(/obj/item/bodypart/arm/left) in owner.bodyparts)
		else
			blockhand = (locate(/obj/item/bodypart/arm/right) in owner.bodyparts)
	else
		if(owner.active_hand_index == 1)
			blockhand = (locate(/obj/item/bodypart/arm/right) in owner.bodyparts)
		else
			blockhand = (locate(/obj/item/bodypart/arm/left) in owner.bodyparts)
	if(!blockhand)
		return FALSE
	if(blockhand?.bodypart_disabled)
		to_chat(owner, span_danger("You're too exausted to block the attack!"))
		return FALSE
	else if(owner.getStaminaLoss() >= 45)
		to_chat(owner, span_danger("You're too exausted to block the attack!"))
		return FALSE
	if((block_flags & BLOCKING_ACTIVE) && owner.get_active_held_item() != src) //you can still parry with the offhand
		return FALSE
	if(isprojectile(hitby)) //fucking bitflags broke this when coded in other ways
		var/obj/projectile/P = hitby
		if(block_flags & BLOCKING_PROJECTILE)
			if(P.movement_type & PHASING) //you can't block piercing rounds!
				return FALSE
			// Recalculate the relative_dir based on the projectile angle
			relative_dir = dir2angle(angle2dir(P.Angle)) - dir2angle(owner.dir)
		else
			return FALSE
	// Shields do not have a blocking cooldown
	if(istype(src, /obj/item/shield) || COOLDOWN_FINISHED(owner, block_cooldown))
		COOLDOWN_START(owner, block_cooldown, BLOCK_CD)
	else
		return FALSE
	switch(relative_dir)
		if(180, -180) //Check for head on attack
			if(canblock)
				playsound(src, block_sound, 50, 1)
				owner.visible_message(span_danger("[owner] blocks [attack_text] with [src]!"))
				return TRUE
		if(135, 225, -135, -225) //Check for forward diagonals
			if(canblock)
				playsound(src, block_sound, 50, 1)
				owner.visible_message(span_danger("[owner] blocks [attack_text] with [src]!"))
				return TRUE
	return FALSE

/obj/item/proc/on_block(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	var/attackforce = damage
	var/mob/living/attacking_mob
	var/mob/living/unarmed_mob

	if(isliving(hitby))
		attacking_mob = hitby
		unarmed_mob = TRUE

	if(isliving(hitby.loc))
		attacking_mob = hitby.loc

	if(isprojectile(hitby) && (block_flags & BLOCKING_PROJECTILE))
		var/obj/projectile/P = hitby
		if(P.damage_type == STAMINA)
			attackforce = 0 //Blocking disablers and tasers is free, but other projectiles do their standard damage
		else
			attackforce *= 0.5

	//Alright, it isn't a projectile, are we being hit with a weapon?
	else if(isitem(hitby))
		var/obj/item/I = hitby

		//If we block a stamina weapon, it does nothing
		if(I.damtype == STAMINA || (I.block_flags & BLOCKING_EFFORTLESS))
			attackforce = 0

		//Blocking gets a bonus against weapons that don't get their power from brute force, but the weight also doesn't matter
		else if(!I.damtype == BRUTE)
			attackforce = (attackforce * 0.8)

		//When blocking a sharp weapon, the force conveyed is determined purely by its weight rather than its damage
		else if(I.get_sharpness())
			attackforce = I.w_class * 2

		//And if it's a blunt weapon, blocking takes the worst outcome between weight and damage bonuses
		else
			attackforce = max(I.w_class * 2, attackforce * 1.5)

		//Is it a weapon especially adept at counterattacks? If so we roll for one
		if((owner.combat_mode && block_flags & BLOCKING_COUNTERATTACK) && prob(50))
			//is the item we blocked held by a mob, or was it thrown at us? We can't counter attack a thrown item.
			if(isliving(hitby.loc))
				var/mob/living/living_enemy = hitby.loc
				INVOKE_ASYNC(living_enemy, TYPE_PROC_REF(/atom, attackby), src, owner)
				owner.visible_message(span_danger("[owner] deftly counter-attacks while deflecting [hitby]!"))

	//if it's not a weapon and it's not a projectile, we need to check for counterattacks and blocking_nasty
	else if(owner.combat_mode && attack_type == UNARMED_ATTACK && unarmed_mob && (block_flags & (BLOCKING_NASTY|BLOCKING_COUNTERATTACK)))
		INVOKE_ASYNC(attacking_mob, TYPE_PROC_REF(/atom, attackby), src, owner)
		owner.visible_message(span_danger("[attacking_mob] injures themselves on [owner]'s [src]!"))

	//If this weapon is prone to knocking the opponent off balance, we want to delay their next attack and knock them down
	if((block_flags & BLOCKING_UNBALANCE) && prob(20) && attacking_mob)
		owner.visible_message(span_warning("[owner] knocks [attacking_mob] off balance!"))
		attacking_mob.Knockdown(1 SECONDS)
		attacking_mob.changeNext_move(CLICK_CD_MELEE * 2)

	//If the attacker is a simple_animal we need to check if they are designed to be especially good against blocking
	if(istype(hitby, /mob/living/simple_animal))
		var/mob/living/simple_animal/simplemob = hitby
		if(simplemob.hardattacks)
			attackforce = attackforce * 5 //You can probably only block them once or twice at most because of stamina and/or shield damage

	//We are ready to deal stamina damage to our owner
	owner.apply_damage(min(attackforce, 35), STAMINA, blocked = block_power)
	owner.changeNext_move(CLICK_CD_MELEE)

	//This is done here so we don't have to pass attackforce up somehow
	if(istype(src, /obj/item/shield))
		take_damage(attackforce)
	return TRUE

/obj/item/proc/talk_into(mob/M, input, channel, spans, datum/language/language, list/message_mods)
	return ITALICS | REDUCE_RANGE

/// Called when a mob drops an item.
/obj/item/proc/dropped(mob/user, silent = FALSE)
	SHOULD_CALL_PARENT(TRUE)

	// Remove any item actions we temporary gave out.
	for(var/datum/action/action_item_has as anything in actions)
		action_item_has.Remove(user)

	UnregisterSignal(src, list(SIGNAL_ADDTRAIT(TRAIT_NO_WORN_ICON), SIGNAL_REMOVETRAIT(TRAIT_NO_WORN_ICON)))

	item_flags &= ~BEING_REMOVED
	item_flags &= ~PICKED_UP
	SEND_SIGNAL(src, COMSIG_ITEM_DROPPED, user)
	SEND_SIGNAL(user, COMSIG_MOB_DROPPED_ITEM, src, loc)
	if(item_flags & SLOWS_WHILE_IN_HAND)
		user?.update_equipment_speed_mods()
	remove_outline()
	if(verbs && user?.client)
		user.client.remove_verbs(verbs)
	log_item(user, INVESTIGATE_VERB_DROPPED)
	if(!silent)
		playsound(src, drop_sound, DROP_SOUND_VOLUME, ignore_walls = FALSE)
	user?.update_equipment_speed_mods()
	user.refresh_self_screentips()

	if(item_flags & DROPDEL && !QDELETED(src))
		qdel(src)

// called just as an item is picked up (loc is not yet changed)
/obj/item/proc/pickup(mob/user)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_ITEM_PICKUP, user)
	SEND_SIGNAL(user, COMSIG_LIVING_PICKED_UP_ITEM, src)
	item_flags |= PICKED_UP
	if(item_flags & WAS_THROWN)
		item_flags &= ~WAS_THROWN
	if(verbs && user.client)
		user.client.add_verbs(verbs)
	user.refresh_self_screentips()
	log_item(user, INVESTIGATE_VERB_PICKEDUP)

// called when "found" in pockets and storage items. Returns 1 if the search should end.
/obj/item/proc/on_found(mob/finder)
	return

/**
 * To be overwritten to only perform visual tasks;
 * this is directly called instead of `equipped` on visual-only features like human dummies equipping outfits.
 *
 * This separation exists to prevent things like the monkey sentience helmet from
 * polling ghosts while it's just being equipped as a visual preview for a dummy.
 */
/obj/item/proc/visual_equipped(mob/user, slot, initial = FALSE)
	return

// called after an item is placed in an equipment slot
// user is mob that equipped it
// slot uses the slot_X defines found in setup.dm
// for items that can be placed in multiple slots
// note this isn't called during the initial dressing of a player
/obj/item/proc/equipped(mob/user, slot, initial = FALSE)
	SHOULD_CALL_PARENT(TRUE)
	visual_equipped(user, slot, initial)
	SEND_SIGNAL(src, COMSIG_ITEM_EQUIPPED, user, slot)
	SEND_SIGNAL(user, COMSIG_MOB_EQUIPPED_ITEM, src, slot)

	// Give out actions our item has to people who equip it.
	for(var/datum/action/action as anything in actions)
		give_item_action(action, user, slot)

	RegisterSignals(src, list(SIGNAL_ADDTRAIT(TRAIT_NO_WORN_ICON), SIGNAL_REMOVETRAIT(TRAIT_NO_WORN_ICON)), PROC_REF(update_slot_icon), override = TRUE)

	if(item_flags & SLOWS_WHILE_IN_HAND || slowdown)
		user.update_equipment_speed_mods()
	if(ismonkey(user)) //Only generate icons if we have to
		compile_monkey_icon()
	log_item(user, INVESTIGATE_VERB_EQUIPPED)

	if(!initial)
		if(equip_sound && slot_flags)
			playsound(src, equip_sound, EQUIP_SOUND_VOLUME, TRUE, ignore_walls = FALSE)
		else if(slot == ITEM_SLOT_HANDS)
			playsound(src, pickup_sound, PICKUP_SOUND_VOLUME, ignore_walls = FALSE)
	user.update_equipment_speed_mods()


/// Gives one of our item actions to a mob, when equipped to a certain slot
/obj/item/proc/give_item_action(datum/action/action, mob/to_who, slot)
	// Some items only give their actions buttons when in a specific slot.
	if(!item_action_slot_check(slot, to_who))
		// There is a chance we still have our item action currently,
		// and are moving it from a "valid slot" to an "invalid slot".
		// So call Remove() here regardless, even if excessive.
		action.Remove(to_who)
		return

	action.Grant(to_who)

//sometimes we only want to grant the item's action if it's equipped in a specific slot.
/obj/item/proc/item_action_slot_check(slot, mob/user)
	if(slot == ITEM_SLOT_BACKPACK || slot == ITEM_SLOT_LEGCUFFED) //these aren't true slots, so avoid granting actions there
		return FALSE
	return TRUE

/**
 *the mob M is attempting to equip this item into the slot passed through as 'slot'. Return 1 if it can do this and 0 if it can't.
 *if this is being done by a mob other than M, it will include the mob equipper, who is trying to equip the item to mob M. equipper will be null otherwise.
 *If you are making custom procs but would like to retain partial or complete functionality of this one, include a 'return ..()' to where you want this to happen.
 * Arguments:
 * * disable_warning to TRUE if you wish it to not give you text outputs.
 * * slot is the slot we are trying to equip to
 * * bypass_equip_delay_self for whether we want to bypass the equip delay
 * * ignore_equipped ignores any already equipped items in that slot
 * * indirect_action allows inserting into "soft locked" bags, things that can be easily opened by the owner
 */
/obj/item/proc/mob_can_equip(mob/living/M, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE, ignore_equipped = FALSE)
	if(!M)
		return FALSE

	return M.can_equip(src, slot, disable_warning, bypass_equip_delay_self, ignore_equipped)

/obj/item/verb/verb_pickup()
	set src in oview(1)
	set category = "Object"
	set name = "Pick up"

	if(usr.incapacitated || !Adjacent(usr))
		return

	if(isliving(usr))
		var/mob/living/L = usr
		if(!(L.mobility_flags & MOBILITY_PICKUP))
			return

	if(usr.get_active_held_item() == null) // Let me know if this has any problems -Yota
		usr.UnarmedAttack(src)

//This proc is executed when someone clicks the on-screen UI button.
//The default action is attack_self().
//Checks before we get to here are: mob is alive, mob is not restrained, stunned, asleep, resting, laying, item is on the mob.
/obj/item/proc/ui_action_click(mob/user, datum/actiontype)
	if(SEND_SIGNAL(src, COMSIG_ITEM_UI_ACTION_CLICK, user, actiontype) & COMPONENT_ACTION_HANDLED)
		return

	attack_self(user)

/obj/item/proc/IsReflect(def_zone) //This proc determines if and at what% an object will reflect energy projectiles if it's in l_hand,r_hand or wear_suit
	return FALSE

/// Returns true if damage was applied, false if the attack was fully blocked.
/obj/item/proc/eyestab(mob/living/carbon/M, mob/living/carbon/user, obj/item/weapon, silent)

	var/is_human_victim
	var/obj/item/bodypart/affecting = M.get_bodypart(BODY_ZONE_HEAD)
	if(ishuman(M))
		if(!affecting) //no head!
			return FALSE
		is_human_victim = TRUE

	if(M.is_eyes_covered())
		// you can't stab someone in the eyes wearing a mask!
		if (!silent)
			to_chat(user, span_danger("You're going to need to remove [M.p_their()] eye protection first!"))
		return FALSE

	if(isalien(M))//Aliens don't have eyes./N     slimes also don't have eyes!
		if (!silent)
			to_chat(user, span_warning("You cannot locate any eyes on this creature!"))
		return FALSE

	if(isbrain(M))
		if (!silent)
			to_chat(user, span_danger("You cannot locate any organic eyes on this brain!"))
		return FALSE

	add_fingerprint(user)

	playsound(loc, src.hitsound, 30, 1, -1)

	user.do_attack_animation(M)

	if(is_human_victim)
		var/mob/living/carbon/human/U = M
		var/blocked = U.run_armor_check(BODY_ZONE_HEAD, MELEE, armour_penetration = weapon.armour_penetration)
		U.apply_damage(weapon.force, BRUTE, affecting, blocked = blocked)
		if (prob(blocked))
			if(M != user)
				M.visible_message(span_danger("[user] stabbed [M] in the head with [src]!"), \
									span_userdanger("[user] stabs you in the head with [src], but your armor protects your eyes!"))
			else
				user.visible_message( \
					span_danger("[user] has stabbed [user.p_them()]self in the head with [src]!"), \
					span_userdanger("You stab yourself in the head with [src], your armor protecting your eyes!") \
				)
			return TRUE

	else
		M.take_bodypart_damage(weapon.force)

	if(M != user)
		M.visible_message(span_danger("[user] has stabbed [M] in the eye with [src]!"), \
							span_userdanger("[user] stabs you in the eye with [src]!"))
	else
		user.visible_message( \
			span_danger("[user] has stabbed [user.p_them()]self in the eyes with [src]!"), \
			span_userdanger("You stab yourself in the eyes with [src]!") \
		)

	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "eye_stab", /datum/mood_event/eye_stab)

	log_combat(user, M, "attacked", "[src.name]", "(Combat mode: [user.combat_mode ? "On" : "Off"])")

	var/obj/item/organ/eyes/eyes = M.get_organ_slot(ORGAN_SLOT_EYES)
	if (!eyes)
		return TRUE
	M.adjust_eye_blur(6 SECONDS)
	eyes.apply_organ_damage(3)
	if(eyes.damage >= 10)
		M.adjust_eye_blur(30 SECONDS)
		if(M.stat != DEAD)
			to_chat(M, span_danger("Your eyes start to bleed profusely!"))
		if(!M.is_blind() || HAS_TRAIT(M, TRAIT_NEARSIGHT))
			to_chat(M, span_danger("You become nearsighted!"))
		M.become_nearsighted(EYE_DAMAGE)
		if (eyes.damage >= 60)
			M.become_blind(EYE_DAMAGE)
			to_chat(M, span_danger("You go blind!"))
	return TRUE

/obj/item/singularity_pull(obj/anomaly/singularity/singularity, current_size)
	. = ..()
	if(current_size >= STAGE_FOUR)
		throw_at(singularity, 14, 3, spin = FALSE)

/obj/item/on_exit_storage(datum/storage/master_storage)
	. = ..()
	var/atom/location = master_storage.real_location?.resolve()
	do_drop_animation(location)

/obj/item/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(QDELETED(hit_atom))
		return
	if(SEND_SIGNAL(src, COMSIG_MOVABLE_IMPACT, hit_atom, throwingdatum) & COMPONENT_MOVABLE_IMPACT_NEVERMIND)
		return

	if(get_temperature() && isliving(hit_atom))
		var/mob/living/L = hit_atom
		L.ignite_mob()
	var/itempush = 1
	if(w_class < WEIGHT_CLASS_NORMAL)
		itempush = 0 //too light to push anything
	if(isliving(hit_atom)) //Living mobs handle hit sounds differently.
		var/volume = get_volume_by_throwforce_and_or_w_class()
		if (throwforce > 0)
			if (mob_throw_hit_sound)
				playsound(hit_atom, mob_throw_hit_sound, volume, TRUE, -1)
			else if(hitsound)
				playsound(hit_atom, hitsound, volume, TRUE, -1)
			else
				playsound(hit_atom, 'sound/weapons/genhit.ogg',volume, TRUE, -1)
		else
			playsound(src, drop_sound, YEET_SOUND_VOLUME, ignore_walls = FALSE)
	var/obj/item/modular_computer/comp
	var/obj/item/computer_hardware/processor_unit/cpu
	for(var/obj/item/modular_computer/M in contents)
		cpu = M.all_components[MC_CPU]
		if(cpu?.hacked)
			comp = M
		break
	if(comp)
		if(!cpu)
			return
		var/turf/target = comp.get_blink_destination(get_turf(src), dir, (cpu.max_idle_programs * 2))
		var/turf/start = get_turf(src)
		if(!comp.enabled)
			new /obj/effect/particle_effect/sparks(start)
			playsound(start, "sparks", 50, 1)
			return
		if(!target)
			return
		// The better the CPU the farther it goes, and the more battery it needs
		playsound(target, 'sound/effects/phasein.ogg', 25, 1)
		playsound(start, "sparks", 50, 1)
		playsound(target, "sparks", 50, 1)
		do_dash(src, start, target, 0, TRUE)
		comp.use_power((250 * cpu.max_idle_programs))
	return hit_atom.hitby(src, 0, itempush, throwingdatum=throwingdatum)


/obj/item/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback, force = MOVE_FORCE_WEAK, quickstart = TRUE)
	if(HAS_TRAIT(src, TRAIT_NODROP))
		return
	thrownby = WEAKREF(thrower)
	callback = CALLBACK(src, PROC_REF(after_throw), callback) //replace their callback with our own
	. = ..(target, range, speed, thrower, spin, diagonals_first, callback, force, quickstart = quickstart)

/obj/item/proc/after_throw(datum/callback/callback)
	if (callback) //call the original callback
		. = callback.Invoke()
	item_flags &= ~PICKED_UP
	if(!pixel_y && !pixel_x && !(item_flags & NO_PIXEL_RANDOM_DROP))
		pixel_x = rand(-8,8)
		pixel_y = rand(-8,8)

/// Takes the location to move the item to, and optionally the mob doing the removing
/// If no mob is provided, we'll pass in the location, assuming it is a mob
/// Please use this if you're going to snowflake an item out of a obj/item/storage
/obj/item/proc/remove_item_from_storage(atom/newLoc, mob/removing)
	if(!newLoc)
		return FALSE
	if(!removing)
		if(ismob(newLoc))
			removing = newLoc
		else
			stack_trace("Tried to remove an item and place it into [newLoc] without implicitly or explicitly passing in a mob doing the removing")
			return
	if(loc.atom_storage)
		return loc.atom_storage.remove_single(removing, src, newLoc, silent = TRUE)
	return FALSE

/// Returns the icon used for overlaying the object on a belt
/obj/item/proc/get_belt_overlay()
	var/icon_state_to_use = belt_icon_state || icon_state
	if(greyscale_config_belt && greyscale_colors)
		return mutable_appearance(SSgreyscale.GetColoredIconByType(greyscale_config_belt, greyscale_colors), icon_state_to_use)
	return mutable_appearance('icons/obj/clothing/belt_overlays.dmi', icon_state_to_use)

/obj/item/proc/update_slot_icon()
	SIGNAL_HANDLER
	if(!ismob(loc))
		return
	var/mob/owner = loc
	owner.update_clothing(slot_flags | owner.get_slot_by_item(src))

/obj/item/proc/get_temperature()
	return heat

/obj/item/proc/get_sharpness()
	return sharpness

/obj/item/proc/get_dismember_sound()
	if(damtype == BURN)
		. = 'sound/weapons/sear.ogg'
	else
		. = pick('sound/misc/desecration-01.ogg', 'sound/misc/desecration-02.ogg', 'sound/misc/desecration-03.ogg')

/obj/item/proc/open_flame(flame_heat=700)
	var/turf/location = loc
	if(ismob(location))
		var/mob/M = location
		var/success = FALSE
		if(src == M.get_item_by_slot(ITEM_SLOT_MASK))
			success = TRUE
		if(success)
			location = get_turf(M)
	if(isturf(location))
		location.hotspot_expose(flame_heat, 5)

/obj/item/proc/ignition_effect(atom/A, mob/user)
	if(get_temperature())
		. = span_notice("[user] lights [A] with [src].")
	else
		. = ""

/obj/item/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	return SEND_SIGNAL(src, COMSIG_ATOM_HITBY, AM, skipcatch, hitpush, blocked, throwingdatum)

/obj/item/attack_hulk(mob/living/carbon/human/user)
	return FALSE

/obj/item/attack_animal(mob/living/simple_animal/M)
	if (obj_flags & CAN_BE_HIT)
		return ..()
	return FALSE

/obj/item/burn()
	if(!QDELETED(src))
		var/turf/T = get_turf(src)
		var/ash_type = /obj/effect/decal/cleanable/ash
		if(w_class == WEIGHT_CLASS_HUGE || w_class == WEIGHT_CLASS_GIGANTIC)
			ash_type = /obj/effect/decal/cleanable/ash/large
		var/obj/effect/decal/cleanable/ash/A = new ash_type(T)
		A.desc += "\nLooks like this used to be \an [name] some time ago."
		..()

/obj/item/acid_melt()
	if(!QDELETED(src))
		var/turf/T = get_turf(src)
		var/obj/effect/decal/cleanable/molten_object/MO = new(T)
		MO.pixel_x = rand(-16,16)
		MO.pixel_y = rand(-16,16)
		MO.desc = "Looks like this was \an [src] some time ago."
		..()

/obj/item/proc/microwave_act(obj/machinery/microwave/M)
	if(SEND_SIGNAL(src, COMSIG_ITEM_MICROWAVE_ACT, M) & COMPONENT_SUCCESFUL_MICROWAVE)
		return
	if(istype(M) && M.dirty < 100)
		M.dirty++

	var/obj/item/stock_parts/cell/battery = get_cell()
	if(battery && battery.charge < battery.maxcharge * 0.4)
		battery.give(battery.maxcharge * 0.4 - battery.charge)
		if(prob(5))
			message_admins("A modular tablet ([src]) was detonated in a microwave (5% chance) at [ADMIN_JMP(src)]")
			log_game("A modular tablet named [src] detonated in a microwave at [get_turf(src)]")
			if(battery.charge > 3600) //At this charge level, the default charge-based battery explosion is more severe
				battery.explode()
			else
				explosion(src, 0, 0, 3, 4)

/obj/item/proc/on_mob_death(mob/living/L, gibbed)

/obj/item/proc/grind_requirements(obj/machinery/reagentgrinder/R) //Used to check for extra requirements for grinding an object
	return TRUE

//Called BEFORE the object is ground up - use this to change grind results based on conditions
//Return "-1" to prevent the grinding from occurring
/obj/item/proc/on_grind()
	return SEND_SIGNAL(src, COMSIG_ITEM_ON_GRIND)

///Grind item, adding grind_results to item's reagents and transfering to target_holder if specified
/obj/item/proc/grind(datum/reagents/target_holder, mob/user)
	if(on_grind() == -1)
		return FALSE
	if(target_holder)
		target_holder.add_reagent_list(grind_results)
		if(reagents)
			reagents.trans_to(target_holder, reagents.total_volume, transfered_by = user)
	return TRUE

///Called BEFORE the object is ground up - use this to change grind results based on conditions. Return "-1" to prevent the grinding from occurring
/obj/item/proc/on_juice()
	if(!juice_typepath)
		return -1
	return SEND_SIGNAL(src, COMSIG_ITEM_ON_JUICE)

///Juice item, converting nutriments into juice_typepath and transfering to target_holder if specified
/obj/item/proc/juice(datum/reagents/target_holder, mob/user)
	if(on_juice() == -1)
		return FALSE
	if(reagents)
		reagents.convert_reagent(/datum/reagent/consumable, juice_typepath, include_source_subtypes = TRUE)
		if(target_holder)
			reagents.trans_to(target_holder, reagents.total_volume, transfered_by = user)
	return TRUE

/obj/item/proc/set_force_string()
	switch(force)
		if(0 to 4)
			force_string = "very low"
		if(4 to 7)
			force_string = "low"
		if(7 to 10)
			force_string = "medium"
		if(10 to 11)
			force_string = "high"
		if(11 to 20) //12 is the force of a toolbox
			force_string = "robust"
		if(20 to 25)
			force_string = "very robust"
		else
			force_string = "exceptionally robust"
	last_force_string_check = force

/obj/item/proc/openTip(location, control, params, user)
	if(last_force_string_check != force && !(item_flags & FORCE_STRING_OVERRIDE))
		set_force_string()
	if(!(item_flags & FORCE_STRING_OVERRIDE))
		openToolTip(user,src,params,title = name,content = "[desc]<br>[force ? "<b>Force:</b> [force_string]" : ""]",theme = "")
	else
		openToolTip(user,src,params,title = name,content = "[desc]<br><b>Force:</b> [force_string]",theme = "")

/obj/item/MouseEntered(location, control, params)
	..()
	if(((get(src, /mob) == usr) || loc?.atom_storage || (item_flags & IN_STORAGE)) && !QDELETED(src)) //nullspace exists.
		var/mob/living/L = usr
		if(usr.client.prefs.read_player_preference(/datum/preference/toggle/enable_tooltips))
			var/timedelay = usr.client.prefs.read_player_preference(/datum/preference/numeric/tooltip_delay)/100
			tip_timer = addtimer(CALLBACK(src, PROC_REF(openTip), location, control, params, usr), timedelay, TIMER_STOPPABLE)//timer takes delay in deciseconds, but the pref is in milliseconds. dividing by 100 converts it.
		if(usr.client.prefs.read_preference(/datum/preference/toggle/item_outlines))
			if(istype(L) && L.incapacitated)
				apply_outline(COLOR_RED_GRAY)
			else
				apply_outline()

/obj/item/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	. = ..()
	remove_outline()

/obj/item/MouseExited()
	deltimer(tip_timer)//delete any in-progress timer if the mouse is moved off the item before it finishes
	closeToolTip(usr)
	remove_outline()

/obj/item/proc/apply_outline(colour = null)
	if(((get(src, /mob) != usr) && !loc?.atom_storage && !(item_flags & IN_STORAGE)) || QDELETED(src) || isobserver(usr)) //cancel if the item isn't in an inventory, is being deleted, or if the person hovering is a ghost (so that people spectating you don't randomly make your items glow)
		return FALSE
	if(!usr.client?.prefs?.read_player_preference(/datum/preference/toggle/item_outlines))
		return
	if(!colour)
		if(usr?.client?.prefs)
			colour = usr.client.prefs.read_player_preference(/datum/preference/color/outline_color)
		else
			colour = COLOR_BLUE_GRAY
	add_filter(HOVER_OUTLINE_FILTER, 1, list(type="outline", size=1, color=colour))

/obj/item/proc/remove_outline()
	remove_filter(HOVER_OUTLINE_FILTER)

// Called when a mob tries to use the item as a tool.
// Handles most checks.
/obj/item/proc/use_tool(atom/target, mob/living/user, delay, amount=0, volume=0, datum/callback/extra_checks)
	// No delay means there is no start message, and no reason to call tool_start_check before use_tool.
	// Run the start check here so we wouldn't have to call it manually.
	if(!delay && !tool_start_check(user, amount))
		return

	delay *= toolspeed

	// Play tool sound at the beginning of tool usage.
	play_tool_sound(target, volume)

	if(delay)
		// Create a callback with checks that would be called every tick by do_after.
		var/datum/callback/tool_check = CALLBACK(src, PROC_REF(tool_check_callback), user, amount, extra_checks)

		if(ismob(target))
			if(!do_after(user, delay, target, extra_checks=tool_check))
				return

		else
			if(!do_after(user, delay, target=target, extra_checks=tool_check))
				return
	else
		// Invoke the extra checks once, just in case.
		if(extra_checks && !extra_checks.Invoke())
			return

	// Use tool's fuel, stack sheets or charges if amount is set.
	if(amount && !use(amount))
		return

	// Play tool sound at the end of tool usage,
	// but only if the delay between the beginning and the end is not too small
	if(delay >= MIN_TOOL_SOUND_DELAY)
		play_tool_sound(target, volume)

	return TRUE

// Called before use_tool if there is a delay, or by use_tool if there isn't.
// Only ever used by welding tools and stacks, so it's not added on any other use_tool checks.
/obj/item/proc/tool_start_check(mob/living/user, amount=0)
	return tool_use_check(user, amount)

// A check called by tool_start_check once, and by use_tool on every tick of delay.
/obj/item/proc/tool_use_check(mob/living/user, amount)
	return !amount

// Generic use proc. Depending on the item, it uses up fuel, charges, sheets, etc.
// Returns TRUE on success, FALSE on failure.
/obj/item/proc/use(used)
	return !used

// Plays item's usesound, if any.
/obj/item/proc/play_tool_sound(atom/target, volume=50)
	if(target && usesound && volume)
		var/played_sound = usesound

		if(islist(usesound))
			played_sound = pick(usesound)

		playsound(target, played_sound, volume, 1)

// Used in a callback that is passed by use_tool into do_after call. Do not override, do not call manually.
/obj/item/proc/tool_check_callback(mob/living/user, amount, datum/callback/extra_checks)
	return tool_use_check(user, amount) && (!extra_checks || extra_checks.Invoke())

// Returns a numeric value for sorting items used as parts in machines, so they can be replaced by the rped
/obj/item/proc/get_part_rating()
	return FALSE

/obj/item/doMove(atom/destination)
	if (ismob(loc))
		var/mob/M = loc
		var/hand_index = M.get_held_index_of_item(src)
		if(hand_index)
			M.held_items[hand_index] = null
			M.update_held_items()
			if(M.client)
				M.client.screen -= src
			layer = initial(layer)
			plane = initial(plane)
			dropped(M, FALSE)
	return ..()

/obj/item/proc/embedded(atom/embedded_target)

/obj/item/proc/unembedded()
	if(item_flags & DROPDEL && !QDELETED(src))
		QDEL_NULL(src)
		return TRUE

/obj/item/proc/canStrip(mob/stripper, mob/owner)
	SHOULD_BE_PURE(TRUE)
	return !HAS_TRAIT(src, TRAIT_NODROP)

/obj/item/proc/doStrip(mob/stripper, mob/owner)
	. = owner.doUnEquip(src, force, drop_location(), FALSE)
	return stripper.put_in_hands(src)

/obj/item/ex_act(severity, target)
	if(resistance_flags & INDESTRUCTIBLE)
		return
	..() //contents explosion
	if(QDELETED(src))
		return
	if(target == src)
		take_damage(INFINITY, BRUTE, BOMB, 0)
		return
	switch(severity)
		if(1)
			take_damage(250, BRUTE, BOMB, 0)
		if(2)
			take_damage(75, BRUTE, BOMB, 0)
		if(3)
			take_damage(20, BRUTE, BOMB, 0)

///Does the current embedding var meet the criteria for being harmless? Namely, does it have a pain multiplier and jostle pain mult of 0? If so, return true.
/obj/item/proc/isEmbedHarmless()
	if(embedding)
		return (!embedding["pain_mult"] && !embedding["jostle_pain_mult"])

///In case we want to do something special (like self delete) upon failing to embed in something, return true
/obj/item/proc/failedEmbed()
	if(item_flags & DROPDEL && !QDELETED(src))
		QDEL_NULL(src)
		return TRUE
	if(istype(src, /obj/item/shrapnel))
		src.disableEmbedding()

///Called by the carbon throw_item() proc. Returns null if the item negates the throw, or a reference to the thing to suffer the throw else.
/obj/item/proc/on_thrown(mob/living/carbon/user, atom/target)
	if((item_flags & ABSTRACT) || HAS_TRAIT(src, TRAIT_NODROP))
		return
	user.dropItemToGround(src, silent = TRUE)
	if(throwforce && HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, span_notice("You set [src] down gently on the ground."))
		return
	return src

/**
  * tryEmbed() is for when you want to try embedding something without dealing with the damage + hit messages of calling hitby() on the item while targeting the target.
  *
  * Really, this is used mostly with projectiles with shrapnel payloads, from [/datum/element/embed/proc/checkEmbedProjectile], and called on said shrapnel. Mostly acts as an intermediate between different embed elements.
  *
  * Arguments:
  * * target- Either a body part or a carbon. What are we hitting?
  * * forced- Do we want this to go through 100%?
  */
/obj/item/proc/tryEmbed(atom/target, forced=FALSE, silent=FALSE)
	if(!isbodypart(target) && !iscarbon(target))
		return
	if(!forced && !LAZYLEN(embedding))
		return

	if(SEND_SIGNAL(src, COMSIG_EMBED_TRY_FORCE, target, forced, silent))
		return TRUE
	failedEmbed()

///For when you want to disable an item's embedding capabilities (like transforming weapons and such), this proc will detach any active embed elements from it.
/obj/item/proc/disableEmbedding()
	SEND_SIGNAL(src, COMSIG_ITEM_DISABLE_EMBED)
	return

///For when you want to add/update the embedding on an item. Uses the vars in [/obj/item/embedding], and defaults to config values for values that aren't set. Will automatically detach previous embed elements on this item.
/obj/item/proc/updateEmbedding()
	SHOULD_CALL_PARENT(TRUE)
	
	if(!islist(embedding) || !LAZYLEN(embedding))
		return

	AddElement(/datum/element/embed,\
		embed_chance = (!isnull(embedding["embed_chance"]) ? embedding["embed_chance"] : EMBED_CHANCE),\
		fall_chance = (!isnull(embedding["fall_chance"]) ? embedding["fall_chance"] : EMBEDDED_ITEM_FALLOUT),\
		pain_chance = (!isnull(embedding["pain_chance"]) ? embedding["pain_chance"] : EMBEDDED_PAIN_CHANCE),\
		pain_mult = (!isnull(embedding["pain_mult"]) ? embedding["pain_mult"] : EMBEDDED_PAIN_MULTIPLIER),\
		max_damage_mult = (!isnull(embedding["max_damage_mult"]) ? embedding["max_damage_mult"] : EMBEDDED_MAX_DAMAGE_MULTIPLIER),\
		remove_pain_mult = (!isnull(embedding["remove_pain_mult"]) ? embedding["remove_pain_mult"] : EMBEDDED_UNSAFE_REMOVAL_PAIN_MULTIPLIER),\
		rip_time = (!isnull(embedding["rip_time"]) ? embedding["rip_time"] : EMBEDDED_UNSAFE_REMOVAL_TIME),\
		ignore_throwspeed_threshold = (!isnull(embedding["ignore_throwspeed_threshold"]) ? embedding["ignore_throwspeed_threshold"] : FALSE),\
		jostle_chance = (!isnull(embedding["jostle_chance"]) ? embedding["jostle_chance"] : EMBEDDED_JOSTLE_CHANCE),\
		jostle_pain_mult = (!isnull(embedding["jostle_pain_mult"]) ? embedding["jostle_pain_mult"] : EMBEDDED_JOSTLE_PAIN_MULTIPLIER),\
		pain_stam_pct = (!isnull(embedding["pain_stam_pct"]) ? embedding["pain_stam_pct"] : EMBEDDED_PAIN_STAM_PCT),\
		armour_block = (!isnull(embedding["armour_block"]) ? embedding["armour_block"] : EMBEDDED_ARMOUR_BLOCK))
	return TRUE

/// How many different types of mats will be counted in a bite?
#define MAX_MATS_PER_BITE 2

/*
 * On accidental consumption: when you somehow end up eating an item accidentally (currently, this is used for when items are hidden in food like bread or cake)
 *
 * The base proc will check if the item is sharp and has a decent force.
 * Then, it checks the item's mat datums for the effects it applies afterwards.
 * Then, it checks tiny items.
 * After all that, it returns TRUE if the item is set to be discovered. Otherwise, it returns FALSE.
 *
 * This works similarily to /suicide_act: if you want an item to have a unique interaction, go to that item
 * and give it an /on_accidental_consumption proc override. For a simple example of this, check out the nuke disk.
 *
 * Arguments
 * * M - the mob accidentally consuming the item
 * * user - the mob feeding M the item - usually, it's the same as M
 * * source_item - the item that held the item being consumed - bread, cake, etc
 * * discover_after - if the item will be discovered after being chomped (FALSE will usually mean it was swallowed, TRUE will usually mean it was bitten into and discovered)
 */
/obj/item/proc/on_accidental_consumption(mob/living/carbon/victim, mob/living/carbon/user, obj/item/source_item, discover_after = TRUE)
	if(get_sharpness() && force >= 5) //if we've got something sharp with a decent force (ie, not plastic)
		INVOKE_ASYNC(victim, TYPE_PROC_REF(/mob, emote), "scream")
		victim.visible_message(span_warning("[victim] looks like [victim.p_theyve()] just bit something they shouldn't have!"), \
							span_boldwarning("OH GOD! Was that a crunch? That didn't feel good at all!!"))

		victim.apply_damage(max(15, force), BRUTE, BODY_ZONE_HEAD)
		victim.losebreath += 2
		if(tryEmbed(victim.get_bodypart(BODY_ZONE_CHEST), forced = TRUE)) //and if it embeds successfully in their chest, cause a lot of pain
			victim.apply_damage(max(25, force*1.5), BRUTE, BODY_ZONE_CHEST)
			victim.losebreath += 6
			discover_after = FALSE
		if(QDELETED(src)) // in case trying to embed it caused its deletion (say, if it's DROPDEL)
			return
		source_item?.reagents?.add_reagent(/datum/reagent/blood, 2)

	else if(custom_materials?.len) //if we've got materials, lets see whats in it
		/// How many mats have we found? You can only be affected by two material datums by default
		var/found_mats = 0
		/// How much of each material is in it? Used to determine if the glass should break
		var/total_material_amount = 0

		for(var/mats in custom_materials)
			total_material_amount += custom_materials[mats]
			if(found_mats >= MAX_MATS_PER_BITE)
				continue //continue instead of break so we can finish adding up all the mats to the total

			var/datum/material/discovered_mat = mats
			if(discovered_mat.on_accidental_mat_consumption(victim, source_item))
				found_mats++

		//if there's glass in it and the glass is more than 60% of the item, then we can shatter it
		if(custom_materials[SSmaterials.GetMaterialRef(/datum/material/glass)] >= total_material_amount * 0.60)
			if(prob(66)) //66% chance to break it
				/// The glass shard that is spawned into the source item
				var/obj/item/shard/broken_glass = new /obj/item/shard(loc)
				broken_glass.name = "broken [name]"
				broken_glass.desc = "This used to be \a [name], but it sure isn't anymore."
				playsound(victim, "shatter", 25, TRUE)
				qdel(src)
				if(QDELETED(source_item))
					broken_glass.on_accidental_consumption(victim, user)
			else //33% chance to just "crack" it (play a sound) and leave it in the bread
				playsound(victim, "shatter", 15, TRUE)
			discover_after = FALSE

		victim.adjust_disgust(33)
		victim.visible_message(
			span_warning("[victim] looks like [victim.p_theyve()] just bitten into something hard."), \
			span_warning("Eugh! Did I just bite into something?"))

	else if(w_class == WEIGHT_CLASS_TINY) //small items like soap or toys that don't have mat datums
		/// victim's chest (for cavity implanting the item)
		var/obj/item/bodypart/chest/victim_cavity = victim.get_bodypart(BODY_ZONE_CHEST)
		if(victim_cavity.cavity_item)
			victim.vomit(5, FALSE, FALSE, distance = 0)
			forceMove(drop_location())
			to_chat(victim, span_warning("You vomit up a [name]! [source_item? "Was that in \the [source_item]?" : ""]"))
		else
			victim.transferItemToLoc(src, victim, TRUE)
			victim.losebreath += 2
			victim_cavity.cavity_item = src
			to_chat(victim, span_warning("You swallow hard. [source_item? "Something small was in \the [source_item]..." : ""]"))
		discover_after = FALSE

	else
		to_chat(victim, span_warning("[source_item? "Something strange was in the \the [source_item]..." : "I just bit something strange..."] "))

	return discover_after

#undef MAX_MATS_PER_BITE

/**
 * Updates all action buttons associated with this item
 *
 * Arguments:
 * * status_only - Update only current availability status of the buttons to show if they are ready or not to use
 * * force - Force buttons update even if the given button icon state has not changed
 */
/obj/item/proc/update_action_buttons(status_only = FALSE, force = FALSE)
	for(var/datum/action/current_action as anything in actions)
		current_action.update_buttons(status_only, force)
/**
 * * An interrupt for offering an item to other people, called mainly from [/mob/living/carbon/proc/give], in case you want to run your own offer behavior instead.
 *
 * * Return TRUE if you want to interrupt the offer.
 *
 * * Arguments:
 * * offerer - the person offering the item
 */
/obj/item/proc/on_offered(mob/living/carbon/offerer)
	if(SEND_SIGNAL(src, COMSIG_ITEM_OFFERING, offerer) & COMPONENT_OFFER_INTERRUPT)
		return TRUE

/**
 * * An interrupt for someone trying to accept an offered item, called mainly from [/mob/living/carbon/proc/take], in case you want to run your own take behavior instead.
 *
 * * Return TRUE if you want to interrupt the taking.
 *
 * * Arguments:
 * * offerer - the person offering the item
 * * taker - the person trying to accept the offer
 */
/obj/item/proc/on_offer_taken(mob/living/carbon/offerer, mob/living/carbon/taker)
	if(SEND_SIGNAL(src, COMSIG_ITEM_OFFER_TAKEN, offerer, taker) & COMPONENT_OFFER_INTERRUPT)
		return TRUE

/// Special stuff you want to do when an outfit equips this item.
/obj/item/proc/on_outfit_equip(mob/living/carbon/human/outfit_wearer, visuals_only, item_slot)
	return

/// Whether or not this item can be put into a storage item through attackby
/obj/item/proc/attackby_storage_insert(datum/storage, atom/storage_holder, mob/user)
	return TRUE

/**
 * * Overridden to generate icons for monkey clothing
 */
/obj/item/proc/compile_monkey_icon()
	return

/// Called on [/datum/element/openspace_item_click_handler/proc/on_afterattack]. Check the relative file for information.
/obj/item/proc/handle_openspace_click(turf/target, mob/user, proximity_flag, click_parameters)
	CRASH("Undefined handle_openspace_click() behaviour. Ascertain the openspace_item_click_handler element has been attached to the right item and that its proc override doesn't call parent.")

/**
 * Returns null if this object cannot be used to interact with physical writing mediums such as paper.
 * Returns a list of key attributes for this object interacting with paper otherwise.
 */
/obj/item/proc/get_writing_implement_details()
	return null

/// Increases weight class by one class and returns true, or else returns false
/obj/item/proc/weight_class_up()
	switch(w_class)
		if(WEIGHT_CLASS_TINY)
			w_class = WEIGHT_CLASS_SMALL
		if(WEIGHT_CLASS_SMALL)
			w_class = WEIGHT_CLASS_NORMAL
		if(WEIGHT_CLASS_NORMAL)
			w_class = WEIGHT_CLASS_LARGE
		if(WEIGHT_CLASS_LARGE)
			w_class = WEIGHT_CLASS_BULKY
		if(WEIGHT_CLASS_BULKY)
			w_class = WEIGHT_CLASS_HUGE
		if(WEIGHT_CLASS_HUGE)
			w_class = WEIGHT_CLASS_GIGANTIC
		else
			return FALSE
	return TRUE

/// Decreases weight class by one class and returns true, or else returns false
/obj/item/proc/weight_class_down()
	switch(w_class)
		if(WEIGHT_CLASS_SMALL)
			w_class = WEIGHT_CLASS_TINY
		if(WEIGHT_CLASS_NORMAL)
			w_class = WEIGHT_CLASS_SMALL
		if(WEIGHT_CLASS_LARGE)
			w_class = WEIGHT_CLASS_NORMAL
		if(WEIGHT_CLASS_BULKY)
			w_class = WEIGHT_CLASS_LARGE
		if(WEIGHT_CLASS_HUGE)
			w_class = WEIGHT_CLASS_BULKY
		if(WEIGHT_CLASS_GIGANTIC)
			w_class = WEIGHT_CLASS_HUGE
		else
			return FALSE
	return TRUE

// Update icons if this is being carried by a mob
/obj/item/wash(clean_types)
	. = ..()

	if(ismob(loc))
		var/mob/mob_loc = loc
		mob_loc.regenerate_icons()

/obj/item/proc/add_strip_actions(datum/strip_context/context)

/obj/item/proc/perform_strip_actions(action_key, mob/actor)

// For item specific checks on strip start. Return true to interrupt stripping, return false to continue stripping.
/obj/item/proc/on_start_stripping(mob/source, mob/user, item_slot)
	return FALSE

/obj/item/Topic(href, href_list)
	. = ..()

	if (href_list["examine"])
		if(!usr.can_examine_in_detail(src))
			return
		if (src in usr)
			usr.examinate(src)
		else
			usr.external_examinate(src)
		return TRUE

/// Gets the examination title of an item that is equipped by another mob, this is what
/// shows on every line when you examine someone. Certain things, such as uniforms, may include
/// more details such as information on the accessories equipped which would not be appropriate
/// in the title of that item.
/// This proc also appends inspection links, which can be clicked in the chatbox to examine this
/// item in greater detail.
/obj/item/proc/examine_worn_title(mob/living/wearer, mob/user, skip_examine_link = FALSE)
	ASSERT(user, "Cannot generate worn examination title without a user, worn titles require the target which you are showing them to.")
	ASSERT(user.client, "Attempting to generate worn title for a mob without a client, which is not allowed.")
	var/examine_name = get_examine_name(user)

	// Don't add examine link if this is the item being directly examined
	if(skip_examine_link)
		return "[icon2html(src, user.client)] [examine_name]"
	return examine_inspection_link(user, "[icon2html(src, user.client)] [examine_name]")

/// Appends the inspection links to the name of this item.
/// This may be overriden to provice custom inspection commands, or may be called with a custom item name
/// that differs from the returned examine name of the item.
/obj/item/proc/examine_inspection_link(mob/user, examine_name)
	var/whole_word = user.client.prefs?.read_player_preference(/datum/preference/toggle/whole_word_examine_links)
	var/obj/item/card/id/ID = GetID()
	if(ID)
		return "[examine_name] <a href='byond://?src=\ref[ID];look_at_id=1'>\[Examine ID\]</a>"
	else
		if(whole_word)
			return "<a href='byond://?src=\ref[src];examine=1'>[examine_name]</a>"
		else
			return "[examine_name] <a href='byond://?src=\ref[src];examine=1'>\[?\]</a>"
