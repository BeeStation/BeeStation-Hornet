//open shell
/datum/surgery_step/mechanic_open
	name = "unscrew shell"
	implements = list(
		TOOL_SCREWDRIVER		= 100,
		TOOL_SCALPEL 			= 75, // med borgs could try to unskrew shell with scalpel
		/obj/item/kitchen/knife	= 50,
		/obj/item				= 10) // 10% success with any sharp item.
	time = 24
	preop_sound = 'sound/items/screwdriver.ogg'
	success_sound = 'sound/items/screwdriver2.ogg'

/datum/surgery_step/mechanic_open/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to unscrew the shell of [target]'s [parse_zone(target_zone)]...</span>",
			"[user] begins to unscrew the shell of [target]'s [parse_zone(target_zone)].",
			"[user] begins to unscrew the shell of [target]'s [parse_zone(target_zone)].")

/datum/surgery_step/mechanic_incise/tool_check(mob/user, obj/item/tool)
	if(implement_type == /obj/item && !tool.is_sharp())
		return FALSE
	if(tool.usesound)
		preop_sound = tool.usesound

	return TRUE

//close shell
/datum/surgery_step/mechanic_close
	name = "screw shell"
	implements = list(
		TOOL_SCREWDRIVER		= 100,
		TOOL_SCALPEL 			= 75,
		/obj/item/kitchen/knife	= 50,
		/obj/item				= 10) // 10% success with any sharp item.
	time = 24
	preop_sound = 'sound/items/screwdriver.ogg'
	success_sound = 'sound/items/screwdriver2.ogg'

/datum/surgery_step/mechanic_close/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to screw the shell of [target]'s [parse_zone(target_zone)]...</span>",
			"[user] begins to screw the shell of [target]'s [parse_zone(target_zone)].",
			"[user] begins to screw the shell of [target]'s [parse_zone(target_zone)].")

/datum/surgery_step/mechanic_close/tool_check(mob/user, obj/item/tool)
	if(implement_type == /obj/item && !tool.is_sharp())
		return FALSE
	if(tool.usesound)
		preop_sound = tool.usesound

	return TRUE

//prepare electronics
/datum/surgery_step/prepare_electronics
	name = "prepare electronics"
	implements = list(
		TOOL_MULTITOOL = 100,
		TOOL_HEMOSTAT = 10) // try to reboot internal controllers via short circuit with some conductor
	time = 24
	preop_sound = 'sound/surgery/tape_flip.ogg'
	success_sound = 'sound/surgery/taperecorder_close.ogg'

/datum/surgery_step/prepare_electronics/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to prepare electronics in [target]'s [parse_zone(target_zone)]...</span>",
			"[user] begins to prepare electronics in [target]'s [parse_zone(target_zone)].",
			"[user] begins to prepare electronics in [target]'s [parse_zone(target_zone)].")

//unwrench
/datum/surgery_step/mechanic_unwrench
	name = "unwrench bolts"
	implements = list(
		TOOL_WRENCH = 100,
		TOOL_RETRACTOR = 10)
	time = 24
	preop_sound = 'sound/items/ratchet.ogg'

/datum/surgery_step/mechanic_unwrench/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to unwrench some bolts in [target]'s [parse_zone(target_zone)]...</span>",
			"[user] begins to unwrench some bolts in [target]'s [parse_zone(target_zone)].",
			"[user] begins to unwrench some bolts in [target]'s [parse_zone(target_zone)].")

//wrench
/datum/surgery_step/mechanic_wrench
	name = "wrench bolts"
	implements = list(
		TOOL_WRENCH = 100,
		TOOL_RETRACTOR = 10)
	time = 24
	preop_sound = 'sound/items/ratchet.ogg'

/datum/surgery_step/mechanic_wrench/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to wrench some bolts in [target]'s [parse_zone(target_zone)]...</span>",
			"[user] begins to wrench some bolts in [target]'s [parse_zone(target_zone)].",
			"[user] begins to wrench some bolts in [target]'s [parse_zone(target_zone)].")

//open hatch
/datum/surgery_step/open_hatch
	name = "open the hatch"
	accept_hand = 1
	time = 10
	preop_sound = 'sound/items/ratchet.ogg'
	preop_sound = 'sound/machines/doorclick.ogg'

/datum/surgery_step/open_hatch/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to open the hatch holders in [target]'s [parse_zone(target_zone)]...</span>",
		"[user] begins to open the hatch holders in [target]'s [parse_zone(target_zone)].",
		"[user] begins to open the hatch holders in [target]'s [parse_zone(target_zone)].")

//wirecutter
/datum/surgery_step/cut_wires
	name = "cut wires"
	implements = list(
		TOOL_WIRECUTTER			= 100,
		TOOL_SCALPEL 			= 65,
		/obj/item/kitchen/knife	= 40,
		/obj/item				= 10) // 10% success with any sharp item.
	time = 24
	preop_sound = 'sound/items/ratchet.ogg'

/datum/surgery_step/cut_wires/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to cut some wires in [target]'s [parse_zone(target_zone)]...</span>",
			"[user] begins to cut some wires in [target]'s [parse_zone(target_zone)].",
			"[user] begins to cut some wires in [target]'s [parse_zone(target_zone)].")

/datum/surgery_step/cut_wires/tool_check(mob/user, obj/item/tool)
	if(implement_type == /obj/item && !tool.is_sharp())
		return FALSE
	if(tool.usesound)
		preop_sound = tool.usesound

	return TRUE

//change or insert new wires
/datum/surgery_step/insert_wires
	name = "insert new wires"
	implements = list(
		/obj/item/stack/cable_coil = 100)
	time = 24
	preop_sound = 'sound/items/ratchet.ogg'

/datum/surgery_step/insert_wires/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to insert some wires in [target]'s [parse_zone(target_zone)]...</span>",
			"[user] begins to insert some wires in [target]'s [parse_zone(target_zone)].",
			"[user] begins to insert some wires in [target]'s [parse_zone(target_zone)].")

/datum/surgery_step/insert_wires/tool_check(mob/user, obj/item/stack/cable_coil/tool)
	if(tool.amount < 10)
		to_chat(user, "<span class='warning'>You need to have 10 pieces of wires to operate this.</span>")
		return FALSE
	if(tool.usesound)
		preop_sound = tool.usesound

	tool.amount -= 10
	return TRUE

//pulling out debris
/datum/surgery_step/pulling_out
	name = "pull out debris"
	implements = list(TOOL_HEMOSTAT = 100)
	time = 24
	preop_sound = 'sound/surgery/hemostat1.ogg'

/datum/surgery_step/pulling_out/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to pull out some debrisin [target]'s [parse_zone(target_zone)]...</span>",
		"[user] begins to pull out some debris in [target]'s [parse_zone(target_zone)].",
		"[user] begins to pull out some debris in [target]'s [parse_zone(target_zone)].")
