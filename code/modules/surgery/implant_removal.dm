/datum/surgery/implant_removal
	name = "Implant removal"
	target_mobtypes = list(/mob/living)
	possible_locs = list(BODY_ZONE_CHEST)
	surgery_flags = SURGERY_REQUIRE_RESTING
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/extract_implant,
		/datum/surgery_step/close,
	)

//extract implant
/datum/surgery_step/extract_implant
	name = "extract implant (hemostat)"
	implements = list(
		TOOL_HEMOSTAT = 100,
		TOOL_CROWBAR = 65,
		/obj/item/kitchen/fork = 35)
	time = 64
	success_sound = 'sound/surgery/hemostat1.ogg'
	var/obj/item/implant/implant

/datum/surgery_step/extract_implant/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	for(var/obj/item/implant/O in target.implants)
		if (O.implant_flags & IMPLANT_HIDDEN)
			continue
		implant = O
		break
	if(implant)
		display_results(
			user,
			target,
			span_notice("You begin to extract [implant] from [target]'s [target_zone]..."),
			span_notice("[user] begins to extract [implant] from [target]'s [target_zone]."),
			span_notice("[user] begins to extract something from [target]'s [target_zone]."),
		)
		//Incase they are interupted mid-extraction, log it
		log_combat(user, target, "tried to extract [implant.name] from")
	else
		display_results(
			user,
			target,
			span_notice("You look for an implant in [target]'s [target_zone]..."),
			span_notice("[user] looks for an implant in [target]'s [target_zone]."),
			span_notice("[user] looks for something in [target]'s [target_zone]."),
		)
		//Doesn't matter if they finish or not, defaults to this if there are no implants
		log_combat(user, target, "implant checked")

/datum/surgery_step/extract_implant/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(implant)
		display_results(
			user,
			target,
			span_notice("You successfully remove [implant] from [target]'s [target_zone]."),
			span_notice("[user] successfully removes [implant] from [target]'s [target_zone]!"),
			span_notice("[user] successfully removes something from [target]'s [target_zone]!"),
		)
		implant.removed(target)

		//Logs removal of implants, similar to removal of organs during organ manipulation
		log_combat(user, target, "surgically extracted [implant.name] from")

		var/obj/item/implantcase/case
		for(var/obj/item/implantcase/ic in user.held_items)
			case = ic
			break
		if(!case)
			case = locate(/obj/item/implantcase) in get_turf(target)
		if(case && !case.imp)
			case.imp = implant
			implant.forceMove(case)
			case.update_icon()
			display_results(
				user,
				target,
				span_notice("You place [implant] into [case]."),
				span_notice("[user] places [implant] into [case]!"),
				span_notice("[user] places it into [case]!"),
			)
		else
			qdel(implant)

	else
		to_chat(user, span_warning("You can't find anything in [target]'s [target_zone]!"))
	return ..()

/datum/surgery/implant_removal/mechanic
	name = "Implant Removal"
	requires_bodypart_type = BODYTYPE_ROBOTIC
	target_mobtypes = list(/mob/living/carbon/human) // Simpler mobs don't have bodypart types
	surgery_flags = parent_type::surgery_flags | SURGERY_REQUIRE_LIMB
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/extract_implant,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close
	)
