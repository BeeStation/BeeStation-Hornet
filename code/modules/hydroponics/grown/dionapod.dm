// A very special plant, deserving it's own file.

/obj/item/seeds/dionapod
	name = "pack of diona seeds"
	desc = "These seeds grow into diona nymphs. They say these are used to grow new dionae, just add blood!"
	icon_state = "seed-dionapod"
	species = "diona"
	plantname = "Diona Pod"
	product = /mob/living/simple_animal/nymph
	lifespan = 50
	endurance = 8
	maturation = 8
	production = 1
	yield = 1
	potency = 30
	growthstages = 3
	var/volume = 5
	var/spawnNymph = FALSE
	var/list/result = list()

/obj/item/seeds/dionapod/Initialize(mapload)
	. = ..()
	create_reagents(volume, INJECTABLE|DRAWABLE)

/obj/item/seeds/dionapod/on_reagent_change(changetype)
	if(changetype == ADD_REAGENT)
		if(reagents.has_reagent(/datum/reagent/blood))
			spawnNymph = TRUE
	if(!reagents.has_reagent(/datum/reagent/blood))
		spawnNymph = FALSE

/obj/item/seeds/dionapod/harvest(mob/user)
	var/obj/machinery/hydroponics/parent = src.loc
	if(CONFIG_GET(flag/revival_pod_plants) && spawnNymph)
		for (var/x ; x < yield; x++)
			var/mob/living/simple_animal/nymph/child = new /mob/living/simple_animal/nymph(get_turf(parent))
			child.IsGhostSpawn = TRUE
	else
		var/seed_count = 1
		if(prob(getYield() * 20))
			seed_count++
		var/output_loc = parent.Adjacent(user) ? user.loc : parent.loc //needed for TK
		while(seed_count)
			var/obj/item/seeds/dionapod/harvestseeds = src.Copy()
			result.Add(harvestseeds)
			harvestseeds.forceMove(output_loc)
			seed_count--
	parent.update_tray()
	return result
