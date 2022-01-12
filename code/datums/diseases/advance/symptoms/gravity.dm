/datum/symptom/gravity
	name = "Gravitic Biopotential Instability Syndrome"
	desc = "The virus causes localized gravity changes within the host, resulting in rapidly changing gravity."
	stealth = -3
	resistance = -1
	stage_speed = -2
	transmission = -1
	level = 9
	severity = 2
	symptom_delay_min = 5
	symptom_delay_max = 10
	prefixes = list("Gravitic ")
	var/throwobj = FALSE
	var/datum/component/forced_gravity/gravcomponent
	power = 2 // "power" here is used to determine the maximum and minimum gravity levels enacted upon the host. 
	threshold_desc = "<b>Transmission 6:</b>The host may spontaneously cause gravity wells, bringing nearby objects closer.<br>\
					  <b>Resistance 6:</b> The gravitic instability becomes intense enough to cause damage to the host.<br>\
					  <b>Resistance 10:</b>	The gravitic instability becomes intense enough that it may cause the host to spontaneously implode." //gibs hosts who are crit if the virus is dealing enough damage

/datum/symptom/gravity/severityset(datum/disease/advance/A)
	. = ..()
	if(A.transmission >= 6)
		severity += 1
		suffixes = list(" Possession")
		bodies = list("Poltergeist")
	if(A.resistance >= 6)
		severity += 1
		prefixes = list("Gravitic ", "Crushing ")
	if(A.resistance >= 10)
		severity += 2
		prefixes = list("Gibbington's ", "Crushing ", "Gravitic ")

/datum/symptom/gravity/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.transmission >= 6)
		throwobj = TRUE
	if(A.resistance >= 6)
		power = 4
	if(A.resistance >= 10)
		power = 6

/datum/symptom/gravity/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	if(A.stage == 5)
		if(!gravcomponent)
			gravcomponent = M.AddComponent(/datum/component/forced_gravity, rand(0, power))
		else 
			var/lastgravity = gravcomponent.gravity
			var/realpower = power
			if(lastgravity >= 3)
				realpower = 2 //never have a damaging cycle twice in a row
			gravcomponent.gravity = rand(0, power)
			M.update_gravity(gravcomponent.gravity)
			if(throwobj && prob(40))
				var/list/throwing = list()
				for(var/atom/movable/AM in orange(5, get_turf(M)))
					if(AM == M || AM.anchored)
						continue
					if(ismob(AM))
						var/mob/L = AM
						if(L.mob_negates_gravity())
							continue
					throwing += AM
				for(var/O in 0 to min((power + 1), LAZYLEN(throwing)))
					var/atom/movable/AM = pick_n_take(throwing)
					if(AM)
						AM.throw_at(M, 4, 2)
			if(gravcomponent.gravity >= 6 && M.stat >= UNCONSCIOUS && !HAS_TRAIT(M, TRAIT_NODISMEMBER))
				M.visible_message("<span class='userdanger'>[M]'s body contorts, compresses, and collapses in on itself, before exploding into a shower of gore!</span>")
				playsound(M, 'sound/magic/demon_consume.ogg', 50, 1, -1)
				M.gib()
				return
			if((gravcomponent.gravity - realpower) >= 2 && (M.mobility_flags & MOBILITY_STAND) && !(isspaceturf(get_turf(M))))
				M.Knockdown((gravcomponent.gravity - realpower) * 10)
				playsound(M, 'sound/effects/meteorimpact.ogg', 25, 1, -1)
				M.visible_message("<span class='danger'>[M] is slammed into the ground by an unseen force!</span>",   "<span class='userdanger'>A sudden increase in gravity slams you into the ground!</span>")
			if(gravcomponent.gravity == 0)
				M.visible_message("<span class='danger'>[M] floats away from the ground, as if gravity no longer works on them!</span>",   "<span class='userdanger'>The ground falls away under you... You're floating!</span>")
	else if(prob(40))
		to_chat(M, "<span class='danger'>[pick("You feel heavy", "You feel incredibly light", "Your arms sag towards the floor")]</span>")

/datum/symptom/gravity/End(datum/disease/advance/A)
	. = ..()
	if(gravcomponent)
		gravcomponent.RemoveComponent()
		gravcomponent = null

/datum/symptom/gravity/OnDeath(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	if(power >= 6)
		M.visible_message("<span class='userdanger'>[M]'s body contorts, compresses, and collapses in on itself, before exploding into a shower of gore!</span>")
		playsound(M, 'sound/magic/demon_consume.ogg', 50, 1, -1)
		addtimer(CALLBACK(M, /mob/proc/gib), 0.5 SECONDS)	//we can't gib mob while it's already dying
