/datum/objective/abductee
	completed = 1

/datum/objective/abductee/random

/datum/objective/abductee/random/New()
	explanation_text = pick(world.file2list("strings/abductee_objectives.txt"))

/datum/objective/abductee/steal
	explanation_text = "Steal all"

/datum/objective/abductee/steal/New()
	var/target = pick(list("pets","lights","monkeys","fruits","shoes","bars of soap", "weapons", "computers", "organs"))
	explanation_text+=" [target]."

/datum/objective/abductee/paint
	explanation_text = "The station is hideous. You must color it all"

/datum/objective/abductee/paint/New()
	var/color = pick(list("red", "blue", "green", "yellow", "orange", "purple", "black", "in rainbows", "in blood"))
	explanation_text+= " [color]!"

/datum/objective/abductee/speech
	explanation_text = "Your brain is broken... you can only communicate in"

/datum/objective/abductee/speech/New()
	var/style = pick(list("pantomime", "rhyme", "haiku", "extended metaphors", "riddles", "extremely literal terms", "sound effects", "military jargon", "three word sentences"))
	explanation_text+= " [style]."

/datum/objective/abductee/cargonia
	explanation_text = "Your comrades have been oppressed for long enough. Declare and protect the independence of"

/datum/objective/abductee/cargonia/New()
	var/department = pick(list("service", "security", "command", "cargo", "medbay", "science", "engineering"))
	explanation_text+= " [department]!"

/datum/objective/abductee/gangstalkers
	explanation_text = "You are a targeted individual. There are gangstalkers out to get you, and all of them are from"

/datum/objective/abductee/gangstalkers/New()
	var/skinwalker = pick(list("lavaland", "security", "clown planet", "the syndicate", "maintenance"))
	explanation_text+= " [skinwalker]."

/datum/objective/abductee/cure
	explanation_text = "There is a cure for every ailment know to man. You must bring"

/datum/objective/abductee/cure/New()
	var/heal = pick(list("cannabis", "corgis", "the beautiful sound of bikehorns", "weapons", "holy water"))
	explanation_text+= " [heal] to all sick and injured people!"

/datum/objective/abductee/capture
	explanation_text = "Capture"

/datum/objective/abductee/capture/New()
	var/list/jobs = SSjob.occupations.Copy()
	for(var/X in jobs)
		var/datum/job/J = X
		if(J.current_positions < 1)
			jobs -= J
	if(jobs.len > 0)
		var/datum/job/target = pick(jobs)
		explanation_text += " a [target.title]."
	else
		explanation_text += " someone."

/datum/objective/abductee/calling/New()
	var/mob/dead/D = pick(GLOB.dead_mob_list)
	if(D)
		explanation_text = "You know that [D] has perished. Hold a seance to call [D.p_them()] from the spirit realm."

/datum/objective/abductee/forbiddennumber

/datum/objective/abductee/forbiddennumber/New()
	var/number = rand(2,10)
	explanation_text = "Ignore anything in a set of [number], they don't exist."
