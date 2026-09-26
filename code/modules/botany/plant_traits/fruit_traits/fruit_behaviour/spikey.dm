/*
	spikey, makes fruit embed when thrown at mobs
*/
/datum/plant_trait/fruit/spikey
	name = "Spikey"
	desc = "The fruit becomes spikey, causing it to embed into targets."

/datum/plant_trait/fruit/spikey/setup_fruit_parent()
	. = ..()
	if(!isitem(fruit_parent))
		return
	fruit_parent.throwforce = fruit_parent.throwforce*trait_power
	fruit_parent.throw_speed = 4
	fruit_parent.embedding = list("embed_chance" = 300)
	fruit_parent.updateEmbedding()
