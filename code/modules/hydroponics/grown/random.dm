//Random seeds; stats, traits, and plant type are randomized for each seed.

/obj/item/seeds/random
	name = "pack of strange seeds"
	desc = "Mysterious seeds as strange as their name implies. Spooky."
	icon_state = "seed-x"
	species = "?????"
	plantname = "strange plant"
	product = /obj/item/reagent_containers/food/snacks/grown/random
	icon_grow = "xpod-grow"
	icon_dead = "xpod-dead"
	icon_harvest = "xpod-harvest"
	growthstages = 4
	mutatelist = list(/obj/item/seeds/random) // recursive
	var/previous_identifier = FALSE

/obj/item/seeds/random/Initialize(mapload)
	. = ..()
	if(previous_identifier)
		return
	randomize_stats()
	if(prob(60))
		add_random_reagents(1, 3)
	else
		add_random_reagents(1, 1)
	if(prob(50))
		add_random_traits(1, 2)
	else
		add_random_traits(1, 1)
	add_random_plant_type(35)

	if(research_identifier == name)
		research_identifier = "[rand(1, SHORT_REAL_LIMIT)]" //strange seeds won't be researched if it still has a static value.

/obj/item/seeds/random/New(previous_identifier = FALSE)
	if(!previous_identifier)
		return

	// This makes each seed have their own cycle. although the key looks ugly, but I found nothing better.
	// touching `rand_seed()` because botany seed needs can cause unexpectable situation.
	// len(get_random_reagent_id(CHEMICAL_RNG_BOTANY, return_as_list=TRUE))

	research_identifier = "[randmaker(previous_identifier, maximum = SHORT_REAL_LIMIT)]"



/proc/randmaker(var/seed = 0, var/multiplier = seed, var/maximum, var/numbers_of_return = 1, var/flat = 1)
 // Pseudo random number generating - "Modified" Linear Congruential Method
 // Since I didn't want to touch `rand_seed()` proc, I had to make this.
 . = numbers_of_return == 1 ? 0 : list()

 for(var/i in 1 to numbers_of_return)
  var/seed_result = (seed*multiplier) %maximum +flat
  seed = seed_result
  . += seed_result
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
