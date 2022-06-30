/datum/hallucination/shock
	var/image/shock_image
	var/image/electrocution_skeleton_anim

/datum/hallucination/shock/New(mob/living/carbon/C, forced = TRUE)
	set waitfor = FALSE
	..()
	shock_image = image(target, target, dir = target.dir)
	shock_image.appearance_flags |= KEEP_APART
	shock_image.color = rgb(0,0,0)
	shock_image.override = TRUE
	electrocution_skeleton_anim = image('icons/mob/human.dmi', target, icon_state = "electrocuted_base", layer=ABOVE_MOB_LAYER)
	electrocution_skeleton_anim.appearance_flags |= RESET_COLOR|KEEP_APART
	to_chat(target, "<span class='userdanger'>You feel a powerful shock course through your body!</span>")
	if(target.client)
		target.client.images |= shock_image
		target.client.images |= electrocution_skeleton_anim
	addtimer(CALLBACK(src, .proc/reset_shock_animation), 40)
	target.playsound_local(get_turf(src), "sparks", 100, 1)
	target.staminaloss += 50
	target.Stun(40)
	target.jitteriness += 1000
	target.do_jitter_animation(target.jitteriness)
	addtimer(CALLBACK(src, .proc/shock_drop), 20)

/datum/hallucination/shock/proc/reset_shock_animation()
	if(target.client)
		target.client.images.Remove(shock_image)
		target.client.images.Remove(electrocution_skeleton_anim)

/datum/hallucination/shock/proc/shock_drop()
	target.jitteriness = max(target.jitteriness - 990, 10) //Still jittery, but vastly less
	target.Paralyze(60)
