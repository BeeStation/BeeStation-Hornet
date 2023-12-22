/datum/species/golem
	// Animated beings of stone. They have increased defenses, and do not need to breathe. They're also slow as fuuuck.
	name = "\improper Golem"
	id = SPECIES_GOLEM_IRON
	species_traits = list(NOBLOOD,MUTCOLORS,NO_UNDERWEAR,NOTRANSSTING)
	inherent_traits = list(TRAIT_RESISTHEAT,TRAIT_NOBREATH,TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_NOFIRE,TRAIT_NOGUNS,TRAIT_RADIMMUNE,TRAIT_PIERCEIMMUNE,TRAIT_NODISMEMBER, TRAIT_NONECRODISEASE)
	inherent_biotypes = list(MOB_INORGANIC, MOB_HUMANOID)
	mutant_organs = list(/obj/item/organ/adamantine_resonator)
	mutanttongue = /obj/item/organ/tongue/golem
	speedmod = 2
	armor = 55
	siemens_coeff = 0
	punchdamage = 11
	no_equip = list(ITEM_SLOT_MASK, ITEM_SLOT_OCLOTHING, ITEM_SLOT_GLOVES, ITEM_SLOT_FEET, ITEM_SLOT_ICLOTHING, ITEM_SLOT_SUITSTORE)
	nojumpsuit = 1
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC
	sexes = FALSE
	damage_overlay_type = ""
	meat = /obj/item/food/meat/slab/human/mutant/golem
	species_language_holder = /datum/language_holder/golem
	// To prevent golem subtypes from overwhelming the odds when random species
	// changes, only the Random Golem type can be chosen
	species_chest = /obj/item/bodypart/chest/golem
	species_head = /obj/item/bodypart/head/golem
	species_l_arm = /obj/item/bodypart/l_arm/golem
	species_r_arm = /obj/item/bodypart/r_arm/golem
	species_l_leg = /obj/item/bodypart/l_leg/golem
	species_r_leg = /obj/item/bodypart/r_leg/golem

	fixed_mut_color = "aaa"
	swimming_component = /datum/component/swimming/golem
	var/info_text = "As an <span class='danger'>Iron Golem</span>, you don't have any special traits."
	var/random_eligible = TRUE //If false, the golem subtype can't be made through golem mutation toxin

	var/prefix = "Iron"
	var/list/special_names = list("Tarkus")
	var/human_surname_chance = 3
	var/special_name_chance = 5
	var/owner //dobby is a free golem

/datum/species/golem/random_name(gender,unique,lastname)
	var/golem_surname = pick(GLOB.golem_names)
	// 3% chance that our golem has a human surname, because
	// cultural contamination
	if(prob(human_surname_chance))
		golem_surname = pick(GLOB.last_names)
	else if(special_names && special_names.len && prob(special_name_chance))
		golem_surname = pick(special_names)

	var/golem_name = "[prefix] [golem_surname]"
	return golem_name

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

/datum/species/golem/random
	name = "Random golem"
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN
	var/static/list/random_golem_types

/datum/species/golem/random/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	if(!random_golem_types)
		random_golem_types = subtypesof(/datum/species/golem) - type
		for(var/V in random_golem_types)
			var/datum/species/golem/G = V
			if(!initial(G.random_eligible))
				random_golem_types -= G
	var/datum/species/golem/golem_type = pick(random_golem_types)
	var/mob/living/carbon/human/H = C
	H.set_species(golem_type)
	to_chat(H, "[initial(golem_type.info_text)]")

/datum/species/golem/adamantine
	name = "Adamantine Golem"
	id = SPECIES_GOLEM_ADAMANTINE
	meat = /obj/item/food/meat/slab/human/mutant/golem/adamantine
	mutant_organs = list(/obj/item/organ/adamantine_resonator, /obj/item/organ/vocal_cords/adamantine)
	fixed_mut_color = "4ed"
	info_text = "As an <span class='danger'>Adamantine Golem</span>, you possess special vocal cords allowing you to \"resonate\" messages to all golems. Your unique mineral makeup makes you immune to most types of magic."
	prefix = "Adamantine"
	special_names = null

/datum/species/golem/adamantine/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	ADD_TRAIT(C, TRAIT_ANTIMAGIC, SPECIES_TRAIT)

/datum/species/golem/adamantine/on_species_loss(mob/living/carbon/C)
	REMOVE_TRAIT(C, TRAIT_ANTIMAGIC, SPECIES_TRAIT)
	..()

//The suicide bombers of golemkind
/datum/species/golem/plasma
	name = "Plasma Golem"
	id = SPECIES_GOLEM_PLASMA
	fixed_mut_color = "a3d"
	meat = /obj/item/stack/ore/plasma
	//Can burn and takes damage from heat
	inherent_traits = list(TRAIT_NOBREATH, TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_NOGUNS,TRAIT_RADIMMUNE,TRAIT_PIERCEIMMUNE,TRAIT_NODISMEMBER) //no RESISTHEAT, NOFIRE
	info_text = "As a <span class='danger'>Plasma Golem</span>, you burn easily. Be careful, if you get hot enough while burning, you'll blow up!"
	heatmod = 0 //fine until they blow up
	prefix = "Plasma"
	special_names = list("Flood","Fire","Bar","Man")
	var/boom_warning = FALSE
	var/datum/action/innate/ignite/ignite

/datum/species/golem/plasma/spec_life(mob/living/carbon/human/H)
	if(H.bodytemperature > 750)
		if(!boom_warning && H.on_fire)
			to_chat(H, "<span class='userdanger'>You feel like you could blow up at any moment!</span>")
			boom_warning = TRUE
	else
		if(boom_warning)
			to_chat(H, "<span class='notice'>You feel more stable.</span>")
			boom_warning = FALSE

	if(H.bodytemperature > 850 && H.on_fire && prob(25))
		explosion(get_turf(H),1,2,4,flame_range = 5)
		if(H)
			H.investigate_log("has been gibbed as [H.p_their()] body explodes.", INVESTIGATE_DEATHS)
			H.gib()
	if(H.fire_stacks < 2) //flammable
		H.adjust_fire_stacks(1)
	..()

/datum/species/golem/plasma/on_species_gain(mob/living/carbon/C, datum/species/old_species)
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

/datum/action/innate/ignite/Activate()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(H.fire_stacks)
			to_chat(owner, "<span class='notice'>You ignite yourself!</span>")
		else
			to_chat(owner, "<span class='warning'>You try to ignite yourself, but fail!</span>")
		H.IgniteMob() //firestacks are already there passively

//Harder to hurt
/datum/species/golem/diamond
	name = "Diamond Golem"
	id = SPECIES_GOLEM_DIAMOND
	fixed_mut_color = "0ff"
	armor = 70 //up from 55
	meat = /obj/item/stack/ore/diamond
	info_text = "As a <span class='danger'>Diamond Golem</span>, you are more resistant than the average golem."
	prefix = "Diamond"
	special_names = list("Back","Grill")

//Faster but softer and less armoured
/datum/species/golem/gold
	name = "Gold Golem"
	id = SPECIES_GOLEM_GOLD
	fixed_mut_color = "cc0"
	speedmod = 1
	armor = 25 //down from 55
	meat = /obj/item/stack/ore/gold
	info_text = "As a <span class='danger'>Gold Golem</span>, you are faster but less resistant than the average golem."
	prefix = "Golden"
	special_names = list("Boy")

//Heavier, thus higher chance of stunning when punching
/datum/species/golem/silver
	name = "Silver Golem"
	id = SPECIES_GOLEM_SILVER
	fixed_mut_color = "ddd"
	meat = /obj/item/stack/ore/silver
	info_text = "As a <span class='danger'>Silver Golem</span>, your attacks have a higher chance of stunning. Being made of silver, your body is immune to most types of magic."
	prefix = "Silver"
	special_names = list("Surfer", "Chariot", "Lining")

/datum/species/golem/silver/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	ADD_TRAIT(C, TRAIT_HOLY, SPECIES_TRAIT)

/datum/species/golem/silver/on_species_loss(mob/living/carbon/C)
	REMOVE_TRAIT(C, TRAIT_HOLY, SPECIES_TRAIT)
	..()

// Softer and faster, but conductive
/datum/species/golem/copper
	name = "Copper Golem"
	id = SPECIES_GOLEM_COPPER
	fixed_mut_color = "#d95802"
	speedmod = 1.5
	armor = 30
	meat = /obj/item/stack/ore/copper
	siemens_coeff = 1 //set as conductive, next line sets shock immunity
	inherent_traits = list(TRAIT_RESISTHEAT,TRAIT_NOBREATH,TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_NOFIRE,TRAIT_NOGUNS,TRAIT_RADIMMUNE,TRAIT_PIERCEIMMUNE,TRAIT_NODISMEMBER, TRAIT_SHOCKIMMUNE)
	info_text = "As a <span class='danger'>Copper Golem</span>, you are faster but less resistant than the average golem. You also act as a conduit for electricity, while not being affected by it."
	prefix = "Copper"
	special_names = list("Wire")

//Harder to stun, deals more damage, massively slowpokes, but gravproof and obstructive. Basically, The Wall.
/datum/species/golem/plasteel
	name = "Plasteel Golem"
	id = SPECIES_GOLEM_PLASTEEL
	fixed_mut_color = "bbb"
	stunmod = 0.4
	punchdamage = 18
	speedmod = 4 //pretty fucking slow
	meat = /obj/item/stack/ore/iron
	info_text = "As a <span class='danger'>Plasteel Golem</span>, you are slower, but harder to stun, and hit very hard when punching. You also magnetically attach to surfaces and so don't float without gravity and cannot have positions swapped with other beings."
	attack_verb = "smash"
	attack_sound = 'sound/effects/meteorimpact.ogg' //hits pretty hard
	prefix = "Plasteel"
	special_names = null

/datum/species/golem/plasteel/negates_gravity(mob/living/carbon/human/H)
	return TRUE

/datum/species/golem/plasteel/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	ADD_TRAIT(C, TRAIT_NOMOBSWAP, SPECIES_TRAIT) //THE WALL THE WALL THE WALL

/datum/species/golem/plasteel/on_species_loss(mob/living/carbon/C)
	REMOVE_TRAIT(C, TRAIT_NOMOBSWAP, SPECIES_TRAIT) //NOTHING ON ERF CAN MAKE IT FALL
	..()

//Immune to ash storms
/datum/species/golem/titanium
	name = "Titanium Golem"
	id = SPECIES_GOLEM_TITANIUM
	fixed_mut_color = "fff"
	meat = /obj/item/stack/ore/titanium
	info_text = "As a <span class='danger'>Titanium Golem</span>, you are immune to ash storms, and slightly more resistant to burn damage."
	burnmod = 0.9
	prefix = "Titanium"
	special_names = list("Dioxide")

/datum/species/golem/titanium/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.weather_immunities |= "ash"

/datum/species/golem/titanium/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.weather_immunities -= "ash"

//Immune to ash storms and lava
/datum/species/golem/plastitanium
	name = "Plastitanium Golem"
	id = SPECIES_GOLEM_PLASTITANIUM
	fixed_mut_color = "888"
	meat = /obj/item/stack/ore/titanium
	info_text = "As a <span class='danger'>Plastitanium Golem</span>, you are immune to both ash storms and lava, and slightly more resistant to burn damage."
	burnmod = 0.8
	prefix = "Plastitanium"
	special_names = null

/datum/species/golem/plastitanium/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.weather_immunities |= "lava"
	C.weather_immunities |= "ash"

/datum/species/golem/plastitanium/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.weather_immunities -= "ash"
	C.weather_immunities -= "lava"

//Fast and regenerates... but can only speak like an abductor
/datum/species/golem/alloy
	name = "Alien Alloy Golem"
	id = SPECIES_GOLEM_ALLOY
	species_traits = list(NOBLOOD,NO_UNDERWEAR,NOEYESPRITES,NOTRANSSTING)
	meat = /obj/item/stack/sheet/mineral/abductor
	mutanttongue = /obj/item/organ/tongue/abductor
	speedmod = 1 //faster
	info_text = "As an <span class='danger'>Alloy Golem</span>, you are made of advanced alien materials: you are faster and regenerate over time. You are, however, only able to be heard by other alloy golems."
	prefix = "Alien"
	special_names = list("Outsider", "Technology", "Watcher", "Stranger") //ominous and unknown

	species_chest = /obj/item/bodypart/chest/golem/alloy
	species_head = /obj/item/bodypart/head/golem/alloy
	species_l_arm = /obj/item/bodypart/l_arm/golem/alloy
	species_r_arm = /obj/item/bodypart/r_arm/golem/alloy
	species_l_leg = /obj/item/bodypart/l_leg/golem/alloy
	species_r_leg = /obj/item/bodypart/r_leg/golem/alloy

//Regenerates because self-repairing super-advanced alien tech
/datum/species/golem/alloy/spec_life(mob/living/carbon/human/H)
	if(H.stat == DEAD)
		return
	H.heal_overall_damage(2,2, 0, BODYTYPE_ORGANIC)
	H.adjustToxLoss(-2)
	H.adjustOxyLoss(-2)

//Since this will usually be created from a collaboration between podpeople and free golems, wood golems are a mix between the two races
/datum/species/golem/wood
	name = "Wood Golem"
	id = SPECIES_GOLEM_WOOD
	fixed_mut_color = "9E704B"
	meat = /obj/item/stack/sheet/wood
	//Can burn and take damage from heat
	inherent_traits = list(TRAIT_NOBREATH, TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_NOGUNS,TRAIT_RADIMMUNE,TRAIT_PIERCEIMMUNE,TRAIT_NODISMEMBER)
	armor = 30
	burnmod = 1.25
	heatmod = 1.5
	info_text = "As a <span class='danger'>Wooden Golem</span>, you have plant-like traits: you take damage from extreme temperatures, can be set on fire, and have lower armor than a normal golem. You regenerate when in the light and wither in the darkness."
	prefix = "Wooden"
	special_names = list("Bark", "Willow", "Catalpa", "Woody", "Oak", "Sap", "Twig", "Branch", "Maple", "Birch", "Elm", "Basswood", "Cottonwood", "Larch", "Aspen", "Ash", "Beech", "Buckeye", "Cedar", "Chestnut", "Cypress", "Fir", "Hawthorn", "Hazel", "Hickory", "Ironwood", "Juniper", "Leaf", "Mangrove", "Palm", "Pawpaw", "Pine", "Poplar", "Redwood", "Redbud", "Sassafras", "Spruce", "Sumac", "Trunk", "Walnut", "Yew")
	human_surname_chance = 0
	special_name_chance = 100
	inherent_factions = list("plants", "vines")

/datum/species/golem/wood/spec_life(mob/living/carbon/human/H)
	if(H.stat == DEAD)
		return
	var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
	if(isturf(H.loc)) //else, there's considered to be no light
		var/turf/T = H.loc
		light_amount = min(1,T.get_lumcount()) - 0.5
		H.adjust_nutrition(light_amount * 10)
		if(H.nutrition > NUTRITION_LEVEL_ALMOST_FULL)
			H.set_nutrition(NUTRITION_LEVEL_ALMOST_FULL)
		if(light_amount > 0.2) //if there's enough light, heal
			H.heal_overall_damage(1,1,0, BODYTYPE_ORGANIC)
			H.adjustToxLoss(-1)
			H.adjustOxyLoss(-1)

	if(H.nutrition < NUTRITION_LEVEL_STARVING + 50)
		H.take_overall_damage(2,0)

/datum/species/golem/wood/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.type == /datum/reagent/toxin/plantbgone)
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.type, chem.metabolization_rate)
		return TRUE
	return ..()

//Radioactive
/datum/species/golem/uranium
	name = "Uranium Golem"
	id = SPECIES_GOLEM_URANIUM
	fixed_mut_color = "7f0"
	meat = /obj/item/stack/ore/uranium
	info_text = "As an <span class='danger'>Uranium Golem</span>, you emit radiation pulses every once in a while. It won't harm fellow golems, but organic lifeforms will be affected."

	var/last_event = 0
	var/active = null
	prefix = "Uranium"
	special_names = list("Oxide", "Rod", "Meltdown", "235")

/datum/species/golem/uranium/spec_life(mob/living/carbon/human/H)
	if(!active)
		if(world.time > last_event+30)
			active = 1
			radiation_pulse(H, 50)
			last_event = world.time
			active = null
	..()

//Immune to physical bullets and resistant to brute, but very vulnerable to burn damage. Dusts on death.
/datum/species/golem/sand
	name = "Sand Golem"
	id = SPECIES_GOLEM_SAND
	fixed_mut_color = "ffdc8f"
	meat = /obj/item/stack/ore/glass //this is sand
	armor = 0
	burnmod = 3 //melts easily
	brutemod = 0.25
	info_text = "As a <span class='danger'>Sand Golem</span>, you are immune to physical bullets and take very little brute damage, but are extremely vulnerable to burn damage and energy weapons. You will also turn to sand when dying, preventing any form of recovery."
	attack_sound = 'sound/effects/shovel_dig.ogg'
	prefix = "Sand"
	special_names = list("Castle", "Bag", "Dune", "Worm", "Storm")

/datum/species/golem/sand/spec_death(gibbed, mob/living/carbon/human/H)
	H.visible_message("<span class='danger'>[H] turns into a pile of sand!</span>")
	for(var/obj/item/W in H)
		H.dropItemToGround(W)
	for(var/i in 1 to rand(3,5))
		new /obj/item/stack/ore/glass(get_turf(H))
	qdel(H)

/datum/species/golem/sand/bullet_act(obj/projectile/P, mob/living/carbon/human/H)
	if(!(P.original == H && P.firer == H))
		if(P.armor_flag == BULLET || P.armor_flag == BOMB)
			playsound(H, 'sound/effects/shovel_dig.ogg', 70, 1)
			H.visible_message("<span class='danger'>The [P.name] sinks harmlessly in [H]'s sandy body!</span>", \
			"<span class='userdanger'>The [P.name] sinks harmlessly in [H]'s sandy body!</span>")
			return BULLET_ACT_BLOCK
	return ..()

//Reflects lasers and resistant to burn damage, but very vulnerable to brute damage. Shatters on death.
/datum/species/golem/glass
	name = "Glass Golem"
	id = SPECIES_GOLEM_GLASS
	fixed_mut_color = "5a96b4aa" //transparent body
	meat = /obj/item/shard
	armor = 0
	brutemod = 3 //very fragile
	burnmod = 0.25
	info_text = "As a <span class='danger'>Glass Golem</span>, you reflect lasers and energy weapons, and are very resistant to burn damage. However, you are extremely vulnerable to brute damage. On death, you'll shatter beyond any hope of recovery."
	attack_sound = 'sound/effects/glassbr2.ogg'
	prefix = "Glass"
	special_names = list("Lens", "Prism", "Fiber", "Bead")

/datum/species/golem/glass/spec_death(gibbed, mob/living/carbon/human/H)
	playsound(H, "shatter", 70, 1)
	H.visible_message("<span class='danger'>[H] shatters!</span>")
	for(var/obj/item/W in H)
		H.dropItemToGround(W)
	for(var/i in 1 to rand(3,5))
		new /obj/item/shard(get_turf(H))
	qdel(H)

/datum/species/golem/glass/bullet_act(obj/projectile/P, mob/living/carbon/human/H)
	if(!(P.original == H && P.firer == H)) //self-shots don't reflect
		if(P.armor_flag == LASER || P.armor_flag == ENERGY)
			H.visible_message("<span class='danger'>The [P.name] gets reflected by [H]'s glass skin!</span>", \
			"<span class='userdanger'>The [P.name] gets reflected by [H]'s glass skin!</span>")
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
	fixed_mut_color = "33f"
	meat = /obj/item/stack/ore/bluespace_crystal
	info_text = "As a <span class='danger'>Bluespace Golem</span>, you are spatially unstable: You will teleport when hit, and you can teleport manually at a long distance."
	attack_verb = "bluespace punch"
	attack_sound = 'sound/effects/phasein.ogg'
	prefix = "Bluespace"
	special_names = list("Crystal", "Polycrystal")

	var/datum/action/innate/unstable_teleport/unstable_teleport
	var/teleport_cooldown = 100
	var/last_teleport = 0

/datum/species/golem/bluespace/proc/reactive_teleport(mob/living/carbon/human/H)
	H.visible_message("<span class='warning'>[H] teleports!</span>", "<span class='danger'>You destabilize and teleport!</span>")
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
	if(world.time > last_teleport + teleport_cooldown && M != H &&  M.a_intent != INTENT_HELP)
		reactive_teleport(H)

/datum/species/golem/bluespace/spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, intent, mob/living/carbon/human/H)
	..()
	if(world.time > last_teleport + teleport_cooldown && user != H)
		reactive_teleport(H)

/datum/species/golem/bluespace/on_hit(obj/projectile/P, mob/living/carbon/human/H)
	..()
	if(world.time > last_teleport + teleport_cooldown)
		reactive_teleport(H)

/datum/species/golem/bluespace/on_species_gain(mob/living/carbon/C, datum/species/old_species)
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
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	var/cooldown = 150
	var/last_teleport = 0

/datum/action/innate/unstable_teleport/IsAvailable()
	if(..())
		if(world.time > last_teleport + cooldown)
			return 1
		return 0

/datum/action/innate/unstable_teleport/Activate()
	var/mob/living/carbon/human/H = owner
	H.visible_message("<span class='warning'>[H] starts vibrating!</span>", "<span class='danger'>You start charging your bluespace core...</span>")
	playsound(get_turf(H), 'sound/weapons/flash.ogg', 25, 1)
	addtimer(CALLBACK(src, PROC_REF(teleport), H), 15)

/datum/action/innate/unstable_teleport/proc/teleport(mob/living/carbon/human/H)
	H.visible_message("<span class='warning'>[H] disappears in a shower of sparks!</span>", "<span class='danger'>You teleport!</span>")
	var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(10, 0, src)
	spark_system.attach(H)
	spark_system.start()
	do_teleport(H, get_turf(H), 12, asoundin = 'sound/weapons/emitter2.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)
	last_teleport = world.time
	UpdateButtonIcon() //action icon looks unavailable
	//action icon looks available again
	addtimer(CALLBACK(src, PROC_REF(UpdateButtonIcon)), cooldown + 5)


//honk
/datum/species/golem/bananium
	name = "Bananium Golem"
	id = SPECIES_GOLEM_BANANIUM
	species_traits = list(NOBLOOD,NO_UNDERWEAR,NOEYESPRITES,NOTRANSSTING)
	punchdamage = 0
	meat = /obj/item/stack/ore/bananium
	mutanttongue = /obj/item/organ/tongue/golem/bananium
	info_text = "As a <span class='danger'>Bananium Golem</span>, you are made for pranking. Your body emits natural honks, and you can barely even hurt people when punching them. Your skin also bleeds banana peels when damaged."
	attack_verb = "honk"
	attack_sound = 'sound/items/airhorn2.ogg'
	prefix = "Bananium"
	special_names = null

	species_chest = /obj/item/bodypart/chest/golem/bananium
	species_head = /obj/item/bodypart/head/golem/bananium
	species_l_arm = /obj/item/bodypart/l_arm/golem/bananium
	species_r_arm = /obj/item/bodypart/r_arm/golem/bananium
	species_l_leg = /obj/item/bodypart/l_leg/golem/bananium
	species_r_leg = /obj/item/bodypart/r_leg/golem/bananium

	var/last_honk = 0
	var/honkooldown = 0
	var/last_banana = 0
	var/banana_cooldown = 100
	var/active = null

/datum/species/golem/bananium/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	last_banana = world.time
	last_honk = world.time
	RegisterSignal(C, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/species/golem/bananium/on_species_loss(mob/living/carbon/C)
	. = ..()
	UnregisterSignal(C, COMSIG_MOB_SAY)

/datum/species/golem/bananium/random_name(gender,unique,lastname)
	var/clown_name = pick(GLOB.clown_names)
	var/golem_name = "[uppertext(clown_name)]"
	return golem_name

/datum/species/golem/bananium/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style)
	..()
	if(world.time > last_banana + banana_cooldown && M != H &&  M.a_intent != INTENT_HELP)
		new/obj/item/grown/bananapeel/specialpeel(get_turf(H))
		last_banana = world.time

/datum/species/golem/bananium/spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, intent, mob/living/carbon/human/H)
	..()
	if(world.time > last_banana + banana_cooldown && user != H)
		new/obj/item/grown/bananapeel/specialpeel(get_turf(H))
		last_banana = world.time

/datum/species/golem/bananium/on_hit(obj/projectile/P, mob/living/carbon/human/H)
	..()
	if(world.time > last_banana + banana_cooldown)
		new/obj/item/grown/bananapeel/specialpeel(get_turf(H))
		last_banana = world.time

/datum/species/golem/bananium/spec_hitby(atom/movable/AM, mob/living/carbon/human/H)
	..()
	var/obj/item/I
	if(istype(AM, /obj/item))
		I = AM
		if(I.thrownby == WEAKREF(H)) //No throwing stuff at yourself to make bananas
			return 0
		else
			new/obj/item/grown/bananapeel/specialpeel(get_turf(H))
			last_banana = world.time

/datum/species/golem/bananium/spec_life(mob/living/carbon/human/H)
	if(!active)
		if(world.time > last_honk + honkooldown)
			active = 1
			playsound(get_turf(H), 'sound/items/bikehorn.ogg', 50, 1)
			last_honk = world.time
			honkooldown = rand(20, 80)
			active = null
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
	info_text = "As a <span class='danger'>Runic Golem</span>, you possess eldritch powers granted by the Elder Goddess Nar'Sie."
	species_traits = list(NOBLOOD,NO_UNDERWEAR,NOEYESPRITES,NOFLASH,NOTRANSSTING) //no mutcolors
	prefix = "Runic"
	special_names = null
	random_eligible = FALSE //Zesko claims runic golems break the game
	inherent_factions = list("cult")
	species_language_holder = /datum/language_holder/golem/runic
	var/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/golem/phase_shift
	var/obj/effect/proc_holder/spell/targeted/abyssal_gaze/abyssal_gaze
	var/obj/effect/proc_holder/spell/targeted/dominate/dominate

	species_chest = /obj/item/bodypart/chest/golem/cult
	species_head = /obj/item/bodypart/head/golem/cult
	species_l_arm = /obj/item/bodypart/l_arm/golem/cult
	species_r_arm = /obj/item/bodypart/r_arm/golem/cult
	species_l_leg = /obj/item/bodypart/l_leg/golem/cult
	species_r_leg = /obj/item/bodypart/r_leg/golem/cult

/datum/species/golem/runic/random_name(gender,unique,lastname)
	var/edgy_first_name = pick("Razor","Blood","Dark","Evil","Cold","Pale","Black","Silent","Chaos","Deadly","Coldsteel")
	var/edgy_last_name = pick("Edge","Night","Death","Razor","Blade","Steel","Calamity","Twilight","Shadow","Nightmare") //dammit Razor Razor
	var/golem_name = "[edgy_first_name] [edgy_last_name]"
	return golem_name

/datum/species/golem/runic/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	phase_shift = new
	phase_shift.charge_counter = 0
	phase_shift.start_recharge()
	C.AddSpell(phase_shift)
	abyssal_gaze = new
	abyssal_gaze.charge_counter = 0
	abyssal_gaze.start_recharge()
	C.AddSpell(abyssal_gaze)
	dominate = new
	dominate.charge_counter = 0
	dominate.start_recharge()
	C.AddSpell(dominate)

/datum/species/golem/runic/on_species_loss(mob/living/carbon/C)
	. = ..()
	if(phase_shift)
		C.RemoveSpell(phase_shift)
	if(abyssal_gaze)
		C.RemoveSpell(abyssal_gaze)
	if(dominate)
		C.RemoveSpell(dominate)

/datum/species/golem/runic/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(istype(chem, /datum/reagent/water/holywater))
		H.adjustFireLoss(4)
		H.reagents.remove_reagent(chem.type, chem.metabolization_rate)
		return TRUE

	if(chem.type == /datum/reagent/fuel/unholywater)
		H.adjustBruteLoss(-4)
		H.adjustFireLoss(-4)
		H.reagents.remove_reagent(chem.type, chem.metabolization_rate)
		return TRUE
	return ..()

/datum/species/golem/clockwork
	name = "Clockwork Golem"
	id = SPECIES_GOLEM_CLOCKWORK
	info_text = "<span class='bold alloy'>As a </span><span class='bold brass'>Clockwork Golem</span><span class='bold alloy'>, you are faster than other types of golems. On death, you will break down into scrap.</span>"
	species_traits = list(NOBLOOD,NO_UNDERWEAR,NOEYESPRITES,NOFLASH,NOTRANSSTING)
	inherent_biotypes = list(MOB_ROBOTIC, MOB_HUMANOID)
	armor = 20 //Reinforced, but much less so to allow for fast movement
	attack_verb = "smash"
	attack_sound = 'sound/magic/clockwork/anima_fragment_attack.ogg'
	sexes = FALSE
	speedmod = 0
	changesource_flags = MIRROR_BADMIN | WABBAJACK
	damage_overlay_type = "synth"
	prefix = "Clockwork"
	special_names = list("Remnant", "Relic", "Scrap", "Vestige") //RIP Ratvar
	inherent_factions = list("ratvar")
	mutanttongue = /obj/item/organ/tongue/golem/clockwork
	var/has_corpse

	species_chest = /obj/item/bodypart/chest/golem/clock
	species_head = /obj/item/bodypart/head/golem/clock
	species_l_arm = /obj/item/bodypart/l_arm/golem/clock
	species_r_arm = /obj/item/bodypart/r_arm/golem/clock
	species_l_leg = /obj/item/bodypart/l_leg/golem/clock
	species_r_leg = /obj/item/bodypart/r_leg/golem/clock

/datum/species/golem/clockwork/on_species_gain(mob/living/carbon/human/H)
	. = ..()
	RegisterSignal(H, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/species/golem/clockwork/on_species_loss(mob/living/carbon/human/H)
	UnregisterSignal(H, COMSIG_MOB_SAY)
	. = ..()

/datum/species/golem/clockwork/proc/handle_speech(datum/source, list/speech_args)
	speech_args[SPEECH_SPANS] |= SPAN_ROBOT //beep

/datum/species/golem/clockwork/spec_death(gibbed, mob/living/carbon/human/H)
	gibbed = !has_corpse ? FALSE : gibbed
	. = ..()
	if(!has_corpse)
		var/turf/T = get_turf(H)
		H.visible_message("<span class='warning'>[H]'s exoskeleton shatters, collapsing into a heap of scrap!</span>")
		playsound(H, 'sound/magic/clockwork/anima_fragment_death.ogg', 62, TRUE)
		for(var/i in 1 to rand(3, 5))
			new/obj/item/clockwork/alloy_shards/small(T)
		new/obj/item/clockwork/alloy_shards/clockgolem_remains(T)
		qdel(H)

/datum/species/golem/clockwork/no_scrap //These golems are created through the herald's beacon and leave normal corpses on death.
	id = SPECIES_GOLEM_CLOCKWORK_SERVANT
	armor = 15 //Balance reasons make this armor weak
	no_equip = list()
	nojumpsuit = FALSE
	has_corpse = TRUE
	random_eligible = FALSE
	info_text = "<span class='bold alloy'>As a </span><span class='bold brass'>Clockwork Golem Servant</span><span class='bold alloy'>, you are faster than other types of golems.</span>" //warcult golems leave a corpse

/datum/species/golem/cloth
	name = "Cloth Golem"
	id = SPECIES_GOLEM_CLOTH
	sexes = FALSE
	info_text = "As a <span class='danger'>Cloth Golem</span>, you are able to reform yourself after death, provided your remains aren't burned or destroyed. You are, of course, very flammable. \
	Being made of cloth, your body is magic resistant and faster than that of other golems, but weaker and less resilient."
	species_traits = list(NOBLOOD,NO_UNDERWEAR,NOTRANSSTING) //no mutcolors, and can burn
	inherent_traits = list(TRAIT_RESISTCOLD,TRAIT_NOBREATH,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_RADIMMUNE,TRAIT_PIERCEIMMUNE,TRAIT_NODISMEMBER,TRAIT_NOGUNS)
	inherent_biotypes = list(MOB_UNDEAD, MOB_HUMANOID)
	armor = 15 //feels no pain, but not too resistant
	burnmod = 2 // don't get burned
	speedmod = 1 // not as heavy as stone
	punchdamage = 6
	prefix = "Cloth"
	special_names = null

	species_chest = /obj/item/bodypart/chest/golem/cloth
	species_head = /obj/item/bodypart/head/golem/cloth
	species_l_arm = /obj/item/bodypart/l_arm/golem/cloth
	species_r_arm = /obj/item/bodypart/r_arm/golem/cloth
	species_l_leg = /obj/item/bodypart/l_leg/golem/cloth
	species_r_leg = /obj/item/bodypart/r_leg/golem/cloth

/datum/species/golem/cloth/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	ADD_TRAIT(C, TRAIT_HOLY, SPECIES_TRAIT)

/datum/species/golem/cloth/on_species_loss(mob/living/carbon/C)
	REMOVE_TRAIT(C, TRAIT_HOLY, SPECIES_TRAIT)
	..()

/datum/species/golem/cloth/check_roundstart_eligible()
	if(SSevents.holidays && SSevents.holidays[HALLOWEEN])
		return TRUE
	return ..()

/datum/species/golem/cloth/random_name(gender,unique,lastname)
	var/pharaoh_name = pick("Neferkare", "Hudjefa", "Khufu", "Mentuhotep", "Ahmose", "Amenhotep", "Thutmose", "Hatshepsut", "Tutankhamun", "Ramses", "Seti", \
	"Merenptah", "Djer", "Semerkhet", "Nynetjer", "Khafre", "Pepi", "Intef", "Ay") //yes, Ay was an actual pharaoh
	var/golem_name = "[pharaoh_name] \Roman[rand(1,99)]"
	return golem_name

/datum/species/golem/cloth/spec_life(mob/living/carbon/human/H)
	if(H.fire_stacks < 1)
		H.adjust_fire_stacks(1) //always prone to burning
	..()

/datum/species/golem/cloth/spec_death(gibbed, mob/living/carbon/human/H)
	if(gibbed)
		return
	if(H.on_fire)
		H.visible_message("<span class='danger'>[H] burns into ash!</span>")
		H.dust(just_ash = TRUE)
		return

	H.visible_message("<span class='danger'>[H] falls apart into a pile of bandages!</span>")
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
	armor = list(MELEE = 90,  BULLET = 90, LASER = 25, ENERGY = 80, BOMB = 50, BIO = 100, FIRE = -50, ACID = -50, STAMINA = 0)
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "pile_bandages"
	resistance_flags = FLAMMABLE

	var/revive_time = 900
	var/mob/living/carbon/human/cloth_golem

/obj/structure/cloth_pile/Initialize(mapload, mob/living/carbon/human/H)
	. = ..()
	if(!QDELETED(H) && is_species(H, /datum/species/golem/cloth))
		H.unequip_everything()
		H.forceMove(src)
		cloth_golem = H
		to_chat(cloth_golem, "<span class='notice'>You start gathering your life energy, preparing to rise again...</span>")
		addtimer(CALLBACK(src, PROC_REF(revive)), revive_time)
	else
		return INITIALIZE_HINT_QDEL

/obj/structure/cloth_pile/Destroy()
	if(cloth_golem)
		QDEL_NULL(cloth_golem)
	return ..()

/obj/structure/cloth_pile/burn()
	visible_message("<span class='danger'>[src] burns into ash!</span>")
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	..()

/obj/structure/cloth_pile/proc/revive()
	if(QDELETED(src) || QDELETED(cloth_golem)) //QDELETED also checks for null, so if no cloth golem is set this won't runtime
		return
	if(cloth_golem.suiciding || cloth_golem.ishellbound())
		QDEL_NULL(cloth_golem)
		return

	invisibility = INVISIBILITY_MAXIMUM //disappear before the animation
	new /obj/effect/temp_visual/mummy_animation(get_turf(src))
	if(cloth_golem.revive(full_heal = TRUE, admin_revive = TRUE))
		cloth_golem.grab_ghost() //won't pull if it's a suicide
	sleep(20)
	cloth_golem.forceMove(get_turf(src))
	cloth_golem.visible_message("<span class='danger'>[src] rises and reforms into [cloth_golem]!</span>","<span class='userdanger'>You reform into yourself!</span>")
	cloth_golem = null
	qdel(src)

/obj/structure/cloth_pile/attackby(obj/item/P, mob/living/carbon/human/user, params)
	. = ..()

	if(resistance_flags & ON_FIRE)
		return

	if(P.is_hot())
		visible_message("<span class='danger'>[src] bursts into flames!</span>")
		fire_act()

/datum/species/golem/plastic
	name = "Plastic Golem"
	id = SPECIES_GOLEM_PLASTIC
	prefix = "Plastic"
	special_names = list("Sheet", "Bag", "Bottle")
	fixed_mut_color = "fffa"
	info_text = "As a <span class='danger'>Plastic Golem</span>, you are capable of ventcrawling and passing through plastic flaps as long as you are naked."

/datum/species/golem/plastic/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.ventcrawler = VENTCRAWLER_NUDE

/datum/species/golem/plastic/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.ventcrawler = initial(C.ventcrawler)

/datum/species/golem/bronze
	name = "Bronze Golem"
	id = SPECIES_GOLEM_BRONZE
	prefix = "Bronze"
	special_names = list("Bell")
	fixed_mut_color = "cd7f32"
	info_text = "As a <span class='danger'>Bronze Golem</span>, you are very resistant to loud noises, and make loud noises if something hard hits you, however this ability does hurt your hearing."
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
	if(world.time > last_gong_time + gong_cooldown &&  M.a_intent != INTENT_HELP)
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
			H.show_message("<span class='narsiesmall'>You cringe with pain as your body rings around you!</span>", MSG_AUDIBLE)
			H.playsound_local(H, 'sound/effects/gong.ogg', 100, TRUE)
			H.soundbang_act(2, 0, 100, 1)
			H.jitteriness += 7
		var/distance = max(0,get_dist(get_turf(H),get_turf(M)))
		switch(distance)
			if(0 to 1)
				M.show_message("<span class='narsiesmall'>GONG!</span>", MSG_AUDIBLE)
				M.playsound_local(H, 'sound/effects/gong.ogg', 100, TRUE)
				M.soundbang_act(1, 0, 30, 3)
				M.confused += 10
				M.jitteriness += 4
				SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "gonged", /datum/mood_event/loud_gong)
			if(2 to 3)
				M.show_message("<span class='cult'>GONG!</span>", MSG_AUDIBLE)
				M.playsound_local(H, 'sound/effects/gong.ogg', 75, TRUE)
				M.soundbang_act(1, 0, 15, 2)
				M.jitteriness += 3
				SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "gonged", /datum/mood_event/loud_gong)
			else
				M.show_message("<span class='warning'>GONG!</span>", MSG_AUDIBLE)
				M.playsound_local(H, 'sound/effects/gong.ogg', 50, TRUE)


/datum/species/golem/cardboard //Faster but weaker, can also make new shells on its own
	name = "Cardboard Golem"
	id = SPECIES_GOLEM_CARDBOARD
	prefix = "Cardboard"
	special_names = list("Box")
	info_text = "As a <span class='danger'>Cardboard Golem</span>, you aren't very strong, but you are a bit quicker and can easily create more brethren by using cardboard on yourself."
	species_traits = list(NOBLOOD,NO_UNDERWEAR,NOEYESPRITES,NOFLASH,NOTRANSSTING)
	inherent_traits = list(TRAIT_NOBREATH, TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_NOGUNS,TRAIT_RADIMMUNE,TRAIT_PIERCEIMMUNE,TRAIT_NODISMEMBER)
	attack_verb = "whips"
	attack_sound = 'sound/weapons/whip.ogg'
	miss_sound = 'sound/weapons/etherealmiss.ogg'
	fixed_mut_color = null
	armor = 25
	burnmod = 1.25
	heatmod = 2
	speedmod = 1.5
	punchdamage = 6
	var/last_creation = 0
	var/brother_creation_cooldown = 300

	species_chest = /obj/item/bodypart/chest/golem/cardboard
	species_head = /obj/item/bodypart/head/golem/cardboard
	species_l_arm = /obj/item/bodypart/l_arm/golem/cardboard
	species_r_arm = /obj/item/bodypart/r_arm/golem/cardboard
	species_l_leg = /obj/item/bodypart/l_leg/golem/cardboard
	species_r_leg = /obj/item/bodypart/r_leg/golem/cardboard

/datum/species/golem/cardboard/spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, intent, mob/living/carbon/human/H)
	. = ..()
	if(user != H)
		return FALSE //forced reproduction is rape.
	if(istype(I, /obj/item/stack/sheet/cardboard))
		var/obj/item/stack/sheet/cardboard/C = I
		if(last_creation + brother_creation_cooldown > world.time) //no cheesing dork
			return
		if(C.amount < 10)
			to_chat(H, "<span class='warning'>You do not have enough cardboard!</span>")
			return FALSE
		to_chat(H, "<span class='notice'>You attempt to create a new cardboard brother.</span>")
		if(do_after(user, 30, target = user))
			if(last_creation + brother_creation_cooldown > world.time) //no cheesing dork
				return
			if(!C.use(10))
				to_chat(H, "<span class='warning'>You do not have enough cardboard!</span>")
				return FALSE
			to_chat(H, "<span class='notice'>You create a new cardboard golem shell.</span>")
			create_brother(H.loc)

/datum/species/golem/cardboard/proc/create_brother(var/location)
	new /obj/effect/mob_spawn/human/golem/servant(location, /datum/species/golem/cardboard, owner)
	last_creation = world.time

/datum/species/golem/leather
	name = "Leather Golem"
	id = SPECIES_GOLEM_LEATHER
	special_names = list("Face", "Man", "Belt") //Ah dude 4 strength 4 stam leather belt AHHH
	inherent_traits = list(TRAIT_NOBREATH, TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_NOGUNS,TRAIT_RADIMMUNE,TRAIT_PIERCEIMMUNE,TRAIT_NODISMEMBER, TRAIT_STRONG_GRABBER)
	prefix = "Leather"
	fixed_mut_color = "624a2e"
	info_text = "As a <span class='danger'>Leather Golem</span>, you are flammable, but you can grab things with incredible ease, allowing all your grabs to start at a strong level."
	grab_sound = 'sound/weapons/whipgrab.ogg'
	attack_sound = 'sound/weapons/whip.ogg'

/datum/species/golem/durathread
	name = "Durathread Golem"
	id = SPECIES_GOLEM_DURATHREAD
	prefix = "Durathread"
	special_names = list("Boll","Weave")
	species_traits = list(NOBLOOD,NO_UNDERWEAR,NOEYESPRITES,NOFLASH,NOTRANSSTING)
	fixed_mut_color = null
	inherent_traits = list(TRAIT_NOBREATH, TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_NOGUNS,TRAIT_RADIMMUNE,TRAIT_PIERCEIMMUNE,TRAIT_NODISMEMBER)
	info_text = "As a <span class='danger'>Durathread Golem</span>, your strikes will cause those your targets to start choking, but your woven body won't withstand fire as well."

	species_chest = /obj/item/bodypart/chest/golem/durathread
	species_head = /obj/item/bodypart/head/golem/durathread
	species_l_arm = /obj/item/bodypart/l_arm/golem/durathread
	species_r_arm = /obj/item/bodypart/r_arm/golem/durathread
	species_l_leg = /obj/item/bodypart/l_leg/golem/durathread
	species_r_leg = /obj/item/bodypart/r_leg/golem/durathread

/datum/species/golem/durathread/spec_unarmedattacked(mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = ..()
	target.apply_status_effect(STATUS_EFFECT_CHOKINGSTRAND)

/datum/species/golem/bone
	name = "Bone Golem"
	id = SPECIES_GOLEM_BONE
	prefix = "Bone"
	special_names = list("Head", "Broth", "Fracture", "Rattler", "Appetit")
	species_traits = list(NOBLOOD,NO_UNDERWEAR,NOEYESPRITES,NOFLASH)
	inherent_biotypes = list(MOB_UNDEAD, MOB_HUMANOID)
	mutanttongue = /obj/item/organ/tongue/bone
	sexes = FALSE
	fixed_mut_color = null
	inherent_traits = list(TRAIT_RESISTHEAT,TRAIT_NOBREATH,TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_NOFIRE,TRAIT_NOGUNS,TRAIT_RADIMMUNE,TRAIT_PIERCEIMMUNE,TRAIT_NODISMEMBER,TRAIT_FAKEDEATH)
	species_language_holder = /datum/language_holder/golem/bone
	info_text = "As a <span class='danger'>Bone Golem</span>, You have a powerful spell that lets you chill your enemies with fear, and milk heals you! Just make sure to watch our for bone-hurting juice."
	var/datum/action/innate/bonechill/bonechill

	species_chest = /obj/item/bodypart/chest/golem/bone
	species_head = /obj/item/bodypart/head/golem/bone
	species_l_arm = /obj/item/bodypart/l_arm/golem/bone
	species_r_arm = /obj/item/bodypart/r_arm/golem/bone
	species_l_leg = /obj/item/bodypart/l_leg/golem/bone
	species_r_leg = /obj/item/bodypart/r_leg/golem/bone

/datum/species/golem/bone/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	if(ishuman(C))
		bonechill = new
		bonechill.Grant(C)

/datum/species/golem/bone/on_species_loss(mob/living/carbon/C)
	if(bonechill)
		bonechill.Remove(C)
	..()

/datum/species/golem/bone/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
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
	return ..()

/datum/action/innate/bonechill
	name = "Bone Chill"
	desc = "Rattle your bones and strike fear into your enemies!"
	check_flags = AB_CHECK_CONSCIOUS
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "bonechill"
	var/cooldown = 600
	var/last_use
	var/snas_chance = 3

/datum/action/innate/bonechill/Activate()
	if(world.time < last_use + cooldown)
		to_chat("<span class='notice'>You aren't ready yet to rattle your bones again.</span>")
		return
	owner.visible_message("<span class='warning'>[owner] rattles [owner.p_their()] bones harrowingly.</span>", "<span class='notice'>You rattle your bones.</span>")
	last_use = world.time
	if(prob(snas_chance))
		playsound(get_turf(owner),'sound/magic/RATTLEMEBONES2.ogg', 100)
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			var/mutable_appearance/badtime = mutable_appearance('icons/mob/human_parts.dmi', "b_golem_eyes", CALCULATE_MOB_OVERLAY_LAYER(FIRE_LAYER))
			badtime.appearance_flags = RESET_COLOR
			H.overlays_standing[FIRE_LAYER+0.5] = badtime
			H.apply_overlay(FIRE_LAYER+0.5)
			addtimer(CALLBACK(H, TYPE_PROC_REF(/mob/living/carbon, remove_overlay), FIRE_LAYER+0.5), 25)
	else
		playsound(get_turf(owner),'sound/magic/RATTLEMEBONES.ogg', 100)
	for(var/mob/living/L in orange(7, get_turf(owner)))
		if((MOB_UNDEAD in L.mob_biotypes) || isgolem(L) || HAS_TRAIT(L, TRAIT_RESISTCOLD))
			return //Do not affect our brothers

		to_chat(L, "<span class='cultlarge'>A spine-chilling sound chills you to the bone!</span>")
		L.apply_status_effect(/datum/status_effect/bonechill)
		SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "spooked", /datum/mood_event/spooked)

/datum/species/golem/snow
	name = "Snow Golem"
	id = SPECIES_GOLEM_SNOW
	fixed_mut_color = "null" //custom sprites
	armor = 45 //down from 55
	burnmod = 3 //melts easily
	info_text = "As a <span class='danger'>Snow Golem</span>, you are extremely vulnerable to burn damage, but you can generate snowballs and shoot cryokinetic beams. You will also turn to snow when dying, preventing any form of recovery."
	prefix = "Snow"
	special_names = list("Flake", "Blizzard", "Storm")
	species_traits = list(NOBLOOD,NO_UNDERWEAR,NOEYESPRITES,NOTRANSSTING) //no mutcolors, no eye sprites
	inherent_traits = list(TRAIT_NOBREATH,TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_NOGUNS,TRAIT_RADIMMUNE,TRAIT_PIERCEIMMUNE,TRAIT_NODISMEMBER)

	var/obj/effect/proc_holder/spell/targeted/conjure_item/snowball/ball
	var/obj/effect/proc_holder/spell/aimed/cryo/cryo

	species_chest = /obj/item/bodypart/chest/golem/snow
	species_head = /obj/item/bodypart/head/golem/snow
	species_l_arm = /obj/item/bodypart/l_arm/golem/snow
	species_r_arm = /obj/item/bodypart/r_arm/golem/snow
	species_l_leg = /obj/item/bodypart/l_leg/golem/snow
	species_r_leg = /obj/item/bodypart/r_leg/golem/snow

/datum/species/golem/snow/spec_death(gibbed, mob/living/carbon/human/H)
	H.visible_message("<span class='danger'>[H] turns into a pile of snow!</span>")
	for(var/obj/item/W in H)
		H.dropItemToGround(W)
	for(var/i in 1 to rand(3,5))
		new /obj/item/stack/sheet/snow(get_turf(H))
	new /obj/item/food/grown/carrot(get_turf(H))
	qdel(H)

/datum/species/golem/snow/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.weather_immunities |= "snow"
	ball = new
	ball.charge_counter = 0
	ball.start_recharge()
	C.AddSpell(ball)
	cryo = new
	cryo.charge_counter = 0
	cryo.start_recharge()
	C.AddSpell(cryo)

/datum/species/golem/snow/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.weather_immunities -= "snow"
	if(ball)
		C.RemoveSpell(ball)
	if(cryo)
		C.RemoveSpell(cryo)

/obj/effect/proc_holder/spell/targeted/conjure_item/snowball
	name = "Snowball"
	desc = "Concentrates cryokinetic forces to create snowballs, useful for throwing at people."
	item_type = /obj/item/toy/snowball
	charge_max = 15
	action_icon = 'icons/obj/toy.dmi'
	action_icon_state = "snowball"

/datum/species/golem/capitalist
	name = "Capitalist Golem"
	id = SPECIES_GOLEM_CAPITALIST
	prefix = "Capitalist"
	attack_verb = "monopoliz"
	special_names = list("John D. Rockefeller","Rich Uncle Pennybags","Commodore Vanderbilt","Entrepreneur","Mr. Moneybags", "Adam Smith")
	species_traits = list(NOBLOOD,NO_UNDERWEAR,NOEYESPRITES,NOFLASH,NOTRANSSTING)
	fixed_mut_color = null
	inherent_traits = list(TRAIT_RESISTHEAT,TRAIT_NOBREATH,TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_NOFIRE,TRAIT_RADIMMUNE,TRAIT_PIERCEIMMUNE,TRAIT_NODISMEMBER)
	info_text = "As a <span class='danger'>Capitalist Golem</span>, your fist spreads the powerful industrializing light of capitalism."
	changesource_flags = MIRROR_BADMIN
	random_eligible = FALSE

	var/last_cash = 0
	var/cash_cooldown = 100

/datum/species/golem/capitalist/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.equip_to_slot_or_del(new /obj/item/clothing/glasses/monocle (), ITEM_SLOT_EYES)
	C.revive(full_heal = TRUE)

	SEND_SOUND(C, sound('sound/misc/capitialism.ogg'))
	C.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/knock ())
	RegisterSignal(C, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/species/golem/capitalist/on_species_loss(mob/living/carbon/C)
	. = ..()
	UnregisterSignal(C, COMSIG_MOB_SAY)
	for(var/obj/effect/proc_holder/spell/aoe_turf/knock/spell in C.mob_spell_list)
		C.RemoveSpell(spell)

/datum/species/golem/capitalist/spec_unarmedattacked(mob/living/carbon/human/user, mob/living/carbon/human/target)
	..()
	if(isgolem(target))
		return
	if(target.nutrition >= NUTRITION_LEVEL_FAT)
		target.set_species(/datum/species/golem/capitalist)
		return
	target.adjust_nutrition(40)

/datum/species/golem/capitalist/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	playsound(source, 'sound/misc/mymoney.ogg', 25, 0)
	speech_args[SPEECH_MESSAGE] = "Hello, I like money!"

/datum/species/golem/soviet
	name = "Soviet Golem"
	id = SPECIES_GOLEM_SOVIET
	prefix = "Comrade"
	attack_verb = "nationaliz"
	special_names = list("Stalin","Lenin","Trotsky","Marx","Comrade") //comrade comrade
	species_traits = list(NOBLOOD,NO_UNDERWEAR,NOEYESPRITES,NOFLASH,NOTRANSSTING)
	fixed_mut_color = null
	inherent_traits = list(TRAIT_RESISTHEAT,TRAIT_NOBREATH,TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_NOFIRE,TRAIT_RADIMMUNE,TRAIT_PIERCEIMMUNE,TRAIT_NODISMEMBER)
	info_text = "As a <span class='danger'>Soviet Golem</span>, your fist spreads the bright soviet light of communism."
	changesource_flags = MIRROR_BADMIN
	random_eligible = FALSE

/datum/species/golem/soviet/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.equip_to_slot_or_del(new /obj/item/clothing/head/ushanka (), ITEM_SLOT_HEAD)
	C.revive(full_heal = TRUE)

	SEND_SOUND(C, sound('sound/misc/Russian_Anthem_chorus.ogg'))
	C.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/knock ())
	RegisterSignal(C, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/species/golem/soviet/on_species_loss(mob/living/carbon/C)
	. = ..()
	for(var/obj/effect/proc_holder/spell/aoe_turf/knock/spell in C.mob_spell_list)
		C.RemoveSpell(spell)
	UnregisterSignal(C, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/species/golem/soviet/spec_unarmedattacked(mob/living/carbon/human/user, mob/living/carbon/human/target)
	..()
	if(isgolem(target))
		return
	if(target.nutrition <= NUTRITION_LEVEL_STARVING)
		target.set_species(/datum/species/golem/soviet)
		return
	target.adjust_nutrition(-40)

/datum/species/golem/soviet/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	playsound(source, 'sound/misc/Cyka Blyat.ogg', 25, 0)
	speech_args[SPEECH_MESSAGE] = "Cyka Blyat"
