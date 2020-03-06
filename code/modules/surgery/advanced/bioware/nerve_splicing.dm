/datum/surgery/advanced/bioware/nerve_splicing
	name = "Nerve Splicing"
	desc = "A surgical procedure which splices the patient's nerves, making them more resistant to stuns."
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/incise,
				/datum/surgery_step/incise,
				/datum/surgery_step/splice_nerves,
				/datum/surgery_step/close)
	possible_locs = list(BODY_ZONE_CHEST)
	bioware_target = BIOWARE_NERVES

/datum/surgery_step/splice_nerves
	name = "splice nerves"
	accept_hand = TRUE
	time = 155

/datum/surgery_step/splice_nerves/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You start splicing together [target]'s nerves.</span>",
		"[user] starts splicing together [target]'s nerves.",
		"[user] starts manipulating [target]'s nervous system.")

/datum/surgery_step/splice_nerves/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You successfully splice [target]'s nervous system!</span>",
		"[user] successfully splices [target]'s nervous system!",
		"[user] finishes manipulating [target]'s nervous system.")
	new /datum/bioware/spliced_nerves(target)
	return TRUE

/datum/bioware/spliced_nerves
	name = "Spliced Nerves"
	desc = "Nerves are connected to each other multiple times, greatly reducing the impact of stunning effects."
	mod_type = BIOWARE_NERVES

/datum/bioware/spliced_nerves/on_gain()
	..()
	owner.physiology.stun_mod *= 0.5

/datum/bioware/spliced_nerves/on_lose()
	..()
	owner.physiology.stun_mod *= 2