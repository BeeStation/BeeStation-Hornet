/obj/item/reagent_containers/pill/patch
	name = "chemical patch"
	desc = "A chemical patch for touch based applications."
	icon = 'icons/obj/medicine_containers.dmi'
	icon_state = "bandaid_small_cross"
	item_state = "bandaid_small_cross"
	volume = 40
	apply_type = PATCH
	apply_method = "apply"
	self_delay = 3 SECONDS
	dissolvable = FALSE

/obj/item/reagent_containers/pill/patch/attack(mob/living/L, mob/user)
	if(!ishuman(L))
		return ..()
	if (user.client?.prefs.)
	var/accurate_health = HAS_TRAIT(user, TRAIT_MEDICAL_HUD) || istype(user.get_inactive_held_item(), /obj/item/healthanalyzer)
	if (!accurate_health)
		to_chat(user, "<span class='warning'>You could more easilly determine how injured [L] was if you had a medical hud or a health analyser!</span>")
	var/datum/task/task = user.select_bodyzone(L, icon_callback = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(select_bodyzone_limb_health), accurate_health))
	task.continue_with(CALLBACK(src, PROC_REF(apply_part), L, user))
	return TRUE

/obj/item/reagent_containers/pill/patch/proc/apply_part(mob/living/L, mob/user, selected_target)
	if (!selected_target)
		return
	var/obj/item/bodypart/affecting = L.get_bodypart(selected_target)
	if(!affecting)
		balloon_alert(user, "The limb is missing.")
		return
	if(!IS_ORGANIC_LIMB(affecting))
		balloon_alert(user, "[src] doesn't work on robotic limbs.")
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
