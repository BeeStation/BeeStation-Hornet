/datum/disease/transformation
	name = "Transformation"
	max_stages = 5
	spread_text = "Acute"
	spread_flags = DISEASE_SPREAD_SPECIAL
	cure_text = "A coder's love (theoretical)."
	agent = "Shenanigans"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey, /mob/living/carbon/alien)
	severity = DISEASE_SEVERITY_BIOHAZARD
	stage_prob = 10
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

/datum/disease/transformation/stage_act()
	..()
	switch(stage)
		if(1)
			if (prob(stage_prob) && stage1)
				to_chat(affected_mob, pick(stage1))
		if(2)
			if (prob(stage_prob) && stage2)
				to_chat(affected_mob, pick(stage2))
		if(3)
			if (prob(stage_prob*2) && stage3)
				to_chat(affected_mob, pick(stage3))
		if(4)
			if (prob(stage_prob*2) && stage4)
				to_chat(affected_mob, pick(stage4))
		if(5)
			if(is_mutagenic)	//we don't do it normally
				form_mutagen(affected_mob)
				return
			do_disease_transformation(affected_mob)

/datum/disease/transformation/proc/do_disease_transformation(mob/living/affected_mob)
	if(istype(affected_mob, /mob/living/carbon) && affected_mob.stat != DEAD)
		if(stage5)
			to_chat(affected_mob, pick(stage5))
		if(QDELETED(affected_mob))
			return
		if(affected_mob.notransform)
			return
		affected_mob.notransform = 1
		for(var/obj/item/W in affected_mob.get_equipped_items(TRUE))
			affected_mob.dropItemToGround(W)
		for(var/obj/item/I in affected_mob.held_items)
			affected_mob.dropItemToGround(I)
		var/mob/living/new_mob = new new_form(affected_mob.loc)
		if(istype(new_mob))
			if(bantype && is_banned_from(affected_mob.ckey, bantype))
				replace_banned_player(new_mob)
			new_mob.a_intent = INTENT_HARM
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

	var/list/mob/dead/observer/candidates = pollCandidatesForMob("Do you want to play as [affected_mob.name]?", bantype, null, bantype, 50, affected_mob)
	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		to_chat(affected_mob, "Your mob has been taken over by a ghost! Appeal your job ban if you want to avoid this in the future!")
		message_admins("[key_name_admin(C)] has taken control of ([key_name_admin(affected_mob)]) to replace a jobbanned player.")
		affected_mob.ghostize(0)
		affected_mob.key = C.key
	else
		to_chat(new_mob, "Your mob has been claimed by death! Appeal your job ban if you want to avoid this in the future!")
		new_mob.death()
		if (!QDELETED(new_mob))
			new_mob.ghostize(can_reenter_corpse = FALSE)
			new_mob.key = null

/datum/disease/transformation/jungle_fever
	name = "Jungle Fever"
	cure_text = "Death."
	cures = list(/datum/reagent/medicine/adminordrazine)
	spread_text = "Monkey Bites"
	spread_flags = DISEASE_SPREAD_SPECIAL
	viable_mobtypes = list(/mob/living/carbon/monkey, /mob/living/carbon/human)
	permeability_mod = 1
	cure_chance = 1
	disease_flags = CAN_CARRY|CAN_RESIST
	desc = "Monkeys with this disease will bite humans, causing humans to mutate into a monkey."
	severity = DISEASE_SEVERITY_BIOHAZARD
	stage_prob = 4
	visibility_flags = 0
	agent = "Kongey Vibrion M-909"
	new_form = null
	bantype = ROLE_MONKEY


	stage1	= list()
	stage2	= list()
	stage3	= list()
	stage4	= list("<span class='warning'>Your back hurts.</span>", "<span class='warning'>You breathe through your mouth.</span>",
					"<span class='warning'>You have a craving for bananas.</span>", "<span class='warning'>Your mind feels clouded.</span>")
	stage5	= list("<span class='warning'>You feel like monkeying around.</span>")

/datum/disease/transformation/jungle_fever/do_disease_transformation(mob/living/carbon/affected_mob)
	if(affected_mob.mind && !is_monkey(affected_mob.mind))
		add_monkey(affected_mob.mind)
	if(ishuman(affected_mob))
		if(affected_mob && !is_monkey_leader(affected_mob.mind))
			var/mob/living/carbon/monkey/M = affected_mob.monkeyize(TR_KEEPITEMS | TR_KEEPIMPLANTS | TR_KEEPORGANS | TR_KEEPDAMAGE | TR_KEEPVIRUS | TR_KEEPSE)
			M.ventcrawler = VENTCRAWLER_ALWAYS
		else
			affected_mob.junglegorillize()

/datum/disease/transformation/jungle_fever/stage_act()
	..()
	switch(stage)
		if(2)
			if(prob(2))
				to_chat(affected_mob, "<span class='notice'>Your [pick("back", "arm", "leg", "elbow", "head")] itches.</span>")
		if(3)
			if(prob(4))
				to_chat(affected_mob, "<span class='danger'>You feel a stabbing pain in your head.</span>")
				affected_mob.confused += 10
		if(4)
			if(prob(3))
				affected_mob.say(pick("Eeek, ook ook!", "Eee-eeek!", "Eeee!", "Ungh, ungh."), forced = "jungle fever")

/datum/disease/transformation/jungle_fever/cure()
	remove_monkey(affected_mob.mind)
	..()

/datum/disease/transformation/jungle_fever/monkeymode
	visibility_flags = HIDDEN_SCANNER|HIDDEN_PANDEMIC
	disease_flags = CAN_CARRY //no vaccines! no cure!

/datum/disease/transformation/jungle_fever/monkeymode/after_add()
	if(affected_mob && !is_monkey_leader(affected_mob.mind))
		visibility_flags = NONE



/datum/disease/transformation/robot

	name = "Robotic Transformation"
	cure_text = "An injection of copper."
	cures = list(/datum/reagent/copper)
	cure_chance = 5
	agent = "R2D2 Nanomachines"
	desc = "This disease, actually acute nanomachine infection, converts the victim into a cyborg."
	severity = DISEASE_SEVERITY_BIOHAZARD
	visibility_flags = 0
	stage1	= list()
	stage2	= list("Your joints feel stiff.", "<span class='danger'>Beep...boop..</span>")
	stage3	= list("<span class='danger'>Your joints feel very stiff.</span>", "Your skin feels loose.", "<span class='danger'>You can feel something move...inside.</span>")
	stage4	= list("<span class='danger'>Your skin feels very loose.</span>", "<span class='danger'>You can feel... something...inside you.</span>")
	stage5	= list("<span class='danger'>Your skin feels as if it's about to burst off!</span>")
	new_form = /mob/living/silicon/robot
	infectable_biotypes = list(MOB_ORGANIC, MOB_UNDEAD, MOB_ROBOTIC)
	bantype = "Cyborg"

/datum/disease/transformation/robot/stage_act()
	..()
	switch(stage)
		if(3)
			if (prob(8))
				affected_mob.say(pick("Beep, boop", "beep, beep!", "Boop...bop"), forced = "robotic transformation")
			if (prob(4))
				to_chat(affected_mob, "<span class='danger'>You feel a stabbing pain in your head.</span>")
				affected_mob.Unconscious(40)
		if(4)
			if (prob(20))
				affected_mob.say(pick("beep, beep!", "Boop bop boop beep.", "kkkiiiill mmme", "I wwwaaannntt tttoo dddiiieeee..."), forced = "robotic transformation")


/datum/disease/transformation/xeno

	name = "Xenomorph Transformation"
	cure_text = "Spaceacillin & Glycerol"
	cures = list(/datum/reagent/medicine/spaceacillin, /datum/reagent/glycerol)
	cure_chance = 5
	agent = "Rip-LEY Alien Microbes"
	desc = "This disease changes the victim into a xenomorph."
	severity = DISEASE_SEVERITY_BIOHAZARD
	visibility_flags = 0
	stage1	= list()
	stage2	= list("Your throat feels scratchy.", "<span class='danger'>Kill...</span>")
	stage3	= list("<span class='danger'>Your throat feels very scratchy.</span>", "Your skin feels tight.", "<span class='danger'>You can feel something move...inside.</span>")
	stage4	= list("<span class='danger'>Your skin feels very tight.</span>", "<span class='danger'>Your blood boils!</span>", "<span class='danger'>You can feel... something...inside you.</span>")
	stage5	= list("<span class='danger'>Your skin feels as if it's about to burst off!</span>")
	new_form = /mob/living/carbon/alien/humanoid/hunter
	bantype = ROLE_ALIEN

/datum/disease/transformation/xeno/stage_act()
	..()
	switch(stage)
		if(3)
			if (prob(4))
				to_chat(affected_mob, "<span class='danger'>You feel a stabbing pain in your head.</span>")
				affected_mob.Unconscious(40)
		if(4)
			if (prob(20))
				affected_mob.say(pick("You look delicious.", "Going to... devour you...", "Hsssshhhhh!"), forced = "xenomorph transformation")


/datum/disease/transformation/slime
	name = "Advanced Mutation Transformation"
	cure_text = "frost oil"
	cures = list(/datum/reagent/consumable/frostoil)
	cure_chance = 80
	agent = "Advanced Mutation Toxin"
	desc = "This highly concentrated extract converts anything into more of itself."
	severity = DISEASE_SEVERITY_BIOHAZARD
	visibility_flags = 0
	stage1	= list("You don't feel very well.")
	stage2	= list("Your skin feels a little slimy.")
	stage3	= list("<span class='danger'>Your appendages are melting away.</span>", "<span class='danger'>Your limbs begin to lose their shape.</span>")
	stage4	= list("<span class='danger'>You are turning into a slime.</span>")
	stage5	= list("<span class='danger'>You have become a slime.</span>")
	new_form = /mob/living/simple_animal/slime/random

/datum/disease/transformation/slime/stage_act()
	..()
	switch(stage)
		if(1)
			if(ishuman(affected_mob) && affected_mob.dna)
				if(affected_mob.dna.species.id == "slime" || affected_mob.dna.species.id == "stargazer" || affected_mob.dna.species.id == "lum")
					stage = 5
		if(3)
			if(ishuman(affected_mob))
				var/mob/living/carbon/human/human = affected_mob
				if(human.dna.species.id != "slime" && affected_mob.dna.species.id != "stargazer" && affected_mob.dna.species.id != "lum")
					human.set_species(/datum/species/jelly/slime)

/datum/disease/transformation/corgi
	name = "The Barkening"
	cure_text = "Death"
	cures = list(/datum/reagent/medicine/adminordrazine)
	agent = "Fell Doge Majicks"
	desc = "This disease transforms the victim into a corgi."
	severity = DISEASE_SEVERITY_BIOHAZARD
	visibility_flags = 0
	stage1	= list("BARK.")
	stage2	= list("You feel the need to wear silly hats.")
	stage3	= list("<span class='danger'>Must... eat... chocolate....</span>", "<span class='danger'>YAP</span>")
	stage4	= list("<span class='danger'>Visions of washing machines assail your mind!</span>")
	stage5	= list("<span class='danger'>AUUUUUU!!!</span>")
	new_form = /mob/living/simple_animal/pet/dog/corgi

/datum/disease/transformation/corgi/stage_act()
	..()
	switch(stage)
		if(3)
			if (prob(8))
				affected_mob.say(pick("YAP", "Woof!"), forced = "corgi transformation")
		if(4)
			if (prob(20))
				affected_mob.say(pick("Bark!", "AUUUUUU"), forced = "corgi transformation")

/datum/disease/transformation/morph
	name = "Gluttony's Blessing"
	cure_text = /datum/reagent/consumable/nothing
	cures = list(/datum/reagent/medicine/adminordrazine)
	agent = "Gluttony's Blessing"
	desc = "A 'gift' from somewhere terrible."
	stage_prob = 20
	severity = DISEASE_SEVERITY_BIOHAZARD
	visibility_flags = 0
	stage1	= list("Your stomach rumbles.")
	stage2	= list("Your skin feels saggy.")
	stage3	= list("<span class='danger'>Your appendages are melting away.</span>", "<span class='danger'>Your limbs begin to lose their shape.</span>")
	stage4	= list("<span class='danger'>You're ravenous.</span>")
	stage5	= list("<span class='danger'>You have become a morph.</span>")
	new_form = /mob/living/simple_animal/hostile/morph
	infectable_biotypes = list(MOB_ORGANIC, MOB_INORGANIC, MOB_UNDEAD) //magic!

/datum/disease/transformation/gondola
	name = "Gondola Transformation"
	cure_text = "Condensed Capsaicin, ingested or injected." //getting pepper sprayed doesn't help
	cures = list(/datum/reagent/consumable/condensedcapsaicin) //beats the hippie crap right out of your system
	cure_chance = 80
	stage_prob = 5
	agent = "Tranquility"
	desc = "Consuming the flesh of a Gondola comes at a terrible price."
	severity = DISEASE_SEVERITY_BIOHAZARD
	visibility_flags = 0
	stage1	= list("You seem a little lighter in your step.")
	stage2	= list("You catch yourself smiling for no reason.")
	stage3	= list("<span class='danger'>A cruel sense of calm overcomes you.</span>", "<span class='danger'>You can't feel your arms!</span>", "<span class='danger'>You let go of the urge to hurt clowns.</span>")
	stage4	= list("<span class='danger'>You can't feel your arms. It does not bother you anymore.</span>", "<span class='danger'>You forgive the clown for hurting you.</span>")
	stage5	= list("<span class='danger'>You have become a Gondola.</span>")
	new_form = /mob/living/simple_animal/pet/gondola

/datum/disease/transformation/gondola/stage_act()
	..()
	switch(stage)
		if(2)
			if (prob(5))
				affected_mob.emote("smile")
			if (prob(20))
				affected_mob.reagents.add_reagent_list(list(/datum/reagent/pax = 5))
		if(3)
			if (prob(5))
				affected_mob.emote("smile")
			if (prob(20))
				affected_mob.reagents.add_reagent_list(list(/datum/reagent/pax = 5))
		if(4)
			if (prob(5))
				affected_mob.emote("smile")
			if (prob(20))
				affected_mob.reagents.add_reagent_list(list(/datum/reagent/pax = 5))
			if (prob(2))
				to_chat(affected_mob, "<span class='danger'>You let go of what you were holding.</span>")
				var/obj/item/I = affected_mob.get_active_held_item()
				affected_mob.dropItemToGround(I)

/datum/disease/transformation/felinid
	name = "Nano-Feline Assimilative Toxoplasmosis"
	cure_text = "Something that would kill off the tiny cats." 
	spread_text = "Acute"
	disease_flags = CURABLE|CAN_CARRY|CAN_RESIST
	cures = list(/datum/reagent/consumable/coco) //kills all the tiny cats that infected your organism
	cure_chance = 25
	stage_prob = 3
	agent = "Nano-feline Toxoplasmosis"
	desc = "A lot of tiny cats in the blood that slowly turn you into a big cat."
	is_mutagenic = TRUE //So that it won't be autocured after stage 5
	severity = DISEASE_SEVERITY_BIOHAZARD
	visibility_flags = 0
	stage1	= list("You feel scratching fom within.", "You hear a faint miaow somewhere really close.")
	stage2	= list("<span class='danger'>You suppress the urge to lick yourself.</span>")
	stage3	= list("<span class='danger'>You feel the need to cough out something fluffy.</span>", "<span class='danger'>You feel the need to scratch your neck with your foot.</span>", "<span class='danger'>You think you should adopt a cat.</span>")
	stage4	= list("<span class='danger'>You start thinking that felinids are not that bad after all!</span>", "<span class='danger'>You feel scared at the thought of eating chocolate.</span>")
	stage5	= list("<span class='danger'>You have become a catperson.</span>")
	infectable_biotypes = list(MOB_ORGANIC, MOB_INORGANIC, MOB_UNDEAD) //Nothing evades the curse!
	new_form = /mob/living/carbon/human/species/felinid

/datum/disease/transformation/felinid/stage_act()
	..()
	switch(stage)
		if(2)
			if (prob(1))
				affected_mob.visible_message("<span class='danger'>[affected_mob] licks [affected_mob.p_their()] hand.</span>")
		if(3)
			if (prob(8))
				affected_mob.say(pick("Nya", "MIAOW", "Ny- NYAAA", "meow", "NYAAA", "nya", "Ny- meow", "mrrrr", "Mew- Nya") + pick("!", "!!", "~!!", "!~", "", "", "", ""), forced = "felinid transformation")
			if (prob(2))
				affected_mob.visible_message("<span class='danger'>[affected_mob] licks [affected_mob.p_their()] hand.</span>")
			if (prob(1))
				affected_mob.visible_message("<span class='danger'>[affected_mob] coughs out a furball.</span>")
				to_chat(affected_mob, "<span class='danger'>You cough out a furball.</span>")
		if(4)
			if (prob(10))
				affected_mob.say(pick("", ";", ".h")+pick("Nya", "MIAOW", "Ny- NYAAA", "meow", "NYAAA", "nya", "Ny- meow", "mrrrr", "Mew- Nya")+pick("!", "!!", "~!!", "!~", "", "", "", ""), forced = "felinid transformation")
			if (prob(1))
				affected_mob.visible_message("<span class='danger'>[affected_mob] coughs out a furball.</span>")
				to_chat(affected_mob, "<span class='danger'>You cough out a furball.</span>")

/datum/disease/transformation/felinid/after_add()
	RegisterSignal(affected_mob, COMSIG_MOB_SAY, .proc/handle_speech)

/datum/disease/transformation/felinid/proc/handle_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = " [message]"
		var/list/whole_words = strings("owo_talk.json", "wowds")
		var/list/owo_sounds = strings("owo_talk.json", "sounds")

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
				affected_mob.visible_message("<span class='danger'>[affected_mob] licks [affected_mob.p_their()] hand.</span>")
			if (prob(1))
				affected_mob.visible_message("<span class='danger'>[affected_mob] coughs out a furball.</span>")
				to_chat(affected_mob, "<span class='danger'>You cough out a furball.</span>")
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
	severity = DISEASE_SEVERITY_BIOHAZARD
	visibility_flags = 0
	stage1	= list("Your skin seems ashy.")
	stage2	= list("You wonder what it would be like to live on Lavaland forever...")
	stage3	= list("<span class='danger'>You need darkness.</span>", "<span class='danger'>You feel so cold...</span>", "<span class='danger'>Give in.</span>")
	stage4	= list("<span class='userdanger'>The planet's core calls to you... Lavaland is your home.</span>", "<span class='danger'>A thousand voices beckon you to join them.</span>")
	stage5	= list("<span class='userdanger'>You have become one of Legion. You are one with the Necropolis now, and have no other loyalties. Serve well.</span>")
	new_form = /mob/living/simple_animal/hostile/asteroid/hivelord/legion/tendril
	infectable_biotypes = list(MOB_ORGANIC, MOB_INORGANIC, MOB_UNDEAD)
