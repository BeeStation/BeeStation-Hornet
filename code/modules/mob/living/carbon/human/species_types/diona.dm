/* TO DO:
tongue, liver, lungs, stomach, heart, action buttons sprites

make the diona mutation work correctly, give a second button to switch between the remote control and original body of the diona, only allow one remote control at a time (unless it dies, then allow another to spawn)


testmerge
win and get those 85 CAD

*/

/datum/species/diona
	name = "\improper Diona"
	plural_form = "Dionae"
	id = SPECIES_DIONA
	sexes = 0
	bodyflag = FLAG_DIONA
	default_color = "59CE00"
	species_traits = list(MUTCOLORS,EYECOLOR,AGENDER,NOHUSK,NO_DNA_COPY,NOMOUTH,NO_UNDERWEAR,NOSOCKS,NOTRANSSTING,NOEYESPRITES)
	inherent_traits = list(TRAIT_ALWAYS_CLEAN, TRAIT_BEEFRIEND, TRAIT_NONECRODISEASE)
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID, MOB_BUG)
	mutant_bodyparts = list("diona_leaves", "diona_thorns", "diona_flowers", "diona_moss", "diona_mushroom", "diona_antennae", "diona_eyes", "diona_pbody")
	default_features = list("diona_leaves" = "None", "diona_thorns" = "None", "diona_flowers" = "None", "diona_moss" = "None", "diona_mushroom" = "None", "diona_antennae" = "None", "body_size" = "Normal", "diona_eyes" = "None", "diona_pbody" = "None")
	inherent_factions = list("plants", "vines")
	fixed_mut_color = "59CE00"
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slice.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	burnmod = 1.25
	heatmod = 1.5
	brutemod = 0.8
	staminamod = 0.7
	meat = /obj/item/food/meat/slab/human/mutant/diona
	exotic_blood = /datum/reagent/water
	species_gibs = GIB_TYPE_ROBOTIC //Someone please make this like, xeno gibs or something in the future. I cant be bothered to fuck around with gib code right now.
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP
	species_language_holder = /datum/language_holder/diona
	bodytemp_normal = (BODYTEMP_NORMAL - 22) // Body temperature for dionae is much lower then humans as they are plants, supposed to be 15 celsius
	speedmod = 2 // Dionae are slow.
	species_height = SPECIES_HEIGHTS(-1, 0, -2) //Naturally tall.
	swimming_component = /datum/component/swimming/diona
	inert_mutation = DRONE

	mutanteyes = /obj/item/organ/eyes/diona //SS14 sprite
	mutanttongue = /obj/item/organ/tongue/diona //placeholder sprite
	mutant_brain = /obj/item/organ/brain/diona //SS14 sprite
	mutantliver = /obj/item/organ/liver/diona //placeholder sprite
	mutantlungs = /obj/item/organ/lungs/diona //placeholder sprite
	mutantstomach = /obj/item/organ/stomach/diona //SS14 sprite
	mutantears = /obj/item/organ/ears/diona //SS14 sprite
	mutant_heart = /obj/item/organ/heart/diona //placeholder sprite
	mutant_organs = list()

	species_chest = /obj/item/bodypart/chest/diona
	species_head = /obj/item/bodypart/head/diona
	species_l_arm = /obj/item/bodypart/l_arm/diona
	species_r_arm = /obj/item/bodypart/r_arm/diona
	species_l_leg = /obj/item/bodypart/l_leg/diona
	species_r_leg = /obj/item/bodypart/r_leg/diona

	var/datum/action/diona/split/SplitAbility //All dionae start with this.

/datum/species/diona/spec_life(mob/living/carbon/human/H)
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
			H.heal_overall_damage(1,1, 0, BODYTYPE_ORGANIC)
			H.adjustToxLoss(-1)
			H.adjustOxyLoss(-1)

	if(H.nutrition < NUTRITION_LEVEL_STARVING + 50)
		H.take_overall_damage(2,0)
	if(H.fire_stacks < 1)
		H.adjust_fire_stacks(1) //VERY flammable

/datum/species/diona/handle_mutations_and_radiation(mob/living/carbon/human/H)
	. = FALSE
	var/radiation = H.radiation
	//Dionae heal and eat radiation for a living.
	H.adjust_nutrition(radiation * 10)
	if(H.nutrition > NUTRITION_LEVEL_ALMOST_FULL)
		H.set_nutrition(NUTRITION_LEVEL_ALMOST_FULL)
	if(radiation > 50)
		H.heal_overall_damage(1,1, 0, BODYTYPE_ORGANIC)
		H.adjustToxLoss(-1)
		H.adjustOxyLoss(-1)

/datum/species/diona/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.type == /datum/reagent/toxin/plantbgone)
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.type, chem.metabolization_rate)
		return TRUE
	if(chem.type == /datum/reagent/toxin/mutagen)
		H.adjustToxLoss(-3)
		H.reagents.remove_reagent(chem.type, chem.metabolization_rate)
		return TRUE
	if(chem.type == /datum/reagent/plantnutriment)
		H.adjustBruteLoss(-1)
		H.adjustFireLoss(-1)
		H.reagents.remove_reagent(chem.type, chem.metabolization_rate)
		return TRUE
	return ..()

/datum/species/diona/on_hit(obj/projectile/P, mob/living/carbon/human/H)
	if(P.type == (/obj/projectile/energy/floramut || /obj/projectile/energy/florayield))
		H.set_nutrition(min(H.nutrition+30, NUTRITION_LEVEL_FULL))

/datum/species/diona/spec_death(gibbed, mob/living/carbon/human/H)
	SplitAbility.Trigger(TRUE)

/datum/species/diona/on_species_gain(mob/living/carbon/human/H)
	. = ..()
	var/obj/item/organ/appendix/appendix = H.getorganslot("appendix") //No appendixes for plant people
	if(appendix)
		appendix.Remove(H)
		QDEL_NULL(appendix)
	SplitAbility = new
	SplitAbility.Grant(H)

/datum/species/diona/on_species_loss(mob/living/carbon/human/H, datum/species/new_species, pref_load)
	. = ..()
	SplitAbility.Remove(H)

/datum/species/diona/random_name(gender, unique, lastname, attempts)
	. = "[pick(GLOB.diona_names)]"
	if(unique && attempts < 10 && findname(.))
		return .(gender, TRUE, null, ++attempts)

/datum/action/diona/split
	name = "Split"
	desc = "Split into your seperate nymphs."
	background_icon_state = "bg_default"
	icon_icon = 'icons/mob/actions/actions_genetic.dmi' // TO DO: Add icons for evolving
	button_icon_state = "default"
	var/Activated = FALSE

/datum/action/diona/split/Trigger(special)
	. = ..()
	var/mob/living/carbon/human/user = owner
	if(!ispodperson(user))
		return FALSE
	if(special)
		split(FALSE, user) //This runs when you are dead.
	if(user.incapacitated())
		return FALSE
	if(do_after(user, 5 SECONDS, user, NONE, TRUE))
		split(FALSE, user) //This runs when you manually activate the ability.

/datum/action/diona/split/proc/split(gibbed, mob/living/carbon/human/H)
	H.death() //Ha ha, we're totally dead right now
	sleep(50) //or are we?
	if(Activated)
		return
	Activated = TRUE
	var/datum/mind/M = H.mind
	for (var/amount = 0, amount < NPC_NYMPH_SPAWN_AMOUNT, amount++) //Spawn the NPC nymphs
		new /mob/living/simple_animal/nymph(H.loc)
	var/mob/living/simple_animal/nymph/nymph = new(H.loc) //Spawn the player nymph
	for(var/obj/item/I in H.contents)
		H.dropItemToGround(I, TRUE)
		I.pixel_x = rand(-10, 10)
		I.pixel_y = rand(-10, 10)
	nymph.origin = M
	nymph.oldName = H.real_name
	if(nymph.origin)
		nymph.origin.active = 1
		nymph.origin.transfer_to(nymph) //Move the player's mind to the player nymph
	H.gib(TRUE, TRUE, FALSE)  //Gib the old corpse with nothing left of use besides limbs

/datum/species/diona/get_species_description()
	return "Dionae are the equivalent to a shambling mound of bug-like sentient plants \
	wearing a trenchoat and pretending to be a human. Commonly found basking in the \
	supermatter chamber during lunch breaks."

/datum/species/diona/get_species_lore()
	return list(
		"Dionae are a space-faring species of intensely curious sapient plant-bug-creatures, formed \
			by a collective of independent Diona, named 'Nymphs', gathering together to form a collective named a 'Gestalt', commonly \
			vaugely resembling a humanoid, although older collectives may grow into structures, or even floating asteroids in space.",

		"Dionae culture, for the most part, is nomadic, with Parent Gestalts splitting off a bud \
			that then goes off into the world to explore and gain knowledge for itself. Rarely, a handful of Gestalts may link up \
			in an agreed upon location to share knowledge, or to form a larger structure.",

		"As a collective of various individual nymphs with varying experiences,  \
			names can become rather tricky, thus, Dionae Gestalts settle upon a single core memory shared between all Nymphs \
			most commonly something from their younger years and expanding over time as they relook upon their memories, though \
			it's not unheard of for a Gestalt to fully change their name if they find a fresher memory represents them more."
	)

/datum/species/diona/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "sun-plant-wilt",
			SPECIES_PERK_NAME = "Photosynthetic",
			SPECIES_PERK_DESC = "You find radiation and light pretty tasty, but you can't live long without either!",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "bugs",
			SPECIES_PERK_NAME = "Bugsplosion",
			SPECIES_PERK_DESC = "When you're about to die, you explode into a pile of bugs to escape, but you are very vulnerable in this state!",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "leaf",
			SPECIES_PERK_NAME = "Planty",
			SPECIES_PERK_DESC = "You're a plant! Bees quite like you, while you LOVE fertilizer and hate weedkiller.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "fire",
			SPECIES_PERK_NAME = "Flammable",
			SPECIES_PERK_DESC = "The smallest flame can set you on fire, be careful!",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "weight-hanging",
			SPECIES_PERK_NAME = "Bulky",
			SPECIES_PERK_DESC = "As a plant, you aren't very nimble, walking takes more time for you.",
		),
	)
	return to_add
