/obj/item/clothing/mask/gas
	name = "gas mask"
	desc = "A face-covering mask that can be connected to an air supply. While good for concealing your identity, it isn't good for blocking gas flow." //More accurate
	icon_state = "gas_alt"
	clothing_flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEFACIALHAIR|HIDESNOUT
	w_class = WEIGHT_CLASS_NORMAL
	item_state = "gas_alt"
	gas_transfer_coefficient = 0.01
	armor_type = /datum/armor/mask_gas
	flags_cover = MASKCOVERSEYES | MASKCOVERSMOUTH
	resistance_flags = NONE


/datum/armor/mask_gas
	bio = 100

/obj/item/clothing/mask/gas/atmos/centcom
	name = "\improper CentCom gas mask"
	desc = "Oooh, gold and green. Fancy! This should help as you sit in your office."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "gas_centcom"
	item_state = "gas_centcom"
	resistance_flags = FIRE_PROOF | ACID_PROOF

// **** Welding gas mask ****

/obj/item/clothing/mask/gas/welding
	name = "welding mask"
	desc = "A gas mask with built-in welding goggles and a face shield. Looks like a skull - clearly designed by a nerd."
	icon_state = "weldingmask"
	custom_materials = list(/datum/material/iron=4000, /datum/material/glass=2000)
	flash_protect = FLASH_PROTECTION_WELDER
	tint = 2
	armor_type = /datum/armor/gas_welding
	actions_types = list(/datum/action/item_action/toggle)
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDESNOUT
	flags_cover = MASKCOVERSEYES
	visor_flags_inv = HIDEEYES
	visor_flags_cover = MASKCOVERSEYES
	resistance_flags = FIRE_PROOF


/datum/armor/gas_welding
	melee = 10
	bio = 100
	fire = 100
	acid = 55
	stamina = 15
	bleed = 5

/obj/item/clothing/mask/gas/welding/attack_self(mob/user)
	weldingvisortoggle(user)

/obj/item/clothing/mask/gas/welding/up

/obj/item/clothing/mask/gas/welding/up/Initialize(mapload)
	. = ..()
	visor_toggling()

// ********************************************************************

//Plague Dr suit can be found in clothing/suits/bio.dm
/obj/item/clothing/mask/gas/plaguedoctor
	name = "plague doctor mask"
	desc = "A modernised version of the classic design, this mask will not only filter out toxins but it can also be connected to an air supply."
	icon_state = "plaguedoctor"
	item_state = "gas_mask"

/obj/item/clothing/mask/gas/syndicate
	name = "syndicate mask"
	desc = "A close-fitting tactical mask that can be connected to an air supply."
	icon_state = "syndicate"
	strip_delay = 60

/obj/item/clothing/mask/gas/clown_hat
	name = "clown wig and mask"
	desc = "A true prankster's facial attire. A clown is incomplete without his wig and mask."
	clothing_flags = MASKINTERNALS
	icon_state = "clown"
	item_state = "clown_hat"
	dye_color = "clown"
	w_class = WEIGHT_CLASS_SMALL
	flags_cover = MASKCOVERSEYES
	resistance_flags = FLAMMABLE
	actions_types = list(/datum/action/item_action/adjust)
	dog_fashion = /datum/dog_fashion/head/clown
	var/list/mask_designs = list()

/obj/item/clothing/mask/gas/clown_hat/Initialize(mapload)
	.=..()
	mask_designs["True Form"] = image(icon = src.icon, icon_state = "clown")
	mask_designs["The Feminist"] = image(icon = src.icon, icon_state = "sexyclown")
	mask_designs["The Madman"] = image(icon = src.icon, icon_state = "joker")
	mask_designs["The Rainbow Color"] = image(icon = src.icon, icon_state = "rainbow")
	mask_designs["The Jester"] = image(icon = src.icon, icon_state = "chaos")
	mask_designs["The Lunatic"] = image(icon = src.icon, icon_state = "trickymask")

/obj/item/clothing/mask/gas/clown_hat/ui_action_click(mob/user)
	if(!istype(user) || user.incapacitated())
		return
	var/list/options = list()
	options["True Form"] = "clown"
	options["The Feminist"] = "sexyclown"
	options["The Madman"] = "joker"
	options["The Rainbow Color"] ="rainbow"
	options["The Jester"] ="chaos" //Nepeta33Leijon is holding me captive and forced me to help with this please send help
	options["The Lunatic"] = "trickymask"

	var/choice = show_radial_menu(user, user, mask_designs, custom_check = FALSE, radius = 40)
	if(!choice)
		return FALSE

	if(src && choice && !user.incapacitated() && in_range(user,src))
		icon_state = options[choice]
		user.update_worn_mask()
		for(var/X in actions)
			var/datum/action/A = X
			A.update_buttons()
		to_chat(user, span_notice("Your Clown Mask has now morphed into [choice], all praise the Honkmother!"))
		return 1

/obj/item/clothing/mask/gas/sexyclown
	name = "sexy-clown wig and mask"
	desc = "A feminine clown mask for the dabbling crossdressers or female entertainers."
	clothing_flags = MASKINTERNALS
	icon_state = "sexyclown"
	item_state = "sexyclown"
	flags_cover = MASKCOVERSEYES
	resistance_flags = FLAMMABLE

/obj/item/clothing/mask/gas/mime
	name = "mime mask"
	desc = "The traditional mime's mask. It has an eerie facial posture."
	clothing_flags = MASKINTERNALS
	icon_state = "mime"
	item_state = "mime"
	w_class = WEIGHT_CLASS_SMALL
	flags_cover = MASKCOVERSEYES
	resistance_flags = FLAMMABLE
	actions_types = list(/datum/action/item_action/adjust)
	var/list/mask_designs = list()

/obj/item/clothing/mask/gas/mime/Initialize(mapload)
	.=..()
	mask_designs["Blanc"] = image(icon = src.icon, icon_state = "mime")
	mask_designs["Triste"] = image(icon = src.icon, icon_state = "sadmime")
	mask_designs["Effrayé"] = image(icon = src.icon, icon_state = "scaredmime")
	mask_designs["Excité"] = image(icon = src.icon, icon_state = "sexymime")

/obj/item/clothing/mask/gas/mime/ui_action_click(mob/user)
	if(!istype(user) || user.incapacitated())
		return

	var/list/options = list()
	options["Blanc"] = "mime"
	options["Triste"] = "sadmime"
	options["Effrayé"] = "scaredmime"
	options["Excité"] ="sexymime"

	var/choice = show_radial_menu(user, user, mask_designs, custom_check = FALSE, radius = 40)
	if(!choice)
		return FALSE

	if(src && choice && !user.incapacitated() && in_range(user,src))
		icon_state = options[choice]
		user.update_worn_mask()
		for(var/X in actions)
			var/datum/action/A = X
			A.update_buttons()
		to_chat(user, span_notice("Your Mime Mask has now morphed into [choice]!"))
		return 1

/obj/item/clothing/mask/gas/monkeymask
	name = "monkey mask"
	desc = "A mask used when acting as a monkey."
	clothing_flags = MASKINTERNALS
	icon_state = "monkeymask"
	item_state = "monkeymask"
	flags_cover = MASKCOVERSEYES
	resistance_flags = FLAMMABLE

/obj/item/clothing/mask/gas/sexymime
	name = "sexy mime mask"
	desc = "A traditional female mime's mask."
	clothing_flags = MASKINTERNALS
	icon_state = "sexymime"
	item_state = "sexymime"
	flags_cover = MASKCOVERSEYES
	resistance_flags = FLAMMABLE

/obj/item/clothing/mask/gas/death_commando
	name = "Death Commando Mask"
	icon_state = "swat"
	item_state = "swat"

/obj/item/clothing/mask/gas/cyborg
	name = "cyborg visor"
	desc = "Beep boop."
	icon_state = "death"
	resistance_flags = FLAMMABLE

/obj/item/clothing/mask/gas/owl_mask
	name = "owl mask"
	desc = "Twoooo!"
	icon_state = "owl"
	clothing_flags = MASKINTERNALS
	flags_cover = MASKCOVERSEYES
	resistance_flags = FLAMMABLE

/obj/item/clothing/mask/gas/carp
	name = "carp mask"
	desc = "Gnash gnash."
	icon_state = "carp_mask"

/obj/item/clothing/mask/gas/tiki_mask
	name = "tiki mask"
	desc = "A creepy wooden mask. Surprisingly expressive for a poorly carved bit of wood."
	icon_state = "tiki_eyebrow"
	item_state = "tiki_eyebrow"
	custom_materials = list(/datum/material/wood = MINERAL_MATERIAL_AMOUNT * 1.25)
	resistance_flags = FLAMMABLE
	max_integrity = 100
	actions_types = list(/datum/action/item_action/adjust)
	dog_fashion = null
	var/list/mask_designs = list()

/obj/item/clothing/mask/gas/tiki_mask/Initialize(mapload)
	.=..()
	mask_designs["Original Tiki"] = image(icon = src.icon, icon_state = "tiki_eyebrow")
	mask_designs["Happy Tikie"] = image(icon = src.icon, icon_state = "tiki_happy")
	mask_designs["Confused Tiki"] = image(icon = src.icon, icon_state = "tiki_confused")
	mask_designs["Angry Tiki"] = image(icon = src.icon, icon_state = "tiki_angry")

/obj/item/clothing/mask/gas/tiki_mask/ui_action_click(mob/user)
	var/mob/M = usr
	var/list/options = list()
	options["Original Tiki"] = "tiki_eyebrow"
	options["Happy Tiki"] = "tiki_happy"
	options["Confused Tiki"] = "tiki_confused"
	options["Angry Tiki"] ="tiki_angry"

	var/choice = show_radial_menu(user, user, mask_designs, custom_check = FALSE, radius = 40)
	if(!choice)
		return FALSE

	if(src && choice && !M.stat && in_range(M,src))
		icon_state = options[choice]
		user.update_worn_mask()
		for(var/X in actions)
			var/datum/action/A = X
			A.update_buttons()
		to_chat(M, "The Tiki Mask has now changed into the [choice] Mask!")
		return 1

/obj/item/clothing/mask/gas/tiki_mask/yalp_elor
	icon_state = "tiki_yalp"
	actions_types = list()

/obj/item/clothing/mask/gas/old
	desc = "A face-covering mask that can be connected to an air supply. This one appears to be one of the older models."
	icon_state = "gas_alt_old"
	item_state = "gas_alt_old"

/obj/item/clothing/mask/gas/old/modulator
	name = "modified gas mask"
	desc = "A face-covering mask that can be connected to an air supply. This one appears to be one of the older models."
	voice_change = TRUE
	chosen_tongue = /obj/item/organ/tongue/robot

/obj/item/clothing/mask/gas/old/modulator/get_name(mob/user, default_name)
	return voice_change ? "Unknown" : default_name

/obj/item/clothing/mask/gas/old/modulator/examine()
	. = ..()
	. += span_notice("It was modified to make the user's voice sound robotic.")
	. += "The modulator is currently [voice_change ? "<b>ON</b>" : "<b>OFF</b>"]."

/obj/item/clothing/mask/gas/old/modulator/attack_self(mob/user)
	voice_change = !voice_change
	to_chat(user, span_notice("The modulator is now [voice_change ? "on" : "off"]!"))

/obj/item/clothing/mask/gas/old/modulator/AltClick(mob/user)
	if(user.canUseTopic(src, BE_CLOSE))
		voice_change = !voice_change
		to_chat(user, span_notice("The modulator is now [voice_change ? "on" : "off"]!"))
