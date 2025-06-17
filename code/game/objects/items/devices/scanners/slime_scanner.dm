/obj/item/slime_scanner
	name = "slime scanner"
	desc = "A device that analyzes a slime's internal composition and measures its stats."
	icon = 'icons/obj/device.dmi'
	icon_state = "adv_spectrometer"
	item_state = "analyzer"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	flags_1 = CONDUCT_1
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/iron=30, /datum/material/glass=20)

/obj/item/slime_scanner/attack(mob/living/M, mob/living/user)
	if(user.stat)
		return
	if(!isslime(M))
		to_chat(user, span_warning("This device can only scan slimes!"))
		return
	var/mob/living/simple_animal/slime/T = M
	slime_scan(T, user)

/proc/slime_scan(mob/living/simple_animal/slime/T, mob/living/user)
	var/list/message = list()

	message += "<b>Slime scan results:</b>"
	message += span_notice("[T.colour] [T.is_adult ? "adult" : "baby"] slime")
	message += "Nutrition: [T.nutrition]/[T.get_max_nutrition()]"
	if(T.nutrition < T.get_starve_nutrition())
		message += span_warning("Warning: slime is starving!")
	else if(T.nutrition < T.get_hunger_nutrition())
		message += span_warning("Warning: slime is hungry")
	message += "Electric change strength: [T.powerlevel]"
	message += "Health: [round(T.health/T.maxHealth,0.01)*100]%"
	if(T.slime_mutation[4] == T.colour)
		message += "This slime does not evolve any further."
	else
		if(T.slime_mutation[3] == T.slime_mutation[4])
			if(T.slime_mutation[2] == T.slime_mutation[1])
				message += "Possible mutation: [T.slime_mutation[3]]"
				message += "Genetic destability: [T.mutation_chance/2] % chance of mutation on splitting"
			else
				message += "Possible mutations: [T.slime_mutation[1]], [T.slime_mutation[2]], [T.slime_mutation[3]] (x2)"
				message += "Genetic destability: [T.mutation_chance] % chance of mutation on splitting"
		else
			message += "Possible mutations: [T.slime_mutation[1]], [T.slime_mutation[2]], [T.slime_mutation[3]], [T.slime_mutation[4]]"
			message += "Genetic destability: [T.mutation_chance] % chance of mutation on splitting"
	if(T.cores > 1)
		message += "Multiple cores detected"
	message += "Growth progress: [T.amount_grown]/[SLIME_EVOLUTION_THRESHOLD]"
	if(T.has_status_effect(/datum/status_effect/slimegrub))
		message += "<b>Redgrub infestation detected. Quarantine immediately.</b>"
		message += "Redgrubs can be purged from a slime using capsaicin oil or extreme heat"
	if(T.effectmod)
		message += span_notice("Core mutation in progress: [T.effectmod]")
		message += span_notice("Progress in core mutation: [T.applied] / [SLIME_EXTRACT_CROSSING_REQUIRED]")
	if(T.transformeffects != SLIME_EFFECT_DEFAULT)
		var/slimeeffect = "\nTransformative extract effect detected: "
		if(T.transformeffects & SLIME_EFFECT_GREY)
			slimeeffect += "grey"
		if(T.transformeffects & SLIME_EFFECT_ORANGE)
			slimeeffect += "orange"
		if(T.transformeffects & SLIME_EFFECT_PURPLE)
			slimeeffect += "purple"
		if(T.transformeffects & SLIME_EFFECT_BLUE)
			slimeeffect += "blue"
		if(T.transformeffects & SLIME_EFFECT_METAL)
			slimeeffect += "metal"
		if(T.transformeffects & SLIME_EFFECT_YELLOW)
			slimeeffect += "yellow"
		if(T.transformeffects & SLIME_EFFECT_DARK_PURPLE)
			slimeeffect += "dark purple"
		if(T.transformeffects & SLIME_EFFECT_DARK_BLUE)
			slimeeffect += "dark blue"
		if(T.transformeffects & SLIME_EFFECT_SILVER)
			slimeeffect += "silver"
		if(T.transformeffects & SLIME_EFFECT_BLUESPACE)
			slimeeffect += "bluespace"
		if(T.transformeffects & SLIME_EFFECT_SEPIA)
			slimeeffect += "sepia"
		if(T.transformeffects & SLIME_EFFECT_CERULEAN)
			slimeeffect += "cerulean"
		if(T.transformeffects & SLIME_EFFECT_PYRITE)
			slimeeffect += "pyrite"
		if(T.transformeffects & SLIME_EFFECT_RED)
			slimeeffect += "red"
		if(T.transformeffects & SLIME_EFFECT_GREEN)
			slimeeffect += "green"
		if(T.transformeffects & SLIME_EFFECT_PINK)
			slimeeffect += "pink"
		if(T.transformeffects & SLIME_EFFECT_GOLD)
			slimeeffect += "gold"
		if(T.transformeffects & SLIME_EFFECT_OIL)
			slimeeffect += "oil"
		if(T.transformeffects & SLIME_EFFECT_BLACK)
			slimeeffect += "black"
		if(T.transformeffects & SLIME_EFFECT_LIGHT_PINK)
			slimeeffect += "light pink"
		if(T.transformeffects & SLIME_EFFECT_ADAMANTINE)
			slimeeffect += "adamantine"
		if(T.transformeffects & SLIME_EFFECT_RAINBOW)
			slimeeffect += "rainbow"
		message += span_notice("[slimeeffect].")
	if(T.special_mutation == TRUE)
		message += span_notice("\n This slime has achieved the critera for a special mutation! On split, it will become four [T.special_mutation_type] slimes")

	to_chat(user, examine_block(jointext(message, "\n")))
