#define THERMAL_REGULATOR_COST 25 WATT // the cost per tick for the thermal regulator

//Note:	Everything in modules/clothing/spacesuits should have the entire suit grouped together.
//		Meaning the the suit is defined directly after the corrisponding helmet. Just like below!
/obj/item/clothing/head/helmet/space
	name = "space helmet"
	icon = 'icons/obj/clothing/head/spacehelm.dmi'
	worn_icon = 'icons/mob/clothing/head/spacehelm.dmi'
	icon_state = "spaceold"
	inhand_icon_state = "space_helmet"
	desc = "A special helmet with solar UV shielding to protect your eyes from harmful rays."
	clothing_flags = STOPSPRESSUREDAMAGE | SNUG_FIT | HEADINTERNALS
	armor_type = /datum/armor/helmet_space
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	dynamic_hair_suffix = ""
	dynamic_fhair_suffix = ""
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	flash_protect = FLASH_PROTECTION_WELDER
	strip_delay = 50
	equip_delay_other = 50
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	resistance_flags = NONE
	dog_fashion = null
	var/obj/item/clothing/head/attached_hat
	custom_price = 75

/datum/armor/helmet_space
	bio = 100
	fire = 80
	acid = 70
	stamina = 10
	bleed = 50

/obj/item/clothing/head/helmet/space/Initialize(mapload)
	. = ..()
	remove_verb(/obj/item/clothing/head/helmet/space/verb/unattach_hat)

/obj/item/clothing/head/helmet/space/Destroy()
	if (attached_hat)
		if (attached_hat.resistance_flags & INDESTRUCTIBLE)
			attached_hat.forceMove(get_turf(src))
		else
			QDEL_NULL(attached_hat)
	..()

/obj/item/clothing/head/helmet/space/attackby(obj/item/item, mob/living/user)
	. = ..()
	if(istype(item, /obj/item/clothing/head) \
		// i know someone is gonna do it after i thought about it
		&& !istype(item, /obj/item/clothing/head/helmet/space) \
		// messy and icon can't be seen before putting on
		&& !istype(item, /obj/item/clothing/head/costume/foilhat))
		var/obj/item/clothing/head/hat = item
		if(attached_hat)
			to_chat(user, span_notice("There's already a hat on the helmet!"))
			return
		attached_hat = hat
		hat.forceMove(src)
		if (user.get_item_by_slot(ITEM_SLOT_HEAD) == src)
			hat.equipped(user, ITEM_SLOT_HEAD)
		update_icon()
		update_button_icons(user)
		add_verb(/obj/item/clothing/head/helmet/space/verb/unattach_hat)

/obj/item/clothing/head/helmet/space/proc/update_button_icons(mob/user)
	if(!user)
		return

	//The icon's may look differently due to overlays being applied asynchronously
	for(var/X in actions)
		var/datum/action/A=X
		A.update_buttons()

/obj/item/clothing/head/helmet/space/equipped(mob/user, slot)
	. = ..()
	attached_hat?.equipped(user, slot)

/obj/item/clothing/head/helmet/space/dropped(mob/user)
	. = ..()
	attached_hat?.dropped(user)

/obj/item/clothing/head/helmet/space/worn_overlays(mutable_appearance/standing, isinhands = FALSE, icon_file, item_layer, atom/origin)
	. = ..()
	if(!isinhands)
		if(attached_hat)
			. += attached_hat.build_worn_icon(default_layer = HEAD_LAYER, default_icon_file = 'icons/mob/clothing/head/default.dmi')

/obj/item/clothing/head/helmet/space/verb/unattach_hat()
	set name = "Remove Hat"
	set category = "Object"
	set src in usr

	usr.put_in_hands(attached_hat)
	if (usr.get_item_by_slot(ITEM_SLOT_HEAD) == src)
		attached_hat.dropped(usr)
	attached_hat = null
	update_icon()
	remove_verb(/obj/item/clothing/head/helmet/space/verb/unattach_hat)

/obj/item/clothing/head/helmet/space/examine(mob/user)
	. = ..()
	if(attached_hat)
		. += span_notice("There's \a [attached_hat.name] on the helmet which can be removed through the context menu.")
	else
		. += span_notice("A hat can be placed on the helmet.")

/obj/item/clothing/suit/space
	name = "space suit"
	desc = "A suit that protects against low pressure environments. Has a big 13 on the back."
	icon_state = "spaceold"
	icon = 'icons/obj/clothing/suits/spacesuit.dmi'
	worn_icon = 'icons/mob/clothing/suits/spacesuit.dmi'
	inhand_icon_state = "s_suit"
	w_class = WEIGHT_CLASS_BULKY
	gas_transfer_coefficient = 0.01
	clothing_flags = NOTCONSUMABLE | STOPSPRESSUREDAMAGE
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	allowed = list(
		/obj/item/flashlight,
		/obj/item/tank/internals,
		/obj/item/tank/jetpack/oxygen/captain,
		)
	slowdown = 0.9
	armor_type = /datum/armor/suit_space
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	cold_protection = CHEST | GROIN | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT_OFF
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	strip_delay = 80
	equip_delay_other = 80
	resistance_flags = NONE
	actions_types = list(/datum/action/item_action/toggle_spacesuit)
	pockets = FALSE
	custom_price = 150
	var/temperature_setting = BODYTEMP_NORMAL /// The default temperature setting
	var/obj/item/stock_parts/cell/cell = /obj/item/stock_parts/cell /// If this is a path, this gets created as an object in Initialize.
	var/cell_cover_open = FALSE /// Status of the cell cover on the suit
	var/thermal_on = FALSE /// Status of the thermal regulator
	var/show_hud = TRUE /// If this is FALSE the battery status UI will be disabled. This is used for suits that don't use batteries like the changeling's flesh suit mutation.


/datum/armor/suit_space
	bio = 100
	fire = 80
	acid = 70
	stamina = 10
	bleed = 50

/obj/item/clothing/suit/space/Initialize(mapload)
	. = ..()
	if(ispath(cell))
		cell = new cell(src)

/// Start Processing on the space suit when it is worn to heat the wearer
/obj/item/clothing/suit/space/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_OCLOTHING) // Check that the slot is valid
		START_PROCESSING(SSobj, src)
		update_hud_icon(user) // update the hud

// On removal stop processing, save battery
/obj/item/clothing/suit/space/dropped(mob/user)
	. = ..()
	STOP_PROCESSING(SSobj, src)
	var/mob/living/carbon/human/human = user
	if(istype(human))
		human.update_spacesuit_hud_icon("0")

// Space Suit temperature regulation and power usage
/obj/item/clothing/suit/space/process(delta_time)
	var/mob/living/carbon/human/user = src.loc
	if(!user || !ishuman(user) || !(user.wear_suit == src))
		return

	// Do nothing if thermal regulators are off
	if(!thermal_on)
		return

	// If we got here, thermal regulators are on. If there's no cell, turn them off
	if(!cell)
		toggle_spacesuit(user)
		update_hud_icon(user)
		return

	// cell.use will return FALSE if charge is lower than THERMAL_REGULATOR_COST
	if(!cell.use(THERMAL_REGULATOR_COST))
		toggle_spacesuit(user)
		update_hud_icon(user)
		to_chat(user, span_warning("The thermal regulator cuts off as [cell] runs out of charge."))
		return

	// If we got here, it means thermals are on, the cell is in and the cell has
	// just had enough charge subtracted from it to power the thermal regulator
	user.adjust_bodytemperature(get_temp_change_amount((temperature_setting - user.bodytemperature), 0.08 * delta_time))
	update_hud_icon(user)

// Clean up the cell on destroy
/obj/item/clothing/suit/space/Destroy()
	if(isatom(cell))
		QDEL_NULL(cell)
	var/mob/living/carbon/human/human = src.loc
	if(istype(human))
		human.update_spacesuit_hud_icon("0")
	STOP_PROCESSING(SSobj, src)
	return ..()

// Clean up the cell on destroy
/obj/item/clothing/suit/space/handle_atom_del(atom/A)
	if(A == cell)
		cell = null
		thermal_on = FALSE
	return ..()

// support for items that interact with the cell
/obj/item/clothing/suit/space/get_cell()
	return cell

// Show the status of the suit and the cell
/obj/item/clothing/suit/space/examine(mob/user)
	. = ..()
	if(in_range(src, user) || isobserver(user))
		. += "The thermal regulator is [thermal_on ? "on" : "off"] and the temperature is set to \
			[round(temperature_setting-T0C,0.1)] &deg;C ([round(temperature_setting*1.8-459.67,0.1)] &deg;F)"
		. += "The power meter shows [cell ? "[round(cell.percent(), 0.1)]%" : "!invalid!"] charge remaining."
		if(cell_cover_open)
			. += "The cell cover is open exposing the cell and setting knobs."
			if(!cell)
				. += "The slot for a cell is empty."
			else
				. += "\The [cell] is firmly in place."

// object handling for accessing features of the suit
/obj/item/clothing/suit/space/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_CROWBAR)
		toggle_spacesuit_cell(user)
		return
	else if(cell_cover_open && I.tool_behaviour == TOOL_SCREWDRIVER)
		var/range_low = 20 // Default min temp c
		var/range_high = 45 // default max temp c
		if(obj_flags & EMAGGED)
			range_low = -20 // emagged min temp c
			range_high = 120 // emagged max temp c

		var/deg_c = input(user, "What temperature would you like to set the thermal regulator to? \
			([range_low]-[range_high] degrees celcius)") as null|num
		if(deg_c && deg_c >= range_low && deg_c <= range_high)
			temperature_setting = round(T0C + deg_c, 0.1)
			to_chat(user, span_notice("You see the readout change to [deg_c] c."))
		return
	else if(cell_cover_open && istype(I, /obj/item/stock_parts/cell))
		if(cell)
			to_chat(user, span_warning("[src] already has a cell installed."))
			return
		if(user.transferItemToLoc(I, src))
			cell = I
			to_chat(user, span_notice("You successfully install \the [cell] into [src]."))
			return
	return ..()

/// Open the cell cover when ALT+Click on the suit
/obj/item/clothing/suit/space/AltClick(mob/living/user)
	if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, !iscyborg(user)))
		return ..()
	toggle_spacesuit_cell(user)

/// Remove the cell whent he cover is open on CTRL+Click
/obj/item/clothing/suit/space/CtrlClick(mob/living/user)
	if(user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, !iscyborg(user)))
		if(cell_cover_open && cell)
			remove_cell(user)
			return
	return ..()

// Remove the cell when using the suit on its self
/obj/item/clothing/suit/space/attack_self(mob/user)
	remove_cell(user)

/// Remove the cell from the suit if the cell cover is open
/obj/item/clothing/suit/space/proc/remove_cell(mob/user)
	if(cell_cover_open && cell)
		user.visible_message(span_notice("[user] removes \the [cell] from [src]!"), \
			span_notice("You remove [cell]."))
		cell.add_fingerprint(user)
		user.put_in_hands(cell)
		cell = null

/// Toggle the space suit's cell cover
/obj/item/clothing/suit/space/proc/toggle_spacesuit_cell(mob/user)
	cell_cover_open = !cell_cover_open
	to_chat(user, span_notice("You [cell_cover_open ? "open" : "close"] the cell cover on \the [src]."))

/// Toggle the space suit's thermal regulator status
/obj/item/clothing/suit/space/proc/toggle_spacesuit(mob/toggler)
	// If we're turning thermal protection on, check for valid cell and for enough
	// charge that cell. If it's too low, we shouldn't bother with setting the
	// thermal protection value and should just return out early.
	if(!thermal_on && (!cell || cell.charge < THERMAL_REGULATOR_COST))
		if(toggler)
			to_chat(toggler, span_warning("The thermal regulator on [src] has no charge."))
		return

	thermal_on = !thermal_on
	min_cold_protection_temperature = thermal_on ? SPACE_SUIT_MIN_TEMP_PROTECT : SPACE_SUIT_MIN_TEMP_PROTECT_OFF
	if(toggler)
		to_chat(toggler, span_notice("You turn [thermal_on ? "on" : "off"] \the [src]'s thermal regulator."))

	update_action_buttons()

/obj/item/clothing/suit/space/ui_action_click(mob/user, actiontype)
	toggle_spacesuit(user)

// let emags override the temperature settings
/obj/item/clothing/suit/space/on_emag(mob/user)
	..()
	user.visible_message(span_warning("You emag [src], overwriting thermal regulator restrictions."))
	log_game("[key_name(user)] emagged [src] at [AREACOORD(src)], overwriting thermal regulator restrictions.")
	playsound(src, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

// update the HUD icon
/obj/item/clothing/suit/space/proc/update_hud_icon(mob/user)
	var/mob/living/carbon/human/human = user

	if(!show_hud)
		return

	if(!cell)
		human.update_spacesuit_hud_icon("missing")
		return

	var/cell_percent = cell.percent()

	// Check if there's enough charge to trigger a thermal regulator tick and
	// if there is, whethere the cell's capacity indicates high, medium or low
	// charge based on it.
	if(cell.charge >= THERMAL_REGULATOR_COST)
		if(cell_percent > 60)
			human.update_spacesuit_hud_icon("high")
			return
		if(cell_percent > 20)
			human.update_spacesuit_hud_icon("mid")
			return
		human.update_spacesuit_hud_icon("low")
		return

	human.update_spacesuit_hud_icon("empty")
	return

// zap the cell if we get hit with an emp
/obj/item/clothing/suit/space/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_CONTENTS)
		return
	if(cell)
		cell.emp_act(severity)

#undef THERMAL_REGULATOR_COST
