/datum/surgery/advanced/revival
	name = "Revival"
	desc = "An experimental surgical procedure which involves reconstruction and reactivation of the patient's brain even long after death. The body must still be able to sustain life."
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/saw,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/incise,
				/datum/surgery_step/revive,
				/datum/surgery_step/close)

	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_HEAD)
	requires_bodypart_type = 0

/datum/surgery/advanced/revival/can_start(mob/user, mob/living/carbon/target)
	if(!..())
		return FALSE
	if(target.stat != DEAD)
		return FALSE
	if(target.suiciding || target.hellbound || HAS_TRAIT(target, TRAIT_HUSK))
		return FALSE
	var/obj/item/organ/brain/B = target.getorganslot(ORGAN_SLOT_BRAIN)
	if(!B)
		return FALSE
	return TRUE

/datum/surgery_step/revive
	name = "revive body"
	implements = list(/obj/item/twohanded/shockpaddles = 100, /obj/item/melee/baton = 75, /obj/item/gun/energy = 60)
	time = 120

/datum/surgery_step/revive/tool_check(mob/user, obj/item/tool)
	. = TRUE
	if(istype(tool, /obj/item/twohanded/shockpaddles))
		var/obj/item/twohanded/shockpaddles/S = tool
		if((S.req_defib && !S.defib.powered) || !S.wielded || S.cooldown || S.busy)
			to_chat(user, "<span class='warning'>You need to wield both paddles, and [S.defib] must be powered!</span>")
			return FALSE
	if(istype(tool, /obj/item/melee/baton))
		var/obj/item/melee/baton/B = tool
		if(!B.turned_on)
			to_chat(user, "<span class='warning'>[B] needs to be active!</span>")
			return FALSE
	if(istype(tool, /obj/item/gun/energy))
		var/obj/item/gun/energy/E = tool
		if(E.chambered && istype(E.chambered, /obj/item/ammo_casing/energy/electrode))
			return TRUE
		else
			to_chat(user, "<span class='warning'>You need an electrode for this!</span>")
			return FALSE

/datum/surgery_step/revive/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You prepare to give [target]'s brain the spark of life with [tool].</span>",
		"[user] prepares to shock [target]'s brain with [tool].",
		"[user] prepares to shock [target]'s brain with [tool].")
	target.notify_ghost_cloning("Someone is trying to zap your brain!", source = target)

/datum/surgery_step/revive/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You successfully shock [target]'s brain with [tool]...</span>",
		"[user] send a powerful shock to [target]'s brain with [tool]...",
		"[user] send a powerful shock to [target]'s brain with [tool]...")
	playsound(get_turf(target), 'sound/magic/lightningbolt.ogg', 50, 1)
	target.grab_ghost()
	target.adjustOxyLoss(-50, 0)
	target.updatehealth()
	if(target.revive())
		target.visible_message("...[target] wakes up, alive and aware!")
		target.emote("gasp")
		target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 50, 199) //MAD SCIENCE
		return TRUE
	else
		target.visible_message("...[target.p_they()] convulses, then lies still.")
		return FALSE

/datum/surgery_step/revive/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You shock [target]'s brain with [tool], but [target.p_they()] doesn't react.</span>",
		"[user] send a powerful shock to [target]'s brain with [tool], but [target.p_they()] doesn't react.",
		"[user] send a powerful shock to [target]'s brain with [tool], but [target.p_they()] doesn't react.")
	playsound(get_turf(target), 'sound/magic/lightningbolt.ogg', 50, 1)
	target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 15, 180)
	return FALSE