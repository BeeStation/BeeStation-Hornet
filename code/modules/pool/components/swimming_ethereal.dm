/datum/component/swimming/ethereal/enter_pool()
	var/mob/living/L = parent
	L.visible_message(span_warning("Sparks of energy begin coursing around the pool!"))

/datum/component/swimming/ethereal/process()
	..()
	var/mob/living/L = parent
	if(!prob(2))
		return
	var/obj/item/organ/stomach/electrical/stomach = L.get_organ_slot(ORGAN_SLOT_STOMACH)
	if(!istype(stomach))
		return
	// Dont arc ourselves down
	if(stomach.cell.charge - ETHEREAL_POOL_ZAP_COST < ETHEREAL_CHARGE_NORMAL)
		return
	stomach.adjust_charge(-ETHEREAL_POOL_ZAP_COST)
	tesla_zap(source = L, zap_range = 7, power = ETHEREAL_POOL_ZAP_POWER, cutoff = ETHEREAL_ZAP_CUTOFF, zap_flags = ZAP_MOB_STUN | ZAP_MOB_DAMAGE)
	playsound(L, 'sound/machines/defib_zap.ogg', 50, TRUE)
