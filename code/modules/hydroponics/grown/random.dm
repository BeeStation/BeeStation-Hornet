//Random seeds; stats, traits, and plant type are randomized for each seed.
/obj/item/seeds/random
	name = "pack of strange seeds"
	desc = "Mysterious seeds as strange as their name implies. Spooky."
	plantname = "strange plant"
	species = "?????"
	icon_state = "seed-x"
	icon_grow = "xpod-grow"
	icon_dead = "xpod-dead"
	icon_harvest = "xpod-harvest"
	growthstages = 4
	product = /obj/item/reagent_containers/food/snacks/grown/random

	mutatelist = list(/obj/item/seeds/random) // recursive
	maturation = 1
	production = 1


/obj/item/seeds/random/Initialize(mapload, nogenes)
	. = ..()

	if(research_identifier == name)
		research_identifier = rand(1, SAFE_RAND_MAX)
	set_random(research_identifier)

/obj/item/seeds/random/proc/set_new_seed(var/previous_identifier)
	// This makes expectable random stuff based on `rand_LCM` proc and `taken_identifier` var.
	previous_identifier = text2num(previous_identifier)
	if(isnum(previous_identifier))
		for(var/each in genes)
			if(istype(each, /datum/plant_gene/trait) || istype(each, /datum/plant_gene/reagent))
				genes -= each
				qdel(each)

		research_identifier = rand_LCM(previous_identifier, maximum=SAFE_RAND_MAX)
		set_random(research_identifier)

/obj/item/seeds/random/proc/set_random(var/given_identifier)
	var/static/list/greekpattern = list("alpha", "beta", "gamma", "delta", "epsilon", "zeta", "eta", "theta", "iota", "kappa", "lambda", "mu", "nu", "xi", "omicron", "pi", "rho", "sigma", "tau", "upsilon", "phi", "chi", "psi", "omega")
	var/pickedpattern = "[greekpattern[rand_LCM(given_identifier, maximum=length(greekpattern))]] No.[rand_LCM(given_identifier, maximum=999)]"
	name = "[initial(name)] [pickedpattern]"
	plantname = "[initial(plantname)] [pickedpattern]"

	if(prob(25))
		genes += new /datum/plant_gene/reagent(/datum/reagent/consumable/nutriment, list(1, 1))
	if(prob(25))
		genes += new /datum/plant_gene/reagent(/datum/reagent/consumable/nutriment/vitamin, list(1, 1))
	var/list/chances = rand_LCM(given_identifier, maximum=101, flat=0, numbers_of_return=3)
	if(chances[1] <= BTNY_CFG_RNG_REAG_CHANCE_FIRST)
		add_random_reagents(given_identifier)
	if(chances[2] <= BTNY_CFG_RNG_REAG_CHANCE_SECOND)
		add_random_reagents(rand_LCM(given_identifier, maximum=SAFE_RAND_MAX-7777))
	if(chances[3] <= BTNY_CFG_RNG_TRAIT_CHANCE)
		add_random_traits(given_identifier)
	randomize_stats(given_identifier)
	chances=null

	research_identifier = "[given_identifier]"

/obj/item/reagent_containers/food/snacks/grown/random
	seed = /obj/item/seeds/random
	name = "strange plant"
	desc = "What could this even be?"
	icon_state = "crunchy"
	bitesize_mod = 2
	discovery_points = 300

/obj/item/reagent_containers/food/snacks/grown/random/Initialize(mapload)
	. = ..()
	wine_power = rand(10,150)
	if(prob(1))
		wine_power = 200
