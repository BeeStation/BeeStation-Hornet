#define TELEPORT_COOLDOWN 60 SECONDS

/datum/symptom/heal
	name = "Basic Healing (does nothing)" //warning for adminspawn viruses
	desc = "You should not be seeing this."
	stealth = 0
	resistance = 0
	stage_speed = 0
	transmission = 0
	level = -1 //not obtainable
	base_message_chance = 20 //here used for the overlays
	symptom_delay_min = 1
	symptom_delay_max = 1
	var/passive_message = "" //random message to infected but not actively healing people
	threshold_desc = "<b>Stealth 4:</b> Healing will no longer be visible to onlookers."

/datum/symptom/heal/Start(datum/disease/advance/A)
	if(!..())
		return FALSE
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
	transmission = -2
	level = 6
	power = 2
	prefixes = list("Toxo")
	var/food_conversion = FALSE
	desc = "The virus rapidly breaks down any foreign chemicals in the bloodstream."
	threshold_desc = "<b>Resistance 7:</b> Increases chem removal speed.<br>\
						<b>Stage Speed 6:</b> Consumed chemicals nourish the host."

/datum/symptom/heal/chem/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage_rate >= 6)
		food_conversion = TRUE
	if(A.resistance >= 7)
		power = 4

/datum/symptom/heal/chem/Heal(mob/living/M, datum/disease/advance/A, actual_power)
	for(var/datum/reagent/R in M.reagents.reagent_list) //Not just toxins!
		M.reagents.remove_reagent(R.type, actual_power)
		if(food_conversion)
			M.adjust_nutrition(0.3)
		if(prob(2) && M.stat != DEAD)
			to_chat(M, span_notice("You feel a mild warmth as your blood purifies itself."))
	return 1

/datum/symptom/heal/coma
	name = "Regenerative Coma"
	desc = "The virus causes the host to fall into a death-like coma when severely damaged, then rapidly fixes the damage. Only fixes burn and brute damage."
	stealth = 0
	resistance = 2
	stage_speed = -3
	transmission = -3
	level = 8
	severity = -2
	passive_message = span_notice("The pain from your wounds makes you feel oddly sleepy.")
	prefixes = list("Sleeping ", "Regenerative ")
	suffixes = list(" Coma")
	var/deathgasp = FALSE
	var/stabilize = FALSE
	var/active_coma = FALSE //to prevent multiple coma procs
	threshold_desc = "<b>Stealth 2:</b> Host appears to die when falling into a coma, triggering symptoms that activate on death.<br>\
						<b>Resistance 4:</b> The virus also stabilizes the host while they are in critical condition.<br>\
						<b>Stage Speed 7:</b> Increases healing speed."

/datum/symptom/heal/coma/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage_rate >= 7)
		power = 1.5
	if(A.resistance >= 4)
		stabilize = TRUE
	if(A.stealth >= 2)
		deathgasp = TRUE

/datum/symptom/heal/coma/on_stage_change(datum/disease/advance/A)  //mostly copy+pasted from the code for self-respiration's TRAIT_NOBREATH stuff
	if(!..())
		return FALSE
	if(A.stage >= 4 && stabilize)
		ADD_TRAIT(A.affected_mob, TRAIT_NOCRITDAMAGE, DISEASE_TRAIT)
	else
		REMOVE_TRAIT(A.affected_mob, TRAIT_NOCRITDAMAGE, DISEASE_TRAIT)
	return TRUE

/datum/symptom/heal/coma/End(datum/disease/advance/A)
	if(!..())
		return
	REMOVE_TRAIT(A.affected_mob, TRAIT_NOCRITDAMAGE, DISEASE_TRAIT)

/datum/symptom/heal/coma/CanHeal(datum/disease/advance/A)
	var/mob/living/M = A.affected_mob
	if(HAS_TRAIT(M, TRAIT_DEATHCOMA))
		return power
	if(M.IsSleeping())
		return power * 0.25 //Voluntary unconsciousness yields lower healing.
	switch(M.stat)
		if(UNCONSCIOUS, HARD_CRIT)
			return power * 0.9
		if(SOFT_CRIT)
			return power * 0.5
	if(M.getBruteLoss() + M.getFireLoss() >= 70 && !active_coma)
		if(M.stat != DEAD)
			to_chat(M, span_warning("You feel yourself slip into a deep, regenerative slumber."))
		active_coma = TRUE
		addtimer(CALLBACK(src, PROC_REF(coma), M), 60)


/datum/symptom/heal/coma/proc/coma(mob/living/M)
	if(deathgasp)
		M.fakedeath(TRAIT_REGEN_COMA)
	else
		M.Unconscious(300, TRUE, TRUE)
	addtimer(CALLBACK(src, PROC_REF(uncoma), M), 300)

/datum/symptom/heal/coma/proc/uncoma(mob/living/M)
	if(!active_coma)
		return
	active_coma = FALSE
	if(deathgasp)
		M.cure_fakedeath(TRAIT_REGEN_COMA)
	else
		M.SetUnconscious(0)

/datum/symptom/heal/coma/Heal(mob/living/carbon/M, datum/disease/advance/A, actual_power)
	var/heal_amt = 4 * actual_power

	var/list/parts = M.get_damaged_bodyparts(1,1)

	if(!parts.len)
		return

	for(var/obj/item/bodypart/L in parts)
		if(L.heal_damage(heal_amt/parts.len, heal_amt/parts.len, null, BODYTYPE_ORGANIC))
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
	transmission = 0
	severity = -1
	level = 8
	passive_message = span_notice("Your skin tingles.")
	prefixes = list("Healing ", "Minor ")
	var/threshold = 15
	var/scarcounter = 0

	threshold_desc = "<b>Stage Speed 8:</b> Doubles healing speed.<br>\
						<b>Resistance 10:</b> Improves healing threshold."

/datum/symptom/heal/surface/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage_rate >= 8) //stronger healing
		power = 2
	if(A.resistance >= 10)
		threshold = 30

/datum/symptom/heal/surface/Heal(mob/living/carbon/M, datum/disease/advance/A, actual_power)
	var/healed = FALSE

	if(M.getBruteLoss() && M.getBruteLoss() <= threshold)
		M.heal_overall_damage(power, required_status = BODYTYPE_ORGANIC)
		healed = TRUE
		scarcounter++

	if(M.getFireLoss() && M.getFireLoss() <= threshold)
		M.heal_overall_damage(burn = power, required_status = BODYTYPE_ORGANIC)
		healed = TRUE
		scarcounter++

	if(M.getToxLoss() && M.getToxLoss() <= threshold)
		M.adjustToxLoss(-power, FALSE, TRUE)

	if(healed)
		if(prob(10) && M.stat != DEAD)
			to_chat(M, span_notice("Your wounds heal, granting you a new scar."))
		if(scarcounter >= 200 && !HAS_TRAIT(M, TRAIT_DISFIGURED))
			ADD_TRAIT(M, TRAIT_DISFIGURED, DISEASE_TRAIT)
			M.visible_message(span_warning("[M]'s face becomes unrecognizeable."), span_userdanger("Your scars have made your face unrecognizeable."))
	return healed


/datum/symptom/heal/surface/passive_message_condition(mob/living/M)
	return M.getBruteLoss() <= threshold || M.getFireLoss() <= threshold

/datum/symptom/heal/metabolism
	name = "Metabolic Boost"
	stealth = -1
	resistance = -2
	stage_speed = 2
	transmission = 1
	level = 6
	prefixes = list("Metabolic ", "Junkie's ", "Chemical ")
	bodies = list("Hunger")
	var/triple_metabolism = FALSE
	var/reduced_hunger = FALSE
	desc = "The virus causes the host's metabolism to accelerate rapidly, making them process chemicals twice as fast,\
		but also causing increased hunger."
	threshold_desc = "<b>Stealth 3:</b> Reduces hunger rate.<br>\
						<b>Stage Speed 10:</b> Chemical metabolization is tripled instead of doubled."

/datum/symptom/heal/metabolism/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage_rate >= 10)
		triple_metabolism = TRUE
	if(A.stealth >= 3)
		reduced_hunger = TRUE

/datum/symptom/heal/metabolism/Heal(mob/living/carbon/C, datum/disease/advance/A, actual_power)
	if(!istype(C))
		return
	var/metabolic_boost = triple_metabolism ? 2 : 1
	C.reagents.metabolize(C, metabolic_boost * SSMOBS_DT, 0, can_overdose=TRUE) //this works even without a liver; it's intentional since the virus is metabolizing by itself
	C.overeatduration = max(C.overeatduration - 4 SECONDS, 0)
	var/lost_nutrition = 9 - (reduced_hunger * 5)
	C.adjust_nutrition(-lost_nutrition * HUNGER_FACTOR) //Hunger depletes at 10x the normal speed
	if(prob(2) && C.stat != DEAD)
		to_chat(C, span_notice("You feel an odd gurgle in your stomach, as if it was working much faster than normal."))
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
	transmission = -2
	level = 6
	severity = 2
	symptom_delay_min = 15
	symptom_delay_max = 40
	prefixes = list("Magnetic ", "Electro")
	bodies = list("Magnet")
	var/bigemp = FALSE
	var/cellheal = FALSE
	threshold_desc = "<b>Stealth 2:</b> The disease resets cell DNA, quickly curing cell damage and mutations.<br>\
					<b>Transmission 8:</b> The EMP affects electronics adjacent to the subject as well."

/datum/symptom/EMP/severityset(datum/disease/advance/A)
	. = ..()
	if(A.stealth >= 2) //if you combine this with pituitary disruption, you have the two most downside-heavy symptoms available
		severity -= 1
	if(A.transmission >= 8 || A.event)
		severity += 1

/datum/symptom/EMP/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stealth >= 2)
		cellheal = TRUE
	if(A.transmission >= 8 || A.event)
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
			if(M.stat != DEAD)
				to_chat(M, span_userdanger("[pick("Your mind fills with static!", "You feel a jolt!", "Your sense of direction flickers out!")]"))
		else
			if(M.stat != DEAD)
				to_chat(M, span_notice("[pick("You feel a slight tug toward the station's wall.", "Nearby electronics flicker.", "Your hair stands on end.")]"))
	return

/datum/symptom/sweat
	name = "Hyperperspiration"
	desc = "Causes the host to sweat profusely, leaving small water puddles and extinguishing small fires"
	stealth = 1
	resistance = -1
	stage_speed = 0
	transmission = 1
	level = 6
	severity = 1
	symptom_delay_min = 10
	symptom_delay_max = 30
	prefixes = list("Sweaty ", "Moist ", "Mister ")
	bodies = list("Perspiration")
	var/bigsweat = FALSE
	var/toxheal = FALSE
	var/ammonia = FALSE
	threshold_desc = "<b>Transmission 4:</b> The sweat production ramps up to the point that it puts out fires in the general vicinity.<br>\
					<b>Transmission 6:</b> The symptom heals toxin damage and purges chemicals.<br>\
					<b>Stage speed 6:</b> The host's sweat contains traces of ammonia."

/datum/symptom/sweat/severityset(datum/disease/advance/A)
	. = ..()
	if(A.transmission >= 6 || (CONFIG_GET(flag/unconditional_symptom_thresholds) || A.event))
		severity -= 1
	if(CONFIG_GET(flag/unconditional_symptom_thresholds))
		threshold_desc = "<b>Transmission 4:</b> The sweat production ramps up to the point that it puts out fires in the general vicinity.<br>\
					<b>Always:</b> The symptom heals toxin damage and purges chemicals.<br>\
					<b>Stage speed 6:</b> The host's sweat contains traces of ammonia."

/datum/symptom/sweat/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.transmission >= 6 || (CONFIG_GET(flag/unconditional_symptom_thresholds) || A.event))
		toxheal = TRUE
	if(A.transmission >= 4)
		bigsweat = TRUE
	if(A.stage_rate >= 6)
		ammonia = TRUE

/datum/symptom/sweat/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	switch(A.stage)
		if(4, 5)
			M.adjust_wet_stacks(5)
			if(!ammonia && prob(30))
				var/turf/open/OT = get_turf(M)
				if(istype(OT))
					if(M.stat != DEAD)
						to_chat(M, span_danger("The sweat pools into a puddle!"))
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
				if(M.stat != DEAD)
					to_chat(M, span_userdanger("You sweat out nearly everything in your body!"))
		else
			if(M.stat != DEAD)
				to_chat(M, span_notice("[pick("You feel moist.", "Your clothes are soaked.", "You're sweating buckets!")]"))
	return

/obj/effect/sweatsplash
	name = "Sweatsplash"

/obj/effect/sweatsplash/Initialize(mapload)
	. = ..()
	create_reagents(1000)
	reagents.add_reagent(/datum/reagent/water, 10)

/obj/effect/sweatsplash/proc/splash()
	chem_splash(loc, 2, list(reagents))
	qdel(src)

/datum/symptom/teleport
	name = "Thermal Retrostable Displacement"
	desc = "When too hot or cold, the subject will return to a recent location at which they experienced safe homeostasis."
	stealth = 1
	resistance = 2
	stage_speed = -2
	transmission = -3
	level = 8
	severity = 0
	symptom_delay_min = 1
	symptom_delay_max = 1
	prefixes = list("Quantum ", "Thermal ")
	bodies = list("Teleport")
	var/telethreshold = 15
	var/burnheal = FALSE
	var/turf/open/location_return = null
	COOLDOWN_DECLARE(teleport_cooldown)
	threshold_desc = "<b>Resistance 6:</b> The disease acts on a smaller scale, resetting burnt tissue back to a state of health.<br>\
					<b>Transmission 8:</b> The disease becomes more active, activating in a smaller temperature range."

/datum/symptom/teleport/severityset(datum/disease/advance/A)
	. = ..()
	if(A.resistance >= 6 || (CONFIG_GET(flag/unconditional_symptom_thresholds) || A.event))
		severity -= 1
		if(A.transmission >= 8)
			severity -= 1
	if(CONFIG_GET(flag/unconditional_symptom_thresholds))
		threshold_desc = "<b>Always:</b> The disease acts on a smaller scale, resetting burnt tissue back to a state of health.<br>\
					<b>Transmission 8:</b> The disease becomes more active, activating in a smaller temperature range."

/datum/symptom/teleport/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.resistance >= 6 || (CONFIG_GET(flag/unconditional_symptom_thresholds) || A.event))
		burnheal = TRUE
	if(A.transmission >= 8)
		telethreshold = -10
		power = 2

/datum/symptom/teleport/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	switch(A.stage)
		if(4, 5)
			if(burnheal)
				M.heal_overall_damage(0, 1.5 * power) //no required_status checks here, this does all bodyparts equally
			if(M.stat == DEAD)
				return
			if(COOLDOWN_FINISHED(src, teleport_cooldown) && (M.bodytemperature < BODYTEMP_HEAT_DAMAGE_LIMIT || M.bodytemperature > BODYTEMP_COLD_DAMAGE_LIMIT))
				location_return = get_turf(M)	//sets up return point
				to_chat(M, span_warning("The lukewarm temperature makes you feel strange!"))
				COOLDOWN_START(src, teleport_cooldown, (TELEPORT_COOLDOWN * 5) + (rand(1, 300) * 10))
			if(location_return)
				if(location_return.z != M.loc.z)
					location_return = null
					COOLDOWN_RESET(src, teleport_cooldown)
				else if(((M.bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT + telethreshold  && !HAS_TRAIT(M, TRAIT_RESISTHEAT)) || (M.bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT - telethreshold  && !HAS_TRAIT(M, TRAIT_RESISTCOLD)) || (burnheal && M.getFireLoss() > 60 + telethreshold)))
					do_sparks(5, FALSE, M)
					to_chat(M, span_userdanger("The change in temperature shocks you back to a previous spatial state!"))
					do_teleport(M, location_return, 0, asoundin = 'sound/effects/phasein.ogg') //Teleports home
					do_sparks(5, FALSE, M)
					if(burnheal)
						M.adjust_wet_stacks(10)
					location_return = null
					COOLDOWN_START(src, teleport_cooldown, TELEPORT_COOLDOWN)
			if(COOLDOWN_FINISHED(src, teleport_cooldown))
				location_return = null
		else
			if(prob(7) && M.stat != DEAD)
				to_chat(M, span_notice("[pick("Your warm breath fizzles out of existence.", "You feel attracted to temperate climates", "You feel like you're forgetting something")]"))
	return

/datum/symptom/growth
	name = "Pituitary Disruption"
	desc = "Causes uncontrolled growth in the subject."
	stealth = -3
	resistance = -2
	stage_speed = 1
	transmission = -2
	level = 8
	severity = 1
	symptom_delay_min = 1
	symptom_delay_max = 1
	prefixes = list("Blood ", "Meat ", "Flesh ")
	bodies = list("Giant")
	var/current_size = 1
	var/tetsuo = FALSE
	var/bruteheal = FALSE
	var/sizemult = 1
	var/datum/mind/ownermind
	threshold_desc = "<b>Stage Speed 6:</b> The disease heals brute damage at a fast rate, but causes expulsion of benign tumors.<br>\
					<b>Stage Speed 12:</b> The disease heals brute damage incredibly fast, but deteriorates cell health and causes tumors to become more advanced. The disease will also regenerate lost limbs."

/datum/symptom/growth/severityset(datum/disease/advance/A)
	. = ..()
	if(A.stage_rate >= 6 || (CONFIG_GET(flag/unconditional_symptom_thresholds) || A.event))
		severity -= 1
		if(A.stage_rate >= 12)
			severity += 3
	if(CONFIG_GET(flag/unconditional_symptom_thresholds))
		threshold_desc = "<b>Always:</b> The disease heals brute damage at a fast rate, but causes expulsion of benign tumors.<br>\
					<b>Stage Speed 12:</b> The disease heals brute damage incredibly fast, but deteriorates cell health and causes tumors to become more advanced. The disease will also regenerate lost limbs."


/datum/symptom/growth/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage_rate >= 6 || (CONFIG_GET(flag/unconditional_symptom_thresholds) || A.event))
		bruteheal = TRUE
		if(A.stage_rate >= 12)
			tetsuo = TRUE
			power = 3 //should make this symptom actually worth it
	var/mob/living/carbon/M = A.affected_mob
	ownermind = M.mind
	if(!A.carrier && !A.dormant)
		sizemult = clamp((0.5 + A.stage_rate / 10), 1.1, 1.5)
		M.resize = sizemult
		M.update_transform()

/datum/symptom/growth/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	switch(A.stage)
		if(4, 5)
			if(prob(5) && bruteheal)
				if(M.stat != DEAD)
					to_chat(M, span_userdanger("You retch, and a splatter of gore escapes your gullet!"))
					M.Immobilize(5)
					M.add_splatter_floor()
					playsound(get_turf(M), 'sound/effects/splat.ogg', 50, 1)
					if(prob(60) && M.mind && ishuman(M))
						if(tetsuo && prob(15))
							if(A.affected_mob.job == JOB_NAME_CLOWN)
								new /obj/effect/spawner/random/medical/teratoma/major/clown(M.loc)
							if(A.infectable_biotypes & MOB_ROBOTIC)
								new /obj/effect/decal/cleanable/robot_debris(M.loc)
								new /obj/effect/spawner/random/medical/teratoma/robot(M.loc)
						new /obj/effect/spawner/random/medical/teratoma/minor(M.loc)
				if(tetsuo)
					var/list/missing = M.get_missing_limbs()
					if(prob(35) && M.mind && ishuman(M) && M.stat != DEAD)
						new /obj/effect/decal/cleanable/blood/gibs(M.loc) //yes. this is very messy. very, very messy.
						new /obj/effect/spawner/random/medical/teratoma/major(M.loc)
					if(missing.len) //we regrow one missing limb
						for(var/Z in missing) //uses the same text and sound a ling's regen does. This can false-flag the host as a changeling.
							if(M.regenerate_limb(Z, TRUE))
								playsound(M, 'sound/magic/demon_consume.ogg', 50, 1)
								M.visible_message(span_warning("[M]'s missing limbs reform, making a loud, grotesque sound!"),
									span_userdanger("Your limbs regrow, making a loud, crunchy sound and giving you great pain!"),
									span_italics("You hear organic matter ripping and tearing!"))
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
			if(bruteheal)
				M.heal_overall_damage(2 * power, required_status = BODYTYPE_ORGANIC)
				if(prob(33) && tetsuo)
					M.adjustCloneLoss(1)
		else
			if(prob(5) && M.stat != DEAD)
				to_chat(M, span_notice("[pick("You feel bloated.", "The station seems small.", "You are the strongest.")]"))
	return

/datum/symptom/growth/End(datum/disease/advance/A)
	. = ..()
	var/mob/living/carbon/M = A.affected_mob
	to_chat(M, span_notice("You lose your balance and stumble as you shrink, and your legs come out from underneath you!"))
	M.resize = 1/sizemult
	M.update_transform()

#undef TELEPORT_COOLDOWN

/datum/symptom/vampirism
	name = "Hemetophagy"
	desc = "The host absorbs blood from external sources, and seemlessly reintegrates it into their own bloodstream, regardless of its bloodtype or how it was ingested. However, the virus also slowly consumes the host's blood"
	stealth = 1
	resistance = -2
	stage_speed = 1
	transmission = 2
	level = 9
	severity = 0
	symptom_delay_min = 1
	symptom_delay_max = 1
	prefixes = list("Porphyric ", "Hemo")
	bodies = list("Blood")
	var/bloodpoints = 0
	var/maxbloodpoints = 50
	var/datum/blood_type/bloodtypearchive
	var/bruteheal = FALSE
	var/aggression = FALSE
	var/vampire = FALSE
	var/mob/living/carbon/human/bloodbag
	threshold_desc = "<b>Transmission 4:</b> The virus recycles excess absorbed blood into restorative biomass, healing brute damage.<br>\
					<b>Stage Speed 7:</b> The virus grows more aggressive, assimilating blood and healing at a faster rate, but also draining the host's blood quicker<br>\
					<b>Transmission 6:</b> The virus aggressively assimilates blood, resulting in contiguous blood pools being absorbed by the virus, as well as sucking blood out of open wounds of subjects in physical contact with the host."

/datum/symptom/vampirism/severityset(datum/disease/advance/A)
	. = ..()
	if(A.transmission >= 4 || (CONFIG_GET(flag/unconditional_symptom_thresholds) || A.event))
		severity -= 1
	if((((A.stealth >= 2) && (A.transmission >= 6) && CONFIG_GET(flag/special_symptom_thresholds)) || A.event) && A.process_dead)
		severity -= 1
		bodies = list("Vampir", "Blood")
	if(CONFIG_GET(flag/unconditional_symptom_thresholds))
		threshold_desc = "<b>Always:</b> The virus recycles excess absorbed blood into restorative biomass, healing brute damage.<br>\
					<b>Stage Speed 5:</b> The virus grows more aggressive, assimilating blood and healing at a faster rate, but also draining the host's blood quicker<br>\
					<b>Transmission 6:</b> The virus aggressively assimilates blood, resulting in contiguous blood pools being absorbed by the virus, as well as sucking blood out of open wounds of subjects in physical contact with the host."

/datum/symptom/vampirism/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.transmission >= 4 || (CONFIG_GET(flag/unconditional_symptom_thresholds) || A.event))
		bruteheal = TRUE
	if(A.transmission >= 6)
		aggression = TRUE
		maxbloodpoints += 50
	if(A.stage_rate >= 7 || ((CONFIG_GET(flag/unconditional_symptom_thresholds) || A.event) && A.stage_rate >= 5))
		power += 1
	if((((A.stealth >= 2) && (A.transmission >= 6) && CONFIG_GET(flag/special_symptom_thresholds)) || A.event) && A.process_dead) //this is low transmission for 2 reasons: transmission is hard to raise, especially with stealth, and i dont want this to be obligated to be transmittable
		vampire = TRUE
		maxbloodpoints += 50
		power += 1
	if(ishuman(A.affected_mob) && A.affected_mob.get_blood_id() == /datum/reagent/blood)
		var/mob/living/carbon/human/H = A.affected_mob
		bloodtypearchive = H.dna.blood_type
		H.dna.blood_type = /datum/blood_type/universal

/datum/symptom/vampirism/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	switch(A.stage)
		if(1 to 4)
			if(prob(5) && M.stat != DEAD)
				to_chat(M, span_warning("[pick("You feel cold...", "You feel a bit thirsty", "It dawns upon you that every single human on this station has warm blood pulsing through their veins.")]"))
		if(5)
			ADD_TRAIT(A.affected_mob, TRAIT_DRINKSBLOOD, DISEASE_TRAIT)
			var/grabbedblood = succ(M) //before adding sucked blood to bloodpoints, immediately try to heal bloodloss
			if(M.blood_volume < BLOOD_VOLUME_NORMAL && M.get_blood_id() == /datum/reagent/blood)
				var/missing = BLOOD_VOLUME_NORMAL - M.blood_volume
				var/inflated = grabbedblood * 4
				M.blood_volume = min(M.blood_volume + inflated, BLOOD_VOLUME_NORMAL)
				bloodpoints += round(max(0, (inflated - missing)/4))
			else if((M.blood_volume >= BLOOD_VOLUME_NORMAL + 4) && (bloodpoints < maxbloodpoints))//so drinking blood accumulates bloodpoints
				M.blood_volume = (M.blood_volume - 4)
				bloodpoints += 1
			else
				bloodpoints += max(0, grabbedblood)
			for(var/I in 1 to power)//power doesnt increase efficiency, just usage.
				if(bloodpoints > 0)
					if(ishuman(M))
						var/mob/living/carbon/human/H = M
						if(bruteheal && bloodpoints)
							bloodpoints -= 1
							H.cauterise_wounds(0.1)
					if(M.blood_volume < BLOOD_VOLUME_NORMAL && M.get_blood_id() == /datum/reagent/blood) //bloodloss is prioritized over healing brute
						bloodpoints -= 1
						M.blood_volume = max((M.blood_volume + 3 * power), BLOOD_VOLUME_NORMAL) //bloodpoints are valued at 4 units of blood volume per point, so this is diminished
					else if(bruteheal && M.getBruteLoss())
						bloodpoints -= 1
						M.heal_overall_damage(2, required_status = BODYTYPE_ORGANIC)
					if(prob(60) && !M.stat)
						bloodpoints -- //you cant just accumulate blood and keep it as a battery of healing. the quicker the symptom is, the faster your bloodpoints decay
				else if(prob(20) && M.blood_volume >= BLOOD_VOLUME_BAD)//the virus continues to extract blood if you dont have any stored up. higher probability due to BP value
					M.blood_volume = (M.blood_volume - 1)

			if(!bloodpoints && prob(3) && M.stat != DEAD)
				to_chat(M, span_warning("[pick("You feel a pang of thirst.", "No food can sate your hunger", "Blood...")]"))

/datum/symptom/vampirism/End(datum/disease/advance/A)
	. = ..()
	REMOVE_TRAIT(A.affected_mob, TRAIT_DRINKSBLOOD, DISEASE_TRAIT)
	if(bloodtypearchive && ishuman(A.affected_mob))
		var/mob/living/carbon/human/H = A.affected_mob
		H.dna.blood_type = bloodtypearchive

/datum/symptom/vampirism/proc/succ(mob/living/carbon/M) //you dont need the blood reagent to suck blood. however, you need to have blood, or at least a shared blood reagent, for most of the other uses
	var/gainedpoints = 0
	if(bloodbag && !bloodbag.blood_volume) //we've exsanguinated them!
		bloodbag = null
	if(ishuman(M) && M.stat == DEAD && vampire)
		var/mob/living/carbon/human/H = M
		var/possibledist = power + 1
		if(M.get_blood_id() != /datum/reagent/blood)
			possibledist = 1
		if(!HAS_TRAIT(H, TRAIT_NOBLOOD) || HAS_TRAIT(H, TRAIT_NO_BLOOD)) //if you dont have blood, well... sucks to be you
			H.setOxyLoss(0,0) //this is so a crit person still revives if suffocated
			if(bloodpoints >= 200 && H.health > 0 && H.blood_volume >= BLOOD_VOLUME_NORMAL) //note that you need to actually need to heal, so a maxed out virus won't be bringing you back instantly in most cases. *even so*, if this needs to be nerfed ill do it in a heartbeat
				H.revive()
				H.visible_message(span_warning("[H.name]'s skin takes on a rosy hue as they begin moving. They live again!"), span_userdanger("As your body fills with fresh blood, you feel your limbs once more, accompanied by an insatiable thirst for blood."))
				bloodpoints = 0
				return 0
			else if(bloodbag && bloodbag.blood_volume && (bloodbag.stat || bloodbag.is_bleeding()))
				if(get_dist(bloodbag, H) <= 1 && bloodbag.z == H.z)
					var/amt = ((bloodbag.stat * 2) + 2) * power
					var/excess = max(((min(amt, bloodbag.blood_volume) - (BLOOD_VOLUME_NORMAL - H.blood_volume)) / 2), 0)
					H.blood_volume = min(H.blood_volume + min(amt, bloodbag.blood_volume), BLOOD_VOLUME_NORMAL)
					bloodbag.blood_volume = max(bloodbag.blood_volume - amt, 0)
					bloodpoints += max(excess, 0)
					playsound(bloodbag.loc, 'sound/magic/exit_blood.ogg', 10, 1)
					bloodbag.visible_message(span_warning("Blood flows from [bloodbag.name]'s wounds into [H.name]'s corpse!"), span_userdanger("Blood flows from your wounds into [H.name]'s corpse!"))
				else if(get_dist(bloodbag, H) >= possibledist) //they've been taken out of range.
					bloodbag = null
					return
				else if(bloodpoints >= 2)
					var/turf/T = H.loc
					var/obj/effect/decal/cleanable/blood/influenceone = (locate(/obj/effect/decal/cleanable/blood) in H.loc)
					if(!influenceone && bloodpoints >= 2)
						H.add_splatter_floor(T)
						playsound(T, 'sound/effects/splat.ogg', 50, 1)
						bloodpoints -= 2
						return 0
					else
						var/todir = get_dir(H, bloodbag)
						var/targetloc = bloodbag.loc
						var/dist = get_dist(H, bloodbag)
						for(var/i=0 to dist)
							T = get_step(T, todir)
							todir = get_dir(T, bloodbag)
							var/obj/effect/decal/cleanable/blood/influence = (locate(/obj/effect/decal/cleanable/blood) in T)
							if(!influence && bloodpoints >= 2)
								H.add_splatter_floor(T)
								playsound(T, 'sound/effects/splat.ogg', 50, 1)
								bloodpoints -= 2
								return 0
							else if(T == targetloc && bloodpoints >= 2)
								bloodbag.throw_at(H, 1, 1)
								bloodpoints -= 2
								bloodbag.visible_message(span_warning("A current of blood pushes [bloodbag.name] towards [H.name]'s corpse!"))
								playsound(bloodbag.loc, 'sound/magic/exit_blood.ogg', 25, 1)
								return 0
			else
				var/list/candidates = list()
				for(var/mob/living/carbon/human/C in ohearers(min(bloodpoints/4, possibledist), H))
					if(HAS_TRAIT(C, TRAIT_NOBLOOD) || HAS_TRAIT(C, TRAIT_NO_BLOOD))
						continue
					if(C.stat && C.blood_volume && C.get_blood_id() == H.get_blood_id())
						candidates += C
				for(var/prospect in candidates)
					candidates[prospect] = 1
					if(ishuman(prospect))
						var/mob/living/carbon/human/candidate = prospect
						candidates[prospect] += (candidate.stat - 1)
						candidates[prospect] += (3 - get_dist(candidate, H)) * 2
						candidates[prospect] += round(candidate.blood_volume / 150)
				bloodbag = pick_weight(candidates) //dont return here

	if(bloodpoints >= maxbloodpoints)
		return 0
	if(ishuman(M) && aggression) //first, try to suck those the host is actively grabbing
		var/mob/living/carbon/human/H = M
		if(H.pulling && ishuman(H.pulling)) //grabbing is handled with the disease instead of the component, so the component doesn't have to be processed
			var/mob/living/carbon/human/C = H.pulling
			if(!C.is_bleeding() && vampire && C.can_inject() && H.grab_state && C.get_blood_id() == H.get_blood_id() && !(HAS_TRAIT(C, TRAIT_NOBLOOD) || HAS_TRAIT(C, TRAIT_NO_BLOOD)))//aggressive grab as a "vampire" starts the target bleeding
				C.add_bleeding(BLEED_SURFACE)
				C.visible_message(span_warning("Wounds open on [C.name]'s skin as [H.name] grips them tightly!"), span_userdanger("You begin bleeding at [H.name]'s touch!"))
			if(C.blood_volume && C.can_inject() && (C.is_bleeding() && vampire) && C.get_blood_id() == H.get_blood_id() && !(HAS_TRAIT(C, TRAIT_NOBLOOD) || HAS_TRAIT(C, TRAIT_NO_BLOOD)))
				var/amt = (H.grab_state + C.stat + 2) * power
				if(C.blood_volume)
					var/excess = max(((min(amt, C.blood_volume) - (BLOOD_VOLUME_NORMAL - H.blood_volume)) / 4), 0)
					H.blood_volume = min(H.blood_volume + min(amt, C.blood_volume), BLOOD_VOLUME_NORMAL)
					C.blood_volume = max(C.blood_volume - amt, 0)
					gainedpoints = clamp(excess, 0, maxbloodpoints - bloodpoints)
					C.visible_message(span_warning("Blood flows from [C.name]'s wounds into [H.name]!"), span_userdanger("Blood flows from your wounds into [H.name]!"))
					playsound(C.loc, 'sound/magic/exit_blood.ogg', 25, 1)
					return gainedpoints
	if(locate(/obj/effect/decal/cleanable/blood) in M.loc)
		var/obj/effect/decal/cleanable/blood/initialstain = (locate(/obj/effect/decal/cleanable/blood) in M.loc)
		var/list/stains = list()
		var/suckamt = power + 1
		if(aggression)
			for(var/obj/effect/decal/cleanable/blood/contiguousstain in orange(1, M))
				if(suckamt)
					suckamt --
					stains += contiguousstain
			if(suckamt)
				suckamt --
				stains += initialstain
		for(var/obj/effect/decal/cleanable/blood/stain in stains) //this doesnt use switch(type) because that doesnt check subtypes
			if(istype(stain, /obj/effect/decal/cleanable/blood/gibs/old))
				gainedpoints += 3
				qdel(stain)
			else if(istype(stain, /obj/effect/decal/cleanable/blood/old))
				gainedpoints += 1
				qdel(stain)
			else if(istype(stain, /obj/effect/decal/cleanable/blood/gibs))
				gainedpoints += 5
				qdel(stain)
			else if(istype(stain, /obj/effect/decal/cleanable/blood/footprints) || istype(stain, /obj/effect/decal/cleanable/blood/tracks) || istype(stain, /obj/effect/decal/cleanable/blood/drip))
				qdel(stain)//these types of stain are generally very easy to make, we don't use these
			else if(istype(stain, /obj/effect/decal/cleanable/blood))
				gainedpoints += 2
				qdel(stain)
		if(gainedpoints)
			playsound(M.loc, 'sound/magic/exit_blood.ogg', 50, 1)
			M.visible_message(span_warning("Blood flows from the floor into [M.name]!"), span_warning("You consume the errant blood"))
		return clamp(gainedpoints, 0, maxbloodpoints - bloodpoints)
	if(ishuman(M) && aggression)//finally, attack mobs touching the host.
		var/mob/living/carbon/human/H = M
		for(var/mob/living/carbon/human/C in ohearers(1, H))
			if(HAS_TRAIT(C, TRAIT_NOBLOOD) || HAS_TRAIT(C, TRAIT_NO_BLOOD))
				continue
			if((C.pulling && C.pulling == H) || (C.loc == H.loc) && C.is_bleeding() && C.get_blood_id() == H.get_blood_id())
				var/amt = (2 * power)
				if(C.blood_volume)
					var/excess = max(((min(amt, C.blood_volume) - (BLOOD_VOLUME_NORMAL - H.blood_volume)) / 4 * power), 0)
					H.blood_volume = min(H.blood_volume + min(amt, C.blood_volume), BLOOD_VOLUME_NORMAL)
					C.blood_volume = max(C.blood_volume - amt, 0)
					gainedpoints += clamp(excess, 0, maxbloodpoints - bloodpoints)
					C.visible_message(span_warning("Blood flows from [C.name]'s wounds into [H.name]!"), span_userdanger("Blood flows from your wounds into [H.name]!"))
		return clamp(gainedpoints, 0, maxbloodpoints - bloodpoints)


/datum/symptom/parasite
	name = "Xenobiological Symbiosis"
	desc = "The virus contains latent DNA blueprints to create a toxin-devouring grub egg, which parasitizes slimes and slime people. Its normally toxic, infectious flesh becomes safe and delicious when cooked."
	stealth = 1
	resistance = 2
	stage_speed = 2
	transmission = -1
	level = 8
	severity = 1
	symptom_delay_min = 1
	symptom_delay_max = 1
	prefixes = list("Parasitic ")
	bodies = list("Cytoplasm", "Slime")
	var/list/grubs = list()
	var/toxheal = FALSE
	threshold_desc = "<b>Stealth 2:</b>The gestating larvae can consume toxins in the host's bloodstream.<br>\
					<b>Stage Speed 6:</b> More larvae are born, and they leave the host faster."

/datum/symptom/parasite/severityset(datum/disease/advance/A)
	. = ..()
	if(A.stealth >= 2 || (CONFIG_GET(flag/unconditional_symptom_thresholds) || A.event))
		severity -= 2
		prefixes = list("Symbiotic ")
	if(A.stage_rate >= 6)
		severity = (severity * 2)
	if(CONFIG_GET(flag/unconditional_symptom_thresholds))
		threshold_desc = "<b>Always:</b>The gestating larvae can consume toxins in the host's bloodstream.<br>\
					<b>Stage Speed 6:</b> More larvae are born, and they leave the host faster."

/datum/symptom/parasite/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stealth >= 2 || (CONFIG_GET(flag/unconditional_symptom_thresholds) || A.event))
		toxheal = TRUE
	if(A.stage_rate >= 6)
		power += 1

/datum/symptom/parasite/proc/isslimetarget(mob/living/carbon/M)
	if(isoozeling(M))
//	if(isslimeperson(M) || isluminescent(M) || isoozeling(M) || isstargazer(M))
		return TRUE
	else
		return FALSE

/datum/symptom/parasite/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	switch(A.stage)
		if(1, 2)
			if(M.stat != DEAD)
				to_chat(M, span_warning("[pick("You feel something crawling in your veins!", "You feel an unpleasant throbbing.", "You hear something squishy in your ear.")]"))
		if(3 to 5)
			var/slowdown = 0
			for(var/mob/living/simple_animal/hostile/redgrub/grub in grubs)//check if grubs need to be born, then feed existing grubs, or get them closer to hatching
				var/efficacy = grub.growthstage / 2
				if(grub.growthstage >= 3 || grub.patience <= 0 || grub.stat)
					M.visible_message(span_warning("[M] vomits up a disgusting grub!"), \
							span_userdanger("You vomit a large, slithering grub!"))
					M.Stun((grub.growthstage * 10))
					playsound(M.loc, 'sound/effects/splat.ogg', 50, 1)
					grub.forceMove(M.loc)
					grub.togglehibernation()
					grubs -= grub
					continue
				slowdown = (min(3, slowdown + efficacy))
				if((M.getToxLoss() && toxheal) || isslimetarget(M))
					M.adjustToxLoss(-efficacy)
					if(grub.growthstage < (A.stage - 2))
						grub.food += 1 * power
					grub.patience = (rand(60, 120) / power)
				else
					grub.patience --
			if(((M.getToxLoss() > (LAZYLEN(grubs) * (30/power))) || isslimetarget(M)) && prob(10 * power) && (LAZYLEN(grubs) < power * 2))
				var/mob/living/simple_animal/hostile/redgrub/grub = new(src)// add new grubs if there's enough toxin for them
				grub.food = 10
				grubs += grub
				grub.togglehibernation()
				grub.grub_diseases += A
			if(prob(LAZYLEN(grubs) * (6/power)) && M.stat != DEAD)// so you know its working. power lowers this so it doesnt spam you at high grub counts
				to_chat(M, span_warning("You feel something squirming inside of you!"))
			M.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/virus/grub_virus, multiplicative_slowdown = max(slowdown - 0.5, 0))

/datum/symptom/parasite/End(datum/disease/advance/A)
	. = ..()
	var/mob/living/carbon/M = A.affected_mob
	M.remove_movespeed_modifier(/datum/movespeed_modifier/virus/grub_virus)
	for(var/mob/living/simple_animal/hostile/redgrub/grub in grubs)
		M.visible_message(span_warning("[M] vomits up a disgusting grub!"), \
				span_userdanger("You vomit a large, slithering grub!"))
		M.Stun((grub.growthstage * 10))
		grub.forceMove(M.loc)
		grub.togglehibernation()
		playsound(M.loc, 'sound/effects/splat.ogg', 50, 1)

/datum/symptom/parasite/OnDeath(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	for(var/mob/living/simple_animal/hostile/redgrub/grub in grubs)
		grub.forceMove(M.loc)
		grub.togglehibernation()
		playsound(M.loc, 'sound/effects/splat.ogg', 50, 1)
	if(isslimetarget(M) && A.stage >= 3)
		for(var/I in 1 to (rand(1, A.stage)))
			var/mob/living/simple_animal/hostile/redgrub/grub = new(M.loc)
			grub.grub_diseases += A
		M.gib()
		M.visible_message(span_warning("[M] is eaten alive by a swarm of red grubs!"))

/datum/symptom/jitters
	name = "Hyperactivity"
	desc = "The virus causes restlessness, nervousness and hyperactivity, increasing the rate at which the host needs to eat,but making them harder to tire out"
	stealth = -4
	resistance = 0
	stage_speed = 2
	transmission = -3
	level = 8
	severity = 1
	symptom_delay_min = 1
	symptom_delay_max = 1
	prefixes = list("Gray ", "Amped ", "Nervous ")
	var/clearcc = FALSE
	threshold_desc = "<b>Resistance 8:</b>The virus causes an even greater rate of nutriment loss, able to cause starvation, but its energy gain greatly increases<br>\
					<b>Stage Speed 8:</b>The virus causes extreme nervousness and paranoia, resulting in occasional hallucinations, and extreme restlessness, but greater overall energy and the ability to shake off stuns faster."

/datum/symptom/jitters/severityset(datum/disease/advance/A)
	. = ..()
	if(A.resistance >= 8)
		severity -= 1
	if(A.stage_rate >= 8)
		severity -= 1
		prefixes = list("Gray ", "Amped ", "Paranoid ")
		suffixes = list(" Madness", " Insanity")

/datum/symptom/jitters/Start(datum/disease/advance/A)
	if(!..())
		return
	power = initial(power)
	if(A.resistance >= 8)
		power += 2
	if(A.stage_rate >= 8)
		power += 1
		clearcc = TRUE

/datum/symptom/jitters/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	if(M.stat == DEAD)
		return
	switch(A.stage)
		if(2 to 3)
			if(prob(power) && M.stat)
				M.set_jitter_if_lower(4 SECONDS * power)
				M.emote("twitch")
				to_chat(M, span_notice("[pick("You feel energetic!", "You feel well-rested.", "You feel great!")]"))
		if(4 to 5)
			M.adjustStaminaLoss((-5 * power), 0)
			M.set_drowsiness_if_lower(4 SECONDS * power)
			M.AdjustSleeping(-10 * power)
			M.AdjustUnconscious(-10 * power)
			if(prob(power) && prob(50))
				if(M.stat)
					M.emote("twitch")
					M.set_jitter_if_lower(4 SECONDS * power)
				to_chat(M, span_notice("[pick("You feel nervous...", "You feel anxious.", "You feel like everything is moving in slow motion.")]"))
				SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "hyperactivity", /datum/mood_event/nervous)
			if(M.satiety > NUTRITION_LEVEL_HUNGRY - (30 * power))
				M.satiety = max(NUTRITION_LEVEL_HUNGRY - (30 * power), M.satiety - (2 * power))
			if(prob(25))
				M.set_jitter_if_lower(4 SECONDS * power)
			if(clearcc)
				var/realpower = power
				if(prob(power) && prob(50))
					realpower = power + 10
					if(M.stat)
						M.emote("scream")
					M.adjust_hallucinations_up_to(8 SECONDS, (10 * power) SECONDS)
					SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "hyperactivity", /datum/mood_event/paranoid)
				M.AdjustAllImmobility((realpower * -10),TRUE)
