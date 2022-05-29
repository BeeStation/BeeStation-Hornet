/datum/plant_gene/trait/glow
	// Makes plant glow. Makes plant in tray glow too.
	// Adds 1 + potency*rate light range and potency*(rate + 0.01) light_power to products.
	name = "Bioluminescence"
	desc = "It makes your plants glowing."
	rate = 0.03
	examine_line = "<span class='info'>It emits a soft glow.</span>"
	trait_id = "glow"
	var/glow_color = "#C3E381"
	randomness_flags = NONE // use `/datum/plant_gene/trait/glow/random` instead
	research_needed = 1

/datum/plant_gene/trait/glow/proc/glow_range(obj/item/seeds/S)
	return 1.4 + S.potency*rate

/datum/plant_gene/trait/glow/proc/glow_power(obj/item/seeds/S)
	return max(S.potency*(rate + 0.01), 0.1)

/datum/plant_gene/trait/glow/on_new_plant(obj/item/reagent_containers/food/snacks/grown/G, newloc)
	. = ..()
	G.light_system = MOVABLE_LIGHT
	G.AddComponent(/datum/component/overlay_lighting, glow_range(G.seed), glow_power(G.seed), glow_color)

/datum/plant_gene/trait/glow/shadow
	//makes plant emit slightly purple shadows
	//adds -potency*(rate*0.2) light power to products
	name = "Shadow Emission"
	desc = "Absorbes lights so that it would make the station miserable. This is useful to treat a shadowling."
	rate = 0.04
	glow_color = "#AAD84B"
	randomness_flags = BOTANY_RANDOM_COMMON

/datum/plant_gene/trait/glow/shadow/glow_power(obj/item/seeds/S)
	return -max(S.potency*(rate*0.2), 0.2)

/datum/plant_gene/trait/glow/white
	name = "White Bioluminescence"
	desc = "Glowing white."
	glow_color = "#FFFFFF"
	randomness_flags = NONE

/datum/plant_gene/trait/glow/red
	name = "Red Bioluminescence"
	desc = "Glowing red."
	glow_color = "#FF3333"
	randomness_flags = NONE

/datum/plant_gene/trait/glow/yellow
	name = "Yellow Bioluminescence"
	desc = "Glowing yellow."
	glow_color = "#FFFF66"
	randomness_flags = NONE

/datum/plant_gene/trait/glow/green
	name = "Green Bioluminescence"
	desc = "Glowing green. It's not radioactive, no worries."
	glow_color = "#99FF99"
	randomness_flags = NONE

/datum/plant_gene/trait/glow/blue
	name = "Blue Bioluminescence"
	desc = "Glowing blue. the best one."
	glow_color = "#6699FF"
	randomness_flags = NONE

/datum/plant_gene/trait/glow/purple
	name = "Purple Bioluminescence"
	desc = "Glowing purple. Hmm, so flirting color."
	glow_color = "#D966FF"
	randomness_flags = NONE

/datum/plant_gene/trait/glow/pink
	name = "Pink Bioluminescence"
	desc = "Glowing pink. Colour of le princesse de pinkland."
	glow_color = "#FFB3DA"
	randomness_flags = NONE


/datum/plant_gene/trait/glow/random
	name = "random dummy Bioluminescence"
	desc = "this shouldn't exist."
	randomness_flags = BOTANY_RANDOM_COMMON

/datum/plant_gene/trait/glow/random/on_new_seed(obj/item/seeds/S, var/find_by_number=0)
	var/static/list/newgenes = list()
	if(!newgenes.len)
		newgenes = subtypesof(/datum/plant_gene/trait/glow) - list(/datum/plant_gene/trait/glow/shadow, /datum/plant_gene/trait/glow/random)
	var/chosen = null
	if(find_by_number)
		if(length(newgenes) < find_by_number)
			return
		chosen = newgenes[find_by_number]
	else
		chosen = pick(newgenes)
	S.genes -= src
	S.genes += new chosen
	qdel(src)

