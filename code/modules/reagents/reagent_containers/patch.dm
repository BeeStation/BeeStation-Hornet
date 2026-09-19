/obj/item/reagent_containers/applicator/patch
	name = "chemical patch"
	desc = "A chemical patch for touch based applications."
	icon = 'icons/obj/medicine_containers.dmi'
	icon_state = "bandaid_small_cross"
	inhand_icon_state = "bandaid_small_cross"
	volume = 40
	apply_method = "apply"
	// Quick to apply
	application_delay = 1.5 SECONDS
	self_delay = 1.5 SECONDS

/obj/item/reagent_containers/applicator/patch/canconsume(mob/eater, mob/user)
	return TRUE // Masks were stopping people from "eating" patches. Thanks, inheritance.

/obj/item/reagent_containers/applicator/patch/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!ishuman(interacting_with))
		return NONE

	var/datum/task/select_bodyzone = user.select_bodyzone(interacting_with, FALSE, BODYZONE_STYLE_MEDICAL)
	select_bodyzone.continue_with(CALLBACK(src, PROC_REF(apply_part), interacting_with, user))
	return ITEM_INTERACT_SUCCESS // let's just assume it succeeded. we'll want to exit the attack chain either way

/obj/item/reagent_containers/applicator/patch/proc/apply_part(mob/living/carbon/human/target, mob/user, selected_target)
	if (!selected_target)
		return
	if (!user.can_interact_with(target, TRUE))
		balloon_alert(user, "[target] is too far away!")
		return
	if (!user.can_interact_with(src, TRUE))
		balloon_alert(user, "[src] is too far away!")
		return
	var/obj/item/bodypart/affecting = target.get_bodypart(selected_target)
	if(!affecting)
		balloon_alert(user, "The limb is missing.")
		return
	if(!IS_ORGANIC_LIMB(affecting))
		balloon_alert(user, "[src] doesn't work on robotic limbs.")
		return
	attempt_application(target, user, affecting)

/obj/item/reagent_containers/applicator/patch/on_consumption(mob/consumer, mob/giver, obj/item/bodypart/affected_limb)
	if(reagents.total_volume)
		reagents.expose(consumer, PATCH, affecting = affected_limb)
	qdel(src)

/obj/item/reagent_containers/applicator/patch/styptic
	name = "brute patch"
	desc = "Helps with brute injuries."
	list_reagents = list(/datum/reagent/medicine/styptic_powder = 30)
	icon_state = "bandaid_big_brute"

/obj/item/reagent_containers/applicator/patch/silver_sulf
	name = "burn patch"
	desc = "Helps with burn injuries."
	list_reagents = list(/datum/reagent/medicine/silver_sulfadiazine = 30)
	icon_state = "bandaid_big_burn"

/obj/item/reagent_containers/applicator/patch/synthflesh
	name = "synthflesh patch"
	desc = "Helps with brute and burn injuries."
	list_reagents = list(/datum/reagent/medicine/synthflesh = 30)
	icon_state = "bandaid_big_both"

/obj/item/reagent_containers/applicator/patch/mixbrute
	name = "premium brute patch"
	desc = "Helps with brute injuries."
	list_reagents = list(/datum/reagent/medicine/bicaridine = 10, /datum/reagent/medicine/sal_acid = 10)
	icon_state = "bandaid_big_brute"

/obj/item/reagent_containers/applicator/patch/mixburn
	name = "premium burn patch"
	desc = "Helps with burn injuries."
	list_reagents = list(/datum/reagent/medicine/kelotane = 10, /datum/reagent/medicine/oxandrolone = 10)
	icon_state = "bandaid_big_burn"
