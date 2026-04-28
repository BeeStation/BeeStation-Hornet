/obj/effect/spawner/random/medical
	name = "medical loot spawner"
	desc = "Doc, gimmie something good."

/obj/effect/spawner/random/medical/minor_healing
	name = "minor healing spawner"
	icon_state = "gauze"
	loot = list(
		/obj/item/stack/medical/bruise_pack,
		/obj/item/stack/medical/ointment,
		/obj/item/stack/medical/gauze,
	)

/obj/effect/spawner/random/medical/injector
	name = "injector spawner"
	icon_state = "syringe"
	loot = list(
		/obj/item/implanter,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/syringe,
	)

/obj/effect/spawner/random/medical/organs
	name = "ayylien organ spawner"
	icon_state = "eyes"
	spawn_loot_count = 3
	loot = list(
		/obj/item/organ/heart/gland/egg = 7,
		/obj/item/organ/heart/gland/plasma = 7,
		/obj/item/organ/heart/gland/chem = 5,
		/obj/item/organ/heart/gland/mindshock = 5,
		/obj/item/organ/heart/gland/spiderman = 5,
		/obj/item/organ/heart/gland/pop = 5,
		/obj/item/organ/heart/gland/slime = 4,
		/obj/item/organ/heart/gland/trauma = 4,
		/obj/item/organ/heart/gland/electric = 3,
		/obj/item/organ/regenerative_core = 2,
		/obj/item/organ/heart/gland/ventcrawling = 1,
		/obj/item/organ/body_egg/alien_embryo = 1,
	)

/obj/effect/spawner/random/medical/memeorgans
	name = "meme organ spawner"
	icon_state = "eyes"
	spawn_loot_count = 5
	loot = list(
		/obj/item/organ/ears/penguin,
		/obj/item/organ/ears/cat,
		/obj/item/organ/eyes/moth,
		/obj/item/organ/eyes/snail,
		/obj/item/organ/tongue/bone,
		/obj/item/organ/tongue/fly,
		/obj/item/organ/tongue/snail,
		/obj/item/organ/tongue/lizard,
		/obj/item/organ/tongue/alien,
		/obj/item/organ/tongue/ethereal,
		/obj/item/organ/tongue/robot,
		/obj/item/organ/tongue/zombie,
		/obj/item/organ/appendix,
		/obj/item/organ/liver/fly,
		/obj/item/organ/lungs/plasmaman,
		/obj/item/organ/tail/cat,
		/obj/item/organ/tail/lizard,
	)

/obj/effect/spawner/random/medical/two_percent_xeno_egg_spawner
	name = "2% chance xeno egg spawner"
	icon_state = "xeno_egg"
	loot = list(
		/obj/effect/decal/remains/xeno = 49,
		/obj/effect/spawner/xeno_egg_delivery = 1,
	)

/obj/effect/spawner/random/medical/two_percent_xeno_egg_spawner/Initialize(mapload)
	if(prob(40) && SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
		loot = list(/obj/effect/spawner/xeno_egg_delivery_troll = 1)
	. = ..()

/obj/effect/spawner/random/medical/surgery_tool
	name = "Surgery tool spawner"
	icon_state = "scapel"
	loot = list(
		/obj/item/scalpel,
		/obj/item/hemostat,
		/obj/item/retractor,
		/obj/item/circular_saw,
		/obj/item/surgicaldrill,
		/obj/item/cautery,
	)

/obj/effect/spawner/random/medical/surgery_tool_advanced
	name = "Advanced surgery tool spawner"
	icon_state = "scapel"
	loot = list( // Mail loot spawner. Drop pool of advanced medical tools typically from research. Not endgame content.
		/obj/item/scalpel/advanced,
		/obj/item/retractor/advanced,
		/obj/item/cautery/advanced,
	)

/obj/effect/spawner/random/medical/surgery_tool_alien
	name = "Rare surgery tool spawner"
	icon_state = "scapel"
	loot = list( // Mail loot spawner. Some sort of random and rare surgical tool. Alien tech found here.
		/obj/item/scalpel/alien,
		/obj/item/hemostat/alien,
		/obj/item/retractor/alien,
		/obj/item/circular_saw/alien,
		/obj/item/surgicaldrill/alien,
		/obj/item/cautery/alien,
	)

/obj/effect/spawner/random/medical/firstaid_rare
	name = "rare firstaid kit spawner"
	icon_state = "medkit"
	loot = list(
		/obj/item/storage/firstaid/medical,
		/obj/item/storage/firstaid/advanced,
	)

/obj/effect/spawner/random/medical/firstaid
	name = "firstaid kit spawner"
	icon_state = "medkit"
	loot = list(
		/obj/item/storage/firstaid/regular = 10,
		/obj/item/storage/firstaid/o2 = 10,
		/obj/item/storage/firstaid/fire = 10,
		/obj/item/storage/firstaid/brute = 10,
		/obj/item/storage/firstaid/toxin = 10,
		/obj/effect/spawner/random/medical/firstaid_rare = 1,
	)

/obj/effect/spawner/random/medical/patient_stretcher
	name = "patient stretcher spawner"
	icon_state = "rollerbed"
	loot = list(
		/obj/structure/bed/roller,
		/obj/vehicle/ridden/wheelchair,
	)

/obj/effect/spawner/random/medical/supplies
	name = "medical supplies spawner"
	icon_state = "box_small"
	loot = list(
		/obj/item/storage/box/hug,
		/obj/item/storage/box/pillbottles,
		/obj/item/storage/box/bodybags,
		/obj/item/storage/box/rxglasses,
		/obj/item/storage/box/beakers,
		/obj/item/storage/box/gloves,
		/obj/item/storage/box/masks,
		/obj/item/storage/box/syringes,
	)

//Disease zeskocode

/obj/effect/spawner/random/medical/teratoma/minor
	name = "minor teratoma spawner"
	loot = list(
		/obj/item/organ/tongue = 5,
		/obj/item/organ/tongue/lizard = 1,
		/obj/item/organ/tail/cat = 1,
		/obj/item/organ/stomach = 5,
		/obj/item/organ/tongue/zombie = 1,
		/obj/item/organ/tongue/fly = 1,
		/obj/item/organ/stomach/fly = 1,
		/obj/item/organ/ears = 5,
		/obj/item/organ/ears/cat = 1,
		/obj/item/organ/eyes/snail = 1,
		/obj/item/organ/eyes/moth = 1,
		/obj/item/organ/eyes = 5,
		/obj/item/organ/heart = 5,
		/obj/item/organ/liver = 5,
		/obj/item/organ/tail/lizard = 1,
		/obj/item/organ/tongue/snail = 1,
		/obj/item/organ/appendix = 5,
		/obj/effect/gibspawner/human = 1,
		/obj/item/organ/wings = 1,
		/obj/item/organ/wings/moth = 1,
		/obj/item/organ/wings/bee = 1,
		/obj/item/organ/wings/dragon/fake = 1
	)

/obj/effect/spawner/random/medical/teratoma/major
	name = "major teratoma spawner"
	loot = list(
		/obj/item/organ/adamantine_resonator = 2,,
		/obj/item/organ/ears/penguin = 2,
		/obj/item/organ/heart/gland/viral = 1,
		/obj/item/organ/eyes/night_vision = 1,
		/obj/item/organ/liver/plasmaman = 3,
		/obj/item/organ/liver/alien = 3,
		/obj/item/organ/stomach/plasmaman = 3,
		/obj/item/organ/lungs/plasmaman = 3,
		/obj/item/organ/lungs/slime = 3,
		/obj/item/organ/tongue/abductor = 1,
		/obj/item/organ/tongue/alien = 1,
		/obj/item/organ/tongue/bone = 3,
		/obj/item/organ/tongue/bone/plasmaman = 1,
		/obj/item/organ/vocal_cords/adamantine = 1,
		/obj/effect/gibspawner/xeno = 1,
		/obj/effect/mob_spawn/human/corpse/assistant = 1,
		/obj/item/organ/wings/moth/robust = 1,
		/obj/item/organ/wings/dragon = 1
	)

/obj/effect/spawner/random/medical/teratoma/major/clown
	name = "major clown teratoma spawner"
	loot = list(
		/mob/living/simple_animal/cluwne = 1,
		/mob/living/simple_animal/hostile/retaliate/clown/lube = 1,
		/mob/living/simple_animal/hostile/retaliate/clown/fleshclown = 1,
		/mob/living/simple_animal/hostile/retaliate/clown/mutant = 1,
		/obj/item/clothing/mask/gas/clown_hat = 4,
		/obj/item/clothing/shoes/clown_shoes = 3,
		/obj/item/bikehorn = 5,
		/obj/item/food/pie/cream = 3
	)

/obj/effect/spawner/random/medical/teratoma/robot
	name = "robotic teratoma spawner"
	loot = list(
		/obj/item/organ/ears/robot = 5,
		/obj/item/organ/eyes/robotic = 5,
		/obj/item/organ/eyes/robotic/flashlight = 1,
		/obj/item/organ/eyes/night_vision = 1,
		/obj/item/organ/liver/cybernetic = 4,
		/obj/item/organ/liver/cybernetic/upgraded/ipc = 3,
		/obj/item/organ/lungs/cybernetic = 4,
		/obj/item/organ/lungs/cybernetic/upgraded= 2,
		/obj/item/organ/stomach/battery/ipc = 4,
		/obj/item/organ/heart/clockwork = 6,
		/obj/item/organ/stomach/clockwork = 6,
		/obj/item/organ/liver/clockwork = 6,
		/obj/item/organ/lungs/clockwork = 6,
		/obj/item/organ/tail/clockwork = 6,
		/obj/item/organ/adamantine_resonator = 1,
		/obj/item/organ/eyes/robotic/thermals = 2,
		/obj/item/organ/heart/gland/viral = 1,
		/obj/item/organ/eyes/robotic/shield = 2,
		/obj/item/organ/eyes/robotic/glow = 2,
		/obj/item/organ/heart/cybernetic = 2,
		/obj/item/organ/wings/cybernetic = 2,
		/obj/item/organ/tongue/robot/clockwork/better = 2,
		/obj/effect/gibspawner/robot = 4,
		/obj/effect/mob_spawn/drone = 1,
		)
