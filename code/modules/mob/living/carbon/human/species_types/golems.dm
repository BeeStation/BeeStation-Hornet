/datum/species/golem
	// Animated beings of stone. They have increased defenses, and do not need to breathe. They're also slow as fuuuck.
	name = "Golem"
	id = SPECIES_GOLEM
	inherent_traits = list(
		TRAIT_RESISTHEAT,
		TRAIT_NOBREATH,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_NOFIRE,
		TRAIT_RADIMMUNE,
		TRAIT_NOT_TRANSMORPHIC,
		TRAIT_PIERCEIMMUNE,
		TRAIT_NODISMEMBER,
		TRAIT_NOBLOOD,
		TRAIT_NO_DNA_COPY,
		TRAIT_MUTANT_COLORS,
		TRAIT_NO_UNDERWEAR,
	)
	mutantheart = null
	mutantlungs = null
	inherent_biotypes = MOB_HUMANOID|MOB_MINERAL
	mutant_organs = list(/obj/item/organ/adamantine_resonator)
	mutanttongue = /obj/item/organ/tongue/golem
	damage_modifier = 55
	siemens_coeff = 0
	no_equip_flags = ITEM_SLOT_MASK | ITEM_SLOT_OCLOTHING | ITEM_SLOT_GLOVES | ITEM_SLOT_FEET | ITEM_SLOT_ICLOTHING | ITEM_SLOT_SUITSTORE
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC
	sexes = FALSE
	meat = /obj/item/food/meat/slab/human/mutant/golem
	species_language_holder = /datum/language_holder/golem
	// To prevent golem subtypes from overwhelming the odds when random species
	// changes, only the Random Golem type can be chosen
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/golem,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/golem,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/golem,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/golem,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/golem,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/golem,
	)

	fixed_mut_color = "#aaaaaa"
	swimming_component = /datum/component/swimming/golem
	var/info_text = "As an " + span_danger("Iron Golem") + ", you don't have any special traits."
	var/random_eligible = TRUE //If false, the golem subtype can't be made through golem mutation toxin

	var/prefix = "Iron"
	var/list/special_names = list("Tarkus")
	var/owner //dobby is a free golem

/datum/species/golem/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "gem",
		SPECIES_PERK_NAME = "Lithoid",
		SPECIES_PERK_DESC = "Lithoids are creatures made out of elements instead of \
			blood and flesh. Because of this, they're generally stronger, slower, \
			and mostly immune to environmental dangers and dangers to their health, \
			such as viruses and dismemberment.",
	))

	return to_add

/datum/species/golem/adamantine
	name = "Adamantine Golem"
	id = SPECIES_GOLEM_ADAMANTINE
	meat = /obj/item/food/meat/slab/human/mutant/golem/adamantine
	mutant_organs = list(/obj/item/organ/adamantine_resonator, /obj/item/organ/vocal_cords/adamantine)
	fixed_mut_color = "#44eedd"
	info_text = "As an " + span_danger("Adamantine Golem") + ", you possess special vocal cords allowing you to \"resonate\" messages to all golems. Your unique mineral makeup makes you immune to most types of magic."
	prefix = "Adamantine"
	special_names = null
	examine_limb_id = SPECIES_GOLEM

/datum/species/golem/adamantine/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load, regenerate_icons)
	..()
	C.AddComponent(/datum/component/anti_magic, SPECIES_TRAIT, MAGIC_RESISTANCE)

/datum/species/golem/adamantine/on_species_loss(mob/living/carbon/C)
	for (var/datum/component/anti_magic/anti_magic in C.GetComponents(/datum/component/anti_magic))
		if (anti_magic.source == SPECIES_TRAIT)
			qdel(anti_magic)
	..()

//The suicide bombers of golemkind
/datum/species/golem/plasma
	name = "Plasma Golem"
	id = SPECIES_GOLEM_PLASMA
	fixed_mut_color = "#aa33dd"
	meat = /obj/item/stack/ore/plasma
	//Can burn and takes damage from heat
	inherent_traits = list(
		TRAIT_NOBREATH,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_RADIMMUNE,
		TRAIT_GENELESS,
		TRAIT_PIERCEIMMUNE,
		TRAIT_NODISMEMBER
	) //no RESISTHEAT, NOFIRE
	info_text = "As a " + span_danger("Plasma Golem") + ", you burn easily. Be careful, if you get hot enough while burning, you'll blow up!"
	heatmod = 0 //fine until they blow up
	prefix = "Plasma"
	special_names = list("Flood","Fire","Bar","Man")
	examine_limb_id = SPECIES_GOLEM
	var/boom_warning = FALSE
	var/datum/action/innate/ignite/ignite

/datum/species/golem/plasma/spec_life(mob/living/carbon/human/H, delta_time, times_fired)
	if(H.bodytemperature > 750)
		if(!boom_warning && H.on_fire)
			to_chat(H, span_userdanger("You feel like you could blow up at any moment!"))
			boom_warning = TRUE
	else
		if(boom_warning)
			to_chat(H, span_notice("You feel more stable."))
			boom_warning = FALSE

	if(H.bodytemperature > 850 && H.on_fire && prob(25))
		explosion(get_turf(H),1,2,4,flame_range = 5)
		if(H)
			H.investigate_log("has been gibbed as [H.p_their()] body explodes.", INVESTIGATE_DEATHS)
			H.gib()
	if(H.fire_stacks < 2) //flammable
		H.adjust_fire_stacks(0.5 * delta_time)
	..()

/datum/species/golem/plasma/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load, regenerate_icons)
	..()
	if(ishuman(C))
		ignite = new
		ignite.Grant(C)

/datum/species/golem/plasma/on_species_loss(mob/living/carbon/C)
	if(ignite)
		ignite.Remove(C)
	..()

/datum/action/innate/ignite
	name = "Ignite"
	desc = "Set yourself aflame, bringing yourself closer to exploding!"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "sacredflame"
	button_icon = 'icons/hud/actions/actions_spells.dmi'

/datum/action/innate/ignite/on_activate()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(H.fire_stacks)
			to_chat(owner, span_notice("You ignite yourself!"))
		else
			to_chat(owner, span_warning("You try to ignite yourself, but fail!"))
		H.ignite_mob() //firestacks are already there passively

//Harder to hurt
/datum/species/golem/diamond
	name = "Diamond Golem"
	id = SPECIES_GOLEM_DIAMOND
	fixed_mut_color = COLOR_CYAN
	damage_modifier = 70 //up from 55
	meat = /obj/item/stack/ore/diamond
	info_text = "As a " + span_danger("Diamond Golem") + ", you are more resistant than the average golem."
	prefix = "Diamond"
	special_names = list("Back","Grill")
	examine_limb_id = SPECIES_GOLEM

//Faster but softer and less armoured
/datum/species/golem/gold
	name = "Gold Golem"
	id = SPECIES_GOLEM_GOLD
	fixed_mut_color = "#cccc00"
	damage_modifier = 25 //down from 55
	meat = /obj/item/stack/ore/gold
	info_text = "As a " + span_danger("Gold Golem") + ", you are faster but less resistant than the average golem."
	prefix = "Golden"
	special_names = list("Boy")
	examine_limb_id = SPECIES_GOLEM

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/golem,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/golem,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/golem,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/golem/gold,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/golem/gold,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/golem,
	)

//Heavier, thus higher chance of stunning when punching
/datum/species/golem/silver
	name = "Silver Golem"
	id = SPECIES_GOLEM_SILVER
	fixed_mut_color = "#dddddd"
	meat = /obj/item/stack/ore/silver
	info_text = "As a " + span_danger("Silver Golem") + ", your attacks have a higher chance of stunning. Being made of silver, your body is immune to most types of magic."
	prefix = "Silver"
	special_names = list("Surfer", "Chariot", "Lining")
	examine_limb_id = SPECIES_GOLEM

/datum/species/golem/silver/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load, regenerate_icons)
	..()
	C.AddComponent(/datum/component/anti_magic, SPECIES_TRAIT, MAGIC_RESISTANCE_HOLY)

/datum/species/golem/silver/on_species_loss(mob/living/carbon/C)
	for (var/datum/component/anti_magic/anti_magic in C.GetComponents(/datum/component/anti_magic))
		if (anti_magic.source == SPECIES_TRAIT)
			qdel(anti_magic)
	..()

// Softer and faster, but conductive
/datum/species/golem/copper
	name = "Copper Golem"
	id = SPECIES_GOLEM_COPPER
	fixed_mut_color = "#d95802"
	damage_modifier = 30
	meat = /obj/item/stack/ore/copper
	siemens_coeff = 1 //set as conductive, next line sets shock immunity
	inherent_traits = list(
		TRAIT_RESISTHEAT,
		TRAIT_NOBREATH,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_NOFIRE,
		TRAIT_RADIMMUNE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_NODISMEMBER,
		TRAIT_SHOCKIMMUNE
	)
	info_text = "As a " + span_danger("Copper Golem") + ", you are faster but less resistant than the average golem. You also act as a conduit for electricity, while not being affected by it."
	prefix = "Copper"
	special_names = list("Wire")

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/golem,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/golem,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/golem,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/golem/copper,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/golem/copper,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/golem,
	)

//Harder to stun, deals more damage, massively slowpokes, but gravproof and obstructive. Basically, The Wall.
/datum/species/golem/plasteel
	name = "Plasteel Golem"
	id = SPECIES_GOLEM_PLASTEEL
	fixed_mut_color = "#bbbbbb"
	stunmod = 0.4
	meat = /obj/item/stack/ore/iron
	info_text = "As a " + span_danger("Plasteel Golem") + ", you are slower, but harder to stun, and hit very hard when punching. You also magnetically attach to surfaces and so don't float without gravity and cannot have positions swapped with other beings."
	prefix = "Plasteel"
	special_names = null
	examine_limb_id = SPECIES_GOLEM
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/golem/plasteel,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/golem/plasteel,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/golem,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/golem/plasteel,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/golem/plasteel,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/golem,
	)

/datum/species/golem/plasteel/negates_gravity(mob/living/carbon/human/H)
	return TRUE

/datum/species/golem/plasteel/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load, regenerate_icons)
	..()
	ADD_TRAIT(C, TRAIT_NOMOBSWAP, SPECIES_TRAIT) //THE WALL THE WALL THE WALL

/datum/species/golem/plasteel/on_species_loss(mob/living/carbon/C)
	REMOVE_TRAIT(C, TRAIT_NOMOBSWAP, SPECIES_TRAIT) //NOTHING ON ERF CAN MAKE IT FALL
	..()

//Immune to ash storms
/datum/species/golem/titanium
	name = "Titanium Golem"
	id = SPECIES_GOLEM_TITANIUM
	fixed_mut_color = COLOR_WHITE
	meat = /obj/item/stack/ore/titanium
	info_text = "As a " + span_danger("Titanium Golem") + ", you are immune to ash storms, and slightly more resistant to burn damage."
	prefix = "Titanium"
	special_names = list("Dioxide")

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/golem/titanium,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/golem/titanium,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/golem/titanium,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/golem/titanium,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/golem/titanium,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/golem/titanium
	)

/datum/species/golem/titanium/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	ADD_TRAIT(C, TRAIT_ASHSTORM_IMMUNE, SPECIES_TRAIT)

/datum/species/golem/titanium/on_species_loss(mob/living/carbon/C)
	. = ..()
	REMOVE_TRAIT(C, TRAIT_ASHSTORM_IMMUNE, SPECIES_TRAIT)

//Immune to ash storms and lava
/datum/species/golem/plastitanium
	name = "Plastitanium Golem"
	id = SPECIES_GOLEM_PLASTITANIUM
	fixed_mut_color = "#888888"
	meat = /obj/item/stack/ore/titanium
	info_text = "As a " + span_danger("Plastitanium Golem") + ", you are immune to both ash storms and lava, and slightly more resistant to burn damage."
	prefix = "Plastitanium"
	special_names = null

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/golem/plastitanium,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/golem/plastitanium,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/golem/plastitanium,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/golem/plastitanium,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/golem/plastitanium,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/golem/plastitanium
	)

/datum/species/golem/plastitanium/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	C.add_traits(list(TRAIT_LAVA_IMMUNE, TRAIT_ASHSTORM_IMMUNE), SPECIES_TRAIT)

/datum/species/golem/plastitanium/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.remove_traits(list(TRAIT_LAVA_IMMUNE, TRAIT_ASHSTORM_IMMUNE), SPECIES_TRAIT)

//Fast and regenerates... but can only speak like an abductor
/datum/species/golem/alloy
	name = "Alien Alloy Golem"
	id = SPECIES_GOLEM_ALLOY
	meat = /obj/item/stack/sheet/mineral/abductor
	mutanttongue = /obj/item/organ/tongue/abductor
	info_text = "As an " + span_danger("Alloy Golem") + ", you are made of advanced alien materials: you are faster and regenerate over time. You are, however, only able to be heard by other alloy golems."
	prefix = "Alien"
	special_names = list("Outsider", "Technology", "Watcher", "Stranger") //ominous and unknown

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/golem/alloy,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/golem/alloy,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/golem/alloy,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/golem/alloy,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/golem/alloy,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/golem/alloy
	)

//Regenerates because self-repairing super-advanced alien tech
/datum/species/golem/alloy/spec_life(mob/living/carbon/human/H, delta_time, times_fired)
	. = ..()
	if(H.stat == DEAD)
		return
	H.heal_overall_damage(2,2, 0, BODYTYPE_ORGANIC)
	H.adjustToxLoss(-1 * delta_time)
	H.adjustOxyLoss(-1 * delta_time)

//Since this will usually be created from a collaboration between podpeople and free golems, wood golems are a mix between the two races
/datum/species/golem/wood
	name = "Wood Golem"
	id = SPECIES_GOLEM_WOOD
	fixed_mut_color = "#9E704B"
	meat = /obj/item/stack/sheet/wood
	//Can burn and take damage from heat
	inherent_traits = list(
		TRAIT_NOBREATH,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_RADIMMUNE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_NODISMEMBER
	)
	damage_modifier = 30
	heatmod = 1.5
	info_text = "As a " + span_danger("Wood Golem") + ", you have plant-like traits: you take damage from extreme temperatures, can be set on fire, and have lower armor than a normal golem. You regenerate when in the light and wither in the darkness."
	prefix = "Wooden"
	special_names = list("Bark", "Willow", "Catalpa", "Woody", "Oak", "Sap", "Twig", "Branch", "Maple", "Birch", "Elm", "Basswood", "Cottonwood", "Larch", "Aspen", "Ash", "Beech", "Buckeye", "Cedar", "Chestnut", "Cypress", "Fir", "Hawthorn", "Hazel", "Hickory", "Ironwood", "Juniper", "Leaf", "Mangrove", "Palm", "Pawpaw", "Pine", "Poplar", "Redwood", "Redbud", "Sassafras", "Spruce", "Sumac", "Trunk", "Walnut", "Yew")
	inherent_factions = list(FACTION_PLANTS, FACTION_VINES)

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/golem/wood,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/golem/wood,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/golem/wood,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/golem/wood,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/golem/wood,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/golem/wood
	)

/datum/species/golem/wood/spec_life(mob/living/carbon/human/H, delta_time, times_fired)
	. = ..()
	if(H.stat == DEAD)
		return
	var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
	if(isturf(H.loc)) //else, there's considered to be no light
		var/turf/T = H.loc
		light_amount = min(1, T.get_lumcount()) - 0.5
		H.adjust_nutrition(5 * light_amount * delta_time)
		if(H.nutrition > NUTRITION_LEVEL_ALMOST_FULL)
			H.set_nutrition(NUTRITION_LEVEL_ALMOST_FULL)
		if(light_amount > 0.2) //if there's enough light, heal
			H.heal_overall_damage(0.5 * delta_time, 0.5 * delta_time, 0, BODYTYPE_ORGANIC)
			H.adjustToxLoss(-0.5 * delta_time)
			H.adjustOxyLoss(-0.5 * delta_time)

	if(H.nutrition < NUTRITION_LEVEL_STARVING + 50)
		H.take_overall_damage(brute = 2, required_bodytype = BODYTYPE_ORGANIC)

/datum/species/golem/wood/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H, delta_time, times_fired)
	if(chem.type == /datum/reagent/toxin/plantbgone)
		H.adjustToxLoss(3 * REM * delta_time)
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM * delta_time)
		return TRUE
	return ..()

//Radioactive
/datum/species/golem/uranium
	name = "Uranium Golem"
	id = SPECIES_GOLEM_URANIUM
	fixed_mut_color = "#77ff00"
	meat = /obj/item/stack/ore/uranium
	info_text = "As an " + span_danger("Uranium Golem") + ", you emit radiation pulses every once in a while. It won't harm fellow golems, but organic lifeforms will be affected."
	damage_modifier = 40
	prefix = "Uranium"
	special_names = list("Oxide", "Rod", "Meltdown", "235")
	examine_limb_id = SPECIES_GOLEM
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/golem/uranium,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/golem/uranium,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/golem/uranium,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/golem/uranium,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/golem/uranium,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/golem/uranium,
	)

	COOLDOWN_DECLARE(radiate_cooldown)

/datum/species/golem/uranium/spec_life(mob/living/carbon/human/source)
	. = ..()
	if(COOLDOWN_FINISHED(src, radiate_cooldown))
		COOLDOWN_START(src, radiate_cooldown, 3 SECONDS)
		radiation_pulse(source, max_range = 2)

//Immune to physical bullets and resistant to brute, but very vulnerable to burn damage. Dusts on death.
/datum/species/golem/sand
	name = "Sand Golem"
	id = SPECIES_GOLEM_SAND
	fixed_mut_color = "#ffdc8f"
	meat = /obj/item/stack/ore/glass //this is sand
	damage_modifier = 0
	info_text = "As a " + span_danger("Sand Golem") + ", you are immune to physical bullets and take very little brute damage, but are extremely vulnerable to burn damage and energy weapons. You will also turn to sand when dying, preventing any form of recovery."
	prefix = "Sand"
	special_names = list("Castle", "Bag", "Dune", "Worm", "Storm")

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/golem/sand,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/golem/sand,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/golem/sand,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/golem/sand,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/golem/sand,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/golem/sand
	)

/datum/species/golem/sand/spec_death(gibbed, mob/living/carbon/human/H)
	H.visible_message(span_danger("[H] turns into a pile of sand!"))
	for(var/obj/item/W in H)
		H.dropItemToGround(W)
	for(var/i in 1 to rand(3,5))
		new /obj/item/stack/ore/glass(get_turf(H))
	qdel(H)

/datum/species/golem/sand/bullet_act(obj/projectile/P, mob/living/carbon/human/H)
	if(!(P.original == H && P.firer == H))
		if(P.armor_flag == BULLET || P.armor_flag == BOMB)
			playsound(H, 'sound/effects/shovel_dig.ogg', 70, 1)
			H.visible_message(span_danger("The [P.name] sinks harmlessly in [H]'s sandy body!"), \
			span_userdanger("The [P.name] sinks harmlessly in [H]'s sandy body!"))
			return BULLET_ACT_BLOCK
	return ..()

//Reflects lasers and resistant to burn damage, but very vulnerable to brute damage. Shatters on death.
/datum/species/golem/glass
	name = "Glass Golem"
	id = SPECIES_GOLEM_GLASS
	fixed_mut_color = "#5a96b4aa" //transparent body
	meat = /obj/item/shard
	damage_modifier = 0
	info_text = "As a " + span_danger("Glass Golem") + ", you reflect lasers and energy weapons, and are very resistant to burn damage. However, you are extremely vulnerable to brute damage. On death, you'll shatter beyond any hope of recovery."
	prefix = "Glass"
	special_names = list("Lens", "Prism", "Fiber", "Bead")

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/golem/glass,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/golem/glass,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/golem/glass,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/golem/glass,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/golem/glass,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/golem/glass
	)

/datum/species/golem/glass/spec_death(gibbed, mob/living/carbon/human/H)
	playsound(H, "shatter", 70, 1)
	H.visible_message(span_danger("[H] shatters!"))
	for(var/obj/item/W in H)
		H.dropItemToGround(W)
	for(var/i in 1 to rand(3,5))
		new /obj/item/shard(get_turf(H))
	qdel(H)

/datum/species/golem/glass/bullet_act(obj/projectile/P, mob/living/carbon/human/H)
	if(!(P.original == H && P.firer == H)) //self-shots don't reflect
		if(P.armor_flag == LASER || P.armor_flag == ENERGY)
			H.visible_message(span_danger("The [P.name] gets reflected by [H]'s glass skin!"), \
			span_userdanger("The [P.name] gets reflected by [H]'s glass skin!"))
			if(P.starting)
				var/new_x = P.starting.x + pick(0, 0, 0, 0, 0, -1, 1, -2, 2)
				var/new_y = P.starting.y + pick(0, 0, 0, 0, 0, -1, 1, -2, 2)
				// redirect the projectile
				P.firer = H
				P.preparePixelProjectile(locate(clamp(new_x, 1, world.maxx), clamp(new_y, 1, world.maxy), H.z), H)
			return BULLET_ACT_FORCE_PIERCE
	return ..()

//Teleports when hit or when it wants to
/datum/species/golem/bluespace
	name = "Bluespace Golem"
	id = SPECIES_GOLEM_BLUESPACE
	fixed_mut_color = "#3333ff"
	meat = /obj/item/stack/ore/bluespace_crystal
	info_text = "As a " + span_danger("Bluespace Golem") + ", you are spatially unstable: You will teleport when hit, and you can teleport manually at a long distance."
	prefix = "Bluespace"
	special_names = list("Crystal", "Polycrystal")

	var/datum/action/innate/unstable_teleport/unstable_teleport
	var/teleport_cooldown = 100
	var/last_teleport = 0

/datum/species/golem/bluespace/proc/reactive_teleport(mob/living/carbon/human/H)
	H.visible_message(span_warning("[H] teleports!"), span_danger("You destabilize and teleport!"))
	new /obj/effect/particle_effect/sparks(get_turf(H))
	playsound(get_turf(H), "sparks", 50, 1)
	do_teleport(H, get_turf(H), 6, asoundin = 'sound/weapons/emitter2.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)
	last_teleport = world.time

/datum/species/golem/bluespace/spec_hitby(atom/movable/AM, mob/living/carbon/human/H)
	..()
	var/obj/item/I
	if(istype(AM, /obj/item))
		I = AM
		if(I.thrownby == WEAKREF(H)) //No throwing stuff at yourself to trigger the teleport
			return 0
		else
			reactive_teleport(H)

/datum/species/golem/bluespace/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style)
	..()
	if(world.time > last_teleport + teleport_cooldown && M != H &&  M.combat_mode)
		reactive_teleport(H)

/datum/species/golem/bluespace/spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, intent, mob/living/carbon/human/H)
	..()
	if(world.time > last_teleport + teleport_cooldown && user != H)
		reactive_teleport(H)

/datum/species/golem/bluespace/on_hit(obj/projectile/P, mob/living/carbon/human/H)
	..()
	if(world.time > last_teleport + teleport_cooldown)
		reactive_teleport(H)

/datum/species/golem/bluespace/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load, regenerate_icons)
	..()
	if(ishuman(C))
		unstable_teleport = new
		unstable_teleport.Grant(C)
		last_teleport = world.time

/datum/species/golem/bluespace/on_species_loss(mob/living/carbon/C)
	if(unstable_teleport)
		unstable_teleport.Remove(C)
	..()

/datum/action/innate/unstable_teleport
	name = "Unstable Teleport"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "jaunt"
	button_icon = 'icons/hud/actions/actions_spells.dmi'
	var/cooldown = 150
	var/last_teleport = 0

/datum/action/innate/unstable_teleport/is_available()
	if(..())
		if(world.time > last_teleport + cooldown)
			return 1
		return 0

/datum/action/innate/unstable_teleport/on_activate()
	var/mob/living/carbon/human/H = owner
	H.visible_message(span_warning("[H] starts vibrating!"), span_danger("You start charging your bluespace core..."))
	playsound(get_turf(H), 'sound/weapons/flash.ogg', 25, 1)
	addtimer(CALLBACK(src, PROC_REF(teleport), H), 15)

/datum/action/innate/unstable_teleport/proc/teleport(mob/living/carbon/human/H)
	H.visible_message(span_warning("[H] disappears in a shower of sparks!"), span_danger("You teleport!"))
	var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(10, 0, src)
	spark_system.attach(H)
	spark_system.start()
	do_teleport(H, get_turf(H), 12, asoundin = 'sound/weapons/emitter2.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)
	last_teleport = world.time
	update_buttons() //action icon looks unavailable
	//action icon looks available again
	addtimer(CALLBACK(src, PROC_REF(update_buttons)), cooldown + 5)


//honk
/datum/species/golem/bananium
	name = "Bananium Golem"
	id = SPECIES_GOLEM_BANANIUM
	fixed_mut_color = "#ffff00"
	inherent_traits = list(
		TRAIT_NO_UNDERWEAR
	)
	meat = /obj/item/stack/ore/bananium
	mutanttongue = /obj/item/organ/tongue/golem/bananium
	info_text = "As a " + span_danger("Bananium Golem") + ", you are made for pranking. Your body emits natural honks, and you can barely even hurt people when punching them. Your skin also bleeds banana peels when damaged."
	prefix = "Bananium"
	special_names = null
	examine_limb_id = SPECIES_GOLEM
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/golem/bananium,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/golem/bananium,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/golem,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/golem/bananium,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/golem/bananium,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/golem,
	)

	/// Cooldown for producing honks
	COOLDOWN_DECLARE(honkooldown)
	/// Cooldown for producing bananas
	COOLDOWN_DECLARE(banana_cooldown)
	/// Time between possible banana productions
	var/banana_delay = 10 SECONDS
	/// Same as the uranium golem. I'm pretty sure this is vestigial.
	var/active = FALSE

/datum/species/golem/bananium/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load, regenerate_icons)
	..()
	COOLDOWN_START(src, honkooldown, 0)
	COOLDOWN_START(src, banana_cooldown, banana_delay)
	RegisterSignal(C, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/species/golem/bananium/on_species_loss(mob/living/carbon/C)
	. = ..()
	UnregisterSignal(C, COMSIG_MOB_SAY)

/datum/species/golem/bananium/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style)
	..()
	if(COOLDOWN_FINISHED(src, banana_cooldown) && M != H &&  M.combat_mode)
		new /obj/item/grown/bananapeel/specialpeel(get_turf(H))
		COOLDOWN_START(src, banana_cooldown, banana_delay)

/datum/species/golem/bananium/spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, intent, mob/living/carbon/human/H)
	..()
	if((user != H) && COOLDOWN_FINISHED(src, banana_cooldown))
		new /obj/item/grown/bananapeel/specialpeel(get_turf(H))
		COOLDOWN_START(src, banana_cooldown, banana_delay)

/datum/species/golem/bananium/on_hit(obj/projectile/P, mob/living/carbon/human/H)
	..()
	if(COOLDOWN_FINISHED(src, banana_cooldown))
		new /obj/item/grown/bananapeel/specialpeel(get_turf(H))
		COOLDOWN_START(src, banana_cooldown, banana_delay)

/datum/species/golem/bananium/spec_hitby(atom/movable/AM, mob/living/carbon/human/H)
	..()
	var/obj/item/I
	if(istype(AM, /obj/item))
		I = AM
		if(I.thrownby == WEAKREF(H)) //No throwing stuff at yourself to make bananas
			return 0
		else
			new/obj/item/grown/bananapeel/specialpeel(get_turf(H))
			COOLDOWN_START(src, banana_cooldown, banana_delay)

/datum/species/golem/bananium/spec_life(mob/living/carbon/human/H, delta_time, times_fired)
	if(!active && COOLDOWN_FINISHED(src, honkooldown))
		active = TRUE
		playsound(get_turf(H), 'sound/items/bikehorn.ogg', 50, TRUE)
		COOLDOWN_START(src, honkooldown, rand(2 SECONDS, 8 SECONDS))
		active = FALSE
	..()

/datum/species/golem/bananium/spec_death(gibbed, mob/living/carbon/human/H)
	playsound(get_turf(H), 'sound/misc/sadtrombone.ogg', 70, 0)

/datum/species/golem/bananium/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	speech_args[SPEECH_SPANS] |= SPAN_CLOWN

/datum/species/golem/runic
	name = "Runic Golem"
	id = SPECIES_GOLEM_RUNIC
	sexes = FALSE
	info_text = "As a " + span_danger("Runic Golem") + ", you possess eldritch powers granted by the Elder Goddess Nar'Sie."
	inherent_traits = list(
		TRAIT_NO_UNDERWEAR,
		TRAIT_NOFLASH,
	) //no mutcolors
	prefix = "Runic"
	special_names = null
	random_eligible = FALSE //Zesko claims runic golems break the game
	inherent_factions = list(FACTION_CULT)
	species_language_holder = /datum/language_holder/golem/runic
	/// A ref to our jaunt spell that we get on species gain.
	var/datum/action/spell/jaunt/ethereal_jaunt/shift/golem/jaunt
	/// A ref to our gaze spell that we get on species gain.
	var/datum/action/spell/pointed/abyssal_gaze/abyssal_gaze
	/// A ref to our dominate spell that we get on species gain.
	var/datum/action/spell/pointed/dominate/dominate

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/golem/runic,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/golem/runic,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/golem/runic,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/golem/runic,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/golem/runic,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/golem/runic
	)

/datum/species/golem/runic/spec_death(gibbed, mob/living/carbon/human/body)

	for(var/obj/item/item in body.get_equipped_items(INCLUDE_POCKETS))
		body.dropItemToGround(item)
	body.visible_message(span_danger("[body] dissolves into a pile of blood, leaving behind a strange stone."))
	var/obj/item/soulstone/new_stone = new(body.drop_location())
	new_stone.init_shade(body)
	new /obj/effect/decal/cleanable/blood/splatter(get_turf(body))
	body.dust()

/datum/species/golem/runic/on_species_gain(mob/living/carbon/grant_to, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	// Create our species specific spells here.
	// Note we link them to the mob, not the mind,
	// so they're not moved around on mindswaps
	jaunt = new(grant_to)
	jaunt.Grant(grant_to)

	abyssal_gaze = new(grant_to)
	abyssal_gaze.Grant(grant_to)

	dominate = new(grant_to)
	dominate.Grant(grant_to)

/datum/species/golem/runic/on_species_loss(mob/living/carbon/C)
	// Aaand cleanup our species specific spells.
	// No free rides.
	QDEL_NULL(jaunt)
	QDEL_NULL(abyssal_gaze)
	QDEL_NULL(dominate)
	return ..()

/datum/species/golem/runic/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H, delta_time, times_fired)
	if(istype(chem, /datum/reagent/water/holywater))
		H.adjustFireLoss(4 * REM * delta_time)
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM * delta_time)
		return TRUE

	if(chem.type == /datum/reagent/fuel/unholywater)
		H.adjustBruteLoss(-4 * REM * delta_time)
		H.adjustFireLoss(-4 * REM * delta_time)
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM * delta_time)
		return TRUE
	return ..()

/datum/species/golem/clockwork
	name = "Clockwork Golem"
	id = SPECIES_GOLEM_CLOCKWORK
	info_text = span_boldalloy("As a " + span_danger("Clockwork Golem") + ", you are faster than other types of golems. On death, you will break down into scrap.")
	inherent_traits = list(
		TRAIT_NO_UNDERWEAR,
		TRAIT_NOFLASH,
	)
	inherent_biotypes = MOB_ROBOTIC|MOB_HUMANOID
	damage_modifier = 20 //Reinforced, but much less so to allow for fast movement
	sexes = FALSE
	changesource_flags = MIRROR_BADMIN | WABBAJACK
	prefix = "Clockwork"
	special_names = list("Remnant", "Relic", "Scrap", "Vestige") //RIP Ratvar
	inherent_factions = list(FACTION_RATVAR)
	mutanttongue = /obj/item/organ/tongue/golem/clockwork
	var/has_corpse

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/golem/clock,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/golem/clock,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/golem/clock,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/golem/clock,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/golem/clock,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/golem/clock
	)

/datum/species/golem/clockwork/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	RegisterSignal(C, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/species/golem/clockwork/on_species_loss(mob/living/carbon/C)
	UnregisterSignal(C, COMSIG_MOB_SAY)
	. = ..()

/datum/species/golem/clockwork/proc/handle_speech(datum/source, list/speech_args)
	speech_args[SPEECH_SPANS] |= SPAN_ROBOT //beep

/datum/species/golem/clockwork/spec_death(gibbed, mob/living/carbon/human/H)
	gibbed = !has_corpse ? FALSE : gibbed
	. = ..()
	if(!has_corpse)
		var/turf/T = get_turf(H)
		H.visible_message(span_warning("[H]'s exoskeleton shatters, collapsing into a heap of scrap!"))
		playsound(H, 'sound/magic/clockwork/anima_fragment_death.ogg', 62, TRUE)
		for(var/i in 1 to rand(3, 5))
			new/obj/item/clockwork/alloy_shards/small(T)
		new/obj/item/clockwork/alloy_shards/clockgolem_remains(T)
		qdel(H)

/datum/species/golem/clockwork/no_scrap //These golems are created through the herald's beacon and leave normal corpses on death.
	id = SPECIES_GOLEM_CLOCKWORK_SERVANT
	damage_modifier = 15 //Balance reasons make this armor weak
	no_equip_flags = NONE
	has_corpse = TRUE
	random_eligible = FALSE
	info_text = span_boldalloy("As a " + span_boldbrass("Clockwork Golem Servant") + ", you are faster than other types of golems.") //warcult golems leave a corpse

/datum/species/golem/cloth
	name = "Cloth Golem"
	id = SPECIES_GOLEM_CLOTH
	sexes = FALSE
	info_text = "As a " + span_danger("Cloth Golem") + ", you are able to reform yourself after death, provided your remains aren't burned or destroyed. You are, of course, very flammable. \
	Being made of cloth, your body is magic resistant and faster than that of other golems, but weaker and less resilient."
	inherent_traits = list(
		TRAIT_RESISTCOLD,
		TRAIT_NOBREATH,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_RADIMMUNE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_NODISMEMBER,
		TRAIT_NOBLOOD,
		TRAIT_NO_UNDERWEAR,
		TRAIT_NOT_TRANSMORPHIC,
	)
	inherent_biotypes = MOB_UNDEAD|MOB_HUMANOID
	damage_modifier = 15 //feels no pain, but not too resistant
	prefix = "Cloth"
	special_names = null

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/golem/cloth,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/golem/cloth,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/golem/cloth,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/golem/cloth,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/golem/cloth,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/golem/cloth
	)

/datum/species/golem/cloth/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load, regenerate_icons)
	..()
	C.AddComponent(/datum/component/anti_magic, SPECIES_TRAIT, MAGIC_RESISTANCE_HOLY)

/datum/species/golem/cloth/on_species_loss(mob/living/carbon/C)
	for (var/datum/component/anti_magic/anti_magic in C.GetComponents(/datum/component/anti_magic))
		if (anti_magic.source == SPECIES_TRAIT)
			qdel(anti_magic)
	..()

/datum/species/golem/cloth/check_roundstart_eligible()
	if(SSevents.holidays && SSevents.holidays[HALLOWEEN])
		return TRUE
	return ..()

/datum/species/golem/cloth/spec_life(mob/living/carbon/human/H)
	if(H.fire_stacks < 1)
		H.adjust_fire_stacks(1) //always prone to burning
	..()

/datum/species/golem/cloth/spec_death(gibbed, mob/living/carbon/human/H)
	if(gibbed)
		return
	if(H.on_fire)
		H.visible_message(span_danger("[H] burns into ash!"))
		H.dust(just_ash = TRUE)
		return

	H.visible_message(span_danger("[H] falls apart into a pile of bandages!"))
	new /obj/structure/cloth_pile(get_turf(H), H)
	..()

/datum/species/golem/cloth/get_species_description()
	return "A wrapped up Mummy! They descend upon Space Station Thirteen every year to spook the crew! \"Return the slab!\""

/datum/species/golem/cloth/get_species_lore()
	return list(
		"Mummies are very self conscious. They're shaped weird, they walk slow, and worst of all, \
		they're considered the laziest halloween costume. But that's not even true, they say.",

		"Making a mummy costume may be easy, but making a CONVINCING mummy costume requires \
		things like proper fabric and purposeful staining to achieve the look. Which is FAR from easy. Gosh.",
	)

// Calls parent, as Golems have a species-wide perk we care about.
/datum/species/golem/cloth/create_pref_unique_perks()
	var/list/to_add = ..()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "recycle",
		SPECIES_PERK_NAME = "Reformation",
		SPECIES_PERK_DESC = "A boon quite similar to Ethereals, Mummies collapse into \
			a pile of bandages after they die. If left alone, they will reform back \
			into themselves. The bandages themselves are very vulnerable to fire.",
	))

	return to_add

// Override to add a perk elaborating on just how dangerous fire is.
/datum/species/golem/cloth/create_pref_temperature_perks()
	var/list/to_add = list()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = "fire-alt",
		SPECIES_PERK_NAME = "Incredibly Flammable",
		SPECIES_PERK_DESC = "Mummies are made entirely of cloth, which makes them \
			very vulnerable to fire. They will not reform if they die while on \
			fire, and they will easily catch alight. If your bandages burn to ash, you're toast!",
	))

	return to_add

/obj/structure/cloth_pile
	name = "pile of bandages"
	desc = "It emits a strange aura, as if there was still life within it..."
	max_integrity = 50
	armor_type = /datum/armor/structure_cloth_pile
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "pile_bandages"
	resistance_flags = FLAMMABLE

	var/revive_time = 90 SECONDS
	var/mob/living/carbon/human/cloth_golem

CREATION_TEST_IGNORE_SUBTYPES(/obj/structure/cloth_pile)


/datum/armor/structure_cloth_pile
	melee = 90
	bullet = 90
	laser = 25
	energy = 80
	bomb = 50
	fire = -50
	acid = -50

/obj/structure/cloth_pile/Initialize(mapload, mob/living/carbon/human/H)
	. = ..()
	if(!QDELETED(H) && is_species(H, /datum/species/golem/cloth))
		H.unequip_everything()
		H.forceMove(src)
		cloth_golem = H
		to_chat(cloth_golem, span_notice("You start gathering your life energy, preparing to rise again..."))
		addtimer(CALLBACK(src, PROC_REF(revive)), revive_time)
	else
		return INITIALIZE_HINT_QDEL

/obj/structure/cloth_pile/Destroy()
	if(cloth_golem)
		QDEL_NULL(cloth_golem)
	return ..()

/obj/structure/cloth_pile/burn()
	visible_message(span_danger("[src] burns into ash!"))
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	..()

/obj/structure/cloth_pile/proc/revive()
	if(QDELETED(src) || QDELETED(cloth_golem)) //QDELETED also checks for null, so if no cloth golem is set this won't runtime
		return
	if(cloth_golem.suiciding)
		QDEL_NULL(cloth_golem)
		return

	invisibility = INVISIBILITY_MAXIMUM //disappear before the animation
	new /obj/effect/temp_visual/mummy_animation(get_turf(src))
	if(cloth_golem.revive(HEAL_ALL))
		cloth_golem.grab_ghost() //won't pull if it's a suicide
	sleep(20)
	cloth_golem.forceMove(get_turf(src))
	cloth_golem.visible_message(span_danger("[src] rises and reforms into [cloth_golem]!"),span_userdanger("You reform into yourself!"))
	cloth_golem = null
	qdel(src)

/obj/structure/cloth_pile/attackby(obj/item/P, mob/living/carbon/human/user, params)
	. = ..()

	if(resistance_flags & ON_FIRE)
		return

	if(P.get_temperature())
		visible_message(span_danger("[src] bursts into flames!"))
		fire_act()

/datum/species/golem/plastic
	name = "Plastic Golem"
	id = SPECIES_GOLEM_PLASTIC
	//Default plus ventcrawling
	inherent_traits = list(
		TRAIT_RESISTHEAT,
		TRAIT_NOBREATH,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_NOFIRE,
		TRAIT_CHUNKYFINGERS,
		TRAIT_RADIMMUNE,
		TRAIT_NO_DNA_COPY,
		TRAIT_NO_JUMPSUIT,
		TRAIT_NOT_TRANSMORPHIC,
		TRAIT_PIERCEIMMUNE,
		TRAIT_NODISMEMBER,
		TRAIT_NOBLOOD,
		TRAIT_VENTCRAWLER_NUDE
	)
	prefix = "Plastic"
	special_names = list("Sheet", "Bag", "Bottle")
	fixed_mut_color = "#ffffffaa"
	info_text = "As a " + span_danger("Plastic Golem") + ", you are capable of ventcrawling and passing through plastic flaps as long as you are naked."

/datum/species/golem/bronze
	name = "Bronze Golem"
	id = SPECIES_GOLEM_BRONZE
	prefix = "Bronze"
	special_names = list("Bell")
	fixed_mut_color = "#cd7f32"
	info_text = "As a " + span_danger("Bronze Golem") + ", you are very resistant to loud noises, and make loud noises if something hard hits you, however this ability does hurt your hearing."
	special_step_sounds = list('sound/machines/clockcult/integration_cog_install.ogg', 'sound/magic/clockwork/fellowship_armory.ogg' )
	mutantears = /obj/item/organ/ears/bronze
	var/last_gong_time = 0
	var/gong_cooldown = 150

/datum/species/golem/bronze/bullet_act(obj/projectile/P, mob/living/carbon/human/H)
	if(!(world.time > last_gong_time + gong_cooldown))
		return ..()
	if(P.armor_flag == BULLET || P.armor_flag == BOMB)
		gong(H)
		return ..()

/datum/species/golem/bronze/spec_hitby(atom/movable/AM, mob/living/carbon/human/H)
	..()
	if(world.time > last_gong_time + gong_cooldown)
		gong(H)

/datum/species/golem/bronze/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style)
	..()
	if(world.time > last_gong_time + gong_cooldown &&  M.combat_mode)
		gong(H)

/datum/species/golem/bronze/spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, intent, mob/living/carbon/human/H)
	..()
	if(world.time > last_gong_time + gong_cooldown)
		gong(H)

/datum/species/golem/bronze/on_hit(obj/projectile/P, mob/living/carbon/human/H)
	..()
	if(world.time > last_gong_time + gong_cooldown)
		gong(H)

/datum/species/golem/bronze/proc/gong(mob/living/carbon/human/H)
	last_gong_time = world.time
	for(var/mob/living/M in hearers(7,H))
		if(M.stat == DEAD)	//F
			return
		if(M == H)
			H.show_message(span_narsiesmall("You cringe with pain as your body rings around you!"), MSG_AUDIBLE)
			H.playsound_local(H, 'sound/effects/gong.ogg', 100, TRUE)
			H.soundbang_act(2, 0, 100, 1)
			H.adjust_jitter(14 SECONDS)
		var/distance = max(0,get_dist(get_turf(H),get_turf(M)))
		switch(distance)
			if(0 to 1)
				M.show_message(span_narsiesmall("GONG!"), MSG_AUDIBLE)
				M.playsound_local(H, 'sound/effects/gong.ogg', 100, TRUE)
				M.soundbang_act(1, 0, 30, 3)
				M.adjust_confusion(10 SECONDS)
				M.adjust_jitter(8 SECONDS)
				SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "gonged", /datum/mood_event/loud_gong)
			if(2 to 3)
				M.show_message(span_cult("GONG!"), MSG_AUDIBLE)
				M.playsound_local(H, 'sound/effects/gong.ogg', 75, TRUE)
				M.soundbang_act(1, 0, 15, 2)
				M.adjust_jitter(6 SECONDS)
				SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "gonged", /datum/mood_event/loud_gong)
			else
				M.show_message(span_warning("GONG!"), MSG_AUDIBLE)
				M.playsound_local(H, 'sound/effects/gong.ogg', 50, TRUE)


/datum/species/golem/cardboard //Faster but weaker, can also make new shells on its own
	name = "Cardboard Golem"
	id = SPECIES_GOLEM_CARDBOARD
	prefix = "Cardboard"
	special_names = list("Box")
	info_text = "As a " + span_danger("Cardboard Golem") + ", you aren't very strong, but you are a bit quicker and can easily create more brethren by using cardboard on yourself."

	inherent_traits = list(
		TRAIT_NOBREATH,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_RADIMMUNE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_NODISMEMBER,
		TRAIT_NOBLOOD,
		TRAIT_NO_UNDERWEAR,
		TRAIT_NOFLASH,
		TRAIT_NOT_TRANSMORPHIC,
	)
	fixed_mut_color = null
	damage_modifier = 25
	heatmod = 2
	var/last_creation = 0
	var/brother_creation_cooldown = 300

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/golem/cardboard,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/golem/cardboard,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/golem/cardboard,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/golem/cardboard,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/golem/cardboard,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/golem/cardboard,
	)

/datum/species/golem/cardboard/spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, intent, mob/living/carbon/human/H)
	. = ..()
	if(user != H)
		return FALSE //forced reproduction is rape.
	if(istype(I, /obj/item/stack/sheet/cardboard))
		var/obj/item/stack/sheet/cardboard/C = I
		if(last_creation + brother_creation_cooldown > world.time) //no cheesing dork
			return
		if(C.amount < 10)
			to_chat(H, span_warning("You do not have enough cardboard!"))
			return FALSE
		to_chat(H, span_notice("You attempt to create a new cardboard brother."))
		if(do_after(user, 30, target = user))
			if(last_creation + brother_creation_cooldown > world.time) //no cheesing dork
				return
			if(!C.use(10))
				to_chat(H, span_warning("You do not have enough cardboard!"))
				return FALSE
			to_chat(H, span_notice("You create a new cardboard golem shell."))
			create_brother(H.loc)

/datum/species/golem/cardboard/proc/create_brother(location)
	new /obj/effect/mob_spawn/human/golem/servant(location, /datum/species/golem/cardboard, owner)
	last_creation = world.time

/datum/species/golem/leather
	name = "Leather Golem"
	id = SPECIES_GOLEM_LEATHER
	special_names = list("Face", "Man", "Belt") //Ah dude 4 strength 4 stam leather belt AHHH
	inherent_traits = list(
		TRAIT_NOBREATH,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_RADIMMUNE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_NODISMEMBER,
		TRAIT_STRONG_GRABBER
	)
	prefix = "Leather"
	fixed_mut_color = "#624a2e"
	info_text = "As a " + span_danger("Leather Golem") + ", you are flammable, but you can grab things with incredible ease, allowing all your grabs to start at a strong level."
	grab_sound = 'sound/weapons/whipgrab.ogg'
	examine_limb_id = SPECIES_GOLEM

/datum/species/golem/durathread
	name = "Durathread Golem"
	id = SPECIES_GOLEM_DURATHREAD
	prefix = "Durathread"
	special_names = list("Boll","Weave")
	fixed_mut_color = null
	inherent_traits = list(
		TRAIT_NOBREATH,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_RADIMMUNE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_NODISMEMBER,
		TRAIT_NOBLOOD,
		TRAIT_NOT_TRANSMORPHIC,
		TRAIT_NO_UNDERWEAR,
		TRAIT_NOFLASH,
	)
	info_text = "As a " + span_danger("Durathread Golem") + ", your strikes will cause those your targets to start choking, but your woven body won't withstand fire as well."

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/golem/durathread,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/golem/durathread,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/golem/durathread,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/golem/durathread,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/golem/durathread,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/golem/durathread
	)

/datum/species/golem/durathread/spec_unarmedattack(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	target.apply_status_effect(/datum/status_effect/strandling)

/datum/species/golem/bone
	name = "Bone Golem"
	id = SPECIES_GOLEM_BONE
	prefix = "Bone"
	special_names = list("Head", "Broth", "Fracture", "Rattler", "Appetit")
	inherent_biotypes = MOB_UNDEAD|MOB_HUMANOID
	mutanttongue = /obj/item/organ/tongue/bone
	sexes = FALSE
	fixed_mut_color = null
	inherent_traits = list(
		TRAIT_RESISTHEAT,
		TRAIT_NOBREATH,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_NOFIRE,
		TRAIT_RADIMMUNE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_NODISMEMBER,
		TRAIT_FAKEDEATH,
		TRAIT_NOBLOOD,
		TRAIT_NO_UNDERWEAR,
		TRAIT_NOFLASH
	)
	species_language_holder = /datum/language_holder/golem/bone
	info_text = "As a " + span_danger("Bone Golem") + ", You have a powerful spell that lets you chill your enemies with fear, and milk heals you! Just make sure to watch our for bone-hurting juice."
	var/datum/action/innate/bonechill/bonechill

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/golem/bone,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/golem/bone,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/golem/bone,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/golem/bone,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/golem/bone,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/golem/bone
	)

/datum/species/golem/bone/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load, regenerate_icons)
	..()
	if(ishuman(C))
		bonechill = new
		bonechill.Grant(C)

/datum/species/golem/bone/on_species_loss(mob/living/carbon/C)
	if(bonechill)
		bonechill.Remove(C)
	..()

/datum/species/golem/bone/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H, delta_time, times_fired)
	if(chem.type == /datum/reagent/consumable/milk)
		if(chem.volume >= 6)
			H.reagents.remove_reagent(chem.type, chem.volume - 5)
			to_chat(H, span_warning("The excess milk is dripping off your bones!"))
		H.heal_bodypart_damage(1.5,0, 0)
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM)
		return TRUE

	if(chem.type == /datum/reagent/toxin/bonehurtingjuice)
		H.adjustBruteLoss(0.5, 0)
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM)
		return TRUE
	return ..()

/datum/action/innate/bonechill
	name = "Bone Chill"
	desc = "Rattle your bones and strike fear into your enemies!"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon = 'icons/hud/actions/actions_spells.dmi'
	button_icon_state = "bonechill"
	var/cooldown = 600
	var/last_use
	var/snas_chance = 3

/datum/action/innate/bonechill/on_activate()
	if(world.time < last_use + cooldown)
		to_chat(owner, span_notice("You aren't ready yet to rattle your bones again."))
		return
	owner.visible_message(span_warning("[owner] rattles [owner.p_their()] bones harrowingly."), span_notice("You rattle your bones."))
	last_use = world.time
	if(prob(snas_chance))
		playsound(get_turf(owner),'sound/magic/RATTLEMEBONES2.ogg', 100)
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			var/mutable_appearance/badtime = mutable_appearance('icons/mob/human/bodyparts.dmi', "b_golem_eyes", CALCULATE_MOB_OVERLAY_LAYER(HIGHEST_LAYER))
			badtime.appearance_flags = RESET_COLOR
			H.overlays_standing[HIGHEST_LAYER+0.5] = badtime
			H.apply_overlay(HIGHEST_LAYER+0.5)
			addtimer(CALLBACK(H, TYPE_PROC_REF(/mob/living/carbon, remove_overlay), HIGHEST_LAYER+0.5), 25)
	else
		playsound(get_turf(owner),'sound/magic/RATTLEMEBONES.ogg', 100)
	for(var/mob/living/L in orange(7, get_turf(owner)))
		if((L.mob_biotypes & MOB_UNDEAD) || isgolem(L) || HAS_TRAIT(L, TRAIT_RESISTCOLD))
			return //Do not affect our brothers

		to_chat(L, span_cultlarge("A spine-chilling sound chills you to the bone!"))
		L.apply_status_effect(/datum/status_effect/bonechill)
		SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "spooked", /datum/mood_event/spooked)

/datum/species/golem/snow
	name = "Snow Golem"
	id = SPECIES_GOLEM_SNOW
	fixed_mut_color = null //custom sprites
	damage_modifier = 45 //down from 55
	info_text = "As a " + span_danger("Snow Golem") + ", you are extremely vulnerable to burn damage, but you can generate snowballs and shoot cryokinetic beams. You will also turn to snow when dying, preventing any form of recovery."
	prefix = "Snow"
	special_names = list("Flake", "Blizzard", "Storm")
	inherent_traits = list(
		TRAIT_NOBREATH,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_RADIMMUNE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_NODISMEMBER,
		TRAIT_NOBLOOD,
		TRAIT_NOT_TRANSMORPHIC,
		TRAIT_NO_UNDERWEAR,
	)

	/// A ref to our "throw snowball" spell we get on species gain.
	var/datum/action/spell/conjure_item/snowball/snowball
	/// A ref to our cryobeam spell we get on species gain.
	var/datum/action/spell/pointed/projectile/cryo/cryo

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/golem/snow,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/golem/snow,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/golem/snow,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/golem/snow,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/golem/snow,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/golem/snow
	)

/datum/species/golem/snow/spec_death(gibbed, mob/living/carbon/human/H)
	H.visible_message(span_danger("[H] turns into a pile of snow!"))
	for(var/obj/item/W in H)
		H.dropItemToGround(W)
	for(var/i in 1 to rand(3,5))
		new /obj/item/stack/sheet/snow(get_turf(H))
	new /obj/item/food/grown/carrot(get_turf(H))
	qdel(H)

/datum/species/golem/snow/on_species_gain(mob/living/carbon/grant_to, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	ADD_TRAIT(grant_to, TRAIT_SNOWSTORM_IMMUNE, SPECIES_TRAIT)

	snowball = new(grant_to)
	snowball.start_cooldown()
	snowball.Grant(grant_to)

	cryo = new(grant_to)
	cryo.start_cooldown()
	cryo.Grant(grant_to)
