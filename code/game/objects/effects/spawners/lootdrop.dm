/obj/effect/spawner/lootdrop
	icon = 'icons/effects/landmarks_spawners.dmi'
	icon_state = "random_loot"
	layer = OBJ_LAYER
	var/lootcount = 1		//how many items will be spawned
	var/lootdoubles = TRUE	//if the same item can be spawned twice
	var/list/loot			//a list of possible items to spawn e.g. list(/obj/item, /obj/structure, /obj/effect)
	var/fan_out_items = FALSE //Whether the items should be distributed to offsets 0,1,-1,2,-2,3,-3.. This overrides pixel_x/y on the spawner itself

/obj/effect/spawner/lootdrop/Initialize(mapload)
	. = ..()
	spawn_loot()

/obj/effect/spawner/lootdrop/proc/spawn_loot()
	if(!length(loot))
		return
	var/turf/T = get_turf(src)
	var/loot_spawned = 0
	while((lootcount-loot_spawned) && loot.len)
		var/lootspawn = pick_weight(loot)
		if(!lootdoubles)
			loot.Remove(lootspawn)

		if(lootspawn)
			var/atom/movable/spawned_loot = new lootspawn(T)
			if (!fan_out_items)
				if (pixel_x != 0)
					spawned_loot.pixel_x = pixel_x
				if (pixel_y != 0)
					spawned_loot.pixel_y = pixel_y
			else
				if (loot_spawned)
					spawned_loot.pixel_x = spawned_loot.pixel_y = ((!(loot_spawned%2)*loot_spawned/2)*-1)+((loot_spawned%2)*(loot_spawned+1)/2*1)
		loot_spawned++


/obj/effect/spawner/lootdrop/donkpockets
	icon_state = "random_donk"
	name = "donk pocket box spawner"
	lootdoubles = FALSE

	loot = list(
			/obj/item/storage/box/donkpockets/donkpocketspicy = 1,
			/obj/item/storage/box/donkpockets/donkpocketteriyaki = 1,
			/obj/item/storage/box/donkpockets/donkpocketpizza = 1,
			/obj/item/storage/box/donkpockets/donkpocketberry = 1,
			/obj/item/storage/box/donkpockets/donkpockethonk = 1,
			/obj/item/storage/box/donkpockets = 1
		)

/obj/effect/spawner/lootdrop/donkpocketsfinlandia
	icon_state = "random_donk"
	name = "5% gondola pocket spawner"
	lootdoubles = FALSE

	loot = list(
			/obj/item/storage/box/donkpockets = 19,
			/obj/item/storage/box/donkpockets/donkpocketgondolafinlandia = 1
		)

/obj/effect/spawner/lootdrop/armory_contraband
	icon_state = "random_contrabband"
	name = "armory contraband gun spawner"
	lootdoubles = FALSE

	loot = list(
				/obj/item/gun/ballistic/automatic/pistol/locker = 8,
				/obj/item/gun/ballistic/shotgun/automatic/combat = 3,
				/obj/item/gun/ballistic/revolver/mateba,
				/obj/item/gun/ballistic/automatic/pistol/deagle,
				/obj/item/storage/box/syndie_kit/throwing_weapons = 3,
				/obj/item/grenade/clusterbuster
				)

/obj/effect/spawner/lootdrop/gambling
	icon_state = "random_gambling"
	name = "gambling valuables spawner"
	loot = list(
				/obj/item/gun/ballistic/revolver/russian = 5,
				/obj/item/storage/box/syndie_kit/throwing_weapons = 1,
				/obj/item/toy/cards/deck/syndicate = 2
				)

/obj/effect/spawner/lootdrop/grille_or_trash
	icon_state = "random_grille"
	name = "maint grille or trash spawner"
	loot = list(/obj/structure/grille = 5,
			/obj/item/cigbutt = 1,
			/obj/item/trash/cheesie = 1,
			/obj/item/trash/candy = 1,
			/obj/item/trash/chips = 1,
			/obj/item/reagent_containers/food/snacks/deadmouse = 1,
			/obj/item/trash/pistachios = 1,
			/obj/item/trash/plate = 1,
			/obj/item/trash/popcorn = 1,
			/obj/item/trash/raisins = 1,
			/obj/item/trash/sosjerky = 1,
			/obj/item/trash/syndi_cakes = 1)

/obj/effect/spawner/lootdrop/three_course_meal
	name = "three course meal spawner"
	lootcount = 3
	lootdoubles = FALSE
	var/soups = list(
			/obj/item/reagent_containers/food/snacks/soup/beet,
			/obj/item/reagent_containers/food/snacks/soup/sweetpotato,
			/obj/item/reagent_containers/food/snacks/soup/stew,
			/obj/item/reagent_containers/food/snacks/soup/hotchili,
			/obj/item/reagent_containers/food/snacks/soup/nettle,
			/obj/item/reagent_containers/food/snacks/soup/meatball)
	var/salads = list(
			/obj/item/reagent_containers/food/snacks/salad/herbsalad,
			/obj/item/reagent_containers/food/snacks/salad/validsalad,
			/obj/item/reagent_containers/food/snacks/salad/fruit,
			/obj/item/reagent_containers/food/snacks/salad/jungle,
			/obj/item/reagent_containers/food/snacks/salad/aesirsalad)
	var/mains = list(
			/obj/item/reagent_containers/food/snacks/bearsteak,
			/obj/item/reagent_containers/food/snacks/enchiladas,
			/obj/item/reagent_containers/food/snacks/stewedsoymeat,
			/obj/item/reagent_containers/food/snacks/burger/bigbite,
			/obj/item/reagent_containers/food/snacks/burger/superbite,
			/obj/item/reagent_containers/food/snacks/burger/fivealarm)

/obj/effect/spawner/lootdrop/three_course_meal/Initialize(mapload)
	loot = list(pick(soups) = 1,pick(salads) = 1,pick(mains) = 1)
	. = ..()

/obj/effect/spawner/lootdrop/maintenance
	name = "maintenance loot spawner"
	// see code/_globalvars/lists/maintenance_loot.dm for loot table

/obj/effect/spawner/lootdrop/maintenance/Initialize(mapload)
	loot = GLOB.maintenance_loot

	if(HAS_TRAIT(SSstation, STATION_TRAIT_FILLED_MAINT))
		lootcount = FLOOR(lootcount * 1.5, 1)

	else if(HAS_TRAIT(SSstation, STATION_TRAIT_EMPTY_MAINT))
		lootcount = FLOOR(lootcount * 0.5, 1)

	. = ..()

/obj/effect/spawner/lootdrop/maintenance/two
	name = "2 x maintenance loot spawner"
	lootcount = 2

/obj/effect/spawner/lootdrop/maintenance/three
	name = "3 x maintenance loot spawner"
	lootcount = 3

/obj/effect/spawner/lootdrop/maintenance/four
	name = "4 x maintenance loot spawner"
	lootcount = 4

/obj/effect/spawner/lootdrop/maintenance/five
	name = "5 x maintenance loot spawner"
	lootcount = 5

/obj/effect/spawner/lootdrop/maintenance/six
	name = "6 x maintenance loot spawner"
	lootcount = 6

/obj/effect/spawner/lootdrop/maintenance/seven
	name = "7 x maintenance loot spawner"
	lootcount = 7

/obj/effect/spawner/lootdrop/maintenance/eight
	name = "8 x maintenance loot spawner"
	lootcount = 8

/obj/effect/spawner/lootdrop/crate_spawner
	name = "lootcrate spawner" //USE PROMO CODE "SELLOUT" FOR 20% OFF!
	lootdoubles = FALSE

	loot = list(
				/obj/structure/closet/crate/secure/loot = 20,
				"" = 80
				)

/obj/effect/spawner/lootdrop/organ_spawner
	name = "organ spawner"
	loot = list(
		/obj/item/organ/heart/gland/electric = 3,
		/obj/item/organ/heart/gland/trauma = 4,
		/obj/item/organ/heart/gland/egg = 7,
		/obj/item/organ/heart/gland/chem = 5,
		/obj/item/organ/heart/gland/mindshock = 5,
		/obj/item/organ/heart/gland/plasma = 7,
		/obj/item/organ/heart/gland/pop = 5,
		/obj/item/organ/heart/gland/slime = 4,
		/obj/item/organ/heart/gland/spiderman = 5,
		/obj/item/organ/heart/gland/ventcrawling = 1,
		/obj/item/organ/body_egg/alien_embryo = 1,
		/obj/item/organ/regenerative_core = 2)
	lootcount = 3

/obj/effect/spawner/lootdrop/teratoma/minor
	name = "teratoma spawner"
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
		/obj/item/organ/wings/dragon/fake = 1)

/obj/effect/spawner/lootdrop/teratoma/major
	name = "advanced teratoma spawner"
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
		/obj/item/organ/wings/dragon = 1)

/obj/effect/spawner/lootdrop/teratoma/robot
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

/obj/effect/spawner/lootdrop/teratoma/major/clown
	name = "funny teratoma spawner"
	loot = list(
		/mob/living/simple_animal/cluwne = 1,
		/mob/living/simple_animal/hostile/retaliate/clown/lube = 1,
		/mob/living/simple_animal/hostile/retaliate/clown/fleshclown = 1,
		/mob/living/simple_animal/hostile/retaliate/clown/mutant = 1,
		/obj/item/clothing/mask/gas/clown_hat = 4,
		/obj/item/clothing/shoes/clown_shoes = 3,
		/obj/item/bikehorn = 5,
		/obj/item/reagent_containers/food/snacks/pie/cream = 3)

/obj/effect/spawner/lootdrop/two_percent_xeno_egg_spawner
	name = "2% chance xeno egg spawner"
	icon_state = "random_xenoegg"
	loot = list(
		/obj/effect/decal/remains/xeno = 49,
		/obj/effect/spawner/xeno_egg_delivery = 1)

/obj/effect/spawner/lootdrop/two_percent_xeno_egg_spawner/Initialize(mapload)
	if(prob(40) && SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
		loot = list(/obj/effect/spawner/xeno_egg_delivery_troll = 1)
	. = ..()

/obj/effect/spawner/lootdrop/ten_percent_girlfriend_spawner
	name = "10% chance girlfriend spawner"
	loot = list(
		/mob/living/simple_animal/pet/dog/corgi = 9,
		/mob/living/simple_animal/pet/dog/corgi/Lisa = 1)

/obj/effect/spawner/lootdrop/sanitarium
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
		/mob/living/simple_animal/pet/gondola = 2,
		/mob/living/simple_animal/hostile/macrophage/aggro/vector = 2,
		/mob/living/simple_animal/hostile/retaliate/spaceman = 2,
		/obj/effect/mob_spawn/human/corpse/assistant/brainrot_infection = 1,
		/mob/living/simple_animal/hostile/retaliate/frog = 2)

/obj/effect/spawner/lootdrop/costume
	icon_state = "random_costume"
	name = "random costume spawner"

/obj/effect/spawner/lootdrop/costume/Initialize(mapload)
	loot = list()
	for(var/path in subtypesof(/obj/effect/spawner/bundle/costume))
		loot[path] = TRUE
	. = ..()

// Minor lootdrops follow

/obj/effect/spawner/lootdrop/minor/beret_or_rabbitears
	name = "beret or rabbit ears spawner"
	loot = list(
		/obj/item/clothing/head/beret = 1,
		/obj/item/clothing/head/rabbitears = 1)

/obj/effect/spawner/lootdrop/minor/bowler_or_that
	name = "bowler or top hat spawner"
	loot = list(
		/obj/item/clothing/head/bowler = 1,
		/obj/item/clothing/head/that = 1)

/obj/effect/spawner/lootdrop/minor/kittyears_or_rabbitears
	name = "kitty ears or rabbit ears spawner"
	loot = list(
		/obj/item/clothing/head/kitty = 1,
		/obj/item/clothing/head/rabbitears = 1)

/obj/effect/spawner/lootdrop/minor/pirate_or_bandana
	name = "pirate hat or bandana spawner"
	loot = list(
		/obj/item/clothing/head/pirate = 1,
		/obj/item/clothing/head/bandana = 1)

/obj/effect/spawner/lootdrop/minor/twentyfive_percent_cyborg_mask
	name = "25% cyborg mask spawner"
	loot = list(
		/obj/item/clothing/mask/gas/cyborg = 25,
		"" = 75)

/obj/effect/spawner/lootdrop/aimodule_harmless // These shouldn't allow the AI to start butchering people
	icon_state = "random_board"
	name = "harmless AI module spawner"
	loot = list(
				/obj/item/aiModule/core/full/asimov,
				/obj/item/aiModule/core/full/asimovpp,
				/obj/item/aiModule/core/full/hippocratic,
				/obj/item/aiModule/core/full/paladin_devotion,
				/obj/item/aiModule/core/full/paladin
				)

/obj/effect/spawner/lootdrop/aimodule_neutral // These shouldn't allow the AI to start butchering people without reason
	icon_state = "random_board"
	name = "neutral AI module spawner"
	loot = list(
				/obj/item/aiModule/core/full/corp,
				/obj/item/aiModule/core/full/maintain,
				/obj/item/aiModule/core/full/drone,
				/obj/item/aiModule/core/full/peacekeeper,
				/obj/item/aiModule/core/full/reporter,
				/obj/item/aiModule/core/full/robocop,
				/obj/item/aiModule/core/full/liveandletlive,
				/obj/item/aiModule/core/full/hulkamania
				)

/obj/effect/spawner/lootdrop/aimodule_harmful // These will get the shuttle called
	icon_state = "random_board"
	name = "harmful AI module spawner"
	loot = list(
				/obj/item/aiModule/core/full/antimov,
				/obj/item/aiModule/core/full/balance,
				/obj/item/aiModule/core/full/tyrant,
				/obj/item/aiModule/core/full/thermurderdynamic,
				/obj/item/aiModule/core/full/damaged
				)

// Tech storage circuit board spawners

/obj/effect/spawner/lootdrop/techstorage

	name = "generic circuit board spawner"
	icon_state = "random_board"
	lootdoubles = FALSE
	fan_out_items = TRUE
	lootcount = INFINITY

/obj/effect/spawner/lootdrop/techstorage/service
	name = "service circuit board spawner"
	loot = list(
				/obj/item/circuitboard/computer/arcade/battle,
				/obj/item/circuitboard/computer/arcade/orion_trail,
				/obj/item/circuitboard/machine/autolathe,
				/obj/item/circuitboard/computer/mining,
				/obj/item/circuitboard/machine/ore_redemption,
				/obj/item/circuitboard/machine/mining_equipment_vendor,
				/obj/item/circuitboard/machine/microwave,
				/obj/item/circuitboard/machine/chem_dispenser/drinks,
				/obj/item/circuitboard/machine/chem_dispenser/drinks/beer,
				/obj/item/circuitboard/computer/slot_machine
				)

/obj/effect/spawner/lootdrop/techstorage/rnd
	name = "RnD circuit board spawner"
	loot = list(
				/obj/item/circuitboard/computer/aifixer,
				/obj/item/circuitboard/machine/rdserver,
				/obj/item/circuitboard/machine/mechfab,
				/obj/item/circuitboard/machine/circuit_imprinter/department,
				/obj/item/circuitboard/computer/teleporter,
				/obj/item/circuitboard/machine/destructive_analyzer,
				/obj/item/circuitboard/computer/rdconsole,
				/obj/item/circuitboard/computer/nanite_chamber_control,
				/obj/item/circuitboard/computer/nanite_cloud_controller,
				/obj/item/circuitboard/machine/nanite_chamber,
				/obj/item/circuitboard/machine/nanite_programmer,
				/obj/item/circuitboard/machine/nanite_program_hub,
				/obj/item/circuitboard/machine/xenoartifact_inbox,
				/obj/item/circuitboard/computer/xenoartifact_console
				)

/obj/effect/spawner/lootdrop/techstorage/security
	name = "security circuit board spawner"
	loot = list(
				/obj/item/circuitboard/computer/secure_data,
				/obj/item/circuitboard/computer/security,
				/obj/item/circuitboard/computer/prisoner
				)

/obj/effect/spawner/lootdrop/techstorage/engineering
	name = "engineering circuit board spawner"
	loot = list(
				/obj/item/circuitboard/computer/atmos_alert,
				/obj/item/circuitboard/computer/stationalert,
				/obj/item/circuitboard/computer/powermonitor
				)

/obj/effect/spawner/lootdrop/techstorage/tcomms
	name = "tcomms circuit board spawner"
	loot = list(
				/obj/item/circuitboard/computer/message_monitor,
				/obj/item/circuitboard/machine/telecomms/broadcaster,
				/obj/item/circuitboard/machine/telecomms/bus,
				/obj/item/circuitboard/machine/telecomms/server,
				/obj/item/circuitboard/machine/telecomms/receiver,
				/obj/item/circuitboard/machine/telecomms/processor,
				/obj/item/circuitboard/machine/announcement_system,
				/obj/item/circuitboard/computer/comm_server,
				/obj/item/circuitboard/computer/comm_monitor
				)

/obj/effect/spawner/lootdrop/techstorage/medical
	name = "medical circuit board spawner"
	loot = list(
				/obj/item/circuitboard/computer/cloning,
				/obj/item/circuitboard/machine/clonepod,
				/obj/item/circuitboard/machine/chem_dispenser,
				/obj/item/circuitboard/computer/scan_consolenew,
				/obj/item/circuitboard/computer/med_data,
				/obj/item/circuitboard/machine/smoke_machine,
				/obj/item/circuitboard/machine/chem_master,
				/obj/item/circuitboard/machine/clonescanner,
				/obj/item/circuitboard/computer/pandemic
				)

/obj/effect/spawner/lootdrop/techstorage/AI
	name = "secure AI circuit board spawner"
	loot = list(
				/obj/item/circuitboard/computer/aiupload,
				/obj/item/circuitboard/computer/borgupload,
				/obj/item/circuitboard/aicore
				)

/obj/effect/spawner/lootdrop/techstorage/command
	name = "secure command circuit board spawner"
	loot = list(
				/obj/item/circuitboard/computer/crew,
				/obj/item/circuitboard/computer/communications,
				/obj/item/circuitboard/computer/card
				)

/obj/effect/spawner/lootdrop/techstorage/RnD_secure
	name = "secure RnD circuit board spawner"
	loot = list(
				/obj/item/circuitboard/computer/mecha_control,
				/obj/item/circuitboard/computer/apc_control,
				/obj/item/circuitboard/computer/robotics
				)

/obj/effect/spawner/lootdrop/trap
	name = "10% pressure plate spawner"
	loot = list(
		/obj/effect/spawner/lootdrop/maintenance = 9,
		/obj/effect/trap/trigger/all = 1)

/obj/effect/spawner/lootdrop/trap/reusable
	loot = list(
		/obj/effect/spawner/lootdrop/maintenance = 9,
		/obj/effect/trap/trigger/reusable/all = 1)

/obj/effect/spawner/lootdrop/clowntrap
	name = "clown trap spawner"
	loot = list(
		/obj/effect/spawner/lootdrop/maintenance = 9,
		/obj/effect/trap/nexus/trickyspawner/clownmutant = 2,
		/obj/effect/trap/nexus/trickyspawner/honkling = 3,
		/obj/effect/trap/nexus/cluwnecurse = 1)

/obj/effect/spawner/lootdrop/megafaunaore
	name = "megafauna ore drop"
	lootcount = 50
	lootdoubles = TRUE
	loot = list(
		/obj/item/stack/ore/iron = 5,
		/obj/item/stack/ore/glass/basalt = 5,
		/obj/item/stack/ore/plasma = 3,
		/obj/item/stack/ore/silver = 3,
		/obj/item/stack/ore/gold = 3,
		/obj/item/stack/ore/copper = 3,
		/obj/item/stack/ore/titanium = 2,
		/obj/item/stack/ore/uranium = 2,
		/obj/item/stack/ore/diamond = 2)

