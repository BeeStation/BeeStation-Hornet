// Round start tablets

/obj/item/modular_computer/tablet/pda
	icon = 'icons/obj/pda.dmi'
	icon_state = "pda"
	worn_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'

	bypass_icon_state = TRUE

	var/default_disk = 0
	/// If the PDA has been picked up / equipped before. This is used to set the user's preference background color / theme.
	var/equipped = FALSE

/obj/item/modular_computer/tablet/pda/equipped(mob/user, slot)
	. = ..()
	if(equipped || !user.client)
		return
	equipped = TRUE
	if(!user.client.prefs)
		return
	var/pref_theme = user.client.prefs.read_character_preference(/datum/preference/choiced/pda_theme)
	if(!mainboard.theme_locked && !mainboard.ignore_theme_pref && (pref_theme in mainboard.allowed_themes))
		mainboard.device_theme = mainboard.allowed_themes[pref_theme]
	mainboard.classic_color = user.client.prefs.read_character_preference(/datum/preference/color/pda_classic_color)

/obj/item/modular_computer/tablet/pda/update_icon()
	..()
	var/init_icon = initial(icon)
	if(!init_icon)
		return
	var/obj/item/computer_hardware/id_slot/id_slot = mainboard.all_components[MC_ID_AUTH]
	if(istype(id_slot))
		if(id_slot.stored_card)
			add_overlay(mutable_appearance(init_icon, "id_overlay"))
	if(inserted_item)
		add_overlay(mutable_appearance(init_icon, "insert_overlay"))
	if(light_on)
		add_overlay(mutable_appearance(init_icon, "light_overlay"))


/obj/item/modular_computer/tablet/pda/attack_ai(mob/user)
	to_chat(user, "<span class='notice'>It doesn't feel right to snoop around like that...</span>")
	return // we don't want ais or cyborgs using a private role tablet

/obj/item/modular_computer/tablet/pda/Initialize(mapload)
	. = ..()
	install_component(new /obj/item/computer_hardware/hard_drive/small/pda)
	install_component(new /obj/item/computer_hardware/processor_unit/small)
	install_component(new /obj/item/computer_hardware/battery(src, /obj/item/stock_parts/cell/computer))
	install_component(new /obj/item/computer_hardware/network_card)
	install_component(new /obj/item/computer_hardware/id_slot)
	install_component(new /obj/item/computer_hardware/goober/pai)
	install_component(new /obj/item/computer_hardware/identifier)
	install_component(new /obj/item/computer_hardware/sensorpackage)

	if(default_disk)
		var/obj/item/computer_hardware/hard_drive/portable/disk = new default_disk(src)
		install_component(disk)

	if(insert_type)
		inserted_item = new insert_type(src)
		// show the inserted item
		update_icon()
