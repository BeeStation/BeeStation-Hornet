/*
////////////////////////////////////////
//				MKULTA				  //
////////////////////////////////////////
The magnum opus of FermiChem -
Long and complicated, I highly recomend you look at the two other files heavily involved in this
modular_citadel/code/datums/status_effects/chems.dm - handles the subject's reactions
code/modules/surgery/organs/vocal_cords.dm - handles the enchanter speaking

HOW IT WORKS
Fermis_Reagent.dm
There's 3 main ways this chemical works; I'll start off with discussing how it's set up.
Upon reacting with blood as a catalyst, the blood is used to define who the enthraller is - thus only the creator is/can choose who the master will be. As a side note, you can't adminbus this chem, even admins have to earn it.
This uses the fermichem only proc; FermiCreate, which is basically the same as On_new, except it doesn't require "data" which is something to do with blood and breaks everything so I said bugger it and made my own proc. It basically sets up vars.
When it's first made, the creator has to drink some of it, in order to give them the vocal chords needed.
When it's given to someone, it gives them the status effect and kicks off that side of things. For every metabolism tick, it increases the enthrall tally.
Finally, if you manage to pump 100u into some poor soul, you overload them, and mindbreak them. Making them your willing, but broken slave. Which can only be reversed by; fixing their brain with mannitol and neurine (100 / 50u respectively) (or less with both),

vocal_cords.dm
This handles when the enchanter speaks - basically uses code from voice of god, but only for people with the staus effect. Most of the words are self explainitory, and has a smaller range of commands. If you're not sure what one does, it likely affects the enthrall tally, or the resist tally.
list of commands:

-mixables-
enthral_words
reward_words
punish_words
0
saymyname_words
wakeup_words
1
silence_words
antiresist_words
resist_words
forget_words
attract_words
orgasm_words
2
awoo_words
nya_words
sleep_words
strip_words
walk_words
run_words
knockdown_words
3
statecustom_words
custom_words
objective_words
heal_words
stun_words
hallucinate_words
hot_words
cold_words
getup_words
pacify_words
charge_words

Mixables can be used intersperced with other commands, 0 is commands that work on sleeper against (i.e. players enthralled to state 3, then ordered to wake up and forget, they can be triggered back instantly)
1 is for players who immediately are injected with the chem - no stuns, only a silence and something that draws them towrds them. This is the best time to try to fight it and you're likely to win by spamming resist, unless the enchantress has plans.
2 is the seconds stage, which allows removal of clothes, slowdown and light stunning. You can also make them nya and awoo, because cute.
3 is the finaly state, which allows application of a few status effects (see chem.dm) and allows custom triggers to be installed (kind of like nanites), again, see chem.dm
In a nutshell, this is the way you enthrall people, by typing messages into chat and managing cooldowns on the stronger words. You have to type words and your message strength is increases with the number of characters - if you type short messages the cooldown will be too much and the other player will overcome the chem.
I suppose people could spam gdjshogndjoadphgiuaodp but, the truth of this chem is that it mostly allows a casus beli for subs to give in, and everyones a sub on cit (mostly), so if you aujigbnadjgipagdsjk then they might resist harder cause you're a baddie and baddies don't deserve pets.
Also, the use of this chem as a murder aid is antithetic to it's design, the subject gains bonus resistance if they're hurt or hungry (I'd like to expland this more, I like the idea that you have to look after all of them otherwise they aren't as effective, kind of like tamagachis!). If this becomes a problem, I'll deal with it, I'm not happy with people abusing this chem for an easy murder. (I might make it so you an't strike your pet when health is too low.)
Additionaly, in lieu of previous statement - the pet is ordered to not kill themselves, even if ordered to.

chem.dm
oof
There's a few basic things that have to be understood with this status effect
1. There is a min loop which calculates the enthrall state of the subject, when the entrall tally is over a certain amount, it will push you up 1 phase.
0 - Sleeper
1 - initial
2 - enthralled
3 - Fully entranced
4 - mindbroken
4 can only be reached via OD, whereas you can increment up from 1 > 2 > 3. 0 is only obtainable on a state 3 pet, and it toggles between the two.

1.5 Chem warfare
Since this is a chem, it's expected that you will use all of the chemicals at your disposal. Using aphro and aphro+ will weaken the resistance of the subject, while ananphro, anaphro+, mannitol and neurine will strengthen it.
Additionally, the more aroused you are, the weaker your resistance will be, as a result players immune to aphro and anaphro give a flat bonus to the enthraller.
using furranium and hatmium on the enchanter weakens their power considerably, because they sound rediculous. "Youwe fweewing wery sweepy uwu" This completely justifies their existance.
The impure toxin for this chem increases resistance too, so if they're a bad chemist it'll be unlikely they have a good ratio (and as a secret bonus, really good chemists cann purposely make the impure chem, to use either to combat the use of it against them, or as smoke grenades to deal with a large party)

2. There is a resistance proc which occurs whenever the player presses resist. You have to press it a lot, this is intentional. If you're trying to fight the enchanter, then you can't click both. You usually will win if you just mash resist and the enchanter does nothing, so you've got to react.
Each step futher it becomes harder to resist, in state 2 it's longer, but resisting is still worthwhile. If you're not in state 3, and you've not got MKultra inside of you, you generate resistance very fast. So in some cases the better option will be to stall out any attempts to entrance you.
At the moment, resistance doesn't affect the commands - mostly because it's a way to tell if a state 3 is trying to resist. But this might change if it gets too hard to fight them off.
Durign state 3, it's impossible to resist if the enthraller is in your presence (8 tiles), you generate no resistance if so. If they're out of your range, then you start to go into the addiction processed
As your resistance is tied to your arousal, sometimes your best option is to wah

3. The addition process starts when the enthraller is out of range, it roughtly follows the five stages of grief; denial, anger, bargaining, depression and acceptance.
What it mostly does makes you sad, hurts your brain, and sometimes you lash out in anger.
Denial - minor brain damaged
bargaining - 50:50 chance of brain damage and brain healing
anger - randomly lashing out and hitting people
depression - massive mood loss, stuttering, jittering, hallucinations and brain damage
depression, again - random stunning and crying, brain damage, and resistance
acceptance - minor brain damage and resistance.
You can also resist while out of range, but you can only break free of a stange 3 enthrallment by hitting the acceptance phase with a high enough resistance.
Finally, being near your enthraller reverts the damages caused.
It is expected that if you intend to break free you'll need to use psicodine and mannitol or you'll end up in a bad, but not dead, state. This gives more work for medical!! Finally the true rational of this complicated chem comes out.

4. Status effects in status effects.
There's a few commands that give status effects, such as antiresist, which will cause resistance presses to increase the enthrallment instead, theses are called from the vocal chords.
They're mostly self explainitory; antiresist, charge, pacify and heal. Heals quite weak for obvious reasons. I'd like to add more, maybe some weak adneals with brute/exhaustion costs after the status is over. A truth serum might be neat too.
State 4 pets don't get status effects.

5. Custom triggers
Because it wasnt complicated enough already.
Custom triggers are set by stating a trigger word, which will call a sub proc, which is also defined when the trigger is Called
The effects avalible at the moment are:
Speak - forces pet to say a preallocated phrase in response to the trigger
Echo - sends a message to that player only (i.e. makes them think something)
Shock - gives them a seizure/zaps them
You can look this one up yourself - it's what you expect, it's cit
kneel - gives a short knockdown
strip - strips jumpsuit only
objective - gives the pet a new objective. This requires a high ammount of mental capasity - which is determined by how much you resist. If you resist enough during phase 1 and 2, then they can't give you an objective.
Feel free to add more.
triggers work when said by ANYONE, not just the enchanter.
This is only state 3 pets, state 4 pets cannot get custom triggers, you broke them you bully.

7. If you're an antage you get a bonus to resistance AND to enthralling. Thus it can be worth using this on both sides. It shouldn't be hard to resist as an antag. There are futher bonuses to command, Chaplains and chemist.
If you give your pet a collar then their resistance reduced too.
(I think thats everything?)

Failstates:
Blowing up the reaction produces a gas that causes everyone to fall in love with one another.

Creating a chem with a low purity will make you permanently fall in love with someone, and tasked with keeping them safe. If someone else drinks it, you fall for them.
*/

/datum/reagent/fermi/enthrall
	name = "MKUltra"
	description = "A forbidden deep red mixture that increases a person's succeptability to another's words. When taken by the creator, it will enhance the draw of their voice to those affected by it."
	color = "#660015" // rgb: , 0, 255
	taste_description = "synthetic chocolate, a base tone of alcohol, and high notes of roses"
	overdose_threshold = 100 //If this is too easy to get 100u of this, then double it please.
	metabolization_rate = 0.1//It has to be slow, so there's time for the effect.
	data = list("creatorID" = null, "creatorGender" = null, "creatorName" = null)
	var/creatorID  //ckey
	var/creatorGender
	var/creatorName
	var/mob/living/creator
	pH = 10
	chemical_flags = REAGENT_ONMOBMERGE | REAGENT_DONOTSPLIT //Procs on_mob_add when merging into a human
	can_synth = FALSE


/datum/reagent/fermi/enthrall/test
	name = "MKUltraTest"
	description = "A forbidden deep red mixture that makes you like Fermis a little too much. Unobtainable and due to be removed from the wiki."
	data = list("creatorID" = "honkatonkbramblesnatch", "creatorGender" = "Mistress", "creatorName" = "Fermis Yakumo")
	creatorID  = "honkatonkbramblesnatch"//ckey
	creatorGender = "Mistress"
	creatorName = "Fermis Yakumo"
	purity = 1

/datum/reagent/fermi/enthrall/test/on_new()
	..()
	creator = get_mob_by_key(creatorID)

/datum/reagent/fermi/enthrall/on_new(list/data)
	creatorID = data["creatorID"]
	creatorGender = data["creatorGender"]
	creatorName = data["creatorName"]
	creator = get_mob_by_key(creatorID)

/datum/reagent/fermi/enthrall/on_mob_add(mob/living/carbon/M)
	. = ..()
	if(M.client?.prefs.cit_toggles & NEVER_HYPNO) // Just in case people are opting out of this
		holder.del_reagent(type)
		return
	if(!ishuman(M))//Just to make sure screwy stuff doesn't happen.
		return
	if(!creatorID)
		//This happens when the reaction explodes.
		return
	if(purity < 0.5)//Impure chems don't function as you expect
		return
	var/datum/status_effect/chem/enthrall/E = M.has_status_effect(/datum/status_effect/chem/enthrall)
	if(E)
		if(E.enthrallID == M.ckey && creatorID != M.ckey)//If you're enthralled to yourself (from OD) and someone else tries to enthrall you, you become thralled to them instantly.
			E.enthrallID = creatorID
			E.enthrallGender = creatorGender
			E.master = get_mob_by_key(creatorID)
			to_chat(M, "<span class='big love'><i>Your addled, plastic, mind bends under the chemical influence of a new [(E.lewd?"master":"leader")]. Your highest priority is now to stay by [creatorName]'s side, following and aiding them at all costs.</i></span>") //THIS SHOULD ONLY EVER APPEAR IF YOU MINDBREAK YOURSELF AND THEN GET INJECTED FROM SOMEONE ELSE.
			log_game("FERMICHEM: Narcissist [M] ckey: [M.key] been rebound to [creatorName], ID: [creatorID]")
			return
	if((M.ckey == creatorID) && (creatorName == M.real_name)) //same name AND same player - same instance of the player. (should work for clones?)
		log_game("FERMICHEM: [M] ckey: [M.key] has been given velvetspeech")
		var/obj/item/organ/vocal_cords/Vc = M.getorganslot(ORGAN_SLOT_VOICE)
		var/obj/item/organ/vocal_cords/nVc = new /obj/item/organ/vocal_cords/velvet
		if(Vc)
			Vc.Remove(M)
		nVc.Insert(M)
		qdel(Vc)
		to_chat(M, "<span class='notice'><i>You feel your vocal chords tingle you speak in a more charasmatic and sultry tone.</i></span>")
	else
		log_game("FERMICHEM: MKUltra: [creatorName], [creatorID], is enthralling [M.name], [M.ckey]")
		M.apply_status_effect(/datum/status_effect/chem/enthrall)
	log_game("FERMICHEM: [M] ckey: [M.key] has taken MKUltra")

/datum/reagent/fermi/enthrall/on_mob_life(mob/living/carbon/M)
	. = ..()
	if(purity < 0.5)//DO NOT SPLIT INTO DIFFERENT CHEM: This relies on DoNotSplit - has to be done this way.

		if (M.ckey == creatorID && creatorName == M.real_name)//If the creator drinks it, they fall in love randomly. If someone else drinks it, the creator falls in love with them.
			if(M.has_status_effect(STATUS_EFFECT_INLOVE))//Can't be enthralled when enthralled, so to speak.
				return
			var/list/seen = viewers(7, get_turf(M))
			for(var/victim in seen)
				if(ishuman(victim))
					var/mob/living/carbon/V = victim
					if((V == M) || (!V.client) || (V.stat == DEAD))
						seen = seen - victim
				else
					seen = seen - victim

			if(LAZYLEN(seen))
				return
			M.reagents.del_reagent(type)
			FallInLove(M, pick(seen))
			return

		else // If someone else drinks it, the creator falls in love with them!
			var/mob/living/carbon/C = get_mob_by_key(creatorID)
			if(M.has_status_effect(STATUS_EFFECT_INLOVE))
				return
			if((C in viewers(7, get_turf(M))) && (C.client))
				M.reagents.del_reagent(type)
				FallInLove(C, M)
			return
	if (M.ckey == creatorID && creatorName == M.real_name)//If you yourself drink it, it supresses the vocal effects, for stealth. NEVERMIND ADD THIS LATER I CAN'T GET IT TO WORK
		return
	if(!M.client)
		metabolization_rate = 0 //Stops powergamers from quitting to avoid affects. but prevents affects on players that don't exist for performance.
		return
	if(metabolization_rate == 0)
		metabolization_rate = 0.1
	var/datum/status_effect/chem/enthrall/E = M.has_status_effect(/datum/status_effect/chem/enthrall)//If purity is over 5, works as intended
	if(!E)
		return
	else
		E.enthrallTally += 1
	..()

/datum/reagent/fermi/enthrall/overdose_start(mob/living/carbon/M)//I made it so the creator is set to gain the status for someone random.
	. = ..()
	metabolization_rate = 1//Mostly to manage brain damage and reduce server stress
	if (M.ckey == creatorID && creatorName == M.real_name)//If the creator drinks 100u, then you get the status for someone random (They don't have the vocal chords though, so it's limited.)
		if (!M.has_status_effect(/datum/status_effect/chem/enthrall))
			to_chat(M, "<span class='love'><i>You are unable to resist your own charms anymore, and become a full blown narcissist.</i></span>")
	ADD_TRAIT(M, TRAIT_PACIFISM, "MKUltra")
	var/datum/status_effect/chem/enthrall/E
	if (!M.has_status_effect(/datum/status_effect/chem/enthrall))
		M.apply_status_effect(/datum/status_effect/chem/enthrall)
		E = M.has_status_effect(/datum/status_effect/chem/enthrall)
		E.enthrallID = creatorID
		E.enthrallGender = creatorGender
		E.master = creator
	else
		E = M.has_status_effect(/datum/status_effect/chem/enthrall)
	if(E.lewd)
		to_chat(M, "<span class='big love'><i>Your mind shatters under the volume of the mild altering chem inside of you, breaking all will and thought completely. Instead the only force driving you now is the instinctual desire to obey and follow [creatorName]. Your highest priority is now to stay by their side and protect them at all costs.</i></span>")
	else
		to_chat(M, "<span class='big warning'><i>The might volume of chemicals in your system overwhelms your mind, and you suddenly agree with what [creatorName] has been saying. Your highest priority is now to stay by their side and protect them at all costs.</i></span>")
	log_game("FERMICHEM: [M] ckey: [M.key] has been mindbroken for [creatorName] ckey: [creatorID]")
	M.slurring = 100
	M.confused = 100
	E.phase = 4
	E.mental_capacity = 0
	E.customTriggers = list()
	SSblackbox.record_feedback("tally", "fermi_chem", 1, "Thralls mindbroken")

/datum/reagent/fermi/enthrall/overdose_process(mob/living/carbon/M)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.2)//should be ~30 in total
	..()

//Creates a gas cloud when the reaction blows up, causing everyone in it to fall in love with someone/something while it's in their system.
/datum/reagent/fermi/enthrallExplo//Created in a gas cloud when it explodes
	name = "Gaseous MKUltra"
	description = "A forbidden deep red gas that overwhelms a foreign body, causing the person they next lay their eyes on to become more interesting. Studies have shown that people are 66% more likely to make friends with this in the air. Produced when MKUltra explodes."
	color = "#2C051A" // rgb: , 0, 255
	metabolization_rate = 0.1
	taste_description = "synthetic chocolate, a base tone of alcohol, and high notes of roses."
	chemical_flags = REAGENT_DONOTSPLIT
	can_synth = FALSE
	var/mob/living/carbon/love
	var/lewd = FALSE

/datum/reagent/fermi/enthrallExplo/on_mob_life(mob/living/carbon/M)//Love gas, only affects while it's in your system,Gives a positive moodlet if close, gives brain damagea and a negative moodlet if not close enough.
	if(HAS_TRAIT(M, TRAIT_MINDSHIELD))
		return ..()
	if(!M.has_status_effect(STATUS_EFFECT_INLOVE))
		var/list/seen = viewers(7, get_turf(M))//Sound and sight checkers
		for(var/victim in seen)
			if((istype(victim, /mob/living/simple_animal/pet/)) || (victim == M) || (M.stat == DEAD) || (!isliving(victim)))
				seen = seen - victim
		if(seen.len == 0)
			return
		love = pick(seen)
		if(!love)
			return
		M.apply_status_effect(STATUS_EFFECT_INLOVE, love)
		lewd = (M.client?.prefs.cit_toggles & HYPNO) && (love.client?.prefs.cit_toggles & HYPNO)
		to_chat(M, "[(lewd?"<span class='love'>":"<span class='warning'>")][(lewd?"You develop a sudden crush on [love], your heart beginning to race as you look upon them with new eyes.":"You suddenly feel like making friends with [love].")] You feel strangely drawn towards them.</span>")
		log_game("FERMICHEM: [M] ckey: [M.key] has temporarily bonded with [love] ckey: [love.key]")
		SSblackbox.record_feedback("tally", "fermi_chem", 1, "Times people have bonded")
	else
		if(get_dist(M, love) < 8)
			var/message = "[(lewd?"I'm next to my crush..! Eee!":"I'm making friends with [love]!")]"
			SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "InLove", /datum/mood_event/InLove, message)
			SEND_SIGNAL(M, COMSIG_CLEAR_MOOD_EVENT, "MissingLove")
		else
			var/message = "[(lewd?"I can't keep my crush off my mind, I need to see them again!":"I really want to make friends with [love]!")]"
			SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "MissingLove", /datum/mood_event/MissingLove, message)
			SEND_SIGNAL(M, COMSIG_CLEAR_MOOD_EVENT, "InLove")
			if(prob(5))
				M.Stun(10)
				M.emote("whimper")//does this exist?
				to_chat(M, "[(lewd?"<span class='love'>":"<span class='warning'>")] You're overcome with a desire to see [love].</span>")
				M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.5)//I found out why everyone was so damaged!
	..()

/datum/reagent/fermi/enthrallExplo/on_mob_delete(mob/living/carbon/M)
	if(HAS_TRAIT(M, TRAIT_MINDSHIELD))
		return ..()
	M.remove_status_effect(STATUS_EFFECT_INLOVE)
	SEND_SIGNAL(M, COMSIG_CLEAR_MOOD_EVENT, "InLove")
	SEND_SIGNAL(M, COMSIG_CLEAR_MOOD_EVENT, "MissingLove")
	to_chat(M, "[(lewd?"<span class='love'>":"<span class='warning'>")]Your feelings for [love] suddenly vanish!")
	log_game("FERMICHEM: [M] ckey: [M.key] is no longer in temp bond")
	..()

/datum/reagent/fermi/proc/FallInLove(mob/living/carbon/Lover, mob/living/carbon/Love)
	if(Lover.has_status_effect(STATUS_EFFECT_INLOVE))
		to_chat(Lover, "<span class='warning'>You are already fully devoted to someone else!</span>")
		return
	var/lewd = (Lover.client?.prefs.cit_toggles & HYPNO) && (Love.client?.prefs.cit_toggles & HYPNO)
	to_chat(Lover, "[(lewd?"<span class='love'>":"<span class='warning'>")]You develop a deep and sudden bond with [Love][(lewd?", your heart beginning to race as your mind filles with thoughts about them.":".")] You are determined to keep them safe and happy, and feel drawn towards them.</span>")
	if(Lover.mind)
		Lover.mind.store_memory("You are in love with [Love].")
	Lover.faction |= "[REF(Love)]"
	Lover.apply_status_effect(STATUS_EFFECT_INLOVE, Love)
	forge_valentines_objective(Lover, Love, TRUE)
	SSblackbox.record_feedback("tally", "fermi_chem", 1, "Times people have become infatuated.")
	log_game("FERMICHEM: [Lover] ckey: [Lover.key] has been chemically made to fall for [Love] ckey: [Love.key]")
	return

//For addiction see chem.dm
//For vocal commands see vocal_cords.dm
