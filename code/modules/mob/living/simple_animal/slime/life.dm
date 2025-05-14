/mob/living/simple_animal/slime
	var/Discipline = 0 // if a slime has been hit with a freeze gun, or wrestled/attacked off a human, they become disciplined and don't attack anymore for a while
	var/SStun = 0 // stun variable

	var/monkey_bonus_damage = 2
	var/attack_cooldown = 0
	var/attack_cooldown_time = 20 //How long, in deciseconds, the cooldown of attacks is


/mob/living/simple_animal/slime/Life(delta_time = SSMOBS_DT, times_fired)
	set invisibility = 0
	if(notransform)
		return
	alpha = 255
	if(transformeffects & SLIME_EFFECT_BLACK)
		alpha = 64
	. = ..()
	if(!.)
		return

	if(buckled)
		handle_feeding(delta_time, times_fired)
	if(stat) // Slimes in stasis don't lose nutrition, don't change mood and don't respond to speech
		return
	handle_nutrition(delta_time, times_fired)
	if(QDELETED(src)) // Stop if the slime split during handle_nutrition()
		return
	reagents.remove_all(0.5 * REAGENTS_METABOLISM * reagents.reagent_list.len * delta_time) //Slimes are such snowflakes
	handle_targets(delta_time, times_fired)
	if(ckey)
		return
	handle_mood(delta_time, times_fired)
	handle_speech(delta_time, times_fired)
	if(colour == "red" && burn_damage_stored > 80 * delta_time)
		special_mutation = TRUE
		special_mutation_type = "crimson"
		visible_message(span_danger("[src] shudders, their red core deepening into an abyssal crimson."))
	burn_damage_stored = 0

// Unlike most of the simple animals, slimes support UNCONSCIOUS. This is an ugly hack.
/mob/living/simple_animal/slime/update_stat()
	switch(stat)
		if(UNCONSCIOUS, HARD_CRIT)
			if(health > 0)
				return
	return ..()

/mob/living/simple_animal/slime/process()
	if(stat == DEAD || !Target || client || buckled)
		return
	special_process = FALSE

	var/slime_on_target = 0
	if(Target.buckled_mobs?.len && (locate(/mob/living/simple_animal/slime) in Target.buckled_mobs))
		slime_on_target = 1

	if(Target.get_virtual_z_level() == src.get_virtual_z_level() && attack_cooldown < world.time && get_dist(Target, src) <= 1)
		if(!slime_on_target && CanFeedon(Target))
			if(!Target.client || prob(20))
				Feedon(Target)
				special_process = FALSE
				reset_processing()
				return
		if((attacked || rabid) && Adjacent(Target))
			Target.attack_slime(src)
			attack_cooldown = world.time + attack_cooldown_time
	else if(src in viewers(7, Target))
		if((transformeffects & SLIME_EFFECT_BLUESPACE) && powerlevel >= 5)
			do_teleport(src, get_turf(Target), asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)
			powerlevel -= 5
		else
			step_to(src, Target)
	else
		special_process = FALSE
		set_target(null)

	reset_processing()

/mob/living/simple_animal/slime/proc/reset_processing()
	var/sleeptime = cached_multiplicative_slowdown
	if(sleeptime <= 0)
		sleeptime = 1
	addtimer(VARSET_CALLBACK(src, special_process, TRUE), (sleeptime + 2), TIMER_UNIQUE)

/mob/living/simple_animal/slime/handle_environment(datum/gas_mixture/environment, delta_time, times_fired)

	var/loc_temp = get_temperature(environment)
	var/divisor = 10 /// The divisor controls how fast body temperature changes, lower causes faster changes

	var/temp_delta = loc_temp - bodytemperature
	if(abs(temp_delta) > 50) // If the difference is great, reduce the divisor for faster stabilization
		divisor = 5

	if(temp_delta < 0) // It is cold here
		if(!on_fire) // Do not reduce body temp when on fire
			adjust_bodytemperature(clamp((temp_delta / divisor) * delta_time, temp_delta, 0))
	else // This is a hot place
		adjust_bodytemperature(clamp((temp_delta / divisor) * delta_time, 0, temp_delta))

	if(bodytemperature < (T0C + 5)) // start calculating temperature damage etc

		if(bodytemperature <= (T0C - 50)) // hurt temperature
			if(bodytemperature <= 50) // sqrting negative numbers is bad
				adjustBruteLoss(100 * delta_time)
			else
				adjustBruteLoss(round(sqrt(bodytemperature)) * delta_time)

	if(stat != DEAD)
		var/bz_percentage = environment.total_moles() ? (GET_MOLES(/datum/gas/bz, environment) / environment.total_moles()) : 0
		var/stasis = (bz_percentage >= 0.05 && bodytemperature < (T0C + 100)) || force_stasis
		if(transformeffects & SLIME_EFFECT_DARK_PURPLE)
			var/amt = is_adult ? 30 : 15
			var/plas_amt = min(amt,GET_MOLES(/datum/gas/plasma, environment))
			REMOVE_MOLES(/datum/gas/plasma, environment, plas_amt)
			ADD_MOLES(/datum/gas/oxygen, environment, plas_amt)
			adjustBruteLoss(plas_amt ? -2 : 0)

		switch(stat)
			if(CONSCIOUS)
				if(stasis)
					to_chat(src, span_danger("Nerve gas in the air has put you in stasis!"))
					set_stat(UNCONSCIOUS)
					powerlevel = 0
					rabid = FALSE
					regenerate_icons()
			if(UNCONSCIOUS, HARD_CRIT)
				if(!stasis)
					to_chat(src, span_notice("You wake up from the stasis."))
					set_stat(CONSCIOUS)
					regenerate_icons()

	updatehealth()


	return //TODO: DEFERRED

/mob/living/simple_animal/slime/handle_status_effects(delta_time, times_fired)
	..()
	if(!stat && DT_PROB(16, delta_time))
		var/heal = 0.5
		if(transformeffects & SLIME_EFFECT_PURPLE)
			heal += 0.25
		adjustBruteLoss(-heal * delta_time)
	if((transformeffects & SLIME_EFFECT_RAINBOW) && DT_PROB(5, delta_time))
		random_colour()

/mob/living/simple_animal/slime/proc/handle_feeding(delta_time, times_fired)
	if(!isliving(buckled))
		return
	alpha = 255
	var/mob/living/M = buckled
	if(transformeffects & SLIME_EFFECT_OIL)
		var/datum/reagent/fuel/fuel = new
		fuel.expose_mob(buckled,TOUCH,20)
		qdel(fuel)
	if(M.stat == DEAD)
		if(client)
			to_chat(src, "<i>This subject does not have a strong enough life energy anymore...</i>")
		//we go rabid after finishing to feed on a human with a client.
		if(M.client && ishuman(M))
			rabid = 1

		set_target(null)
		special_process = FALSE
		Feedstop()
		return

	if(DT_PROB(5, delta_time) && M.client)
		to_chat(M, "<span class='userdanger'>[pick("You can feel your body becoming weak!", \
		"You feel like you're about to die!", \
		"You feel every part of your body screaming in agony!", \
		"A low, rolling pain passes through your body!", \
		"Your body feels as if it's falling apart!", \
		"You feel extremely weak!", \
		"A sharp, deep pain bathes every inch of your body!")]</span>")

	var/bonus_damage = 1
	if(transformeffects & SLIME_EFFECT_RED)
		bonus_damage *= 1.1
	M.adjustCloneLoss(4*bonus_damage)
	M.adjustToxLoss(2*bonus_damage)
	if(ismonkey(M))
		M.adjustCloneLoss(monkey_bonus_damage*bonus_damage)

	add_nutrition((15 * CONFIG_GET(number/damage_multiplier)))
	adjustBruteLoss(-2.5 * delta_time)

/mob/living/simple_animal/slime/proc/handle_nutrition(delta_time, times_fired)
	if(docile) //God as my witness, I will never go hungry again
		set_nutrition(700) //fuck you for using the base nutrition var
		return

	if(DT_PROB(7.5, delta_time) && !(transformeffects & SLIME_EFFECT_SILVER))
		adjust_nutrition(-0.5 * (1 + is_adult) * delta_time)

	if(nutrition <= 0)
		set_nutrition(0)
		adjustBruteLoss(1)
	else if (nutrition >= get_grow_nutrition() && amount_grown < SLIME_EVOLUTION_THRESHOLD)
		adjust_nutrition(-10 * delta_time)
		amount_grown++
		update_action_buttons_icon()

	if(amount_grown >= SLIME_EVOLUTION_THRESHOLD && !buckled && !Target && !ckey)
		if(is_adult)
			Reproduce()
		else
			Evolve()

/mob/living/simple_animal/slime/proc/add_nutrition(nutrition_to_add = 0)
	var/gainpower = (transformeffects & SLIME_EFFECT_YELLOW) ? 3 : 1
	set_nutrition(min((nutrition + nutrition_to_add), get_max_nutrition()))
	if(nutrition >= get_grow_nutrition())
		if(powerlevel<10)
			if(prob(30-powerlevel*2))
				powerlevel += gainpower
	else if(nutrition >= get_hunger_nutrition() + 100) //can't get power levels unless you're a bit above hunger level.
		if(powerlevel<5)
			if(prob(25-powerlevel*5))
				powerlevel += gainpower

/mob/living/simple_animal/slime/proc/handle_targets(delta_time, times_fired)
	if(attacked > 50)
		attacked = 50

	if(attacked > 0)
		attacked--

	if(Discipline > 0)
		if(Discipline >= 5 && rabid && DT_PROB(37, delta_time))
			rabid = 0
		if(DT_PROB(5, delta_time))
			Discipline--

	if(buckled || client)
		return

	if(Target)
		--target_patience
		if (target_patience <= 0 || SStun > world.time || Discipline || attacked || docile)
			target_patience = 0
			set_target(null)
			special_process = FALSE

	var/hungry = 0

	if (nutrition < get_starve_nutrition())
		hungry = 2
	else if (nutrition < get_grow_nutrition() || nutrition < get_hunger_nutrition())
		hungry = 1

	if(hungry == 2)
		if(Friends.len > 0 && DT_PROB(0.5, delta_time))
			var/mob/nofriend = pick(Friends)
			add_friendship(nofriend, -1)

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
						set_target(L)
				else
					set_target(L)

				if(Target)
					target_patience = rand(5,7)
					if(is_adult)
						target_patience += 3
					break

	if(!Target) // If we have no target, we are wandering or following orders
		if (Leader)
			if(holding_still)
				holding_still = max(holding_still - (0.5 * delta_time), 0)
			else if(!HAS_TRAIT(src, TRAIT_IMMOBILIZED) && isturf(loc))
				step_to(src, Leader)
		else if(hungry)
			if (holding_still)
				holding_still = max(holding_still - (0.5 * hungry * delta_time), 0)
			else if(!HAS_TRAIT(src, TRAIT_IMMOBILIZED) && isturf(loc) && prob(50))
				step(src, pick(GLOB.cardinals))
		else
			if(holding_still)
				holding_still = max(holding_still - (0.5 * delta_time), 0)
			else if (docile && pulledby)
				holding_still = 10
			else if(!HAS_TRAIT(src, TRAIT_IMMOBILIZED) && isturf(loc) && prob(33))
				step(src, pick(GLOB.cardinals))
	else if(!special_process)
		special_process = TRUE

/mob/living/simple_animal/slime/handle_automated_movement()
	return //slime random movement is currently handled in handle_targets()

/mob/living/simple_animal/slime/handle_automated_speech()
	return //slime random speech is currently handled in handle_speech()

/mob/living/simple_animal/slime/proc/handle_mood(delta_time, times_fired)
	var/newmood = ""
	if (rabid || attacked)
		newmood = "angry"
	else if (docile)
		newmood = ":3"
	else if (Target)
		newmood = "mischievous"

	if (!newmood)
		if (Discipline && DT_PROB(13, delta_time))
			newmood = "pout"
		else if (DT_PROB(0.5, delta_time))
			newmood = pick("sad", ":3", "pout")

	if ((mood == "sad" || mood == ":3" || mood == "pout") && !newmood)
		if(prob(75))
			newmood = mood

	if (newmood != mood) // This is so we don't redraw them every time
		mood = newmood
		regenerate_icons()

/mob/living/simple_animal/slime/proc/handle_speech(delta_time, times_fired)
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
						set_leader(who)
						to_say = "Yes... I follow [who]..."
					else
						to_say = "No... I follow [Leader]..."
				else
					if (Friends[who] >= SLIME_FRIENDSHIP_FOLLOW)
						set_leader(who)
						to_say = "I follow..."
					else // Not friendly enough
						to_say = pick("No...", "I no follow...")
			else if (findtext(phrase, "stop"))
				if (buckled) // We are asked to stop feeding
					if (Friends[who] >= SLIME_FRIENDSHIP_STOPEAT)
						Feedstop()
						set_target(null)
						if (Friends[who] < SLIME_FRIENDSHIP_STOPEAT_NOANGRY)
							add_friendship(who, -1)
							to_say = "Grrr..." // I'm angry but I do it
						else
							to_say = "Fine..."
				else if (Target) // We are asked to stop chasing
					if (Friends[who] >= SLIME_FRIENDSHIP_STOPCHASE)
						set_target(null)
						if (Friends[who] < SLIME_FRIENDSHIP_STOPCHASE_NOANGRY)
							add_friendship(who, -1)
							to_say = "Grrr..." // I'm angry but I do it
						else
							to_say = "Fine..."
				else if (Leader) // We are asked to stop following
					if (Leader == who)
						to_say = "Yes... I stay..."
						set_leader(null)
					else
						if (Friends[who] > Friends[Leader])
							set_leader(null)
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
					set_target(who)
					special_process = TRUE
					to_say = "ATTACK!?!?"
				else if (Friends[who] >= SLIME_FRIENDSHIP_ATTACK)
					for (var/mob/living/L in view(7,src)-list(src,who))
						if (findtext(phrase, LOWER_TEXT(L.name)))
							if (isslime(L))
								to_say = "NO... [L] slime friend"
								add_friendship(who, -1) //Don't ask a slime to attack its friend
							else if(!Friends[L] || Friends[L] < 1)
								set_target(L)
								special_process = TRUE
								to_say = "Ok... I attack [Target]"
							else
								to_say = "No... like [L] ..."
								add_friendship(who, -1) //Don't ask a slime to attack its friend
							break
				else
					to_say = "No... no listen"

		speech_buffer = list()

	//Speech starts here
	if (to_say)
		INVOKE_ASYNC(src, /atom/movable/proc/say, to_say)
	else if(DT_PROB(0.5, delta_time))
		INVOKE_ASYNC(src, TYPE_PROC_REF(/mob, emote), pick("bounce","sway","light","vibrate","jiggle"))
	else
		var/t = 10
		var/slimes_near = 0
		var/dead_slimes = 0
		var/friends_near = list()
		for (var/mob/living/L in oview(7,src))
			if(isslime(L))
				++slimes_near
				if (L.stat == DEAD)
					++dead_slimes
			if(L in Friends)
				t += 20
				friends_near += L
		if (nutrition < get_hunger_nutrition())
			t += 10
		if (nutrition < get_starve_nutrition())
			t += 10
		if (DT_PROB(1, delta_time) && prob(t))
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
				INVOKE_ASYNC(src, /atom/movable/proc/say, pick(phrases))

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

