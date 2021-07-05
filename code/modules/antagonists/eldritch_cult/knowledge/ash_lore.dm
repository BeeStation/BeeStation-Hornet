/datum/eldritch_knowledge/base_ash
	name = "STATION I - The Lord's wrath"
	desc = "Opens up the Path of Ash to you. Allows you to transmute a match with a kitchen knife, or its derivatives, into an Ashen Blade."
	gain_text = "A sudden burst of anger overwhelms you, a feeling of power, you see their heresy. They must be punished and YOU are the one that must cleanse all with flame into the perfectness of ash..."
	banned_knowledge = list(/datum/eldritch_knowledge/base_rust,/datum/eldritch_knowledge/base_flesh,/datum/eldritch_knowledge/final/rust_final,/datum/eldritch_knowledge/final/flesh_final)
	next_knowledge = list(/datum/eldritch_knowledge/ashen_grasp)
	required_atoms = list(/obj/item/kitchen/knife,/obj/item/match)
	result_atoms = list(/obj/item/melee/sickly_blade/ash)
	cost = 1
	route = PATH_ASH

/datum/eldritch_knowledge/ashen_grasp
	name = "STATION II - Grasp of Ash"
	gain_text = "When He broke the second seal, I heard the second living creature saying, 'Come.' And another, a red horse, went out; and to him who sat on it, it was granted to take peace from Earth, and that men would slay one another; and a great sword was given to him."
	desc = "Empowers your mansus grasp to blind enemies."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/spell/ashen_rewind)
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


/datum/eldritch_knowledge/spell/ashen_rewind
	name = "STATION III - Ashen rewind"
	gain_text = "Ashes to ashes, dust to dust, and as such your time will come, but fear not as you will be granted life again by your savior once you complete your task."
	desc = "Lets you rewind back to the casting position after 60 seconds. Your health is unaffected."
	cost = 1
	spell_to_add = /obj/effect/proc_holder/spell/targeted/ashen_rewind
	next_knowledge = list(/datum/eldritch_knowledge/spell/ashen_shift, /datum/eldritch_knowledge/spell/executioners_fury)
	route = PATH_ASH

/datum/eldritch_knowledge/spell/ashen_shift
	name = "STATION IV - Ashen Shift"
	gain_text = "A goal he was so decided in completing no matter of the physical world could stop his advance..."
	desc = "A short range jaunt that can help you escape from bad situations."
	cost = 1
	spell_to_add = /obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash
	next_knowledge = list(/datum/eldritch_knowledge/ash_mark)
	route = PATH_ASH
	banned_knowledge = list(/datum/eldritch_knowledge/spell/executioners_fury)

/datum/eldritch_knowledge/spell/executioners_fury
	name = "STATION IV - Executioner's Fury"
	gain_text = "...a motivation so strong not even his flesh could stop what his soul yearned the most!"
	desc = "Empower your action speed for a few seconds, allowing you to perform most melee actions at high speeds for a short time."
	cost = 1
	spell_to_add = (/obj/effect/proc_holder/spell/targeted/executioners_fury)
	next_knowledge = list(/datum/eldritch_knowledge/ash_mark)
	banned_knowledge = list(/datum/eldritch_knowledge/spell/ashen_shift)

/datum/eldritch_knowledge/ash_mark
	name = "STATION V - Mark of ash"
	gain_text = "'Let me show you something' said the preacher, as he set ablaze a piece of stained cloth. 'Do you see? After the flames clear there is nothing left. Nothing of evil. It is clean, depsite being dust which we sweep outside as filth. Remember this.'"
	desc = "Your Mansus Grasp now applies the Mark of Ash on hit. Attack the afflicted with your Sickly Blade to detonate the mark. Upon detonation, the Mark of Ash ignites targets and those around them."
	cost = 2
	next_knowledge = list(/datum/eldritch_knowledge/spell/flame_birth, /datum/eldritch_knowledge/spell/flame_judgement)
	route = PATH_ASH

/datum/eldritch_knowledge/ash_mark/on_mansus_grasp(target,user,proximity_flag,click_parameters)
	. = ..()
	if(isliving(target))
		var/mob/living/living_target = target
		living_target.apply_status_effect(/datum/status_effect/eldritch/ash)

/datum/eldritch_knowledge/spell/flame_birth
	name = "STATION VI - Flaming Rebirth"
	gain_text = "As his power grew, the rage did too. The thrill was too much. And just like he spiraled down the road of power..."
	desc = "Short range spell that allows you to extinguish nearby burning targets to heal yourself and finish them off if in critical condition."
	cost = 2
	spell_to_add = /obj/effect/proc_holder/spell/targeted/fiery_rebirth
	next_knowledge = list(/datum/eldritch_knowledge/armor/ash, /datum/eldritch_knowledge/ash_blade_upgrade)
	route = PATH_ASH
	banned_knowledge = list(/datum/eldritch_knowledge/spell/flame_judgement)

/datum/eldritch_knowledge/spell/flame_judgement
	name = "STATION VI - Flaming Judgement"
	gain_text = "...the flame fueled the man, the man fed the flame. Living fuel, a high calliber round of living ammunition."
	desc = "Short range spell that allows you to extinguish nearby burning targets to stun, damage and finish them off if in critical condition."
	cost = 2
	spell_to_add = /obj/effect/proc_holder/spell/targeted/flame_birth_variant
	next_knowledge = list(/datum/eldritch_knowledge/armor/ash, /datum/eldritch_knowledge/ash_blade_upgrade)
	route = PATH_VARIANT
	banned_knowledge = list(/datum/eldritch_knowledge/spell/flame_birth)

/datum/eldritch_knowledge/ash_blade_upgrade
	name = "SACRIMENT - Fiery blade"
	gain_text = "Blade in hand, he swung and swung as the ash fell from the skies. His city, his people... all burnt to cinders, and yet life still remained in his charred body."
	desc = "Your blade of choice will now light your enemies ablaze."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/armor/ash)
	banned_knowledge = list(/datum/eldritch_knowledge/rust_blade_upgrade,/datum/eldritch_knowledge/flesh_blade_upgrade)
	route = PATH_ASH

/datum/eldritch_knowledge/ash_blade_upgrade/on_eldritch_blade(target,user,proximity_flag,click_parameters)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		C.adjust_fire_stacks(1)
		C.IgniteMob()
	
/datum/eldritch_knowledge/final/ash_final
	name = "THE LORD WEEPS - Ashlord's Ascent"
	gain_text = "'Prometheus cared more for man than for the wrath of the increasingly powerful and autocratic king of the gods, so he stole fire from Zeus' lightning, concealed it in a hollow stalk of fennel, and brought it to man'. The question stands, but was he right to do so?."
	desc = "Bring 3 corpses onto a transmutation rune to ascend. While ascended you are extremely durable to most things, however you take more stamina damage. You gain a spell that lets you conjure an ashen javelin to throw at your foes and also a whisper. The whisper allows you to set all who hear it ablaze and deal brain damage, but doing so warns all in a large radius of your presence."
	required_atoms = list(/mob/living/carbon/human)
	cost = 3
	route = PATH_ASH
	var/list/trait_list = list(TRAIT_RESISTHEAT,TRAIT_NOBREATH,TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_NOFIRE,TRAIT_RADIMMUNE,TRAIT_NODISMEMBER, TRAIT_PIERCEIMMUNE)

/datum/eldritch_knowledge/final/ash_final/on_finished_recipe(mob/living/user, list/atoms, loc)
	priority_announce("ATTENTION: Your station is radiating abnormal temperature levels and divine signals. We are cutting communications after this message due to mass hysteria. Our specialists came up with experimental methods to avert crisis: EMPLOY USE OF EAR PROTECTION, USE FIRE PROTECTIVE CLOTHING, IT APPEARS DISABLING WEAPONRY IS MOST EFFECTIVE AGAINST DIVINE BEINGS. ETA 1 MINUTE, GEAR UP, EVACUATE THE AREA AND REMEMBER TO DECONVERT THE HERETIC IF POSSIBLE -BZZZ!@*(%&!)*%+!@%&*", "Central Command High Officer of Elderitch Activity Research", 'sound/magic/eldritch/bell.ogg')
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/conjure_item/ash_javelin)
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/trial_by_fire)
	var/mob/living/carbon/human/H = user
	for(var/X in trait_list)
		ADD_TRAIT(user,X,MAGIC_TRAIT)
	H.physiology.damage_resistance = 100
	H.visible_message("[H.name] is wrapped in a strange shell, you have a bad feeling about this...", \
				"<span class='notice'>You are enveloped by a strange shell, do not worry, as in a minute your metamorphosis will be complete...</span>")
	H.physiology.brute_mod *= 0.5
	H.physiology.burn_mod *= 0.5
	H.physiology.stamina_mod *= 1.25
	sleep(600)
	H.physiology.damage_resistance = initial(H.physiology.damage_resistance)