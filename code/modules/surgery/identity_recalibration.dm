
/////RENAMING SURGERY//////


//SURGERY STEP

/datum/surgery_step/rename
	name = "swipe ID"
	implements = list(/obj/item/card/id = 100)
	time = 10
	repeatable = TRUE

//SURGERY

/datum/surgery/rename
	name = "Identity Recalibration"
	steps = list(
			/datum/surgery_step/mechanic_open,
			/datum/surgery_step/open_hatch,
			/datum/surgery_step/prepare_electronics,
			/datum/surgery_step/rename,
			/datum/surgery_step/mechanic_close,
			)
	target_mobtypes = list(/mob/living/carbon/human)
	possible_locs = list(BODY_ZONE_CHEST)
	requires_real_bodypart = TRUE
	requires_bodypart_type = BODYTYPE_ROBOTIC
	lying_required = FALSE
	self_operable = TRUE

//SURGERY STEP SUCCESS

/datum/surgery_step/rename/success(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!tool)
		return
	var/old_name = target.real_name
	var/obj/item/card/id/id = tool
	if(id.registered_name)
		target.real_name = id.registered_name
		display_results(user, target, span_notice("You successfully recalibrated [old_name]'s identity!"),
		"[user] successfully recalibrated [old_name]'s identity with [tool]!",
		"[user] successfully recalibrated [old_name]'s identity!")
		log_combat(user, target, "renamed", addition="changed [old_name]'s name to [id.registered_name]")
	else
		target.real_name = "????"
		to_chat(user, span_warning("The lack of registered name on the card has lead to a glitch!"))
		log_combat(user, target, "renamed", addition="changed [old_name] to ????")
	return TRUE
