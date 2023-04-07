
//==================================//
// !            Kindle            ! //
//==================================//
/datum/clockcult/scripture/slab/kindle
	name = "Kindle"
	desc = "Stuns and mutes a target from a short range. Significantly less effective on Reebe."
	tip = "Stuns and mutes a target from a short range."
	button_icon_state = "Kindle"
	power_cost = 125
	invokation_time = 30
	invokation_text = list("Divinity, show them your light!")
	after_use_text = "Let the power flow through you!"
	slab_overlay = "volt"
	use_time = 150
	cogs_required = 1
	category = SPELLTYPE_SERVITUDE

/datum/clockcult/scripture/slab/kindle/apply_effects(atom/A)
	var/mob/living/M = A
	if(!istype(M))
		return FALSE
	if(!is_servant_of_ratvar(invoker))
		M = invoker
	if(is_servant_of_ratvar(M))
		return FALSE
	//Anti magic abilities
	var/anti_magic_source = M.anti_magic_check(holy = TRUE)
	if(anti_magic_source)
		M.mob_light(_color = LIGHT_COLOR_HOLY_MAGIC, _range = 2, _duration = 100)
		var/mutable_appearance/forbearance = mutable_appearance('icons/effects/genetics.dmi', "servitude", -MUTATIONS_LAYER)
		M.add_overlay(forbearance)
		addtimer(CALLBACK(M, TYPE_PROC_REF(/atom, cut_overlay), forbearance), 100)
		M.visible_message("<span class='warning'>[M] stares blankly, as a field of energy flows around them.</span>", \
									   "<span class='userdanger'>You feel a slight shock as a wave of energy flows past you.</span>")
		playsound(invoker, 'sound/magic/mm_hit.ogg', 50, TRUE)
		return TRUE
	//Blood Cultist Effect
	if(iscultist(M))
		M.mob_light(_color = LIGHT_COLOR_BLOOD_MAGIC, _range = 2, _duration = 300)
		M.stuttering += 15
		M.Jitter(15)
		var/mob_color = M.color
		M.color = LIGHT_COLOR_BLOOD_MAGIC
		animate(M, color = mob_color, time = 300)
		M.say("Fwebar uloft'gib mirlig yro'fara!")
		to_chat(invoker, "<span class='brass'>You fail to stun [M]!</span>")
		playsound(invoker, 'sound/magic/mm_hit.ogg', 50, TRUE)
		return TRUE
	//Successful Invokation
	invoker.mob_light(_color = LIGHT_COLOR_CLOCKWORK, _range = 2, _duration = 10)
	if(!is_reebe(invoker.z))
		if(!HAS_TRAIT(M, TRAIT_MINDSHIELD))
			M.Paralyze(150)
		else
			to_chat(invoker, "<span class='brass'>[M] seems somewhat resistant to your powers!</span>")
			M.confused = CLAMP(M.confused, 50, INFINITY)
	if(issilicon(M))
		var/mob/living/silicon/S = M
		S.emp_act(EMP_HEAVY)
	else if(iscarbon(M))
		var/mob/living/carbon/C = M
		C.silent += 6
		C.stuttering += 15
		C.Jitter(15)
	if(M.client)
		var/client_color = M.client.color
		M.client.color = "#BE8700"
		animate(M.client, color = client_color, time = 25)
	playsound(invoker, 'sound/magic/staff_animation.ogg', 50, TRUE)
	return TRUE
