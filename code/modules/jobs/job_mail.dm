//All of the /tg/ mail non-junk job items are in here for modularity and easy editing later.


//ASSISTANT
/datum/job/assistant
	mail_goodies = list(
		/obj/item/reagent_containers/food/snacks/donkpocket/random = 10,
		/obj/item/clothing/mask/gas/old = 10,
		/obj/item/clothing/gloves/color/fyellow = 7,
		/obj/item/choice_beacon/music = 5,
		/obj/item/toy/crayon/spraycan = 3,
		/obj/item/crowbar/large = 2,
	)

//ATMOSPHERIC TECHNICIAN
/datum/job/atmospheric_technician
	mail_goodies = list(
		/obj/item/book/manual/wiki/atmospherics = 12,
		/obj/item/tank/internals/emergency_oxygen/engi = 10,
		/obj/item/clothing/mask/gas = 10,
		/obj/effect/spawner/mail/maintloot = 7,
		/obj/item/tank/internals/plasma/empty = 5,
		/obj/item/crowbar/large = 3,
	)

//BART ENDER
/datum/job/bartender
	mail_goodies = list(
		/obj/item/storage/box/rubbershot = 30,
		/obj/item/reagent_containers/glass/bottle/clownstears = 10,
		/obj/item/stack/sheet/mineral/plasma = 5,
		/obj/item/stack/sheet/mineral/uranium = 5,
		/obj/item/reagent_containers/food/drinks/bottle/fernet = 3,
		/obj/item/reagent_containers/food/drinks/bottle/champagne = 3,
		/obj/item/reagent_containers/food/drinks/bottle/trappist = 3,
	)

//BOTANIST
/datum/job/botanist
	mail_goodies = list(
		/obj/item/reagent_containers/glass/bottle/saltpetre = 15,
		/obj/item/reagent_containers/glass/bottle/diethylamine = 15,
		/obj/item/reagent_containers/glass/bottle/toxin/mutagen = 12,
		/obj/item/grenade/chem_grenade/antiweed = 10,
		/obj/item/gun/energy/floragun = 5,
		// These are strong, rare seeds, so use sparingly.
		/obj/item/seeds/random = 2,
	)

//BRIG PHYSICIAN
/datum/job/brig_physician
	mail_goodies = list(
		/obj/item/reagent_containers/hypospray/medipen = 15,
		/obj/item/reagent_containers/medspray/silver_sulf = 10,
		/obj/item/reagent_containers/medspray/styptic = 10,
		/obj/item/reagent_containers/hypospray/medipen/survival = 5,
		//The ultimate validhunter tool
		/obj/item/clothing/glasses/hud/medsec = 2,
		/obj/item/healthanalyzer/advanced = 2,
	)

//CAPTAIN
/datum/job/captain
	mail_goodies = list(
		/obj/item/clothing/mask/cigarette/cigar/havana = 15,
		/obj/item/pen/fountain/captain = 10,
		/obj/item/coin/plasma = 7,
		/obj/item/storage/fancy/cigarettes/cigars/havana = 5,
		/obj/item/reagent_containers/food/drinks/bottle/champagne = 5,
		/obj/item/ammo_box/n762 = 2,
		/obj/item/gun/ballistic/revolver/nagant = 1,
	)

//CARGO TECH
/datum/job/cargo_technician
	mail_goodies = list(
		/obj/effect/spawner/mail/maintloot = 15,
		/obj/item/pizzabox = 10,
		/obj/item/ammo_box/a762 = 3,
		//URAAAAHH
		/obj/item/gun/ballistic/rifle/boltaction = 1,
	)

//CHAPLAIN
/datum/job/chaplain
	mail_goodies = list(
		/obj/item/reagent_containers/food/drinks/bottle/holywater = 15,
		/obj/item/storage/book/bible = 10,
		/obj/item/grenade/chem_grenade/holy = 5,
		/obj/item/toy/plush/awakenedplushie = 3,
		/obj/item/toy/plush/narplush = 2,
		/obj/item/toy/plush/plushvar = 2,
	)

//CHEMIST
/datum/job/chemist
	mail_goodies = list(
		/obj/item/reagent_containers/glass/bottle/flash_powder = 15,
		/obj/item/reagent_containers/dropper = 10,
		/obj/item/reagent_containers/glass/beaker/large = 10,
		/obj/item/reagent_containers/glass/beaker/plastic = 10,
		/obj/item/reagent_containers/glass/bottle/ketamine = 5,
	)

//CHIEF ENGINEER
/datum/job/chief_engineer
	mail_goodies = list(
		//you know. for poly
		/obj/item/reagent_containers/food/snacks/cracker = 15,
		/obj/item/reagent_containers/food/drinks/soda_cans/thirteenloko = 15,
		/obj/item/rcd_ammo = 10,
		/obj/item/wrench/caravan = 3,
		/obj/item/wirecutters/caravan = 3,
		/obj/item/screwdriver/caravan = 3,
		/obj/item/crowbar/red/caravan = 3,
		//if you got this, you hit the lottery
		/obj/item/construction/rcd/arcd = 1,
	)

//CHIEF MEDICAL OFFICER
/datum/job/chief_medical_officer
	mail_goodies = list(
		//it's just a memo, just sayin'...
		/obj/item/paper/fluff/jobs/medical/hippocratic = 15,
		/obj/effect/spawner/mail/organminor = 12,
		/obj/effect/spawner/mail/organmajor = 8,
		/obj/item/sensor_device = 5,
		/obj/effect/spawner/mail/advmedtool = 4,
		/obj/effect/spawner/mail/ayymedtool = 1,
	)

//CLOWN
/datum/job/clown
	mail_goodies = list(
		/obj/item/reagent_containers/food/snacks/grown/banana = 20,
		/obj/item/reagent_containers/food/snacks/pie/cream = 15,
		/obj/item/clothing/shoes/clown_shoes/combat = 5,
		// lube
		/obj/item/reagent_containers/spray/waterflower/lube = 3,
		// Superlube, good lord.
		/obj/item/reagent_containers/spray/waterflower/superlube = 2,
		//An entire fucking clown, an aggressive one, why? The station is a circus anyway...
		/mob/living/simple_animal/hostile/retaliate/clown = 1,
	)

//COOK
/datum/job/cook
	mail_goodies = list(
		/obj/item/reagent_containers/glass/bottle/caramel = 20,
		/obj/item/reagent_containers/food/condiment/flour = 20,
		/obj/item/reagent_containers/food/condiment/rice = 20,
		/obj/item/reagent_containers/food/condiment/enzyme = 15,
		/obj/item/reagent_containers/food/condiment/soymilk = 15,
		/obj/item/reagent_containers/food/condiment/milk = 15,
		//UR SO FAT!
		/obj/item/reagent_containers/food/snacks/mint = 12,
		/obj/item/storage/box/ingredients/wildcard = 10,
		//EEEEEEEK
		/obj/item/storage/box/monkeycubes = 5,
		/obj/item/kitchen/knife = 4,
		/obj/item/storage/box/ingredients/exotic = 3,
		/obj/item/kitchen/knife/butcher = 2,
	)

//CURATOR
/datum/job/curator
	mail_goodies = list(
		/obj/item/paper_bin/bundlenatural = 12,
		/obj/item/camera_film = 10,
		/obj/item/tape = 10,
		/obj/item/storage/toolbox/artistic = 10,
		/obj/item/storage/fancy/candle_box = 7,
		/obj/item/pen/fountain = 5,
		/obj/item/storage/pill_bottle/dice_cup = 5,
		//maybe better than a lame PAi after all
		/obj/item/toy/plush/flushed = 5,
		//rare, but not that much...
		/obj/item/paicard = 2,
	)

//DEPUTY...IS THIS JOB EVEN ACTIVE? I DON'T THINK IT IS
/datum/job/deputy
	mail_goodies = list(
		/obj/effect/spawner/mail/donut = 20,
		/obj/effect/spawner/mail/rdonut = 15,
		/obj/item/melee/baton = 1,
	)

//DETECTIVE
/datum/job/detective
	mail_goodies = list(
		/obj/item/storage/fancy/cigarettes = 15,
		/obj/item/ammo_box/c38 = 10,
		/obj/item/reagent_containers/food/drinks/bottle/rum = 10,
		/obj/item/ammo_box/c38/dumdum = 5,
		/obj/item/ammo_box/c38/hotshot = 5,
		/obj/item/ammo_box/c38/iceblox = 5,
		/obj/item/ammo_box/c38/match = 5,
		/obj/item/ammo_box/c38/trac = 5,
		//you'll get this inevitably when you don't need it.
		/obj/item/clothing/accessory/holster/detective = 1,
	)

//PARAMEDIC
/datum/job/paramedic
	mail_goodies = list(
		/obj/item/reagent_containers/hypospray/medipen = 20,
		/obj/item/reagent_containers/medspray/silver_sulf = 10,
		/obj/item/reagent_containers/medspray/styptic = 10,
		/obj/item/reagent_containers/hypospray/medipen/dexalin = 10,
		/obj/item/sensor_device = 7,
		/obj/item/pinpointer/crew = 7,
		/obj/item/reagent_containers/hypospray/medipen/survival = 5,
		/obj/item/reagent_containers/hypospray/medipen/pumpup = 1,
	)

//EXPLORATION CREW
//Slightly more powerful due to the rarity of them ever actually getting a chance to get their mail.
/datum/job/exploration_crew
	mail_goodies = list(
		/obj/item/tank/internals/emergency_oxygen/engi = 20,
		/obj/item/storage/box/minertracker = 15,
		/obj/item/stack/sheet/mineral/plasma/five = 15,
		/obj/item/reagent_containers/hypospray/medipen/survival = 10,
		/obj/item/stack/marker_beacon/thirty = 5,
		/obj/item/extraction_pack = 5,
		/obj/item/gps/mining/exploration = 5,
	)

//GENETICIST
/datum/job/geneticist
	mail_goodies = list(
		/obj/item/reagent_containers/pill/mutadone = 15,
		/obj/item/storage/pill_bottle/mannitol = 10,
		/obj/item/reagent_containers/food/snacks/monkeycube = 10,
		/obj/effect/spawner/mail/genes = 5,
	)

//HEAD OF PERSONNEL
/datum/job/head_of_personnel
	mail_goodies = list(
		/obj/item/card/id/silver = 10,
		/obj/item/assembly/flash/handheld = 5,
		/obj/item/mining_voucher = 5,
		/obj/item/stack/sheet/bone = 5,
		//a slim chance for reviving ian... how exicting
		/obj/item/lazarus_injector = 1,
	)

//HEAD OF SECURITY
/datum/job/head_of_security
	mail_goodies = list(
		/obj/effect/spawner/mail/donut = 20,
		/obj/effect/spawner/mail/rdonut = 15,
		/obj/item/firing_pin = 10,
		/obj/item/implantcase/mindshield = 7,
		//Vile, vile person...
		/obj/item/clothing/head/kitty = 5,
		//hey, always come in handy!
		/obj/item/storage/lockbox/loyalty = 2,
	)

//JANITOR
/datum/job/janitor
	mail_goodies = list(
		/obj/item/grenade/chem_grenade/cleaner = 30,
		/obj/item/storage/box/lights/mixed = 20,
		/obj/item/lightreplacer = 10,
		//ha!
		/obj/item/clothing/under/rank/civilian/janitor/maid = 5,
		/obj/item/grenade/clusterbuster/cleaner = 2,
	)

//LAWYER
/datum/job/lawyer
	mail_goodies = list(
		//Can never have enough LAW
		/obj/item/book/manual/wiki/security_space_law = 15,
		/obj/item/clothing/accessory/lawyers_badge = 10,
		/obj/item/storage/secure/briefcase = 10,
		//an emergency hammer is always nice!
		/obj/item/gavelhammer = 10,
		//What else are you gonna do as a lawyer? Fancy a game of solitaire?
		/obj/item/toy/cards/deck = 10,
		/obj/item/clothing/glasses/sunglasses/advanced/big = 5,
		/obj/item/book/manual/wiki/security_space_law = 5,
		//Harassing security has never been this fun
		/obj/item/megaphone = 3,
	)

//MAGICIAN GIMMICK
/datum/job/gimmick/stage_magician
	mail_goodies = list(
		//AND FOR MY NEXT TRICK... Bunny
		/obj/item/clothing/head/mob_holder/rabbit = 40,
		/obj/item/gun/magic/wand = 10,
		/obj/item/clothing/head/collectable/tophat = 10,
		/obj/item/clothing/head/bowler = 5,
	)

//MEDICAL DOCTOR
/datum/job/medical_doctor
	mail_goodies = list(
		/obj/item/healthanalyzer/advanced = 10,
		/obj/item/storage/pill_bottle/epinephrine = 8,
		/obj/item/reagent_containers/glass/bottle/formaldehyde = 6,
		/obj/effect/spawner/mail/advmedtool = 4,
		/obj/effect/spawner/mail/organminor = 5,
		/obj/effect/spawner/mail/organmajor = 1,
	)

//MIME
/datum/job/mime
	mail_goodies = list(
		/obj/item/reagent_containers/food/snacks/baguette/mime = 15,
		/obj/item/reagent_containers/food/snacks/store/cheesewheel = 10,
		/obj/item/reagent_containers/food/drinks/bottle/bottleofnothing = 10,
		/obj/item/book/mimery = 2,
		//when you thought it could get worse...
		/obj/item/book/granter/spell/mimery_blockade = 1,
	)

//PSYCHOLOGIST / PSYCHIATRIST GIMMICK
/datum/job/gimmick/psychiatrist
	mail_goodies =  list(
		/obj/item/storage/pill_bottle/mannitol = 30,
		/obj/item/storage/pill_bottle/happy = 5,
		/obj/item/gun/syringe = 1,
	)

//QUARTERMASTER
/datum/job/quartermaster
	mail_goodies = list(
		/obj/item/reagent_containers/food/snacks/donkpocket/random = 10,
		//the beginning of your department's independence
		/obj/item/banner/cargo = 5,
		//if you want to watch the world burn, this is it.
		/obj/item/circuitboard/machine/emitter = 3,
		/obj/item/ammo_box/a762 = 3,
		//URAAAAHH
		/obj/item/gun/ballistic/rifle/boltaction = 1,
	)

//RESEARCH DIRECTOR
/datum/job/research_director
	mail_goodies = list(
		/obj/item/storage/box/monkeycubes = 15,
		// it's hard to not look cool
		/obj/item/clothing/glasses/science/sciencesun = 10,
		/obj/item/taperecorder = 7,
		/obj/item/disk/tech_disk/research/random  = 4,
		/obj/item/borg/upgrade/ai = 2,
	)

//ROBOTICIST
/datum/job/roboticist
	mail_goodies = list(
		//you'll always run out of iron regardless...
		/obj/item/stack/sheet/iron/twenty = 15,
		/obj/item/storage/box/flashes = 10,
		//eh.
		/obj/item/clothing/glasses/hud/diagnostic/sunglasses = 7,
		/obj/item/borg/upgrade/rename = 5,
		//do anyone ever use this???
		/obj/item/modular_computer/tablet/preset/advanced = 5,
	)

//SCIENTIST
/datum/job/scientist
	mail_goodies = list(
		/obj/item/anomaly_neutralizer = 10,
		/obj/item/disk/tech_disk = 7,
		//STUFF
		/obj/effect/spawner/mail/science = 4,
	)

//SECURITY OFFICER
/datum/job/security_officer
	mail_goodies = list(
		/obj/item/reagent_containers/food/snacks/donut/plain = 15,
		/obj/effect/spawner/mail/donut = 10,
		//just in case...
		/obj/item/assembly/flash/handheld = 7,
		/obj/effect/spawner/mail/rdonut = 5,
		//we don't have boomerangs here, ask ausstation
		/obj/item/melee/classic_baton/police/telescopic = 1,
	)

//SHAFT MINER
/datum/job/shaft_miner
	mail_goodies = list(
		/obj/item/reagent_containers/hypospray/medipen/survival = 10,
		/obj/item/tank/internals/emergency_oxygen/double = 7,
		/obj/item/storage/pill_bottle/mining = 5,
		/obj/item/storage/belt/mining/alt = 5,
		//THE DRIP!!!
		/obj/item/clothing/glasses/material/mining/gar = 1,
	)

//ENGINEER
/datum/job/station_engineer
	mail_goodies = list(
		/obj/item/storage/box/lights/mixed = 15,
		/obj/item/reagent_containers/food/drinks/soda_cans/thirteenloko = 15,
		/obj/item/lightreplacer = 10,
		/obj/item/holosign_creator/engineering = 8,
		//An assistant can only dream of those...
		/obj/item/clothing/gloves/color/yellow = 4,
	)

//VIROLOGIST
/datum/job/virologist
	mail_goodies = list(
		/obj/item/reagent_containers/syringe/used = 15,
		//keep your workplace clean, please.
		/obj/item/reagent_containers/spray/cleaner = 15,
		/obj/item/reagent_containers/food/snacks/monkeycube = 10,
		/obj/item/reagent_containers/glass/bottle/formaldehyde = 10,
		/obj/item/reagent_containers/glass/bottle/random_virus/minor = 10,
		/obj/item/reagent_containers/glass/bottle/random_virus = 5,
		/obj/item/stock_parts/scanning_module/phasic = 5,
		//hampter.
		/obj/item/choice_beacon/pet/hamster = 5,

	)

//VIP / VIP GIMMICK
/datum/job/gimmick/vip
	mail_goodies = list(
		//WOW THE NEW BEATS BY DR.MOFF?
		/obj/item/clothing/ears/headphones = 10,
		//Only on the iScream 12
		/obj/item/clothing/under/syndicate/tacticool = 10,
		/obj/item/reagent_containers/food/drinks/flask/gold = 10,
		/obj/item/choice_beacon/pet = 5,
		/obj/item/storage/bag/money = 5,
		/obj/item/coin/gold = 5,
		/obj/item/coin/silver = 5,
		//Tiny chance to harass the entire crew
		/obj/item/encryptionkey/heads/captain = 1,
	)

//WARDEN
/datum/job/warden
	mail_goodies = list(
		/obj/item/storage/fancy/donut_box = 15,
		/obj/effect/spawner/mail/donut = 15,
		/obj/effect/spawner/mail/rdonut= 10,
		/obj/item/storage/box/teargas = 10,
		/obj/item/storage/box/rubbershot = 10,
		/obj/item/storage/box/lethalshot = 5,
		/obj/item/storage/box/handcuffs = 5,
		/obj/item/melee/classic_baton/police/telescopic = 1,
		)
