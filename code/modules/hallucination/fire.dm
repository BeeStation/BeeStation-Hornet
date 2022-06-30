/datum/hallucination/fire
	var/active = TRUE
	var/stage = 0
	var/image/fire_overlay

/datum/hallucination/fire/New(mob/living/carbon/C, forced = TRUE)
	set waitfor = FALSE
	..()
	target.fire_stacks = max(target.fire_stacks, 0.1) //Placebo flammability
	fire_overlay = image('icons/mob/OnFire.dmi', target, "Standing", ABOVE_MOB_LAYER)
	if(target.client)
		target.client.images += fire_overlay
	to_chat(target, "<span class='userdanger'>You're set on fire!</span>")
	target.throw_alert("fire", /atom/movable/screen/alert/fire, override = TRUE)
	sleep(20)
	for(var/i in 1 to 3)
		if(target.fire_stacks <= 0)
			clear_fire()
			return
		stage++
		update_temp()
		sleep(30)
	for(var/i in 1 to rand(5, 10))
		if(target.fire_stacks <= 0)
			clear_fire()
			return
		target.adjustStaminaLoss(15)
		sleep(20)
	clear_fire()

/datum/hallucination/fire/proc/update_temp()
	if(stage <= 0)
		target.clear_alert("temp", clear_override = TRUE)
	else
		target.clear_alert("temp", clear_override = TRUE)
		target.throw_alert("temp", /atom/movable/screen/alert/hot, stage, override = TRUE)

/datum/hallucination/fire/proc/clear_fire()
	if(!active)
		return
	active = FALSE
	target.clear_alert("fire", clear_override = TRUE)
	if(target.client)
		target.client.images -= fire_overlay
	QDEL_NULL(fire_overlay)
	while(stage > 0)
		stage--
		update_temp()
		sleep(30)
	qdel(src)
