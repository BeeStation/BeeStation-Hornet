/datum/plant_gene/trait/glow
	// Makes plant glow. Makes plant in tray glow too.
	// Adds 1 + potency*rate light range and potency*(rate + 0.01) light_power to products.
	name = "Bioluminescence"
	rate = 0.03
	examine_line = "<span class='info'>It emits a soft glow.</span>"
	trait_id = "glow"
	var/glow_color = "#C3E381"

/datum/plant_gene/trait/glow/proc/glow_range(obj/item/seeds/S)
	return 1.4 + S.potency*rate

/datum/plant_gene/trait/glow/proc/glow_power(obj/item/seeds/S)
	return max(S.potency*(rate + 0.01), 0.1)

/datum/plant_gene/trait/glow/on_new(obj/item/reagent_containers/food/snacks/grown/G, newloc)
	. = ..()
	G.light_system = MOVABLE_LIGHT
	G.AddComponent(/datum/component/overlay_lighting, glow_range(G.seed), glow_power(G.seed), glow_color)

/datum/plant_gene/trait/glow/shadow
	//makes plant emit slightly purple shadows
	//adds -potency*(rate*0.2) light power to products
	name = "Shadow Emission"
	rate = 0.04
	glow_color = "#AAD84B"

/datum/plant_gene/trait/glow/shadow/glow_power(obj/item/seeds/S)
	return -max(S.potency*(rate*0.2), 0.2)

/datum/plant_gene/trait/glow/white
	name = "White Bioluminescence"
	glow_color = "#FFFFFF"

/datum/plant_gene/trait/glow/red
	//Colored versions of bioluminescence.
	name = "Red Bioluminescence"
	glow_color = "#FF3333"

/datum/plant_gene/trait/glow/yellow
	//not the disgusting glowshroom yellow hopefully
	name = "Yellow Bioluminescence"
	glow_color = "#FFFF66"

/datum/plant_gene/trait/glow/green
	//oh no, now I'm radioactive
	name = "Green Bioluminescence"
	glow_color = "#99FF99"

/datum/plant_gene/trait/glow/blue
	//the best one
	name = "Blue Bioluminescence"
	glow_color = "#6699FF"

/datum/plant_gene/trait/glow/purple
	//did you know that Notepad++ doesnt think bioluminescence is a word
	name = "Purple Bioluminescence"
	glow_color = "#D966FF"

/datum/plant_gene/trait/glow/pink
	//gay tide station pride
	name = "Pink Bioluminescence"
	glow_color = "#FFB3DA"
