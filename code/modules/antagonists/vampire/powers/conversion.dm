/datum/action/vampire/conversion
	name = "Vampiric Conversion"
	desc = "Transform iron into fleshy mass, used for vampire structures"
	button_icon_state = "power_bleed"
	power_explanation = "Activate this power with iron in-hand to transform its vampiric counterpart. The material obtained from using this spell\
		can be used to construct vampire structures."
	power_flags = NONE
	check_flags = NONE
	purchase_flags = VAMPIRE_DEFAULT_POWER
	bloodcost = 50
	cooldown_time = 10 SECONDS

/datum/action/vampire/conversion/can_use()
	. = ..()
	if(!.)
		return FALSE

	var/obj/item/held_item = owner.get_active_held_item()
	if(!istype(held_item, /obj/item/stack/sheet/iron))
		return FALSE

/datum/action/vampire/conversion/activate_power()
	. = ..()
	var/obj/item/held_item = owner.get_active_held_item()
	if(istype(held_item, /obj/item/stack/sheet/iron))
		var/obj/item/stack/sheet/iron/iron = held_item
		var/quantity = iron.amount
		if(iron.use(quantity))
			var/fleshymass = new /obj/item/stack/sheet/fleshymass(get_turf(owner), quantity)
			owner.put_in_hands(fleshymass)
			to_chat(owner, span_warning("You bleed on the iron transforming it with your vampiric blood"))
			SEND_SOUND(owner, sound('sound/effects/magic.ogg', 0, 1, 25))
	deactivate_power()
