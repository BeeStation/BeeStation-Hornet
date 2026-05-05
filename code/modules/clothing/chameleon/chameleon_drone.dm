/datum/action/item_action/chameleon/drone/randomise
	name = "Randomise Headgear"
	button_icon = 'icons/hud/actions/actions_items.dmi'
	button_icon_state = "random"

/datum/action/item_action/chameleon/drone/randomise/on_activate(mob/user, atom/target)
	for(var/datum/action/item_action/chameleon/change/to_randomize in owner.actions)
		to_randomize.random_look()
	return TRUE

/datum/action/item_action/chameleon/drone/togglehatmask
	name = "Toggle Headgear Mode"
	button_icon = 'icons/hud/actions/actions_silicon.dmi'

/datum/action/item_action/chameleon/drone/togglehatmask/New(master)
	. = ..()
	if (istype(master, /obj/item/clothing/head/chameleon/drone))
		button_icon_state = "drone_camogear_helm"
	if (istype(master, /obj/item/clothing/mask/chameleon/drone))
		button_icon_state = "drone_camogear_mask"

/datum/action/item_action/chameleon/drone/togglehatmask/is_available(feedback = FALSE)
	return ..() && isdrone(owner)

/datum/action/item_action/chameleon/drone/togglehatmask/on_activate(mob/user, atom/target)
	var/mob/living/simple_animal/drone/droney

	// The drone unEquip() proc sets head to null after dropping
	// an item, so we need to keep a reference to our old headgear
	// to make sure it's deleted.
	var/obj/old_headgear = target
	var/obj/new_headgear

	if(istype(old_headgear, /obj/item/clothing/head/chameleon/drone))
		new_headgear = new /obj/item/clothing/mask/chameleon/drone(droney)
	else if(istype(old_headgear, /obj/item/clothing/mask/chameleon/drone))
		new_headgear = new /obj/item/clothing/head/chameleon/drone(droney)
	else
		to_chat(owner, span_warning("You shouldn't be able to toggle a camogear helmetmask if you're not wearing it"))
		return FALSE

	droney.dropItemToGround(target, force = TRUE)
	qdel(old_headgear)
	droney.equip_to_slot_or_del(new_headgear, ITEM_SLOT_HEAD)
	return TRUE
