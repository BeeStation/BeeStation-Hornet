/datum/symptom/heal
	name = "Basic Healing (does nothing)" //warning for adminspawn viruses
	desc = "You should not be seeing this."
	stealth = 0
	resistance = 0
	stage_speed = 0
	transmittable = 0
	level = -1 //not obtainable
	base_message_chance = 20 //here used for the overlays
	symptom_delay_min = 1
	symptom_delay_max = 1
	var/passive_message = "" //random message to infected but not actively healing people
	threshold_desc = "<b>Stage Speed 6:</b> Doubles healing speed.<br>\
					  <b>Stealth 4:</b> Healing will no longer be visible to onlookers."

/datum/symptom/heal/Start(datum/disease/advance/A)
	if(!..())
		return FALSE
	if(A.properties["stage_rate"] >= 6) //stronger healing
		power = 2
	return TRUE //For super calls of subclasses

/datum/symptom/heal/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(4, 5)
			var/effectiveness = CanHeal(A)
			if(!effectiveness)
				if(passive_message && prob(2) && passive_message_condition(M))
					to_chat(M, passive_message)
				return
			else
				Heal(M, A, effectiveness)
	return

/datum/symptom/heal/proc/CanHeal(datum/disease/advance/A)
	return power

/datum/symptom/heal/proc/Heal(mob/living/M, datum/disease/advance/A, actual_power)
	return TRUE

/datum/symptom/heal/proc/passive_message_condition(mob/living/M)
	return TRUE

/datum/symptom/heal/chem
	name = "Toxolysis"
	stealth = 0
	resistance = -2
	stage_speed = 2
	transmittable = -2
	level = 7
	power = 2
	var/food_conversion = FALSE
	desc = "The virus rapidly breaks down any foreign chemicals in the bloodstream."
	threshold_desc = "<b>Resistance 7:</b> Increases chem removal speed.<br>\
					  <b>Stage Speed 6:</b> Consumed chemicals nourish the host."

/datum/symptom/heal/chem/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["stage_rate"] >= 6)
		food_conversion = TRUE
	if(A.properties["resistance"] >= 7)
		power = 4

/datum/symptom/heal/chem/Heal(mob/living/M, datum/disease/advance/A, actual_power)
	for(var/datum/reagent/R in M.reagents.reagent_list) //Not just toxins!
		M.reagents.remove_reagent(R.type, actual_power)
		if(food_conversion)
			M.adjust_nutrition(0.3)
		if(prob(2))
			to_chat(M, "<span class='notice'>You feel a mild warmth as your blood purifies itself.</span>")
	return 1

/datum/symptom/heal/coma
	name = "Regenerative Coma"
	desc = "The virus causes the host to fall into a death-like coma when severely damaged, then rapidly fixes the damage. Only fixes burn and brute damage."
	stealth = 0
	resistance = 2
	stage_speed = -3
	transmittable = -3
	level = 8
	severity = -2
	passive_message = "<span class='notice'>The pain from your wounds makes you feel oddly sleepy.</span>"
	var/deathgasp = FALSE
	var/stabilize = FALSE
	var/active_coma = FALSE //to prevent multiple coma procs
	threshold_desc = "<b>Stealth 2:</b> Host appears to die when falling into a coma, triggering symptoms that activate on death.<br>\

					  <b>Resistance 4:</b> The virus also stabilizes the host while they are in critical condition.<br>\
					  <b>Stage Speed 7:</b> Increases healing speed."

/datum/symptom/heal/coma/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["stage_rate"] >= 7)
		power = 1.5
	if(A.properties["resistance"] >= 4)
		stabilize = TRUE
	if(A.properties["stealth"] >= 2)
		deathgasp = TRUE

/datum/symptom/heal/coma/on_stage_change(new_stage, datum/disease/advance/A)  //mostly copy+pasted from the code for self-respiration's TRAIT_NOBREATH stuff
	if(!..())
		return FALSE
	if(A.stage <= 3)
		REMOVE_TRAIT(A.affected_mob, TRAIT_NOCRITDAMAGE, DISEASE_TRAIT)
	return TRUE

/datum/symptom/heal/coma/End(datum/disease/advance/A)
	if(!..())
		return
	REMOVE_TRAIT(A.affected_mob, TRAIT_NOCRITDAMAGE, DISEASE_TRAIT)

/datum/symptom/heal/coma/CanHeal(datum/disease/advance/A)
	var/mob/living/M = A.affected_mob
	if(stabilize)
		ADD_TRAIT(M, TRAIT_NOCRITDAMAGE, DISEASE_TRAIT)
	if(HAS_TRAIT(M, TRAIT_DEATHCOMA))
		return power
	else if(M.IsUnconscious() || M.stat == UNCONSCIOUS)
		return power * 0.9
	else if(M.stat == SOFT_CRIT)
		return power * 0.5
	else if(M.IsSleeping())
		return power * 0.25
	else if(M.getBruteLoss() + M.getFireLoss() >= 70 && !active_coma)
		to_chat(M, "<span class='warning'>You feel yourself slip into a deep, regenerative slumber.</span>")
		active_coma = TRUE
		addtimer(CALLBACK(src, .proc/coma, M), 60)

/datum/symptom/heal/coma/proc/coma(mob/living/M)
	if(deathgasp)
		M.emote("deathgasp")
	M.fakedeath("regenerative_coma")
	M.update_stat()
	M.update_mobility()
	addtimer(CALLBACK(src, .proc/uncoma, M), 300)

/datum/symptom/heal/coma/proc/uncoma(mob/living/M)
	if(!active_coma)
		return
	active_coma = FALSE
	M.cure_fakedeath("regenerative_coma")
	M.update_stat()
	M.update_mobility()

/datum/symptom/heal/coma/Heal(mob/living/carbon/M, datum/disease/advance/A, actual_power)
	var/heal_amt = 4 * actual_power

	var/list/parts = M.get_damaged_bodyparts(1,1)

	if(!parts.len)
		return

	for(var/obj/item/bodypart/L in parts)
		if(L.heal_damage(heal_amt/parts.len, heal_amt/parts.len, null, BODYPART_ORGANIC))
			M.update_damage_overlays()

	if(active_coma && M.getBruteLoss() + M.getFireLoss() == 0)
		uncoma(M)

	return 1

/datum/symptom/heal/coma/passive_message_condition(mob/living/M)
	if((M.getBruteLoss() + M.getFireLoss()) > 30)
		return TRUE
	return FALSE

/datum/symptom/heal/surface
	name = "Superficial Healing"
	desc = "The virus accelerates the body's natural healing, causing the body to heal minor wounds quickly. Causes heavy scarring."
	stealth = -1
	resistance = -2
	stage_speed = -2
	transmittable = 0
	severity = -1
	level = 6
	passive_message = "<span class='notice'>Your skin tingles.</span>"
	var/threshhold = 15
	var/scarcounter = 0

	threshold_desc = "<b>Stage Speed 8:</b> Doubles healing speed.<br>\
					  <b>Resistance 10:</b> Improves healing threshhold."

/datum/symptom/heal/surface/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["stage_rate"] >= 8) //stronger healing
		power = 2
	if(A.properties["resistance"] >= 10)
		threshhold = 30

/datum/symptom/heal/surface/Heal(mob/living/carbon/M, datum/disease/advance/A, actual_power)
	var/healed = FALSE

	if(M.getBruteLoss() && M.getBruteLoss() <= threshhold)
		M.heal_overall_damage(power, required_status = BODYPART_ORGANIC)
		healed = TRUE
		scarcounter++

	if(M.getFireLoss() && M.getFireLoss() <= threshhold)
		M.heal_overall_damage(burn = power, required_status = BODYPART_ORGANIC)
		healed = TRUE
		scarcounter++

	if(M.getToxLoss() && M.getToxLoss() <= threshhold)
		M.adjustToxLoss(-power)

	if(healed)
		if(prob(10))
			to_chat(M, "<span class='notice'>Your wounds heal, granting you a new scar.</span>")
		if(scarcounter >= 200 && !HAS_TRAIT(M, TRAIT_DISFIGURED))
			ADD_TRAIT(M, TRAIT_DISFIGURED, DISEASE_TRAIT)
			M.visible_message("<span class='warning'>[M]'s face becomes unrecognizeable.</span>", "<span class='userdanger'>Your scars have made your face unrecognizeable.</span>")
	return healed


/datum/symptom/heal/surface/passive_message_condition(mob/living/M)
	return M.getBruteLoss() <= threshhold || M.getFireLoss() <= threshhold

/datum/symptom/heal/metabolism
	name = "Metabolic Boost"
	stealth = -1
	resistance = -2
	stage_speed = 2
	transmittable = 1
	level = 4
	var/triple_metabolism = FALSE
	var/reduced_hunger = FALSE
	desc = "The virus causes the host's metabolism to accelerate rapidly, making them process chemicals twice as fast,\
	 but also causing increased hunger."
	threshold_desc = "<b>Stealth 3:</b> Reduces hunger rate.<br>\
					  <b>Stage Speed 10:</b> Chemical metabolization is tripled instead of doubled."

/datum/symptom/heal/metabolism/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["stage_rate"] >= 10)
		triple_metabolism = TRUE
	if(A.properties["stealth"] >= 3)
		reduced_hunger = TRUE

/datum/symptom/heal/metabolism/Heal(mob/living/carbon/C, datum/disease/advance/A, actual_power)
	if(!istype(C))
		return
	C.reagents.metabolize(C, can_overdose=TRUE) //this works even without a liver; it's intentional since the virus is metabolizing by itself
	if(triple_metabolism)
		C.reagents.metabolize(C, can_overdose=TRUE)
	C.overeatduration = max(C.overeatduration - 2, 0)
	var/lost_nutrition = 9 - (reduced_hunger * 5)
	C.adjust_nutrition(-lost_nutrition * HUNGER_FACTOR) //Hunger depletes at 10x the normal speed
	if(prob(2))
		to_chat(C, "<span class='notice'>You feel an odd gurgle in your stomach, as if it was working much faster than normal.</span>")
	return 1

/*
//////////////////////////////////////
im not even gonna bother with these for the following symptoms. typed em out, code was deleted, had to start over, read the symptoms yourself.

//////////////////////////////////////
*/

/datum/symptom/EMP
	name = "Organic Flux Induction"
	desc = "Causes electromagnetic interference around the subject"
	stealth = 0
	resistance = -1
	stage_speed = -1
	transmittable = -2
	level = 6
	severity = 2
	symptom_delay_min = 15
	symptom_delay_max = 40
	var/bigemp = FALSE
	var/cellheal = FALSE
	threshold_desc = "<b>Stealth 2:</b> The disease resets cell DNA, quickly curing cell damage and mutations.<br>\
					<b>Transmission 8:</b> The EMP affects electronics adjacent to the subject as well."

/datum/symptom/EMP/severityset(datum/disease/advance/A)
	. = ..()
	if(A.properties["stealth"] >= 2) //if you combine this with pituitary disruption, you have the two most downside-heavy symptoms available
		severity -= 1
	if(A.properties["transmittable"] >= 8)
		severity += 1

/datum/symptom/EMP/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["stealth"] >= 2)
		cellheal = TRUE
	if(A.properties["transmittable"] >= 8)
		bigemp = TRUE

/datum/symptom/EMP/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	switch(A.stage)
		if(4, 5)
			M.emp_act(EMP_HEAVY)
			if(cellheal)
				M.adjustCloneLoss(-30)
				M.reagents.add_reagent(/datum/reagent/medicine/mutadone = 1)
			if(bigemp)
				empulse(M.loc, 0, 1)
			to_chat(M, "<span class='userdanger'>[pick("Your mind fills with static!", "You feel a jolt!", "Your sense of direction flickers out!")]</span>")
		else
			to_chat(M, "<span class='notice'>[pick("You feel a slight tug toward the station's wall.", "Nearby electronics flicker.", "Your hair stands on end.")]</span>")
	return

/datum/symptom/sweat
	name = "Hyperperspiration"
	desc = "Causes the host to sweat profusely, leaving small water puddles and extnguishing small fires"
	stealth = 1
	resistance = -1
	stage_speed = 0
	transmittable = 1
	level = 6
	severity = 1
	symptom_delay_min = 10
	symptom_delay_max = 30
	var/bigsweat = FALSE
	var/toxheal = FALSE
	var/ammonia = FALSE
	threshold_desc = "<b>Transmission 4:</b> The sweat production ramps up to the point that it puts out fires in the general vicinity.<br>\
					<b>Transmission 6:</b> The symptom heals toxin damage and purges chemicals.<br>\
					<b>Stage speed 6:</b> The host's sweat contains traces of ammonia."

/datum/symptom/sweat/severityset(datum/disease/advance/A)
	. = ..()
	if(A.properties["transmittable"] >= 6)
		severity -= 1

/datum/symptom/sweat/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["transmittable"] >= 6)
		toxheal = TRUE
	if(A.properties["transmittable"] >= 4)
		bigsweat = TRUE
	if(A.properties["stage_rate"] >= 6)
		ammonia = TRUE

/datum/symptom/sweat/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	switch(A.stage)
		if(4, 5)
			M.adjust_fire_stacks(-5)
			if(prob(30))
				var/turf/open/OT = get_turf(M)
				if(istype(OT))
					to_chat(M, "<span class='danger'>The sweat pools into a puddle!</span>")
					OT.MakeSlippery(TURF_WET_WATER, min_wet_time = 10 SECONDS, wet_time_to_add = 5 SECONDS)
			if(bigsweat)
				var/obj/effect/sweatsplash/S = new(M.loc)
				if(toxheal)
					for(var/datum/reagent/R in M.reagents.reagent_list) //Not just toxins!
						M.reagents.remove_reagent(R.type, 5)
						S.reagents.add_reagent(R.type, 5)
					M.adjustToxLoss(-20, forced = TRUE)
				if(ammonia)
					S.reagents.add_reagent(/datum/reagent/space_cleaner, 5)
				S.splash()
				to_chat(M, "<span class='userdanger'>You sweat out nearly everything in your body!</span>")
		else
			to_chat(M, "<span class='notice'>[pick("You feel moist.", "Your clothes are soaked.", "You're sweating buckets!")]</span>")
	return

/obj/effect/sweatsplash
	name = "Sweatsplash"

/obj/effect/sweatsplash/Initialize()
	create_reagents(1000)
	reagents.add_reagent(/datum/reagent/water, 10)

obj/effect/sweatsplash/proc/splash()
	chem_splash(loc, 2, list(reagents))
	qdel(src)

/datum/symptom/teleport
	name = "Thermal Retrostable Displacement"
	desc = "When too hot or cold, the subject will return to a recent location at which they experienced safe homeostasis."
	stealth = 1
	resistance = 2
	stage_speed = -2
	transmittable = -3
	level = 8
	severity = 0
	symptom_delay_min = 1
	symptom_delay_max = 1
	var/telethreshold = 15
	var/burnheal = FALSE
	var/turf/open/location_return = null
	var/cooldowntimer = 0
	threshold_desc = "<b>Resistance 6:</b> The disease acts on a smaller scale, resetting burnt tissue back to a state of health.<br>\
					<b>Transmission 8:</b> The disease becomes more active, activating in a smaller temperature range."

/datum/symptom/teleport/severityset(datum/disease/advance/A)
	. = ..()
	if(A.properties["resistance"] >= 6)
		severity -= 1
		if(A.properties["transmittable"] >= 8)
			severity -= 1

/datum/symptom/teleport/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["resistance"] >= 6)
		burnheal = TRUE
	if(A.properties["transmittable"] >= 8)
		telethreshold = -10
		power = 2

/datum/symptom/teleport/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	switch(A.stage)
		if(4, 5)
			if(burnheal)
				M.heal_overall_damage(0, 1) //no required_status checks here, this does all bodyparts equally
			if(prob(5) && (M.bodytemperature < BODYTEMP_HEAT_DAMAGE_LIMIT || M.bodytemperature > BODYTEMP_COLD_DAMAGE_LIMIT))
				location_return = get_turf(M)	//sets up return point
				if(prob(50))
					to_chat(M, "<span class='userwarning'>The lukewarm temperature makes you feel strange!</span>")
			if(cooldowntimer == 0 && ((M.bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT + telethreshold  && !HAS_TRAIT(M, TRAIT_RESISTHEAT)) || (M.bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT - telethreshold  && !HAS_TRAIT(M, TRAIT_RESISTCOLD)) || (burnheal && M.getFireLoss() > 60 + telethreshold)))
				do_sparks(5,FALSE,M)
				to_chat(M, "<span class='userdanger'>The change in temperature shocks you back to a previous spacial state!</span>")
				do_teleport(M, location_return, 0, asoundin = 'sound/effects/phasein.ogg') //Teleports home
				do_sparks(5,FALSE,M)
				cooldowntimer = 10
				if(burnheal)
					M.adjust_fire_stacks(-10)
			if(cooldowntimer > 0)
				cooldowntimer --
		else
			if(prob(7))
				to_chat(M, "<span class='notice'>[pick("Your warm breath fizzles out of existence.", "You feel attracted to temperate climates", "You feel like you're forgetting something")]</span>")
	return

/datum/symptom/growth
	name = "Pituitary Disruption"
	desc = "Causes uncontrolled growth in the subject."
	stealth = -3
	resistance = -2
	stage_speed = 1
	transmittable = -2
	level = 7
	severity = 1
	symptom_delay_min = 1
	symptom_delay_max = 1
	var/current_size = 1
	var/tetsuo = FALSE
	var/bruteheal = FALSE
	var/sizemult = 1
	var/datum/mind/ownermind
	threshold_desc = "<b>Stage Speed 6:</b> The disease heals brute damage at a fast rate, but causes expulsion of benign tumors.<br>\
					<b>Stage Speed 12:</b> The disease heals brute damage incredibly fast, but deteriorates cell health and causes tumors to become more advanced. The disease will also regenerate lost limbs and cause organ mutation."

/datum/symptom/growth/severityset(datum/disease/advance/A)
	. = ..()
	if(A.properties["stage_rate"] >= 6)
		severity -= 1
	if(A.properties["stage_rate"] >= 12)
		severity += 3

/datum/symptom/growth/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["stage_rate"] >= 6)
		bruteheal = TRUE
	if(A.properties["stage_rate"] >= 12)
		tetsuo = TRUE
		power = 3 //should make this symptom actually worth it
	var/mob/living/carbon/M = A.affected_mob
	ownermind = M.mind
	sizemult = CLAMP((0.5 + A.properties["stage_rate"] / 10), 1.1, 2.5)
	M.resize = sizemult
	M.update_transform()

/datum/symptom/growth/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	switch(A.stage)
		if(4, 5)
			if(prob(5) && bruteheal)
				to_chat(M, "<span class='userdanger'>You retch, and a splatter of gore escapes your gullet!</span>")
				M.Knockdown(10)
				new /obj/effect/decal/cleanable/blood/(M.loc)
				playsound(get_turf(M), 'sound/effects/splat.ogg', 50, 1)
				if(prob(60))
					new /obj/effect/spawner/lootdrop/teratoma/minor(M.loc)
				if(tetsuo)
					var/list/organcantidates = list()
					var/list/missing = M.get_missing_limbs()
					if(prob(35))
						new /obj/effect/gibspawner/human/bodypartless(M.loc) //yes. this is very messy. very, very messy.
						new /obj/effect/spawner/lootdrop/teratoma/major(M.loc)
						for(var/obj/item/organ/O in M.loc)
							if(O.organ_flags & ORGAN_FAILING || O.organ_flags & ORGAN_VITAL) //dont use shitty organs or brains
								continue
							if(O.organ_flags & (ORGAN_SYNTHETIC)) //if we can infect robots, we can implant cyber organs
								if(MOB_ROBOTIC in A.infectable_biotypes) //why do i have to do this this way? no idea, but it wont fucking work otherwise
									organcantidates += O
								continue
							organcantidates += O
						if(organcantidates.len)
							for(var/I in 1 to min(rand(1, 3), organcantidates.len))
								var/obj/item/organ/chosen = pick_n_take(organcantidates)
								chosen.Insert(M, TRUE, FALSE)
								to_chat(M, "<span class='userdanger'>As the [chosen] touches your skin, it is promptly absorbed.</span>")
					if(missing.len) //we regrow one missing limb
						for(var/Z in missing) //uses the same text and sound a ling's regen does. This can false-flag the host as a changeling.
							if(M.regenerate_limb(Z, TRUE))
								playsound(M, 'sound/magic/demon_consume.ogg', 50, 1)
								M.visible_message("<span class='warning'>[M]'s missing limbs \
									reform, making a loud, grotesque sound!</span>",
									"<span class='userdanger'>Your limbs regrow, making a \
									loud, crunchy sound and giving you great pain!</span>",
									"<span class='italics'>You hear organic matter ripping \
									and tearing!</span>")
								M.emote("scream")
								if(Z == BODY_ZONE_HEAD) //if we regenerate the head, make sure the mob still owns us
									if(isliving(ownermind.current))
										var/mob/living/owner = ownermind.current
										if(owner.stat != DEAD)//if they have a new mob, forget they exist
											ownermind = null
											break
										if(owner == M) //they're already in control of this body, probably because their brain isn't in the head!
											break
									if(ishuman(M))
										var/mob/living/carbon/human/H = M
										H.dna.species.regenerate_organs(H, replace_current = FALSE) //get head organs, including the brain, back
									ownermind.transfer_to(M)
									M.grab_ghost()
								break
				if(tetsuo && prob(10) && A.affected_mob.job == "Clown")
					new /obj/effect/spawner/lootdrop/teratoma/major/clown(M.loc)
			if(bruteheal)
				M.heal_overall_damage(2 * power, required_status = BODYPART_ORGANIC)
				if(prob(11 * power))
					M.adjustCloneLoss(1)
		else
			if(prob(5))
				to_chat(M, "<span class='notice'>[pick("You feel bloated.", "The station seems small.", "You are the strongest.")]</span>")
	return

/datum/symptom/growth/End(datum/disease/advance/A)
	. = ..()
	var/mob/living/carbon/M = A.affected_mob
	to_chat(M, "<span class='notice'>You lose your balance and stumble as you shrink, and your legs come out from underneath you!</span>")
	animate(M, pixel_z = 4, time = 0) //size is fixed by having the player do one waddle. Animation for some reason resets size, meaning waddling can desize you
	animate(pixel_z = 0, transform = turn(matrix(), pick(-12, 0, 12)), time=2) //waddle desizing is an issue, because you can game it to use this symptom and become small
	animate(pixel_z = 0, transform = matrix(), time = 0) //so, instead, we use waddle desizing to desize you from this symptom, instead of a transformation, because it wont shrink you naturally

//they are used for the maintenance spawn, for ling teratoma see changeling\teratoma.dm
/obj/effect/mob_spawn/teratomamonkey //spawning these is one of the downsides of overclocking the symptom
	name = "fleshy mass"
	desc = "A writhing mass of flesh."
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_spore_temp"
	density = FALSE
	anchored = FALSE

	antagonist_type = /datum/antagonist/teratoma/hugbox
	mob_type = /mob/living/carbon/monkey/tumor
	mob_name = "a living tumor"
	death = FALSE
	roundstart = FALSE
	use_cooldown = TRUE
	show_flavour = FALSE	//it's handled by antag datum


/obj/effect/mob_spawn/teratomamonkey/Initialize()
	. = ..()
	var/area/A = get_area(src)
	if(A)
		notify_ghosts("A living tumor has been born in [A.name].", 'sound/effects/splat.ogg', source = src, action = NOTIFY_ATTACK, flashwindow = FALSE)

/obj/effect/mob_spawn/teratomamonkey/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	to_chat(user, "<span class='notice'>Ew. It would be a bad idea to touch this. It could probably be destroyed with the extreme heat of a welder.</span>")

/obj/effect/mob_spawn/teratomamonkey/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_WELDER && user.a_intent != INTENT_HARM)
		user.visible_message("<span class='warning'>[usr.name] destroys [src].</span>",
			"<span class='notice'>You hold the welder to [src] and it violently bursts!</span>",
			"<span class='italics'>You hear a gurgling noise.</span>")
		new /obj/effect/gibspawner/human(get_turf(src))
		qdel(src)
	else
		..()

/obj/effect/mob_spawn/teratomamonkey/create(ckey, name)
	..()
	var/datum/antagonist/teratoma/hugbox/D = new
	usr.mind.add_antag_datum(D)
