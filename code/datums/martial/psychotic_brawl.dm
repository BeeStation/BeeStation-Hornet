/datum/martial_art/psychotic_brawling
	name = "Psychotic Brawling"
	id = MARTIALART_PSYCHOBRAWL

/datum/martial_art/psychotic_brawling/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return psycho_disarm(A,D)

/datum/martial_art/psychotic_brawling/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return psycho_grab(A,D)

/datum/martial_art/psychotic_brawling/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return psycho_attack(A,D)

/datum/martial_art/psychotic_brawling/proc/psycho_disarm(mob/living/carbon/human/A, mob/living/carbon/human/D)
	var/atk_verb
	switch(rand(1,6))
		if(1)
			A.do_attack_animation(D, ATTACK_EFFECT_DISARM)
			playsound(D, 'sound/weapons/slap.ogg', 50, TRUE, -1)
			var/throwtarget = get_edge_target_turf(A, get_dir(A, get_step_away(D, A)))
			D.throw_at(throwtarget, 4, 2, A)
			D.visible_message("<span class='warning'>[A] shoves [D] across the room!</span>", "<span class='userdanger'>[A] shoves you with inhuman strength!</span>")
			D.Knockdown(60)
			atk_verb = "shoves"
		if(2,3)
			var/throw_dir = pick(GLOB.alldirs)
			var/atom/throw_target = get_edge_target_turf(A, throw_dir)
			A.throw_at(throw_target, 1, 4)
			A.visible_message("<span class='warning'>[A] trips over [A.p_them()]self!</span>", "<span class='userdanger'>You stumble and trip!</span>")
			A.Paralyze(40)
			A.Knockdown(60)
		if(4)
			A.visible_message("<span class='warning'>[A] starts throwing a tantrum!</span>")
			A.emote("scream")
			atk_verb = "throws a tantrum at"
			A.Paralyze(12)
			A.Knockdown(25)
			for(var/i in list(NORTH,SOUTH,EAST,WEST,EAST,SOUTH,NORTH,SOUTH,EAST,WEST,EAST,SOUTH))
				if(!A)
					break
				A.setDir(i)
				playsound(A.loc, pick('sound/weapons/punch1.ogg', 'sound/weapons/genhit.ogg', 'sound/weapons/slap.ogg', 'sound/effects/meteorimpact.ogg'), 15, 1, -1)
				stoplag(1)
			var/obj/effect/proc_holder/spell/aoe_turf/repulse/R = new(null)
			R.cast(RANGE_TURFS(1,A))
		if(5)
			var/obj/item/I = D.get_active_held_item()
			if(I && D.temporarilyRemoveItemFromInventory(I))
				A.put_in_hands(I)
				D.visible_message("<span class='warning'>[A] takes [D]'s [I]!</span>", "<span class='userdanger'>[A] snatches the [I] from your hands!!</span>")
			else
				D.visible_message("<span class='warning'>[A] shoves [D]!</span>", "<span class='userdanger'>[A] shoves you to the ground!</span>")
				if(!(D.mobility_flags & MOBILITY_STAND))
					D.Paralyze(40)
				else
					D.Knockdown(20)
			atk_verb = "disarms"
			playsound(D, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
			A.do_attack_animation(D, ATTACK_EFFECT_DISARM)
		if(6)
			playsound(D, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
			A.do_attack_animation(D, ATTACK_EFFECT_DISARM)
			D.visible_message("<span class='warning'>[A] shoves [D] with great force!</span>", "<span class='userdanger'>[A] shoves you to the ground!</span>")
			if(!(D.mobility_flags & MOBILITY_STAND))
				D.Paralyze(20)
			else
				var/throwtarget = get_edge_target_turf(A, get_dir(A, get_step_away(D, A)))
				D.throw_at(throwtarget, 2, 2, A)
				D.Knockdown(10)
			atk_verb = "shoves"
	if(atk_verb)
		log_combat(A, D, "[atk_verb] (Psychotic Brawling)")
	return TRUE

/datum/martial_art/psychotic_brawling/proc/psycho_grab(mob/living/carbon/human/A, mob/living/carbon/human/D)
	var/atk_verb
	if(D.stat)
		atk_verb = "grabbed"
		A.start_pulling(D)
		log_combat(A, D, "grabbed (Psychotic Brawling)")
		return TRUE
	switch(rand(1,6))
		if(1,2)
			A.stop_pulling()
			D.help_shake_act(A)
			atk_verb = "helped"
		if(3)
			atk_verb = "prepares to pounce at"
			A.Immobilize(20)
			A.changeNext_move(20)
			addtimer(CALLBACK(src, .proc/pounce, A, D), 20)
			D.visible_message("<span class='warning'>[A] crouches down, preparing to pounce at [D]!</span>", "<span class='userdanger'>[A] prepares to pounce at you!</span>")
		if(4)
			if(A.grab_state >= GRAB_AGGRESSIVE)
				D.grabbedby(A, 1)
			else
				A.start_pulling(D, supress_message = TRUE)
				if(A.pulling)
					D.drop_all_held_items()
					D.stop_pulling()
					log_combat(A, D, "grabbed", addition="aggressively")
					D.visible_message("<span class='warning'>[A] violently grabs [D]!</span>", \
									"<span class='userdanger'>You're violently grabbed by [A]!</span>", "<span class='hear'>You hear sounds of aggressive fondling!</span>", null, A)
					to_chat(A, "<span class='danger'>You violently grab [D]!</span>")
					A.setGrabState(GRAB_AGGRESSIVE) //Instant aggressive grab
		if(5,6)
			atk_verb = "grabbed"
			A.start_pulling(D)
	if(atk_verb)
		log_combat(A, D, "[atk_verb] (Psychotic Brawling)")
	return TRUE

/datum/martial_art/psychotic_brawling/proc/pounce(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(A.stat)
		return
	if(A.throw_at(D.loc, 7, 2, force = MOVE_FORCE_VERY_STRONG))
		if(!(D.mobility_flags & MOBILITY_STAND))
			A.throw_at(D.loc, 2, 4, spin = FALSE, force = MOVE_FORCE_VERY_WEAK)
			A.SetKnockdown(0)
			A.SetImmobilized(0)
			A.SetParalyzed(0)
			A.start_pulling(D, supress_message = TRUE)
			if(A.pulling)
				D.drop_all_held_items()
				D.stop_pulling()
				log_combat(A, D, "grabbed", addition="aggressively")
				D.visible_message("<span class='warning'>[A] pounces onto [D]!</span>", "<span class='userdanger'>[A] grabs hold of your neck!</span>")
				to_chat(A, "<span class='danger'>You grab [D] by the neck!</span>")
				A.setGrabState(GRAB_NECK)

/datum/martial_art/psychotic_brawling/proc/psycho_attack(mob/living/carbon/human/A, mob/living/carbon/human/D)
	var/atk_verb
	var/armor_block = D.run_armor_check(attack_flag = "melee")
	switch(rand(1,6))
		if(1)
			playsound(A, 'sound/weapons/bite.ogg', 50, 1, -1)
			A.do_attack_animation(D, ATTACK_EFFECT_BITE)
			D.apply_damage(D.dna.species.punchdamage-3, A.dna.species.attack_type, blocked = armor_block)
			for(var/datum/disease/V in A.diseases)
				if((V.spread_flags & DISEASE_SPREAD_SPECIAL) || (V.spread_flags & DISEASE_SPREAD_NON_CONTAGIOUS) || (V.spread_flags & DISEASE_SPREAD_FALTERED))
					continue
				V.try_infect(D)
			for(var/datum/disease/V in D.diseases)
				if((V.spread_flags & DISEASE_SPREAD_SPECIAL) || (V.spread_flags & DISEASE_SPREAD_NON_CONTAGIOUS) || (V.spread_flags & DISEASE_SPREAD_FALTERED))
					continue
				V.try_infect(A)
			if(prob(10))
				var/datum/disease/advance/R = new /datum/disease/advance/random(rand(1, 3), rand(4,9), 0)
				R.try_infect(D)
			atk_verb = "bit"		
		if(2)
			A.emote("cry")
			A.Stun(20)
			atk_verb = "cried looking at"
		if(3)
			A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
			atk_verb = "headbutts"
			D.visible_message("<span class='danger'>[A] [atk_verb] [D]!</span>", \
					  "<span class='userdanger'>[A] [atk_verb] you!</span>")
			playsound(get_turf(D), 'sound/weapons/punch1.ogg', 40, 1, -1)
			D.apply_damage(rand(5,10), A.dna.species.attack_type, BODY_ZONE_HEAD)
			A.apply_damage(rand(5,10), A.dna.species.attack_type, BODY_ZONE_HEAD)
			if(!istype(D.head,/obj/item/clothing/head/helmet/) && !istype(D.head,/obj/item/clothing/head/hardhat))
				D.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5)
			A.Stun(rand(10,45))
			D.Stun(rand(5,30))
		if(4)
			basic_hit(A,D)
		if(5)
			A.do_attack_animation(D, ATTACK_EFFECT_BOOP)
			atk_verb = "pokes"
			D.apply_damage(max(0, D.dna.species.punchdamage-5), A.dna.species.attack_type, BODY_ZONE_HEAD)
			A.changeNext_move(2)
			A.emote("laugh")
			D.visible_message("<span class='danger'>[A] [atk_verb] [D]!</span>", \
					  "<span class='userdanger'>[A] [atk_verb] you!</span>")
		if(6)
			A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
			atk_verb = pick("punches", "kicks", "hits", "slams into")
			D.visible_message("<span class='danger'>[A] [atk_verb] [D] with inhuman strength, sending [D.p_them()] flying backwards!</span>", \
							  "<span class='userdanger'>[A] [atk_verb] you with inhuman strength, sending you flying backwards!</span>")
			D.apply_damage(rand(D.dna.species.punchdamage+9,D.dna.species.punchdamage+24), A.dna.species.attack_type, blocked = armor_block)
			playsound(get_turf(D), 'sound/effects/meteorimpact.ogg', 25, 1, -1)
			var/throwtarget = get_edge_target_turf(A, get_dir(A, get_step_away(D, A)))
			D.throw_at(throwtarget, 4, 2, A)//So stuff gets tossed around at the same time.
			D.Knockdown(40)
			

	if(atk_verb)
		log_combat(A, D, "[atk_verb] (Psychotic Brawling)")
	return 1