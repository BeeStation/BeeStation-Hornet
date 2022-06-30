/datum/hallucination/hudscrew

/datum/hallucination/hudscrew/New(mob/living/carbon/C, forced = TRUE, screwyhud_type)
	set waitfor = FALSE
	..()
	//Screwy HUD
	var/chosen_screwyhud = screwyhud_type
	if(!chosen_screwyhud)
		chosen_screwyhud = pick(SCREWYHUD_CRIT,SCREWYHUD_DEAD,SCREWYHUD_HEALTHY)
	target.set_screwyhud(chosen_screwyhud)
	feedback_details += "Type: [target.hal_screwyhud]"
	sleep(rand(100,250))
	target.set_screwyhud(SCREWYHUD_NONE)
	qdel(src)

/datum/hallucination/fake_alert
	var/alert_type

/datum/hallucination/fake_alert/New(mob/living/carbon/C, forced = TRUE, specific, duration = 150)
	set waitfor = FALSE
	..()
	var/alert_type = pick("not_enough_oxy","not_enough_tox","not_enough_co2","too_much_oxy","too_much_co2","too_much_tox","newlaw","nutrition","charge","gravity","fire","locked","hacked","temphot","tempcold","pressure")
	if(specific)
		alert_type = specific
	feedback_details += "Type: [alert_type]"
	switch(alert_type)
		if("not_enough_oxy")
			target.throw_alert(alert_type, /atom/movable/screen/alert/not_enough_oxy, override = TRUE)
		if("not_enough_tox")
			target.throw_alert(alert_type, /atom/movable/screen/alert/not_enough_tox, override = TRUE)
		if("not_enough_co2")
			target.throw_alert(alert_type, /atom/movable/screen/alert/not_enough_co2, override = TRUE)
		if("too_much_oxy")
			target.throw_alert(alert_type, /atom/movable/screen/alert/too_much_oxy, override = TRUE)
		if("too_much_co2")
			target.throw_alert(alert_type, /atom/movable/screen/alert/too_much_co2, override = TRUE)
		if("too_much_tox")
			target.throw_alert(alert_type, /atom/movable/screen/alert/too_much_tox, override = TRUE)
		if("nutrition")
			if(prob(50))
				target.throw_alert(alert_type, /atom/movable/screen/alert/fat, override = TRUE)
			else
				target.throw_alert(alert_type, /atom/movable/screen/alert/starving, override = TRUE)
		if("gravity")
			target.throw_alert(alert_type, /atom/movable/screen/alert/weightless, override = TRUE)
		if("fire")
			target.throw_alert(alert_type, /atom/movable/screen/alert/fire, override = TRUE)
		if("temphot")
			alert_type = "temp"
			target.throw_alert(alert_type, /atom/movable/screen/alert/hot, 3, override = TRUE)
		if("tempcold")
			alert_type = "temp"
			target.throw_alert(alert_type, /atom/movable/screen/alert/cold, 3, override = TRUE)
		if("pressure")
			if(prob(50))
				target.throw_alert(alert_type, /atom/movable/screen/alert/highpressure, 2, override = TRUE)
			else
				target.throw_alert(alert_type, /atom/movable/screen/alert/lowpressure, 2, override = TRUE)
		//BEEP BOOP I AM A ROBOT
		if("newlaw")
			target.throw_alert(alert_type, /atom/movable/screen/alert/newlaw, override = TRUE)
		if("locked")
			target.throw_alert(alert_type, /atom/movable/screen/alert/locked, override = TRUE)
		if("hacked")
			target.throw_alert(alert_type, /atom/movable/screen/alert/hacked, override = TRUE)
		if("charge")
			target.throw_alert(alert_type, /atom/movable/screen/alert/emptycell, override = TRUE)
	sleep(duration)
	target.clear_alert(alert_type, clear_override = TRUE)
	qdel(src)


/datum/hallucination/fake_alert/proc/cleanup()
	target.clear_alert(alert_type, clear_override = TRUE)
	qdel(src)

///Causes the target to see incorrect health damages on the healthdoll
/datum/hallucination/fake_health_doll
	var/timer_id = null

///Creates a specified doll hallucination, or picks one randomly
/datum/hallucination/fake_health_doll/New(mob/living/carbon/human/human_mob, forced = TRUE, specific_limb, severity, duration = 500)
	. = ..()
	if(!specific_limb)
		specific_limb = pick(list(SCREWYDOLL_HEAD, SCREWYDOLL_CHEST, SCREWYDOLL_L_ARM, SCREWYDOLL_R_ARM, SCREWYDOLL_L_LEG, SCREWYDOLL_R_LEG))
	if(!severity)
		severity = rand(1, 5)
	LAZYSET(human_mob.hallucination_screwydoll, specific_limb, severity)
	human_mob.update_health_hud()

	timer_id = addtimer(CALLBACK(src, .proc/cleanup), duration, TIMER_STOPPABLE)

///Increments the severity of the damage seen on the doll
/datum/hallucination/fake_health_doll/proc/increment_fake_damage()
	if(!ishuman(target))
		stack_trace("Somehow [target] managed to get a fake health doll hallucination, while not being a human mob.")
	var/mob/living/carbon/human/human_mob = target
	for(var/entry in human_mob.hallucination_screwydoll)
		human_mob.hallucination_screwydoll[entry] = clamp(human_mob.hallucination_screwydoll[entry]+1, 1, 5)
	human_mob.update_health_hud()

///Adds a fake limb to the hallucination datum effect
/datum/hallucination/fake_health_doll/proc/add_fake_limb(specific_limb, severity)
	if(!specific_limb)
		specific_limb = pick(list(SCREWYDOLL_HEAD, SCREWYDOLL_CHEST, SCREWYDOLL_L_ARM, SCREWYDOLL_R_ARM, SCREWYDOLL_L_LEG, SCREWYDOLL_R_LEG))
	if(!severity)
		severity = rand(1, 5)
	var/mob/living/carbon/human/human_mob = target
	LAZYSET(human_mob.hallucination_screwydoll, specific_limb, severity)
	target.update_health_hud()


///Cleans up the hallucinations - this deletes any overlap, but that shouldn't happen.
/datum/hallucination/fake_health_doll/proc/cleanup()
	qdel(src)

//So that the associated addition proc cleans it up correctly
/datum/hallucination/fake_health_doll/Destroy()
	if(!ishuman(target))
		stack_trace("Somehow [target] managed to get a fake health doll hallucination, while not being a human mob.")
	var/mob/living/carbon/human/human_mob = target
	LAZYNULL(human_mob.hallucination_screwydoll)
	human_mob.update_health_hud()
	return ..()
