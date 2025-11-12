/datum/action/vampire/quickness
	name = "Quickness"
	desc = "Focus the your full speed into your hands, enabling you to attack with preternatural speed."
	button_icon_state = "power_quickness"
	power_explanation = "Imbues your hands with supernatural speed. Cannot be used with gloves on.\n\
						Use with combat mode. Does not require you to click on a target directly to hit them."
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	sol_multiplier = 2
	cooldown_time = 30 SECONDS
	constant_bloodcost = 5

	// Ref to the item
	var/datum/weakref/item_ref
	var/mob/living/carbon/carbon_owner

/datum/action/vampire/quickness/Grant()
	. = ..()
	carbon_owner = owner

/datum/action/vampire/quickness/can_use()
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/carbon_owner = owner

	if(carbon_owner.gloves)
		if(istype(carbon_owner.gloves, /obj/item/clothing/gloves/rapid/vampire))
			return TRUE
		owner.balloon_alert(owner, "you're wearing gloves!")
		return FALSE
	return TRUE

/datum/action/vampire/quickness/activate_power()
	. = ..()

	var/obj/item/clothing/gloves/rapid/vampire/the_gloves = new /obj/item/clothing/gloves/rapid/vampire()

	item_ref = WEAKREF(the_gloves)

	carbon_owner.equip_to_slot_or_del(the_gloves, ITEM_SLOT_GLOVES)

/datum/action/vampire/quickness/deactivate_power()
	. = ..()
	qdel(item_ref)
