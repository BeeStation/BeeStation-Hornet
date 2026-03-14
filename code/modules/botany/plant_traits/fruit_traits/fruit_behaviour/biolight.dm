/*
	Bioluminescence, makes the fruit glow
*/

/datum/plant_trait/fruit/biolight
	name = "Bioluminescence"
	desc = "Makes the fruit glow."
	examine_line = span_info("It emits a soft glow.")
///Glow characteristics
	var/glow_color = "#ffffff"
	//Minimums
	var/glow_range = 2
	var/glow_power = 3

/datum/plant_trait/fruit/biolight/setup_fruit_parent()
	. = ..()
	if(QDELETED(fruit_parent))
		return
	fruit_parent.light_system = MOVABLE_LIGHT
	fruit_parent.AddComponent(/datum/component/overlay_lighting, glow_range*trait_power, glow_power*trait_power, glow_color)

//Yellow
/datum/plant_trait/fruit/biolight/yellow
	name = "Yellow Bioluminescence"
	desc = "Makes the fruit glow yellow."
	glow_color = "#FFFF66"

//Orange
/datum/plant_trait/fruit/biolight/orange
	name = "Orange Bioluminescence"
	desc = "Makes the fruit glow orange."
	glow_color = "#D05800"


//Green
/datum/plant_trait/fruit/biolight/green
	name = "Green Bioluminescence"
	desc = "Makes the fruit glow green."
	glow_color = "#99FF99"

//Red
/datum/plant_trait/fruit/biolight/red
	name = "Red Bioluminescence"
	desc = "Makes the fruit glow red."
	glow_color = "#FF3333"

//Blue
/datum/plant_trait/fruit/biolight/blue
	//the best one - Pirill
	name = "Blue Bioluminescence"
	glow_color = "#6699FF"

//Purple
/datum/plant_trait/fruit/biolight/purple
	//did you know that Notepad++ doesnt think bioluminescence is a word - Pirill
	name = "Purple Bioluminescence"
	glow_color = "#D966FF"

//Pink
/datum/plant_trait/fruit/biolight/pink
	//gay tide station pride - Pirill
	name = "Pink Bioluminescence"
	glow_color = "#FFB3DA"

//White
/datum/plant_trait/fruit/biolight/white
	//gay tide station pride - Pirill
	name = "White Bioluminescence"
	glow_color = "#FFF"

//Shadow
/datum/plant_trait/fruit/biolight/dark
	name = "Shadow Emission"
	desc = "Makes the fruit emmit shadows."
	glow_color = "#AAD84B"
	glow_power = 0.04
