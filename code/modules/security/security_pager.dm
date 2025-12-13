/obj/item/clothing/accessory/security_pager
	name = "security pager"
	desc = "A chest-mounted pager which is used to quickly keep in touch with a commanding body."
	icon_state = "pager"
	above_suit = TRUE
	var/obj/item/radio/radio

/obj/item/clothing/accessory/security_pager/Initialize(mapload)
	. = ..()
	radio = new(src)
	radio.keyslot = new /obj/item/encryptionkey/headset_sec
	radio.subspace_transmission = TRUE
	radio.canhear_range = 0
	radio.recalculateChannels()

/obj/item/clothing/accessory/security_pager/on_uniform_equip(obj/item/clothing/under/U, mob/living/wearer)
	. = ..()
	RegisterSignal(wearer, COMSIG_MOB_DEATH, PROC_REF(on_owner_died))

/obj/item/clothing/accessory/security_pager/on_uniform_dropped(obj/item/clothing/under/U, mob/living/wearer)
	. = ..()
	UnregisterSignal(wearer, COMSIG_MOB_DEATH)

/obj/item/clothing/accessory/security_pager/proc/on_owner_died(datum/source)
	SIGNAL_HANDLER
	radio.talk_into(src, "Alert, vital signs from the wearer have been lost.", RADIO_CHANNEL_SECURITY)
