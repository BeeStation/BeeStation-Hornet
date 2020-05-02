/datum/species/plasmaman
	name = "Plasmaman"
	id = "plasmaman"
	say_mod = "rattles"
	sexes = 0
	meat = /obj/item/stack/sheet/mineral/plasma
	species_traits = list(NOBLOOD,NOTRANSSTING)
	inherent_traits = list(TRAIT_RESISTCOLD,TRAIT_RADIMMUNE,TRAIT_NOHUNGER,TRAIT_ALWAYS_CLEAN)
	inherent_biotypes = list(MOB_INORGANIC, MOB_HUMANOID)
	mutantlungs = /obj/item/organ/lungs/plasmaman
	mutanttongue = /obj/item/organ/tongue/bone/plasmaman
	mutantliver = /obj/item/organ/liver/plasmaman
	mutantstomach = /obj/item/organ/stomach/plasmaman
	burnmod = 1.5
	heatmod = 1.5
	brutemod = 1.5
	breathid = "tox"
	damage_overlay_type = ""//let's not show bloody wounds or burns over bones.
	var/internal_fire = FALSE //If the bones themselves are burning clothes won't help you much
	disliked_food = FRUIT
	liked_food = VEGETABLES
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC
	outfit_important_for_life = /datum/outfit/plasmaman

/datum/species/plasmaman/spec_life(mob/living/carbon/human/H)
	var/datum/gas_mixture/environment = H.loc.return_air()
	var/atmos_sealed = FALSE
	if (H.wear_suit && H.head && istype(H.wear_suit, /obj/item/clothing) && istype(H.head, /obj/item/clothing))
		var/obj/item/clothing/CS = H.wear_suit
		var/obj/item/clothing/CH = H.head
		if (CS.clothing_flags & CH.clothing_flags & STOPSPRESSUREDAMAGE)
			atmos_sealed = TRUE
	if((!istype(H.w_uniform, /obj/item/clothing/under/plasmaman) || !istype(H.head, /obj/item/clothing/head/foilhat/plasmaman) && !istype(H.head, /obj/item/clothing/head/helmet/space/plasmaman)) && !atmos_sealed)
		if(environment)
			if(environment.total_moles())
				if(environment.gases[/datum/gas/oxygen] && (environment.gases[/datum/gas/oxygen][MOLES]) >= 1) //Same threshhold that extinguishes fire
					H.adjust_fire_stacks(0.5)
					if(!H.on_fire && H.fire_stacks > 0)
						H.visible_message("<span class='danger'>[H]'s body reacts with the atmosphere and bursts into flames!</span>","<span class='userdanger'>Your body reacts with the atmosphere and bursts into flame!</span>")
					H.IgniteMob()
					internal_fire = TRUE
	else
		if(H.fire_stacks)
			var/obj/item/clothing/under/plasmaman/P = H.w_uniform
			if(istype(P))
				P.Extinguish(H)
				internal_fire = FALSE
		else
			internal_fire = FALSE
	H.update_fire()

/datum/species/plasmaman/handle_fire(mob/living/carbon/human/H, no_protection)
	if(internal_fire)
		no_protection = TRUE
	. = ..()

/datum/species/plasmaman/before_equip_job(datum/job/J, mob/living/carbon/human/H, visualsOnly = FALSE)
	var/current_job = J.title
	var/datum/outfit/plasmaman/O = new /datum/outfit/plasmaman
	switch(current_job)
		if("Chaplain")
			O = new /datum/outfit/plasmaman/chaplain

		if("Curator")
			O = new /datum/outfit/plasmaman/curator

		if("Janitor")
			O = new /datum/outfit/plasmaman/janitor

		if("Botanist")
			O = new /datum/outfit/plasmaman/botany

		if("Bartender", "Lawyer", "Barber")
			O = new /datum/outfit/plasmaman/bar

		if("Stage Magician")
			O = new /datum/outfit/plasmaman/magic

		if("Cook")
			O = new /datum/outfit/plasmaman/chef

		if("Security Officer")
			O = new /datum/outfit/plasmaman/security
		
		if("Deputy")
			O = new /datum/outfit/plasmaman

		if("Brig Physician")
			O = new /datum/outfit/plasmaman/secmed

		if("Detective")
			O = new /datum/outfit/plasmaman/detective

		if("Warden")
			O = new /datum/outfit/plasmaman/warden

		if("Cargo Technician", "Quartermaster")
			O = new /datum/outfit/plasmaman/cargo

		if("Shaft Miner")
			O = new /datum/outfit/plasmaman/mining

		if("Medical Doctor")
			O = new /datum/outfit/plasmaman/medical

		if("Paramedic")
			O = new /datum/outfit/plasmaman/emt

		if("Chemist")
			O = new /datum/outfit/plasmaman/chemist

		if("Geneticist")
			O = new /datum/outfit/plasmaman/genetics

		if("Roboticist")
			O = new /datum/outfit/plasmaman/robotics

		if("Virologist")
			O = new /datum/outfit/plasmaman/viro

		if("Scientist")
			O = new /datum/outfit/plasmaman/science

		if("Station Engineer")
			O = new /datum/outfit/plasmaman/engineering

		if("Atmospheric Technician")
			O = new /datum/outfit/plasmaman/atmospherics

		if("Captain")
			O = new /datum/outfit/plasmaman/command

		if("Chief Engineer")
			O = new /datum/outfit/plasmaman/ce

		if("Chief Medical Officer")
			O = new /datum/outfit/plasmaman/cmo

		if("Head of Security")
			O = new /datum/outfit/plasmaman/hos

		if("Research Director")
			O = new /datum/outfit/plasmaman/rd

		if("Head of Personnel")
			O = new /datum/outfit/plasmaman/hop

		if("Clown")
			O = new /datum/outfit/plasmaman/honk

		if("Mime")
			O = new /datum/outfit/plasmaman/mime

	H.equipOutfit(O, visualsOnly)
	H.internal = H.get_item_for_held_index(2)
	H.update_internals_hud_icon(1)
	return 0

/datum/species/plasmaman/qualifies_for_rank(rank, list/features)
	if(rank in GLOB.security_positions)
		return 0
	if(rank == "Clown" || rank == "Mime")//No funny bussiness
		return 0
	return ..()

/datum/species/plasmaman/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_plasmaman_name()

	var/randname = plasmaman_name()

	if(lastname)
		randname += " [lastname]"

	return randname

/datum/species/plasmaman/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	. = ..()
	if(chem.type == /datum/reagent/consumable/milk)
		if(chem.volume >= 6)
			H.reagents.remove_reagent(chem.type, chem.volume - 5)
			to_chat(H, "<span class='warning'>The excess milk is dripping off your bones!</span>")
		H.heal_bodypart_damage(1.5,0, 0)
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM)
		return TRUE

	if(chem.type == /datum/reagent/toxin/bonehurtingjuice)
		H.adjustBruteLoss(0.5, 0)
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM)
		return TRUE
