/obj/item/clothing/accessory/security_pager
	name = "security pager"
	desc = "A chest-mounted pager which is used to quickly keep in touch with a commanding body."
	icon_state = "pager"
	above_suit = TRUE
	var/obj/item/radio/radio
	COOLDOWN_DECLARE(deathgasp_cooldown)

/obj/item/clothing/accessory/security_pager/Initialize(mapload)
	. = ..()
	radio = new(src)
	radio.keyslot = new /obj/item/encryptionkey/headset_sec
	radio.subspace_transmission = TRUE
	radio.canhear_range = 0
	radio.recalculateChannels()

/obj/item/clothing/accessory/security_pager/Destroy()
	. = ..()
	QDEL_NULL(radio)

/obj/item/clothing/accessory/security_pager/on_uniform_equip(obj/item/clothing/under/U, mob/living/wearer)
	. = ..()
	RegisterSignal(wearer, COMSIG_LIVING_DEATH, PROC_REF(on_owner_died))
	RegisterSignal(wearer, COMSIG_MOB_DEATHGASP, PROC_REF(on_owner_deathgasp))

/obj/item/clothing/accessory/security_pager/on_uniform_dropped(obj/item/clothing/under/U, mob/living/wearer)
	. = ..()
	UnregisterSignal(wearer, COMSIG_LIVING_DEATH)
	UnregisterSignal(wearer, COMSIG_MOB_DEATHGASP)

/obj/item/clothing/accessory/security_pager/proc/on_owner_deathgasp(mob/living/source)
	SIGNAL_HANDLER
	if (!COOLDOWN_FINISHED(src, deathgasp_cooldown))
		return COMSIG_MOB_CANCEL_DEATHGASP_SOUND
	COOLDOWN_START(src, deathgasp_cooldown, 10 SECONDS)
	playsound(source, 'sound/voice/sec_death.ogg', 200, TRUE, TRUE)
	return COMSIG_MOB_CANCEL_DEATHGASP_SOUND

/obj/item/clothing/accessory/security_pager/proc/on_owner_died(mob/living/source)
	SIGNAL_HANDLER
	radio.talk_into(src, "Alert, vital signs from the wearer have been lost.", RADIO_CHANNEL_SECURITY)
