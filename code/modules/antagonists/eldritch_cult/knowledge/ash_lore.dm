/datum/eldritch_knowledge/base_ash
	name = "Nightwatcher's secret"
	desc = "Opens up the Path of Ash to you. Allows you to transmute a match with a kitchen knife, or its derivatives, into an Ashen Blade."
	gain_text = "The City Guard know their watch. If you ask them at night, they may tell you about the ashy lantern."
	banned_knowledge = list(/datum/eldritch_knowledge/base_rust,/datum/eldritch_knowledge/base_flesh,/datum/eldritch_knowledge/last/rust_final,/datum/eldritch_knowledge/last/flesh_final)
	next_knowledge = list(/datum/eldritch_knowledge/ashen_grasp)
	required_atoms = list(/obj/item/kitchen/knife,/obj/item/match)
	result_atoms = list(/obj/item/melee/sickly_blade/ash)
	cost = 1
	route = PATH_ASH

/datum/eldritch_knowledge/base_ash/on_gain(mob/user)
	. = ..()
	ADD_TRAIT( user, TRAIT_NOFIRE, MAGIC_TRAIT)

/datum/eldritch_knowledge/base_ash/on_lose(mob/user)
	. = ..()
	REMOVE_TRAIT( user, TRAIT_NOFIRE, MAGIC_TRAIT)

/datum/eldritch_knowledge/spell/ashen_shift
	name = "Ashen Shift"
	gain_text = "The Nightwatcher was the first of them, his treason started it all."
	desc = "A short range jaunt that can help you escape from bad situations."
	cost = 1
	spell_to_add = /obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash
	next_knowledge = list(/datum/eldritch_knowledge/ash_mark,/datum/eldritch_knowledge/essence,/datum/eldritch_knowledge/ashen_eyes)
	route = PATH_ASH

/datum/eldritch_knowledge/ashen_grasp
	name = "Grasp of Ash"
	gain_text = "Gates have opened, minds have flooded, I remain."
	desc = "Empowers your mansus grasp to throw away enemies."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/spell/ashen_shift)
	route = PATH_ASH

/datum/eldritch_knowledge/ashen_grasp/on_mansus_grasp(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	var/mob/living/carbon/C = target
	if(!istype(C))
		return
	to_chat(C, "<span class='danger'>Your eyes burn horrifically!</span>") //pocket sand! also, this is the message that changeling blind stings use, and no, I'm not ashamed about reusing it
	C.become_nearsighted(EYE_DAMAGE)
	C.blind_eyes(5)
	C.blur_eyes(10)
	return

/datum/eldritch_knowledge/ashen_grasp/on_eldritch_blade(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!iscarbon(target))
		return
	var/mob/living/carbon/C = target
	var/datum/status_effect/eldritch/E = C.has_status_effect(/datum/status_effect/eldritch/rust) || C.has_status_effect(/datum/status_effect/eldritch/ash) || C.has_status_effect(/datum/status_effect/eldritch/flesh)
	if(E)
		E.on_effect()
		for(var/X in user.mind.spell_list)
			if(!istype(X,/obj/effect/proc_holder/spell/targeted/touch/mansus_grasp))
				continue
			var/obj/effect/proc_holder/spell/targeted/touch/mansus_grasp/MG = X
			MG.charge_counter = min(round(MG.charge_counter + MG.charge_max * 0.75),MG.charge_max) // refunds 75% of charge.

/datum/eldritch_knowledge/ash_mark
	name = "Mark of ash"
	gain_text = "The Nightwatcher was a very particular man, always watching in the dead of night. But in spite of his duty, he regularly tranced through the manse with his blazing lantern held high."
	desc = "Your Mansus Grasp now applies the Mark of Ash on hit. Attack the afflicted with your Sickly Blade to detonate the mark. Upon detonation, the Mark of Ash causes stamina damage and burn damage, and spreads to an additional nearby opponent. The damage decreases with each spread."
	cost = 2
	next_knowledge = list(/datum/eldritch_knowledge/mad_mask)
	banned_knowledge = list(/datum/eldritch_knowledge/rust_mark,/datum/eldritch_knowledge/flesh_mark)
	route = PATH_ASH

/datum/eldritch_knowledge/ash_mark/on_mansus_grasp(target,user,proximity_flag,click_parameters)
	. = ..()
	if(isliving(target))
		var/mob/living/living_target = target
		living_target.apply_status_effect(/datum/status_effect/eldritch/ash,5)

/datum/eldritch_knowledge/mad_mask
	name = "Mask of Madness"
	gain_text = "He walks the world, unnoticed by the masses."
	desc = "Allows you to transmute any mask, with a candle and a pair of eyes, to create a mask of madness, It causes passive stamina damage to everyone around the wearer and hallucinations, can be forced on a non believer to make him unable to take it off..."
	result_atoms = list(/obj/item/clothing/mask/void_mask)
	required_atoms = list(/obj/item/organ/eyes,/obj/item/clothing/mask,/obj/item/candle)
	next_knowledge = list(/datum/eldritch_knowledge/guise,/datum/eldritch_knowledge/ash_blade_upgrade,/datum/eldritch_knowledge/curse/alteration)
	cost = 1
	route = PATH_ASH

/datum/eldritch_knowledge/spell/flame_birth
	name = "Flame Birth"
	gain_text = "The Nightwatcher was a man of principles, and yet his power arose from the chaos he vowed to combat."
	desc = "Short range spell that allows you to curse someone with massive sanity loss."
	cost = 1
	spell_to_add = /obj/effect/proc_holder/spell/targeted/fiery_rebirth
	next_knowledge = list(/datum/eldritch_knowledge/spell/cleave,/datum/eldritch_knowledge/summon/ashy,/datum/eldritch_knowledge/last/ash_final)
	route = PATH_ASH

/datum/eldritch_knowledge/ash_blade_upgrade
	name = "Fiery blade"
	gain_text = "Blade in hand, he swung and swung as the ash fell from the skies. His city, his people... all burnt to cinders, and yet life still remained in his charred body."
	desc = "Your blade of choice will now light your enemies ablaze."
	cost = 2
	next_knowledge = list(/datum/eldritch_knowledge/spell/flame_birth)
	banned_knowledge = list(/datum/eldritch_knowledge/rust_blade_upgrade,/datum/eldritch_knowledge/flesh_blade_upgrade)
	route = PATH_ASH

/datum/eldritch_knowledge/ash_blade_upgrade/on_eldritch_blade(target,user,proximity_flag,click_parameters)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		C.adjust_fire_stacks(1)
		C.IgniteMob()

/datum/eldritch_knowledge/last/ash_final
	name = "Ashlord's rite"
	gain_text = "The Nightwatcher found the rite and shared it amongst mankind! For now I am one with the fire, WITNESS MY ASCENSION!"
	desc = "Bring 3 corpses onto a transmutation rune, you will become immune to fire, the vacuum of space, cold and other environmental hazards and become overall sturdier to all other damages. You will gain a spell that passively creates ring of fire around you as well ,as you will gain a powerful ability that lets you create a wave of flames all around you."
	required_atoms = list(/mob/living/carbon/human)
	cost = 3
	route = PATH_ASH
	var/list/trait_list = list(TRAIT_RESISTHEAT,TRAIT_NOBREATH,TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_RADIMMUNE,TRAIT_PIERCEIMMUNE,TRAIT_NODISMEMBER)

/datum/eldritch_knowledge/last/ash_final/on_finished_recipe(mob/living/user, list/atoms, loc)
	priority_announce("$^@&#*$^@(#&$(@&#^$&#^@# Fear the blaze, for the Ashlord, [user.real_name] has ascended! The flames shall consume all! $^@&#*$^@(#&$(@&#^$&#^@#","#$^@&#*$^@(#&$(@&#^$&#^@#", ANNOUNCER_SPANOMALIES)
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/fire_cascade/big)
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/fire_sworn)
	var/mob/living/carbon/human/H = user
	H.physiology.brute_mod *= 0.5
	H.physiology.burn_mod *= 0.5
	for(var/X in trait_list)
		ADD_TRAIT(user,X,MAGIC_TRAIT)
	return ..()

/datum/eldritch_knowledge/last/ash_final/on_life(mob/user)
	. = ..()
	if(!finished)
		return
	var/turf/L = get_turf(user)
	var/datum/gas_mixture/env = L.return_air()
	for(var/turf/T as() in RANGE_TURFS(1,user))
		env = T.return_air()
		env.set_temperature(env.return_temperature() + 5 )
		T.air_update_turf()
	L.air_update_turf()
