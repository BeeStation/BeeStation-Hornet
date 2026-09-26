/**
 * Clothing
 */

/datum/action/item_action/chameleon/change/neck
	chameleon_type = /obj/item/clothing/neck
	chameleon_name = "Neck Accessory"

/datum/action/item_action/chameleon/change/headset
	chameleon_type = /obj/item/radio/headset
	chameleon_name = "Headset"

/datum/action/item_action/chameleon/change/belt
	chameleon_type = /obj/item/storage/belt
	chameleon_name = "Belt"

/datum/action/item_action/chameleon/change/backpack
	chameleon_type = /obj/item/storage/backpack
	chameleon_name = "Backpack"

/datum/action/item_action/chameleon/change/shoes
	chameleon_type = /obj/item/clothing/shoes
	chameleon_name = "Shoes"

/datum/action/item_action/chameleon/change/shoes/initialize_blacklist()
	. = ..()
	chameleon_blacklist |= typecacheof(/obj/item/clothing/shoes/changeling, only_root_path = TRUE)

/datum/action/item_action/chameleon/change/mask
	chameleon_type = /obj/item/clothing/mask
	chameleon_name = "Mask"

/datum/action/item_action/chameleon/change/mask/initialize_blacklist()
	. = ..()
	chameleon_blacklist |= typecacheof(/obj/item/clothing/mask/changeling, only_root_path = TRUE)

/datum/action/item_action/chameleon/change/hat
	chameleon_type = /obj/item/clothing/head
	chameleon_name = "Hat"

/datum/action/item_action/chameleon/change/hat/initialize_blacklist()
	. = ..()
	chameleon_blacklist |= typecacheof(/obj/item/clothing/head/changeling, only_root_path = TRUE)

/datum/action/item_action/chameleon/change/gloves
	chameleon_type = /obj/item/clothing/gloves
	chameleon_name = "Gloves"

/datum/action/item_action/chameleon/change/gloves/initialize_blacklist()
	. = ..()
	chameleon_blacklist |= typecacheof(list(/obj/item/clothing/gloves/changeling), only_root_path = TRUE)

/datum/action/item_action/chameleon/change/glasses
	chameleon_type = /obj/item/clothing/glasses
	chameleon_name = "Glasses"

/datum/action/item_action/chameleon/change/glasses/initialize_blacklist()
	. = ..()
	chameleon_blacklist |= typecacheof(list(/obj/item/clothing/glasses/changeling, /obj/item/clothing/glasses/hud/security/chameleon, /obj/item/clothing/glasses/thermal/syndi), only_root_path = TRUE)

/datum/action/item_action/chameleon/change/suit
	chameleon_type = /obj/item/clothing/suit
	chameleon_name = "Suit"

/datum/action/item_action/chameleon/change/suit/initialize_blacklist()
	. = ..()
	chameleon_blacklist |= typecacheof(list(/obj/item/clothing/suit/armor/abductor, /obj/item/clothing/suit/changeling), only_root_path = TRUE)

/datum/action/item_action/chameleon/change/suit/apply_outfit(datum/outfit/applying_from, list/all_items_to_apply)
	. = ..()
	if(!. || !ispath(applying_from.suit, /obj/item/clothing/suit/hooded))
		return
	// If we're appling a hooded suit, and wearing a cham hat, make it a hood
	var/obj/item/clothing/suit/hooded/hooded = applying_from.suit
	var/datum/action/item_action/chameleon/change/hat/hood_action = locate() in owner?.actions
	hood_action?.update_look(hooded::hoodtype)

/datum/action/item_action/chameleon/change/jumpsuit
	chameleon_type = /obj/item/clothing/under
	chameleon_name = "Jumpsuit"

/datum/action/item_action/chameleon/change/jumpsuit/initialize_blacklist()
	. = ..()
	chameleon_blacklist |= typecacheof(list(/obj/item/clothing/under/color, /obj/item/clothing/under/changeling), only_root_path = TRUE)

/**
 * Not clothing
 */

/datum/action/item_action/chameleon/change/pda
	chameleon_type = /obj/item/modular_computer/tablet/pda
	chameleon_name = "PDA"

/datum/action/item_action/chameleon/change/pda/update_item(obj/item/picked_item)
	. = ..()
	if(!istype(master, /obj/item/modular_computer))
		return

	var/obj/item/modular_computer/computer_target = master
	var/obj/item/card/id/id = computer_target.GetID()
	if(id)
		computer_target.saved_identification = id.registered_name
		computer_target.saved_job = id.assignment
		computer_target.update_id_display()

/datum/action/item_action/chameleon/change/id
	chameleon_type = /obj/item/card/id
	chameleon_name = "ID Card"

/datum/action/item_action/chameleon/change/id/initialize_blacklist()
	. = ..()
	chameleon_blacklist |= typecacheof(
		list(
			/obj/item/card/id,
			/obj/item/card/id/changeling,
			/obj/item/card/id/golem,
		) + typesof(/obj/item/card/id/departmental_budget) + typesof(/obj/item/card/id/pass) + subtypesof(/obj/item/card/id/syndicate) + subtypesof(/obj/item/card/id/gulag) + subtypesof(/obj/item/card/id/away),
		only_root_path = TRUE,
	)

/datum/action/item_action/chameleon/change/id/update_item(obj/item/picked_item)
	. = ..()
	if(!isidcard(master) || !ispath(picked_item, /obj/item/card/id))
		return

	var/obj/item/card/id/id_target = master
	var/obj/item/card/id/picked_id = picked_item

	id_target.hud_state = picked_id::hud_state
	astype(owner, /mob/living/carbon/human)?.sec_hud_set_ID()

	// If we are in a modular computer, update its ID
	var/obj/item/modular_computer/computer = get(id_target, /obj/item/modular_computer)
	if(isnull(computer))
		return

	computer.saved_identification = id_target.registered_name
	computer.saved_job = id_target.assignment
	computer.update_id_display()

/datum/action/item_action/chameleon/change/id/random_look()
	. = ..()
	if(!istype(master, /obj/item/card/id))
		return
	var/obj/item/card/id/id_target = master

	id_target.assignment = pick(SSjob.name_occupations)
	id_target.update_label()

/datum/action/item_action/chameleon/change/id/on_multitool_act(obj/item/source, mob/living/user, obj/item/tool, list/processing_recipes)
	. = ..()
	astype(master, /obj/item/card/id/syndicate)?.forge_disabled = should_hide

/datum/action/item_action/chameleon/change/stamp
	chameleon_type = /obj/item/stamp
	chameleon_name = "Stamp"

/datum/action/item_action/chameleon/tongue_change
	name = "Tongue Change"
	button_icon = 'icons/obj/medical/organs/organs.dmi'
	button_icon_state = "tonguebone"
	var/static/list/tongue_list

/datum/action/item_action/chameleon/tongue_change/New(master)
	. = ..()
	if(!isnull(tongue_list))
		return

	tongue_list = list()
	for(var/obj/item/organ/tongue/potential_tongue as anything in typesof(/obj/item/organ/tongue))
		if((potential_tongue::item_flags & ABSTRACT) || !potential_tongue::icon_state)
			continue
		var/tongue_name = "[potential_tongue::name] ([replacetext(potential_tongue::icon_state, "_", " ")])"
		tongue_list[tongue_name] = potential_tongue
	tongue_list = sort_list(tongue_list)

/datum/action/item_action/chameleon/tongue_change/on_activate(mob/user, obj/item/clothing/mask/target_mask)
	if(!istype(target_mask))
		return FALSE

	var/picked_name = tgui_input_list(owner, "Select a tongue to mimic", "Chameleon tongue selection", tongue_list)
	if(QDELETED(target_mask))
		return FALSE
	if(isnull(picked_name))
		target_mask.chosen_tongue = null
		return FALSE

	target_mask.chosen_tongue = tongue_list[picked_name]
	return TRUE
