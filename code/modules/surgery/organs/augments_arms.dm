/obj/item/organ/cyberimp/arm
	name = "arm-mounted implant"
	desc = "You shouldn't see this! Adminhelp and report this as an issue on github!"
	zone = BODY_ZONE_R_ARM
	icon_state = "implant-toolkit"
	w_class = WEIGHT_CLASS_SMALL
	actions_types = list(/datum/action/item_action/organ_action/toggle)
	///A ref for the arm we're taking up. Mostly for the unregister signal upon removal
	var/obj/hand
	//A list of typepaths to create and insert into ourself on init
	var/list/items_to_create = list()
	/// Used to store a list of all items inside, for multi-item implants.
	var/list/items_list = list()// I would use contents, but they shuffle on every activation/deactivation leading to interface inconsistencies.
	/// You can use this var for item path, it would be converted into an item on New().
	var/obj/item/active_item

/obj/item/organ/cyberimp/arm/Initialize(mapload)
	. = ..()
	if(ispath(active_item))
		active_item = new active_item(src)
		items_list += WEAKREF(active_item)

	for(var/typepath in items_to_create)
		var/atom/new_item = new typepath(src)
		items_list += WEAKREF(new_item)

	update_icon()
	SetSlotFromZone()

/obj/item/organ/cyberimp/arm/Destroy()
	hand = null
	active_item = null
	for(var/datum/weakref/ref in items_list)
		var/obj/item/to_del = ref.resolve()
		if(!to_del)
			continue
		qdel(to_del)
	items_list.Cut()
	return ..()

/obj/item/organ/cyberimp/arm/vv_edit_var(var_name, var_value)
	. = ..()
	switch(var_name)
		if(NAMEOF(src, toolspeed))
			for(var/datum/weakref/item_ref as anything in items_list)
				var/obj/item/tool = item_ref.resolve()
				if(tool)
					tool.toolspeed = var_value

/obj/item/organ/cyberimp/arm/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "---")
	VV_DROPDOWN_OPTION(VV_HK_ADD_IMPLANT_TOOL, "Add Tool To Implant")
	VV_DROPDOWN_OPTION(VV_HK_DEL_IMPLANT_TOOL, "Remove Tool From Implant")

/obj/item/organ/cyberimp/arm/vv_do_topic(href_list)
	. = ..()
	if(href_list[VV_HK_ADD_IMPLANT_TOOL])
		var/type_to_search_for = tgui_input_text(usr, "Search for item type", "Typepath Search", "/obj/item")
		var/item_type = pick_closest_path(type_to_search_for, make_types_fancy(subtypesof(/obj/item)))
		if(!item_type)
			return
		var/obj/item/new_item = new item_type(src)
		var/turf/turf = get_turf(src)
		log_admin("[key_name(usr)] added [new_item] ([item_type]) to \the [src] ([type]) at [AREACOORD(turf)]")
		message_admins("[key_name(usr)] added [new_item] ([item_type]) to \the [src] ([type]) at [ADMIN_VERBOSEJMP(turf)]")
		items_list += WEAKREF(new_item)
	if(href_list[VV_HK_DEL_IMPLANT_TOOL])
		var/list/tools = list()
		for(var/datum/weakref/item_ref as anything in items_list)
			var/obj/item/tool = item_ref.resolve()
			if(tool)
				tools |= tool
		var/obj/item/tool_to_remove = tgui_input_list(usr, "Which tool should be removed from \the [src]?", "Remove Tool From Implant", tools)
		if(!tool_to_remove || !istype(tool_to_remove))
			return
		items_list -= tool_to_remove.weak_reference
		var/turf/turf = get_turf(src)
		log_admin("[key_name(usr)] removed [tool_to_remove] ([tool_to_remove.type]) from \the [src] ([type]) at [AREACOORD(turf)]")
		message_admins("[key_name(usr)] added [tool_to_remove] ([tool_to_remove.type]) from \the [src] ([type]) at [ADMIN_VERBOSEJMP(turf)]")
		qdel(tool_to_remove)

/obj/item/organ/cyberimp/arm/proc/SetSlotFromZone()
	switch(zone)
		if(BODY_ZONE_L_ARM)
			slot = ORGAN_SLOT_LEFT_ARM_AUG
		if(BODY_ZONE_R_ARM)
			slot = ORGAN_SLOT_RIGHT_ARM_AUG
		else
			CRASH("Invalid zone for [type]")

/obj/item/organ/cyberimp/arm/update_icon()
	if(zone == BODY_ZONE_R_ARM)
		transform = null
	else // Mirroring the icon
		transform = matrix(-1, 0, 0, 0, 1, 0)

/obj/item/organ/cyberimp/arm/examine(mob/user)
	. = ..()
	. += "<span class='info'>[src] is assembled in the [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm configuration. You can use a screwdriver to reassemble it.</span>"

/obj/item/organ/cyberimp/arm/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(.)
		return TRUE
	I.play_tool_sound(src)
	if(zone == BODY_ZONE_R_ARM)
		zone = BODY_ZONE_L_ARM
	else
		zone = BODY_ZONE_R_ARM
	SetSlotFromZone()
	to_chat(user, "<span class='notice'>You modify [src] to be installed on the [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm.</span>")
	update_icon()

/obj/item/organ/cyberimp/arm/Insert(mob/living/carbon/user, special = FALSE, drop_if_replaced = TRUE)
	. = ..()
	var/side = zone == BODY_ZONE_R_ARM ? 2 : 1
	register_hand(user, owner.hand_bodyparts[side])
	RegisterSignal(user, COMSIG_KB_MOB_DROPITEM_DOWN, PROC_REF(dropkey)) //We're nodrop, but we'll watch for the drop hotkey anyway and then stow if possible.
	RegisterSignal(user, COMSIG_CARBON_POST_ATTACH_LIMB, PROC_REF(limb_attached))

/obj/item/organ/cyberimp/arm/Remove(mob/living/carbon/user, special = 0)
	Retract()
	unregister_hand(user)
	UnregisterSignal(user, list(COMSIG_KB_MOB_DROPITEM_DOWN, COMSIG_CARBON_POST_ATTACH_LIMB))
	..()

/obj/item/organ/cyberimp/arm/proc/register_hand(mob/living/carbon/user, obj/item/bodypart/new_hand)
	if(!istype(new_hand, /obj/item/bodypart/l_arm) && !istype(new_hand, /obj/item/bodypart/r_arm))
		return
	hand = new_hand
	RegisterSignal(hand, COMSIG_BODYPART_REMOVED, PROC_REF(limb_removed))
	RegisterSignal(hand, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_item_attack_self)) //If the limb gets an attack-self, open the menu. Only happens when hand is empty

/obj/item/organ/cyberimp/arm/proc/unregister_hand(mob/living/carbon/user)
	if(hand)
		UnregisterSignal(hand, list(COMSIG_ITEM_ATTACK_SELF, COMSIG_BODYPART_REMOVED))
		hand = null

/obj/item/organ/cyberimp/arm/proc/limb_attached(mob/living/carbon/source, obj/item/bodypart/new_limb, special)
	SIGNAL_HANDLER
	var/side = zone == BODY_ZONE_R_ARM ? 2 : 1
	if(source.hand_bodyparts[side] == new_limb)
		register_hand(source, new_limb)

/obj/item/organ/cyberimp/arm/proc/limb_removed(obj/item/bodypart/source, mob/living/carbon/old_owner, dismembered)
	SIGNAL_HANDLER
	unregister_hand(source)

/obj/item/organ/cyberimp/arm/proc/on_item_attack_self()
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(ui_action_click))

/**
  * Called when the mob uses the "drop item" hotkey
  *
  * Items inside toolset implants have TRAIT_NODROP, but we can still use the drop item hotkey as a
  * quick way to store implant items. In this case, we check to make sure the user has the correct arm
  * selected, and that the item is actually owned by us, and then we'll hand off the rest to Retract()
**/
/obj/item/organ/cyberimp/arm/proc/dropkey(mob/living/carbon/host)
	SIGNAL_HANDLER
	if(!host)
		return //How did we even get here
	if(hand != host.hand_bodyparts[host.active_hand_index])
		return //wrong hand
	Retract()

/obj/item/organ/cyberimp/arm/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(prob(15/severity) && owner)
		to_chat(owner, "<span class='warning'>The electro magnetic pulse causes [src] to malfunction!</span>")
		// give the owner an idea about why his implant is glitching
		Retract()

/obj/item/organ/cyberimp/arm/proc/Retract()
	if(!active_item || (active_item in src))
		return

	owner.visible_message("<span class='notice'>[owner] retracts [active_item] back into [owner.p_their()] [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm.</span>",
		"<span class='notice'>[active_item] snaps back into your [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm.</span>",
		"<span class='italics'>You hear a short mechanical noise.</span>")

	owner.transferItemToLoc(active_item, src, TRUE)
	REMOVE_TRAIT(active_item, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	active_item = null
	playsound(get_turf(owner), 'sound/mecha/mechmove03.ogg', 50, 1)

/obj/item/organ/cyberimp/arm/proc/Extend(var/obj/item/item)
	if(!(item in src))
		return

	active_item = item
	ADD_TRAIT(active_item, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)

	active_item.resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	active_item.slot_flags = null
	active_item.set_custom_materials(null)

	var/side = zone == BODY_ZONE_R_ARM ? "right" : "left"
	var/hand = owner.get_empty_held_index_for_side(side)
	if(hand)
		owner.put_in_hand(active_item, hand)
	else
		var/list/hand_items = owner.get_held_items_for_side(side, all = TRUE)
		var/success = FALSE
		var/list/failure_message = list()
		for(var/i in 1 to hand_items.len) //Can't just use *in* here.
			var/I = hand_items[i]
			if(!owner.dropItemToGround(I))
				failure_message += "<span class='warning'>Your [I] interferes with [src]!</span>"
				continue
			to_chat(owner, "<span class='notice'>You drop [I] to activate [src]!</span>")
			success = owner.put_in_hand(active_item, owner.get_empty_held_index_for_side(side))
			break
		if(!success)
			for(var/i in failure_message)
				to_chat(owner, i)
			return
	owner.visible_message("<span class='notice'>[owner] extends [active_item] from [owner.p_their()] [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm.</span>",
		"<span class='notice'>You extend [active_item] from your [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm.</span>",
		"<span class='italics'>You hear a short mechanical noise.</span>")
	playsound(get_turf(owner), 'sound/mecha/mechmove03.ogg', 50, TRUE)

/obj/item/organ/cyberimp/arm/ui_action_click()
	if((organ_flags & ORGAN_FAILING) || (!active_item && !contents.len))
		to_chat(owner, "<span class='warning'>The implant doesn't respond. It seems to be broken...</span>")
		return

	if(!active_item || (active_item in src))
		active_item = null
		if(contents.len == 1)
			Extend(contents[1])
		else
			var/list/choice_list = list()
			for(var/datum/weakref/augment_ref in items_list)
				var/obj/item/augment_item = augment_ref.resolve()
				if(!augment_item)
					items_list -= augment_ref
					continue
				choice_list[augment_item] = image(augment_item)
			var/obj/item/choice = show_radial_menu(owner, owner, choice_list)
			if(owner && owner == usr && owner.stat != DEAD && (src in owner.internal_organs) && !active_item && (choice in contents))
				// This monster sanity check is a nice example of how bad input is.
				Extend(choice)
	else
		Retract()


/obj/item/organ/cyberimp/arm/gun/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(prob(30/severity) && owner && !(organ_flags & ORGAN_FAILING))
		Retract()
		owner.visible_message("<span class='danger'>A loud bang comes from [owner]\'s [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm!</span>")
		playsound(get_turf(owner), 'sound/weapons/flashbang.ogg', 100, 1)
		to_chat(owner, "<span class='userdanger'>You feel an explosion erupt inside your [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm as your implant breaks!</span>")
		owner.adjust_fire_stacks(20)
		owner.IgniteMob()
		owner.adjustFireLoss(25)
		organ_flags |= ORGAN_FAILING


/obj/item/organ/cyberimp/arm/gun/laser
	name = "arm-mounted laser implant"
	desc = "A variant of the arm cannon implant that fires lethal laser beams. The cannon emerges from the subject's arm and remains inside when not in use."
	icon_state = "arm_laser"
	syndicate_implant = TRUE
	items_to_create = list(/obj/item/gun/energy/laser/mounted)

/obj/item/organ/cyberimp/arm/gun/laser/l
	zone = BODY_ZONE_L_ARM

/obj/item/organ/cyberimp/arm/gun/laser/Initialize(mapload)
	. = ..()
	var/obj/item/organ/cyberimp/arm/gun/laser/laserphasergun = locate(/obj/item/gun/energy/laser/mounted) in contents
	laserphasergun.icon = icon //No invisible laser guns kthx
	laserphasergun.icon_state = icon_state

/obj/item/organ/cyberimp/arm/gun/taser
	name = "arm-mounted taser implant"
	desc = "A variant of the arm cannon implant that fires electrodes and disabler shots. The cannon emerges from the subject's arm and remains inside when not in use."
	icon_state = "arm_taser"
	items_to_create = list(/obj/item/gun/energy/e_gun/advtaser/mounted)

/obj/item/organ/cyberimp/arm/gun/taser/l
	zone = BODY_ZONE_L_ARM

/obj/item/organ/cyberimp/arm/toolset
	name = "integrated toolset implant"
	desc = "A stripped-down version of the engineering cyborg toolset, designed to be installed on subject's arm. Contains advanced versions of every tool."
	items_to_create = list(/obj/item/screwdriver/cyborg, /obj/item/wrench/cyborg, /obj/item/weldingtool/cyborg,
		/obj/item/crowbar/cyborg, /obj/item/wirecutters/cyborg, /obj/item/multitool/cyborg)

/obj/item/organ/cyberimp/arm/toolset/l
	zone = BODY_ZONE_L_ARM

/obj/item/organ/cyberimp/arm/toolset/should_emag(mob/user)
	if(!..())
		return FALSE
	for(var/datum/weakref/created_item in items_list)
		var/obj/potential_blade = created_item.resolve()
		if(istype(/obj/item/melee/hydraulic_blade, potential_blade))
			return FALSE
	return TRUE

/obj/item/organ/cyberimp/arm/toolset/on_emag(mob/user)
	..()
	to_chat(user, "<span class='notice'>You unlock [src]'s integrated blade!</span>")
	items_list += WEAKREF(new /obj/item/melee/hydraulic_blade(src))

/obj/item/organ/cyberimp/arm/esword
	name = "arm-mounted energy blade"
	desc = "An illegal and highly dangerous cybernetic implant that can project a deadly blade of concentrated energy."
	syndicate_implant = TRUE
	items_to_create = list(/obj/item/melee/transforming/energy/blade/hardlight)

/obj/item/organ/cyberimp/arm/medibeam
	name = "integrated medical beamgun"
	desc = "A cybernetic implant that allows the user to project a healing beam from their hand."
	items_to_create = list(/obj/item/gun/medbeam)


/obj/item/organ/cyberimp/arm/flash
	name = "integrated high-intensity photon projector" //Why not
	desc = "An integrated projector mounted onto a user's arm that is able to be used as a powerful flash."
	items_to_create = list(/obj/item/assembly/flash/armimplant)

/obj/item/organ/cyberimp/arm/flash/Initialize(mapload)
	. = ..()
	for(var/datum/weakref/created_item in items_list)
		var/obj/potential_flash = created_item.resolve()
		if(!istype(potential_flash, /obj/item/assembly/flash/armimplant))
			continue
		var/obj/item/assembly/flash/armimplant/flash = potential_flash
		flash.arm = WEAKREF(src)

/obj/item/organ/cyberimp/arm/flash/Extend()
	. = ..()
	active_item.set_light(7)

/obj/item/organ/cyberimp/arm/flash/Retract()
	active_item?.set_light(0)
	return ..()

/obj/item/organ/cyberimp/arm/baton
	name = "arm electrification implant"
	desc = "An illegal combat implant that allows the user to administer disabling shocks from their arm."
	syndicate_implant = TRUE
	items_to_create = list(/obj/item/borg/stun)

/obj/item/organ/cyberimp/arm/combat
	name = "combat cybernetics implant"
	desc = "A powerful cybernetic implant that contains combat modules built into the user's arm."
	syndicate_implant = TRUE
	items_to_create = list(/obj/item/melee/transforming/energy/blade/hardlight, /obj/item/gun/medbeam, /obj/item/borg/stun, /obj/item/assembly/flash/armimplant)

/obj/item/organ/cyberimp/arm/combat/Initialize(mapload)
	. = ..()
	for(var/datum/weakref/created_item in items_list)
		var/obj/potential_flash = created_item.resolve()
		if(!istype(potential_flash, /obj/item/assembly/flash/armimplant))
			continue
		var/obj/item/assembly/flash/armimplant/flash = potential_flash
		flash.arm = WEAKREF(src)

/obj/item/organ/cyberimp/arm/surgery
	name = "surgical toolset implant"
	desc = "A set of surgical tools hidden behind a concealed panel on the user's arm."
	items_to_create = list(/obj/item/retractor/augment, /obj/item/hemostat/augment, /obj/item/cautery/augment, /obj/item/surgicaldrill/augment, /obj/item/scalpel/augment, /obj/item/circular_saw/augment, /obj/item/surgical_drapes)

/obj/item/organ/cyberimp/arm/power_cord
	name = "power cord implant"
	desc = "An internal power cord hooked up to a battery. Useful if you run on volts."
	items_to_create = list(/obj/item/apc_powercord)
	zone = "l_arm"

/obj/item/organ/cyberimp/arm/esaw
	name = "arm-mounted energy saw"
	desc = "An illegal and highly dangerous implanted carbon-fiber blade with a toggleable hard-light edge."
	icon_state = "implant-esaw_0"
	syndicate_implant = TRUE
	items_to_create = list(/obj/item/melee/transforming/energy/sword/esaw/implant)

/obj/item/organ/cyberimp/arm/hydraulic_blade
	name = "arm-mounted hydraulic blade"
	desc = "Highly dangerous implanted plasteel blade."
	icon_state = "hydraulic_blade"
	items_to_create = list(/obj/item/melee/hydraulic_blade)

/obj/item/organ/cyberimp/arm/hydraulic_blade/l
	zone = BODY_ZONE_L_ARM

/obj/item/organ/cyberimp/arm/botany
	name = "botanical arm implant"
	desc = "A rather simple arm implant containing tools used in gardening and botanical research."
	items_to_create = list(/obj/item/cultivator, /obj/item/shovel/spade, /obj/item/hatchet, /obj/item/plant_analyzer, /obj/item/storage/bag/plants/portaseeder/compact)

/obj/item/organ/cyberimp/arm/janitor
	name = "janitorial tools implant"
	desc = "A set of janitorial tools on the user's arm."
	items_to_create = list(/obj/item/lightreplacer/cyborg, /obj/item/holosign_creator/janibarrier, /obj/item/soap/nanotrasen, /obj/item/reagent_containers/spray/cyborg/drying_agent, /obj/item/mop/advanced/cyborg, /obj/item/paint/paint_remover, /obj/item/reagent_containers/spray/cleaner)

/obj/item/organ/cyberimp/arm/janitor/on_emag(mob/user)
	..()
	to_chat(usr, "<span class='notice'>You unlock [src]'s integrated deluxe cleaning supplies!</span>")
	items_list += WEAKREF(new /obj/item/soap/syndie(src)) //We add not replace.
	items_list += WEAKREF(new /obj/item/reagent_containers/spray/cyborg/lube(src))
	return TRUE
