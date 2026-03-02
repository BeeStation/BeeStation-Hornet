/datum/symptom/toxoplasmosis //my take on the adminbus disease added a year ago. I wanted to make it an actual symptom instead of a simple idea, and i dont want it to call set_species()
	name = "Toxoplasmosis Sapiens"
	desc = "A parasitic symptom that causes a humanoid host to feel slightly happier around cats and cat people."
	stealth = 1
	resistance = -2
	stage_speed = -3
	transmission = 1
	level = 0
	severity = -1
	symptom_delay_min = 40
	symptom_delay_max = 60
	prefixes = list("Feline ", "Anime ")
	suffixes = list(" Madness", " Mania") //However, I want this virus to be a bit grimmer than the funny uwu cat disease
	var/mania = FALSE
	var/uwu = FALSE
	var/dnacounter = 0
	threshold_desc = "<b>Transmission 4:</b>The symptom mutates the language center of the host's brain, causing them to speak in an infuriating dialect. Known to drive hosts to suicide.<br>\
						<b>Stealth 4:</b>Hosts are overcome with a dysmorphic mania, causing them to glorify the idea of becoming more catlike. May cause irrational behaviour, and, in extreme cases, major body restructuring."

/datum/symptom/toxoplasmosis/severityset(datum/disease/advance/A)
	. = ..()
	if(A.stealth >= 4 || ((CONFIG_GET(flag/unconditional_symptom_thresholds) || A.event) && A.stealth >= 0))
		severity += 3
	if(A.transmission >= 4)
		severity += 2
	if(CONFIG_GET(flag/unconditional_symptom_thresholds))
		threshold_desc = "<b>Transmission 4:</b>The symptom mutates the language center of the host's brain, causing them to speak in an infuriating dialect. Known to drive hosts to suicide.<br>\
						<b>Stealth 0:</b>Hosts are overcome with a dysmorphic mania, causing them to glorify the idea of becoming more catlike. May cause irrational behaviour, and, in extreme cases, major body restructuring."


/datum/symptom/toxoplasmosis/Start(datum/disease/advance/A)
	. = ..()
	if(A.stealth >= 4 || ((CONFIG_GET(flag/unconditional_symptom_thresholds) || A.event) && A.stealth >= 0))
		mania = TRUE
	if(A.transmission >= 4)
		uwu = TRUE
		RegisterSignal(A.affected_mob, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/symptom/toxoplasmosis/Activate(datum/disease/advance/A)
	if(!..())
		return
	if(!ishuman(A.affected_mob))
		return
	var/mob/living/carbon/human/M = A.affected_mob
	if(M.stat >= DEAD)
		return
	if(A.stage >= 4)
		if(uwu && prob(40))
			M.say(pick("", "", "", ";", ".h")+pick("Nya", "MIAOW", "Ny- NYAAA", "meow", "NYAAA", "nya", "Ny- meow", "mrrrr", "Mew- Nya") + pick("!", "!!", "~!!", "!~", "~", "", "", ""), forced = "toxoplasmosis")
		if(mania)
			var/obj/item/organ/ears/cat/ears = M.get_organ_by_type(/obj/item/organ/ears/cat)
			var/obj/item/organ/tail/tail = M.get_organ_by_type(/obj/item/organ/tail)
			if(tail && !istype(tail, /obj/item/organ/tail/cat))
				SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "toxoplasmosis", /datum/mood_event/feline_dysmorphia)
				M.adjustOrganLoss(ORGAN_SLOT_EXTERNAL_TAIL, 30, 200)
				M.visible_message(span_hypnophrase("This tail is disgusting! you have to get rid of it!"), span_warning("[M] pulls viciously at their own tail!"))
				if(tail.organ_flags & ORGAN_FAILING)
					M.visible_message(span_hypnophrase("You finally manage to rip your tail out!"), span_warning("[M] pulls their own tail out!"))
					tail.Remove(M)
					tail.forceMove(get_turf(M))
					M.add_splatter_floor(get_turf(M))
					M.apply_damage(5, BRUTE)
					M.emote("laugh")
					playsound(M, 'sound/misc/desecration-01.ogg', 50, 1)
			else if(!ears || !tail)
				SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "toxoplasmosis", /datum/mood_event/feline_dysmorphia)
				if(dnacounter >= 5)
					if(!tail)
						var/obj/item/organ/tail/cat/cattail = new()
						cattail.Insert(M, movement_flags = DELETE_IF_REPLACED)
						M.visible_message(span_warning("With the sound of grinding flesh and rearranging bone, a grotesque tail springs forth from [M]'s flesh."), span_hypnophrase("A tail spontaneously sprouts from your pelvis! It's so cute!"))
						playsound(M, 'sound/magic/demon_consume.ogg', 50, 1)
						M.add_splatter_floor(get_turf(M))
					else
						var/obj/item/organ/ears/cat/catears = new()
						catears.Insert(M, movement_flags = DELETE_IF_REPLACED)
						M.visible_message( span_warning("[M]'s ears recede into their skull momentarily before their flesh contorts, and a pair of sickening cat ears erupts from their head."), span_hypnophrase("Your ears reshape themselves into an <b>ADORABLE</b> pair of cat ears!"))
						playsound(M, 'sound/magic/demon_consume.ogg', 50, 1)
						M.add_splatter_floor(get_turf(M))
					dnacounter -= 5
				else if(!M.stat)
					var/mob/living/cat = findcat(M, !ears, !tail)
					if(cat)
						M.visible_message(span_warning("[M] sits back, staring at [cat] with a manic gleam in their eyes."), span_hypnophrase("You prepare to glomp on [cat]!"))
						addtimer(CALLBACK(src, PROC_REF(Pounce), cat, M), 20)
			else
				SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "toxoplasmosis", /datum/mood_event/feline_mania)
		else if(findcat(M))
			SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "toxoplasmosis", /datum/mood_event/toxoplasmosis)

/datum/symptom/toxoplasmosis/proc/Pounce(mob/living/cat, mob/living/carbon/human/H)
	if(istype(cat, /mob/living/simple_animal/pet/cat))
		H.throw_at(cat, get_dist(cat, H), 2)
		if(get_dist(cat, H) > 1)
			return
		to_chat(H, span_hypnophrase("You pet [cat]!"))
		cat.visible_message(span_warning("[H] grabs [cat] roughly!"), span_userdanger("[H] roughly grabs you by the neck!"))
		H.emote("laugh")
		cat.apply_damage(5, BRUTE)
		dnacounter += 2 //real cats are purer, scarcer, and all around better
	else if(H.throw_at(cat, 7, 2))
		if(get_dist(cat, H) > 1)
			return
		if(ishuman(cat))
			var/mob/living/carbon/human/target = cat
			var/obj/item/organ/ears/cat/targetears = target.get_organ_by_type(/obj/item/organ/ears/cat)
			var/obj/item/organ/tail/cat/targettail = target.get_organ_by_type(/obj/item/organ/tail/cat)
			if(!H.get_organ_by_type(/obj/item/organ/tail/cat) && targettail)
				target.adjustOrganLoss(ORGAN_SLOT_EXTERNAL_TAIL, 20, 200)
				dnacounter += 1
				if(targettail.organ_flags & ORGAN_FAILING)
					to_chat(target, span_userdanger("[H] rips your tail from its socket!"))
					H.emote("laugh")
					H.visible_message(span_warning("[H] rips [target]'s tail from its socket!"), span_hypnophrase("You've got [target]'s tail!"))
					targettail.Remove(target)
					targettail.forceMove(get_turf(target))
					target.emote("scream")
					target.add_splatter_floor(get_turf(target))
					target.apply_damage(5, BRUTE)
					H.put_in_hands(targettail)
					dnacounter += 1
					playsound(target, 'sound/misc/desecration-01.ogg', 50, 1)
				else
					H.visible_message(span_warning("[H] pulls at [target]'s tail!"), span_hypnophrase("You bat at [target]'s tail!"))
					to_chat(target, span_userdanger("[H] pulls at your tail!"))
					H.emote("laugh")
			else if(!H.get_organ_by_type(/obj/item/organ/ears/cat) && targetears)
				target.adjustOrganLoss(ORGAN_SLOT_EARS, 20, 200)
				dnacounter += 1
				if(targetears.organ_flags & ORGAN_FAILING)
					to_chat(target, span_userdanger("[H] rips out your ears!"))
					H.emote("laugh")
					H.visible_message(span_warning("[H] rips [target]'s ears from their skull!"), span_hypnophrase("You've got [target]'s ears!"))
					targetears.Remove(target)
					targetears.forceMove(get_turf(target))
					target.emote("scream")
					target.add_splatter_floor(get_turf(target))
					target.apply_damage(5, BRUTE)
					H.put_in_hands(targetears)
					playsound(target, 'sound/misc/desecration-01.ogg', 50, 1)
				else
					H.visible_message(span_warning("[H] yanks on [target]'s ears!"), span_hypnophrase("You scratch behind [target]'s ears!"))
					to_chat(target, span_userdanger("[H] yanks on your ears!"))
					H.emote("laugh")
			target.apply_damage(rand(1, 10), BRUTE)

/datum/symptom/toxoplasmosis/End(datum/disease/advance/A)
	. = ..()
	if(uwu)
		UnregisterSignal(A.affected_mob, COMSIG_MOB_SAY)
	SEND_SIGNAL(A.affected_mob, COMSIG_CLEAR_MOOD_EVENT, "toxoplasmosis")

/datum/symptom/toxoplasmosis/proc/findcat(mob/living/carbon/human/M, requiresears = TRUE, requirestail = TRUE) //return a cat, or someone with cat ears and a tail
	for(var/mob/living/L in oviewers(7, M))
		if(L.stat)
			continue
		if(istype(L, /mob/living/simple_animal/pet/cat))
			return L
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			var/ears = H.get_organ_by_type(/obj/item/organ/ears/cat)
			var/tail = H.get_organ_by_type(/obj/item/organ/tail/cat)
			if((ears && requiresears) || (tail && requirestail))
				return H


/datum/symptom/toxoplasmosis/proc/handle_speech(datum/source, list/speech_args) //taken straight from storm's original felinid virus
	SIGNAL_HANDLER

	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = " [message]"
		var/list/owo_sounds = strings("owo_talk.json", "sounds")

		for(var/key in owo_sounds)
			var/value = owo_sounds[key]
			if(islist(value))
				value = pick(value)

			message = replacetextEx(message, "[uppertext(key)]", "[uppertext(value)]")
			message = replacetextEx(message, "[capitalize(key)]", "[capitalize(value)]")
			message = replacetextEx(message, "[key]", "[value]")

		if(prob(3))
			message += pick(" Nya!"," Meow!", " Mrooww~", " Mew...")
	speech_args[SPEECH_MESSAGE] = trim(message)

