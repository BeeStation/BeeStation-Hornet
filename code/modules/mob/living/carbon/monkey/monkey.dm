/mob/living/carbon/monkey
	name = "monkey"
	verb_say = "chimpers"
	initial_language_holder = /datum/language_holder/monkey
	icon = 'icons/mob/monkey.dmi'
	icon_state = "monkey1"
	gender = NEUTER
	pass_flags = PASSTABLE
	ventcrawler = VENTCRAWLER_NUDE
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	butcher_results = list(/obj/item/food/meat/slab/monkey = 5, /obj/item/stack/sheet/animalhide/monkey = 1)
	type_of_meat = /obj/item/food/meat/slab/monkey
	gib_type = /obj/effect/decal/cleanable/blood/gibs
	unique_name = TRUE
	// Managed by the limb overlay system
	blocks_emissive = FALSE
	bodyparts = list(
		/obj/item/bodypart/chest/monkey,
		/obj/item/bodypart/head/monkey,
		/obj/item/bodypart/arm/left/monkey,
		/obj/item/bodypart/arm/right/monkey,
		/obj/item/bodypart/leg/right/monkey,
		/obj/item/bodypart/leg/left/monkey
	)
	hud_type = /datum/hud/monkey
	mobchatspan = "monkeyhive"
	ai_controller = /datum/ai_controller/monkey
	faction = list(FACTION_NEUTRAL, FACTION_MONKEY)
	/// Whether it can be made into a human with mutadone
	var/natural = TRUE
	///Item reference for jumpsuit
	var/obj/item/clothing/w_uniform = null

GLOBAL_LIST_INIT(strippable_monkey_items, create_strippable_list(list(
	/datum/strippable_item/hand/left,
	/datum/strippable_item/hand/right,
	/datum/strippable_item/mob_item_slot/handcuffs,
	/datum/strippable_item/mob_item_slot/legcuffs,
	/datum/strippable_item/mob_item_slot/head,
	/datum/strippable_item/mob_item_slot/back,
	/datum/strippable_item/mob_item_slot/jumpsuit,
	/datum/strippable_item/mob_item_slot/mask,
	/datum/strippable_item/mob_item_slot/neck
)))

CREATION_TEST_IGNORE_SUBTYPES(/mob/living/carbon/monkey)

/mob/living/carbon/monkey/Initialize(mapload, cubespawned=FALSE, mob/spawner)
	add_verb(/mob/living/proc/mob_sleep)
	add_verb(/mob/living/proc/toggle_resting)

	icon_state = null

	if(unique_name) //used to exclude pun pun
		gender = pick(MALE, FEMALE)
	real_name = name

	//initialize limbs
	create_bodyparts()
	create_internal_organs()

	. = ..()

	if (cubespawned)
		var/cap = CONFIG_GET(number/max_cube_monkeys)
		if (LAZYLEN(SSmobs.cubemonkeys) > cap)
			if (spawner)
				to_chat(spawner, span_warning("Bluespace harmonics prevent the spawning of more than [cap] monkeys on the station at one time!"))
			return INITIALIZE_HINT_QDEL
		SSmobs.cubemonkeys += src

	create_dna()
	dna.initialize_dna(random_blood_type(), randomize_features = FALSE)
	AddComponent(/datum/component/bloodysoles/feet)
	check_if_natural()
	AddElement(/datum/element/strippable, GLOB.strippable_monkey_items)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_BAREFOOT, 1, 2)

	// Give random dormant diseases to roundstart monkeys.
	if(mapload)
		give_random_dormant_disease(30, min_symptoms = 1, max_symptoms = 3)

/mob/living/carbon/monkey/proc/check_if_natural()
	for(var/datum/mutation/race/monke in dna.mutations)
		if(natural)
			monke.mutadone_proof = TRUE
		else
			monke.mutadone_proof = FALSE

/mob/living/carbon/monkey/Destroy()
	SSmobs.cubemonkeys -= src
	return ..()

/mob/living/carbon/monkey/create_internal_organs()
	organs += new /obj/item/organ/appendix
	organs += new /obj/item/organ/lungs
	organs += new /obj/item/organ/heart
	organs += new /obj/item/organ/brain
	organs += new /obj/item/organ/tongue
	organs += new /obj/item/organ/eyes
	organs += new /obj/item/organ/ears
	organs += new /obj/item/organ/liver
	organs += new /obj/item/organ/stomach
	..()

/mob/living/carbon/monkey/on_reagent_change()
	. = ..()
	var/amount
	if(reagents.has_reagent(/datum/reagent/medicine/morphine))
		amount = -1
	if(reagents.has_reagent(/datum/reagent/consumable/nuka_cola))
		amount = -1
	if(amount)
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/monkey_reagent_speedmod, TRUE, amount)

/mob/living/carbon/monkey/updatehealth()
	. = ..()
	var/slow = 0
	if(!HAS_TRAIT(src, TRAIT_IGNOREDAMAGESLOWDOWN))
		var/health_deficiency = (maxHealth - health)
		if(health_deficiency >= 45)
			slow += (health_deficiency / 25)
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/monkey_health_speedmod, TRUE, slow)

/mob/living/carbon/monkey/get_stat_tab_status()
	var/list/tab_data = ..()
	if(client && mind)
		var/datum/antagonist/changeling/changeling = mind.has_antag_datum(/datum/antagonist/changeling)
		if(changeling)
			tab_data["Chemical Storage"] = GENERATE_STAT_TEXT("[changeling.chem_charges]/[changeling.total_chem_storage]")
			tab_data["Absorbed DNA"] = GENERATE_STAT_TEXT("[changeling.absorbed_count]")
	return tab_data


/mob/living/carbon/monkey/verb/removeinternal()
	set name = "Remove Internals"
	set category = "IC"
	internal = null
	return

/mob/living/carbon/monkey/can_use_guns(obj/item/G)
	if(G.trigger_guard == TRIGGER_GUARD_NONE)
		to_chat(src, "<span class='warning'>You are unable to fire this!</span>")
		return FALSE
	return TRUE

/mob/living/carbon/monkey/reagent_check(datum/reagent/R) //can metabolize all reagents
	return FALSE

/mob/living/carbon/monkey/canBeHandcuffed()
	if(num_hands < 2)
		return FALSE
	return TRUE

/mob/living/carbon/monkey/assess_threat(judgment_criteria, lasercolor = "", datum/callback/weaponcheck=null)
	if(judgment_criteria & JUDGE_EMAGGED)
		return 10 //Everyone is a criminal!

	var/threatcount = 0

	//Securitrons can't identify monkeys
	if( !(judgment_criteria & JUDGE_IGNOREMONKEYS) && (judgment_criteria & JUDGE_IDCHECK) )
		threatcount += 4

	//Lasertag bullshit
	if(lasercolor)
		if(lasercolor == "b")//Lasertag turrets target the opposing team, how great is that? -Sieve
			if(is_holding_item_of_type(/obj/item/gun/energy/laser/redtag))
				threatcount += 4

		if(lasercolor == "r")
			if(is_holding_item_of_type(/obj/item/gun/energy/laser/bluetag))
				threatcount += 4

		return threatcount

	//Check for weapons
	if( (judgment_criteria & JUDGE_WEAPONCHECK) && weaponcheck )
		for(var/obj/item/I in held_items) //if they're holding a gun
			if(weaponcheck.Invoke(I))
				threatcount += 4
		if(weaponcheck.Invoke(back)) //if a weapon is present in the back slot
			threatcount += 4 //trigger look_for_perp() since they're nonhuman and very likely hostile

	//mindshield implants imply trustworthyness
	if(has_mindshield_hud_icon())
		threatcount -= 1

	return threatcount

/mob/living/carbon/monkey/IsVocal()
	if(!get_organ_slot(ORGAN_SLOT_LUNGS))
		return 0
	return 1

/mob/living/carbon/monkey/angry
	ai_controller = /datum/ai_controller/monkey/angry

/mob/living/carbon/monkey/angry/Initialize(mapload)
	. = ..()
	if(prob(10))
		var/obj/item/clothing/head/helmet/toggleable/justice/escape/helmet = new(src)
		equip_to_slot_or_del(helmet,ITEM_SLOT_HEAD)
		helmet.attack_self(src) // todo encapsulate toggle


//Special monkeycube subtype to track the number of them and prevent spam
/mob/living/carbon/monkey/cube/Initialize(mapload)
	. = ..()
	GLOB.total_cube_monkeys++

/mob/living/carbon/monkey/cube/death(gibbed)
	GLOB.total_cube_monkeys--
	..()

//In case admins delete them before they die
/mob/living/carbon/monkey/cube/Destroy()
	if(stat != DEAD)
		GLOB.total_cube_monkeys--
	return ..()

/mob/living/carbon/monkey/tumor
	name = "living teratoma"
	verb_say = "blabbers"
	initial_language_holder = /datum/language_holder/monkey
	icon = 'icons/mob/monkey.dmi'
	icon_state = null
	butcher_results = list(/obj/effect/spawner/lootdrop/teratoma/minor = 5, /obj/effect/spawner/lootdrop/teratoma/major = 1)
	type_of_meat = /obj/effect/spawner/lootdrop/teratoma/minor
	bodyparts = list(/obj/item/bodypart/chest/monkey/teratoma, /obj/item/bodypart/head/monkey/teratoma, /obj/item/bodypart/arm/left/monkey/teratoma,
					/obj/item/bodypart/arm/right/monkey/teratoma, /obj/item/bodypart/leg/right/monkey/teratoma, /obj/item/bodypart/leg/left/monkey/teratoma)
	ai_controller = null
	var/creator_key = null

/mob/living/carbon/monkey/tumor/death(gibbed)
	. = ..()
	for (var/mob/living/creator in GLOB.player_list)
		if (creator.key != creator_key)
			continue
		if (creator.stat == DEAD)
			return
		if (!creator.mind)
			return
		if (!creator.mind.has_antag_datum(/datum/antagonist/changeling))
			return
		to_chat(creator, span_warning("We gain the energy to birth another Teratoma..."))
		return

/datum/dna/tumor
	species = new /datum/species/teratoma

/datum/species/teratoma
	name = "Teratoma"
	id = "teratoma"
	inherent_traits = list(
		TRAIT_NO_UNDERWEAR,
		TRAIT_NO_BLOOD_OVERLAY,
		TRAIT_NO_AUGMENTS,
		TRAIT_NOHUNGER,
		TRAIT_RADIMMUNE,
		TRAIT_BADDNA,
		TRAIT_CHUNKYFINGERS,
		TRAIT_NONECRODISEASE
	) //Made of mutated cells
	skinned_type = /obj/item/stack/sheet/animalhide/monkey
	changesource_flags = MIRROR_BADMIN
	mutantbrain = /obj/item/organ/brain/tumor
	mutanttongue = /obj/item/organ/tongue/teratoma

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/monkey/teratoma,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/monkey/teratoma,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/monkey/teratoma,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/monkey/teratoma,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/monkey/teratoma,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/monkey/teratoma
	)

/obj/item/organ/brain/tumor
	name = "teratoma brain"

/obj/item/organ/brain/tumor/Remove(mob/living/carbon/C, special, no_id_transfer, pref_load = FALSE)
	. = ..()
	//Removing it deletes it
	if(!QDELETED(src))
		qdel(src)

/mob/living/carbon/monkey/tumor/handle_mutations_and_radiation()
	return

/mob/living/carbon/monkey/tumor/has_dna()
	return FALSE

/mob/living/carbon/monkey/tumor/create_dna()
	dna = new /datum/dna/tumor(src)
	//Give us the juicy mutant organs
	dna.species.on_species_gain(src, null, FALSE)
	dna.species.regenerate_organs(src, replace_current = TRUE)
