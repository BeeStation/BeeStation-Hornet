/datum/reagent/blood
	data = list("donor"=null,"viruses"=null,"blood_DNA"=null,"blood_type"=null,"resistances"=null,"trace_chem"=null,"mind"=null,"ckey"=null,"gender"=null,"real_name"=null,"cloneable"=null,"factions"=null,"quirks"=null)
	name = "Blood"
	color = "#C80000"
	metabolization_rate = 5
	taste_description = "iron"
	taste_mult = 1.3
	glass_icon_state = "glass_red"
	glass_name = "glass of tomato juice"
	glass_desc = "Are you sure this is tomato juice?"
	shot_glass_icon_state = "shotglassred"

/datum/reagent/blood/reaction_mob(mob/living/L, method=TOUCH, reac_volume)
	if(data && data["viruses"])
		for(var/thing in data["viruses"])
			var/datum/disease/D = thing

			if((D.spread_flags & DISEASE_SPREAD_SPECIAL) || (D.spread_flags & DISEASE_SPREAD_NON_CONTAGIOUS))
				continue

			if((method == TOUCH || method == VAPOR) && (D.spread_flags & DISEASE_SPREAD_CONTACT_FLUIDS))
				L.ContactContractDisease(D)
			else
				L.ForceContractDisease(D)

	if(iscarbon(L))
		var/mob/living/carbon/C = L
		if(C.get_blood_id() == /datum/reagent/blood && (method == INJECT || (method == INGEST && C.dna && C.dna.species && (DRINKSBLOOD in C.dna.species.species_traits))))
			if(!data || !(data["blood_type"] in get_safe_blood(C.dna.blood_type)))
				C.reagents.add_reagent(/datum/reagent/toxin, reac_volume * 0.5)
			else
				C.blood_volume = min(C.blood_volume + round(reac_volume, 0.1), BLOOD_VOLUME_MAXIMUM)


/datum/reagent/blood/on_new(list/data)
	if(istype(data))
		SetViruses(src, data)

/datum/reagent/blood/on_merge(list/mix_data)
	if(data && mix_data)
		if(data["blood_DNA"] != mix_data["blood_DNA"])
			data["cloneable"] = 0
		if(data["viruses"] || mix_data["viruses"])

			var/list/mix1 = data["viruses"]
			var/list/mix2 = mix_data["viruses"]


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

/datum/reagent/blood/reaction_turf(turf/T, reac_volume)
	if(!istype(T))
		return
	if(reac_volume < 3)
		return

	var/obj/effect/decal/cleanable/blood/B = locate() in T
	if(!B)
		B = new(T)
	if(data["blood_DNA"])
		B.add_blood_DNA(list(data["blood_DNA"] = data["blood_type"]))

/datum/reagent/liquidgibs
	name = "Liquid gibs"
	color = "#FF9966"
	description = "You don't even want to think about what's in here."
	taste_description = "gross iron"
	shot_glass_icon_state = "shotglassred"

/datum/reagent/vaccine

	name = "Vaccine"
	color = "#C81040"
	taste_description = "slime"

/datum/reagent/vaccine/reaction_mob(mob/living/L, method=TOUCH, reac_volume)
	if(islist(data) && (method == INGEST || method == INJECT))
		for(var/thing in L.diseases)
			var/datum/disease/D = thing
			if(D.GetDiseaseID() in data)
				D.cure()
		L.disease_resistances |= data

/datum/reagent/vaccine/on_merge(list/data)
	if(istype(data))
		src.data |= data.Copy()

/datum/reagent/water
	name = "Water"
	description = "An ubiquitous chemical substance that is composed of hydrogen and oxygen."
	color = "#AAAAAA77"
	taste_description = "water"
	var/cooling_temperature = 2
	glass_icon_state = "glass_clear"
	glass_name = "glass of water"
	glass_desc = "The father of all refreshments."
	shot_glass_icon_state = "shotglassclear"
	process_flags = ORGANIC | SYNTHETIC
	random_unrestricted = FALSE

/*
 *	Water reaction to turf
 */

/datum/reagent/water/reaction_turf(turf/open/T, reac_volume)
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
			G.set_temperature(max(min(G.return_temperature()-(CT*1000),G.return_temperature()/CT),TCMB))
			G.react(src)
			qdel(hotspot)
	var/obj/effect/acid/A = (locate(/obj/effect/acid) in T)
	if(A)
		A.acid_level = max(A.acid_level - reac_volume*50, 0)

/*
 *	Water reaction to an object
 */

/datum/reagent/water/reaction_obj(obj/O, reac_volume)
	O.extinguish()
	O.acid_level = 0

	if(istype(O, /obj/item/reagent_containers/food/snacks/monkeycube))
		var/obj/item/reagent_containers/food/snacks/monkeycube/cube = O
		cube.Expand()


	else if(istype(O, /obj/item/toy/plush/carpplushie/dehy_carp))
		var/obj/item/toy/plush/carpplushie/dehy_carp/dehy = O
		dehy.Swell()

	else if(istype(O, /obj/item/stack/sheet/hairlesshide))
		var/obj/item/stack/sheet/hairlesshide/HH = O
		new /obj/item/stack/sheet/wetleather(get_turf(HH), HH.amount)
		qdel(HH)

/*
 *	Water reaction to a mob
 */

/datum/reagent/water/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(!istype(M))
		return
	if(method == TOUCH)
		M.adjust_fire_stacks(-(reac_volume / 10))
		M.ExtinguishMob()
	..()

/datum/reagent/water/holywater
	name = "Holy Water"
	description = "Water blessed by some deity."
	color = "#E0E8EF"
	glass_icon_state  = "glass_clear"
	glass_name = "glass of holy water"
	glass_desc = "A glass of holy water."
	self_consuming = TRUE

/datum/reagent/water/holywater/on_mob_metabolize(mob/living/L)
	..()
	ADD_TRAIT(L, TRAIT_HOLY, type)

/datum/reagent/water/holywater/on_mob_end_metabolize(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_HOLY, type)
	if(HAS_TRAIT_FROM(L, TRAIT_DEPRESSION, HOLYWATER_TRAIT))
		REMOVE_TRAIT(L, TRAIT_DEPRESSION, HOLYWATER_TRAIT)
		to_chat(L, "<span class='notice'>You cheer up, knowing that everything is going to be ok.</span>")
	..()

/datum/reagent/water/holywater/on_mob_life(mob/living/carbon/M)
	if(!data)
		data = list("misc" = 1)
	data["misc"]++
	M.jitteriness = min(M.jitteriness+4,10)
	if(iscultist(M))
		for(var/datum/action/innate/cult/blood_magic/BM in M.actions)
			to_chat(M, "<span class='cultlarge'>Your blood rites falter as holy water scours your body!</span>")
			for(var/datum/action/innate/cult/blood_spell/BS in BM.spells)
				qdel(BS)
	if(data["misc"] >= 25)
		if(!M.stuttering)
			M.stuttering = 1
		M.stuttering = min(M.stuttering+4, 10)
		M.Dizzy(5)
		if(is_servant_of_ratvar(M) && prob(20))
			M.say(text2ratvar(pick("Please don't leave me...", "Rat'var what happened?", "My friends, where are you?", "The hierophant network just went dark, is anyone there?", "The light is fading...", "No... It can't be...")), forced = "holy water")
			if(prob(40))
				if(!HAS_TRAIT_FROM(M, TRAIT_DEPRESSION, HOLYWATER_TRAIT))
					to_chat(M, "<span class='large_brass'>You feel the light fading and the world collapsing around you...</span>")
					ADD_TRAIT(M, TRAIT_DEPRESSION, HOLYWATER_TRAIT)
		if(iscultist(M) && prob(20))
			M.say(pick("Av'te Nar'Sie","Pa'lid Mors","INO INO ORA ANA","SAT ANA!","Daim'niodeis Arc'iai Le'eones","R'ge Na'sie","Diabo us Vo'iscum","Eld' Mon Nobis"), forced = "holy water")
			if(prob(10))
				M.visible_message("<span class='danger'>[M] starts having a seizure!</span>", "<span class='userdanger'>You have a seizure!</span>")
				M.Unconscious(120)
				to_chat(M, "<span class='cultlarge'>[pick("Your blood is your bond - you are nothing without it", "Do not forget your place", \
				"All that power, and you still fail?", "If you cannot scour this poison, I shall scour your meager life!")].</span>")
	if(data["misc"] >= 60)	// 30 units, 135 seconds
		if(iscultist(M) || is_servant_of_ratvar(M))
			if(iscultist(M))
				SSticker.mode.remove_cultist(M.mind, FALSE, TRUE)
			if(is_servant_of_ratvar(M))
				remove_servant_of_ratvar(M.mind)
			M.jitteriness = 0
			M.stuttering = 0
			holder.remove_reagent(type, volume)
			return
	holder.remove_reagent(type, 0.4)

/datum/reagent/water/holywater/reaction_turf(turf/T, reac_volume)
	..()
	if(!istype(T))
		return
	if(reac_volume>=10)
		for(var/obj/effect/rune/R in T)
			qdel(R)
	T.Bless()

/datum/reagent/fuel/unholywater
	name = "Unholy Water"
	description = "Something that shouldn't exist on this plane of existence."
	taste_description = "suffering"

/datum/reagent/fuel/unholywater/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == TOUCH || method == VAPOR)
		M.reagents.add_reagent(type,reac_volume/4)
		return
	return ..()

/datum/reagent/fuel/unholywater/on_mob_life(mob/living/carbon/M)
	if(iscultist(M))
		M.drowsyness = max(M.drowsyness-5, 0)
		M.AdjustAllImmobility(-40, FALSE)
		M.adjustStaminaLoss(-10, 0)
		M.adjustToxLoss(-2, 0)
		M.adjustOxyLoss(-2, 0)
		M.adjustBruteLoss(-2, 0)
		M.adjustFireLoss(-2, 0)
		if(ishuman(M) && M.blood_volume < BLOOD_VOLUME_NORMAL)
			M.blood_volume += 3
	else
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3, 150)
		M.adjustToxLoss(2, 0)
		M.adjustFireLoss(2, 0)
		M.adjustOxyLoss(2, 0)
		M.adjustBruteLoss(2, 0)
	holder.remove_reagent(type, 1)
	return TRUE

/datum/reagent/hellwater
	name = "Hell Water"
	description = "YOUR FLESH! IT BURNS!"
	taste_description = "burning"
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/hellwater/on_mob_life(mob/living/carbon/M)
	M.fire_stacks = min(5,M.fire_stacks + 3)
	M.IgniteMob()
	M.adjustToxLoss(1, 0)
	M.adjustFireLoss(1, 0)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5, 150)
	holder.remove_reagent(type, 1)

/datum/reagent/medicine/omnizine/godblood
	name = "Godblood"
	description = "Slowly heals all damage types. Has a rather high overdose threshold. Glows with mysterious power."
	overdose_threshold = 150

/datum/reagent/lube
	name = "Space Lube"
	description = "Lubricant is a substance introduced between two moving surfaces to reduce the friction and wear between them. giggity."
	color = "#009CA8"
	taste_description = "cherry"

/datum/reagent/lube/reaction_turf(turf/open/T, reac_volume)
	if (!istype(T))
		return
	if(reac_volume >= 1)
		T.MakeSlippery(TURF_WET_LUBE, 15 SECONDS, min(reac_volume * 2 SECONDS, 120))

/datum/reagent/spraytan
	name = "Spray Tan"
	description = "A substance applied to the skin to darken the skin."
	color = "#FFC080"
	metabolization_rate = 10 * REAGENTS_METABOLISM
	overdose_threshold = 11
	taste_description = "sour oranges"

/datum/reagent/spraytan/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message = 1)
	if(ishuman(M))
		if(method == PATCH || method == VAPOR)
			var/mob/living/carbon/human/N = M
			if(N.dna.species.id == "human")
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

			if(MUTCOLORS in N.dna.species.species_traits)
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
							newcolor += ascii2text(ascii-1)
						if(97)
							newcolor += "9"
						if(98 to 102)
							newcolor += ascii2text(ascii-1)
						if(65)
							newcolor += "9"
						if(66 to 70)
							newcolor += ascii2text(ascii+31)
						else
							break
				if(ReadHSV(newcolor)[3] >= ReadHSV("#7F7F7F")[3])
					N.dna.features["mcolor"] = newcolor
			N.regenerate_icons()



		if(method == INGEST)
			if(show_message)
				to_chat(M, "<span class='notice'>That tasted horrible.</span>")
	..()


/datum/reagent/spraytan/overdose_process(mob/living/M)
	metabolization_rate = 1 * REAGENTS_METABOLISM

	if(ishuman(M))
		var/mob/living/carbon/human/N = M
		N.hair_style = "Spiky"
		N.facial_hair_style = "Shaved"
		N.facial_hair_color = "000"
		N.hair_color = "000"
		if(!(HAIR in N.dna.species.species_traits))
			N.dna.species.species_traits += HAIR
		if(N.dna.species.use_skintones)
			N.skin_tone = "orange"
		else if(MUTCOLORS in N.dna.species.species_traits)
			N.dna.features["mcolor"] = "f80"
		N.regenerate_icons()
		if(prob(7))
			if(N.w_uniform)
				M.visible_message(pick("<b>[M]</b>'s collar pops up without warning.</span>", "<b>[M]</b> flexes [M.p_their()] arms."))
			else
				M.visible_message("<b>[M]</b> flexes [M.p_their()] arms.")
	if(prob(10))
		M.say(pick("Shit was SO cash.", "You are everything bad in the world.", "What sports do you play, other than 'jack off to naked drawn Japanese people?'", "Don???t be a stranger. Just hit me with your best shot.", "My name is John and I hate every single one of you."), forced = /datum/reagent/spraytan)
	..()
	return

#define MUT_MSG_IMMEDIATE 1
#define MUT_MSG_EXTENDED 2
#define MUT_MSG_ABOUT2TURN 3

/datum/reagent/mutationtoxin
	name = "Stable Mutation Toxin"
	description = "A humanizing toxin."
	color = "#5EFF3B"
	metabolization_rate = INFINITY
	taste_description = "slime"
	var/datum/species/race = /datum/species/human
	var/mutationtext = "<span class='danger'>The pain subsides. You feel... human.</span>"
	process_flags = ORGANIC | SYNTHETIC
	var/list/mutationtexts = list( "You don't feel very well." = MUT_MSG_IMMEDIATE,
									"Your skin feels a bit abnormal." = MUT_MSG_IMMEDIATE,
									"Your limbs begin to take on a different shape." = MUT_MSG_EXTENDED,
									"Your appendages begin morphing." = MUT_MSG_EXTENDED,
									"You feel as though you're about to change at any moment!" = MUT_MSG_ABOUT2TURN)
	var/cycles_to_turn = 20 //the current_cycle threshold / iterations needed before one can transform
	can_synth = FALSE

/datum/reagent/mutationtoxin/on_mob_life(mob/living/carbon/human/H)
	..()
	if(!istype(H))
		return
	if(!(H.dna?.species) || !(H.mob_biotypes & MOB_ORGANIC))
		return

	if(prob(10))
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
		to_chat(H, "<span class='warning'>[pick(pick_ur_fav)]</span>")

/datum/reagent/mutationtoxin/proc/mutate(mob/living/carbon/human/H)
	if(QDELETED(H))
		return
	var/datum/species/mutation = pick(race)
	var/current_species = H.dna.species.type
	if(mutation && mutation != current_species)
		to_chat(H, mutationtext)
		H.set_species(mutation)
	else
		to_chat(H, "<span class='danger'>The pain vanishes suddenly. You feel no different.</span>")
	H.reagents.del_reagent(type)

/datum/reagent/mutationtoxin/classic
	name = "Mutation Toxin"
	description = "A corruptive toxin."
	color = "#13BC5E"
	race = /datum/species/jelly/slime
	mutationtext = "<span class='danger'>The pain subsides. Your whole body feels like slime.</span>"
	process_flags = ORGANIC | SYNTHETIC
	can_synth = TRUE

/datum/reagent/mutationtoxin/unstable
	name = "Unstable Mutation Toxin"
	description = "A mostly safe mutation toxin."
	color = "#13BC5E"
	race = list(/datum/species/jelly/slime,
						/datum/species/human,
						/datum/species/human/felinid,
						/datum/species/lizard,
						/datum/species/fly,
						/datum/species/moth,
						/datum/species/pod,
						/datum/species/jelly,
						/datum/species/abductor,
						/datum/species/squid)
	mutationtext = "<span class='danger'>The pain subsides. Your whole body feels... Different.</span>"
	process_flags = ORGANIC | SYNTHETIC
	can_synth = TRUE

/datum/reagent/mutationtoxin/felinid
	name = "Felinid Mutation Toxin"
	color = "#5EFF3B"
	race = /datum/species/human/felinid
	mutationtext = "<span class='danger'>The pain subsides. You feel... like a degenerate.</span>"
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/mutationtoxin/lizard
	name = "Lizard Mutation Toxin"
	description = "A lizarding toxin."
	color = "#5EFF3B"
	race = /datum/species/lizard
	mutationtext = "<span class='danger'>The pain subsides. You feel... scaly.</span>"
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/mutationtoxin/fly
	name = "Fly Mutation Toxin"
	description = "An insectifying toxin."
	color = "#5EFF3B"
	race = /datum/species/fly
	mutationtext = "<span class='danger'>The pain subsides. You feel... buzzy.</span>"
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/mutationtoxin/moth
	name = "Moth Mutation Toxin"
	description = "A glowing toxin."
	color = "#5EFF3B"
	race = /datum/species/moth
	mutationtext = "<span class='danger'>The pain subsides. You feel... attracted to light.</span>"
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/mutationtoxin/pod
	name = "Podperson Mutation Toxin"
	description = "A vegetalizing toxin."
	color = "#5EFF3B"
	race = /datum/species/pod
	mutationtext = "<span class='danger'>The pain subsides. You feel... plantlike.</span>"
	process_flags = ORGANIC | SYNTHETIC
	can_synth = TRUE

/datum/reagent/mutationtoxin/jelly
	name = "Imperfect Mutation Toxin"
	description = "An jellyfying toxin."
	color = "#5EFF3B"
	race = /datum/species/jelly
	mutationtext = "<span class='danger'>The pain subsides. You feel... wobbly.</span>"
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/mutationtoxin/golem
	name = "Golem Mutation Toxin"
	description = "A crystal toxin."
	color = "#5EFF3B"
	race = /datum/species/golem/random
	mutationtext = "<span class='danger'>The pain subsides. You feel... rocky.</span>"
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/mutationtoxin/abductor
	name = "Abductor Mutation Toxin"
	description = "An alien toxin."
	color = "#5EFF3B"
	race = /datum/species/abductor
	mutationtext = "<span class='danger'>The pain subsides. You feel... alien.</span>"
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/mutationtoxin/android
	name = "Android Mutation Toxin"
	description = "A robotic toxin."
	color = "#5EFF3B"
	race = /datum/species/android
	mutationtext = "<span class='danger'>The pain subsides. You feel... artificial.</span>"
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/mutationtoxin/ipc
	name = "IPC Mutation Toxin"
	description = "An integrated positronic toxin."
	color = "#5EFF3B"
	race = /datum/species/ipc
	mutationtext = "<span class='danger'>The pain subsides. You feel... artificial.</span>"
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/mutationtoxin/squid
	name = "Squid Mutation Toxin"
	description = "A salty toxin."
	color = "#5EFF3B"
	race = /datum/species/squid
	mutationtext = "<span class='danger'>The pain subsides. You feel... salty.</span>"
	process_flags = ORGANIC | SYNTHETIC


/datum/reagent/mutationtoxin/skeleton
	name = "Skeleton Mutation Toxin"
	description = "A scary toxin."
	color = "#5EFF3B"
	race = /datum/species/skeleton
	mutationtext = "<span class='danger'>The pain subsides. You feel... spooky.</span>"
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/mutationtoxin/zombie
	name = "Zombie Mutation Toxin"
	description = "An undead toxin."
	color = "#5EFF3B"
	race = /datum/species/zombie
	mutationtext = "<span class='danger'>The pain subsides. You feel... undead.</span>"
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/mutationtoxin/goofzombie
	name = "Zombie Mutation Toxin"
	description = "An undead toxin... kinda..."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/krokodil_addict //Not the infectious kind. The days of xenobio zombie outbreaks are long past.
	taste_description = "krokodil"


/datum/reagent/mutationtoxin/ash
	name = "Ash Mutation Toxin"
	description = "An ashen toxin."
	color = "#5EFF3B"
	race = /datum/species/lizard/ashwalker
	mutationtext = "<span class='danger'>The pain subsides. You feel... savage.</span>"
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/mutationtoxin/supersoldier
	name = "Super Soldier Toxin"
	description = "A flesh-sculpting toxin."
	color = "#5EFF3B"
	race = /datum/species/human/supersoldier
	mutationtext = "<span class='danger'>The pain subsides. You feel... like you can take on anything.</span>"
	process_flags = ORGANIC | SYNTHETIC
	can_synth = FALSE
	random_unrestricted = FALSE

/datum/reagent/mutationtoxin/shadow
	name = "Shadow Mutation Toxin"
	description = "A dark toxin."
	color = "#5EFF3B"
	race = /datum/species/shadow
	mutationtext = "<span class='danger'>The pain subsides. You feel... darker.</span>"
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/mutationtoxin/plasma
	name = "Plasma Mutation Toxin"
	description = "A plasma-based toxin."
	color = "#5EFF3B"
	race = /datum/species/plasmaman
	mutationtext = "<span class='danger'>The pain subsides. You feel... flammable.</span>"
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/slime_toxin
	name = "Slime Mutation Toxin"
	description = "A toxin that turns organic material into slime."
	color = "#5EFF3B"
	taste_description = "slime"
	metabolization_rate = 0.2
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/slime_toxin/on_mob_life(mob/living/carbon/human/H)
	..()
	if(!istype(H))
		return
	if(!H.dna || !H.dna.species || !(MOB_ORGANIC in H.mob_biotypes))
		return

	if(isjellyperson(H))
		to_chat(H, "<span class='warning'>Your jelly shifts and morphs, turning you into another subspecies!</span>")
		var/species_type = pick(subtypesof(/datum/species/jelly))
		H.set_species(species_type)
		H.reagents.del_reagent(type)

	switch(current_cycle)
		if(1 to 6)
			if(prob(10))
				to_chat(H, "<span class='warning'>[pick("You don't feel very well.", "Your skin feels a little slimy.")]</span>")
		if(7 to 12)
			if(prob(10))
				to_chat(H, "<span class='warning'>[pick("Your appendages are melting away.", "Your limbs begin to lose their shape.")]</span>")
		if(13 to 19)
			if(prob(10))
				to_chat(H, "<span class='warning'>[pick("You feel your internal organs turning into slime.", "You feel very slimelike.")]</span>")
		if(20 to INFINITY)
			var/species_type = pick(subtypesof(/datum/species/jelly))
			H.set_species(species_type)
			H.reagents.del_reagent(type)
			to_chat(H, "<span class='warning'>You've become \a jellyperson!</span>")

/datum/reagent/mulligan
	name = "Mulligan Toxin"
	description = "This toxin will rapidly change the DNA of human beings. Commonly used by Syndicate spies and assassins in need of an emergency ID change."
	color = "#5EFF3B"
	metabolization_rate = INFINITY
	taste_description = "slime"

/datum/reagent/mulligan/on_mob_life(mob/living/carbon/human/H)
	..()
	if (!istype(H))
		return
	to_chat(H, "<span class='warning'><b>You grit your teeth in pain as your body rapidly mutates!</b></span>")
	H.visible_message("<b>[H]</b> suddenly transforms!")
	randomize_human(H)

/datum/reagent/aslimetoxin
	name = "Advanced Mutation Toxin"
	description = "An advanced corruptive toxin produced by slimes."
	color = "#13BC5E"
	taste_description = "slime"

/datum/reagent/aslimetoxin/reaction_mob(mob/living/L, method=TOUCH, reac_volume)
	if(method != TOUCH)
		L.ForceContractDisease(new /datum/disease/transformation/slime(), FALSE, TRUE)

/datum/reagent/gluttonytoxin
	name = "Gluttony's Blessing"
	description = "An advanced corruptive toxin produced by something terrible."
	color = "#5EFF3B"
	can_synth = FALSE
	taste_description = "decay"

/datum/reagent/gluttonytoxin/reaction_mob(mob/living/L, method=TOUCH, reac_volume)
	L.ForceContractDisease(new /datum/disease/transformation/morph(), FALSE, TRUE)

/datum/reagent/serotrotium
	name = "Serotrotium"
	description = "A chemical compound that promotes concentrated production of the serotonin neurotransmitter in humans."
	color = "#202040"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	taste_description = "bitterness"

/datum/reagent/serotrotium/on_mob_life(mob/living/carbon/M)
	if(ishuman(M))
		if(prob(7))
			M.emote(pick("twitch","drool","moan","gasp"))
	..()

/datum/reagent/oxygen
	name = "Oxygen"
	description = "A colorless, odorless gas. Grows on trees but is still pretty valuable."
	reagent_state = GAS
	color = "#808080"
	taste_mult = 0
	random_unrestricted = FALSE

/datum/reagent/oxygen/reaction_obj(obj/O, reac_volume)
	if((!O) || (!reac_volume))
		return 0
	var/temp = holder ? holder.chem_temp : T20C
	O.atmos_spawn_air("o2=[reac_volume/2];TEMP=[temp]")

/datum/reagent/oxygen/reaction_turf(turf/open/T, reac_volume)
	if(istype(T))
		var/temp = holder ? holder.chem_temp : T20C
		T.atmos_spawn_air("o2=[reac_volume/2];TEMP=[temp]")
	return

/datum/reagent/copper
	name = "Copper"
	description = "A highly ductile metal. Things made out of copper aren't very durable, but it makes a decent material for electrical wiring."
	reagent_state = SOLID
	color = "#6E3B08"
	taste_description = "metal"
	random_unrestricted = FALSE

/datum/reagent/copper/reaction_obj(obj/O, reac_volume)
	if(istype(O, /obj/item/stack/sheet/iron))
		var/obj/item/stack/sheet/iron/M = O
		reac_volume = min(reac_volume, M.amount)
		new/obj/item/stack/tile/bronze(get_turf(M), reac_volume)
		M.use(reac_volume)

/datum/reagent/nitrogen
	name = "Nitrogen"
	description = "A colorless, odorless, tasteless gas. A simple asphyxiant that can silently displace vital oxygen."
	reagent_state = GAS
	color = "#808080"
	taste_mult = 0
	random_unrestricted = FALSE

/datum/reagent/nitrogen/reaction_obj(obj/O, reac_volume)
	if((!O) || (!reac_volume))
		return 0
	var/temp = holder ? holder.chem_temp : T20C
	O.atmos_spawn_air("n2=[reac_volume/2];TEMP=[temp]")

/datum/reagent/nitrogen/reaction_turf(turf/open/T, reac_volume)
	if(istype(T))
		var/temp = holder ? holder.chem_temp : T20C
		T.atmos_spawn_air("n2=[reac_volume/2];TEMP=[temp]")
	return

/datum/reagent/hydrogen
	name = "Hydrogen"
	description = "A colorless, odorless, nonmetallic, tasteless, highly combustible diatomic gas."
	reagent_state = GAS
	color = "#808080"
	taste_mult = 0
	random_unrestricted = FALSE

/datum/reagent/potassium
	name = "Potassium"
	description = "A soft, low-melting solid that can easily be cut with a knife. Reacts violently with water."
	reagent_state = SOLID
	color = "#A0A0A0"
	taste_description = "sweetness"
	random_unrestricted = FALSE

/datum/reagent/mercury
	name = "Mercury"
	description = "A curious metal that's a liquid at room temperature. Neurodegenerative and very bad for the mind."
	color = "#484848"
	taste_mult = 0
	random_unrestricted = FALSE

/datum/reagent/mercury/on_mob_life(mob/living/carbon/M)
	if((M.mobility_flags & MOBILITY_MOVE) && !isspaceturf(M.loc))
		step(M, pick(GLOB.cardinals))
	if(prob(5))
		M.emote(pick("twitch","drool","moan"))
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 1)
	..()

/datum/reagent/sulfur
	name = "Sulfur"
	description = "A sickly yellow solid mostly known for its nasty smell. It's actually much more helpful than it looks in biochemisty."
	reagent_state = SOLID
	color = "#BF8C00"
	taste_description = "rotten eggs"
	random_unrestricted = FALSE

/datum/reagent/carbon
	name = "Carbon"
	description = "A crumbly black solid that, while unexciting on a physical level, forms the base of all known life. Kind of a big deal."
	reagent_state = SOLID
	color = "#1C1300"
	taste_description = "sour chalk"
	random_unrestricted = FALSE

/datum/reagent/carbon/reaction_turf(turf/T, reac_volume)
	if(!isspaceturf(T))
		var/obj/effect/decal/cleanable/dirt/D = locate() in T.contents
		if(!D)
			new /obj/effect/decal/cleanable/dirt(T)

/datum/reagent/chlorine
	name = "Chlorine"
	description = "A pale yellow gas that's well known as an oxidizer. While it forms many harmless molecules in its elemental form it is far from harmless."
	reagent_state = GAS
	color = "#808080"
	taste_description = "chlorine"
	random_unrestricted = FALSE

/datum/reagent/chlorine/on_mob_life(mob/living/carbon/M)
	M.take_bodypart_damage(1*REM, 0, 0, 0)
	. = 1
	..()

/datum/reagent/fluorine
	name = "Fluorine"
	description = "A comically-reactive chemical element. The universe does not want this stuff to exist in this form in the slightest."
	reagent_state = GAS
	color = "#808080"
	taste_description = "acid"
	process_flags = ORGANIC | SYNTHETIC
	random_unrestricted = FALSE

/datum/reagent/fluorine/on_mob_life(mob/living/carbon/M)
	M.adjustToxLoss(1*REM, 0)
	. = 1
	..()

/datum/reagent/sodium
	name = "Sodium"
	description = "A soft silver metal that can easily be cut with a knife. It's not salt just yet, so refrain from putting in on your chips."
	reagent_state = SOLID
	color = "#808080"
	taste_description = "salty metal"
	random_unrestricted = FALSE

/datum/reagent/phosphorus
	name = "Phosphorus"
	description = "A ruddy red powder that burns readily. Though it comes in many colors, the general theme is always the same."
	reagent_state = SOLID
	color = "#832828"
	taste_description = "vinegar"
	random_unrestricted = FALSE

/datum/reagent/lithium
	name = "Lithium"
	description = "A silver metal, its claim to fame is its remarkably low density. Using it is a bit too effective in calming oneself down."
	reagent_state = SOLID
	color = "#808080"
	taste_description = "metal"
	random_unrestricted = FALSE

/datum/reagent/lithium/on_mob_life(mob/living/carbon/M)
	if((M.mobility_flags & MOBILITY_MOVE) && !isspaceturf(M.loc))
		step(M, pick(GLOB.cardinals))
	if(prob(5))
		M.emote(pick("twitch","drool","moan"))
	..()

/datum/reagent/glycerol
	name = "Glycerol"
	description = "Glycerol is a simple polyol compound. Glycerol is sweet-tasting and of low toxicity."
	color = "#808080"
	taste_description = "sweetness"

/datum/reagent/space_cleaner/sterilizine
	name = "Sterilizine"
	description = "Sterilizes wounds in preparation for surgery."
	color = "#C8A5DC"
	taste_description = "bitterness"

/datum/reagent/space_cleaner/sterilizine/reaction_mob(mob/living/carbon/C, method=TOUCH, reac_volume)
	if(method in list(TOUCH, VAPOR, PATCH))
		for(var/s in C.surgeries)
			var/datum/surgery/S = s
			S.success_multiplier = max(0.2, S.success_multiplier)

	..()

/datum/reagent/iron
	name = "Iron"
	description = "Pure iron is a metal."
	reagent_state = SOLID
	taste_description = "iron"
	random_unrestricted = FALSE

	color = "#C8A5DC"

/datum/reagent/iron/on_mob_life(mob/living/carbon/C)
	if(C.blood_volume < BLOOD_VOLUME_NORMAL)
		C.blood_volume += 0.5
	..()

/datum/reagent/iron/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(M.has_bane(BANE_IRON))
		if(holder && holder.chem_temp < 100)
			M.reagents.add_reagent(/datum/reagent/toxin, reac_volume)
	..()

/datum/reagent/gold
	name = "Gold"
	description = "Gold is a dense, soft, shiny metal and the most malleable and ductile metal known."
	reagent_state = SOLID
	color = "#F7C430"
	taste_description = "expensive metal"
	random_unrestricted = FALSE

/datum/reagent/silver
	name = "Silver"
	description = "A soft, white, lustrous transition metal, it has the highest electrical conductivity of any element and the highest thermal conductivity of any metal."
	reagent_state = SOLID
	color = "#D0D0D0"
	taste_description = "expensive yet reasonable metal"
	random_unrestricted = FALSE

/datum/reagent/silver/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(M.has_bane(BANE_SILVER))
		M.reagents.add_reagent(/datum/reagent/toxin, reac_volume)
	..()

/datum/reagent/uranium
	name ="Uranium"
	description = "A silvery-white metallic chemical element in the actinide series, weakly radioactive."
	reagent_state = SOLID
	color = "#B8B8C0"
	taste_description = "the inside of a reactor"
	var/irradiation_level = 1
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/uranium/on_mob_life(mob/living/carbon/M)
	M.apply_effect(irradiation_level/M.metabolism_efficiency,EFFECT_IRRADIATE,0)
	..()

/datum/reagent/uranium/reaction_turf(turf/T, reac_volume)
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
	color = "#C7C7C7"
	taste_description = "the colour blue and regret"
	irradiation_level = 2*REM
	process_flags = ORGANIC | SYNTHETIC
	random_unrestricted = FALSE

/datum/reagent/bluespace
	name = "Bluespace Dust"
	description = "A dust composed of microscopic bluespace crystals, with minor space-warping properties."
	reagent_state = SOLID
	color = "#0000CC"
	taste_description = "fizzling blue"
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/bluespace/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == TOUCH || method == VAPOR)
		do_teleport(M, get_turf(M), (reac_volume / 5), asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)
	..()

/datum/reagent/bluespace/on_mob_life(mob/living/carbon/M)
	if(current_cycle > 10 && prob(15))
		to_chat(M, "<span class='warning'>You feel unstable...</span>")
		M.Jitter(2)
		current_cycle = 1
		addtimer(CALLBACK(M, /mob/living/proc/bluespace_shuffle), 30)
	..()

/mob/living/proc/bluespace_shuffle()
	do_teleport(src, get_turf(src), 5, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)

/datum/reagent/aluminium
	name = "Aluminium"
	description = "A silvery white and ductile member of the boron group of chemical elements."
	reagent_state = SOLID
	color = "#A8A8A8"
	taste_description = "metal"
	random_unrestricted = FALSE

/datum/reagent/silicon
	name = "Silicon"
	description = "A tetravalent metalloid, silicon is less reactive than its chemical analog carbon."
	reagent_state = SOLID
	color = "#A8A8A8"
	taste_mult = 0
	random_unrestricted = FALSE

/datum/reagent/fuel
	name = "Welding fuel"
	description = "Required for welders. Flammable."
	color = "#660000"
	taste_description = "gross metal"
	glass_icon_state = "dr_gibb_glass"
	glass_name = "glass of welder fuel"
	glass_desc = "Unless you're an industrial tool, this is probably not safe for consumption."
	process_flags = ORGANIC | SYNTHETIC
	random_unrestricted = FALSE

/datum/reagent/fuel/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == TOUCH || method == VAPOR)
		M.adjust_fire_stacks(reac_volume / 10)
		return
	..()

/datum/reagent/fuel/on_mob_life(mob/living/carbon/M)
	M.adjustToxLoss(1, 0)
	..()
	return TRUE

/datum/reagent/space_cleaner
	name = "Space cleaner"
	description = "A compound used to clean things. Now with 50% more sodium hypochlorite! Not safe for consumption. If ingested, contact poison control immediately"
	color = "#A5F0EE"
	taste_description = "sourness"
	reagent_weight = 0.6
	var/toxic = FALSE

/datum/reagent/space_cleaner/on_mob_life(mob/living/carbon/M)
	if(toxic)
		M.adjustToxLoss(1, 0)
	..()
	return TRUE

/datum/reagent/space_cleaner/reaction_obj(obj/O, reac_volume)
	if(istype(O, /obj/effect/decal/cleanable))
		qdel(O)
	else
		if(O)
			O.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
			SEND_SIGNAL(O, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)

/datum/reagent/space_cleaner/reaction_turf(turf/T, reac_volume)
	if(reac_volume >= 1)
		T.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
		SEND_SIGNAL(T, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
		for(var/obj/effect/decal/cleanable/C in T)
			qdel(C)

		for(var/mob/living/simple_animal/slime/M in T)
			M.adjustToxLoss(rand(5,10))

/datum/reagent/space_cleaner/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == TOUCH || method == VAPOR)
		M.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				H.adjust_hygiene((30 * reac_volume) / (3 + reac_volume))
				if(H.lip_style)
					H.lip_style = null
					H.update_body()
			for(var/obj/item/I in C.held_items)
				SEND_SIGNAL(I, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
			if(C.wear_mask)
				if(SEND_SIGNAL(C.wear_mask, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD))
					C.update_inv_wear_mask()
			if(ishuman(M))
				var/mob/living/carbon/human/H = C
				if(H.head)
					if(SEND_SIGNAL(H.head, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD))
						H.update_inv_head()
				if(H.wear_suit)
					if(SEND_SIGNAL(H.wear_suit, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD))
						H.update_inv_wear_suit()
				else if(H.w_uniform)
					if(SEND_SIGNAL(H.w_uniform, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD))
						H.update_inv_w_uniform()
				if(H.shoes)
					if(SEND_SIGNAL(H.shoes, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD))
						H.update_inv_shoes()
				H.wash_cream()
			SEND_SIGNAL(M, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
	else if(method == INGEST || method == INJECT)
		toxic = TRUE

/datum/reagent/space_cleaner/ez_clean
	name = "EZ Clean"
	description = "A powerful, acidic cleaner sold by Waffle Co. Affects organic matter while leaving other objects unaffected."
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	taste_description = "acid"

/datum/reagent/space_cleaner/ez_clean/on_mob_life(mob/living/carbon/M)
	M.adjustBruteLoss(3.33)
	M.adjustFireLoss(3.33)
	M.adjustToxLoss(3.33)
	..()

/datum/reagent/space_cleaner/ez_clean/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	..()
	if((method == TOUCH || method == VAPOR) && !issilicon(M))
		M.adjustBruteLoss(1.5)
		M.adjustFireLoss(1.5)

/datum/reagent/cryptobiolin
	name = "Cryptobiolin"
	description = "Cryptobiolin causes confusion and dizziness."
	color = "#C8A5DC"
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	taste_description = "sourness"

/datum/reagent/cryptobiolin/on_mob_life(mob/living/carbon/M)
	M.Dizzy(1)
	if(!M.confused)
		M.confused = 1
	M.confused = max(M.confused, 20)
	..()

/datum/reagent/impedrezene
	name = "Impedrezene"
	description = "Impedrezene is a narcotic that impedes one's ability by slowing down the higher brain cell functions."
	color = "#C8A5DC"
	taste_description = "numbness"

/datum/reagent/impedrezene/on_mob_life(mob/living/carbon/M)
	M.jitteriness = max(M.jitteriness-5,0)
	if(prob(80))
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2*REM)
	if(prob(50))
		M.drowsyness = max(M.drowsyness, 3)
	if(prob(10))
		M.emote("drool")
	..()

/datum/reagent/nanomachines
	name = "Nanomachines"
	description = "Microscopic construction robots."
	color = "#535E66"
	can_synth = FALSE
	taste_description = "sludge"

/datum/reagent/nanomachines/reaction_mob(mob/living/L, method=TOUCH, reac_volume, show_message = 1, touch_protection = 0)
	if(method==PATCH || method==INGEST || method==INJECT || (method == VAPOR && prob(min(reac_volume,100)*(1 - touch_protection))))
		L.ForceContractDisease(new /datum/disease/transformation/robot(), FALSE, TRUE)

/datum/reagent/xenomicrobes
	name = "Xenomicrobes"
	description = "Microbes with an entirely alien cellular structure."
	color = "#535E66"
	can_synth = FALSE
	taste_description = "sludge"

/datum/reagent/xenomicrobes/reaction_mob(mob/living/L, method=TOUCH, reac_volume, show_message = 1, touch_protection = 0)
	if(method==PATCH || method==INGEST || method==INJECT || (method == VAPOR && prob(min(reac_volume,100)*(1 - touch_protection))))
		L.ForceContractDisease(new /datum/disease/transformation/xeno(), FALSE, TRUE)

/datum/reagent/fungalspores
	name = "Tubercle bacillus Cosmosis microbes"
	description = "Active fungal spores."
	color = "#92D17D"
	can_synth = FALSE
	taste_description = "slime"
	random_unrestricted = FALSE

/datum/reagent/fungalspores/reaction_mob(mob/living/L, method=TOUCH, reac_volume, show_message = 1, touch_protection = 0)
	if(method==PATCH || method==INGEST || method==INJECT || (method == VAPOR && prob(min(reac_volume,100)*(1 - touch_protection))))
		L.ForceContractDisease(new /datum/disease/tuberculosis(), FALSE, TRUE)

/datum/reagent/snail
	name = "Agent-S"
	description = "Virological agent that infects the subject with Gastrolosis."
	color = "#003300"
	taste_description = "goo"
	can_synth = FALSE

/datum/reagent/snail/reaction_mob(mob/living/L, method=TOUCH, reac_volume, show_message = 1, touch_protection = 0)
	if(method==PATCH || method==INGEST || method==INJECT || (method == VAPOR && prob(min(reac_volume,100)*(1 - touch_protection))))
		L.ForceContractDisease(new /datum/disease/gastrolosis(), FALSE, TRUE)

/datum/reagent/fluorosurfactant
	name = "Fluorosurfactant"
	description = "A perfluoronated sulfonic acid that forms a foam when mixed with water."
	color = "#9E6B38"
	taste_description = "metal"
	random_unrestricted = FALSE

/datum/reagent/foaming_agent
	name = "Foaming agent"
	description = "An agent that yields metallic foam when mixed with light metal and a strong acid."
	reagent_state = SOLID
	color = "#664B63"
	taste_description = "metal"
	random_unrestricted = FALSE

/datum/reagent/smart_foaming_agent
	name = "Smart foaming agent"
	description = "An agent that yields metallic foam which conforms to area boundaries when mixed with light metal and a strong acid."
	reagent_state = SOLID
	color = "#664B63"
	taste_description = "metal"
	random_unrestricted = FALSE

/datum/reagent/ammonia
	name = "Ammonia"
	description = "A caustic substance commonly used in fertilizer or household cleaners."
	reagent_state = GAS
	color = "#404030"
	taste_description = "mordant"
	random_unrestricted = FALSE

/datum/reagent/diethylamine
	name = "Diethylamine"
	description = "A secondary amine, mildly corrosive."
	color = "#604030"
	taste_description = "iron"
	random_unrestricted = FALSE

/datum/reagent/carbondioxide
	name = "Carbon Dioxide"
	reagent_state = GAS
	description = "A gas commonly produced by burning carbon fuels. You're constantly producing this in your lungs."
	color = "#B0B0B0"
	taste_description = "something unknowable"
	random_unrestricted = FALSE

/datum/reagent/carbondioxide/reaction_obj(obj/O, reac_volume)
	if((!O) || (!reac_volume))
		return 0
	var/temp = holder ? holder.chem_temp : T20C
	O.atmos_spawn_air("co2=[reac_volume/5];TEMP=[temp]")

/datum/reagent/carbondioxide/reaction_turf(turf/open/T, reac_volume)
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
	taste_description = "sweetness"

/datum/reagent/nitrous_oxide/reaction_obj(obj/O, reac_volume)
	if((!O) || (!reac_volume))
		return 0
	var/temp = holder ? holder.chem_temp : T20C
	O.atmos_spawn_air("n2o=[reac_volume/5];TEMP=[temp]")

/datum/reagent/nitrous_oxide/reaction_turf(turf/open/T, reac_volume)
	if(istype(T))
		var/temp = holder ? holder.chem_temp : T20C
		T.atmos_spawn_air("n2o=[reac_volume/5];TEMP=[temp]")

/datum/reagent/nitrous_oxide/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == VAPOR)
		M.drowsyness += max(round(reac_volume, 1), 2)

/datum/reagent/nitrous_oxide/on_mob_life(mob/living/carbon/M)
	M.drowsyness += 2
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.blood_volume = max(H.blood_volume - 10, 0)
	if(prob(20))
		M.losebreath += 2
		M.confused = min(M.confused + 2, 5)
	..()

/datum/reagent/stimulum
	name = "Stimulum"
	description = "An unstable experimental gas that greatly increases the energy of those that inhale it, while dealing increasing toxin damage over time."
	reagent_state = GAS
	metabolization_rate = REAGENTS_METABOLISM * 0.5
	color = "E1A116"
	taste_description = "sourness"

/datum/reagent/stimulum/on_mob_metabolize(mob/living/L)
	..()
	ADD_TRAIT(L, TRAIT_STUNIMMUNE, type)
	ADD_TRAIT(L, TRAIT_SLEEPIMMUNE, type)
	ADD_TRAIT(L, TRAIT_IGNOREDAMAGESLOWDOWN, type)
	ADD_TRAIT(L, TRAIT_NOSTAMCRIT, type)
	ADD_TRAIT(L, TRAIT_NOLIMBDISABLE, type)
	ADD_TRAIT(L, TRAIT_NOBLOCK, type)

/datum/reagent/stimulum/on_mob_end_metabolize(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_STUNIMMUNE, type)
	REMOVE_TRAIT(L, TRAIT_SLEEPIMMUNE, type)
	REMOVE_TRAIT(L, TRAIT_IGNOREDAMAGESLOWDOWN, type)
	REMOVE_TRAIT(L, TRAIT_NOSTAMCRIT, type)
	REMOVE_TRAIT(L, TRAIT_NOLIMBDISABLE, type)
	REMOVE_TRAIT(L, TRAIT_NOBLOCK, type)
	..()

/datum/reagent/stimulum/on_mob_life(mob/living/carbon/M)
	M.adjustStaminaLoss(-2*REM, 0)
	..()

/datum/reagent/nitryl
	name = "Nitryl"
	description = "A highly reactive gas that makes you feel faster."
	reagent_state = GAS
	metabolization_rate = REAGENTS_METABOLISM * 0.5
	color = "90560B"
	taste_description = "burning"

/datum/reagent/nitryl/on_mob_metabolize(mob/living/L)
	..()
	L.add_movespeed_modifier(type, update=TRUE, priority=100, multiplicative_slowdown=-1, blacklisted_movetypes=(FLYING|FLOATING))

/datum/reagent/nitryl/on_mob_end_metabolize(mob/living/L)
	L.remove_movespeed_modifier(type)
	..()




/datum/reagent/colorful_reagent/powder
	name = "Mundane Powder"
	var/colorname = "none"
	description = "A powder that is used for coloring things."
	reagent_state = SOLID
	color = "#FFFFFF"
	taste_description = "the back of class"

/datum/reagent/colorful_reagent/powder/New()
	if(colorname == "none")
		description = "A rather mundane-looking powder. It doesn't look like it'd color much of anything..."
	else if(colorname == "invisible")
		description = "An invisible powder. Unfortunately, since it's invisible, it doesn't look like it'd color much of anything..."
	else
		description = "\An [colorname] powder, used for coloring things [colorname]."

/datum/reagent/colorful_reagent/powder/red
	name = "Red Powder"
	colorname = "red"
	color = "#DA0000"
	random_color_list = list("#FC7474")

/datum/reagent/colorful_reagent/powder/orange
	name = "Orange Powder"
	colorname = "orange"
	color = "#FF9300"
	random_color_list = list("#FF9300")

/datum/reagent/colorful_reagent/powder/yellow
	name = "Yellow Powder"
	colorname = "yellow"
	color = "#FFF200"
	random_color_list = list("#FFF200")

/datum/reagent/colorful_reagent/powder/green
	name = "Green Powder"
	colorname = "green"
	color = "#A8E61D"
	random_color_list = list("#A8E61D")

/datum/reagent/colorful_reagent/powder/blue
	name = "Blue Powder"
	colorname = "blue"
	color = "#00B7EF"
	random_color_list = list("#00B7EF")

/datum/reagent/colorful_reagent/powder/purple
	name = "Purple Powder"
	colorname = "purple"
	color = "#DA00FF"
	random_color_list = list("#BD8FC4")

/datum/reagent/colorful_reagent/powder/invisible
	name = "Invisible Powder"
	colorname = "invisible"
	color = "#FFFFFF00"
	random_color_list = list(null)

/datum/reagent/colorful_reagent/powder/black
	name = "Black Powder"
	colorname = "black"
	color = "#1C1C1C"
	random_color_list = list("#404040")

/datum/reagent/colorful_reagent/powder/white
	name = "White Powder"
	colorname = "white"
	color = "#FFFFFF"
	random_color_list = list("#FFFFFF")

 /* used by crayons, can't color living things but still used for stuff like food recipes */

/datum/reagent/colorful_reagent/powder/red/crayon
	name = "Red Crayon Powder"
	can_colour_mobs = FALSE
	random_unrestricted = FALSE

/datum/reagent/colorful_reagent/powder/orange/crayon
	name = "Orange Crayon Powder"
	can_colour_mobs = FALSE
	random_unrestricted = FALSE

/datum/reagent/colorful_reagent/powder/yellow/crayon
	name = "Yellow Crayon Powder"
	can_colour_mobs = FALSE
	random_unrestricted = FALSE

/datum/reagent/colorful_reagent/powder/green/crayon
	name = "Green Crayon Powder"
	can_colour_mobs = FALSE
	random_unrestricted = FALSE

/datum/reagent/colorful_reagent/powder/blue/crayon
	name = "Blue Crayon Powder"
	can_colour_mobs = FALSE
	random_unrestricted = FALSE

/datum/reagent/colorful_reagent/powder/purple/crayon
	name = "Purple Crayon Powder"
	can_colour_mobs = FALSE
	random_unrestricted = FALSE



/datum/reagent/colorful_reagent/powder/black/crayon
	name = "Black Crayon Powder"
	can_colour_mobs = FALSE
	random_unrestricted = FALSE

/datum/reagent/colorful_reagent/powder/white/crayon
	name = "White Crayon Powder"
	can_colour_mobs = FALSE
	random_unrestricted = FALSE



/datum/reagent/plantnutriment
	name = "Generic nutriment"
	description = "Some kind of nutriment. You can't really tell what it is. You should probably report it, along with how you obtained it."
	color = "#000000"
	var/tox_prob = 0
	taste_description = "plant food"

/datum/reagent/plantnutriment/on_mob_life(mob/living/carbon/M)
	if(prob(tox_prob))
		M.adjustToxLoss(1*REM, 0)
		. = 1
	..()

/datum/reagent/plantnutriment/eznutriment
	name = "E-Z-Nutrient"
	description = "Cheap and extremely common type of plant nutriment."
	color = "#376400"
	tox_prob = 10

/datum/reagent/plantnutriment/left4zednutriment
	name = "Left 4 Zed"
	description = "Unstable nutriment that makes plants mutate more often than usual."
	color = "#1A1E4D"
	tox_prob = 25

/datum/reagent/plantnutriment/robustharvestnutriment
	name = "Robust Harvest"
	description = "Very potent nutriment that prevents plants from mutating."
	color = "#9D9D00"
	tox_prob = 15











/datum/reagent/oil
	name = "Oil"
	description = "Burns in a small smoky fire, mostly used to get Ash."
	reagent_state = LIQUID
	color = "#C8A5DC"
	taste_description = "oil"
	process_flags = ORGANIC | SYNTHETIC
	random_unrestricted = FALSE

/datum/reagent/stable_plasma
	name = "Stable Plasma"
	description = "Non-flammable plasma locked into a liquid form that cannot ignite or become gaseous/solid."
	reagent_state = LIQUID
	color = "#C8A5DC"
	taste_description = "bitterness"
	taste_mult = 1.5
	process_flags = ORGANIC | SYNTHETIC
	random_unrestricted = FALSE

/datum/reagent/stable_plasma/on_mob_life(mob/living/carbon/C)
	C.adjustPlasma(10)
	..()

/datum/reagent/iodine
	name = "Iodine"
	description = "Commonly added to table salt as a nutrient. On its own it tastes far less pleasing."
	reagent_state = LIQUID
	color = "#C8A5DC"
	taste_description = "metal"
	random_unrestricted = FALSE

/datum/reagent/carpet
	name = "Carpet"
	description = "For those that need a more creative way to roll out a red carpet."
	reagent_state = LIQUID
	color = "#C8A5DC"
	taste_description = "carpet"

/datum/reagent/carpet/reaction_turf(turf/T, reac_volume)
	if(isplatingturf(T) || istype(T, /turf/open/floor/plasteel))
		var/turf/open/floor/F = T
		F.PlaceOnTop(/turf/open/floor/carpet, flags = CHANGETURF_INHERIT_AIR)
	..()

/datum/reagent/bromine
	name = "Bromine"
	description = "A brownish liquid that's highly reactive. Useful for stopping free radicals, but not intended for human consumption."
	reagent_state = LIQUID
	color = "#C8A5DC"
	taste_description = "chemicals"
	random_unrestricted = FALSE

/datum/reagent/phenol
	name = "Phenol"
	description = "An aromatic ring of carbon with a hydroxyl group. A useful precursor to some medicines, but has no healing properties on its own."
	reagent_state = LIQUID
	color = "#C8A5DC"
	taste_description = "acid"
	random_unrestricted = FALSE

/datum/reagent/ash
	name = "Ash"
	description = "Supposedly phoenixes rise from these, but you've never seen it."
	reagent_state = LIQUID
	color = "#C8A5DC"
	taste_description = "ash"
	random_unrestricted = FALSE

/datum/reagent/acetone
	name = "Acetone"
	description = "A slick, slightly carcinogenic liquid. Has a multitude of mundane uses in everyday life."
	reagent_state = LIQUID
	color = "#C8A5DC"
	taste_description = "acid"
	random_unrestricted = FALSE

/datum/reagent/colorful_reagent
	name = "Colorful Reagent"
	description = "Thoroughly sample the rainbow."
	reagent_state = LIQUID
	color = "#C8A5DC"
	var/list/random_color_list = list("#00aedb","#a200ff","#f47835","#d41243","#d11141","#00b159","#00aedb","#f37735","#ffc425","#008744","#0057e7","#d62d20","#ffa700")
	taste_description = "rainbows"
	var/can_colour_mobs = TRUE


/datum/reagent/colorful_reagent/on_mob_life(mob/living/carbon/M)
	if(can_colour_mobs)
		M.add_atom_colour(pick(random_color_list), WASHABLE_COLOUR_PRIORITY)
	return ..()

/datum/reagent/colorful_reagent/reaction_mob(mob/living/M, reac_volume)
	if(can_colour_mobs)
		M.add_atom_colour(pick(random_color_list), WASHABLE_COLOUR_PRIORITY)
	..()

/datum/reagent/colorful_reagent/reaction_obj(obj/O, reac_volume)
	if(O)
		O.add_atom_colour(pick(random_color_list), WASHABLE_COLOUR_PRIORITY)
	..()

/datum/reagent/colorful_reagent/reaction_turf(turf/T, reac_volume)
	if(T)
		T.add_atom_colour(pick(random_color_list), WASHABLE_COLOUR_PRIORITY)
	..()

/datum/reagent/hair_dye
	name = "Quantum Hair Dye"
	description = "Has a high chance of making you look like a mad scientist."
	reagent_state = LIQUID
	color = "#C8A5DC"
	var/list/potential_colors = list("0ad","a0f","f73","d14","d14","0b5","0ad","f73","fc2","084","05e","d22","fa0")
	taste_description = "sourness"

/datum/reagent/hair_dye/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
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
	taste_description = "sourness"

/datum/reagent/barbers_aid/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == TOUCH || method == VAPOR)
		if(M && ishuman(M))
			var/mob/living/carbon/human/H = M
			var/datum/sprite_accessory/hair/picked_hair = pick(GLOB.hair_styles_list)
			var/datum/sprite_accessory/facial_hair/picked_beard = pick(GLOB.facial_hair_styles_list)
			H.hair_style = picked_hair
			H.facial_hair_style = picked_beard
			H.update_hair()

/datum/reagent/concentrated_barbers_aid
	name = "Concentrated Barber's Aid"
	description = "A concentrated solution to hair loss across the world."
	reagent_state = LIQUID
	color = "#C8A5DC"
	taste_description = "sourness"

/datum/reagent/concentrated_barbers_aid/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == TOUCH || method == VAPOR)
		if(M && ishuman(M))
			var/mob/living/carbon/human/H = M
			H.hair_style = "Very Long Hair"
			H.facial_hair_style = "Beard (Very Long)"
			H.update_hair()

/datum/reagent/saltpetre
	name = "Saltpetre"
	description = "Volatile. Controversial. Third Thing."
	reagent_state = LIQUID
	color = "#60A584"
	taste_description = "cool salt"
	random_unrestricted = FALSE

/datum/reagent/lye
	name = "Lye"
	description = "Also known as sodium hydroxide. As a profession making this is somewhat underwhelming."
	reagent_state = LIQUID
	color = "#FFFFD6"
	taste_description = "acid"
	random_unrestricted = FALSE

/datum/reagent/drying_agent
	name = "Drying agent"
	description = "A desiccant. Can be used to dry things."
	reagent_state = LIQUID
	color = "#A70FFF"
	taste_description = "dryness"
	random_unrestricted = FALSE

/datum/reagent/drying_agent/reaction_turf(turf/open/T, reac_volume)
	if(istype(T))
		T.MakeDry(ALL, TRUE, reac_volume * 5 SECONDS)

/datum/reagent/drying_agent/reaction_obj(obj/O, reac_volume)
	if(O.type == /obj/item/clothing/shoes/galoshes)
		var/t_loc = get_turf(O)
		qdel(O)
		new /obj/item/clothing/shoes/galoshes/dry(t_loc)



/datum/reagent/toxin/mutagen/mutagenvirusfood
	name = "mutagenic agar"
	color = "#A3C00F"
	taste_description = "sourness"

/datum/reagent/toxin/mutagen/mutagenvirusfood/sugar
	name = "sucrose agar"
	color = "#41B0C0"
	taste_description = "sweetness"

/datum/reagent/medicine/synaptizine/synaptizinevirusfood
	name = "virus rations"
	color = "#D18AA5"
	taste_description = "bitterness"

/datum/reagent/toxin/plasma/plasmavirusfood
	name = "virus plasma"
	color = "#A69DA9"
	taste_description = "bitterness"
	taste_mult = 1.5

/datum/reagent/toxin/plasma/plasmavirusfood/weak
	name = "weakened virus plasma"
	color = "#CEC3C6"
	taste_description = "bitterness"
	taste_mult = 1.5

/datum/reagent/uranium/uraniumvirusfood
	name = "decaying uranium gel"
	color = "#67ADBA"
	taste_description = "the inside of a reactor"

/datum/reagent/uranium/uraniumvirusfood/unstable
	name = "unstable uranium gel"
	color = "#2FF2CB"
	taste_description = "the inside of a reactor"

/datum/reagent/uranium/uraniumvirusfood/stable
	name = "stable uranium gel"
	color = "#04506C"
	taste_description = "the inside of a reactor"

/datum/reagent/consumable/laughter/laughtervirusfood
	name = "anomolous virus food"
	color = "#ffa6ff"
	taste_description = "a bad idea"

/datum/reagent/consumable/virus_food/advvirusfood
	name = "highly unstable virus food"
	color = "#ffffff"
	taste_description = "an EXTREMELY bad idea"
	can_synth = FALSE

/datum/reagent/consumable/virus_food/viralbase
	name = "Experimental viral base"
	description = "Recently discovered by Nanotrasen's top scientists after years of research, this substance can be used as the base for extremely rare and extremely dangerous viruses once exposed to uranium."
	color = "#fff0da"
	taste_description = "tears of scientists"
	can_synth = FALSE



/datum/reagent/royal_bee_jelly
	name = "royal bee jelly"
	description = "Royal Bee Jelly, if injected into a Queen Space Bee said bee will split into two bees."
	color = "#00ff80"
	taste_description = "strange honey"

/datum/reagent/royal_bee_jelly/on_mob_life(mob/living/carbon/M)
	if(prob(2))
		M.say(pick("Bzzz...","BZZ BZZ","Bzzzzzzzzzzz..."), forced = "royal bee jelly")
	..()



/datum/reagent/romerol
	name = "Romerol"

	description = "Romerol is a highly experimental bioterror agent \
		which causes dormant nodules to be etched into the grey matter of \
		the subject. These nodules only become active upon death of the \
		host, upon which, the secondary structures activate and take control \
		of the host body."
	color = "#123524"
	metabolization_rate = INFINITY
	can_synth = FALSE
	taste_description = "brains"

/datum/reagent/romerol/reaction_mob(mob/living/carbon/human/H, method=TOUCH, reac_volume)

	if(!H.getorganslot(ORGAN_SLOT_ZOMBIE))
		var/obj/item/organ/zombie_infection/nodamage/ZI = new()
		ZI.Insert(H)
	..()

/datum/reagent/magillitis
	name = "Magillitis"
	description = "An experimental serum which causes rapid muscular growth in Hominidae. Side-affects may include hypertrichosis, violent outbursts, and an unending affinity for bananas."
	reagent_state = LIQUID
	color = "#00f041"
	can_synth = FALSE

/datum/reagent/magillitis/on_mob_life(mob/living/carbon/M)
	..()
	if((ismonkey(M) || ishuman(M)) && current_cycle >= 10)
		M.gorillize()

/datum/reagent/growthserum
	name = "Growth Serum"
	description = "A commercial chemical designed to help older men in the bedroom."
	color = "#ff0000"
	var/current_size = 1
	taste_description = "bitterness"

/datum/reagent/growthserum/on_mob_life(mob/living/carbon/H)
	var/newsize = current_size
	switch(volume)
		if(0 to 19)
			newsize = 1.25
		if(20 to 49)
			newsize = 1.5
		if(50 to 99)
			newsize = 2
		if(100 to 199)
			newsize = 2.5
		if(200 to INFINITY)
			newsize = 3.5

	H.resize = newsize/current_size
	current_size = newsize
	H.update_transform()
	..()

/datum/reagent/growthserum/on_mob_end_metabolize(mob/living/M)
	M.resize = 1/current_size
	M.update_transform()
	..()

/datum/reagent/plastic_polymers
	name = "plastic polymers"
	description = "the petroleum based components of plastic."
	color = "#f7eded"
	taste_description = "plastic"
	random_unrestricted = FALSE

/datum/reagent/glitter
	name = "generic glitter"
	description = "if you can see this description, contact a coder."
	color = "#FFFFFF"
	taste_description = "plastic"
	reagent_state = SOLID
	var/glitter_type = /obj/effect/decal/cleanable/glitter
	random_unrestricted = FALSE

/datum/reagent/glitter/reaction_turf(turf/T, reac_volume)
	if(!istype(T))
		return
	new glitter_type(T)

/datum/reagent/glitter/pink
	name = "pink glitter"
	description = "pink sparkles that get everywhere"
	color = "#ff8080"
	glitter_type = /obj/effect/decal/cleanable/glitter/pink

/datum/reagent/glitter/white
	name = "white glitter"
	description = "white sparkles that get everywhere"
	glitter_type = /obj/effect/decal/cleanable/glitter/white

/datum/reagent/glitter/blue
	name = "blue glitter"
	description = "blue sparkles that get everywhere"
	color = "#4040FF"
	glitter_type = /obj/effect/decal/cleanable/glitter/blue

/datum/reagent/pax
	name = "Pax"
	description = "A colorless liquid that suppresses violence in its subjects."
	color = "#AAAAAA55"
	taste_description = "water"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM

/datum/reagent/pax/on_mob_metabolize(mob/living/L)
	..()
	ADD_TRAIT(L, TRAIT_PACIFISM, type)

/datum/reagent/pax/on_mob_end_metabolize(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_PACIFISM, type)
	..()

/datum/reagent/bz_metabolites
	name = "BZ metabolites"
	description = "A harmless metabolite of BZ gas"
	color = "#FAFF00"
	taste_description = "acrid cinnamon"
	metabolization_rate = 0.2 * REAGENTS_METABOLISM
	random_unrestricted = FALSE

/datum/reagent/bz_metabolites/on_mob_metabolize(mob/living/L)
	..()
	ADD_TRAIT(L, CHANGELING_HIVEMIND_MUTE, type)

/datum/reagent/bz_metabolites/on_mob_end_metabolize(mob/living/L)
	..()
	REMOVE_TRAIT(L, CHANGELING_HIVEMIND_MUTE, type)

/datum/reagent/bz_metabolites/on_mob_life(mob/living/L)
	if(L.mind)
		var/datum/antagonist/changeling/changeling = L.mind.has_antag_datum(/datum/antagonist/changeling)
		if(changeling)
			changeling.chem_charges = max(changeling.chem_charges-2, 0)
	return ..()

/datum/reagent/concentrated_bz
	name = "Concentrated BZ"
	description = "A hyperconcentrated liquid form of BZ gas, known to cause an extremely adverse reaction to changelings. Also causes minor brain damage."
	color = "#FAFF00"
	taste_description = "acrid cinnamon"
	random_unrestricted = FALSE

/datum/reagent/concentrated_bz/on_mob_metabolize(mob/living/L)
	..()
	ADD_TRAIT(L, CHANGELING_HIVEMIND_MUTE, type)

/datum/reagent/concentrated_bz/on_mob_end_metabolize(mob/living/L)
	..()
	REMOVE_TRAIT(L, CHANGELING_HIVEMIND_MUTE, type)

/datum/reagent/concentrated_bz/on_mob_life(mob/living/L)
	if(L.mind)
		var/datum/antagonist/changeling/changeling = L.mind.has_antag_datum(/datum/antagonist/changeling)
		if(changeling)
			changeling.chem_charges = max(changeling.chem_charges-2, 0)
			if(prob(30))
				L.losebreath += 1
				L.adjustOxyLoss(3,5)
				L.emote("gasp")
				to_chat(L, "<font size=3 color=red><b>You can't breathe!</b></font>")

		L.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2, 50)
	return ..()

/datum/reagent/fake_cbz
	name = "Concentrated BZ"
	description = "A hyperconcentrated liquid form of BZ gas, known to cause an extremely adverse reaction to changelings. Also causes minor brain damage."
	color = "#FAFF00"
	taste_description = "acrid cinnamon"
	random_unrestricted = FALSE

/datum/reagent/fake_cbz/on_mob_life(mob/living/L)
	L.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2, 50)
	if(prob(15))
		to_chat(L, "You don't feel much of anything")

/datum/reagent/pax/peaceborg
	name = "synthpax"
	description = "A colorless liquid that suppresses violence in its subjects. Cheaper to synthesize than normal Pax, but wears off faster."
	metabolization_rate = 1.5 * REAGENTS_METABOLISM

/datum/reagent/peaceborg
	can_synth = FALSE
	random_unrestricted = FALSE

/datum/reagent/peaceborg/confuse
	name = "Dizzying Solution"
	description = "Makes the target off balance and dizzy"
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	taste_description = "dizziness"
	can_synth = TRUE
	random_unrestricted = TRUE

/datum/reagent/peaceborg/confuse/on_mob_life(mob/living/carbon/M)
	if(M.confused < 6)
		M.confused = CLAMP(M.confused + 3, 0, 5)
	if(M.dizziness < 6)
		M.dizziness = CLAMP(M.dizziness + 3, 0, 5)
	if(prob(20))
		to_chat(M, "You feel confused and disorientated.")
	..()

/datum/reagent/peaceborg/inabizine
	name = "Inabizine"
	description = "Induces muscle relaxation causing the target to drop items and fall on the ground"
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	taste_description = "relaxing"

/datum/reagent/peaceborg/inabizine/on_mob_life(mob/living/carbon/M)
	if(prob(33))
		M.Stun(20, 0)
		M.blur_eyes(5)
	if(prob(33))
		M.Knockdown(2 SECONDS)
	if(prob(20))
		to_chat(M, "Your muscles relax...")
	..()

/datum/reagent/peaceborg/tire
	name = "Tiring Solution"
	description = "An extremely weak stamina-toxin that tires out the target. Completely harmless."
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	taste_description = "tiredness"
	can_synth = TRUE

/datum/reagent/peaceborg/tire/on_mob_life(mob/living/carbon/M)
	var/healthcomp = (100 - M.health)
	if(M.getStaminaLoss() < (45 - healthcomp))
		M.adjustStaminaLoss(10)
	if(prob(30))
		to_chat(M, "You should sit down and take a rest...")
	..()

/datum/reagent/tranquility
	name = "Tranquility"
	description = "A highly mutative liquid of unknown origin."
	color = "#9A6750"
	taste_description = "inner peace"
	can_synth = FALSE

/datum/reagent/tranquility/reaction_mob(mob/living/L, method=TOUCH, reac_volume, show_message = 1, touch_protection = 0)
	if(method==PATCH || method==INGEST || method==INJECT || (method == VAPOR && prob(min(reac_volume,100)*(1 - touch_protection))))
		L.ForceContractDisease(new /datum/disease/transformation/gondola(), FALSE, TRUE)
/datum/reagent/eldritch //unholy water, but for eldritch cultists. why couldn't they have both just used the same reagent? who knows. maybe nar'sie is considered to be too "mainstream" of a god to worship in the cultist community.
	name = "Eldritch Essence"
	description = "A strange liquid that defies the laws of physics. It re-energizes and heals those who can see beyond this fragile reality, but is incredibly harmful to the closed-minded. It metabolizes very quickly."
	taste_description = "Ag'hsj'saje'sh"
	color = "#1f8016"
	metabolization_rate = 2.5 * REAGENTS_METABOLISM  //1u/tick

/datum/reagent/eldritch/on_mob_life(mob/living/carbon/M)
	if(IS_HERETIC(M))
		M.drowsyness = max(M.drowsyness-5, 0)
		M.AdjustAllImmobility(-40, FALSE)
		M.adjustStaminaLoss(-10, FALSE)
		M.adjustToxLoss(-2, FALSE)
		M.adjustOxyLoss(-2, FALSE)
		M.adjustBruteLoss(-2, FALSE)
		M.adjustFireLoss(-2, FALSE)
		if(ishuman(M) && M.blood_volume < BLOOD_VOLUME_NORMAL)
			M.blood_volume += 3
	else
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3, 150)
		M.adjustToxLoss(2, FALSE)
		M.adjustFireLoss(2, FALSE)
		M.adjustOxyLoss(2, FALSE)
		M.adjustBruteLoss(2, FALSE)
	return ..()


/datum/reagent/liquidadamantine
	name = "Liquid Adamantine"
	description = "A legengary lifegiving metal liquified."
	color = "#10cca6"
	taste_description = "lifegiiving metal"
	can_synth = FALSE
	random_unrestricted = FALSE

/datum/reagent/spider_extract
	name = "Spider Extract"
	description = "A highly specialized extract coming from the Australicus sector, used to create broodmother spiders."
	color = "#ED2939"
	taste_description = "upside down"
	can_synth = FALSE

/datum/reagent/consumable/ratlight
	name = "Ratvarian Light"
	description = "A special concoction said to have been blessed by an ancient god. Makes the consumer glow with literal enlightenment."
	color = "#B5A642"
	taste_description = "enlightenment"
	metabolization_rate = 0.8 * REAGENTS_METABOLISM
	var/datum/language_holder/prev_language

/datum/reagent/consumable/ratlight/reaction_mob(mob/living/M)
	M.set_light(2)
	..()

/datum/reagent/consumable/ratlight/on_mob_life(mob/living/carbon/M)
	if(prob(10))
		playsound(M, "scripture_tier_up", 50, 1)
	..()

/datum/reagent/consumable/ratlight/on_mob_metabolize(mob/living/L)
	L.add_blocked_language(subtypesof(/datum/language/) - /datum/language/ratvar, LANGUAGE_REAGENT)
	L.grant_language(/datum/language/ratvar, TRUE, TRUE, LANGUAGE_REAGENT)
	..()

/datum/reagent/consumable/ratlight/on_mob_end_metabolize(mob/living/L)
	L.remove_blocked_language(subtypesof(/datum/language/), LANGUAGE_REAGENT)
	L.remove_language(/datum/language/ratvar, TRUE, TRUE, LANGUAGE_REAGENT)
	L.set_light(-1)
	..()

/datum/reagent/invisium
	name = "Invisium"
	description = "a close to magic substance that turns the user invisible when consumed, your body will start whithering due to loss of reality"
	color = "#85E3E9"
	taste_description = "vanishing"
	metabolization_rate = 2 * REAGENTS_METABOLISM

/datum/reagent/invisium/on_mob_life(mob/living/carbon/M)

	if(M.alpha > 1)
		M.alpha -= 20
	else
		M.adjustBruteLoss(0.5,0)
		M.adjustFireLoss(0.5,0)
		M.adjustToxLoss(0.5,0)
		M.adjustCloneLoss(0.5,0)
	. = ..()

/datum/reagent/invisium/on_mob_end_metabolize(mob/living/L)
	L.alpha = 255
	L.Sleeping(20,0)
	. = ..()

/datum/reagent/bread
	name = "bread"
	description = "a strange as fuck substance that some fucking how turns you into a bread"
	color = "#d48b1e"
	taste_description = "tasty"
	metabolization_rate = 2 * REAGENTS_METABOLISM

/datum/reagent/bread/on_mob_life(mob/living/carbon/M)
	spawn_atom_to_turf(/obj/item/reagent_containers/food/snacks/store/bread/plain, M.loc, 1, FALSE)
	M.gib()
	. = ..()
