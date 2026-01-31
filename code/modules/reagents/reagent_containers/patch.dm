/obj/item/reagent_containers/pill/patch
	name = "chemical patch"
	desc = "A chemical patch for touch based applications."
	icon = 'icons/obj/medicine_containers.dmi'
	icon_state = "bandaid_small_cross"
	inhand_icon_state = "bandaid_small_cross"
	volume = 40
	apply_type = PATCH
	apply_method = "apply"
	self_delay = 3 SECONDS
	dissolvable = FALSE

/obj/item/reagent_containers/pill/patch/attack(mob/living/L, mob/user)
	if(!ishuman(L))
		return ..()
	var/datum/task/select_bodyzone = user.select_bodyzone(L, FALSE, BODYZONE_STYLE_MEDICAL)
	select_bodyzone.continue_with(CALLBACK(src, PROC_REF(apply_part), L, user))
	return TRUE

/obj/item/reagent_containers/pill/patch/proc/apply_part(mob/living/L, mob/user, selected_target)
	if (!selected_target)
		return
	if (!user.can_interact_with(L, TRUE))
		balloon_alert(user, "[L] is too far away!")
		return
	if (!user.can_interact_with(src, TRUE))
		balloon_alert(user, "[src] is too far away!")
		return
	var/obj/item/bodypart/affecting = L.get_bodypart(selected_target)
	if(!affecting)
		balloon_alert(user, "The limb is missing.")
		return
	if(!IS_ORGANIC_LIMB(affecting))
		balloon_alert(user, "[src] won't work on an inorganic limb!")
		return
	perform_application(L, user, affecting)

/obj/item/reagent_containers/pill/patch/canconsume(mob/eater, mob/user)
	if(!iscarbon(eater))
		return FALSE
	return TRUE // Masks were stopping people from "eating" patches. Thanks, inheritance.

/obj/item/reagent_containers/pill/patch/styptic
	name = "brute patch"
	desc = "Helps with brute injuries."
	list_reagents = list(/datum/reagent/medicine/styptic_powder = 30)
	icon_state = "bandaid_big_brute"

/obj/item/reagent_containers/pill/patch/silver_sulf
	name = "burn patch"
	desc = "Helps with burn injuries."
	list_reagents = list(/datum/reagent/medicine/silver_sulfadiazine = 30)
	icon_state = "bandaid_big_burn"

/obj/item/reagent_containers/pill/patch/synthflesh
	name = "synthflesh patch"
	desc = "Helps with brute and burn injuries."
	list_reagents = list(/datum/reagent/medicine/synthflesh = 30)
	icon_state = "bandaid_big_both"
