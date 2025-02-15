/datum/symptom/light
	name = "Photosensitive muscle condensation"
	desc = "The virus will cause muscles to contract when exposed to light, resulting in lowered speed, but increased durability. Muscles will become more malleable in the darkness, resulting in the host moving faster, but being more easily bruised."
	stealth = 0
	resistance = 2
	stage_speed = -3
	transmission = 0
	level = 8
	severity = -2
	var/currenthealthmodifier
	prefixes = list("Photo", "Light ")
	bodies = list("Cramp")
	threshold_desc = "<b>Stealth 3:</b> The virus causes a wider disparity between light and dark" //this is a stealth symptom because, at its first threshold, its effects are negligable enough it could be spread with minimal downside

/datum/symptom/light/severityset(datum/disease/advance/A)
	. = ..()
	if(A.stealth >= 3)
		severity -= 1 //this symptom has the lowest severity out of any, this is to make it difficult to stack

/datum/symptom/light/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stealth >= 3)
		power = 2

/datum/symptom/light/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	if(M.stat >= DEAD)
		return
	var/realpower = power
	var/healthchange = min(1 * realpower, (10 * realpower) - currenthealthmodifier)
	if(isturf(M.loc))
		var/turf/T = M.loc
		var/light_amount = min(1,T.get_lumcount()) - 0.5
		if(light_amount < SHADOW_SPECIES_LIGHT_THRESHOLD)
			realpower = power * -1
			healthchange = max(1 * realpower, (10 * realpower) - currenthealthmodifier)
			if(prob(5))
				to_chat(M, span_warning("[pick("You feel vulnerable.", "Your limbs feel loose and limber.", "The dark makes you feel relaxed.")]"))
		else if(prob(5))
			to_chat(M, span_warning("[pick("Your muscles feel tight.", "You feel lethargic.", "Your muscles feel hard and tough.")]"))
	if(A.stage >= 5)
		currenthealthmodifier += healthchange
		M.maxHealth += healthchange
		M.health += healthchange
		M.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/virus/light_virus, multiplicative_slowdown = (currenthealthmodifier / 25))

/datum/symptom/light/End(datum/disease/advance/A)
	. = ..()
	var/mob/living/M = A.affected_mob
	M.remove_movespeed_modifier(/datum/movespeed_modifier/virus/light_virus)
	M.maxHealth -= currenthealthmodifier
	M.health -= currenthealthmodifier
