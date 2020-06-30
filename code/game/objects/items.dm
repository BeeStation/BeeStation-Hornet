GLOBAL_DATUM_INIT(fire_overlay, /mutable_appearance, mutable_appearance('icons/effects/fire.dmi', "fire"))

GLOBAL_VAR_INIT(rpg_loot_items, FALSE)
// if true, everyone item when created will have its name changed to be
// more... RPG-like.

/obj/item
	name = "item"
	icon = 'icons/obj/items_and_weapons.dmi'

	/// The icon state for the icons that appear in the players hand while holding it. Gotten from /client/var/lefthand_file and /client/var/righthand_file
	var/item_state = null
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

	//Not on /clothing because for some reason any /obj/item can technically be "worn" with enough fuckery.
	/// If this is set, update_icons() will find on mob (WORN, NOT INHANDS) states in this file instead, primary use: badminnery/events
	var/icon/alternate_worn_icon = null
	/// If this is set, update_icons() will force the on mob state (WORN, NOT INHANDS) onto this layer, instead of it's default
	var/alternate_worn_layer = null

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

	/// Used in picking icon_states based on the string color here. Also used for cables or something. This could probably do with being deprecated.
	var/item_color = null

	/// The body parts this item covers when worn. Used mostly for armor. See _DEFINES/setup.dm
	var/body_parts_covered = 0
	/// For leaking gas from turf to mask and vice-versa (for masks right now, but at some point, i'd like to include space helmets)
	var/gas_transfer_coefficient = 1
	/// For leaking chemicals/diseases from turf to mask and vice-versa
	var/permeability_coefficient = 1

	/// For electrical admittance/conductance (electrocution checks and shit)
	var/siemens_coefficient = 1
	/// How much clothing is slowing you down. Negative values speeds you up
	var/slowdown = 0
	/// Percentage of armour effectiveness to remove
	var/armour_penetration = 0
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

	/// List of materials it contains as the keys and the quantities as the vals. Like when you pop it into an autolathe these are the materials you get out of it. Also used in microwaves to see if there is enough iron to make it explode. Oh yeah it's used for a ton of other things too. Less exciting things though.
	var/list/materials

	/// Used in attackby() to say how something was attacked "[x] has been [z.attack_verb] by [y] with [z]"
	var/list/attack_verb
	/// list() of species types, if a species cannot put items in a certain slot, but species type is in list, it will be able to wear that item
	var/list/species_exception = null

	var/mob/thrownby = null

	mouse_drag_pointer = MOUSE_ACTIVE_POINTER //the icon to indicate this object is being dragged

	/// Used for when things get stuck in you and need to be surgically removed. See [/datum/embedding_behavior]
	var/datum/embedding_behavior/embedding

	/// For flags such as GLASSESCOVERSEYES to show which slots this item can cover. See _DEFINES/inventory.dm
	var/flags_cover = 0
	/// Used to define how hot it's flame will be when lit. Used it igniters, lighters, flares, candles, etc.
	var/heat = 0
	/// IS_BLUNT | IS_SHARP | IS_SHARP_ACCURATE Used to define whether the item is sharp or blunt. IS_SHARP is used if the item is supposed to be able to cut open things. See _DEFINES/combat.dm
	var/sharpness = IS_BLUNT
	//this multiplies an attacks force for secondary effects like attacking blocking implements, dismemberment, and knocking a target silly
	var/attack_weight = 1

	/// What this thing does when used like a tool. NONE if it isn't a tool. If I give a piece of paper TOOL_WRENCH I can use it to unwrench tables. See _DEFINES/tools.dm
	var/tool_behaviour = NONE
	/// The tool speed multiplier of how long it takes to do the tool action.
	var/toolspeed = 1

	/// The chance that holding this item will block attacks.
	var/block_level = 0
	//does the item block better if walking?
	var/block_upgrade_walk = 0
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

	//Grinder vars
	/// A reagent list containing the reagents this item produces when ground up in a grinder - this can be an empty list to allow for reagent transferring only
	var/list/grind_results
	/// A reagent list containing the reagents this item produces when JUICED in a grinder!
	var/list/juice_results

	//the outline filter on hover
	var/outline_filter

/obj/item/Initialize()

	materials =	typelist("materials", materials)

	if(materials) //Otherwise, use the instances already provided.
		var/list/temp_list = list()
		for(var/i in materials) //Go through all of our materials, get the subsystem instance, and then replace the list.
			var/amount = materials[i]
			var/datum/material/M = getmaterialref(i)
			temp_list[M] = amount
		materials = temp_list

	if (attack_verb)
		attack_verb = typelist("attack_verb", attack_verb)

	. = ..()
	for(var/path in actions_types)
		new path(src)
	actions_types = null

	if(GLOB.rpg_loot_items)
		rpg_loot = new(src)

	if(force_string)
		item_flags |= FORCE_STRING_OVERRIDE

	if(istype(loc, /obj/item/storage))
		item_flags |= IN_STORAGE

	if(istype(loc, /obj/item/robot_module))
		item_flags |= IN_INVENTORY

	if(!hitsound)
		if(damtype == "fire")
			hitsound = 'sound/items/welder.ogg'
		if(damtype == "brute")
			hitsound = "swing_hit"

	if (!embedding)
		embedding = getEmbeddingBehavior()
	else if (islist(embedding))
		embedding = getEmbeddingBehavior(arglist(embedding))
	else if (!istype(embedding, /datum/embedding_behavior))
		stack_trace("Invalid type [embedding.type] found in .embedding during /obj/item Initialize()")

/obj/item/Destroy()
	item_flags &= ~DROPDEL	//prevent reqdels
	if(ismob(loc))
		var/mob/m = loc
		m.temporarilyRemoveItemFromInventory(src, TRUE)
	for(var/X in actions)
		qdel(X)
	QDEL_NULL(rpg_loot)
	return ..()

/obj/item/proc/check_allowed_items(atom/target, not_inside, target_self)
	if(((src in target) && !target_self) || (!isturf(target.loc) && !isturf(target) && not_inside))
		return 0
	else
		return 1

/obj/item/blob_act(obj/structure/blob/B)
	if(B && B.loc == loc)
		qdel(src)

//user: The mob that is suiciding
//damagetype: The type of damage the item will inflict on the user
//BRUTELOSS = 1
//FIRELOSS = 2
//TOXLOSS = 4
//OXYLOSS = 8
//Output a creative message and then return the damagetype done
/obj/item/proc/suicide_act(mob/user)
	return

/obj/item/verb/move_to_top()
	set name = "Move To Top"
	set category = "Object"
	set src in oview(1)

	if(!isturf(loc) || usr.stat || usr.restrained())
		return

	if(isliving(usr))
		var/mob/living/L = usr
		if(!(L.mobility_flags & MOBILITY_PICKUP))
			return

	var/turf/T = loc
	loc = null
	loc = T

/obj/item/examine(mob/user) //This might be spammy. Remove?
	. = ..()

	. += "[gender == PLURAL ? "They are" : "It is"] a [weightclass2text(w_class)] item."

	if(resistance_flags & INDESTRUCTIBLE)
		. += "[src] seems extremely robust! It'll probably withstand anything that could happen to it!"
	else
		if(resistance_flags & LAVA_PROOF)
			. += "[src] is made of an extremely heat-resistant material, it'd probably be able to withstand lava!"
		if(resistance_flags & (ACID_PROOF | UNACIDABLE))
			. += "[src] looks pretty robust! It'd probably be able to withstand acid!"
		if(resistance_flags & FREEZE_PROOF)
			. += "[src] is made of cold-resistant materials."
		if(resistance_flags & FIRE_PROOF)
			. += "[src] is made of fire-retardant materials."

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
	if (materials.len)
		sep = ""
		for(var/mat in materials)
			research_msg += sep
			research_msg += CallMaterialName(mat)
			sep = ", "
	else
		research_msg += "None"
	research_msg += "."
	. += research_msg.Join()

/obj/item/interact(mob/user)
	add_fingerprint(user)
	ui_interact(user)

/obj/item/ui_act(action, params)
	add_fingerprint(usr)
	return ..()

/obj/item/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(!user)
		return
	if(anchored)
		return

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
			to_chat(user, "<span class='notice'>You put out the fire on [src].</span>")
		else
			to_chat(user, "<span class='warning'>You burn your hand on [src]!</span>")
			var/obj/item/bodypart/affecting = C.get_bodypart("[(user.active_hand_index % 2 == 0) ? "r" : "l" ]_arm")
			if(affecting && affecting.receive_damage( 0, 5 ))		// 5 burn damage
				C.update_damage_overlays()
			return

	if(acid_level > 20 && !ismob(loc))// so we can still remove the clothes on us that have acid.
		var/mob/living/carbon/C = user
		if(istype(C))
			if(!C.gloves || (!(C.gloves.resistance_flags & (UNACIDABLE|ACID_PROOF))))
				to_chat(user, "<span class='warning'>The acid on [src] burns your hand!</span>")
				var/obj/item/bodypart/affecting = C.get_bodypart("[(user.active_hand_index % 2 == 0) ? "r" : "l" ]_arm")
				if(affecting && affecting.receive_damage( 0, 5 ))		// 5 burn damage
					C.update_damage_overlays()

	if(!(interaction_flags_item & INTERACT_ITEM_ATTACK_HAND_PICKUP))		//See if we're supposed to auto pickup.
		return

	//Heavy gravity makes picking up things very slow.
	var/grav = user.has_gravity()
	if(grav > STANDARD_GRAVITY)
		var/grav_power = min(3,grav - STANDARD_GRAVITY)
		to_chat(user,"<span class='notice'>You start picking up [src]...</span>")
		if(!do_mob(user,src,30*grav_power))
			return


	//If the item is in a storage item, take it out
	SEND_SIGNAL(loc, COMSIG_TRY_STORAGE_TAKE, src, user.loc, TRUE)
	if(QDELETED(src)) //moving it out of the storage to the floor destroyed it.
		return

	if(throwing)
		throwing.finalize(FALSE)
	if(loc == user)
		if(!allow_attack_hand_drop(user) || !user.temporarilyRemoveItemFromInventory(src))
			return

	remove_outline()
	pickup(user)
	add_fingerprint(user)
	if(!user.put_in_active_hand(src, FALSE, FALSE))
		user.dropItemToGround(src)

/obj/item/proc/allow_attack_hand_drop(mob/user)
	return TRUE

/obj/item/attack_paw(mob/user)
	if(!user)
		return
	if(anchored)
		return

	SEND_SIGNAL(loc, COMSIG_TRY_STORAGE_TAKE, src, user.loc, TRUE)

	if(throwing)
		throwing.finalize(FALSE)
	if(loc == user)
		if(!user.temporarilyRemoveItemFromInventory(src))
			return

	pickup(user)
	add_fingerprint(user)
	if(!user.put_in_active_hand(src, FALSE, FALSE))
		user.dropItemToGround(src)

/obj/item/attack_alien(mob/user)
	var/mob/living/carbon/alien/A = user

	if(!A.has_fine_manipulation)
		if(src in A.contents) // To stop Aliens having items stuck in their pockets
			A.dropItemToGround(src)
		to_chat(user, "<span class='warning'>Your claws aren't capable of such fine manipulation!</span>")
		return
	attack_paw(A)

/obj/item/attack_ai(mob/user)
	if(istype(src.loc, /obj/item/robot_module))
		//If the item is part of a cyborg module, equip it
		if(!iscyborg(user))
			return
		var/mob/living/silicon/robot/R = user
		if(!R.low_power_mode) //can't equip modules with an empty cell.
			R.activate_module(src)
			R.hud_used.update_robot_modules_display()

/obj/item/proc/GetDeconstructableContents()
	return GetAllContents() - src

// afterattack() and attack() prototypes moved to _onclick/item_attack.dm for consistency

/obj/item/proc/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	SEND_SIGNAL(src, COMSIG_ITEM_HIT_REACT, args)
	var/relative_dir = (dir2angle(get_dir(hitby, owner)) - dir2angle(owner.dir)) //shamelessly stolen from mech code
	var/final_block_level = block_level
	var/obj/item/bodypart/blockhand = null
	if(owner.stat) //can't block if you're dead
		return 0
	if(HAS_TRAIT(owner, TRAIT_NOBLOCK) && istype(src, /obj/item/shield)) //shields can always block, because they break instead of using stamina damage
		return 0
	if(owner.get_active_held_item() == src) //copypaste of this code for an edgecase-nodrops
		if(owner.active_hand_index == 1)
			blockhand = (locate(/obj/item/bodypart/l_arm) in owner.bodyparts)
		else
			blockhand = (locate(/obj/item/bodypart/r_arm) in owner.bodyparts)
	else
		if(owner.active_hand_index == 1)
			blockhand = (locate(/obj/item/bodypart/r_arm) in owner.bodyparts)
		else
			blockhand = (locate(/obj/item/bodypart/l_arm) in owner.bodyparts)
	if(blockhand.is_disabled())
		to_chat(owner, "<span_class='danger'>You're too exausted to block the attack<!/span>")
		return 0
	else if(HAS_TRAIT(owner, TRAIT_NOLIMBDISABLE) && owner.getStaminaLoss() >= 30)
		to_chat(owner, "<span_class='danger'>You're too exausted to block the attack<!/span>")
		return 0
	if(owner.a_intent == INTENT_HARM) //you can choose not to block an attack
		return 0
	if(block_flags & BLOCKING_ACTIVE && owner.get_active_held_item() != src) //you can still parry with the offhand
		return 0
	if(isprojectile(hitby)) //fucking bitflags broke this when coded in other ways
		var/obj/item/projectile/P = hitby
		if(block_flags & BLOCKING_PROJECTILE)
			if(P.movement_type & UNSTOPPABLE) //you can't block piercing rounds!
				return 0
		else
			return 0
	if(owner.m_intent == MOVE_INTENT_WALK)
		final_block_level += block_upgrade_walk
	switch(relative_dir)
		if(180, -180)
			if(final_block_level >= 1)
				playsound(src, block_sound, 50, 1)
				owner.visible_message("<span class='danger'>[owner] blocks [attack_text] with [src]!</span>")
				return 1
		if(135, 225, -135, -225)
			if(final_block_level >= 2)
				playsound(src, block_sound, 50, 1)
				owner.visible_message("<span class='danger'>[owner] blocks [attack_text] with [src]!</span>")
				return 1
		if(90, 270, -90, -270)
			if(final_block_level >= 3)
				owner.visible_message("<span class='danger'>[owner] blocks [attack_text] with [src]!</span>")
				playsound(src, block_sound, 50, 1)
				return 1
		if(45, 315, -45, -315)
			if(final_block_level >= 4)
				playsound(src, block_sound, 50, 1)
				owner.visible_message("<span class='danger'>[owner] blocks [attack_text] with [src]!</span>")
				return 1
	return 0

/obj/item/proc/on_block(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	var/blockhand = 0
	var/attackforce = 0
	if(owner.get_active_held_item() == src) //this feels so hacky...
		if(owner.active_hand_index == 1)
			blockhand = BODY_ZONE_L_ARM
		else
			blockhand = BODY_ZONE_R_ARM
	else
		if(owner.active_hand_index == 1)
			blockhand = BODY_ZONE_R_ARM
		else
			blockhand = BODY_ZONE_L_ARM
	if(isprojectile(hitby))
		var/obj/item/projectile/P = hitby
		if(P.damage_type != STAMINA)// disablers dont do shit to shields
			attackforce = (P.damage)
	else if(isitem(hitby))
		var/obj/item/I = hitby
		attackforce = damage
		if(I.sharpness)
			attackforce = (attackforce / 2)//sharp weapons get much of their force by virtue of being sharp, not physical power
		if(!I.damtype == BRUTE)
			attackforce = (attackforce / 2)//as above, burning weapons, or weapons that deal other damage type probably dont get force from physical power
		attackforce = (attackforce * I.attack_weight)
		if(I.damtype == STAMINA)//pure stamina damage wont affect blocks
			attackforce = 0
	else if(attack_type == UNARMED_ATTACK && isliving(hitby))
		var/mob/living/L = hitby
		if(block_flags & BLOCKING_NASTY && !HAS_TRAIT(L, TRAIT_PIERCEIMMUNE))
			L.attackby(src, owner)
			owner.visible_message("<span class='danger'>[L] injures themselves on [owner]'s [src]!</span>")
	else if(isliving(hitby))
		var/mob/living/L = hitby
		attackforce = (damage * 2)//simplemobs have an advantage here because of how much these blocking mechanics put them at a disadvantage
		if(block_flags & BLOCKING_NASTY)
			if(istype(L, /mob/living/simple_animal))
				var/mob/living/simple_animal/S = L
				if(!S.hardattacks)
					S.attackby(src, owner)
					owner.visible_message("<span class='danger'>[S] injures themselves on [owner]'s [src]!</span>")
			else
				L.attackby(src, owner)
				owner.visible_message("<span class='danger'>[L] injures themselves on [owner]'s [src]!</span>")
	owner.apply_damage(attackforce, STAMINA, blockhand, block_power)
	if((owner.getStaminaLoss() >= 35 && HAS_TRAIT(src, TRAIT_NODROP)) || (HAS_TRAIT(owner, TRAIT_NOLIMBDISABLE) && owner.getStaminaLoss() >= 30))//if you don't drop the item, you can't block for a few seconds
		owner.blockbreak()
	return TRUE

/obj/item/proc/talk_into(mob/M, input, channel, spans, datum/language/language)
	return ITALICS | REDUCE_RANGE

/obj/item/proc/dropped(mob/user)
	for(var/X in actions)
		var/datum/action/A = X
		A.Remove(user)
	if(item_flags & DROPDEL)
		qdel(src)
	item_flags &= ~IN_INVENTORY
	SEND_SIGNAL(src, COMSIG_ITEM_DROPPED,user)
	remove_outline()

// called just as an item is picked up (loc is not yet changed)
/obj/item/proc/pickup(mob/user)
	SEND_SIGNAL(src, COMSIG_ITEM_PICKUP, user)
	item_flags |= IN_INVENTORY

// called when "found" in pockets and storage items. Returns 1 if the search should end.
/obj/item/proc/on_found(mob/finder)
	return

// called after an item is placed in an equipment slot
// user is mob that equipped it
// slot uses the slot_X defines found in setup.dm
// for items that can be placed in multiple slots
// note this isn't called during the initial dressing of a player
/obj/item/proc/equipped(mob/user, slot)
	SEND_SIGNAL(src, COMSIG_ITEM_EQUIPPED, user, slot)
	for(var/X in actions)
		var/datum/action/A = X
		if(item_action_slot_check(slot, user)) //some items only give their actions buttons when in a specific slot.
			A.Grant(user)
	item_flags |= IN_INVENTORY

//sometimes we only want to grant the item's action if it's equipped in a specific slot.
/obj/item/proc/item_action_slot_check(slot, mob/user)
	if(slot == SLOT_IN_BACKPACK || slot == SLOT_LEGCUFFED) //these aren't true slots, so avoid granting actions there
		return FALSE
	return TRUE

//the mob M is attempting to equip this item into the slot passed through as 'slot'. Return 1 if it can do this and 0 if it can't.
//if this is being done by a mob other than M, it will include the mob equipper, who is trying to equip the item to mob M. equipper will be null otherwise.
//If you are making custom procs but would like to retain partial or complete functionality of this one, include a 'return ..()' to where you want this to happen.
//Set disable_warning to TRUE if you wish it to not give you outputs.
/obj/item/proc/mob_can_equip(mob/living/M, mob/living/equipper, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE)
	if(!M)
		return FALSE

	return M.can_equip(src, slot, disable_warning, bypass_equip_delay_self)

/obj/item/verb/verb_pickup()
	set src in oview(1)
	set category = "Object"
	set name = "Pick up"

	if(usr.incapacitated() || !Adjacent(usr))
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
/obj/item/proc/ui_action_click(mob/user, actiontype)
	attack_self(user)

/obj/item/proc/IsReflect(var/def_zone) //This proc determines if and at what% an object will reflect energy projectiles if it's in l_hand,r_hand or wear_suit
	return 0

/obj/item/proc/eyestab(mob/living/carbon/M, mob/living/carbon/user)

	var/is_human_victim
	var/obj/item/bodypart/affecting = M.get_bodypart(BODY_ZONE_HEAD)
	if(ishuman(M))
		if(!affecting) //no head!
			return
		is_human_victim = TRUE

	if(M.is_eyes_covered())
		// you can't stab someone in the eyes wearing a mask!
		to_chat(user, "<span class='danger'>You're going to need to remove [M.p_their()] eye protection first!</span>")
		return

	if(isalien(M))//Aliens don't have eyes./N     slimes also don't have eyes!
		to_chat(user, "<span class='warning'>You cannot locate any eyes on this creature!</span>")
		return

	if(isbrain(M))
		to_chat(user, "<span class='danger'>You cannot locate any organic eyes on this brain!</span>")
		return

	src.add_fingerprint(user)

	playsound(loc, src.hitsound, 30, 1, -1)

	user.do_attack_animation(M)

	if(M != user)
		M.visible_message("<span class='danger'>[user] has stabbed [M] in the eye with [src]!</span>", \
							"<span class='userdanger'>[user] stabs you in the eye with [src]!</span>")
	else
		user.visible_message( \
			"<span class='danger'>[user] has stabbed [user.p_them()]self in the eyes with [src]!</span>", \
			"<span class='userdanger'>You stab yourself in the eyes with [src]!</span>" \
		)
	if(is_human_victim)
		var/mob/living/carbon/human/U = M
		U.apply_damage(7, BRUTE, affecting)

	else
		M.take_bodypart_damage(7)

	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "eye_stab", /datum/mood_event/eye_stab)

	log_combat(user, M, "attacked", "[src.name]", "(INTENT: [uppertext(user.a_intent)])")

	var/obj/item/organ/eyes/eyes = M.getorganslot(ORGAN_SLOT_EYES)
	if (!eyes)
		return
	M.adjust_blurriness(3)
	eyes.applyOrganDamage(3)
	if(eyes.damage >= 10)
		M.adjust_blurriness(15)
		if(M.stat != DEAD)
			to_chat(M, "<span class='danger'>Your eyes start to bleed profusely!</span>")
		if(!(HAS_TRAIT(M, TRAIT_BLIND) || HAS_TRAIT(M, TRAIT_NEARSIGHT)))
			to_chat(M, "<span class='danger'>You become nearsighted!</span>")
		M.become_nearsighted(EYE_DAMAGE)
		if (eyes.damage >= 60)
			M.become_blind(EYE_DAMAGE)
			to_chat(M, "<span class='danger'>You go blind!</span>")

/obj/item/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_FOUR)
		throw_at(S,14,3, spin=0)
	else
		return

/obj/item/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(hit_atom && !QDELETED(hit_atom))
		SEND_SIGNAL(src, COMSIG_MOVABLE_IMPACT, hit_atom, throwingdatum)
		if(is_hot() && isliving(hit_atom))
			var/mob/living/L = hit_atom
			L.IgniteMob()
		var/itempush = 1
		if(w_class < 4)
			itempush = 0 //too light to push anything
		return hit_atom.hitby(src, 0, itempush, throwingdatum=throwingdatum)

/obj/item/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback, force)
	thrownby = thrower
	callback = CALLBACK(src, .proc/after_throw, callback) //replace their callback with our own
	. = ..(target, range, speed, thrower, spin, diagonals_first, callback, force)


/obj/item/proc/after_throw(datum/callback/callback)
	if (callback) //call the original callback
		. = callback.Invoke()
	item_flags &= ~IN_INVENTORY

/obj/item/proc/remove_item_from_storage(atom/newLoc) //please use this if you're going to snowflake an item out of a obj/item/storage
	if(!newLoc)
		return FALSE
	if(SEND_SIGNAL(loc, COMSIG_CONTAINS_STORAGE))
		return SEND_SIGNAL(loc, COMSIG_TRY_STORAGE_TAKE, src, newLoc, TRUE)
	return FALSE

/obj/item/proc/get_belt_overlay() //Returns the icon used for overlaying the object on a belt
	return mutable_appearance('icons/obj/clothing/belt_overlays.dmi', icon_state)

/obj/item/proc/update_slot_icon()
	if(!ismob(loc))
		return
	var/mob/owner = loc
	var/flags = slot_flags
	if(flags & ITEM_SLOT_OCLOTHING)
		owner.update_inv_wear_suit()
	if(flags & ITEM_SLOT_ICLOTHING)
		owner.update_inv_w_uniform()
	if(flags & ITEM_SLOT_GLOVES)
		owner.update_inv_gloves()
	if(flags & ITEM_SLOT_EYES)
		owner.update_inv_glasses()
	if(flags & ITEM_SLOT_EARS)
		owner.update_inv_ears()
	if(flags & ITEM_SLOT_MASK)
		owner.update_inv_wear_mask()
	if(flags & ITEM_SLOT_HEAD)
		owner.update_inv_head()
	if(flags & ITEM_SLOT_FEET)
		owner.update_inv_shoes()
	if(flags & ITEM_SLOT_ID)
		owner.update_inv_wear_id()
	if(flags & ITEM_SLOT_BELT)
		owner.update_inv_belt()
	if(flags & ITEM_SLOT_BACK)
		owner.update_inv_back()
	if(flags & ITEM_SLOT_NECK)
		owner.update_inv_neck()

/obj/item/proc/is_hot()
	return heat

/obj/item/proc/is_sharp()
	return sharpness

/obj/item/proc/get_dismember_sound()
	if(damtype == BURN)
		. = 'sound/weapons/sear.ogg'
	else
		. = pick('sound/misc/desceration-01.ogg', 'sound/misc/desceration-02.ogg', 'sound/misc/desceration-03.ogg')

/obj/item/proc/open_flame(flame_heat=700)
	var/turf/location = loc
	if(ismob(location))
		var/mob/M = location
		var/success = FALSE
		if(src == M.get_item_by_slot(SLOT_WEAR_MASK))
			success = TRUE
		if(success)
			location = get_turf(M)
	if(isturf(location))
		location.hotspot_expose(flame_heat, 5)

/obj/item/proc/ignition_effect(atom/A, mob/user)
	if(is_hot())
		. = "<span class='notice'>[user] lights [A] with [src].</span>"
	else
		. = ""

/obj/item/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	return

/obj/item/attack_hulk(mob/living/carbon/human/user)
	return 0

/obj/item/attack_animal(mob/living/simple_animal/M)
	if (obj_flags & CAN_BE_HIT)
		return ..()
	return 0

/obj/item/mech_melee_attack(obj/mecha/M)
	return 0

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
	if(istype(M) && M.dirty < 100)
		M.dirty++

/obj/item/proc/on_mob_death(mob/living/L, gibbed)

/obj/item/proc/grind_requirements(obj/machinery/reagentgrinder/R) //Used to check for extra requirements for grinding an object
	return TRUE

 //Called BEFORE the object is ground up - use this to change grind results based on conditions
 //Use "return -1" to prevent the grinding from occurring
/obj/item/proc/on_grind()

/obj/item/proc/on_juice()

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
	if((item_flags & IN_INVENTORY || item_flags & IN_STORAGE) && usr.client.prefs.enable_tips && !QDELETED(src))
		var/timedelay = usr.client.prefs.tip_delay/100
		var/user = usr
		tip_timer = addtimer(CALLBACK(src, .proc/openTip, location, control, params, user), timedelay, TIMER_STOPPABLE)//timer takes delay in deciseconds, but the pref is in milliseconds. dividing by 100 converts it.
	var/mob/living/L = usr
	if(istype(L) && L.incapacitated())
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
	if(!(item_flags & IN_INVENTORY || item_flags & IN_STORAGE) || QDELETED(src))
		return
	if(usr.client)
		if(!usr.client.prefs.outline_enabled)
			return
	if(!colour)
		if(usr.client)
			colour = usr.client.prefs.outline_color
			if(!colour)
				colour = COLOR_BLUE_GRAY
		else
			colour = COLOR_BLUE_GRAY
	if(outline_filter)
		filters -= outline_filter
	outline_filter = filter(type="outline", size=1, color=colour)
	filters += outline_filter

/obj/item/proc/remove_outline()
	if(outline_filter)
		filters -= outline_filter
		outline_filter = null

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
		var/datum/callback/tool_check = CALLBACK(src, .proc/tool_check_callback, user, amount, extra_checks)

		if(ismob(target))
			if(!do_mob(user, target, delay, extra_checks=tool_check))
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
	return 0

/obj/item/doMove(atom/destination)
	if (ismob(loc))
		var/mob/M = loc
		var/hand_index = M.get_held_index_of_item(src)
		if(hand_index)
			M.held_items[hand_index] = null
			M.update_inv_hands()
			if(M.client)
				M.client.screen -= src
			layer = initial(layer)
			plane = initial(plane)
			appearance_flags &= ~NO_CLIENT_COLOR
			dropped(M)
	return ..()

/obj/item/throw_at(atom/target, range, speed, mob/thrower, spin=TRUE, diagonals_first = FALSE, var/datum/callback/callback)
	if(HAS_TRAIT(src, TRAIT_NODROP))
		return
	return ..()

/obj/item/proc/canStrip(mob/stripper, mob/owner)
	return !HAS_TRAIT(src, TRAIT_NODROP)

/obj/item/proc/doStrip(mob/stripper, mob/owner)
	return owner.dropItemToGround(src)
