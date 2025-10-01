
//Ears: currently only used for headsets and earmuffs
/obj/item/clothing/ears
	name = "ears"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	slot_flags = ITEM_SLOT_EARS
	resistance_flags = NONE

/obj/item/clothing/ears/earmuffs
	name = "earmuffs"
	desc = "Protects your hearing from loud noises, and quiet ones as well."
	icon_state = "earmuffs"
	item_state = "earmuffs"
	strip_delay = 15
	equip_delay_other = 25
	resistance_flags = FLAMMABLE
	custom_price = 40
	bang_protect = 2

/obj/item/clothing/ears/earmuffs/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/earhealing)

/obj/item/clothing/ears/headphones
	name = "headphones"
	desc = "Unce unce unce unce. Boop!"
	icon = 'icons/obj/clothing/accessories.dmi'
	worn_icon = 'icons/mob/clothing/head/costume.dmi'
	icon_state = "headphones"
	item_state = "headphones"
	slot_flags = ITEM_SLOT_EARS | ITEM_SLOT_HEAD | ITEM_SLOT_NECK //Fluff item, put it wherever you want!
	actions_types = list(/datum/action/item_action/toggle_headphones)
	var/headphones_on = FALSE
	var/datum/song/headphones/song
	custom_price = 20
	bang_protect = 1 //these only work if on your ears due to how bang_protect is calculated, so it's as balanced as earmuffs

/obj/item/clothing/ears/headphones/Initialize(mapload)
	. = ..()
	song = new(src, SSinstruments.synthesizer_instrument_ids, 2)
	update_appearance()

/obj/item/clothing/ears/headphones/update_icon_state()
	icon_state = "[initial(icon_state)]_[headphones_on? "on" : "off"]"
	item_state = "[initial(item_state)]_[headphones_on? "on" : "off"]"
	. = ..()

/obj/item/clothing/ears/headphones/proc/toggle(owner, force_state)
	if(!force_state)
		headphones_on = !headphones_on
	if(force_state == "ON")
		headphones_on = TRUE
	if(force_state == "OFF")
		headphones_on = FALSE
	update_appearance()
	var/mob/living/carbon/human/H = owner
	if(istype(H))
		H.update_worn_ears()
		H.update_worn_neck()
		H.update_worn_head()
	to_chat(owner, span_notice("You turn the music [headphones_on? "on. Untz Untz Untz!" : "off."]"))
	balloon_alert(owner, "Music is now [headphones_on? "on" : "off"]")

/obj/item/clothing/ears/headphones/attack_self(mob/user)
	if(!ISADVANCEDTOOLUSER(user))
		to_chat(user, span_warning("You don't have the dexterity to do this!"))
		return TRUE
	interact(user)

/obj/item/clothing/ears/headphones/ui_interact(mob/living/user)
	if(!isliving(user) || user.stat != CONSCIOUS || (HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) && !ispAI(user)))
		return

	user.set_machine(src)
	song.ui_interact(user)

/obj/item/clothing/ears/headphones/Destroy()
	QDEL_NULL(song)
	return ..()

/obj/item/clothing/ears/headphones/proc/should_stop_playing(mob/user)
	return user.incapacitated() || !((loc == user) || (isturf(loc) && Adjacent(user)))

/obj/item/clothing/ears/headphones/AltClick(mob/user)
	. = ..()
	if(headphones_on)
		song.stop_playing()
		toggle(user, "OFF")
	else
		song.start_playing(user)
		toggle(user, "ON")

/obj/item/clothing/ears/headphones/examine(mob/user)
	. = ..()
	. += span_notice("They are currently [headphones_on? "on" : "off"].")
	. += span_notice("Alt-click to quickly turn the music [headphones_on? "off" : "on"].")
