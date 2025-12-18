//slime scanner

/obj/item/slime_scanner
	name = "slime scanner"
	desc = "A device that analyzes a slime's internal composition and measures its stats."
	icon = 'icons/obj/device.dmi'
	icon_state = "adv_spectrometer"
	inhand_icon_state = "analyzer"
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

/proc/slime_scan(mob/living/simple_animal/slime/scanned_slime, mob/living/user)
	var/to_render = "<b>Slime scan results:</b>\
					\n[span_notice("[scanned_slime.colour] [scanned_slime.is_adult ? "adult" : "baby"] slime")]\
					\nNutrition: [scanned_slime.nutrition]/[scanned_slime.get_max_nutrition()]"

	if (scanned_slime.nutrition < scanned_slime.get_starve_nutrition())
		to_render += "\n[span_warning("Warning: slime is starving!")]"
	else if (scanned_slime.nutrition < scanned_slime.get_hunger_nutrition())
		to_render += "\n[span_warning("Warning: slime is hungry")]"

	to_render += "\nElectric charge strength: [scanned_slime.powerlevel]\nHealth: [round(scanned_slime.health/scanned_slime.maxHealth,0.01)*100]%"
	if(scanned_slime.slime_mutation[4] == scanned_slime.colour)
		to_render += "\nThis slime does not evolve any further."
	else
		if (scanned_slime.slime_mutation[3] == scanned_slime.slime_mutation[4])
			if (scanned_slime.slime_mutation[2] == scanned_slime.slime_mutation[1])
				to_render += "\nPossible mutation: [scanned_slime.slime_mutation[3]]\
							  \nGenetic destability: [scanned_slime.mutation_chance/2] % chance of mutation on splitting"
			else
				to_render += "\nPossible mutations: [scanned_slime.slime_mutation[1]], [scanned_slime.slime_mutation[2]], [scanned_slime.slime_mutation[3]] (x2)\
							  \nGenetic destability: [scanned_slime.mutation_chance] % chance of mutation on splitting"
		else
			to_render += "\nPossible mutations: [scanned_slime.slime_mutation[1]], [scanned_slime.slime_mutation[2]], [scanned_slime.slime_mutation[3]], [scanned_slime.slime_mutation[4]]\
						  \nGenetic destability: [scanned_slime.mutation_chance] % chance of mutation on splitting"
	if (scanned_slime.cores > 1)
		to_render += "\nMultiple cores detected"
	to_render += "\nGrowth progress: [scanned_slime.amount_grown]/[SLIME_EVOLUTION_THRESHOLD]"
	if(scanned_slime.has_status_effect(/datum/status_effect/slimegrub))
		to_render += "\n<b>Redgrub infestation detected. Quarantine immediately.</b>"
		to_render += "\nRedgrubs can be purged from a slime using capsaicin oil or extreme heat"
	if(scanned_slime.effectmod)
		to_render += "\n[span_notice("Core mutation in progress: [scanned_slime.effectmod]")]\
					  \n[span_notice("Progress in core mutation: [scanned_slime.applied] / [SLIME_EXTRACT_CROSSING_REQUIRED]")]"
	if(scanned_slime.transformeffects != SLIME_EFFECT_DEFAULT)
		var/slimeeffect = "\nTransformative extract effect detected: "
		if(scanned_slime.transformeffects & SLIME_EFFECT_GREY)
			slimeeffect += "grey"
		if(scanned_slime.transformeffects & SLIME_EFFECT_ORANGE)
			slimeeffect += "orange"
		if(scanned_slime.transformeffects & SLIME_EFFECT_PURPLE)
			slimeeffect += "purple"
		if(scanned_slime.transformeffects & SLIME_EFFECT_BLUE)
			slimeeffect += "blue"
		if(scanned_slime.transformeffects & SLIME_EFFECT_METAL)
			slimeeffect += "metal"
		if(scanned_slime.transformeffects & SLIME_EFFECT_YELLOW)
			slimeeffect += "yellow"
		if(scanned_slime.transformeffects & SLIME_EFFECT_DARK_PURPLE)
			slimeeffect += "dark purple"
		if(scanned_slime.transformeffects & SLIME_EFFECT_DARK_BLUE)
			slimeeffect += "dark blue"
		if(scanned_slime.transformeffects & SLIME_EFFECT_SILVER)
			slimeeffect += "silver"
		if(scanned_slime.transformeffects & SLIME_EFFECT_BLUESPACE)
			slimeeffect += "bluespace"
		if(scanned_slime.transformeffects & SLIME_EFFECT_SEPIA)
			slimeeffect += "sepia"
		if(scanned_slime.transformeffects & SLIME_EFFECT_CERULEAN)
			slimeeffect += "cerulean"
		if(scanned_slime.transformeffects & SLIME_EFFECT_PYRITE)
			slimeeffect += "pyrite"
		if(scanned_slime.transformeffects & SLIME_EFFECT_RED)
			slimeeffect += "red"
		if(scanned_slime.transformeffects & SLIME_EFFECT_GREEN)
			slimeeffect += "green"
		if(scanned_slime.transformeffects & SLIME_EFFECT_PINK)
			slimeeffect += "pink"
		if(scanned_slime.transformeffects & SLIME_EFFECT_GOLD)
			slimeeffect += "gold"
		if(scanned_slime.transformeffects & SLIME_EFFECT_OIL)
			slimeeffect += "oil"
		if(scanned_slime.transformeffects & SLIME_EFFECT_BLACK)
			slimeeffect += "black"
		if(scanned_slime.transformeffects & SLIME_EFFECT_LIGHT_PINK)
			slimeeffect += "light pink"
		if(scanned_slime.transformeffects & SLIME_EFFECT_ADAMANTINE)
			slimeeffect += "adamantine"
		if(scanned_slime.transformeffects & SLIME_EFFECT_RAINBOW)
			slimeeffect += "rainbow"
		to_render += span_notice("\n[slimeeffect].")
	if(scanned_slime.special_mutation == TRUE)
		to_render += span_notice("\n This slime has achieved the criteria for a special mutation! On split, it will become four [scanned_slime.special_mutation_type] slimes")
	to_chat(user, examine_block(to_render))
