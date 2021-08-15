/datum/surgery/advanced/bioware/muscled_veins
	name = "Vein Muscle Membrane"
	desc = "A surgical procedure which adds a muscled membrane to blood vessels, allowing them to pump blood without a heart."
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/incise,
				/datum/surgery_step/incise,
				/datum/surgery_step/thread_veins,
				/datum/surgery_step/close)
	possible_locs = list(BODY_ZONE_CHEST)
	bioware_target = BIOWARE_CIRCULATION

/datum/surgery_step/muscled_veins
	name = "shape vein muscles"
	accept_hand = TRUE
	time = 125

/datum/surgery_step/muscled_veins/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You start wrapping muscles around [target]'s circulatory system.</span>",
		"[user] starts wrapping muscles around [target]'s circulatory system.",
		"[user] starts manipulating [target]'s circulatory system.")

/datum/surgery_step/muscled_veins/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You reshape [target]'s circulatory system, adding a muscled membrane!</span>",
		"[user] reshapes [target]'s circulatory system, adding a muscled membrane!",
		"[user] finishes manipulating [target]'s circulatory system.")
	new /datum/bioware/muscled_veins(target)
	return TRUE

/datum/bioware/muscled_veins
	name = "Threaded Veins"
	desc = "The circulatory system is woven into a mesh, severely reducing the amount of blood lost from wounds."
	mod_type = BIOWARE_CIRCULATION

/datum/bioware/muscled_veins/on_gain()
	..()
	ADD_TRAIT(owner, TRAIT_STABLEHEART, "muscled_veins")

/datum/bioware/muscled_veins/on_lose()
	..()
	REMOVE_TRAIT(owner, TRAIT_STABLEHEART, "muscled_veins")