//The misbegotten progeny of random maint coders from bygone years...
//Are you, future codetrudger, going to continue this and add another entry to this category?
//Don't.
/obj/effect/spawner/random/unsorted
	name = "unsorted spawner"
	desc = "Stuff that doesn't fit anywhere else(this is bad)."

/obj/effect/spawner/random/unsorted/sanitarium
	name = "patient spawner"
	loot = list(
		/obj/effect/decal/remains/human = 10,
		/mob/living/simple_animal/hostile/cat_butcherer = 2,
		/mob/living/simple_animal/hostile/stickman = 2,
		/mob/living/simple_animal/hostile/netherworld/blankbody = 2,
		/mob/living/simple_animal/cluwne = 1,
		/mob/living/simple_animal/hostile/retaliate/clown = 1,
		/mob/living/simple_animal/hostile/retaliate/clown/clownhulk/honcmunculus = 1,
		/mob/living/simple_animal/hostile/retaliate/clown/longface = 1,
		/mob/living/basic/pet/gondola = 2,
		/mob/living/simple_animal/hostile/macrophage/aggro/vector = 2,
		/mob/living/simple_animal/hostile/retaliate/spaceman = 2,
		/obj/effect/mob_spawn/human/corpse/assistant/brainrot_infection = 1,
		/mob/living/simple_animal/hostile/retaliate/frog = 2
	)

/obj/effect/spawner/random/unsorted/megafaunaore
	name = "megafauna ore drop"
	spawn_loot_count = 50
	spawn_loot_double = TRUE
	loot = list(
		/obj/item/stack/ore/iron = 5,
		/obj/item/stack/ore/glass/basalt = 5,
		/obj/item/stack/ore/plasma = 3,
		/obj/item/stack/ore/silver = 3,
		/obj/item/stack/ore/gold = 3,
		/obj/item/stack/ore/copper = 3,
		/obj/item/stack/ore/titanium = 2,
		/obj/item/stack/ore/uranium = 2,
		/obj/item/stack/ore/diamond = 2
	)

/obj/effect/spawner/random/unsorted/trap
	name = "10% pressure plate spawner"
	loot = list(
		/obj/effect/spawner/random/maintenance = 9,
		/obj/effect/trap/trigger/all = 1)

/obj/effect/spawner/random/unsorted/trap/reusable
	loot = list(
		/obj/effect/spawner/random/maintenance = 9,
		/obj/effect/trap/trigger/reusable/all = 1)

/obj/effect/spawner/random/unsorted/trap/clowntrap
	name = "clown trap spawner"
	loot = list(
		/obj/effect/spawner/random/maintenance = 9,
		/obj/effect/trap/nexus/trickyspawner/clownmutant = 2,
		/obj/effect/trap/nexus/trickyspawner/honkling = 3,
		/obj/effect/trap/nexus/cluwnecurse = 1)
