/obj/item/poison_paper
	name = "poison paper"
	desc = "A sheet of paper which can be used to apply a toxin to the surface \
	of another item. The next person to make unprotected contact with the item will \
	receive the dose of the toxin. Make sure you use gloves when applying it to \
	prevent accidental poisoning."
	gender = NEUTER
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "toxin_slip"
	inhand_icon_state = "paper"
	worn_icon = 'icons/mob/clothing/head/costume.dmi'
	worn_icon_state = "paper"
	custom_fire_overlay = "paper_onfire_overlay"
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	drop_sound = 'sound/items/handling/paper_drop.ogg'
	pickup_sound =  'sound/items/handling/paper_pickup.ogg'
	throw_range = 1
	throw_speed = 1
	pressure_resistance = 0
	slot_flags = ITEM_SLOT_HEAD
	body_parts_covered = HEAD
	resistance_flags = FLAMMABLE
	max_integrity = 50
	dog_fashion = /datum/dog_fashion/head
	color = COLOR_WHITE
	dye_color = DYE_WHITE

/obj/item/poison_paper/Initialize(mapload)
	. = ..()
	create_reagents(10, INJECTABLE | ABSOLUTELY_GRINDABLE)
	update_appearance(UPDATE_ICON_STATE)

/obj/item/poison_paper/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if (!isitem(target))
		return ..()
	if (!reagents.total_volume)
		to_chat(user, span_warn("\The [src] has nothing on it!"))
		return ..()
	to_chat(user, span_notice("You begin to apply \the [src] to \the [target]."))
	if (!do_after(user, 3 SECONDS, target))
		return
	to_chat(user, span_notice("You successfully transfer the contact toxin from \the [src] to \the [target]."))
	target.AddComponent(/datum/component/transfer_reagents, reagents)
	update_appearance(UPDATE_ICON_STATE)
	SEND_SIGNAL(src, COMSIG_POISON_PAPER_APPLIED, target, user)

/obj/item/poison_paper/update_icon_state()
	if (reagents.total_volume > 0)
		icon_state = "[initial(icon_state)]"
	else
		icon_state = "[initial(icon_state)]_used"
	return ..()

/obj/item/poison_paper/on_reagent_change(changetype)
	. = ..()
	update_appearance(UPDATE_ICON_STATE)

/obj/item/poison_paper/sarin/Initialize(mapload)
	. = ..()
	reagents.add_reagent(/datum/reagent/toxin/sarin, 10)
	update_appearance(UPDATE_ICON_STATE)
