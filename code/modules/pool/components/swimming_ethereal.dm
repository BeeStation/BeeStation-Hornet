/datum/component/swimming/ethereal/enter_pool()
	var/mob/living/L = parent
	L.visible_message("<span class='warning'>Sparks of energy begin coursing around the pool!</span>")

/datum/component/swimming/ethereal/process()
	..()
	var/mob/living/L = parent
	if(prob(2) && L.nutrition > NUTRITION_LEVEL_FED)
		L.adjust_nutrition(-50)
		tesla_zap(L, 7, 2000, TESLA_MOB_STUN)
		playsound(L, 'sound/machines/defib_zap.ogg', 50, TRUE)
