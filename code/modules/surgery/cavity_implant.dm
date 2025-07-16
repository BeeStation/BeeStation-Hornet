/datum/surgery/cavity_implant
	name = "cavity implant"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/incise, /datum/surgery_step/handle_cavity, /datum/surgery_step/close)
	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_CHEST)
	self_operable = TRUE


//handle cavity
/datum/surgery_step/handle_cavity
	name = "implant item"
	accept_hand = 1
	implements = list(/obj/item = 100)
	repeatable = TRUE
	time = 32
	var/obj/item/IC = null
	preop_sound = 'sound/surgery/organ1.ogg'
	success_sound = 'sound/surgery/organ2.ogg'

/datum/surgery_step/handle_cavity/tool_check(mob/user, obj/item/tool)
	if(tool.tool_behaviour == TOOL_CAUTERY || istype(tool, /obj/item/gun/energy/laser))
		return FALSE
	return !tool.is_hot()

/datum/surgery_step/handle_cavity/preop(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/bodypart/chest/CH = target.get_bodypart(BODY_ZONE_CHEST)
	IC = CH.cavity_item
	if(tool)
		display_results(user, target, span_notice("You begin to insert [tool] into [target]'s [target_zone]..."),
			"[user] begins to insert [tool] into [target]'s [target_zone].",
			"[user] begins to insert [tool.w_class > WEIGHT_CLASS_SMALL ? tool : "something"] into [target]'s [target_zone].")
		//Incase they are interupted mid-insert, log it; shows intent to implant
		log_combat(user, target, "tried to cavity implant [tool.name] into")
	else
		display_results(user, target, span_notice("You check for items in [target]'s [target_zone]..."),
			"[user] checks for items in [target]'s [target_zone].",
			"[user] looks for something in [target]'s [target_zone].")
		log_combat(user, target, "searched for cavity item [IC ? "([IC.name])" : null] in")

/datum/surgery_step/handle_cavity/success(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery = FALSE)
	var/obj/item/bodypart/chest/CH = target.get_bodypart(BODY_ZONE_CHEST)
	if(tool)
		if(IC || tool.w_class > WEIGHT_CLASS_NORMAL || HAS_TRAIT(tool, TRAIT_NODROP) || istype(tool, /obj/item/organ))
			to_chat(user, span_warning("You can't seem to fit [tool] in [target]'s [target_zone]!"))
			return 0
		else
			display_results(user, target, span_notice("You stuff [tool] into [target]'s [target_zone]."),
				"[user] stuffs [tool] into [target]'s [target_zone]!",
				"[user] stuffs [tool.w_class > WEIGHT_CLASS_SMALL ? tool : "something"] into [target]'s [target_zone].")
			user.transferItemToLoc(tool, target, TRUE)
			CH.cavity_item = tool
			//Logs stowing items in a cavity, similar to organ manipulation
			log_combat(user, target, "cavity implanted [tool.name] into")
			return ..()
	else
		if(IC)
			display_results(user, target, span_notice("You pull [IC] out of [target]'s [target_zone]."),
				"[user] pulls [IC] out of [target]'s [target_zone]!",
				"[user] pulls [IC.w_class > WEIGHT_CLASS_SMALL ? IC : "something"] out of [target]'s [target_zone].")
			user.put_in_hands(IC)
			CH.cavity_item = null
			//Log when cavity items are surgically removed, we don't care about it popping out from gibbing
			log_combat(user, target, "extracted [IC.name] from cavity in")
			return ..()
		else
			to_chat(user, span_warning("You don't find anything in [target]'s [target_zone]."))
			return 0
