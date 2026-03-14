/*
	spikey, makes fruit embed when thrown at mobs
*/
/datum/plant_trait/fruit/spikey
	name = "Spikey"
	desc = "The fruit becomes spikey, allowing it to embed into targets."

/datum/plant_trait/fruit/spikey/setup_fruit_parent()
	. = ..()
	fruit_parent.throwforce = fruit_parent.throwforce*trait_power
	fruit_parent.throw_speed = 4
	fruit_parent.embedding = list("pain_mult" = 0, "embed_chance" = 300, "fall_chance" = 0, "armour_block" = 0)
	fruit_parent.updateEmbedding()
