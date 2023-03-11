#define GHOUL_MAX_HEALTH 25
#define MUTE_MAX_HEALTH 50
#define ORIGINAL_MAX_HEALTH 100

/datum/eldritch_knowledge/base_flesh
	name = "Principle of Hunger"
	desc = "Opens up the Path of Flesh to you. Allows you to transmute a pool of blood with a kitchen knife, or its derivatives, into a Flesh Blade."
	gain_text = "Hundreds of us starved, but not me... I found strength in my greed."
	banned_knowledge = list(/datum/eldritch_knowledge/base_ash,/datum/eldritch_knowledge/base_rust,/datum/eldritch_knowledge/last/ash_final,/datum/eldritch_knowledge/last/rust_final)
	next_knowledge = list(/datum/eldritch_knowledge/flesh_grasp)
	required_atoms = list(/obj/item/kitchen/knife,/obj/effect/decal/cleanable/blood)
	result_atoms = list(/obj/item/melee/sickly_blade/flesh)
	cost = 1
	route = PATH_FLESH

/datum/eldritch_knowledge/flesh_ghoul
	name = "Imperfect Ritual"
	desc = "Allows you to resurrect the dead as voiceless dead by sacrificing them on the transmutation rune with a poppy. Voiceless dead are mute and have 50 HP. You can only have 2 at a time."
	gain_text = "I found notes of a dark ritual, unfinished... yet still, I pushed forward."
	cost = 1
	required_atoms = list(/mob/living/carbon/human,/obj/item/reagent_containers/food/snacks/grown/poppy)
	next_knowledge = list(/datum/eldritch_knowledge/flesh_mark,/datum/eldritch_knowledge/armor,/datum/eldritch_knowledge/ashen_eyes)
	route = PATH_FLESH
	var/max_amt = 2
	var/current_amt = 0
	var/list/ghouls = list()

/datum/eldritch_knowledge/flesh_ghoul/on_finished_recipe(mob/living/user,list/atoms,loc)
	var/mob/living/carbon/human/humie = locate() in atoms
	if(QDELETED(humie) || humie.stat != DEAD)
		return

	if(length(ghouls) >= max_amt)
		return

	if(HAS_TRAIT(humie,TRAIT_HUSK))
		return

	humie.grab_ghost()

	if(!humie.mind || !humie.client)
		var/list/mob/dead/observer/candidates = pollCandidatesForMob("Do you want to play as a [humie.real_name], a voiceless dead", ROLE_HERETIC, null, ROLE_HERETIC, 50,humie)
		if(!LAZYLEN(candidates))
			to_chat(user,"<span class='warning'>No ghost could be found...</span>")
			return
		var/mob/dead/observer/C = pick(candidates)
		message_admins("[key_name_admin(C)] has taken control of ([key_name_admin(humie)]) to replace an AFK player.")
		humie.ghostize(FALSE,SENTIENCE_ERASE)
		humie.key = C.key

	log_game("[key_name_admin(humie)] has become a voiceless dead, their master is [user.real_name]")
	humie.revive(full_heal = TRUE, admin_revive = TRUE)
	ADD_TRAIT(humie,TRAIT_MUTE,MAGIC_TRAIT)
	ADD_TRAIT(humie, TRAIT_STUNIMMUNE, MAGIC_TRAIT)
	ADD_TRAIT(humie, TRAIT_CONFUSEIMMUNE, MAGIC_TRAIT)
	ADD_TRAIT(humie, TRAIT_IGNOREDAMAGESLOWDOWN, MAGIC_TRAIT)
	ADD_TRAIT(humie, TRAIT_NOSTAMCRIT, MAGIC_TRAIT)
	ADD_TRAIT(humie, TRAIT_NOLIMBDISABLE, MAGIC_TRAIT)
	humie.setMaxHealth(MUTE_MAX_HEALTH)
	humie.health = MUTE_MAX_HEALTH // Voiceless dead are much tougher than ghouls
	humie.become_husk()
	humie.faction |= "heretics"
	humie.apply_status_effect(/datum/status_effect/ghoul)

	var/datum/antagonist/heretic_monster/heretic_monster = humie.mind.add_antag_datum(/datum/antagonist/heretic_monster)
	var/datum/antagonist/heretic/master = user.mind.has_antag_datum(/datum/antagonist/heretic)
	heretic_monster.set_owner(master)
	atoms -= humie
	RegisterSignal(humie,COMSIG_MOB_DEATH,PROC_REF(remove_ghoul))
	ghouls += humie

/datum/eldritch_knowledge/flesh_ghoul/proc/remove_ghoul(datum/source)
	SIGNAL_HANDLER

	var/mob/living/carbon/human/humie = source
	ghouls -= humie
	humie.setMaxHealth(ORIGINAL_MAX_HEALTH)
	humie.remove_status_effect(/datum/status_effect/ghoul)
	humie.mind.remove_antag_datum(/datum/antagonist/heretic_monster)
	UnregisterSignal(source,COMSIG_MOB_DEATH)

/datum/eldritch_knowledge/flesh_grasp
	name = "Grasp of Flesh"
	gain_text = "My new found desires drove me to greater and greater heights."
	desc = "Empowers your mansus grasp to be able to create a single ghoul out of a dead person. Ghouls have only 25 HP and look like husks to the heathens' eyes."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/flesh_ghoul)
	var/ghoul_amt = 1
	var/list/spooky_scaries
	route = PATH_FLESH

/datum/eldritch_knowledge/flesh_grasp/on_mansus_grasp(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!ishuman(target) || target == user)
		return
	var/mob/living/carbon/human/human_target = target

	if(QDELETED(human_target) || human_target.stat != DEAD)
		return

	human_target.grab_ghost()

	if(!human_target.mind || !human_target.client)
		to_chat(user, "<span class='warning'>There is no soul connected to this body...</span>")
		return

	if(HAS_TRAIT(human_target, TRAIT_HUSK))
		to_chat(user, "<span class='warning'>You cannot revive a dead ghoul!</span>")
		return

	if(LAZYLEN(spooky_scaries) >= ghoul_amt)
		to_chat(user, "<span class='warning'>Your patron cannot support more ghouls on this plane!</span>")
		return

	LAZYADD(spooky_scaries, human_target)
	log_game("[key_name_admin(human_target)] has become a ghoul, their master is [user.real_name]")
	//we change it to true only after we know they passed all the checks
	. = TRUE
	RegisterSignal(human_target,COMSIG_MOB_DEATH, PROC_REF(remove_ghoul))
	human_target.revive(full_heal = TRUE, admin_revive = TRUE)
	ADD_TRAIT(human_target, TRAIT_NOSTAMCRIT, MAGIC_TRAIT)
	ADD_TRAIT(human_target, TRAIT_NOLIMBDISABLE, MAGIC_TRAIT)
	human_target.setMaxHealth(GHOUL_MAX_HEALTH)
	human_target.health = GHOUL_MAX_HEALTH
	human_target.become_husk()
	human_target.apply_status_effect(/datum/status_effect/ghoul)
	human_target.faction |= "heretics"
	var/datum/antagonist/heretic_monster/heretic_monster = human_target.mind.add_antag_datum(/datum/antagonist/heretic_monster)
	var/datum/antagonist/heretic/master = user.mind.has_antag_datum(/datum/antagonist/heretic)
	heretic_monster.set_owner(master)

/datum/eldritch_knowledge/flesh_grasp/proc/remove_ghoul(datum/source)
	SIGNAL_HANDLER

	var/mob/living/carbon/human/humie = source
	spooky_scaries -= humie
	humie.setMaxHealth(ORIGINAL_MAX_HEALTH)
	humie.remove_status_effect(/datum/status_effect/ghoul)
	humie.mind.remove_antag_datum(/datum/antagonist/heretic_monster)
	UnregisterSignal(source, COMSIG_MOB_DEATH)

/datum/eldritch_knowledge/flesh_grasp/on_eldritch_blade(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!ishuman(target))
		return
	var/mob/living/carbon/C = target
	var/datum/status_effect/eldritch/E = C.has_status_effect(/datum/status_effect/eldritch/rust) || C.has_status_effect(/datum/status_effect/eldritch/ash) || C.has_status_effect(/datum/status_effect/eldritch/flesh)
	if(E)
		E.on_effect()

/datum/eldritch_knowledge/flesh_mark
	name = "Mark of Flesh"
	gain_text = "I saw them, the marked ones. The screams... the silence."
	desc = "Your Mansus Grasp now applies the Mark of Flesh on hit. Attack the afflicted with your Sickly Blade to detonate the mark. Upon detonation, the Mark of Flesh causes additional bleeding."
	cost = 2
	next_knowledge = list(/datum/eldritch_knowledge/summon/raw_prophet)
	banned_knowledge = list(/datum/eldritch_knowledge/rust_mark,/datum/eldritch_knowledge/ash_mark)
	route = PATH_FLESH

/datum/eldritch_knowledge/flesh_mark/on_mansus_grasp(target,user,proximity_flag,click_parameters)
	. = ..()
	if(isliving(target))
		var/mob/living/living_target = target
		living_target.apply_status_effect(/datum/status_effect/eldritch/flesh)

/datum/eldritch_knowledge/flesh_blade_upgrade
	name = "Bleeding Steel"
	gain_text = "And then, blood rained from the heavens. That's when I finally understood the Marshal's teachings."
	desc = "Your Sickly Blade will now cause additional bleeding."
	cost = 2
	next_knowledge = list(/datum/eldritch_knowledge/summon/stalker)
	banned_knowledge = list(/datum/eldritch_knowledge/ash_blade_upgrade,/datum/eldritch_knowledge/rust_blade_upgrade)
	route = PATH_FLESH

/datum/eldritch_knowledge/flesh_blade_upgrade/on_eldritch_blade(target,user,proximity_flag,click_parameters)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.bleed_rate+= 2

/datum/eldritch_knowledge/summon/raw_prophet
	name = "Raw Ritual"
	gain_text = "The Uncanny Man, who walks alone in the valley between the worlds... I was able to summon his aid."
	desc = "You can now summon a Raw Prophet by transmutating a pair of eyes, a left arm and a pool of blood. Raw prophets have increased seeing range, as well as X-Ray vision, but they are very fragile."
	cost = 1
	required_atoms = list(/obj/item/organ/eyes,/obj/item/bodypart/l_arm,/obj/item/bodypart/r_arm,/obj/effect/decal/cleanable/blood)
	mob_to_summon = /mob/living/simple_animal/hostile/eldritch/raw_prophet
	next_knowledge = list(/datum/eldritch_knowledge/flesh_blade_upgrade,/datum/eldritch_knowledge/spell/blood_siphon,/datum/eldritch_knowledge/curse/alteration)
	route = PATH_FLESH

/datum/eldritch_knowledge/summon/stalker
	name = "Lonely Ritual"
	gain_text = "I was able to combine my greed and desires to summon an eldritch beast I had never seen before. An ever shapeshifting mass of flesh, it knew well my goals."
	desc = "You can now summon a Stalker by transmutating a knife, a flower, a pen and a piece of paper. Stalkers can shapeshift into harmless animals to get close to the victim."
	cost = 1
	required_atoms = list(/obj/item/kitchen/knife,/obj/item/reagent_containers/food/snacks/grown/poppy,/obj/item/pen,/obj/item/paper)
	mob_to_summon = /mob/living/simple_animal/hostile/eldritch/stalker
	next_knowledge = list(/datum/eldritch_knowledge/summon/ashy,/datum/eldritch_knowledge/summon/rusty,/datum/eldritch_knowledge/last/flesh_final)
	route = PATH_FLESH

/datum/eldritch_knowledge/last/flesh_final
	name = "Priest's Final Hymn"
	gain_text = "Man of this world. Hear me! For the time of the lord of arms has come! Emperor of Flesh guides my army!"
	desc = "Bring 3 bodies onto a transmutation rune to gain the ability of shedding your human form, and gaining untold power."
	required_atoms = list(/mob/living/carbon/human)
	cost = 3
	route = PATH_FLESH

/datum/eldritch_knowledge/last/flesh_final/on_finished_recipe(mob/living/user, list/atoms, loc)
	. = ..()
	priority_announce("$^@&#*$^@(#&$(@&#^$&#^@# Ever coiling vortex. Reality unfolded. THE LORD OF ARMS, [user.real_name] has ascended! Fear the ever twisting hand! $^@&#*$^@(#&$(@&#^$&#^@#","#$^@&#*$^@(#&$(@&#^$&#^@#", ANNOUNCER_SPANOMALIES)
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/shed_human_form)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	H.physiology.brute_mod *= 0.5
	H.physiology.burn_mod *= 0.5
	var/datum/antagonist/heretic/heretic = user.mind.has_antag_datum(/datum/antagonist/heretic)
	var/datum/eldritch_knowledge/flesh_grasp/ghoul1 = heretic.get_knowledge(/datum/eldritch_knowledge/flesh_grasp)
	ghoul1.ghoul_amt *= 3
	var/datum/eldritch_knowledge/flesh_ghoul/ghoul2 = heretic.get_knowledge(/datum/eldritch_knowledge/flesh_ghoul)
	ghoul2.max_amt *= 3

#undef GHOUL_MAX_HEALTH
#undef MUTE_MAX_HEALTH
#undef ORIGINAL_MAX_HEALTH
