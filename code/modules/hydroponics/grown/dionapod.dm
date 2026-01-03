// A very special plant, deserving it's own file.

/obj/item/seeds/dionapod
	name = "pack of diona seeds"
	desc = "These seeds grow into diona nymphs. They say these are used to grow new dionae, just add blood!"
	icon_state = "seed-dionapod"
	species = "diona"
	plantname = "Diona Pod"
	product = /mob/living/simple_animal/hostile/retaliate/nymph
	lifespan = 200
	endurance = 8
	maturation = 8
	production = 1
	yield = 1
	potency = 30
	growthstages = 3
	var/volume = 5
	var/list/result = list()

/obj/item/seeds/dionapod/harvest(mob/user)
	var/obj/machinery/hydroponics/parent = src.loc
	if(CONFIG_GET(flag/diona_ghost_spawn))
		var/mob/living/simple_animal/hostile/retaliate/nymph/child = new /mob/living/simple_animal/hostile/retaliate/nymph(get_turf(parent))
		child.is_ghost_spawn = TRUE
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


/obj/item/seeds/nymph
	name = "Dead Nymph"
	icon_state = "seed-dionapod"
	species = "diona"
	plantname = "Dead Nymph"
	product = /mob/living/simple_animal/hostile/retaliate/nymph
	lifespan = 200
	endurance = 8
	maturation = 8
	production = 1
	yield = 1
	potency = 30
	growthstages = 3
	var/volume = 5
	var/list/result = list()

/obj/item/seeds/nymph/harvest(mob/user)
	var/obj/machinery/hydroponics/parent = src.loc
	var/mob/living/simple_animal/hostile/retaliate/nymph/child = new /mob/living/simple_animal/hostile/retaliate/nymph(get_turf(parent))
	mind.transfer_to(child)
	child.grab_ghost()
	parent.update_tray()
	return result
