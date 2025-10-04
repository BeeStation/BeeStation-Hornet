/datum/species/diona
	name = "\improper Diona"
	plural_form = "Dionae"
	id = SPECIES_DIONA
	sexes = 0 //no sex for bug/plant people!
	bodyflag = FLAG_DIONA
	species_traits = list(
		MUTCOLORS,
		EYECOLOR,
		AGENDER,
		NOHUSK,
		NO_UNDERWEAR,
		NOSOCKS,
		NOEYESPRITES,
	)
	inherent_traits = list(
		TRAIT_BEEFRIEND,
		TRAIT_NONECRODISEASE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_RESISTCOLD,
		TRAIT_NORADDAMAGE,
		TRAIT_NOBREATH,
		TRAIT_NO_DNA_COPY,
		TRAIT_NO_TRANSFORMATION_STING,
	)
	inherent_biotypes = list(MOB_HUMANOID, MOB_ORGANIC, MOB_BUG)
	mutant_bodyparts = list("diona_leaves", "diona_thorns", "diona_flowers", "diona_moss", "diona_mushroom", "diona_antennae", "diona_eyes", "diona_pbody")
	mutant_organs = list(/obj/item/organ/nymph_organ/r_arm, /obj/item/organ/nymph_organ/l_arm, /obj/item/organ/nymph_organ/l_leg, /obj/item/organ/nymph_organ/r_leg, /obj/item/organ/nymph_organ/chest)
	inherent_factions = list(FACTION_PLANTS, FACTION_VINES, FACTION_DIONA)
	attack_verb = "slash"
	attack_sound = 'sound/emotes/diona/hit.ogg'
	burnmod = 1.25
	heatmod = 1.5
	brutemod = 0.8
	staminamod = 0.7
	meat = /obj/item/food/meat/slab/human/mutant/diona
	exotic_blood = /datum/reagent/consumable/chlorophyll
	species_gibs = null //Someone please make this like, xeno gibs or something in the future. I cant be bothered to fuck around with gib code right now.
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP
	species_language_holder = /datum/language_holder/diona
	bodytemp_normal = (BODYTEMP_NORMAL - 22) // Body temperature for dionae is much lower then humans as they are plants, supposed to be 15 celsius
	speedmod = 1.2 // Dionae are slow.
	species_height = SPECIES_HEIGHTS(0, -1, -2) //Naturally tall.
	swimming_component = /datum/component/swimming/diona
	inert_mutation = /datum/mutation/drone
	deathsound = "sound/emotes/diona/death.ogg"
	species_bitflags = NOT_TRANSMORPHIC

	mutanteyes = /obj/item/organ/eyes/diona //SS14 sprite
	mutanttongue = /obj/item/organ/tongue/diona //Dungeon's sprite
	mutantbrain = /obj/item/organ/brain/diona //SS14 sprite
	mutantliver = /obj/item/organ/liver/diona //Dungeon's sprite
	mutantlungs = /obj/item/organ/lungs/diona //Dungeon's sprite
	mutantstomach = /obj/item/organ/stomach/diona //SS14 sprite
	mutantears = /obj/item/organ/ears/diona //SS14 sprite
	mutantheart = /obj/item/organ/heart/diona //Dungeon's sprite
	mutantappendix = null

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/diona,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/diona,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/diona,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/diona,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/diona,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/diona,
	)

	var/datum/action/diona/split/split_ability //All dionae start with this, this is for splitting apart completely.
	var/datum/action/diona/partition/partition_ability //All dionae start with this as well, this is for splitting off a nymph from food.
	var/datum/weakref/drone_ref

	var/time_spent_in_light
	var/informed_nymph = FALSE //If the user was informed that they can release a nymph via food.

/datum/species/diona/spec_life(mob/living/carbon/human/H)
	if(H.fire_stacks < 1)
		H.adjust_fire_stacks(1) //VERY flammable
	if(H.nutrition < NUTRITION_LEVEL_STARVING)
		H.take_overall_damage(1,0)
	if(H.stat != CONSCIOUS)
		H.remove_status_effect(/datum/status_effect/planthealing)
	if((H.health <= H.crit_threshold)) //Shit, we're dying! Scatter!
		split_ability.split(FALSE, H)
	if(H.nutrition > NUTRITION_LEVEL_WELL_FED && !informed_nymph)
		informed_nymph = TRUE
		to_chat(H, span_warning("You feel sufficiently satiated to allow a nymph to split off from your gestalt!"))
	if(partition_ability)
		partition_ability.update_buttons()
	if(H.nutrition > NUTRITION_LEVEL_ALMOST_FULL)
		H.set_nutrition(NUTRITION_LEVEL_ALMOST_FULL)
	var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
	if(!isturf(H.loc)) //else, there's considered to be no light
		H.remove_status_effect(/datum/status_effect/planthealing)
		time_spent_in_light = 0  //No light? Reset the timer.
		return
	var/turf/T = H.loc
	light_amount = min(1,T.get_lumcount()) - 0.5
	H.adjust_nutrition(light_amount * 7)
	if(light_amount > 0.2) //Is there light here?
		time_spent_in_light++  //If so, how long have we been somewhere with light?
		if(time_spent_in_light > 5) //More than 5 seconds spent in the light
			if(H.stat != CONSCIOUS)
				H.remove_status_effect(/datum/status_effect/planthealing)
				return
			H.apply_status_effect(/datum/status_effect/planthealing)

/datum/species/diona/spec_updatehealth(mob/living/carbon/human/H)
	var/mob/living/simple_animal/hostile/retaliate/nymph/drone = drone_ref?.resolve()
	if(H.stat != CONSCIOUS && !H.mind && drone) //If the home body is not fully conscious, they dont have a mind and have a drone
		drone.switch_ability.trigger() //Bring them home.

/datum/species/diona/handle_mutations_and_radiation(mob/living/carbon/human/H)
	. = FALSE
	var/radiation = H.radiation
	//Dionae heal and eat radiation for a living.
	H.adjust_nutrition(clamp(radiation, 0, 7))
	if(radiation > 50)
		H.heal_overall_damage(1,1, 0, BODYTYPE_ORGANIC)
		H.adjustToxLoss(-2)
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
	drone_ref = null
	if(gibbed)
		QDEL_NULL(H)
		return
	split_ability.split(gibbed, H)

/datum/species/diona/spec_gib(no_brain, no_organs, no_bodyparts, mob/living/carbon/human/H)
	H.unequip_everything()
	H.gib_animation()
	H.spawn_gibs()
	QDEL_NULL(H)
	return

/datum/species/diona/on_species_gain(mob/living/carbon/human/H)
	. = ..()
	split_ability = new
	split_ability.Grant(H)
	partition_ability = new
	partition_ability.Grant(H)
	ADD_TRAIT(H, TRAIT_MOBILE, "diona")

/datum/species/diona/on_species_loss(mob/living/carbon/human/H, datum/species/new_species, pref_load)
	. = ..()
	split_ability.Remove(H)
	QDEL_NULL(split_ability)
	partition_ability.Remove(H)
	QDEL_NULL(partition_ability)
	REMOVE_TRAIT(H, TRAIT_MOBILE, "diona")
	qdel(drone_ref)
	for(var/status_effect as anything in H.status_effects)
		if(status_effect == /datum/status_effect/planthealing)
			H.remove_status_effect(/datum/status_effect/planthealing)

/datum/species/diona/random_name(gender, unique, lastname, attempts)
	. = "[pick(GLOB.diona_names)]"
	if(unique && attempts < 10 && findname(.))
		return ..(gender, TRUE, null, ++attempts)

/datum/species/diona/help(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	. = ..()
	if(. && target != user && target.on_fire)
		user.balloon_alert(user, "[user] you hug [target]")
		target.visible_message(span_warning("[user] catches fire from hugging [target]!"), span_boldnotice("[user] catches fire hugging you!"), span_italics("You hear a fire crackling."))
		user.fire_stacks = target.fire_stacks
		if(user.fire_stacks > 0)
			user.IgniteMob()

//////////////////////////////////////// Action abilities ///////////////////////////////////////////////

/datum/action/diona/split
	name = "Split"
	desc = "Split into our seperate nymphs."
	background_icon_state = "bg_default"
	icon_icon = 'icons/hud/actions/actions_spells.dmi'
	button_icon_state = "split"
	check_flags = AB_CHECK_DEAD
	var/Activated = FALSE

/datum/action/diona/split/is_available()
	return ..() && isdiona(owner)

/datum/action/diona/split/on_activate(mob/user, atom/target)
	if(tgui_alert(usr, "Are we sure we wish to devolve ourselves and split into separated nymphs?",,list("Yes", "No")) != "Yes")
		return FALSE
	if(do_after(user, 8 SECONDS, user, hidden = TRUE))
		if(user.incapacitated(IGNORE_RESTRAINTS)) //Second check incase the ability was activated RIGHT as we were being cuffed, and thus now in cuffs when this triggers
			return FALSE
		startSplitting(FALSE, user) //This runs when you manually activate the ability.
		return TRUE

/datum/action/diona/split/proc/startSplitting(gibbed, mob/living/carbon/H)
	if(Activated || gibbed)
		return
	Activated = TRUE
	H.Stun(6 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(split), gibbed, H), 5 SECONDS, TIMER_DELETE_ME)

/datum/action/diona/split/proc/split(gibbed, mob/living/carbon/human/H)
	if(gibbed)
		H.gib(TRUE, TRUE, TRUE)  //Gib the corpse with nothing left of use. After all the nymphs are ALL dead.
		return
	var/list/alive_nymphs = list()
	var/mob/living/simple_animal/hostile/retaliate/nymph/nymph = new(H.loc) //Spawn the player nymph, including this one, should be six total nymphs
	for(var/obj/item/bodypart/BP as anything in H.bodyparts)
		if(BP.limb_id != SPECIES_DIONA) //Robot limb? Ignore it.
			BP.drop_limb()
			continue
		if(istype(BP, /obj/item/bodypart/head))
			nymph.adjustBruteLoss(BP.brute_dam)
			nymph.adjustFireLoss(BP.burn_dam)
			nymph.updatehealth()
			continue //Exclude the head nymph from the alive_nymphs list, since that list is used for secondary consciousness transfer.
		var/mob/living/simple_animal/hostile/retaliate/nymph/limb_nymph = new /mob/living/simple_animal/hostile/retaliate/nymph(H.loc)
		limb_nymph.adjustBruteLoss(BP.brute_dam)
		limb_nymph.adjustFireLoss(BP.burn_dam)
		limb_nymph.updatehealth()
		if(limb_nymph.stat != DEAD)
			alive_nymphs += limb_nymph

	var/mob/living/simple_animal/hostile/retaliate/nymph/gambling_nymph = alive_nymphs[rand(1, alive_nymphs)] // Let's go gambling!
	gambling_nymph.adjustBruteLoss(50) // Aw dangit.
	alive_nymphs -= gambling_nymph //Remove it from the alive_nymphs list.

	if(nymph.stat == DEAD) //If the head nymph is dead, transfer all consciousness to the next best thing - an alive limb nymph!
		nymph = pick(alive_nymphs)
	for(var/obj/item/I in H.contents) //Drop the player's items on the ground
		H.dropItemToGround(I, TRUE)
		I.pixel_x = rand(-10, 10)
		I.pixel_y = rand(-10, 10)
	nymph.old_name = H.real_name
	nymph.features = H.dna.features
	H.mind?.transfer_to(nymph) //Move the player's mind datum to the player nymph
	H.mind?.grab_ghost() // Throw the fucking ghost back into the nymph.
	H.gib(TRUE, TRUE, TRUE)  //Gib the old corpse with nothing left of use

/datum/action/diona/partition
	name = "Partition"
	desc = "Allow a nymph to partition from our gestalt self."
	background_icon_state = "bg_default"
	icon_icon = 'icons/hud/actions/actions_spells.dmi'
	button_icon_state = "grow"
	cooldown_time = 5 MINUTES
	var/ability_partition_cooldow

/datum/action/diona/partition/on_activate(mob/user, atom/target)
	var/mob/living/carbon/human/H = owner
	start_cooldown()
	H.nutrition = NUTRITION_LEVEL_STARVING
	playsound(H, 'sound/creatures/venus_trap_death.ogg', 25, 1)
	new /mob/living/simple_animal/hostile/retaliate/nymph(H.loc)

/datum/action/diona/partition/is_available()
	if(..())
		var/mob/living/carbon/human/H = owner
		if(H.nutrition >= NUTRITION_LEVEL_WELL_FED)
			return TRUE
		return FALSE

/////////////////////////////////// Dionae organs down here, special behavior stuffs ///////////////////////////////////////
/obj/item/organ/nymph_organ
	name = "diona nymph"
	desc = "You should not be seeing this, if you are, please contact a coder."
	icon = 'icons/mob/animal.dmi'
	icon_state = "nymph"

/obj/item/organ/nymph_organ/Remove(mob/living/carbon/organ_owner, special, pref_load)
	. = ..()
	if(istype(organ_owner, /mob/living/carbon/human/dummy) || special)
		return
	var/obj/item/bodypart/body_part = organ_owner.get_bodypart(zone)
	for(var/datum/surgery/organ_manipulation/surgery in organ_owner.surgeries)
		surgery.Destroy()
	if(istype(body_part, /obj/item/bodypart/chest)) //Does the same things as removing the brain would, since the torso is what keeps the diona together.
		organ_owner.dna.species.spec_death(FALSE, src)
		QDEL_NULL(src)
		return
	new /mob/living/simple_animal/hostile/retaliate/nymph(organ_owner.loc)
	QDEL_NULL(body_part)
	QDEL_NULL(src)
	organ_owner.update_body()

/obj/item/organ/nymph_organ/transfer_to_limb(obj/item/bodypart/LB, mob/living/carbon/C)
	Remove(C, FALSE)
	forceMove(LB)

/obj/item/organ/nymph_organ/r_arm
	zone = BODY_ZONE_R_ARM
	slot = ORGAN_SLOT_R_ARM_NYMPH

/obj/item/organ/nymph_organ/l_arm
	zone = BODY_ZONE_L_ARM
	slot = ORGAN_SLOT_L_ARM_NYMPH

/obj/item/organ/nymph_organ/r_leg
	zone = BODY_ZONE_R_LEG
	slot = ORGAN_SLOT_R_LEG_NYMPH

/obj/item/organ/nymph_organ/l_leg
	zone = BODY_ZONE_L_LEG
	slot = ORGAN_SLOT_L_LEG_NYMPH

/obj/item/organ/nymph_organ/chest
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_CHEST_NYMPH


////////////////////////////////////// Preferences menu stuffs ////////////////////////////////////////////////////////////
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

/datum/species/diona/get_laugh_sound(mob/living/carbon/user)
	return 'sound/emotes/diona/laugh.ogg'

/datum/species/diona/get_scream_sound(mob/living/carbon/user)
	return 'sound/emotes/diona/scream.ogg'

/datum/species/diona/get_sneeze_sound(mob/living/carbon/user)
	return 'sound/emotes/diona/sneeze.ogg'
