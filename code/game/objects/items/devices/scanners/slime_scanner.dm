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
	obj_flags = CONDUCTS_ELECTRICITY
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/iron=30, /datum/material/glass=20)

/obj/item/slime_scanner/attack(mob/living/living_mob, mob/living/user)
	if(user.stat || !user.can_read(src))
		return
	if(!isslime(living_mob))
		to_chat(user, span_warning("This device can only scan slimes!"))
		return
	var/mob/living/basic/slime/scanned_slime = living_mob
	slime_scan(scanned_slime, user)

/proc/slime_scan(mob/living/basic/slime/scanned_slime, mob/living/user)
	var/to_render = "<b>Slime scan results:</b>\
					\n[span_notice("[scanned_slime.slime_type.colour] [scanned_slime.life_stage] slime")]\
					\nNutrition: [scanned_slime.nutrition]/[SLIME_MAX_NUTRITION]"

	if (scanned_slime.nutrition < SLIME_STARVE_NUTRITION)
		to_render += "\n[span_warning("Warning: slime is starving!")]"
	else if (scanned_slime.nutrition < SLIME_HUNGER_NUTRITION)
		to_render += "\n[span_warning("Warning: slime is hungry")]"

	to_render += "\nElectric charge strength: [scanned_slime.powerlevel]\nHealth: [round(scanned_slime.health/scanned_slime.maxHealth,0.01)*100]%"

	to_render += "\nPossible mutation[scanned_slime.slime_type.mutations.len > 1 ? "s" : ""]: "
	var/list/mutation_text = list()
	for(var/datum/slime_type/key as anything in scanned_slime.slime_type.mutations)
		mutation_text += initial(key.colour)

	if(!mutation_text.len)
		to_render += " None detected."

	to_render += "[mutation_text.Join(", ")]"
	to_render += "\nGenetic instability: [scanned_slime.mutation_chance] % chance of mutation attempt on splitting."

	if (scanned_slime.cores > 1)
		to_render += "\nMultiple cores detected"
	to_render += "\nGrowth progress: [scanned_slime.amount_grown]/[SLIME_EVOLUTION_THRESHOLD]"
	if(scanned_slime.has_status_effect(/datum/status_effect/slimegrub))
		to_render += "\n<b>Redgrub infestation detected. Quarantine immediately.</b>"
		to_render += "\nRedgrubs can be purged from a slime using capsaicin oil or extreme heat"
	if(scanned_slime.crossbreed_modification)
		to_render += "\n[span_notice("Core mutation in progress: [scanned_slime.crossbreed_modification]")]\
					  \n[span_notice("Progress in core mutation: [scanned_slime.applied_crossbreed_amount] / [SLIME_EXTRACT_CROSSING_REQUIRED]")]"
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
	if(scanned_slime.special_mutation_type)
		var/datum/slime_type/special_type = scanned_slime.special_mutation_type
		to_render += span_notice("\n This slime has achieved the criteria for a special mutation! On split, it will become four [initial(special_type.colour)] slimes")
	to_chat(user, examine_block(jointext(to_render,"")))
