/datum/surgery/implant_removal
	name = "Implant removal"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/extract_implant, /datum/surgery_step/close)
	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_CHEST)

//extract implant
/datum/surgery_step/extract_implant
	name = "extract implant"
	implements = list(TOOL_HEMOSTAT = 100, TOOL_CROWBAR = 65)
	time = 64
	var/obj/item/implant/I = null
	success_sound = 'sound/surgery/hemostat1.ogg'

/datum/surgery_step/extract_implant/preop(mob/user, mob/living/carbon/target, obj/item/tool, datum/surgery/surgery)
	for(var/obj/item/O in target.implants)
		I = O
		break
	if(I)
		display_results(user, target, "<span class='notice'>You begin to extract [I] from [target]'s [surgery.location]...</span>",
			"[user] begins to extract [I] from [target]'s [surgery.location].",
			"[user] begins to extract something from [target]'s [surgery.location].")
		//Incase they are interupted mid-extraction, log it
		log_combat(user, target, "tried to extract [I.name] from")
	else
		display_results(user, target, "<span class='notice'>You look for an implant in [target]'s [surgery.location]...</span>",
			"[user] looks for an implant in [target]'s [surgery.location].",
			"[user] looks for something in [target]'s [surgery.location].")
		//Doesn't matter if they finish or not, defaults to this if there are no implants
		log_combat(user, target, "implant checked")

/datum/surgery_step/extract_implant/success(mob/user, mob/living/carbon/target, obj/item/tool, datum/surgery/surgery)
	if(I)
		display_results(user, target, "<span class='notice'>You successfully remove [I] from [target]'s [surgery.location].</span>",
			"[user] successfully removes [I] from [target]'s [surgery.location]!",
			"[user] successfully removes something from [target]'s [surgery.location]!")
		I.removed(target)

		//Logs removal of implants, similar to removal of organs during organ manipulation
		log_combat(user, target, "surgically extracted [I.name] from")

		var/obj/item/implantcase/case
		for(var/obj/item/implantcase/ic in user.held_items)
			case = ic
			break
		if(!case)
			case = locate(/obj/item/implantcase) in get_turf(target)
		if(case && !case.imp)
			case.imp = I
			I.forceMove(case)
			case.update_icon()
			display_results(user, target, "<span class='notice'>You place [I] into [case].</span>",
				"[user] places [I] into [case]!",
				"[user] places it into [case]!")
		else
			qdel(I)

	else
		to_chat(user, "<span class='warning'>You can't find anything in [target]'s [surgery.location]!</span>")
	return 1

/datum/surgery/implant_removal/mechanic
	name = "implant removal"
	requires_bodypart_type = BODYTYPE_ROBOTIC
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/extract_implant,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close)
