//==================================//
// !       Abscond       ! //
//==================================//

/datum/clockcult/scripture/abscond
	name = "Abscond"
	desc = "Return you and anyone you are dragging back to Reebe."
	tip = "Transports you and anyone you are dragging to Reebe."
	button_icon_state = "Abscond"
	power_cost = 5
	invokation_time = 50
	invokation_text = list("As we bid farewell, and return to the stars...", "...we shall find our way home.")
	var/client_color

/datum/clockcult/scripture/abscond/recital()
	client_color = invoker.client.color
	animate(invoker.client, color = "#AF0AAF", time = invokation_time)
	do_sparks(5, TRUE, invoker)
	. = ..()

/datum/clockcult/scripture/abscond/invoke_success()
	var/mob/living/M = invoker
	var/mob/living/P = M.pulling
	var/turf/T = get_turf(pick(GLOB.servant_spawns))
	playsound(invoker, 'sound/magic/magic_missile.ogg', 50, TRUE)
	playsound(T, 'sound/magic/magic_missile.ogg', 50, TRUE)
	do_sparks(5, TRUE, invoker)
	do_sparks(5, TRUE, T)
	M.forceMove(T)
	if(invoker.client)
		animate(invoker.client, color = client_color, time = 25)
	if(istype(P))
		P.forceMove(T)
		P.Paralyze(30)
		to_chat(P, "<span class='warning'>You feel sick and confused as your suddenly appear in a strange, forgotten land.</span>")

/datum/clockcult/scripture/abscond/invoke_fail()
	if(invoker?.client)
		animate(invoker.client, color = client_color, time = 10)

//==================================//
// !       Kindle       ! //
//==================================//
/datum/clockcult/scripture/slab/kindle
	name = "Kindle"
	desc = "Stuns and mutes a target from a short range."
	tip = "Stuns and mutes a target from a short range."
	button_icon_state = "Kindle"
	power_cost = 125
	invokation_time = 30
	invokation_text = list("Divinity, show them your light!")
	after_use_text = "Let the power flow through you!"
	slab_overlay = "volt"
	use_time = 150

/datum/clockcult/scripture/slab/kindle/apply_affects(atom/A)
	var/mob/living/M = A
	if(!istype(M))
		return FALSE
	if(!is_servant_of_ratvar(invoker))
		M = invoker
	/*if(is_servant_of_ratvar(M))
		return FALSE*/
	//Anti magic abilities
	var/anti_magic_source = M.anti_magic_check()
	if(anti_magic_source)
		M.mob_light(_color = LIGHT_COLOR_HOLY_MAGIC, _range = 2, _duration = 100)
		var/mutable_appearance/forbearance = mutable_appearance('icons/effects/genetics.dmi', "servitude", -MUTATIONS_LAYER)
		M.add_overlay(forbearance)
		addtimer(CALLBACK(M, /atom/proc/cut_overlay, forbearance), 100)
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
	M.Paralyze(150)
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

//==================================//
// !       Hateful Manacles       ! //
//==================================//
/datum/clockcult/scripture/slab/hateful_manacles
	name = "Hateful Menacles"
	desc = "Forms replicant manacles around a target's wrists that function like handcuffs."
	tip = "Handcuff a target at close range."
	button_icon_state = "Hateful Manacles"
	power_cost = 25
	invokation_time = 15
	invokation_text = list("Shackle the heretic...", "...Break them in body and spirit!")
	slab_overlay = "hateful_manacles"
	use_time = 200

/datum/clockcult/scripture/slab/hateful_manacles/apply_affects(atom/A)
	. = ..()
	var/mob/living/carbon/M = A
	if(!istype(M))
		return FALSE
	if(is_servant_of_ratvar(M))
		return FALSE
	if(M.handcuffed)
		to_chat(invoker, "<span class='brass'>[M] is already restrained!</span>")
		return FALSE
	playsound(src, 'sound/weapons/cablecuff.ogg', 30, TRUE, -2)
	M.visible_message("<span class='danger'>[invoker] forms a well of energy around [M], brass appearing at their wrists!</span>",\
						"<span class='userdanger'>[invoker] is trying to restrain you!</span>")
	if(do_after(invoker, 50, target=M))
		if(M.handcuffed)
			return FALSE
		//Todo, update with custom cuffs
		M.handcuffed = new /obj/item/restraints/handcuffs/cable/zipties/used(M)
		M.update_handcuffed()
		return TRUE
	return FALSE
