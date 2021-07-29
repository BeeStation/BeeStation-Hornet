/obj/item/reagent_containers/pill/patch
	name = "chemical patch"
	desc = "A chemical patch for touch based applications."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bandaid"
	item_state = "bandaid"
	possible_transfer_amounts = list()
	volume = 40
	apply_type = PATCH
	apply_method = "apply"
	self_delay = 30		// three seconds
	dissolvable = FALSE

/obj/item/reagent_containers/pill/patch/attack(mob/living/L, mob/user)
	if(ishuman(L))
		var/obj/item/bodypart/affecting = L.get_bodypart(check_zone(user.zone_selected))
		if(!affecting)
			balloon_alert(user, "The limb is missing")
			return
		if(affecting.status != BODYPART_ORGANIC)
			balloon_alert(user, "It doesn't work on robotic limb")
			return
	..()

/obj/item/reagent_containers/pill/patch/canconsume(mob/eater, mob/user)
	if(!iscarbon(eater))
		return 0
	return 1 // Masks were stopping people from "eating" patches. Thanks, inheritance.

/obj/item/reagent_containers/pill/patch/styptic
	name = "brute patch"
	desc = "Helps with brute injuries."
	list_reagents = list(/datum/reagent/medicine/styptic_powder = 30)
	icon_state = "bandaid_brute"

/obj/item/reagent_containers/pill/patch/silver_sulf
	name = "burn patch"
	desc = "Helps with burn injuries."
	list_reagents = list(/datum/reagent/medicine/silver_sulfadiazine = 30)
	icon_state = "bandaid_burn"

/obj/item/reagent_containers/pill/patch/synthflesh
	name = "synthflesh patch"
	desc = "Helps with brute and burn injuries."
	list_reagents = list(/datum/reagent/medicine/synthflesh = 30)
	icon_state = "bandaid_both"
