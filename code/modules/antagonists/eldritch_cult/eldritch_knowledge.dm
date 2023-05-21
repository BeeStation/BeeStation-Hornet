/**
 * #Eldritch Knwoledge
 *
 * Datum that makes eldritch cultist interesting.
 *
 * Eldritch knowledge aren't instantiated anywhere roundstart, and are initalized and destroyed as the round goes on.
 */
/datum/eldritch_knowledge
	///Name of the knowledge
	var/name = "Basic knowledge"
	///Description of the knowledge
	var/desc = "Basic knowledge of forbidden arts."
	///What shows up
	var/gain_text = ""
	///Cost of knowledge in souls
	var/cost = 0
	///Next knowledge in the research tree
	var/list/next_knowledge = list()
	///What knowledge is incompatible with this. This will simply make it impossible to research knowledges that are in banned_knowledge once this gets researched.
	var/list/banned_knowledge = list()
	///Used with rituals, how many items this needs
	var/list/required_atoms = list()
	///What do we get out of this
	var/list/result_atoms = list()
	///What path is this on defaults to "Side"
	var/route = PATH_SIDE

/datum/eldritch_knowledge/New()
	. = ..()
	var/list/temp_list
	for(var/X in required_atoms)
		var/atom/A = X
		temp_list += list(typesof(A))
	required_atoms = temp_list

/**
 * What happens when this is assigned to an antag datum
 *
 * This proc is called whenever a new eldritch knowledge is added to an antag datum
 */
/datum/eldritch_knowledge/proc/on_gain(mob/user)
	to_chat(user, "<span class='warning'>[gain_text]</span>")
	return
/**
 * What happens when you loose this
 *
 * This proc is called whenever antagonist looses his antag datum, put cleanup code in here
 */
/datum/eldritch_knowledge/proc/on_lose(mob/user)
	return
/**
 * What happens every tick
 *
 * This proc is called on SSprocess in eldritch cultist antag datum. SSprocess happens roughly every second
 */
/datum/eldritch_knowledge/proc/on_life(mob/user)
	return

/**
 * Special check for recipes
 *
 * If you are adding a more complex summoning or something that requires a special check that parses through all the atoms in an area override this.
 */
/datum/eldritch_knowledge/proc/recipe_snowflake_check(list/atoms,loc)
	return TRUE

/**
 * What happens once the recipe is successfully finished
 *
 * By default this proc creates atoms from result_atoms list. Override this is you want something else to happen.
 */
/datum/eldritch_knowledge/proc/on_finished_recipe(mob/living/user,list/atoms,loc)
	if(result_atoms.len == 0)
		return FALSE

	for(var/A in result_atoms)
		new A(loc)

	return TRUE

/**
 * Used atom cleanup
 *
 * Overide this proc if you dont want ALL ATOMS to be destroyed. useful in many situations.
 */
/datum/eldritch_knowledge/proc/cleanup_atoms(list/atoms)	//BUG: crafting something will add to this list and delete ALL of the required components, IE if you have 2 bibles on a rune, and craft a codex, it will make 1 codex and qdel BOTH bibles
	for(var/X in atoms)
		var/atom/A = X
		if(!isliving(A))
			atoms -= A
			qdel(A)
	return

/**
 * Mansus grasp act
 *
 * Gives addtional effects to mansus grasp spell
 * Gives addtional effects to mansus touch spell of your followers
 */
/datum/eldritch_knowledge/proc/on_mansus_grasp(atom/target, mob/user, proximity_flag, click_parameters)
	return FALSE


/datum/eldritch_knowledge/proc/on_mansus_touch(atom/target, mob/user, proximity_flag, click_parameters)
	return FALSE


/**
 * Sickly blade act
 *
 * Gives addtional effects to sickly blade weapon
 */
/datum/eldritch_knowledge/proc/on_eldritch_blade(target,user,proximity_flag,click_parameters)
	return

/**
 * Sickly blade distant act
 *
 * Same as [/datum/eldritch_knowledge/proc/on_eldritch_blade] but works on targets that are not in proximity to you.
 */
/datum/eldritch_knowledge/proc/on_ranged_attack_eldritch_blade(atom/target,mob/user,click_parameters)
	return

//////////////
///Subtypes///
//////////////

/datum/eldritch_knowledge/spell
	var/obj/effect/proc_holder/spell/spell_to_add

/datum/eldritch_knowledge/spell/on_gain(mob/user)
	var/obj/effect/proc_holder/S = new spell_to_add
	user.mind.AddSpell(S)
	return ..()

/datum/eldritch_knowledge/spell/on_lose(mob/user)
	user.mind.RemoveSpell(spell_to_add)
	return ..()

/datum/eldritch_knowledge/curse
	var/timer = 5 MINUTES
	var/list/fingerprints = list()

/datum/eldritch_knowledge/curse/recipe_snowflake_check(list/atoms, loc)
	fingerprints = list()
	for(var/X in atoms)
		var/atom/A = X
		fingerprints |= A.return_fingerprints()
	list_clear_nulls(fingerprints)
	if(fingerprints.len == 0)
		return FALSE
	return TRUE

/datum/eldritch_knowledge/curse/on_finished_recipe(mob/living/user,list/atoms,loc)

	var/list/compiled_list = list()

	for(var/H in GLOB.carbon_list)
		var/mob/living/carbon/human/human_to_check = H
		if(istype(human_to_check) && fingerprints[md5(human_to_check.dna.uni_identity)])
			compiled_list |= human_to_check.real_name
			compiled_list[human_to_check.real_name] = human_to_check

	if(compiled_list.len == 0)
		to_chat(user, "<span class='warning'>These items don't possess the required fingerprints or DNA.</span>")
		return FALSE

	var/chosen_mob = input("Select the person you wish to curse","Your target") as null|anything in sort_list(compiled_list, GLOBAL_PROC_REF(cmp_mob_realname_dsc))
	if(!chosen_mob)
		return FALSE
	var/mob/living/living_mob = chosen_mob
	if (istype(living_mob) && HAS_TRAIT(living_mob, TRAIT_WARDED))
		to_chat(user, "<span class='warning'>The curse failed! The target is warded against curses.</span>")
		return FALSE
	curse(compiled_list[chosen_mob])
	addtimer(CALLBACK(src, PROC_REF(uncurse), compiled_list[chosen_mob]),timer)
	return TRUE

/datum/eldritch_knowledge/curse/proc/curse(mob/living/chosen_mob)
	return

/datum/eldritch_knowledge/curse/proc/uncurse(mob/living/chosen_mob)
	return

/datum/eldritch_knowledge/summon
	//Mob to summon
	var/mob/living/mob_to_summon


/datum/eldritch_knowledge/summon/on_finished_recipe(mob/living/user,list/atoms,loc)
	//we need to spawn the mob first so that we can use it in pollCandidatesForMob, we will move it from nullspace down the code
	var/mob/living/summoned = new mob_to_summon(loc)
	message_admins("[summoned.name] is being summoned by [user.real_name] in [loc]")
	var/list/mob/dead/observer/candidates = pollCandidatesForMob("Do you want to play as [summoned.real_name]", ROLE_HERETIC, null, FALSE, 100, summoned)
	if(!LAZYLEN(candidates))
		to_chat(user,"<span class='warning'>No ghost could be found...</span>")
		qdel(summoned)
		return FALSE
	var/mob/dead/observer/C = pick(candidates)
	log_game("[key_name_admin(C)] has taken control of ([key_name_admin(summoned)]), their master is [user.real_name]")
	summoned.ghostize(FALSE,SENTIENCE_ERASE)
	summoned.key = C.key
	summoned.mind.add_antag_datum(/datum/antagonist/heretic_monster)
	var/datum/antagonist/heretic_monster/heretic_monster = summoned.mind.has_antag_datum(/datum/antagonist/heretic_monster)
	var/datum/antagonist/heretic/master = user.mind.has_antag_datum(/datum/antagonist/heretic)
	heretic_monster.set_owner(master)
	return TRUE

//Ascension knowledge
/datum/eldritch_knowledge/last
	var/finished = FALSE

/datum/eldritch_knowledge/last/recipe_snowflake_check(list/atoms, loc,selected_atoms)
	if(finished)
		return FALSE
	var/counter = 0
	for(var/mob/living/carbon/human/H in atoms)
		selected_atoms |= H
		counter++
		if(counter == 3)
			return TRUE
	return FALSE

/datum/eldritch_knowledge/last/on_finished_recipe(mob/living/user, list/atoms, loc)
	finished = TRUE
	var/datum/antagonist/heretic/ascension = user.mind.has_antag_datum(/datum/antagonist/heretic)
	ascension.ascended = TRUE
	return TRUE

/datum/eldritch_knowledge/last/cleanup_atoms(list/atoms)
	. = ..()
	for(var/mob/living/carbon/human/H in atoms)
		atoms -= H
		H.gib()


///////////////
///Base lore///
///////////////

/datum/eldritch_knowledge/spell/basic
	name = "Break of dawn"
	desc = "You can sacrifice specific targets by placing their dead bodies and the living heart on a transmutation rune, and performing a transmutation ritual."
	gain_text = "Gates of mansus open up to your mind."
	next_knowledge = list(/datum/eldritch_knowledge/base_rust,/datum/eldritch_knowledge/base_ash,/datum/eldritch_knowledge/base_flesh)
	cost = 0
	spell_to_add = /obj/effect/proc_holder/spell/targeted/touch/mansus_grasp
	required_atoms = list(/obj/item/living_heart)
	route = "Start"

/datum/eldritch_knowledge/spell/basic/recipe_snowflake_check(list/atoms, loc)
	. = ..()
	for(var/obj/item/living_heart/LH in atoms)
		if(!LH.target)
			return TRUE
		if(LH.target in atoms)
			return TRUE
	return FALSE

/datum/eldritch_knowledge/spell/basic/on_finished_recipe(mob/living/user, list/atoms, loc)
	. = TRUE
	var/mob/living/carbon/carbon_user = user
	for(var/obj/item/living_heart/LH in atoms)

		if(LH.target && LH.target.stat == DEAD)
			to_chat(carbon_user,"<span class='danger'>Your patrons accepts your offer..</span>")
			var/mob/living/carbon/human/H = LH.target
			var/obj/item/bodypart/chest/chest = H.get_bodypart(BODY_ZONE_CHEST)
			chest.dismember()
			H.visible_message("<span class='danger'>[H.name] Is quickly surrounded by invisible claws; lacerating their chest open, spilling their organs out!</span>", \
								"<span class='danger'>You feel claws tear your chest open; spilling your organs out onto the floor!</span>", ignored_mobs=H)
			LH.set_target(null)
			var/datum/antagonist/heretic/EC = carbon_user.mind.has_antag_datum(/datum/antagonist/heretic)

			EC.total_sacrifices++
			for(var/X in carbon_user.get_all_gear())
				if(!istype(X,/obj/item/forbidden_book))
					continue
				var/obj/item/forbidden_book/FB = X
				FB.charge += 2
				break

		if(!LH.target)
			var/datum/objective/A = new
			A.owner = user.mind
			var/list/targets = list()
			for(var/i in 1 to 3)
				var/datum/mind/targeted = A.find_target(dupe_search_range=list(),blacklist=targets)//easy way, i dont feel like copy pasting that entire block of code, empty dupe search range so assassinate targets can be sacrificed
				if(!targeted)
					break
				targets[targeted.current.real_name] = targeted
			LH.set_target(targets[input(user,"Choose your next target","Target") in targets])
			qdel(A)
			if(LH.target)
				to_chat(user,"<span class='warning'>Your new target has been selected, go and sacrifice [LH.target.real_name]!</span>")
			else
				to_chat(user,"<span class='warning'>No target could be found for living heart.</span>")

/datum/eldritch_knowledge/spell/basic/cleanup_atoms(list/atoms)
	return


//	---	GENERAL	---

/datum/eldritch_knowledge/living_heart
	name = "Living Heart"
	desc = "Allows you to create additional living hearts, using a heart, a pool of blood and a flower. Living hearts when used on a transmutation rune will grant you a person to hunt and sacrifice on the rune. Every sacrifice gives you an additional charge in the book."
	gain_text = "The Gates of Mansus open up to your mind."
	cost = 0
	required_atoms = list(/obj/item/organ/heart,/obj/effect/decal/cleanable/blood,/obj/item/reagent_containers/food/snacks/grown/flower)
	result_atoms = list(/obj/item/living_heart)
	route = "Start"

/datum/eldritch_knowledge/codex_cicatrix
	name = "Codex Cicatrix"
	desc = "Allows you to create a spare Codex Cicatrix if you have lost one, using a bible, human skin, a pen and a pair of eyes."
	gain_text = "Their hand is at your throats, yet you see Them not."
	cost = 0
	required_atoms = list(/obj/item/organ/eyes,/obj/item/stack/sheet/animalhide/human,/obj/item/storage/book/bible,/obj/item/pen)
	result_atoms = list(/obj/item/forbidden_book/empty)
	route = "Start"

//	---	CRAFTING ---

/datum/eldritch_knowledge/ashen_eyes
	name = "Ashen Eyes"
	gain_text = "Piercing eyes, guide me through the mundane."
	desc = "Allows you to craft a thermal vision amulet by transmutating eyes with a glass shard."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/spell/ashen_shift,/datum/eldritch_knowledge/flesh_ghoul)
	required_atoms = list(/obj/item/organ/eyes,/obj/item/shard)
	result_atoms = list(/obj/item/clothing/neck/eldritch_amulet)

/datum/eldritch_knowledge/guise
	name = "Guise of Istasha"
	gain_text = "Hide your form from the ones without a soul."
	desc = "Allows you to craft a digital camoflage amulet by transmutating a circuit board with a glass shard."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/spell/ashen_shift,/datum/eldritch_knowledge/flesh_ghoul)
	required_atoms = list(/obj/item/circuitboard,/obj/item/shard)
	result_atoms = list(/obj/item/clothing/neck/eldritch_amulet/guise)

/datum/eldritch_knowledge/armor
	name = "Armorer's ritual"
	desc = "You can now create eldritch armor using a table and a gas mask."
	gain_text = "For I am the heir to the throne of doom."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/rust_regen,/datum/eldritch_knowledge/flesh_ghoul)
	required_atoms = list(/obj/structure/table,/obj/item/clothing/mask/gas)
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch)

/datum/eldritch_knowledge/essence
	name = "Priest's Ritual"
	desc = "You can now transmute a tank of water and a glass shard into a bottle of eldritch water."
	gain_text = "This is an old recipe. The Owl whispered it to me."
	cost = 1
	required_atoms = list(/obj/structure/reagent_dispensers/watertank)
	result_atoms = list(/obj/item/reagent_containers/glass/beaker/eldritch)

//	---	CURSES ---

/datum/eldritch_knowledge/curse/alteration
	name = "Curse Of Alteration"
	gain_text = "Mortal bodies, prisons of flesh. Death, a release..."
	desc = "Start an alteration ritual by transmuting a wire cutter, a hatchet and an item that the victim touched with their bare hands. Inflict a debilitating curse that will cripple your target's body for 2 minutes. Add eyes, ears, limbs or tongues to the mix to disable those organs while the curse is in effect."
	cost = 1
	required_atoms = list(/obj/item/wirecutters,/obj/item/hatchet)
	timer = 2 MINUTES
	var/list/debuffs = list()

/datum/eldritch_knowledge/curse/alteration/on_finished_recipe(mob/living/user, list/atoms, loc)	//the ritual completed, take the payment and apply the curse
	//declare
	debuffs = list()
	var/list/extra_atoms = list()

	//check variables
	for(var/A in range(1, loc))	//this
		var/obj/item/bodypart/selected_part = A
		if (istype(selected_part) && (IS_ORGANIC_LIMB(selected_part)))
			switch(selected_part.body_zone)
				if(BODY_ZONE_R_LEG)
					extra_atoms |= A
					debuffs |= "r_leg"
				if(BODY_ZONE_L_LEG)
					extra_atoms |= A
					debuffs |= "l_leg"
				if(BODY_ZONE_R_ARM)
					extra_atoms |= A
					debuffs |= "r_arm"
				if(BODY_ZONE_L_ARM)
					extra_atoms |= A
					debuffs |= "l_arm"

		var/obj/item/organ/selected_organ = A
		if (istype(selected_organ) && selected_organ.status == ORGAN_ORGANIC)
			switch(selected_organ.slot)
				if(ORGAN_SLOT_TONGUE)
					extra_atoms |= A
					debuffs |= "tongue"
				if(ORGAN_SLOT_EYES)
					extra_atoms |= A
					debuffs |= "eyes"
				if(ORGAN_SLOT_EARS)
					extra_atoms |= A
					debuffs |= "ears"

	cleanup_atoms(extra_atoms)
	. = ..()
	return .

/datum/eldritch_knowledge/curse/alteration/curse(mob/living/chosen_mob)
	. = ..()
	if (chosen_mob.has_status_effect(/datum/status_effect/corrosion_curse))
		return FALSE

	var/mob/living/carbon/human/chosen_mortal = chosen_mob
	if (!istype(chosen_mob))
		return

	chosen_mortal.apply_status_effect(/datum/status_effect/corrosion_curse)	//the purpose of this debuff is to alert the victim they've been cursed
	for(var/X in debuffs)
		switch (X)
			if ("r_leg")
				ADD_TRAIT(chosen_mortal,TRAIT_PARALYSIS_R_LEG,CURSE_TRAIT)
			if ("l_leg")
				ADD_TRAIT(chosen_mortal,TRAIT_PARALYSIS_L_LEG,CURSE_TRAIT)
			if ("r_arm")
				ADD_TRAIT(chosen_mortal,TRAIT_PARALYSIS_R_ARM,CURSE_TRAIT)
			if ("l_arm")
				ADD_TRAIT(chosen_mortal,TRAIT_PARALYSIS_L_ARM,CURSE_TRAIT)
			if ("tongue")
				ADD_TRAIT(chosen_mortal, TRAIT_MUTE, CURSE_TRAIT)
			if ("eyes")
				chosen_mortal.become_blind(CURSE_TRAIT)
			if ("ears")
				ADD_TRAIT(chosen_mortal, TRAIT_DEAF, CURSE_TRAIT)
	return .

/datum/eldritch_knowledge/curse/alteration/uncurse(mob/living/chosen_mob)
	. = ..()
	var/mob/living/carbon/human/chosen_mortal = chosen_mob
	//organ fuckup
	chosen_mortal.remove_status_effect(/datum/status_effect/corrosion_curse)

	//CC
	chosen_mortal.cure_blind(CURSE_TRAIT)
	REMOVE_TRAIT(chosen_mortal, TRAIT_MUTE, CURSE_TRAIT)
	REMOVE_TRAIT(chosen_mortal, TRAIT_DEAF, CURSE_TRAIT)

	//paralysis
	REMOVE_TRAIT(chosen_mortal,TRAIT_PARALYSIS_R_ARM,CURSE_TRAIT)
	REMOVE_TRAIT(chosen_mortal,TRAIT_PARALYSIS_L_ARM,CURSE_TRAIT)
	REMOVE_TRAIT(chosen_mortal,TRAIT_PARALYSIS_L_LEG,CURSE_TRAIT)
	REMOVE_TRAIT(chosen_mortal,TRAIT_PARALYSIS_R_LEG,CURSE_TRAIT)
	chosen_mortal.update_mobility()

	return .

//	--- SPELLS ---

/datum/eldritch_knowledge/spell/cleave
	name = "Blood Cleave"
	gain_text = "At first I didn't understand these instruments of war, but the priest told me to use them regardless. Soon, he said, I would know them well."
	desc = "Gives AOE spell that causes heavy bleeding and blood loss."
	cost = 1
	spell_to_add = /obj/effect/proc_holder/spell/pointed/cleave
	next_knowledge = list(/datum/eldritch_knowledge/spell/entropic_plume,/datum/eldritch_knowledge/spell/flame_birth)

/datum/eldritch_knowledge/spell/blood_siphon
	name = "Blood Siphon"
	gain_text = "No matter the man, we bleed all the same. That's what the Marshal told me."
	desc = "You gain a spell that drains health from your enemies to restores your own."
	cost = 1
	spell_to_add = /obj/effect/proc_holder/spell/targeted/touch/blood_siphon
	next_knowledge = list(/datum/eldritch_knowledge/summon/raw_prophet,/datum/eldritch_knowledge/spell/area_conversion)

//	--- SUMMONS ---

/datum/eldritch_knowledge/summon/ashy
	name = "Ashen Ritual"
	gain_text = "I combined my principle of hunger with my desire for destruction. And the Nightwatcher knew my name."
	desc = "You can now summon an Ash Man by transmutating a pile of ash, a head and a book."
	cost = 1
	required_atoms = list(/obj/effect/decal/cleanable/ash,/obj/item/bodypart/head,/obj/item/book)
	mob_to_summon = /mob/living/simple_animal/hostile/eldritch/ash_spirit
	next_knowledge = list(/datum/eldritch_knowledge/summon/stalker,/datum/eldritch_knowledge/spell/flame_birth)

/datum/eldritch_knowledge/summon/rusty
	name = "Rusted Ritual"
	gain_text = "I combined my principle of hunger with my desire for corruption. And the Rusted Hills called my name."
	desc = "You can now summon a Rust Walker by transmutating a vomit pool, a severed head and a book."
	cost = 1
	required_atoms = list(/obj/effect/decal/cleanable/vomit,/obj/item/bodypart/head,/obj/item/book)
	mob_to_summon = /mob/living/simple_animal/hostile/eldritch/rust_spirit
	next_knowledge = list(/datum/eldritch_knowledge/summon/stalker,/datum/eldritch_knowledge/spell/entropic_plume)
