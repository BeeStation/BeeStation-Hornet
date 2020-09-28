/mob/living/simple_animal/slime
	var/Discipline = 0 // if a slime has been hit with a freeze gun, or wrestled/attacked off a human, they become disciplined and don't attack anymore for a while
	var/SStun = 0 // stun variable

	var/monkey_bonus_damage = 2
	var/attack_cooldown = 0
	var/attack_cooldown_time = 20 //How long, in deciseconds, the cooldown of attacks is

/mob/living/simple_animal/slime/Life()
	set invisibility = 0

	if (notransform)
		return
	if(..())
		if(buckled)
			handle_feeding()
		if(!stat) // Slimes in stasis don't lose nutrition, don't change mood and don't respond to speech
			handle_nutrition()
			handle_targets()
			if(!ckey)
				handle_mood()
				handle_speech()

// Unlike most of the simple animals, slimes support UNCONSCIOUS
/mob/living/simple_animal/slime/update_stat()
	if(stat == UNCONSCIOUS && health > 0)
		return
	..()

/mob/living/simple_animal/slime/proc/AIprocess()
	if(stat == DEAD || !Target || client || buckled)
		return

	var/slime_on_target = 0
	if(Target.buckled_mobs?.len && (locate(/mob/living/simple_animal/slime) in Target.buckled_mobs))
		slime_on_target = 1

	if(Target.z == src.z && attack_cooldown < world.time && get_dist(Target, src) <= 1)
		if(!slime_on_target && CanFeedon(Target))
			if(!Target.client || prob(20))
				Feedon(Target)
				special_process = FALSE
				return
		if(attacked || rabid)
			Target.attack_slime(src)
			attack_cooldown = world.time + attack_cooldown_time
	else if(Target in view(7, src))
		step_to(src, Target)
	else
		special_process = FALSE
		Target = null
		return

	var/sleeptime = movement_delay()
	if(sleeptime <= 0)
		sleeptime = 1

	addtimer(VARSET_CALLBACK(src, special_process, TRUE), (sleeptime + 2), TIMER_UNIQUE)

/mob/living/simple_animal/slime/handle_environment(datum/gas_mixture/environment)
	if(!environment)
		return

	var/loc_temp = get_temperature(environment)

	adjust_bodytemperature(adjust_body_temperature(bodytemperature, loc_temp, 1))

	//Account for massive pressure differences

	if(bodytemperature < (T0C + 5)) // start calculating temperature damage etc

		if(bodytemperature <= (T0C - 50)) // hurt temperature
			if(bodytemperature <= 50) // sqrting negative numbers is bad
				adjustBruteLoss(200)
			else
				adjustBruteLoss(round(sqrt(bodytemperature)) * 2)

	if(stat != DEAD)
		var/bz_percentage = environment.total_moles() ? (environment.get_moles(/datum/gas/bz) / environment.total_moles()) : 0
		var/stasis = (bz_percentage >= 0.05 && bodytemperature < (T0C + 100)) || force_stasis

		if(stat == CONSCIOUS && stasis)
			to_chat(src, "<span class='danger'>Nerve gas in the air has put you in stasis!</span>")
			stat = UNCONSCIOUS
			powerlevel = 0
			rabid = 0
			update_mobility()
			regenerate_icons()
		else if(stat == UNCONSCIOUS && !stasis)
			to_chat(src, "<span class='notice'>You wake up from the stasis.</span>")
			stat = CONSCIOUS
			update_mobility()
			regenerate_icons()

	updatehealth()


	return //TODO: DEFERRED

/mob/living/simple_animal/slime/proc/adjust_body_temperature(current, loc_temp, boost)
	var/temperature = current
	var/difference = abs(current-loc_temp)	//get difference
	var/increments// = difference/10			//find how many increments apart they are
	if(difference > 50)
		increments = difference/5
	else
		increments = difference/10
	var/change = increments*boost	// Get the amount to change by (x per increment)
	var/temp_change
	if(current < loc_temp)
		temperature = min(loc_temp, temperature+change)
	else if(current > loc_temp)
		temperature = max(loc_temp, temperature-change)
	temp_change = (temperature - current)
	return temp_change

/mob/living/simple_animal/slime/handle_status_effects()
	..()
	if(prob(30) && !stat)
		adjustBruteLoss(-1)

/mob/living/simple_animal/slime/proc/handle_feeding()
	if(!ismob(buckled))
		return

	var/mob/M = buckled

	if(M.stat == DEAD)
		if(client)
			to_chat(src, "<i>This subject does not have a strong enough life energy anymore...</i>")
		else if(!rabid && !attacked && M.LAssailant && prob(50))
			if(M.LAssailant in Friends)
				++Friends[M.LAssailant]
			else
				Friends[M.LAssailant] = 1
		//we go rabid after finishing to feed on a human with a client.
		if(M.client && ishuman(M))
			rabid = 1

		Target = null
		special_process = FALSE
		Feedstop()
		return

	if(prob(10) && M.client)
		to_chat(M, "<span class='userdanger'>[pick("You can feel your body becoming weak!", \
		"You feel like you're about to die!", \
		"You feel every part of your body screaming in agony!", \
		"A low, rolling pain passes through your body!", \
		"Your body feels as if it's falling apart!", \
		"You feel extremely weak!", \
		"A sharp, deep pain bathes every inch of your body!")]</span>")

	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(ismonkey(M))
			C.adjustCloneLoss(monkey_bonus_damage)

		C.adjustCloneLoss(4)
		C.adjustToxLoss(2)
	else if(isanimal(M))
		var/mob/living/simple_animal/SA = M
		SA.adjustCloneLoss(4)
		SA.adjustToxLoss(2)

	add_nutrition((15 * CONFIG_GET(number/damage_multiplier)))
	adjustBruteLoss(-5)

/mob/living/simple_animal/slime/proc/handle_nutrition()
	if(docile) //God as my witness, I will never go hungry again
		set_nutrition(700) //fuck you for using the base nutrition var
		return

	if(prob(15))
		adjust_nutrition(-(1 + is_adult))

	if(nutrition <= 0)
		set_nutrition(0)
		adjustBruteLoss(1)
	else if (nutrition >= get_grow_nutrition() && amount_grown < SLIME_EVOLUTION_THRESHOLD)
		adjust_nutrition(-20)
		amount_grown++
		update_action_buttons_icon()

	if(amount_grown >= SLIME_EVOLUTION_THRESHOLD && !buckled && !Target && !ckey)
		if(is_adult)
			Reproduce()
		else
			Evolve()

/mob/living/simple_animal/slime/proc/add_nutrition(nutrition_to_add = 0)
	set_nutrition(min((nutrition + nutrition_to_add), get_max_nutrition()))
	if(nutrition >= get_grow_nutrition())
		if(powerlevel<10)
			if(prob(30-powerlevel*2))
				powerlevel++
	else if(nutrition >= get_hunger_nutrition() + 100) //can't get power levels unless you're a bit above hunger level.
		if(powerlevel<5)
			if(prob(25-powerlevel*5))
				powerlevel++




/mob/living/simple_animal/slime/proc/handle_targets()
	update_mobility()

	if(attacked > 50)
		attacked = 50

	if(attacked > 0)
		attacked--

	if(Discipline > 0)
		if(Discipline >= 5 && rabid && prob(60))
			rabid = 0
		if(prob(5))
			Discipline--

	if(buckled || client)
		return

	if(Target)
		--target_patience
		if (target_patience <= 0 || SStun > world.time || Discipline || attacked || docile)
			target_patience = 0
			Target = null
			special_process = FALSE

	var/hungry = 0

	if (nutrition < get_starve_nutrition())
		hungry = 2
	else if (nutrition < get_grow_nutrition() || nutrition < get_hunger_nutrition())
		hungry = 1

	if(hungry == 2)
		if(Friends.len > 0 && prob(1))
			var/mob/nofriend = pick(Friends)
			--Friends[nofriend]

	if(!Target)
		if(will_hunt() && hungry || attacked || rabid)
			for(var/mob/living/L in view(7,src))
				if(isslime(L) || L.stat == DEAD)
					continue

				if(L in Friends)
					continue

				if((locate(/mob/living/simple_animal/slime) in L.buckled_mobs || issilicon(L)) && !(attacked || rabid))
					continue

				if(ishuman(L))
					if(!Discipline && prob(5) || attacked || rabid)
						Target = L
				else
					Target = L

				if(Target)
					target_patience = rand(5,7)
					if(is_adult)
						target_patience += 3
					break

	if(!Target) // If we have no target, we are wandering or following orders
		if (Leader)
			if(holding_still)
				holding_still = max(holding_still - 1, 0)
			else if((mobility_flags & MOBILITY_MOVE) && isturf(loc))
				step_to(src, Leader)
		else if(hungry)
			if (holding_still)
				holding_still = max(holding_still - hungry, 0)
			else if((mobility_flags & MOBILITY_MOVE) && isturf(loc) && prob(50))
				step(src, pick(GLOB.cardinals))
		else
			if(holding_still)
				holding_still = max(holding_still - 1, 0)
			else if (docile && pulledby)
				holding_still = 10
			else if((mobility_flags & MOBILITY_MOVE) && isturf(loc) && prob(33))
				step(src, pick(GLOB.cardinals))
	else if(!special_process)
		special_process = TRUE

/mob/living/simple_animal/slime/handle_automated_movement()
	return //slime random movement is currently handled in handle_targets()

/mob/living/simple_animal/slime/handle_automated_speech()
	return //slime random speech is currently handled in handle_speech()

/mob/living/simple_animal/slime/proc/handle_mood()
	var/newmood = ""
	if (rabid || attacked)
		newmood = "angry"
	else if (docile)
		newmood = ":3"
	else if (Target)
		newmood = "mischievous"

	if (!newmood)
		if (Discipline && prob(25))
			newmood = "pout"
		else if (prob(1))
			newmood = pick("sad", ":3", "pout")

	if ((mood == "sad" || mood == ":3" || mood == "pout") && !newmood)
		if(prob(75))
			newmood = mood

	if (newmood != mood) // This is so we don't redraw them every time
		mood = newmood
		regenerate_icons()

/mob/living/simple_animal/slime/proc/handle_speech()
	//Speech understanding starts here
	var/to_say
	if (speech_buffer.len > 0)
		var/who = speech_buffer[1] // Who said it?
		var/phrase = speech_buffer[2] // What did they say?
		if ((findtext(phrase, num2text(number)) || findtext(phrase, "slimes"))) // Talking to us
			if (findtext(phrase, "hello") || findtext(phrase, "hi"))
				to_say = pick("Hello...", "Hi...")
			else if (findtext(phrase, "follow"))
				if (Leader)
					if (Leader == who) // Already following him
						to_say = pick("Yes...", "Lead...", "Follow...")
					else if (Friends[who] > Friends[Leader]) // VIVA
						Leader = who
						to_say = "Yes... I follow [who]..."
					else
						to_say = "No... I follow [Leader]..."
				else
					if (Friends[who] >= SLIME_FRIENDSHIP_FOLLOW)
						Leader = who
						to_say = "I follow..."
					else // Not friendly enough
						to_say = pick("No...", "I no follow...")
			else if (findtext(phrase, "stop"))
				if (buckled) // We are asked to stop feeding
					if (Friends[who] >= SLIME_FRIENDSHIP_STOPEAT)
						Feedstop()
						Target = null
						if (Friends[who] < SLIME_FRIENDSHIP_STOPEAT_NOANGRY)
							--Friends[who]
							to_say = "Grrr..." // I'm angry but I do it
						else
							to_say = "Fine..."
				else if (Target) // We are asked to stop chasing
					if (Friends[who] >= SLIME_FRIENDSHIP_STOPCHASE)
						Target = null
						if (Friends[who] < SLIME_FRIENDSHIP_STOPCHASE_NOANGRY)
							--Friends[who]
							to_say = "Grrr..." // I'm angry but I do it
						else
							to_say = "Fine..."
				else if (Leader) // We are asked to stop following
					if (Leader == who)
						to_say = "Yes... I stay..."
						Leader = null
					else
						if (Friends[who] > Friends[Leader])
							Leader = null
							to_say = "Yes... I stop..."
						else
							to_say = "No... keep follow..."
			else if (findtext(phrase, "stay"))
				if (Leader)
					if (Leader == who)
						holding_still = Friends[who] * 10
						to_say = "Yes... stay..."
					else if (Friends[who] > Friends[Leader])
						holding_still = (Friends[who] - Friends[Leader]) * 10
						to_say = "Yes... stay..."
					else
						to_say = "No... keep follow..."
				else
					if (Friends[who] >= SLIME_FRIENDSHIP_STAY)
						holding_still = Friends[who] * 10
						to_say = "Yes... stay..."
					else
						to_say = "No... won't stay..."
			else if (findtext(phrase, "attack"))
				if (rabid && prob(20))
					Target = who
					special_process = TRUE
					to_say = "ATTACK!?!?"
				else if (Friends[who] >= SLIME_FRIENDSHIP_ATTACK)
					for (var/mob/living/L in view(7,src)-list(src,who))
						if (findtext(phrase, lowertext(L.name)))
							if (isslime(L))
								to_say = "NO... [L] slime friend"
								--Friends[who] //Don't ask a slime to attack its friend
							else if(!Friends[L] || Friends[L] < 1)
								Target = L
								special_process = TRUE
								to_say = "Ok... I attack [Target]"
							else
								to_say = "No... like [L] ..."
								--Friends[who] //Don't ask a slime to attack its friend
							break
				else
					to_say = "No... no listen"

		speech_buffer = list()

	//Speech starts here
	if (to_say)
		say (to_say)
	else if(prob(1))
		emote(pick("bounce","sway","light","vibrate","jiggle"))
	else
		var/t = 10
		var/slimes_near = 0
		var/dead_slimes = 0
		var/friends_near = list()
		for (var/mob/living/L in view(7,src))
			if(isslime(L) && L != src)
				++slimes_near
				if (L.stat == DEAD)
					++dead_slimes
			if (L in Friends)
				t += 20
				friends_near += L
		if (nutrition < get_hunger_nutrition())
			t += 10
		if (nutrition < get_starve_nutrition())
			t += 10
		if (prob(2) && prob(t))
			var/phrases = list()
			if (Target)
				phrases += "[Target]... look yummy..."
			if (nutrition < get_starve_nutrition())
				phrases += "So... hungry..."
				phrases += "Very... hungry..."
				phrases += "Need... food..."
				phrases += "Must... eat..."
			else if (nutrition < get_hunger_nutrition())
				phrases += "Hungry..."
				phrases += "Where food?"
				phrases += "I want to eat..."
			phrases += "Rawr..."
			phrases += "Blop..."
			phrases += "Blorble..."
			if (rabid || attacked)
				phrases += "Hrr..."
				phrases += "Nhuu..."
				phrases += "Unn..."
			if (mood == ":3")
				phrases += "Purr..."
			if (attacked)
				phrases += "Grrr..."
			if (bodytemperature < T0C)
				phrases += "Cold..."
			if (bodytemperature < T0C - 30)
				phrases += "So... cold..."
				phrases += "Very... cold..."
			if (bodytemperature < T0C - 50)
				phrases += "..."
				phrases += "C... c..."
			if (buckled)
				phrases += "Nom..."
				phrases += "Yummy..."
			if (powerlevel > 3)
				phrases += "Bzzz..."
			if (powerlevel > 5)
				phrases += "Zap..."
			if (powerlevel > 8)
				phrases += "Zap... Bzz..."
			if (mood == "sad")
				phrases += "Bored..."
			if (slimes_near)
				phrases += "Slime friend..."
			if (slimes_near > 1)
				phrases += "Slime friends..."
			if (dead_slimes)
				phrases += "What happened?"
			if (!slimes_near)
				phrases += "Lonely..."
			for (var/M in friends_near)
				phrases += "[M]... friend..."
				if (nutrition < get_hunger_nutrition())
					phrases += "[M]... feed me..."
			if(!stat)
				say (pick(phrases))

/mob/living/simple_animal/slime/proc/get_max_nutrition() // Can't go above it
	if (is_adult)
		return 1200
	else
		return 1000

/mob/living/simple_animal/slime/proc/get_grow_nutrition() // Above it we grow, below it we can eat
	if (is_adult)
		return 1000
	else
		return 800

/mob/living/simple_animal/slime/proc/get_hunger_nutrition() // Below it we will always eat
	if (is_adult)
		return 600
	else
		return 500

/mob/living/simple_animal/slime/proc/get_starve_nutrition() // Below it we will eat before everything else
	if(is_adult)
		return 300
	else
		return 200

/mob/living/simple_animal/slime/proc/will_hunt(hunger = -1) // Check for being stopped from feeding and chasing
	if (docile)
		return 0
	if (hunger == 2 || rabid || attacked)
		return 1
	if (Leader)
		return 0
	if (holding_still)
		return 0
	return 1
