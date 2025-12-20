/datum/action/vampire/exactitude
	name = "Exactitude"
	desc = "Focus your powers into your hands, enabling you to attack with preternatural precision."
	button_icon_state = "power_exactitude"
	power_explanation = "Imbues your hands with supernatural precision. Cannot be used with gloves on.\n\
						Use with combat mode. When punching, you will automatically hit the closest being. Best used without moving your mouse at all."
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	sol_multiplier = 2
	cooldown_time = 30 SECONDS
	vitaecost = 50
	constant_vitaecost = 5

	// Ref to the item
	var/datum/weakref/item_ref
	var/mob/living/carbon/carbon_owner

/datum/action/vampire/exactitude/Grant()
	. = ..()
	carbon_owner = owner

/datum/action/vampire/exactitude/can_use()
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/carbon_owner = owner

	if(carbon_owner.gloves)
		if(istype(carbon_owner.gloves, /obj/item/clothing/gloves/rapid/vampire))
			return TRUE
		owner.balloon_alert(owner, "you're wearing gloves!")
		return FALSE

/datum/action/vampire/exactitude/activate_power()
	. = ..()

	var/obj/item/clothing/gloves/rapid/vampire/the_gloves = new /obj/item/clothing/gloves/rapid/vampire()

	item_ref = WEAKREF(the_gloves)

	carbon_owner.equip_to_slot_or_del(the_gloves, ITEM_SLOT_GLOVES)

/datum/action/vampire/exactitude/deactivate_power()
	. = ..()
	qdel(item_ref)
