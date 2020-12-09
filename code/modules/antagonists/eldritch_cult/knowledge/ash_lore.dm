// - TECH TREE -

/datum/eldritch_knowledge/base_ash
	name = "Harbinger of Ember"
	desc = "You chose the path of ash. Allows you to transmute a match with a kitchen knife or it's derivatives into an ashen blade. Allows you to recruit disciples."
	gain_text = "City guard knows their watch. If you ask them at night they may tell you about the ashy lantern."
	banned_knowledge = list(/datum/eldritch_knowledge/base_rust,/datum/eldritch_knowledge/base_flesh,/datum/eldritch_knowledge/final/rust_final,/datum/eldritch_knowledge/final/flesh_final)
	next_knowledge = list(/datum/eldritch_knowledge/ashen_grasp)
	required_atoms = list(/obj/item/kitchen/knife,/obj/item/match)
	result_atoms = list(/obj/item/melee/sickly_blade/ash)
	cost = 5
	route = PATH_ASH
	followers_increment = 1

/datum/eldritch_knowledge/ashen_grasp
	name = "Grasp of Ash"
	gain_text = "Gates have opened, minds have flooded, I remain."
	desc = "Empowers your mansus grasp to throw away enemies."
	cost = 5
	next_knowledge = list(/datum/eldritch_knowledge/spell/ashen_shift)
	route = PATH_ASH

/datum/eldritch_knowledge/spell/ashen_shift
	name = "Ashen Shift"
	gain_text = "Ash is all the same, how can one man master it all?"
	desc = "Short range jaunt that can help you escape from bad situations."
	cost = 5
	spell_to_add = /obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash
	next_knowledge = list(/datum/eldritch_knowledge/ash_mark,/datum/eldritch_knowledge/essence,/datum/eldritch_knowledge/ashen_eyes,/datum/eldritch_knowledge/dreamgate)
	route = PATH_ASH

/datum/eldritch_knowledge/ash_mark
	name = "Priest Ascension"
	gain_text = "Spread the famine."
	desc = "As a Priest of Ash, you can recruit more disciples. Also, your eldritch blade now applies a mark which, when activated with Mansus Grasph, causes stamina loss, and fire damage, and spreads to a nearby carbons."
	cost = 10
	next_knowledge = list(/datum/eldritch_knowledge/dematerialize)
	banned_knowledge = list(/datum/eldritch_knowledge/rust_mark,/datum/eldritch_knowledge/flesh_mark)
	route = PATH_ASH
	followers_increment = 1

/datum/eldritch_knowledge/dematerialize
	name = "Goopher Dust"
	gain_text = "God's anger, my weapon!"
	desc = "Your Mansus Grasp can shred strange figurines into goopher dust. This dust has a greater effect but can dissipates uponuse."
	cost = 5
	next_knowledge = list(/datum/eldritch_knowledge/ash_blade_upgrade,/datum/eldritch_knowledge/spell/blood_siphon,/datum/eldritch_knowledge/curse/alteration,/datum/eldritch_knowledge/armor)
	route = PATH_ASH

/datum/eldritch_knowledge/ash_blade_upgrade
	name = "Prophet Ascension"
	gain_text = "Your pitiful form, turned to ashes..."
	desc = "As a Prophet of Ash, you can recruit more disciples. Enhances your blade to to set targets on fire."
	cost = 10
	next_knowledge = list(/datum/eldritch_knowledge/spell/flame_birth)
	banned_knowledge = list(/datum/eldritch_knowledge/rust_blade_upgrade,/datum/eldritch_knowledge/flesh_blade_upgrade)
	route = PATH_ASH
	followers_increment = 1

/datum/eldritch_knowledge/spell/flame_birth
	name = "Flame Birth"
	gain_text = "Nightwatcher was a man of principles, and yet he arose from the chaos he vowed to protect us from."
	desc = "Flame Birth is a short range spell that allows you to curse someone with massive sanity loss."
	cost = 5
	spell_to_add = /obj/effect/proc_holder/spell/targeted/fiery_rebirth
	next_knowledge = list(/datum/eldritch_knowledge/final/ash_final,/datum/eldritch_knowledge/summon/ashy,/datum/eldritch_knowledge/summon/rusty,/datum/eldritch_knowledge/spell/cleave)
	route = PATH_ASH

/datum/eldritch_knowledge/final/ash_final
	name = "Ashlord's rite"
	gain_text = "The forgotten lords have spoken! The lord of ash have come! Fear the fire!"
	desc = "Bring 3 corpses onto a transmutation rune, you will become immune to fire ,space ,cold and other enviromental hazards and become overall sturdier to all other damages. You will gain a spell that passively creates ring of fire around you as well ,as you will gain a powerful abiltiy that let's you create a wave of flames all around you."
	required_atoms = list(/mob/living/carbon/human)
	cost = 15
	route = PATH_ASH
	var/list/trait_list = list(TRAIT_RESISTHEAT,TRAIT_NOBREATH,TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_NOFIRE,TRAIT_RADIMMUNE,TRAIT_PIERCEIMMUNE,TRAIT_NODISMEMBER)
	followers_increment = 1

//unused

/datum/eldritch_knowledge/curse/blindness
	name = "Curse of blindness"
	gain_text = "Blind man walks through the world, unnoticed by the masses."
	desc = "Curse someone with 2 minutes of complete blindness by sacrificing a pair of eyes, a screwdriver and a pool of blood, with an object that the victim has touched with their bare hands."
	cost = 2
	required_atoms = list(/obj/item/organ/eyes,/obj/item/screwdriver,/obj/effect/decal/cleanable/blood)
	next_knowledge = list(/datum/eldritch_knowledge/curse/corrosion,/datum/eldritch_knowledge/ash_blade_upgrade,/datum/eldritch_knowledge/curse/paralysis)
	timer = 2 MINUTES
	route = PATH_ASH

//	-	EFFECT	-

/datum/eldritch_knowledge/ashen_grasp/on_mansus_grasp(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!iscarbon(target))
		return
	var/mob/living/carbon/C = target
	to_chat(C, "<span class='danger'>Your eyes burn horrifically!</span>") //pocket sand! also, this is the message that changeling blind stings use, and no, I'm not ashamed about reusing it
	C.become_nearsighted(EYE_DAMAGE)
	C.blind_eyes(5)
	C.blur_eyes(10)
	return

/datum/eldritch_knowledge/ash_mark/on_eldritch_blade(target,user,proximity_flag,click_parameters)
	. = ..()
	if(isliving(target))
		var/mob/living/living_target = target
		living_target.apply_status_effect(/datum/status_effect/eldritch/ash,5)

/datum/eldritch_knowledge/curse/blindness/curse(mob/living/chosen_mob)
	. = ..()
	chosen_mob.become_blind(MAGIC_TRAIT)

/datum/eldritch_knowledge/curse/blindness/uncurse(mob/living/chosen_mob)
	. = ..()
	chosen_mob.cure_blind(MAGIC_TRAIT)

/datum/eldritch_knowledge/ash_blade_upgrade/on_eldritch_blade(target,user,proximity_flag,click_parameters)
	..()
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		C.adjust_fire_stacks(1)
		C.IgniteMob()

/datum/eldritch_knowledge/ash_blade_upgrade/on_mansus_touch(atom/target, mob/user, proximity_flag, click_parameters)
	..()
	var/mob/living/L = target
	if (istype(L))
		var/datum/reagent/oil/R = new ()
		R.reaction_mob(L, TOUCH, 10, L.get_permeability_protection(), FALSE)
		qdel(R)
	return TRUE

/datum/eldritch_knowledge/final/ash_final/on_finished_recipe(mob/living/user, list/atoms, loc)
	priority_announce("$^@&#*$^@(#&$(@&#^$&#^@# Fear the blaze, for the Ashlord, [user.real_name] has ascended! The flames shall consume all! $^@&#*$^@(#&$(@&#^$&#^@#","#$^@&#*$^@(#&$(@&#^$&#^@#", 'sound/ai/spanomalies.ogg')
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/fire_cascade/big)
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/fire_sworn)
	var/mob/living/carbon/human/H = user
	H.physiology.brute_mod *= 0.5
	H.physiology.burn_mod *= 0.5
	for(var/X in trait_list)
		ADD_TRAIT(user,X,MAGIC_TRAIT)
	return ..()

/datum/eldritch_knowledge/final/ash_final/on_life(mob/user)
	. = ..()
	if(!finished)
		return
	var/turf/L = get_turf(user)
	var/datum/gas_mixture/env = L.return_air()
	for(var/turf/T in range(1,user))
		env = T.return_air()
		env.set_temperature(env.return_temperature() + 5 )
		T.air_update_turf()
	L.air_update_turf()