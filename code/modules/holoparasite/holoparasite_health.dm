/mob/living/simple_animal/hostile/holoparasite/update_health_hud()
	if(!hud_used?.healths)
		return
	var/mob/living/current = summoner?.current
	if(!QDELETED(current) && current.stat != DEAD)
		var/summoner_max_health = current.maxHealth
		var/health_amount = min(current.health, summoner_max_health - current.getStaminaLoss())
		if(health_amount >= summoner_max_health)
			hud_used.healths.icon_state = "health0"
		else if(health_amount >= (summoner_max_health * 0.8))
			hud_used.healths.icon_state = "health1"
		else if(health_amount >= (summoner_max_health * 0.6))
			hud_used.healths.icon_state = "health2"
		else if(health_amount >= (summoner_max_health * 0.4))
			hud_used.healths.icon_state = "health3"
		else if(health_amount >= (summoner_max_health * 0.2))
			hud_used.healths.icon_state = "health4"
		else if(health_amount >= 1)
			hud_used.healths.icon_state = "health5"
		else
			hud_used.healths.icon_state = "health6"
	else
		hud_used.healths.icon_state = "health7"

/mob/living/simple_animal/hostile/holoparasite/med_hud_set_health()
	if(summoner?.current)
		set_hud_image_state(HEALTH_HUD, "hud[RoundHealth(summoner.current)]")
	SEND_SIGNAL(src, COMSIG_HOLOPARA_SET_HUD_HEALTH, holder)

/mob/living/simple_animal/hostile/holoparasite/med_hud_set_status()
	if(summoner?.current)
		if(summoner.current.stat == DEAD)
			set_hud_image_state(STATUS_HUD, "huddead")
		else
			set_hud_image_state(STATUS_HUD, "hudhealthy")
	SEND_SIGNAL(src, COMSIG_HOLOPARA_SET_HUD_STATUS, holder)

/mob/living/simple_animal/hostile/holoparasite/revive(full_heal_flags = NONE, excess_healing = 0, force_grab_ghost = FALSE)
	. = ..()
	if(!.)
		return
	SSblackbox.record_feedback("amount", "holoparasites_revived", 1)
	var/mob/gost = grab_ghost(TRUE)
	if(gost?.ckey)
		ckey = gost.ckey
	if(!ckey && !client)
		// Ah well, might as well try to reset 'em.
		INVOKE_ASYNC(src, PROC_REF(reset), FALSE, TRUE)
