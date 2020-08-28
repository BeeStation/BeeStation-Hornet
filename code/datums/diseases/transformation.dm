/datum/disease/transformation
	name = "Transformation"
	max_stages = 5
	spread_text = "Acute"
	spread_flags = DISEASE_SPREAD_SPECIAL
	cure_text = "A coder's love (theoretical)."
	agent = "Shenanigans"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey, /mob/living/carbon/alien)
	danger = DISEASE_BIOHAZARD
	stage_prob = 5
	visibility_flags = HIDDEN_SCANNER|HIDDEN_PANDEMIC
	disease_flags = CURABLE
	var/is_mutagenic = FALSE
	var/list/stage1 = list("You feel unremarkable.")
	var/list/stage2 = list("You feel boring.")
	var/list/stage3 = list("You feel utterly plain.")
	var/list/stage4 = list("You feel white bread.")
	var/list/stage5 = list("Oh the humanity!")
	var/new_form = /mob/living/carbon/human
	var/bantype

/datum/disease/transformation/Copy()
	var/datum/disease/transformation/D = ..()
	D.stage1 = stage1.Copy()
	D.stage2 = stage2.Copy()
	D.stage3 = stage3.Copy()
	D.stage4 = stage4.Copy()
	D.stage5 = stage5.Copy()
	D.new_form = D.new_form
	return D

/datum/disease/transformation/stage_act(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(1)
			if (stage1 && DT_PROB(stage_prob, delta_time))
				to_chat(affected_mob, pick(stage1))
		if(2)
			if (stage2 && DT_PROB(stage_prob, delta_time))
				to_chat(affected_mob, pick(stage2))
		if(3)
			if (stage3 && DT_PROB(stage_prob * 2, delta_time))
				to_chat(affected_mob, pick(stage3))
		if(4)
			if (stage4 && DT_PROB(stage_prob * 2, delta_time))
				to_chat(affected_mob, pick(stage4))
		if(5)
			if(is_mutagenic) //we don't do it normally
				form_mutagen(affected_mob)
				return
			do_disease_transformation(affected_mob)

/datum/disease/transformation/proc/do_disease_transformation(mob/living/affected_mob)
	if(istype(affected_mob, /mob/living/carbon) && affected_mob.stat != DEAD)
		if(length(stage5))
			to_chat(affected_mob, pick(stage5))
		if(QDELETED(affected_mob))
			return
		if(affected_mob.notransform)
			return
		affected_mob.notransform = 1
		affected_mob.unequip_everything()
		var/mob/living/new_mob = new new_form(affected_mob.loc)
		if(istype(new_mob))
			if(bantype && is_banned_from(affected_mob.ckey, bantype))
				replace_banned_player(new_mob)
			new_mob.set_combat_mode(TRUE)
			if(affected_mob.mind)
				affected_mob.mind.transfer_to(new_mob)
			else
				new_mob.key = affected_mob.key

		new_mob.name = affected_mob.real_name
		new_mob.real_name = new_mob.name
		qdel(affected_mob)

/datum/disease/transformation/proc/form_mutagen(mob/living/affected_mob)
	return //default if something goes wrong

/datum/disease/transformation/proc/replace_banned_player(var/mob/living/new_mob) // This can run well after the mob has been transferred, so need a handle on the new mob to kill it if needed.
	set waitfor = FALSE

	affected_mob.playable_bantype = bantype
	affected_mob.ghostize(TRUE,SENTIENCE_FORCE)
	to_chat(affected_mob, "Your mob has been taken over by a ghost! Appeal your job ban if you want to avoid this in the future!")

	var/list/mob/dead/observer/candidates = poll_candidates_for_mob("Do you want to play as [affected_mob.name]?", bantype, null, 7.5 SECONDS, affected_mob, ignore_category = FALSE)
	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		message_admins("[key_name_admin(C)] has taken control of ([key_name_admin(affected_mob)]) to replace a jobbanned player.")
		affected_mob.key = C.key
	else
		to_chat(new_mob, "Your mob has been offered to ghosts! Appeal your job ban if you want to avoid this in the future!")

/datum/disease/transformation/robot

	name = "Robotic Transformation"
	cure_text = "An injection of copper."
	cures = list(/datum/reagent/copper)
	cure_chance = 2.5
	agent = "R2D2 Nanomachines"
	desc = "An acute nanomachine infection which converts its host into a cyborg."
	danger = DISEASE_BIOHAZARD
	visibility_flags = NONE
	stage1	= list()
	stage2	= list("Your joints feel stiff.", span_danger("Beep...boop.."))
	stage3	= list(span_danger("Your joints feel very stiff."), "Your skin feels loose.", span_danger("You can feel something move...inside."))
	stage4	= list(span_danger("Your skin feels very loose."), span_danger("You can feel... something...inside you."))
	stage5	= list(span_danger("Your skin feels as if it's about to burst off!"))
	new_form = /mob/living/silicon/robot
	infectable_biotypes = list(MOB_ORGANIC, MOB_UNDEAD, MOB_ROBOTIC)
	bantype = JOB_NAME_CYBORG


/datum/disease/transformation/robot/stage_act(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(3)
			if (DT_PROB(4, delta_time))
				affected_mob.say(pick("Beep, boop", "beep, beep!", "Boop...bop"), forced = "robotic transformation")
			if (DT_PROB(2, delta_time))
				to_chat(affected_mob, span_danger("You feel a stabbing pain in your head."))
				affected_mob.Unconscious(40)
		if(4)
			if (DT_PROB(10, delta_time))
				affected_mob.say(pick("beep, beep!", "Boop bop boop beep.", "kkkiiiill mmme", "I wwwaaannntt tttoo dddiiieeee..."), forced = "robotic transformation")


/datum/disease/transformation/xeno

	name = "Xenomorph Transformation"
	cure_text = "Spaceacillin & Glycerol"
	cures = list(/datum/reagent/medicine/spaceacillin, /datum/reagent/glycerol)
	cure_chance = 2.5
	agent = "Rip-LEY Alien Microbes" //I would have said nostramos, personally, guy from September 2013 -rkz
	desc = "This disease changes the victim into a xenomorph."
	danger = DISEASE_BIOHAZARD
	visibility_flags = NONE
	stage1	= list()
	stage2	= list("Your throat feels scratchy.", span_danger("Kill..."))
	stage3	= list(span_danger("Your throat feels very scratchy."), "Your skin feels tight.", span_danger("You can feel something move...inside."))
	stage4	= list(span_danger("Your skin feels very tight."), span_danger("Your blood boils!"), span_danger("You can feel... something...inside you."))
	stage5	= list(span_danger("Your skin feels as if it's about to burst off!"))
	new_form = /mob/living/carbon/alien/humanoid/hunter
	bantype = ROLE_ALIEN


/datum/disease/transformation/xeno/stage_act(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(3)
			if(DT_PROB(2, delta_time))
				to_chat(affected_mob, span_danger("You feel a stabbing pain in your head."))
				affected_mob.Unconscious(40)
		if(4)
			if(DT_PROB(10, delta_time))
				affected_mob.say(pick("You look delicious.", "Going to... devour you...", "Hsssshhhhh!"), forced = "xenomorph transformation")


/datum/disease/transformation/slime
	name = "Advanced Mutation Transformation"
	cure_text = "Below Freezing Temperature"
	cures = list()
	agent = "Advanced Mutation Toxin"
	desc = "This highly concentrated extract converts anything into more of itself."
	danger = DISEASE_BIOHAZARD
	visibility_flags = NONE
	stage1	= list("You don't feel very well.")
	stage2	= list("Your skin feels a little slimy.")
	stage3	= list(span_danger("Your appendages are melting away."), span_danger("Your limbs begin to lose their shape."))
	stage4	= list(span_danger("You are turning into a slime."))
	stage5	= list(span_danger("You have become a slime."))
	new_form = /mob/living/simple_animal/slime

/datum/disease/transformation/slime/stage_act(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	var/mob/living/carbon/H = affected_mob
	if(H.bodytemperature < T0C)
		cure()
		return FALSE

	switch(stage)
		if(1)
			if(ishuman(affected_mob) && affected_mob.dna)
				if(affected_mob.dna.species.id == "slime" || affected_mob.dna.species.id == "stargazer" || affected_mob.dna.species.id == "lum")
					stage = 5
		if(3)
			if(ishuman(affected_mob))
				var/mob/living/carbon/human/human = affected_mob
				if(human.dna.species.id != "slime" && affected_mob.dna.species.id != "stargazer" && affected_mob.dna.species.id != "lum")
					human.set_species(/datum/species/oozeling/slime)

/datum/disease/transformation/corgi
	name = "The Barkening"
	cure_text = "Death"
	cures = list(/datum/reagent/medicine/adminordrazine)
	agent = "Fell Doge Majicks"
	desc = "This disease transforms the victim into a corgi."
	danger = DISEASE_BIOHAZARD
	visibility_flags = NONE
	stage1	= list("BARK.")
	stage2	= list("You feel the need to wear silly hats.")
	stage3	= list(span_danger("Must... eat... chocolate...."), span_danger("YAP"))
	stage4	= list(span_danger("Visions of washing machines assail your mind!"))
	stage5	= list(span_danger("AUUUUUU!!!"))
	new_form = /mob/living/basic/pet/dog/corgi

/datum/disease/transformation/corgi/stage_act(delta_time, times_fired)
	. = ..()
	if(!.)
		return
	switch(stage)
		if(3)
			if (DT_PROB(4, delta_time))
				affected_mob.say(pick("YAP", "Woof!"), forced = "corgi transformation")
		if(4)
			if (DT_PROB(10, delta_time))
				affected_mob.say(pick("Bark!", "AUUUUUU"), forced = "corgi transformation")

/datum/disease/transformation/morph
	name = "Gluttony's Blessing"
	cure_text = "Nothing"
	cures = list(/datum/reagent/medicine/adminordrazine)
	agent = "Gluttony's Blessing"
	desc = "A 'gift' from somewhere terrible."
	stage_prob = 10
	danger = DISEASE_BIOHAZARD
	visibility_flags = NONE
	stage1	= list("Your stomach rumbles.")
	stage2	= list("Your skin feels saggy.")
	stage3	= list(span_danger("Your appendages are melting away."), span_danger("Your limbs begin to lose their shape."))
	stage4	= list(span_danger("You're ravenous."))
	stage5	= list(span_danger("You have become a morph."))
	new_form = /mob/living/simple_animal/hostile/morph
	infectable_biotypes = list(MOB_ORGANIC, MOB_INORGANIC, MOB_UNDEAD) //magic!

/datum/disease/transformation/gondola
	name = "Gondola Transformation"
	cure_text = "Condensed Capsaicin, ingested or injected." //getting pepper sprayed doesn't help
	cures = list(/datum/reagent/consumable/condensedcapsaicin) //beats the hippie crap right out of your system
	cure_chance = 55
	stage_prob = 2.5
	agent = "Tranquility"
	desc = "Consuming the flesh of a Gondola comes at a terrible price."
	danger = DISEASE_BIOHAZARD
	visibility_flags = NONE
	stage1	= list("You seem a little lighter in your step.")
	stage2	= list("You catch yourself smiling for no reason.")
	stage3	= list(span_danger("A cruel sense of calm overcomes you."), span_danger("You can't feel your arms!"), span_danger("You let go of the urge to hurt clowns."))
	stage4	= list(span_danger("You can't feel your arms. It does not bother you anymore."), span_danger("You forgive the clown for hurting you."))
	stage5	= list(span_danger("You have become a Gondola."))
	new_form = /mob/living/basic/pet/gondola


/datum/disease/transformation/gondola/stage_act(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(DT_PROB(2.5, delta_time))
				affected_mob.emote("smile")
			if(DT_PROB(10, delta_time))
				affected_mob.reagents.add_reagent_list(list(/datum/reagent/pax = 5))
		if(3)
			if(DT_PROB(2.5, delta_time))
				affected_mob.emote("smile")
			if(DT_PROB(10, delta_time))
				affected_mob.reagents.add_reagent_list(list(/datum/reagent/pax = 5))
		if(4)
			if(DT_PROB(2.5, delta_time))
				affected_mob.emote("smile")
			if(DT_PROB(10, delta_time))
				affected_mob.reagents.add_reagent_list(list(/datum/reagent/pax = 5))
			if(DT_PROB(1, delta_time))
				var/obj/item/held_item = affected_mob.get_active_held_item()
				if(held_item)
					to_chat(affected_mob, "<span class='danger'>You let go of what you were holding.</span>")
					affected_mob.dropItemToGround(held_item)

/datum/disease/transformation/felinid
	name = "Nano-Feline Assimilative Toxoplasmosis"
	cure_text = "Something that would kill off the tiny cats."
	spread_text = "Acute"
	disease_flags = CURABLE|CAN_CARRY|CAN_RESIST
	cures = list(/datum/reagent/consumable/cocoa, /datum/reagent/consumable/hot_cocoa) //kills all the tiny cats that infected your organism
	cure_chance = 25
	stage_prob = 3
	agent = "Nano-feline Toxoplasmosis"
	desc = "A lot of tiny cats in the blood that slowly turn you into a big cat."
	is_mutagenic = TRUE //So that it won't be autocured after stage 5
	danger = DISEASE_BIOHAZARD
	visibility_flags = 0
	stage1	= list("You feel scratching fom within.", "You hear a faint miaow somewhere really close.")
	stage2	= list(span_danger("You suppress the urge to lick yourself."))
	stage3	= list(span_danger("You feel the need to cough out something fluffy."), span_danger("You feel the need to scratch your neck with your foot."), span_danger("You think you should adopt a cat."))
	stage4	= list(span_danger("You start thinking that felinids are not that bad after all!"), span_danger("You feel scared at the thought of eating chocolate."))
	stage5	= list(span_danger("You have become a catperson."))
	infectable_biotypes = list(MOB_ORGANIC, MOB_INORGANIC, MOB_UNDEAD) //Nothing evades the curse!
	new_form = /mob/living/carbon/human/species/felinid

/datum/disease/transformation/felinid/stage_act()
	..()
	switch(stage)
		if(2)
			if (prob(1))
				affected_mob.visible_message(span_danger("[affected_mob] licks [affected_mob.p_their()] hand."))
		if(3)
			if (prob(8))
				affected_mob.say(pick("Nya", "MIAOW", "Ny- NYAAA", "meow", "NYAAA", "nya", "Ny- meow", "mrrrr", "Mew- Nya") + pick("!", "!!", "~!!", "!~", "", "", "", ""), forced = "felinid transformation")
			if (prob(2))
				affected_mob.visible_message(span_danger("[affected_mob] licks [affected_mob.p_their()] hand."))
			if (prob(1))
				affected_mob.visible_message(span_danger("[affected_mob] coughs out a furball."))
				to_chat(affected_mob, span_danger("You cough out a furball."))
		if(4)
			if (prob(10))
				affected_mob.say(pick("", ";", ".h")+pick("Nya", "MIAOW", "Ny- NYAAA", "meow", "NYAAA", "nya", "Ny- meow", "mrrrr", "Mew- Nya")+pick("!", "!!", "~!!", "!~", "", "", "", ""), forced = "felinid transformation")
			if (prob(1))
				affected_mob.visible_message(span_danger("[affected_mob] coughs out a furball."))
				to_chat(affected_mob, span_danger("You cough out a furball."))

/datum/disease/transformation/felinid/after_add()
	RegisterSignal(affected_mob, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/disease/transformation/felinid/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = " [message]"
		var/list/whole_words = strings(OWO_TALK_FILE, "wowds")
		var/list/owo_sounds = strings(OWO_TALK_FILE, "sounds")

		for(var/key in whole_words)
			var/value = whole_words[key]
			if(islist(value))
				value = pick(value)

			message = replacetextEx(message, " [uppertext(key)]", " [uppertext(value)]")
			message = replacetextEx(message, " [capitalize(key)]", " [capitalize(value)]")
			message = replacetextEx(message, " [key]", " [value]")

		for(var/key in owo_sounds)
			var/value = owo_sounds[key]
			if(islist(value))
				value = pick(value)

			message = replacetextEx(message, "[uppertext(key)]", "[uppertext(value)]")
			message = replacetextEx(message, "[capitalize(key)]", "[capitalize(value)]")
			message = replacetextEx(message, "[key]", "[value]")

		if(prob(3))
			message += pick(" Nya!"," Meow!"," OwO!!", " Nya-nya!")
	speech_args[SPEECH_MESSAGE] = trim(message)

/datum/disease/transformation/felinid/Destroy()
	UnregisterSignal(affected_mob, COMSIG_MOB_SAY)
	return ..()

/datum/disease/transformation/felinid/remove_disease()
	UnregisterSignal(affected_mob, COMSIG_MOB_SAY)
	return ..()

/datum/disease/transformation/felinid/contagious
	spread_text = "Blood, Fluids, Contact"
	is_mutagenic = TRUE //So that it won't be autocured after stage 5
	spread_flags = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_SKIN | DISEASE_SPREAD_CONTACT_FLUIDS

/datum/disease/transformation/felinid/contagious/form_mutagen(mob/living/affected_mob)
	if(ishuman(affected_mob))
		var/mob/living/carbon/human/affected_human = affected_mob
		if(iscatperson(affected_human))
			if (prob(10))
				affected_mob.say(pick("", ";", ".h")+pick("Nya", "MIAOW", "Ny- NYAAA", "meow", "NYAAA", "nya", "Ny- meow", "mrrrr", "Mew- Nya")+pick("!", "!!", "~!!", "!~", "", "", "", ""), forced = "felinid transformation")
			if (prob(3))
				affected_mob.visible_message(span_danger("[affected_mob] licks [affected_mob.p_their()] hand."))
			if (prob(1))
				affected_mob.visible_message(span_danger("[affected_mob] coughs out a furball."))
				to_chat(affected_mob, span_danger("You cough out a furball."))
			return
	affected_mob.reagents.add_reagent_list(list(/datum/reagent/mutationtoxin/felinid = 1, /datum/reagent/medicine/mutadone = 1))

/datum/disease/transformation/legion
	name = "Necropolis Infestation"
	cure_text = "The healing Vitrium Froth of some Lavaland flora"
	cures = list(/datum/reagent/consumable/vitfro)
	cure_chance = 10 //about 10 seconds/5 units of Froth to heal. Takes a decent gathering period but just shy of the amount that'll fatten you
	stage_prob = 5
	agent = "Legion droppings"
	desc = "Who knew that spreading the primordial goop of a vile entity would take a toll on the body?"
	danger = DISEASE_BIOHAZARD
	visibility_flags = 0
	stage1	= list("Your skin seems ashy.")
	stage2	= list("You wonder what it would be like to live on Lavaland forever...")
	stage3	= list(span_danger("You need darkness."), span_danger("You feel so cold..."), span_danger("Give in."))
	stage4	= list(span_userdanger("The planet's core calls to you... Lavaland is your home."), span_danger("A thousand voices beckon you to join them."))
	stage5	= list(span_userdanger("You have become one of Legion. You are one with the Necropolis now, and have no other loyalties. Serve well."))
	new_form = /mob/living/simple_animal/hostile/asteroid/hivelord/legion/tendril
	infectable_biotypes = list(MOB_ORGANIC, MOB_INORGANIC, MOB_UNDEAD)

/datum/disease/transformation/psyphoza
	name = "Acute Fungal Infection"
	cure_text = "Something that would kill off mold."
	spread_text = "Acute"
	disease_flags = CURABLE|CAN_CARRY|CAN_RESIST
	cures = list(/datum/reagent/space_cleaner, /datum/reagent/consumable/milk, /datum/reagent/toxin/plantbgone/weedkiller)
	cure_chance = 25
	stage_prob = 3
	agent = "Acute Fungal Infection"
	desc = "A system of fungus, taking over the host body."
	is_mutagenic = TRUE
	danger = DISEASE_BIOHAZARD
	visibility_flags = 0
	stage1	= list("You feel oddly fungal.")
	stage2	= list(span_danger("You head throbs."))
	stage3	= list(span_danger("Your vision dims briefly."))
	stage4	= list(span_danger("You sense something you can't see."))
	stage5	= list(span_danger("Your head sprouts a cap, and your eyes rupture."))
	infectable_biotypes = list(MOB_ORGANIC, MOB_INORGANIC, MOB_UNDEAD)
	new_form = /mob/living/carbon/human/species/psyphoza
