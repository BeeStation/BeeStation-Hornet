//--------------------------------------------//
//MAIL DEDICATED - FEEL FREE TO PUT IN MAP !!!//
//--------------------------------------------//
/obj/effect/spawner/mail
	name = "\improper Random mail spawner"
	icon = 'icons/effects/landmarks_spawners.dmi'
	icon_state = "random_loot"

/obj/effect/spawner/mail/maintloot
	name = "\improper Random maintenance loot spawner"

/obj/effect/spawner/mail/maintloot/Initialize(mapload)
	var/picked_item = pick_weight(GLOB.maintenance_loot)
	new picked_item(loc)
	return ..()

/obj/effect/spawner/mail/organminor
	name = "\improper Random minor organs spawner"

/obj/effect/spawner/mail/organminor/Initialize(mapload)
	var/static/list/mail_organminor = pick(
		/obj/item/organ/tongue,
		/obj/item/organ/tongue/lizard,
		/obj/item/organ/tail/cat,
		/obj/item/organ/stomach,
		/obj/item/organ/tongue/zombie,
		/obj/item/organ/tongue/fly,
		/obj/item/organ/stomach/fly,
		/obj/item/organ/ears,
		/obj/item/organ/ears/cat,
		/obj/item/organ/eyes/snail,
		/obj/item/organ/eyes/moth,
		/obj/item/organ/eyes,
		/obj/item/organ/heart,
		/obj/item/organ/liver,
		/obj/item/organ/tail/lizard,
		/obj/item/organ/tongue/snail,
		/obj/item/organ/appendix,
		/obj/effect/gibspawner/human,
		/obj/item/organ/wings,
		/obj/item/organ/wings/moth,
		/obj/item/organ/wings/bee,
		/obj/item/organ/wings/dragon/fake,)
	new mail_organminor(loc)
	return ..()

/obj/effect/spawner/mail/organmajor
	name = "\improper Random major organs spawner"

/obj/effect/spawner/mail/organmajor/Initialize(mapload)
	var/static/list/mail_organmajor= pick(
		/obj/item/organ/adamantine_resonator,
		/obj/item/organ/ears/penguin,
		/obj/item/organ/heart/gland/viral,
		/obj/item/organ/eyes/night_vision,
		/obj/item/organ/liver/plasmaman,
		/obj/item/organ/liver/alien,
		/obj/item/organ/stomach/plasmaman,
		/obj/item/organ/lungs/plasmaman,
		/obj/item/organ/lungs/slime,
		/obj/item/organ/tongue/abductor,
		/obj/item/organ/tongue/alien,
		/obj/item/organ/tongue/bone,
		/obj/item/organ/tongue/bone/plasmaman,
		/obj/item/organ/vocal_cords/adamantine,
		/obj/effect/gibspawner/xeno,
		/obj/effect/mob_spawn/human/corpse/assistant,
		/obj/item/organ/wings/moth/robust,
		/obj/item/organ/wings/dragon,)
	new mail_organmajor(loc)
	return ..()

/obj/effect/spawner/mail/advmedtool
	name = "\improper Random advanced medical tool spawner"

/obj/effect/spawner/mail/advmedtool/Initialize(mapload)
	var/static/list/mail_advmedtool= pick(
		/obj/item/scalpel/advanced,
		/obj/item/retractor/advanced,
		/obj/item/cautery/advanced,)
	new mail_advmedtool(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/spawner/mail/ayymedtool
	name = "\improper Random alien medical tool spawner"

/obj/effect/spawner/mail/ayymedtool/Initialize(mapload)
	var/static/list/mail_ayymedtool= pick(
		/obj/item/scalpel/alien,
		/obj/item/hemostat/alien,
		/obj/item/retractor/alien,
		/obj/item/circular_saw/alien,
		/obj/item/surgicaldrill/alien,
		/obj/item/cautery/alien,)
	new mail_ayymedtool(loc)
	return ..()

/obj/effect/spawner/mail/donut
	name = "\improper Random common donut spawner"

/obj/effect/spawner/mail/donut/Initialize(mapload)
	var/static/list/mail_donut= pick(
		/obj/item/food/donut/berry,
		/obj/item/food/donut/apple,
		/obj/item/food/donut/caramel,
		/obj/item/food/donut/choco,
		/obj/item/food/donut/matcha,)
	new mail_donut(loc)
	return ..()

/obj/effect/spawner/mail/rdonut
	name = "\improper Random rare donut spawner"

/obj/effect/spawner/mail/rdonut/Initialize(mapload)
	var/static/list/mail_rdonut= pick(
		/obj/item/food/donut/meat,
		/obj/item/food/donut/trumpet,
		/obj/item/food/donut/blumpkin,
		/obj/item/food/donut/bungo,
		/obj/item/food/donut/chaos,)
	new mail_rdonut(loc)
	return ..()

/obj/effect/spawner/mail/genes
	name = "\improper Random genes spawner"

/obj/effect/spawner/mail/genes/Initialize(mapload)
	var/static/list/mail_genes= pick(
		/obj/item/chromosome/energy,
		/obj/item/chromosome/power,
		/obj/item/chromosome/reinforcer,
		/obj/item/chromosome/stabilizer,
		/obj/item/chromosome/synchronizer,)
	new mail_genes(loc)
	return ..()

/obj/effect/spawner/mail/science
	name = "\improper Random science junk spawner"

/obj/effect/spawner/mail/science/Initialize(mapload)
	var/static/list/mail_science= pick(
		/obj/item/laser_pointer,
		/obj/item/paicard,
		/obj/item/nanite_remote,
		/obj/item/nanite_scanner,
		/obj/item/disk/tech_disk,
		/obj/item/assembly/prox_sensor,
		/obj/item/bodypart/r_arm/robot,
		/obj/item/assembly/flash/handheld/weak,
		/obj/item/stock_parts/cell/high,
		/obj/item/stock_parts/manipulator/nano,
		/obj/item/stock_parts/manipulator,
		/obj/item/stock_parts/capacitor/super,
		/obj/item/stock_parts/matter_bin/super,
		/obj/item/stock_parts/scanning_module/adv,
		/obj/item/storage/box/monkeycubes,
		/obj/item/stack/sheet/mineral/plasma,
		/obj/item/pipe_dispenser,
		/obj/item/assembly/signaler,
		/obj/item/transfer_valve,
		/obj/item/radio,
		/obj/item/camera,
		/obj/item/encryptionkey/headset_sci,
		/obj/item/aicard,
		/obj/item/flamethrower,
		/obj/item/tank/internals/plasma/full,
		/obj/item/gps/science,
		/obj/item/inducer/sci,
		/obj/item/megaphone,
		/obj/item/modular_computer/tablet/pda/roboticist,
		/obj/item/modular_computer/tablet/pda/science,
		/obj/item/anomaly_neutralizer,
		/obj/item/shuttle_creator,
		/obj/item/soap,
		/obj/item/borg/upgrade/selfrepair,
		/obj/item/borg/upgrade/speciality/botany,
		/obj/item/borg/upgrade/defib,
		/obj/item/taperecorder,)
	new mail_science(loc)
	return ..()
