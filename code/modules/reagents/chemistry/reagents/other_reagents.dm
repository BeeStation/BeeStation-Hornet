/datum/reagent/blood
	data = list("viruses"=null,"blood_DNA"=null,"blood_type"=null,"resistances"=null,"trace_chem"=null,"mind"=null,"ckey"=null,"gender"=null,"real_name"=null,"cloneable"=null,"factions"=null,"quirks"=null)
	name = "Blood"
	color = "#C80000" // rgb: 200, 0, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST
	metabolization_rate = 12.5 * REAGENTS_METABOLISM //fast rate so it disappears fast.
	taste_description = "iron"
	taste_mult = 1.3
	default_container = /obj/item/reagent_containers/blood

/datum/glass_style/shot_glass/blood
	required_drink_type = /datum/reagent/blood
	icon_state = "shotglassred"

/datum/glass_style/drinking_glass/blood
	required_drink_type = /datum/reagent/blood
	name = "glass of tomato juice"
	desc = "Are you sure this is tomato juice?"
	icon_state = "glass_red"

/datum/reagent/blood/expose_mob(mob/living/L, method=TOUCH, reac_volume)
	if(data && data["viruses"])
		for(var/thing in data["viruses"])
			var/datum/disease/D = thing

			if((D.spread_flags & DISEASE_SPREAD_SPECIAL) || (D.spread_flags & DISEASE_SPREAD_NON_CONTAGIOUS))
				continue

			if((method == TOUCH || method == VAPOR) && (D.spread_flags & DISEASE_SPREAD_CONTACT_FLUIDS))
				L.ContactContractDisease(D)
			else //ingest, patch or inject
				L.ForceContractDisease(D)

	if(iscarbon(L))
		var/mob/living/carbon/C = L
		if(C.get_blood_id() == /datum/reagent/blood && (method == INJECT || (method == INGEST && HAS_TRAIT(C, TRAIT_DRINKSBLOOD))))
			if(!data || !(data["blood_type"] in get_safe_blood(C.dna.blood_type)))
				C.reagents.add_reagent(/datum/reagent/toxin, reac_volume * 0.5)
			else
				C.blood_volume = min(C.blood_volume + round(reac_volume, 0.1), BLOOD_VOLUME_MAXIMUM)


/datum/reagent/blood/on_new(list/data)
	. = ..()
	if(istype(data))
		SetViruses(src, data)

/datum/reagent/blood/on_merge(list/mix_data)
	if(data && mix_data)
		if(data["blood_DNA"] != mix_data["blood_DNA"])
			data["cloneable"] = 0 //On mix, consider the genetic sampling unviable for pod cloning if the DNA sample doesn't match.
		if((data["viruses"] || mix_data["viruses"]) && CONFIG_GET(flag/mixvirus_allowed))

			var/list/mix1 = data["viruses"]
			var/list/mix2 = mix_data["viruses"]

			// Stop issues with the list changing during mixing.
			var/list/to_mix = list()

			for(var/datum/disease/advance/AD in mix1)
				if(AD.mutable)
					to_mix += AD
			for(var/datum/disease/advance/AD in mix2)
				if(AD.mutable)
					to_mix += AD

			var/datum/disease/advance/AD = Advance_Mix(to_mix)
			if(AD)
				var/list/preserve = list(AD)
				for(var/D in data["viruses"])
					if(istype(D, /datum/disease/advance))
						var/datum/disease/advance/A = D
						if(!A.mutable)
							preserve += A
					else
						preserve += D
				data["viruses"] = preserve
	return 1

/datum/reagent/blood/proc/get_diseases()
	. = list()
	if(data && data["viruses"])
		for(var/thing in data["viruses"])
			var/datum/disease/D = thing
			. += D

/datum/reagent/blood/expose_turf(turf/T, reac_volume)//splash the blood all over the place
	if(!istype(T))
		return
	if(reac_volume < 3)
		return

	var/obj/effect/decal/cleanable/blood/B = locate() in T //find some blood here
	if(!B)
		B = new(T)
	if(data["blood_DNA"])
		B.add_blood_DNA(list(data["blood_DNA"] = data["blood_type"]))

/datum/reagent/liquidgibs
	name = "Liquid gibs"
	color = "#FF9966"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY
	description = "You don't even want to think about what's in here."
	taste_description = "gross iron"

/datum/glass_style/shot_glass/liquidgibs
	required_drink_type = /datum/reagent/liquidgibs
	icon_state = "shotglassred"

/datum/reagent/vaccine
	//data must contain virus type
	name = "Vaccine"
	color = "#C81040" // rgb: 200, 16, 64
	chem_flags = NONE
	taste_description = "slime"

/datum/reagent/vaccine/expose_mob(mob/living/L, method=TOUCH, reac_volume)
	if(islist(data) && (method == INGEST || method == INJECT))
		for(var/thing in L.diseases)
			var/datum/disease/D = thing
			if(D.GetDiseaseID() in data)
				D.cure()
		L.disease_resistances |= data

/datum/reagent/vaccine/on_merge(list/data)
	if(istype(data))
		src.data |= data.Copy()

/datum/reagent/corgium
	name = "Corgium"
	description = "A happy looking liquid that you feel compelled to consume if you want a better life."
	color = "#ecca7f"
	chem_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "dog treats"
	var/mob/living/resulting_mob

/datum/reagent/corgium/on_mob_metabolize(mob/living/target)
	. = ..()
	target.buckled?.unbuckle_mob(target, force = TRUE)
	resulting_mob = target.do_shapeshift(shapeshift_type = /mob/living/basic/pet/dog/corgi)
	//Restore after this time
	addtimer(CALLBACK(src, PROC_REF(restore), resulting_mob), 5 * (volume / metabolization_rate))

/datum/reagent/corgium/proc/restore(mob/living/target)
	target.do_unshapeshift()
	//Remove all the corgium from the person
	target.reagents?.remove_reagent(/datum/reagent/corgium, INFINITY)
	holder.remove_reagent(/datum/reagent/corgium, INFINITY)

/datum/reagent/water
	name = "Water"
	description = "An ubiquitous chemical substance that is composed of hydrogen and oxygen."
	color = "#AAAAAA77" // rgb: 170, 170, 170, 77 (alpha)
	chem_flags = CHEMICAL_BASIC_ELEMENT | CHEMICAL_RNG_GENERAL // because we want to give it to oozelings
	taste_description = "water"
	var/cooling_temperature = 2
	process_flags = ORGANIC | SYNTHETIC
	default_container = /obj/item/reagent_containers/cup/glass/waterbottle

/datum/glass_style/shot_glass/water
	required_drink_type = /datum/reagent/water
	icon_state = "shotglassclear"

/datum/glass_style/drinking_glass/water
	required_drink_type = /datum/reagent/water
	name = "glass of water"
	desc = "The father of all refreshments."
	icon_state = "glass_clear"

/*
 *	Water reaction to turf
 */

/datum/reagent/water/expose_turf(turf/open/T, reac_volume)
	if(!istype(T))
		return
	var/CT = cooling_temperature

	if(reac_volume >= 5)
		T.MakeSlippery(TURF_WET_WATER, 10 SECONDS, min(reac_volume*1.5 SECONDS, 60 SECONDS))

	for(var/mob/living/simple_animal/slime/M in T)
		M.apply_water()

	var/obj/effect/hotspot/hotspot = (locate(/obj/effect/hotspot) in T)
	if(hotspot && !isspaceturf(T))
		if(T.air)
			var/datum/gas_mixture/G = T.air
			G.temperature = (max(min(G.return_temperature()-(CT*1000),G.return_temperature()/CT),TCMB))
			G.react(src)
			qdel(hotspot)
	var/obj/effect/acid/A = (locate(/obj/effect/acid) in T)
	if(A)
		A.acid_level = max(A.acid_level - reac_volume*50, 0)
	T.clean_turf_texture()

/*
 *	Water reaction to an object
 */

/datum/reagent/water/expose_obj(obj/O, reac_volume)
	O.extinguish()
	O.acid_level = 0
	// Monkey cube
	if(istype(O, /obj/item/food/monkeycube))
		var/obj/item/food/monkeycube/cube = O
		cube.Expand()

	// Dehydrated carp
	else if(istype(O, /obj/item/toy/plush/carpplushie/dehy_carp))
		var/obj/item/toy/plush/carpplushie/dehy_carp/dehy = O
		dehy.Swell() // Makes a carp

	else if(istype(O, /obj/item/stack/sheet/leather/hairlesshide))
		var/obj/item/stack/sheet/leather/hairlesshide/HH = O
		new /obj/item/stack/sheet/leather/wetleather(get_turf(HH), HH.amount)
		qdel(HH)

/*
 *	Water reaction to a mob
 */

/datum/reagent/water/expose_mob(mob/living/M, method=TOUCH, reac_volume)//Splashing people with water can help put them out!
	if(!istype(M))
		return
	if(isoozeling(M))
		var/touch_mod = 0
		if(method in list(TOUCH, VAPOR)) // No melting if you have skin protection
			touch_mod = M.getarmor(null, BIO) * 0.01
		M.blood_volume = max(M.blood_volume - 30 * (1 - touch_mod), 0)
		if(touch_mod < 0.9)
			to_chat(M, span_warning("The water causes you to melt away!"))
	if(method == TOUCH)
		M.adjust_fire_stacks(-(reac_volume / 10))
		M.ExtinguishMob()
	..()

/datum/reagent/water/holywater
	name = "Holy Water"
	description = "Water blessed by some deity."
	color = "#E0E8EF" // rgb: 224, 232, 239
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST
	self_consuming = TRUE //divine intervention won't be limited by the lack of a liver
	default_container = /obj/item/reagent_containers/cup/glass/bottle/holywater

/datum/glass_style/drinking_glass/holywater
	required_drink_type = /datum/reagent/water/holywater
	name = "glass of holy water"
	desc = "A glass of holy water."
	icon_state = "glass_clear"

/datum/reagent/water/holywater/on_mob_metabolize(mob/living/L)
	..()
	L.AddComponent(/datum/component/anti_magic, type, MAGIC_RESISTANCE_HOLY)

/datum/reagent/water/holywater/on_mob_end_metabolize(mob/living/L)
	for (var/datum/component/anti_magic/anti_magic in L.GetComponents(/datum/component/anti_magic))
		if (anti_magic.source == type)
			qdel(anti_magic)
	if(HAS_TRAIT_FROM(L, TRAIT_DEPRESSION, HOLYWATER_TRAIT))
		REMOVE_TRAIT(L, TRAIT_DEPRESSION, HOLYWATER_TRAIT)
		to_chat(L, span_notice("You cheer up, knowing that everything is going to be ok."))
	..()

/datum/reagent/water/holywater/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(!data)
		data = list("misc" = 0)

	data["misc"] += delta_time SECONDS * REM
	M.jitteriness = min(M.jitteriness + (2 * delta_time), 10)
	if(iscultist(M))
		for(var/datum/action/innate/cult/blood_magic/BM in M.actions)
			to_chat(M, span_cultlarge("Your blood rites falter as holy water scours your body!"))
			for(var/datum/action/innate/cult/blood_spell/BS in BM.spells)
				qdel(BS)
	if(data["misc"] >= (25 SECONDS)) // 10 units
		if(!M.stuttering)
			M.stuttering = 1
		M.stuttering = min(M.stuttering + (2 * delta_time), 10)
		M.Dizzy(5)
		if(is_servant_of_ratvar(M) && DT_PROB(10, delta_time))
			M.say(text2ratvar(pick("Please don't leave me...", "Rat'var what happened?", "My friends, where are you?", "The hierophant network just went dark, is anyone there?", "The light is fading...", "No... It can't be...")), forced = "holy water")
			if(prob(40))
				if(!HAS_TRAIT_FROM(M, TRAIT_DEPRESSION, HOLYWATER_TRAIT))
					to_chat(M, "[span_largebrass("You feel the light fading and the world collapsing around you...")]")
					ADD_TRAIT(M, TRAIT_DEPRESSION, HOLYWATER_TRAIT)
		if(iscultist(M) && DT_PROB(10, delta_time))
			M.say(pick("Av'te Nar'Sie","Pa'lid Mors","INO INO ORA ANA","SAT ANA!","Daim'niodeis Arc'iai Le'eones","R'ge Na'sie","Diabo us Vo'iscum","Eld' Mon Nobis"), forced = "holy water")
			if(prob(10))
				M.visible_message(span_danger("[M] starts having a seizure!"), span_userdanger("You have a seizure!"))
				M.Unconscious(12 SECONDS)
				to_chat(M, span_cultlarge(pick("Your blood is your bond - you are nothing without it", "Do not forget your place", \
				"All that power, and you still fail?", "If you cannot scour this poison, I shall scour your meager life!")))
	if(data["misc"] >= (1 MINUTES)) // 24 units
		if(iscultist(M) || is_servant_of_ratvar(M))
			if(iscultist(M))
				SSticker.mode.remove_cultist(M.mind, FALSE, TRUE)
			if(is_servant_of_ratvar(M))
				remove_servant_of_ratvar(M.mind)
			M.jitteriness = 0
			M.stuttering = 0
			holder.remove_reagent(type, volume)	// maybe this is a little too perfect and a max() cap on the statuses would be better??
			return
	holder.remove_reagent(type, 1 * REAGENTS_METABOLISM * delta_time) //fixed consumption to prevent balancing going out of whack

/datum/reagent/water/holywater/expose_turf(turf/T, reac_volume)
	..()
	if(!istype(T))
		return
	if(reac_volume>=10)
		for(var/obj/effect/rune/R in T)
			qdel(R)
	T.Bless()

/datum/reagent/fuel/unholywater		//if you somehow managed to extract this from someone, dont splash it on yourself and have a smoke
	name = "Unholy Water"
	description = "Something that shouldn't exist on this plane of existence."
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "suffering"

/datum/reagent/fuel/unholywater/expose_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == TOUCH || method == VAPOR)
		M.reagents.add_reagent(type,reac_volume/4)
		return
	return ..()

/datum/reagent/fuel/unholywater/on_mob_metabolize(mob/living/L)
	ADD_TRAIT(L, TRAIT_NO_BLEEDING, type)

/datum/reagent/fuel/unholywater/on_mob_end_metabolize(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_NO_BLEEDING, type)

/datum/reagent/fuel/unholywater/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(iscultist(M))
		M.drowsyness = max(M.drowsyness - (5* REM * delta_time), 0)
		M.AdjustAllImmobility(-40 *REM* REM * delta_time)
		M.adjustStaminaLoss(-10 * REM * delta_time, 0)
		M.adjustToxLoss(-2 * REM * delta_time, 0)
		M.adjustOxyLoss(-2 * REM * delta_time, 0)
		M.adjustBruteLoss(-2 * REM * delta_time, 0)
		M.adjustFireLoss(-2 * REM * delta_time, 0)
		if(ishuman(M) && M.blood_volume < BLOOD_VOLUME_NORMAL)
			M.blood_volume += 3 * REM * delta_time
	else  // Will deal about 90 damage when 50 units are thrown
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3 * REM * delta_time, 150)
		M.adjustToxLoss(1 * REM * delta_time, 0)
		M.adjustFireLoss(1 * REM * delta_time, 0)
		M.adjustOxyLoss(1 * REM * delta_time, 0)
		M.adjustBruteLoss(1 * REM * delta_time, 0)
	holder.remove_reagent(type, 1)
	return TRUE

/datum/reagent/hellwater			//if someone has this in their system they've really pissed off an eldrich god
	name = "Hell Water"
	description = "YOUR FLESH! IT BURNS!"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "burning"
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/hellwater/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.fire_stacks = min(M.fire_stacks + (1.5 * delta_time), 5)
	M.IgniteMob() //Only problem with igniting people is currently the commonly available fire suits make you immune to being on fire
	M.adjustToxLoss(0.5*delta_time, 0)
	M.adjustFireLoss(0.5*delta_time, 0) //Hence the other damages... ain't I a bastard?
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2.5*delta_time, 150)
	holder.remove_reagent(type, 0.5*delta_time)

/datum/reagent/medicine/omnizine/godblood
	name = "Godblood"
	description = "Slowly heals all damage types. Has a rather high overdose threshold. Glows with mysterious power."
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	overdose_threshold = 150

/datum/reagent/lube
	name = "Space Lube"
	description = "Lubricant is a substance introduced between two moving surfaces to reduce the friction and wear between them. giggity."
	color = "#009CA8" // rgb: 0, 156, 168
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST | CHEMICAL_GOAL_BARTENDER_SERVING
	taste_description = "cherry" // by popular demand
	var/lube_kind = TURF_WET_LUBE ///What kind of slipperiness gets added to turfs.

/datum/reagent/lube/expose_turf(turf/open/T, reac_volume)
	if (!istype(T))
		return
	if(reac_volume >= 1)
		T.MakeSlippery(lube_kind, 15 SECONDS, min(reac_volume * 2 SECONDS, 120))

///Stronger kind of lube. Applies TURF_WET_SUPERLUBE.
/datum/reagent/lube/superlube
	name = "Super Duper Lube"
	description = "This \[REDACTED\] has been outlawed after the incident on \[DATA EXPUNGED\]."
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	lube_kind = TURF_WET_SUPERLUBE


/datum/reagent/spraytan
	name = "Spray Tan"
	description = "A substance applied to the skin to darken the skin."
	color = "#FFC080" // rgb: 255, 196, 128  Bright orange
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 10 * REAGENTS_METABOLISM // very fast, so it can be applied rapidly.  But this changes on an overdose
	overdose_threshold = 11 //Slightly more than one un-nozzled spraybottle.
	taste_description = "sour oranges"


/datum/reagent/spraytan/expose_mob(mob/living/M, method=TOUCH, reac_volume, show_message = 1)
	if(ishuman(M))
		if(method == PATCH || method == VAPOR)
			var/mob/living/carbon/human/N = M
			if(N.dna.species.id == SPECIES_HUMAN)
				switch(N.skin_tone)
					if("african1")
						N.skin_tone = "african2"
					if("indian")
						N.skin_tone = "african1"
					if("arab")
						N.skin_tone = "indian"
					if("asian2")
						N.skin_tone = "arab"
					if("asian1")
						N.skin_tone = "asian2"
					if("mediterranean")
						N.skin_tone = "african1"
					if("latino")
						N.skin_tone = "mediterranean"
					if("caucasian3")
						N.skin_tone = "mediterranean"
					if("caucasian2")
						N.skin_tone = pick("caucasian3", "latino")
					if("caucasian1")
						N.skin_tone = "caucasian2"
					if ("albino")
						N.skin_tone = "caucasian1"

			if(MUTCOLORS in N.dna.species.species_traits) //take current alien color and darken it slightly
				var/newcolor = ""
				var/string = N.dna.features["mcolor"]
				var/len = length(string)
				var/char = ""
				var/ascii = 0
				for(var/i=1, i<=len, i += length(char))
					char = string[i]
					ascii = text2ascii(char)
					switch(ascii)
						if(48)
							newcolor += "0"
						if(49 to 57)
							newcolor += ascii2text(ascii-1)	//numbers 1 to 9
						if(97)
							newcolor += "9"
						if(98 to 102)
							newcolor += ascii2text(ascii-1)	//letters b to f lowercase
						if(65)
							newcolor += "9"
						if(66 to 70)
							newcolor += ascii2text(ascii+31)	//letters B to F - translates to lowercase
						else
							break
				if(ReadHSV(newcolor)[3] >= ReadHSV("#7F7F7F")[3])
					N.dna.features["mcolor"] = newcolor
			N.regenerate_icons()



		if(method == INGEST)
			if(show_message)
				to_chat(M, span_notice("That tasted horrible."))
	..()

/datum/reagent/spraytan/overdose_start(mob/living/M)
	metabolization_rate = 1 * REAGENTS_METABOLISM

	if(ishuman(M))
		var/mob/living/carbon/human/N = M
		N.hair_style = "Spiky"
		N.facial_hair_style = "Shaved"
		N.facial_hair_color = "000"
		N.hair_color = "000"
		if(!(HAIR in N.dna.species.species_traits)) //No hair? No problem!
			N.dna.species.species_traits += HAIR
		if(N.dna.species.use_skintones)
			N.skin_tone = "orange"
		else if(MUTCOLORS in N.dna.species.species_traits) //Aliens with custom colors simply get turned orange
			N.dna.features["mcolor"] = "f80"
		N.regenerate_icons()
	..()

/datum/reagent/spraytan/overdose_process(mob/living/M, delta_time, times_fired)
	if(ishuman(M))
		var/mob/living/carbon/human/N = M
		if(DT_PROB(3.5, delta_time))
			if(N.w_uniform)
				M.visible_message(pick("<b>[M]</b>'s collar pops up without warning.</span>", "<b>[M]</b> flexes [M.p_their()] arms."))
			else
				M.visible_message("<b>[M]</b> flexes [M.p_their()] arms.")
		if(DT_PROB(1, delta_time))
			M.say(pick("Shit was SO cash.", "Duuuuuude. Yeah bro.", "Check my muscles, broooo!", "Hell yeah brooo!"), forced = /datum/reagent/spraytan)

#define MUT_MSG_IMMEDIATE 1
#define MUT_MSG_EXTENDED 2
#define MUT_MSG_ABOUT2TURN 3

/datum/reagent/mutationtoxin
	name = "Stable Mutation Toxin"
	description = "A humanizing toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	chem_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_FUN
	metabolization_rate = 0.5 * REAGENTS_METABOLISM //metabolizes to prevent micro-dosage
	taste_description = "slime"
	var/race = /datum/species/human
	process_flags = ORGANIC | SYNTHETIC
	var/list/mutationtexts = list( "You don't feel very well." = MUT_MSG_IMMEDIATE,
									"Your skin feels a bit abnormal." = MUT_MSG_IMMEDIATE,
									"Your limbs begin to take on a different shape." = MUT_MSG_EXTENDED,
									"Your appendages begin morphing." = MUT_MSG_EXTENDED,
									"You feel as though you're about to change at any moment!" = MUT_MSG_ABOUT2TURN)
	var/cycles_to_turn = 20 //the current_cycle threshold / iterations needed before one can transform

/datum/reagent/mutationtoxin/on_mob_life(mob/living/carbon/human/H, delta_time, times_fired)
	. = TRUE
	if(!istype(H))
		return
	if(!(H.dna?.species) || !(H.mob_biotypes & MOB_ORGANIC))
		return

	if(DT_PROB(5, delta_time))
		var/list/pick_ur_fav = list()
		var/filter = NONE
		if(current_cycle <= (cycles_to_turn*0.3))
			filter = MUT_MSG_IMMEDIATE
		else if(current_cycle <= (cycles_to_turn*0.8))
			filter = MUT_MSG_EXTENDED
		else
			filter = MUT_MSG_ABOUT2TURN

		for(var/i in mutationtexts)
			if(mutationtexts[i] == filter)
				pick_ur_fav += i
		to_chat(H, span_warning("[pick(pick_ur_fav)]"))

	if(current_cycle >= cycles_to_turn)
		var/datum/species/species_type = pick(race) //this worked with the old code, somehow, and it works here...
		H.set_species(species_type)
		H.reagents.del_reagent(type)
		to_chat(H, span_warning("You've become \a [LOWER_TEXT(initial(species_type.name))]!"))
		return
	..()

/datum/reagent/mutationtoxin/classic //The one from plasma on green slimes
	name = "Mutation Toxin"
	description = "A corruptive toxin."
	color = "#13BC5E" // rgb: 19, 188, 94
	chem_flags = CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	race = /datum/species/oozeling/slime

/datum/reagent/mutationtoxin/unstable
	name = "Unstable Mutation Toxin"
	description = "A mostly safe mutation toxin."
	color = "#13BC5E" // rgb: 19, 188, 94
	chem_flags = CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	race = list(/datum/species/oozeling/slime,
						/datum/species/human,
						/datum/species/human/felinid,
						/datum/species/lizard,
						/datum/species/fly,
						/datum/species/moth,
						/datum/species/apid,
						/datum/species/oozeling,
						/datum/species/abductor,
						/datum/species/skeleton)

/datum/reagent/mutationtoxin/felinid
	name = "Felinid Mutation Toxin"
	color = "#5EFF3B" //RGB: 94, 255, 59
	chem_flags = CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	race = /datum/species/human/felinid
	taste_description = "something nyat good"

/datum/reagent/mutationtoxin/lizard
	name = "Lizard Mutation Toxin"
	description = "A lizarding toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	chem_flags = CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	race = /datum/species/lizard
	taste_description = "dragon's breath but not as cool"

/datum/reagent/mutationtoxin/fly
	name = "Fly Mutation Toxin"
	description = "An insectifying toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	chem_flags = CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	race = /datum/species/fly
	taste_description = "trash"

/datum/reagent/mutationtoxin/moth
	name = "Moth Mutation Toxin"
	description = "A glowing toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	chem_flags = CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	race = /datum/species/moth
	taste_description = "clothing"

/datum/reagent/mutationtoxin/apid
	name = "Apid Mutation Toxin"
	description = "A sweet-smelling toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	chem_flags = CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	race = /datum/species/apid
	taste_description = "honey"

/datum/reagent/mutationtoxin/diona //Admin only, besides maint pills because funny
	name = "Diona Mutation Toxin"
	description = "A vegetalizing toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	chem_flags = CHEMICAL_RNG_FUN
	race = /datum/species/diona
	taste_description = "flowers"

/datum/reagent/mutationtoxin/jelly
	name = "Imperfect Mutation Toxin"
	description = "A jellyfying toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	chem_flags = CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	race = list(/datum/species/oozeling/slime,
					/datum/species/oozeling/luminescent,
					/datum/species/oozeling/stargazer)
	taste_description = "grandma's gelatin"

/datum/reagent/mutationtoxin/golem
	name = "Golem Mutation Toxin"
	description = "A crystal toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	chem_flags = CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	race = /datum/species/golem/random
	taste_description = "rocks"

/datum/reagent/mutationtoxin/abductor
	name = "Abductor Mutation Toxin"
	description = "An alien toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	chem_flags = CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	race = /datum/species/abductor
	taste_description = "something out of this world... no, universe!"

/datum/reagent/mutationtoxin/ethereal
	name = "Ethereal Mutation Toxin"
	description = "A positively electric toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	chem_flags = CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	race = /datum/species/ethereal
	taste_description = "shocking"

/datum/reagent/mutationtoxin/oozeling
	name = "Oozeling Mutation Toxin"
	description = "An oozing toxin"
	color = "#611e80" //RGB: 97, 30, 128
	chem_flags = CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	race = /datum/species/oozeling
	taste_description = "burning ooze"

/datum/reagent/mutationtoxin/ipc
	name = "IPC Mutation Toxin"
	description = "A metallic toxin"
	color = "#5EFF3B"
	chem_flags = CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	race = /datum/species/ipc
	taste_description = "copper wire"

//BLACKLISTED RACES
/datum/reagent/mutationtoxin/skeleton
	name = "Skeleton Mutation Toxin"
	description = "A scary toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	chem_flags = CHEMICAL_RNG_FUN
	race = /datum/species/skeleton
	taste_description = "milk... and lots of it"

/datum/reagent/mutationtoxin/zombie
	name = "Zombie Mutation Toxin"
	description = "An undead toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	chem_flags = CHEMICAL_RNG_FUN
	race = /datum/species/zombie //Not the infectious kind. The days of xenobio zombie outbreaks are long past.
	taste_description = "brai...nothing in particular"

/datum/reagent/mutationtoxin/goofzombie
	name = "Zombie Mutation Toxin"
	description = "An undead toxin... kinda..."
	color = "#5EFF3B" //RGB: 94, 255, 59
	chem_flags = CHEMICAL_RNG_FUN
	race = /datum/species/human/krokodil_addict //Not the infectious kind. The days of xenobio zombie outbreaks are long past.
	taste_description = "krokodil"


/datum/reagent/mutationtoxin/ash
	name = "Ash Mutation Toxin"
	description = "An ashen toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	chem_flags = CHEMICAL_RNG_FUN
	race = /datum/species/lizard/ashwalker
	taste_description = "savagery"


//DANGEROUS RACES
/datum/reagent/mutationtoxin/shadow
	name = "Shadow Mutation Toxin"
	description = "A dark toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	chem_flags = CHEMICAL_RNG_FUN
	race = /datum/species/shadow
	taste_description = "the night"

/datum/reagent/mutationtoxin/plasma
	name = "Plasma Mutation Toxin"
	description = "A plasma-based toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	chem_flags = CHEMICAL_RNG_FUN
	race = /datum/species/plasmaman
	taste_description = "plasma"

/datum/reagent/mutationtoxin/psyphoza
	name = "Psyphoza Mutation Toxin"
	description = "A fungal-based toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	chem_flags = CHEMICAL_RNG_FUN
	race = /datum/species/psyphoza
	taste_description = "fungus"

#undef MUT_MSG_IMMEDIATE
#undef MUT_MSG_EXTENDED
#undef MUT_MSG_ABOUT2TURN

/datum/reagent/mulligan
	name = "Mulligan Toxin"
	description = "This toxin will rapidly change the DNA of human beings. Commonly used by Syndicate spies and assassins in need of an emergency ID change."
	color = "#5EFF3B" //RGB: 94, 255, 59
	chem_flags = CHEMICAL_RNG_FUN
	metabolization_rate = INFINITY
	taste_description = "slime"

/datum/reagent/mulligan/on_mob_life(mob/living/carbon/human/H, delta_time, times_fired)
	..()
	if (!istype(H))
		return
	to_chat(H, span_warning("<b>You grit your teeth in pain as your body rapidly mutates!</b>"))
	H.visible_message("<b>[H]</b> suddenly transforms!")
	randomize_human(H)

/datum/reagent/aslimetoxin
	name = "Advanced Mutation Toxin"
	description = "An advanced corruptive toxin produced by slimes."
	color = "#13BC5E" // rgb: 19, 188, 94
	chem_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_FUN
	taste_description = "slime"

/datum/reagent/aslimetoxin/expose_mob(mob/living/L, method=TOUCH, reac_volume)
	if(method != TOUCH)
		L.ForceContractDisease(new /datum/disease/transformation/slime(), FALSE, TRUE)

/datum/reagent/gluttonytoxin
	name = "Gluttony's Blessing"
	description = "An advanced corruptive toxin produced by something terrible."
	color = "#5EFF3B" //RGB: 94, 255, 59
	chem_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_FUN
	taste_description = "decay"

/datum/reagent/gluttonytoxin/expose_mob(mob/living/L, method=TOUCH, reac_volume)
	L.ForceContractDisease(new /datum/disease/transformation/morph(), FALSE, TRUE)

/datum/reagent/serotrotium
	name = "Serotrotium"
	description = "A chemical compound that promotes concentrated production of the serotonin neurotransmitter in humans."
	color = "#202040" // rgb: 20, 20, 40
	chem_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	taste_description = "bitterness"

/datum/reagent/serotrotium/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(ishuman(M))
		if(DT_PROB(3.5, delta_time))
			M.emote(pick("twitch","drool","moan","gasp"))
	..()

/datum/reagent/oxygen
	name = "Oxygen"
	description = "A colorless, odorless gas. Grows on trees but is still pretty valuable."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	chem_flags = CHEMICAL_BASIC_ELEMENT
	taste_mult = 0 // oderless and tasteless


/datum/reagent/oxygen/expose_obj(obj/O, reac_volume)
	if((!O) || (!reac_volume))
		return 0
	var/temp = holder ? holder.chem_temp : T20C
	O.atmos_spawn_air("o2=[reac_volume/2];TEMP=[temp]")

/datum/reagent/oxygen/expose_turf(turf/open/T, reac_volume)
	if(istype(T))
		var/temp = holder ? holder.chem_temp : T20C
		T.atmos_spawn_air("o2=[reac_volume/2];TEMP=[temp]")
	return

/datum/reagent/copper
	name = "Copper"
	description = "A highly ductile metal. Things made out of copper aren't very durable, but it makes a decent material for electrical wiring."
	reagent_state = SOLID
	color = "#6E3B08" // rgb: 110, 59, 8
	chem_flags = CHEMICAL_BASIC_ELEMENT
	taste_description = "metal"


/datum/reagent/copper/expose_obj(obj/O, reac_volume)
	if(istype(O, /obj/item/stack/sheet/iron))
		var/obj/item/stack/sheet/iron/M = O
		reac_volume = min(reac_volume, M.amount)
		new/obj/item/stack/sheet/bronze(get_turf(M), reac_volume)
		M.use(reac_volume)

/datum/reagent/nitrogen
	name = "Nitrogen"
	description = "A colorless, odorless, tasteless gas. A simple asphyxiant that can silently displace vital oxygen."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	chem_flags = CHEMICAL_BASIC_ELEMENT
	taste_mult = 0


/datum/reagent/nitrogen/expose_obj(obj/O, reac_volume)
	if((!O) || (!reac_volume))
		return 0
	var/temp = holder ? holder.chem_temp : T20C
	O.atmos_spawn_air("n2=[reac_volume/2];TEMP=[temp]")

/datum/reagent/nitrogen/expose_turf(turf/open/T, reac_volume)
	if(istype(T))
		var/temp = holder ? holder.chem_temp : T20C
		T.atmos_spawn_air("n2=[reac_volume/2];TEMP=[temp]")
	return

/datum/reagent/hydrogen
	name = "Hydrogen"
	description = "A colorless, odorless, nonmetallic, tasteless, highly combustible diatomic gas."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	chem_flags = CHEMICAL_BASIC_ELEMENT
	taste_mult = 0


/datum/reagent/potassium
	name = "Potassium"
	description = "A soft, low-melting solid that can easily be cut with a knife. Reacts violently with water."
	reagent_state = SOLID
	color = "#A0A0A0" // rgb: 160, 160, 160
	chem_flags = CHEMICAL_BASIC_ELEMENT
	taste_description = "sweetness"


/datum/reagent/mercury
	name = "Mercury"
	description = "A curious metal that's a liquid at room temperature. Neurodegenerative and very bad for the mind."
	color = "#484848" // rgb: 72, 72, 72A
	chem_flags = CHEMICAL_BASIC_ELEMENT | CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN // because brain damage is fun
	taste_mult = 0 // apparently tasteless.

/datum/reagent/mercury/lead_acetate
	name = "Lead Acetate"
	description = "A sweet neurotoxic chemical. The secret of Roman sweet wine."
	color = "#AAAAAA"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN // because brain damage is fun
	taste_description = "sweetness"
	taste_mult = 3

/datum/reagent/mercury/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(!HAS_TRAIT(src, TRAIT_IMMOBILIZED) && !isspaceturf(M.loc))
		step(M, pick(GLOB.cardinals))
	if(DT_PROB(3.5, delta_time))
		M.emote(pick("twitch","drool","moan"))
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.5*delta_time)
	..()

/datum/reagent/sulfur
	name = "Sulfur"
	description = "A sickly yellow solid mostly known for its nasty smell. It's actually much more helpful than it looks in biochemisty."
	reagent_state = SOLID
	color = "#BF8C00" // rgb: 191, 140, 0
	chem_flags = CHEMICAL_BASIC_ELEMENT
	taste_description = "rotten eggs"

/datum/reagent/carbon
	name = "Carbon"
	description = "A crumbly black solid that, while unexciting on a physical level, forms the base of all known life. Kind of a big deal."
	reagent_state = SOLID
	color = "#1C1300" // rgb: 30, 20, 0
	chem_flags = CHEMICAL_BASIC_ELEMENT
	taste_description = "sour chalk"

/datum/reagent/carbon/expose_turf(turf/T, reac_volume)
	if(!isspaceturf(T))
		var/obj/effect/decal/cleanable/dirt/D = locate() in T.contents
		if(!D)
			new /obj/effect/decal/cleanable/dirt(T)

/datum/reagent/chlorine
	name = "Chlorine"
	description = "A pale yellow gas that's well known as an oxidizer. While it forms many harmless molecules in its elemental form it is far from harmless."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	chem_flags = CHEMICAL_BASIC_ELEMENT
	taste_description = "chlorine"

/datum/reagent/chlorine/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.take_bodypart_damage(0.5*REM*delta_time, 0, 0, 0)
	. = TRUE
	..()

/datum/reagent/fluorine
	name = "Fluorine"
	description = "A comically-reactive chemical element. The universe does not want this stuff to exist in this form in the slightest."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	chem_flags = CHEMICAL_BASIC_ELEMENT
	taste_description = "acid"
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/fluorine/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.adjustToxLoss(0.5*REM*delta_time, 0)
	. = TRUE
	..()

/datum/reagent/sodium
	name = "Sodium"
	description = "A soft silver metal that can easily be cut with a knife. It's not salt just yet, so refrain from putting in on your chips."
	reagent_state = SOLID
	color = "#808080" // rgb: 128, 128, 128
	chem_flags = CHEMICAL_BASIC_ELEMENT
	taste_description = "salty metal"

/datum/reagent/phosphorus
	name = "Phosphorus"
	description = "A ruddy red powder that burns readily. Though it comes in many colors, the general theme is always the same."
	reagent_state = SOLID
	color = "#832828" // rgb: 131, 40, 40
	chem_flags = CHEMICAL_BASIC_ELEMENT
	taste_description = "vinegar"

/datum/reagent/lithium
	name = "Lithium"
	description = "A silver metal, its claim to fame is its remarkably low density. Using it is a bit too effective in calming oneself down."
	reagent_state = SOLID
	color = "#808080" // rgb: 128, 128, 128
	chem_flags = CHEMICAL_BASIC_ELEMENT | CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN // because it is fun
	taste_description = "metal"

/datum/reagent/lithium/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(!HAS_TRAIT(M, TRAIT_IMMOBILIZED) && !isspaceturf(M.loc) && isturf(M.loc))
		step(M, pick(GLOB.cardinals))
	if(DT_PROB(2.5, delta_time))
		M.emote(pick("twitch","drool","moan"))
	..()

/datum/reagent/glycerol
	name = "Glycerol"
	description = "Glycerol is a simple polyol compound. Glycerol is sweet-tasting and of low toxicity."
	color = "#808080" // rgb: 128, 128, 128
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST
	taste_description = "sweetness"

/datum/reagent/space_cleaner/sterilizine
	name = "Sterilizine"
	description = "Sterilizes wounds in preparation for surgery."
	color = "#C8A5DC" // rgb: 200, 165, 220
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "bitterness"

/datum/reagent/space_cleaner/sterilizine/expose_mob(mob/living/carbon/C, method=TOUCH, reac_volume)
	if(method in list(TOUCH, VAPOR, PATCH))
		for(var/s in C.surgeries)
			var/datum/surgery/S = s
			S.speed_modifier = max(0.2, S.speed_modifier)
			// +20% surgery speed on each step, useful while operating in less-than-perfect conditions
	..()

/datum/reagent/iron
	name = "Iron"
	description = "Pure iron is a metal."
	color = "#C8A5DC" // rgb: 200, 165, 220
	chem_flags = CHEMICAL_BASIC_ELEMENT
	reagent_state = SOLID
	taste_description = "iron"


/datum/reagent/iron/on_mob_life(mob/living/carbon/C, delta_time, times_fired)
	if(C.blood_volume < BLOOD_VOLUME_NORMAL)
		C.blood_volume += 0.25 * delta_time
	..()

/datum/reagent/gold
	name = "Gold"
	description = "Gold is a dense, soft, shiny metal and the most malleable and ductile metal known."
	reagent_state = SOLID
	color = "#F7C430" // rgb: 247, 196, 48
	chem_flags = CHEMICAL_RNG_BOTANY
	taste_description = "expensive metal"

/datum/reagent/silver
	name = "Silver"
	description = "A soft, white, lustrous transition metal, it has the highest electrical conductivity of any element and the highest thermal conductivity of any metal."
	reagent_state = SOLID
	color = "#D0D0D0" // rgb: 208, 208, 208
	chem_flags = CHEMICAL_BASIC_ELEMENT
	taste_description = "expensive yet reasonable metal"

/datum/reagent/uranium
	name ="Uranium"
	description = "A silvery-white metallic chemical element in the actinide series, weakly radioactive."
	reagent_state = SOLID
	color = "#B8B8C0" // rgb: 184, 184, 192
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "the inside of a reactor"
	var/irradiation_level = 0.5*REM
	process_flags = ORGANIC | SYNTHETIC
	default_container = /obj/effect/decal/cleanable/greenglow

/datum/reagent/uranium/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.apply_effect(irradiation_level*delta_time/M.metabolism_efficiency, EFFECT_IRRADIATE,0)
	..()

/datum/reagent/uranium/expose_turf(turf/T, reac_volume)
	if(reac_volume >= 3)
		if(!isspaceturf(T))
			var/obj/effect/decal/cleanable/greenglow/GG = locate() in T.contents
			if(!GG)
				GG = new/obj/effect/decal/cleanable/greenglow(T)
			if(!QDELETED(GG))
				GG.reagents.add_reagent(type, reac_volume)

/datum/reagent/uranium/radium
	name = "Radium"
	description = "Radium is an alkaline earth metal. It is extremely radioactive."
	reagent_state = SOLID
	color = "#C7C7C7" // rgb: 199,199,199
	chem_flags = CHEMICAL_BASIC_ELEMENT
	taste_description = "the colour blue and regret"
	irradiation_level = 1*REM
	process_flags = ORGANIC | SYNTHETIC


/datum/reagent/bluespace
	name = "Bluespace Dust"
	description = "A dust composed of microscopic bluespace crystals, with minor space-warping properties."
	reagent_state = SOLID
	color = "#0000CC"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "fizzling blue"
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/bluespace/expose_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == TOUCH || method == VAPOR)
		do_teleport(M, get_turf(M), (reac_volume / 5), asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE) //4 tiles per crystal
	..()

/datum/reagent/bluespace/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(current_cycle > 10 && DT_PROB(7.5, delta_time))
		to_chat(M, span_warning("You feel unstable..."))
		M.Jitter(2)
		current_cycle = 1
		addtimer(CALLBACK(M, TYPE_PROC_REF(/mob/living, bluespace_shuffle)), 30)
	..()

/mob/living/proc/bluespace_shuffle()
	do_teleport(src, get_turf(src), 5, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)

/datum/reagent/aluminium
	name = "Aluminium"
	description = "A silvery white and ductile member of the boron group of chemical elements."
	reagent_state = SOLID
	color = "#A8A8A8" // rgb: 168, 168, 168
	chem_flags = CHEMICAL_BASIC_ELEMENT
	taste_description = "metal"


/datum/reagent/silicon
	name = "Silicon"
	description = "A tetravalent metalloid, silicon is less reactive than its chemical analog carbon."
	reagent_state = SOLID
	color = "#A8A8A8" // rgb: 168, 168, 168
	chem_flags = CHEMICAL_BASIC_ELEMENT
	taste_mult = 0


/datum/reagent/fuel
	name = "Welding Fuel"
	description = "Required for welders. Flammable."
	color = "#660000" // rgb: 102, 0, 0
	chem_flags = CHEMICAL_BASIC_ELEMENT
	taste_description = "gross metal"
	process_flags = ORGANIC | SYNTHETIC

/datum/glass_style/drinking_glass/fuel
	required_drink_type = /datum/reagent/fuel
	name = "glass of welder fuel"
	desc = "Unless you're an industrial tool, this is probably not safe for consumption."
	icon_state = "dr_gibb_glass"

/datum/reagent/fuel/expose_mob(mob/living/M, method=TOUCH, reac_volume)//Splashing people with welding fuel to make them easy to ignite!
	if(method == TOUCH || method == VAPOR)
		M.adjust_fire_stacks(reac_volume / 10)
		return
	..()

/datum/reagent/fuel/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.adjustToxLoss(0.5*delta_time, 0)
	..()
	return TRUE

/datum/reagent/space_cleaner
	name = "Space Cleaner"
	description = "A compound used to clean things. Now with 50% more sodium hypochlorite! Not safe for consumption. If ingested, contact poison control immediately"
	color = "#A5F0EE" // rgb: 165, 240, 238
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST
	taste_description = "sourness"
	reagent_weight = 0.6 //so it sprays further
	var/clean_types = CLEAN_WASH
	var/toxic = FALSE //turn to true if someone drinks this, so it won't poison people who are simply getting sprayed down

/datum/reagent/space_cleaner/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(toxic)//don't drink space cleaner, dumbass
		M.adjustToxLoss(1 * REM * delta_time, FALSE)
	..()
	return TRUE

/datum/reagent/space_cleaner/expose_obj(obj/O, reac_volume)
	O?.wash(clean_types)

/datum/reagent/space_cleaner/expose_turf(turf/T, reac_volume)
	if(reac_volume < 1)
		return

	T.wash(clean_types)
	for(var/am in T)
		var/atom/movable/movable_content = am
		if(ismopable(movable_content)) // Mopables will be cleaned anyways by the turf wash
			continue
		movable_content.wash(clean_types)

	for(var/mob/living/simple_animal/slime/M in T)
		M.adjustToxLoss(rand(5,10))

/datum/reagent/space_cleaner/expose_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == TOUCH || method == VAPOR)
		M.wash(clean_types)
	else if(method == INGEST || method == INJECT) //why the fuck did you drink space cleaner you fucking buffoon
		toxic = TRUE

/datum/reagent/space_cleaner/ez_clean
	name = "EZ Clean"
	description = "A powerful, acidic cleaner sold by Waffle Co. Affects organic matter while leaving other objects unaffected."
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	taste_description = "acid"

/datum/reagent/space_cleaner/ez_clean/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.adjustBruteLoss(1.665*delta_time)
	M.adjustFireLoss(1.665*delta_time)
	M.adjustToxLoss(1.665*delta_time)
	..()

/datum/reagent/space_cleaner/ez_clean/expose_mob(mob/living/M, method=TOUCH, reac_volume)
	..()
	if((method == TOUCH || method == VAPOR) && !issilicon(M))
		M.adjustBruteLoss(1.5)
		M.adjustFireLoss(1.5)

/datum/reagent/cryptobiolin
	name = "Cryptobiolin"
	description = "Cryptobiolin causes confusion and dizziness."
	color = "#C8A5DC" // rgb: 200, 165, 220
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	taste_description = "sourness"

/datum/reagent/cryptobiolin/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.Dizzy(1)
	if(!M.confused)
		M.confused = 1
	M.confused = max(M.confused, 20)
	..()

/datum/reagent/impedrezene
	name = "Impedrezene"
	description = "Impedrezene is a narcotic that impedes one's ability by slowing down the higher brain cell functions."
	color = "#C8A5DC" // rgb: 200, 165, 220A
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "numbness"

/datum/reagent/impedrezene/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.jitteriness = max(M.jitteriness - (2.5*delta_time),0)
	if(DT_PROB(55, delta_time))
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2)
	if(DT_PROB(30, delta_time))
		M.drowsyness = max(M.drowsyness, 3)
	if(DT_PROB(5, delta_time))
		M.emote("drool")
	..()

/datum/reagent/nanomachines
	name = "Nanomachines"
	description = "Microscopic construction robots."
	color = "#535E66" // rgb: 83, 94, 102
	chem_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_FUN
	taste_description = "sludge"

/datum/reagent/nanomachines/expose_mob(mob/living/L, method=TOUCH, reac_volume, show_message = 1, touch_protection = 0)
	if(method==PATCH || method==INGEST || method==INJECT || (method == VAPOR && prob(min(reac_volume,100)*(1 - touch_protection))))
		L.ForceContractDisease(new /datum/disease/transformation/robot(), FALSE, TRUE)

/datum/reagent/xenomicrobes
	name = "Xenomicrobes"
	description = "Microbes with an entirely alien cellular structure."
	color = "#535E66" // rgb: 83, 94, 102
	chem_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_FUN
	taste_description = "sludge"

/datum/reagent/xenomicrobes/expose_mob(mob/living/L, method=TOUCH, reac_volume, show_message = 1, touch_protection = 0)
	if(method==PATCH || method==INGEST || method==INJECT || (method == VAPOR && prob(min(reac_volume,100)*(1 - touch_protection))))
		L.ForceContractDisease(new /datum/disease/transformation/xeno(), FALSE, TRUE)

/datum/reagent/fungalspores
	name = "Tubercle bacillus Cosmosis microbes"
	description = "Active fungal spores."
	color = "#92D17D" // rgb: 146, 209, 125
	chem_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_FUN
	taste_description = "slime"


/datum/reagent/fungalspores/expose_mob(mob/living/L, method=TOUCH, reac_volume, show_message = 1, touch_protection = 0)
	if(method==PATCH || method==INGEST || method==INJECT || (method == VAPOR && prob(min(reac_volume,100)*(1 - touch_protection))))
		L.ForceContractDisease(new /datum/disease/tuberculosis(), FALSE, TRUE)

/datum/reagent/snail
	name = "Agent-S"
	description = "Virological agent that infects the subject with Gastrolosis."
	color = "#003300" // rgb(0, 51, 0)
	chem_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_FUN
	taste_description = "goo"

/datum/reagent/snail/expose_mob(mob/living/L, method=TOUCH, reac_volume, show_message = 1, touch_protection = 0)
	if(method==PATCH || method==INGEST || method==INJECT || (method == VAPOR && prob(min(reac_volume,100)*(1 - touch_protection))))
		L.ForceContractDisease(new /datum/disease/gastrolosis(), FALSE, TRUE)

/datum/reagent/fluorosurfactant//foam precursor
	name = "Fluorosurfactant"
	description = "A perfluoronated sulfonic acid that forms a foam when mixed with water."
	color = "#9E6B38" // rgb: 158, 107, 56
	chem_flags = NONE
	taste_description = "metal"

/datum/reagent/foaming_agent// Metal foaming agent. This is lithium hydride. Add other recipes (e.g. LiH + H2O -> LiOH + H2) eventually.
	name = "Foaming agent"
	description = "An agent that yields metallic foam when mixed with light metal and a strong acid."
	reagent_state = SOLID
	color = "#664B63" // rgb: 102, 75, 99
	chem_flags = NONE
	taste_description = "metal"

/datum/reagent/smart_foaming_agent //Smart foaming agent. Functions similarly to metal foam, but conforms to walls.
	name = "Smart foaming agent"
	description = "An agent that yields metallic foam which conforms to area boundaries when mixed with light metal and a strong acid."
	reagent_state = SOLID
	color = "#664B63" // rgb: 102, 75, 99
	chem_flags = NONE
	taste_description = "metal"

/datum/reagent/ammonia
	name = "Ammonia"
	description = "A caustic substance commonly used in fertilizer or household cleaners."
	reagent_state = GAS
	color = "#404030" // rgb: 64, 64, 48
	chem_flags = NONE
	taste_description = "mordant"

/datum/reagent/diethylamine
	name = "Diethylamine"
	description = "A secondary amine, mildly corrosive."
	color = "#604030" // rgb: 96, 64, 48
	chem_flags = NONE
	taste_description = "iron"

/datum/reagent/carbondioxide
	name = "Carbon Dioxide"
	reagent_state = GAS
	description = "A gas commonly produced by burning carbon fuels. You're constantly producing this in your lungs."
	color = "#B0B0B0" // rgb : 192, 192, 192
	chem_flags = NONE
	taste_description = "something unknowable"

/datum/reagent/carbondioxide/expose_obj(obj/O, reac_volume)
	if((!O) || (!reac_volume))
		return 0
	var/temp = holder ? holder.chem_temp : T20C
	O.atmos_spawn_air("co2=[reac_volume/5];TEMP=[temp]")

/datum/reagent/carbondioxide/expose_turf(turf/open/T, reac_volume)
	if(istype(T))
		var/temp = holder ? holder.chem_temp : T20C
		T.atmos_spawn_air("co2=[reac_volume/5];TEMP=[temp]")
	return

/datum/reagent/nitrous_oxide
	name = "Nitrous Oxide"
	description = "A potent oxidizer used as fuel in rockets and as an anaesthetic during surgery."
	reagent_state = LIQUID
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	color = "#808080"
	chem_flags = NONE
	taste_description = "sweetness"

/datum/reagent/nitrous_oxide/expose_obj(obj/O, reac_volume)
	if((!O) || (!reac_volume))
		return 0
	var/temp = holder ? holder.chem_temp : T20C
	O.atmos_spawn_air("n2o=[reac_volume/5];TEMP=[temp]")

/datum/reagent/nitrous_oxide/expose_turf(turf/open/T, reac_volume)
	if(istype(T))
		var/temp = holder ? holder.chem_temp : T20C
		T.atmos_spawn_air("n2o=[reac_volume/5];TEMP=[temp]")

/datum/reagent/nitrous_oxide/expose_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == VAPOR)
		M.drowsyness += max(round(reac_volume, 1), 2)

/datum/reagent/nitrous_oxide/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.drowsyness += 2 * REM * delta_time
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.blood_volume = max(H.blood_volume - (10 * REM * delta_time), 0)
	if(DT_PROB(10, delta_time))
		M.losebreath += 2
		M.confused = min(M.confused + 2, 5)
	..()

/datum/reagent/nitrium_high_metabolization
	name = "Nitrosyl plasmide"
	description = "A highly reactive byproduct that stops you from sleeping, while dealing increasing toxin damage over time."
	reagent_state = GAS
	metabolization_rate = REAGENTS_METABOLISM * 0.5 // Because nitrium are handled through gas breathing, metabolism must be lower for breathcode to keep up
	color = "#E1A116"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "sourness"
	///stores whether or not the mob has been warned that they are having difficulty breathing.
	var/warned = FALSE

/datum/reagent/nitrium_high_metabolization/on_mob_metabolize(mob/living/L)
	. = ..()
	ADD_TRAIT(L, TRAIT_STUNIMMUNE, type)
	ADD_TRAIT(L, TRAIT_SLEEPIMMUNE, type)
	ADD_TRAIT(L, TRAIT_IGNOREDAMAGESLOWDOWN, type)
	ADD_TRAIT(L, TRAIT_NOSTAMCRIT, type)
	ADD_TRAIT(L, TRAIT_NOLIMBDISABLE, type)
	L.visible_message(span_warning("You feel like nothing can stop you!"))

/datum/reagent/nitrium_high_metabolization/on_mob_end_metabolize(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_STUNIMMUNE, type)
	REMOVE_TRAIT(L, TRAIT_SLEEPIMMUNE, type)
	REMOVE_TRAIT(L, TRAIT_IGNOREDAMAGESLOWDOWN, type)
	REMOVE_TRAIT(L, TRAIT_NOSTAMCRIT, type)
	REMOVE_TRAIT(L, TRAIT_NOLIMBDISABLE, type)
	L.visible_message(span_warning("You can feel your brief high wearing off"))
	return ..()

/datum/reagent/nitrium_high_metabolization/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.adjustStaminaLoss(-2 * REM * delta_time, 0)
	if(M.losebreath <= 10)
		M.losebreath += min(current_cycle*0.05, 2) // gradually builds up suffocation, will not be noticeable for several ticks but effects will linger afterwards
	if(M.losebreath > 2 && !warned)
		M.visible_message(span_danger("You feel like you can't breathe!"))
		warned = TRUE
	return ..()

/datum/reagent/nitrium_low_metabolization
	name = "Nitrium"
	description = "A highly reactive gas that makes you feel faster."
	reagent_state = GAS
	metabolization_rate = REAGENTS_METABOLISM * 0.5 // Because nitrium are handled through gas breathing, metabolism must be lower for breathcode to keep up
	color = "#90560B"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "burning"

/datum/reagent/nitrium_low_metabolization/on_mob_metabolize(mob/living/L)
	. = ..()
	L.add_movespeed_modifier(/datum/movespeed_modifier/reagent/nitrium)

/datum/reagent/nitrium_low_metabolization/on_mob_end_metabolize(mob/living/L)
	L.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/nitrium)
	return ..()

/////////////////////////Colorful Powder////////////////////////////
//For colouring in /proc/mix_color_from_reagents

/datum/reagent/colorful_reagent/powder
	name = "Mundane Powder" //the name's a bit similar to the name of colorful reagent, but hey, they're practically the same chem anyway
	var/colorname = "none"
	description = "A powder that is used for coloring things."
	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 207, 54, 0
	color_intensity = 50
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "the back of class"

/datum/reagent/colorful_reagent/powder/New()
	if(colorname == "none")
		description = "A rather mundane-looking powder. It doesn't look like it'd color much of anything."
	else if(colorname == "invisible")
		description = "An invisible powder. Unfortunately, since it's invisible, it doesn't look like it'd color much of anything."
	else
		description = "\An [colorname] powder, used for coloring things [colorname]."

/datum/reagent/colorful_reagent/powder/red
	name = "Red Dye Powder"
	colorname = "red"
	color = "#DA0000" // red
	random_color_list = list("#FC7474")

/datum/reagent/colorful_reagent/powder/orange
	name = "Orange Dye Powder"
	colorname = "orange"
	color = "#FF9300" // orange
	random_color_list = list("#FF9300")

/datum/reagent/colorful_reagent/powder/yellow
	name = "Yellow Dye Powder"
	colorname = "yellow"
	color = "#FFF200" // yellow
	random_color_list = list("#FFF200")

/datum/reagent/colorful_reagent/powder/green
	name = "Green Dye Powder"
	colorname = "green"
	color = "#A8E61D" // green
	random_color_list = list("#A8E61D")

/datum/reagent/colorful_reagent/powder/blue
	name = "Blue Dye Powder"
	colorname = "blue"
	color = "#00B7EF" // blue
	random_color_list = list("#00B7EF")

/datum/reagent/colorful_reagent/powder/purple
	name = "Purple Dye Powder"
	colorname = "purple"
	color = "#DA00FF" // purple
	random_color_list = list("#BD8FC4")

/datum/reagent/colorful_reagent/powder/invisible
	name = "Invisible Dye Powder"
	colorname = "invisible"
	color = "#FFFFFF00" // white + no alpha
	random_color_list = list(null)	//because using the powder color turns things invisible

/datum/reagent/colorful_reagent/powder/black
	name = "Black Dye Powder"
	colorname = "black"
	color = "#1C1C1C" // not quite black
	random_color_list = list("#404040")

/datum/reagent/colorful_reagent/powder/white
	name = "White Dye Powder"
	colorname = "white"
	color = "#FFFFFF" // white
	random_color_list = list("#FFFFFF") //doesn't actually change appearance at all

/* used by crayons, can't color living things but still used for stuff like food recipes */

/datum/reagent/colorful_reagent/powder/red/crayon
	name = "Red Crayon Powder"
	chem_flags = NONE
	can_colour_mobs = FALSE

/datum/reagent/colorful_reagent/powder/orange/crayon
	name = "Orange Crayon Powder"
	chem_flags = NONE
	can_colour_mobs = FALSE

/datum/reagent/colorful_reagent/powder/yellow/crayon
	name = "Yellow Crayon Powder"
	chem_flags = NONE
	can_colour_mobs = FALSE

/datum/reagent/colorful_reagent/powder/green/crayon
	name = "Green Crayon Powder"
	chem_flags = NONE
	can_colour_mobs = FALSE

/datum/reagent/colorful_reagent/powder/blue/crayon
	name = "Blue Crayon Powder"
	chem_flags = NONE
	can_colour_mobs = FALSE

/datum/reagent/colorful_reagent/powder/purple/crayon
	name = "Purple Crayon Powder"
	chem_flags = NONE
	can_colour_mobs = FALSE

//datum/reagent/colorful_reagent/powder/invisible/crayon

/datum/reagent/colorful_reagent/powder/black/crayon
	name = "Black Crayon Powder"
	chem_flags = NONE
	can_colour_mobs = FALSE

/datum/reagent/colorful_reagent/powder/white/crayon
	name = "White Crayon Powder"
	chem_flags = NONE
	can_colour_mobs = FALSE

//////////////////////////////////Hydroponics stuff///////////////////////////////

/datum/reagent/plantnutriment
	name = "Generic nutriment"
	description = "Some kind of nutriment. You can't really tell what it is. You should probably report it, along with how you obtained it."
	color = "#000000" // RBG: 0, 0, 0
	chem_flags = CHEMICAL_NOT_DEFINED // this shouldn't exist
	var/tox_prob = 0
	taste_description = "plant food"

/datum/reagent/plantnutriment/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(DT_PROB(tox_prob, delta_time))
		M.adjustToxLoss(1, 0)
		. = TRUE
	..()
/datum/reagent/plantnutriment/eznutriment
	name = "E-Z-Nutrient"
	description = "Cheap and extremely common type of plant nutriment."
	color = "#376400" // RBG: 50, 100, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	tox_prob = 5

/datum/reagent/plantnutriment/left4zednutriment
	name = "Left 4 Zed"
	description = "Unstable nutriment that makes plants mutate more often than usual."
	color = "#1A1E4D" // RBG: 26, 30, 77
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	tox_prob = 13

/datum/reagent/plantnutriment/robustharvestnutriment
	name = "Robust Harvest"
	description = "Very potent nutriment that prevents plants from mutating."
	color = "#9D9D00" // RBG: 157, 157, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	tox_prob = 8

/datum/reagent/plantnutriment/slimenutriment
	name = "Living Fertiliser"
	description = "A viscous fluid that clings to living tissue and speeds up growth, in exchange for yield."
	color = "#6ed8db"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	tox_prob = 17




// GOON OTHERS



/datum/reagent/oil
	name = "Oil"
	description = "Burns in a small smoky fire, mostly used to get Ash."
	reagent_state = LIQUID
	color = "#C8A5DC"
	chem_flags = CHEMICAL_BASIC_ELEMENT
	taste_description = "oil"
	process_flags = ORGANIC | SYNTHETIC
	default_container = /obj/effect/decal/cleanable/oil

/datum/reagent/stable_plasma
	name = "Stable Plasma"
	description = "Non-flammable plasma locked into a liquid form that cannot ignite or become gaseous/solid."
	reagent_state = LIQUID
	color = "#C8A5DC"
	chem_flags = CHEMICAL_BASIC_ELEMENT
	taste_description = "bitterness"
	taste_mult = 1.5
	process_flags = ORGANIC | SYNTHETIC


/datum/reagent/stable_plasma/on_mob_life(mob/living/carbon/C, delta_time, times_fired)
	C.adjustPlasma(10 * REM * delta_time)
	..()

/datum/reagent/iodine
	name = "Iodine"
	description = "Commonly added to table salt as a nutrient. On its own it tastes far less pleasing."
	reagent_state = LIQUID
	color = "#C8A5DC"
	chem_flags = CHEMICAL_BASIC_ELEMENT
	taste_description = "metal"

/datum/reagent/carpet
	name = "Carpet"
	description = "For those that need a more creative way to roll out a red carpet."
	reagent_state = LIQUID
	color = "#771100" //The color of the average carpet! Carpets are brown, not pink!
	chem_flags = NONE //Way too many of these to be fair to the bartender!
	taste_description = "carpet" // Your tongue feels furry.
	var/carpet_type = /turf/open/floor/carpet

/datum/reagent/carpet/expose_turf(turf/T, reac_volume)
	if(isplatingturf(T) || istype(T, /turf/open/floor/iron))
		var/turf/open/floor/F = T
		F.PlaceOnTop(carpet_type, flags = CHANGETURF_INHERIT_AIR)
	..()

/datum/reagent/carpet/black
	name = "Black Carpet"
	description = "The carpet also comes in... BLAPCK" //yes, the typo is intentional
	color = "#1E1E1E"
	taste_description = "licorice"
	carpet_type = /turf/open/floor/carpet/black

/datum/reagent/carpet/blue
	name = "Blue Carpet"
	description = "For those that really need to chill out for a while."
	color = "#0000DC"
	taste_description = "frozen carpet"
	carpet_type = /turf/open/floor/carpet/blue

/datum/reagent/carpet/cyan
	name = "Cyan Carpet"
	description = "For those that need a throwback to the years of using poison as a construction material. Smells like asbestos."
	color = "#00B4FF"
	taste_description = "asbestos"
	carpet_type = /turf/open/floor/carpet/cyan

/datum/reagent/carpet/green
	name = "Green Carpet"
	description = "For those that need the perfect flourish for your green eggs and ham."
	color = "#A8E61D"
	taste_description = "Green" //the caps is intentional
	carpet_type = /turf/open/floor/carpet/green

/datum/reagent/carpet/orange
	name = "Orange Carpet"
	description = "For those that prefer a healthy carpet to go along with their healthy diet."
	color = "#E78108"
	taste_description = "orange juice"
	carpet_type = /turf/open/floor/carpet/orange

/datum/reagent/carpet/purple
	name = "Purple Carpet"
	description = "For those that need to waste copious amounts of healing jelly in order to look fancy."
	color = "#91D865"
	taste_description = "jelly"
	carpet_type = /turf/open/floor/carpet/purple

/datum/reagent/carpet/red
	name = "Red Carpet"
	description = "For those that need an even redder carpet."
	color = "#731008"
	taste_description = "blood and gibs"
	carpet_type = /turf/open/floor/carpet/red

/datum/reagent/carpet/royal
	name = "Royal Carpet?"
	description = "For those that break the game and need to make an issue report."

/datum/reagent/carpet/royal/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	. = ..()
	if(!M.mind?.assigned_role)
		return
	switch(M.mind.assigned_role)
		if("Chief Medical Officer", "Captain", "Chief Engineer", "Research Director", "Head of Personnel")
			if(DT_PROB(5, delta_time))
				to_chat(M, "You feel like royalty.")
			if(DT_PROB(2.5, delta_time))
				M.say(pick("Peasants..","This carpet is worth more than your contracts!","I could fire you at any time..."), forced = "royal carpet")
		if("Quartermaster")
			if(DT_PROB(8, delta_time))
				to_chat(M, "You feel like an impostor...")

/datum/reagent/carpet/royal/black
	name = "Royal Black Carpet"
	description = "For those that feel the need to show off their timewasting skills."
	color = "#000000"
	taste_description = "royalty"
	carpet_type = /turf/open/floor/carpet/royalblack

/datum/reagent/carpet/royal/blue
	name = "Royal Blue Carpet"
	description = "For those that feel the need to show off their timewasting skills.. in BLUE."
	color = "#5A64C8"
	taste_description = "blueyalty" //also intentional
	carpet_type = /turf/open/floor/carpet/royalblue

/datum/reagent/bromine
	name = "Bromine"
	description = "A brownish liquid that's highly reactive. Useful for stopping free radicals, but not intended for human consumption."
	reagent_state = LIQUID
	color = "#C8A5DC"
	chem_flags = CHEMICAL_BASIC_ELEMENT
	taste_description = "chemicals"

/datum/reagent/phenol
	name = "Phenol"
	description = "An aromatic ring of carbon with a hydroxyl group. A useful precursor to some medicines, but has no healing properties on its own."
	reagent_state = LIQUID
	color = "#C8A5DC"
	chem_flags = CHEMICAL_RNG_BOTANY
	taste_description = "acid"

/datum/reagent/ash
	name = "Ash"
	description = "Phoenixes supposedly rise from this, but you've never seen it."
	reagent_state = LIQUID
	color = "#C8A5DC"
	chem_flags = CHEMICAL_RNG_BOTANY
	taste_description = "ash"
	default_container = /obj/effect/decal/cleanable/ash

/datum/reagent/acetone
	name = "Acetone"
	description = "A slick liquid with carcinogenic properties. Has a multitude of mundane uses in everyday life."
	reagent_state = LIQUID
	color = "#C8A5DC"
	chem_flags = CHEMICAL_RNG_BOTANY
	taste_description = "acid"

/datum/reagent/colorful_reagent
	name = "Colorful Reagent"
	description = "Thoroughly sample the rainbow."
	reagent_state = LIQUID
	color = "#C8A5DC"
	var/list/random_color_list = list("#00aedb","#a200ff","#f47835","#d41243","#d11141","#00b159","#00aedb","#f37735","#ffc425","#008744","#0057e7","#d62d20","#ffa700")
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "rainbows"
	var/can_colour_mobs = TRUE


/datum/reagent/colorful_reagent/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(can_colour_mobs)
		M.add_atom_colour(pick(random_color_list), WASHABLE_COLOUR_PRIORITY)
	return ..()

/// Colors anything it touches a random color.
/datum/reagent/colorful_reagent/expose_atom(mob/living/M, reac_volume)
	if(can_colour_mobs)
		M.add_atom_colour(pick(random_color_list), WASHABLE_COLOUR_PRIORITY)
	..()

/datum/reagent/hair_dye
	name = "Quantum Hair Dye"
	description = "Has a high chance of making you look like a mad scientist."
	reagent_state = LIQUID
	color = "#C8A5DC"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	var/list/potential_colors = list("0ad","a0f","f73","d14","d14","0b5","0ad","f73","fc2","084","05e","d22","fa0") // fucking hair code // someone forgot how hair_color is programmed
	taste_description = "sourness"

/datum/reagent/hair_dye/expose_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == TOUCH || method == VAPOR)
		if(M && ishuman(M))
			var/mob/living/carbon/human/H = M
			H.hair_color = pick(potential_colors)
			H.facial_hair_color = pick(potential_colors)
			H.update_hair()

/datum/reagent/barbers_aid
	name = "Barber's Aid"
	description = "A solution to hair loss across the world."
	reagent_state = LIQUID
	color = "#C8A5DC"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST
	taste_description = "sourness"

/datum/reagent/barbers_aid/expose_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == TOUCH || method == VAPOR)
		if(M && ishuman(M))
			var/mob/living/carbon/human/H = M
			var/datum/sprite_accessory/hair/picked_hair = pick(GLOB.hair_styles_list)
			var/datum/sprite_accessory/facial_hair/picked_beard = pick(GLOB.facial_hair_styles_list)
			H.hair_style = picked_hair.name
			H.facial_hair_style = picked_beard
			H.update_hair()

/datum/reagent/concentrated_barbers_aid
	name = "Concentrated Barber's Aid"
	description = "A concentrated solution to hair loss across the world."
	reagent_state = LIQUID
	color = "#C8A5DC"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST
	taste_description = "sourness"

/datum/reagent/concentrated_barbers_aid/expose_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == TOUCH || method == VAPOR)
		if(M && ishuman(M))
			var/mob/living/carbon/human/H = M
			H.hair_style = "Very Long Hair"
			H.facial_hair_style = "Beard (Very Long)"
			H.update_hair()

/datum/reagent/barbers_afro_mania
	name = "Barber's Afro Mania"
	description = "Unleash the funk within you."
	reagent_state = LIQUID
	color = "#FF8800"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "funky sugar"

/datum/reagent/barbers_afro_mania/expose_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == TOUCH || method == VAPOR)
		if(M && ishuman(M))
			var/mob/living/carbon/human/H = M
			H.hair_style = "Afro (Large)"
			H.update_hair()

/datum/reagent/barbers_shaving_aid
	name = "Barber's Shaving Aid"
	description = "It seems I messed up. Time to go bald."
	reagent_state = LIQUID
	color = "#C0FFAB"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "hairloss"

/datum/reagent/barbers_shaving_aid/expose_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == TOUCH || method == VAPOR)
		if(M && ishuman(M))
			var/mob/living/carbon/human/H = M
			H.hair_style = "Bald 2"
			H.facial_hair_style = "Shaved"
			H.update_hair()

/datum/reagent/saltpetre
	name = "Saltpetre"
	description = "A fairly innocuous chemical which can be used to improve the potency of various plant species."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	chem_flags = CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BARTENDER_SERVING
	taste_description = "cool salt"


/datum/reagent/lye
	name = "Lye"
	description = "Also known as sodium hydroxide. As a profession, making this is somewhat underwhelming."
	reagent_state = LIQUID
	chem_flags = NONE
	color = "#FFFFD6" // very very light yellow
	taste_description = "acid"


/datum/reagent/drying_agent
	name = "Drying agent"
	description = "A desiccant. Can be used to dry things."
	reagent_state = LIQUID
	color = "#A70FFF"
	chem_flags = NONE
	taste_description = "dryness"


/datum/reagent/drying_agent/expose_turf(turf/open/T, reac_volume)
	if(istype(T))
		T.MakeDry(ALL, TRUE, reac_volume * 5 SECONDS)		//50 deciseconds per unit

/datum/reagent/drying_agent/expose_obj(obj/O, reac_volume)
	if(O.type == /obj/item/clothing/shoes/galoshes)
		var/t_loc = get_turf(O)
		qdel(O)
		new /obj/item/clothing/shoes/galoshes/dry(t_loc)

// Virology virus food chems.

/datum/reagent/toxin/mutagen/mutagenvirusfood
	name = "Mutagenic Agar"
	color = "#A3C00F" // rgb: 163,192,15
	chem_flags = CHEMICAL_RNG_BOTANY
	taste_description = "sourness"

/datum/reagent/toxin/mutagen/mutagenvirusfood/sugar
	name = "Sucrose Agar"
	color = "#41B0C0" // rgb: 65,176,192
	chem_flags = CHEMICAL_RNG_BOTANY
	taste_description = "sweetness"

/datum/reagent/medicine/synaptizine/synaptizinevirusfood
	name = "Virus Rations"
	color = "#D18AA5" // rgb: 209,138,165
	chem_flags = CHEMICAL_RNG_BOTANY
	taste_description = "bitterness"

/datum/reagent/toxin/plasma/plasmavirusfood
	name = "Virus Plasma"
	color = "#A69DA9" // rgb: 166,157,169
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "bitterness"
	taste_mult = 1.5

/datum/reagent/toxin/plasma/plasmavirusfood/weak
	name = "Weakened Virus Plasma"
	color = "#CEC3C6" // rgb: 206,195,198
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "bitterness"
	taste_mult = 1.5

/datum/reagent/uranium/uraniumvirusfood
	name = "Decaying Uranium Gel"
	color = "#67ADBA" // rgb: 103,173,186
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "the inside of a reactor"

/datum/reagent/uranium/uraniumvirusfood/unstable
	name = "Unstable Uranium Gel"
	color = "#2FF2CB" // rgb: 47,242,203
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "the inside of a reactor"

/datum/reagent/uranium/uraniumvirusfood/stable
	name = "Stable Uranium Gel"
	color = "#04506C" // rgb: 4,80,108
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "the inside of a reactor"

/datum/reagent/consumable/laughter/laughtervirusfood
	name = "Anomolous Virus Food"
	color = "#ffa6ff" //rgb: 255,166,255
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "a bad idea"

/datum/reagent/consumable/virus_food/advvirusfood
	name = "Highly Unstable Virus Food"
	color = "#ffffff" //rgb: 255,255,255 ITS PURE WHITE CMON
	chem_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_FUN
	taste_description = "an EXTREMELY bad idea"

/datum/reagent/consumable/virus_food/viralbase
	name = "Experimental Viral Base"
	description = "Recently discovered by Nanotrasen's top scientists after years of research, this substance can be used as the base for extremely rare and extremely dangerous viruses once exposed to uranium."
	color = "#fff0da"
	chem_flags = CHEMICAL_NOT_SYNTH
	taste_description = "tears of scientists"

// Bee chemicals

/datum/reagent/royal_bee_jelly
	name = "Royal Bee Jelly"
	description = "Royal Bee Jelly, if injected into a Queen Space Bee said bee will split into two bees."
	color = "#00ff80"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "strange honey"

/datum/reagent/royal_bee_jelly/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(DT_PROB(1, delta_time))
		M.say(pick("Bzzz...","BZZ BZZ","Bzzzzzzzzzzz..."), forced = "royal bee jelly")
	..()

//Misc reagents

/datum/reagent/romerol
	name = "Romerol"
	// the REAL zombie powder
	description = "Romerol is a highly experimental bioterror agent \
		which causes dormant nodules to be etched into the grey matter of \
		the subject. These nodules only become active upon death of the \
		host, upon which, the secondary structures activate and take control \
		of the host body."
	color = "#123524" // RGB (18, 53, 36)
	chem_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_FUN // romerol zombie outbreak from a maint pill? how can this go not fun.
	metabolization_rate = INFINITY
	taste_description = "brains"

/datum/reagent/romerol/expose_mob(mob/living/carbon/human/H, method=TOUCH, reac_volume)
	// Silently add the zombie infection organ to be activated upon death
	if(!H.get_organ_slot(ORGAN_SLOT_ZOMBIE))
		var/obj/item/organ/zombie_infection/nodamage/ZI = new()
		ZI.Insert(H)
	..()

/datum/reagent/magillitis
	name = "Magillitis"
	description = "An experimental serum which causes rapid muscular growth in Hominidae. Side-affects may include hypertrichosis, violent outbursts, and an unending affinity for bananas."
	reagent_state = LIQUID
	color = "#00f041"
	chem_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_FUN

/datum/reagent/magillitis/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	..()
	if((ismonkey(M) || ishuman(M)) && current_cycle >= 10)
		M.gorillize()

/datum/reagent/growthserum
	name = "Growth Serum"
	description = "A commercial chemical designed to help older men in the bedroom."//not really it just makes you a giant
	color = "#ff0000"//strong red. rgb 255, 0, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST
	var/current_size = RESIZE_DEFAULT_SIZE
	taste_description = "bitterness" // apparently what viagra tastes like

/datum/reagent/growthserum/on_mob_life(mob/living/carbon/H, delta_time, times_fired)
	var/newsize = current_size
	switch(volume)
		if(0 to 19)
			newsize = 1.25*RESIZE_DEFAULT_SIZE
		if(20 to 49)
			newsize = 1.5*RESIZE_DEFAULT_SIZE
		if(50 to 99)
			newsize = 2*RESIZE_DEFAULT_SIZE
		if(100 to 199)
			newsize = 2.5*RESIZE_DEFAULT_SIZE
		if(200 to INFINITY)
			newsize = 3.5*RESIZE_DEFAULT_SIZE

	H.resize = newsize/current_size
	current_size = newsize
	H.update_transform()
	..()

/datum/reagent/growthserum/on_mob_end_metabolize(mob/living/M)
	M.resize = RESIZE_DEFAULT_SIZE/current_size
	current_size = RESIZE_DEFAULT_SIZE
	M.update_transform()
	..()

/datum/reagent/plastic_polymers
	name = "Plastic Polymers"
	description = "The petroleum-based components of plastic."
	color = "#f7eded"
	chem_flags = NONE
	taste_description = "plastic"

/datum/reagent/glitter
	name = "light pink glitter"
	description = "light pink sparkles that get everywhere."
	color = "#FFFFFF" //base colour of decal is light pink
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY
	taste_description = "plastic"
	reagent_state = SOLID
	var/glitter_type = /obj/effect/decal/cleanable/glitter

/datum/reagent/glitter/expose_turf(turf/T, reac_volume)
	if(!istype(T))
		return
	new glitter_type(T)

/datum/reagent/glitter/pink
	name = "Pink Glitter"
	description = "Pink sparkles that get everywhere."
	color = "#ff8080" //A light pink color
	glitter_type = /obj/effect/decal/cleanable/glitter/pink

/datum/reagent/glitter/white
	name = "White Glitter"
	description = "White sparkles that get everywhere."
	glitter_type = /obj/effect/decal/cleanable/glitter/white

/datum/reagent/glitter/blue
	name = "Blue Glitter"
	description = "Blue sparkles that get everywhere."
	color = "#4040FF" //A blueish color
	glitter_type = /obj/effect/decal/cleanable/glitter/blue

/datum/reagent/pax
	name = "Pax"
	description = "A colorless liquid that suppresses violent urges in its subjects."
	color = "#AAAAAA55"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST
	taste_description = "water"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM

/datum/reagent/pax/on_mob_metabolize(mob/living/L)
	..()
	ADD_TRAIT(L, TRAIT_PACIFISM, type)

/datum/reagent/pax/on_mob_end_metabolize(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_PACIFISM, type)
	..()

/datum/reagent/pax/peaceborg
	name = "Synthpax"
	description = "A colorless liquid that suppresses violent urges in its subjects. Cheaper to synthesize than normal Pax, but wears off faster."
	chem_flags = NONE
	metabolization_rate = 1.5 * REAGENTS_METABOLISM

/datum/reagent/peaceborg
	chem_flags = CHEMICAL_NOT_DEFINED

/datum/reagent/peaceborg/confuse
	name = "Dizzying Solution"
	description = "Makes the target off balance and dizzy."
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	taste_description = "dizziness"

/datum/reagent/peaceborg/confuse/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(M.confused < 6)
		M.confused = clamp(M.confused + (3 * REM * delta_time), 0, 5)
	if(M.dizziness < 6)
		M.dizziness = clamp(M.dizziness + (3 * REM * delta_time), 0, 5)
	if(DT_PROB(10, delta_time))
		to_chat(M, "You feel confused and disorientated.")
	..()

/datum/reagent/peaceborg/inabizine
	name = "Inabizine"
	description = "Induces muscle relaxation, which makes holding objects and standing difficult."
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	taste_description = "relaxing"

/datum/reagent/peaceborg/inabizine/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(DT_PROB(17, delta_time))
		M.Stun(20, 0)
		M.blur_eyes(5)
	if(DT_PROB(17, delta_time))
		M.Knockdown(2 SECONDS)
	if(DT_PROB(10, delta_time))
		to_chat(M, "Your muscles relax...")
	..()

/datum/reagent/peaceborg/tire
	name = "Tiring Solution"
	description = "An very mild stamina toxin that wears out the target. Completely harmless."
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	taste_description = "tiredness"

/datum/reagent/peaceborg/tire/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	var/healthcomp = (100 - M.health) //DOES NOT ACCOUNT FOR ADMINBUS THINGS THAT MAKE YOU HAVE MORE THAN 200/210 HEALTH, OR SOMETHING OTHER THAN A HUMAN PROCESSING THIS.
	if(M.getStaminaLoss() < (45 - healthcomp))	//At 50 health you would have 200 - 150 health meaning 50 compensation. 60 - 50 = 10, so would only do 10-19 stamina.)
		M.adjustStaminaLoss(10 * REM * delta_time)
	if(DT_PROB(16, delta_time))
		to_chat(M, "You should sit down and take a rest...")
	..()

/datum/reagent/tranquility
	name = "Tranquility"
	description = "A highly mutative liquid of unknown origin."
	color = "#9A6750" //RGB: 154, 103, 80
	chem_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN
	taste_description = "inner peace"

/datum/reagent/tranquility/expose_mob(mob/living/L, method=TOUCH, reac_volume, show_message = 1, touch_protection = 0)
	if(method==PATCH || method==INGEST || method==INJECT || (method == VAPOR && prob(min(reac_volume,100)*(1 - touch_protection))))
		L.ForceContractDisease(new /datum/disease/transformation/gondola(), FALSE, TRUE)

/datum/reagent/liquidadamantine
	name = "Liquid Adamantine"
	description = "A legengary lifegiving metal liquified."
	color = "#10cca6" //RGB: 16, 204, 166
	chem_flags = CHEMICAL_NOT_SYNTH
	taste_description = "lifegiiving metal"

/datum/reagent/spider_extract
	name = "Spider Extract"
	description = "A highly specialized extract coming from the Australicus sector, used to create broodmother spiders."
	color = "#ED2939"
	chem_flags = CHEMICAL_NOT_SYNTH | CHEMICAL_RNG_FUN
	taste_description = "upside down"

// unholy water, but for heretics.
// why couldn't they have both just used the same reagent?
// who knows.
// maybe nar'sie is considered to be too "mainstream" of a god to worship in the heretic community.
/datum/reagent/eldritch
	name = "Eldritch Essence"
	description = "A strange liquid that defies the laws of physics. \
		It re-energizes and heals those who can see beyond this fragile reality, \
		but is incredibly harmful to the closed-minded. It metabolizes very quickly."
	taste_description = "Ag'hsj'saje'sh"
	color = "#1f8016"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	metabolization_rate = 2.5 * REAGENTS_METABOLISM //0.5u/second

/datum/reagent/eldritch/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(IS_HERETIC(M))
		M.drowsyness = max(M.drowsyness - (5 * REM * delta_time), 0)
		M.AdjustAllImmobility(-40 * REM * delta_time)
		M.adjustStaminaLoss(-10 * REM * delta_time, FALSE)
		M.adjustToxLoss(-2 * REM * delta_time, FALSE)
		M.adjustOxyLoss(-2 * REM * delta_time, FALSE)
		M.adjustBruteLoss(-2 * REM * delta_time, FALSE)
		M.adjustFireLoss(-2 * REM * delta_time, FALSE)
		if(ishuman(M) && M.blood_volume < BLOOD_VOLUME_NORMAL)
			M.blood_volume += 3 * REM * delta_time
	else
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3 * REM * delta_time, 150)
		M.adjustToxLoss(2 * REM * delta_time, FALSE)
		M.adjustFireLoss(2 * REM * delta_time, FALSE)
		M.adjustOxyLoss(2 * REM * delta_time, FALSE)
		M.adjustBruteLoss(2 * REM * delta_time, FALSE)
	..()
	return TRUE

/datum/reagent/consumable/ratlight
	name = "Ratvarian Light"
	description = "A special concoction said to have been blessed by an ancient god. Makes the consumer glow with literal enlightenment."
	color = "#B5A642"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "enlightenment"
	metabolization_rate = 0.8 * REAGENTS_METABOLISM
	var/datum/language_holder/prev_language

/datum/reagent/consumable/ratlight/expose_mob(mob/living/M)
	M.set_light(2)
	..()

/datum/reagent/consumable/ratlight/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(DT_PROB(5, delta_time))
		playsound(M, "scripture_tier_up", 50, 1)
	..()

/datum/reagent/consumable/ratlight/on_mob_metabolize(mob/living/L)
	L.add_blocked_language(subtypesof(/datum/language/) - /datum/language/ratvar, LANGUAGE_REAGENT)
	L.grant_language(/datum/language/ratvar, source = LANGUAGE_REAGENT)
	..()

/datum/reagent/consumable/ratlight/on_mob_end_metabolize(mob/living/L)
	L.remove_blocked_language(subtypesof(/datum/language/), LANGUAGE_REAGENT)
	L.remove_language(/datum/language/ratvar, source = LANGUAGE_REAGENT)
	L.set_light(-1)

	..()

/datum/reagent/helgrasp
	name = "Helgrasp"
	description = "This rare and forbidden concoction is thought to bring you closer to the grasp of the Norse goddess Hel."
	metabolization_rate = 1*REM //This is fast
	//Compensates for delta_time lag by spawning multiple hands at the end
	var/lag_remainder = 0
	//Keeps track of the hand timer so we can cleanup on removal
	var/list/timer_ids

//Warns you about the impending hands
/datum/reagent/helgrasp/on_mob_add(mob/living/L, amount)
	to_chat(L, span_hierophant("You hear laughter as malevolent hands apparate before you, eager to drag you down to hell...! Look out!"))
	playsound(L.loc, 'sound/misc/ahaha.ogg', 80, TRUE, -1) //Very obvious tell so people can be ready
	. = ..()

//Sends hands after you for your hubris
/*
How it works:
Standard delta_time for a reagent is 2s - and volume consumption is equal to the volume * delta_time.
In this chem, I want to consume 0.5u for 1 hand created (since 1*REM is 0.5) so on a single tick I create a hand and set up a callback for another one in 1s from now. But since delta time can vary, I want to be able to create more hands for when the delay is longer.
Initally I round delta_time to the nearest whole number, and take the part that I am rounding down from (i.e. the decimal numbers) and keep track of them. If the decimilised numbers go over 1, then the number is reduced down and an extra hand is created that tick.
Then I attempt to calculate the how many hands to created based off the current delta_time, since I can't know the delay to the next one it assumes the next will be in 2s.
I take the 2s interval period and divide it by the number of hands I want to make (i.e. the current delta_time) and I keep track of how many hands I'm creating (since I always create one on a tick, then I start at 1 hand). For each hand I then use this time value multiplied by the number of hands. Since we're spawning one now, and it checks to see if hands is less than, but not less than or equal to, delta_time, no hands will be created on the next expected tick.
Basically, we fill the time between now and 2s from now with hands based off the current lag.
*/
/datum/reagent/helgrasp/on_mob_life(mob/living/carbon/owner, delta_time = 2, times_fired)
	spawn_hands(owner)
	lag_remainder += delta_time - FLOOR(delta_time, 1)
	delta_time = FLOOR(delta_time, 1)
	if(lag_remainder >= 1)
		delta_time += 1
		lag_remainder -= 1
	var/hands = 1
	var/time = 2 / delta_time
	while(hands < delta_time) //we already made a hand now so start from 1
		LAZYADD(timer_ids, addtimer(CALLBACK(src, PROC_REF(spawn_hands), owner), (time*hands) SECONDS, TIMER_STOPPABLE)) //keep track of all the timers we set up
		hands += time
	return ..()

/datum/reagent/helgrasp/proc/spawn_hands(mob/living/carbon/owner)
	if(!owner && iscarbon(holder.my_atom))//Catch timer
		owner = holder.my_atom
	//Adapted from the end of the curse - but lasts a short time
	var/grab_dir = turn(owner.dir, pick(-90, 90, 180, 180)) //grab them from a random direction other than the one faced, favoring grabbing from behind
	var/turf/spawn_turf = get_ranged_target_turf(owner, grab_dir, 8)//Larger range so you have more time to dodge
	if(!spawn_turf)
		return
	new/obj/effect/temp_visual/dir_setting/curse/grasp_portal(spawn_turf, owner.dir)
	playsound(spawn_turf, 'sound/effects/curse2.ogg', 80, TRUE, -1)
	var/obj/projectile/curse_hand/hel/hand = new (spawn_turf)
	hand.preparePixelProjectile(owner, spawn_turf)
	if(QDELETED(hand)) //safety check if above fails - above has a stack trace if it does fail
		return
	hand.fire()

//At the end, we clear up any loose hanging timers just in case and spawn any remaining lag_remaining hands all at once.
/datum/reagent/helgrasp/on_mob_delete(mob/living/owner)
	var/hands = 0
	while(lag_remainder > hands)
		spawn_hands(owner)
		hands++
	for(var/id in timer_ids) // So that we can be certain that all timers are deleted at the end.
		deltimer(id)
	timer_ids.Cut()
	return ..()

/datum/reagent/helgrasp/heretic
	name = "Grasp of the Mansus"
	description = "The Hand of the Mansus is at your neck."
	metabolization_rate = 1 * REM

/datum/reagent/eldritchkiss
	name = "Eldritch Kiss"
	description = "The lingering touch of eldritch hands pulses through your veins."
	chem_flags = CHEMICAL_NOT_SYNTH
	process_flags = ORGANIC | SYNTHETIC //i think this is how this works
	self_consuming = TRUE //not having a liver will not deny the fairness of the elder gods

/datum/reagent/medicine/eldritchkiss/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(M.health <= 20)
		M.adjustToxLoss(-4 * REM * delta_time, FALSE, TRUE) //this makes it heal toxinlovers, i think
		M.adjustBruteLoss(-4 * REM * delta_time, FALSE)
		M.adjustFireLoss(-4 * REM * delta_time, FALSE)
		M.adjustOxyLoss(-5 * REM * delta_time, FALSE)
		. = TRUE
	M.losebreath = 0

/datum/reagent/ants
	name = "Ants"
	description = "A sample of a lost breed of Space Ants (formicidae bastardium tyrannus), they are well-known for ravaging the living shit out of pretty much anything."
	reagent_state = SOLID
	color = "#993333"
	taste_mult = 1.3
	taste_description = "tiny legs scuttling down the back of your throat."
	metabolization_rate = 5 * REAGENTS_METABOLISM //1u per second
	/// How much damage the ants are going to be doing (rises with each tick the ants are in someone's body)
	var/ant_damage = 0 // Not actual damage, only way to check how long they were inside
	/// Tells the debuff how many ants we are being covered with.
	var/amount_left = 0
	/// List of possible common statements to scream when eating ants
	var/static/list/ant_screams = list(
		"THEY'RE UNDER MY SKIN!!",
		"GET THEM OUT OF ME!!",
		"HOLY HELL THEY BURN!!",
		"MY GOD THEY'RE INSIDE ME!!",
		"GET THEM OUT!!",
		)

/datum/glass_style/drinking_glass/ants
	required_drink_type = /datum/reagent/ants
	name = "glass of ants"
	desc = "Bottoms up...?"

/datum/reagent/ants/on_mob_life(mob/living/carbon/victim, delta_time)
	ant_damage++
	if(ant_damage < 5) // Makes ant food a little more appetizing, since you won't be screaming as much.
		return ..()
	if(DT_PROB(5, delta_time))
		if(DT_PROB(5, delta_time)) //Super rare statement
			victim.say("AUGH NO NOT THE ANTS! NOT THE ANTS! AAAAUUGH THEY'RE IN MY EYES! MY EYES! AUUGH!!", forced = /datum/reagent/ants)
		else
			victim.say(pick(ant_screams), forced = /datum/reagent/ants)
	if(DT_PROB(15, delta_time))
		victim.emote("scream")
	if(DT_PROB(2, delta_time)) // Stuns, but purges ants.
		victim.vomit(rand(5,10), FALSE, TRUE, 1, TRUE, FALSE)
	return ..()

/datum/reagent/ants/on_mob_end_metabolize(mob/living/living_anthill)
	ant_damage = 0
	to_chat(living_anthill, "<span class='notice'>You feel like the last of the ants are out of your system.</span>")
	return ..()

/datum/reagent/ants/expose_mob(mob/living/exposed_mob, method=TOUCH, reac_volume)
	. = ..()
	if(!iscarbon(exposed_mob) || (method == INGEST||INJECT))
		return
	if(method == PATCH||TOUCH||VAPOR)
		amount_left = round(reac_volume,0.1)
		exposed_mob.apply_status_effect(/datum/status_effect/ants, amount_left)

/datum/reagent/ants/expose_obj(obj/exposed_obj, reac_volume)
	. = ..()
	var/turf/open/my_turf = exposed_obj.loc // No dumping ants on an object in a storage slot
	if(!istype(my_turf)) //Are we actually in an open turf?
		return
	var/static/list/accepted_types = typecacheof(list(/obj/machinery/atmospherics, /obj/structure/cable, /obj/structure/disposalpipe))
	if(!accepted_types[exposed_obj.type]) // Bypasses pipes, vents, and cables to let people create ant mounds on top easily.
		return
	expose_turf(my_turf, reac_volume)

/datum/reagent/ants/expose_turf(turf/exposed_turf, reac_volume)
	. = ..()
	if(!istype(exposed_turf) || isspaceturf(exposed_turf)) // Is the turf valid
		return
	if((reac_volume <= 10)) // Makes sure people don't duplicate ants.
		return

	var/obj/effect/decal/cleanable/ants/pests = locate() in exposed_turf.contents
	if(!pests)
		pests = new(exposed_turf)
	var/spilled_ants = (round(reac_volume,1) - 5) // To account for ant decals giving 3-5 ants on initialize.
	pests.reagents.add_reagent(/datum/reagent/ants, spilled_ants)
	pests.update_ant_damage()
