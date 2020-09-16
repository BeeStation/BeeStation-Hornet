#define CAN_DEFAULT_RELEASE_PRESSURE (ONE_ATMOSPHERE)

/obj/machinery/portable_atmospherics/canister
	name = "canister"
	desc = "A canister for the storage of gas."
	icon_state = "yellow"
	density = TRUE
	ui_x = 300
	ui_y = 232

	var/valve_open = FALSE
	var/obj/machinery/atmospherics/components/binary/passive_gate/pump
	var/release_log = ""

	volume = 1000
	var/filled = 0.5
	var/gas_type
	var/release_pressure = ONE_ATMOSPHERE
	var/can_max_release_pressure = (ONE_ATMOSPHERE * 10)
	var/can_min_release_pressure = (ONE_ATMOSPHERE / 10)

	armor = list("melee" = 50, "bullet" = 50, "laser" = 50, "energy" = 100, "bomb" = 10, "bio" = 100, "rad" = 100, "fire" = 80, "acid" = 50)
	max_integrity = 250
	integrity_failure = 100
	pressure_resistance = 7 * ONE_ATMOSPHERE
	var/temperature_resistance = 1000 + T0C
	var/starter_temp
	// Prototype vars
	var/prototype = FALSE
	var/valve_timer = null
	var/timer_set = 30
	var/default_timer_set = 30
	var/minimum_timer_set = 1
	var/maximum_timer_set = 300
	var/timing = FALSE
	var/restricted = FALSE
	req_access = list()

	var/update = 0
	var/static/list/label2types = list(
		"n2" = /obj/machinery/portable_atmospherics/canister/nitrogen,
		"o2" = /obj/machinery/portable_atmospherics/canister/oxygen,
		"co2" = /obj/machinery/portable_atmospherics/canister/carbon_dioxide,
		"plasma" = /obj/machinery/portable_atmospherics/canister/toxins,
		"n2o" = /obj/machinery/portable_atmospherics/canister/nitrous_oxide,
		"no2" = /obj/machinery/portable_atmospherics/canister/nitryl,
		"bz" = /obj/machinery/portable_atmospherics/canister/bz,
		"air" = /obj/machinery/portable_atmospherics/canister/air,
		"water vapor" = /obj/machinery/portable_atmospherics/canister/water_vapor,
		"tritium" = /obj/machinery/portable_atmospherics/canister/tritium,
		"hyper-noblium" = /obj/machinery/portable_atmospherics/canister/nob,
		"stimulum" = /obj/machinery/portable_atmospherics/canister/stimulum,
		"pluoxium" = /obj/machinery/portable_atmospherics/canister/pluoxium,
		"caution" = /obj/machinery/portable_atmospherics/canister,
		// LIST BEGIN
		"bungotoxin" = /obj/machinery/portable_atmospherics/canister/bungotoxin,
		"bonehurtingjuice" = /obj/machinery/portable_atmospherics/canister/bonehurtingjuice,
		"mimesbane" = /obj/machinery/portable_atmospherics/canister/mimesbane,
		"delayed" = /obj/machinery/portable_atmospherics/canister/delayed,
		"fluacid" = /obj/machinery/portable_atmospherics/canister/fluacid,
		"acid" = /obj/machinery/portable_atmospherics/canister/acid,
		"anacea" = /obj/machinery/portable_atmospherics/canister/anacea,
		"skewium" = /obj/machinery/portable_atmospherics/canister/skewium,
		"rotatium" = /obj/machinery/portable_atmospherics/canister/rotatium,
		"heparin" = /obj/machinery/portable_atmospherics/canister/heparin,
		"curare" = /obj/machinery/portable_atmospherics/canister/curare,
		"spewium" = /obj/machinery/portable_atmospherics/canister/spewium,
		"coniine" = /obj/machinery/portable_atmospherics/canister/coniine,
		"lipolicide" = /obj/machinery/portable_atmospherics/canister/lipolicide,
		"amanitin" = /obj/machinery/portable_atmospherics/canister/amanitin,
		"sulfonal" = /obj/machinery/portable_atmospherics/canister/sulfonal,
		"sodium_thiopental" = /obj/machinery/portable_atmospherics/canister/sodium_thiopental,
		"pancuronium" = /obj/machinery/portable_atmospherics/canister/pancuronium,
		"initropidril" = /obj/machinery/portable_atmospherics/canister/initropidril,
		"itching_powder" = /obj/machinery/portable_atmospherics/canister/itching_powder,
		"bad_food" = /obj/machinery/portable_atmospherics/canister/bad_food,
		"cyanide" = /obj/machinery/portable_atmospherics/canister/cyanide,
		"fentanyl" = /obj/machinery/portable_atmospherics/canister/fentanyl,
		"venom" = /obj/machinery/portable_atmospherics/canister/venom,
		"formaldehyde" = /obj/machinery/portable_atmospherics/canister/formaldehyde,
		"histamine" = /obj/machinery/portable_atmospherics/canister/histamine,
		"polonium" = /obj/machinery/portable_atmospherics/canister/polonium,
		"staminatoxin" = /obj/machinery/portable_atmospherics/canister/staminatoxin,
		"mutetoxin" = /obj/machinery/portable_atmospherics/canister/mutetoxin,
		"teapowder" = /obj/machinery/portable_atmospherics/canister/teapowder,
		"coffeepowder" = /obj/machinery/portable_atmospherics/canister/coffeepowder,
		"fakebeer" = /obj/machinery/portable_atmospherics/canister/fakebeer,
		"chloralhydrate" = /obj/machinery/portable_atmospherics/canister/chloralhydrate,
		"spore_burning" = /obj/machinery/portable_atmospherics/canister/spore_burning,
		"spore" = /obj/machinery/portable_atmospherics/canister/spore,
		"pestkiller" = /obj/machinery/portable_atmospherics/canister/pestkiller,
		"weedkiller" = /obj/machinery/portable_atmospherics/canister/weedkiller,
		"plantbgone" = /obj/machinery/portable_atmospherics/canister/plantbgone,
		"mindbreaker" = /obj/machinery/portable_atmospherics/canister/mindbreaker,
		"ghoulpowder" = /obj/machinery/portable_atmospherics/canister/ghoulpowder,
		"zombiepowder" = /obj/machinery/portable_atmospherics/canister/zombiepowder,
		"carpotoxin" = /obj/machinery/portable_atmospherics/canister/carpotoxin,
		"minttoxin" = /obj/machinery/portable_atmospherics/canister/minttoxin,
		"slimejelly" = /obj/machinery/portable_atmospherics/canister/slimejelly,
		"lexorin" = /obj/machinery/portable_atmospherics/canister/lexorin,
		"mutagen" = /obj/machinery/portable_atmospherics/canister/mutagen,
		"amatoxin" = /obj/machinery/portable_atmospherics/canister/amatoxin,
		"toxin" = /obj/machinery/portable_atmospherics/canister/toxin,
		"firefighting_foam" = /obj/machinery/portable_atmospherics/canister/firefighting_foam,
		"energized_jelly" = /obj/machinery/portable_atmospherics/canister/energized_jelly,
		"teslium" = /obj/machinery/portable_atmospherics/canister/teslium,
		"pyrosium" = /obj/machinery/portable_atmospherics/canister/pyrosium,
		"cryostylane" = /obj/machinery/portable_atmospherics/canister/cryostylane,
		"napalm" = /obj/machinery/portable_atmospherics/canister/napalm,
		"phlogiston" = /obj/machinery/portable_atmospherics/canister/phlogiston,
		"sonic_powder" = /obj/machinery/portable_atmospherics/canister/sonic_powder,
		"smoke_powder" = /obj/machinery/portable_atmospherics/canister/smoke_powder,
		"flash_powder" = /obj/machinery/portable_atmospherics/canister/flash_powder,
		"blackpowder" = /obj/machinery/portable_atmospherics/canister/blackpowder,
		"liquid_dark_matter" = /obj/machinery/portable_atmospherics/canister/liquid_dark_matter,
		"sorium" = /obj/machinery/portable_atmospherics/canister/sorium,
		"clf3" = /obj/machinery/portable_atmospherics/canister/clf3,
		"stabilizing_agent" = /obj/machinery/portable_atmospherics/canister/stabilizing_agent,
		"nitroglycerin" = /obj/machinery/portable_atmospherics/canister/nitroglycerin,
		"thermite" = /obj/machinery/portable_atmospherics/canister/thermite,
		"invisium" = /obj/machinery/portable_atmospherics/canister/invisium,
		"ratlight" = /obj/machinery/portable_atmospherics/canister/ratlight,
		"spider_extract" = /obj/machinery/portable_atmospherics/canister/spider_extract,
		"liquidadamantine" = /obj/machinery/portable_atmospherics/canister/liquidadamantine,
		"tranquility" = /obj/machinery/portable_atmospherics/canister/tranquility,
		"tire" = /obj/machinery/portable_atmospherics/canister/tire,
		"inabizine" = /obj/machinery/portable_atmospherics/canister/inabizine,
		"confuse" = /obj/machinery/portable_atmospherics/canister/confuse,
		"peaceborg" = /obj/machinery/portable_atmospherics/canister/peaceborg,
		"fake_cbz" = /obj/machinery/portable_atmospherics/canister/fake_cbz,
		"concentrated_bz" = /obj/machinery/portable_atmospherics/canister/concentrated_bz,
		"bz_metabolites" = /obj/machinery/portable_atmospherics/canister/bz_metabolites,
		"pax" = /obj/machinery/portable_atmospherics/canister/pax,
		"pink" = /obj/machinery/portable_atmospherics/canister/pink,
		"glitter" = /obj/machinery/portable_atmospherics/canister/glitter,
		"plastic_polymers" = /obj/machinery/portable_atmospherics/canister/plastic_polymers,
		"growthserum" = /obj/machinery/portable_atmospherics/canister/growthserum,
		"magillitis" = /obj/machinery/portable_atmospherics/canister/magillitis,
		"romerol" = /obj/machinery/portable_atmospherics/canister/romerol,
		"royal_bee_jelly" = /obj/machinery/portable_atmospherics/canister/royal_bee_jelly,
		"viralbase" = /obj/machinery/portable_atmospherics/canister/viralbase,
		"advvirusfood" = /obj/machinery/portable_atmospherics/canister/advvirusfood,
		"laughtervirusfood" = /obj/machinery/portable_atmospherics/canister/laughtervirusfood,
		"stable" = /obj/machinery/portable_atmospherics/canister/stable,
		"uraniumvirusfood" = /obj/machinery/portable_atmospherics/canister/uraniumvirusfood,
		"weak" = /obj/machinery/portable_atmospherics/canister/weak,
		"plasmavirusfood" = /obj/machinery/portable_atmospherics/canister/plasmavirusfood,
		"synaptizinevirusfood" = /obj/machinery/portable_atmospherics/canister/synaptizinevirusfood,
		"mutagenvirusfood" = /obj/machinery/portable_atmospherics/canister/mutagenvirusfood,
		"drying_agent" = /obj/machinery/portable_atmospherics/canister/drying_agent,
		"lye" = /obj/machinery/portable_atmospherics/canister/lye,
		"saltpetre" = /obj/machinery/portable_atmospherics/canister/saltpetre,
		"concentrated_barbers_aid" = /obj/machinery/portable_atmospherics/canister/concentrated_barbers_aid,
		"barbers_aid" = /obj/machinery/portable_atmospherics/canister/barbers_aid,
		"hair_dye" = /obj/machinery/portable_atmospherics/canister/hair_dye,
		"colorful_reagent" = /obj/machinery/portable_atmospherics/canister/colorful_reagent,
		"acetone" = /obj/machinery/portable_atmospherics/canister/acetone,
		"phenol" = /obj/machinery/portable_atmospherics/canister/phenol,
		"bromine" = /obj/machinery/portable_atmospherics/canister/bromine,
		"carpet" = /obj/machinery/portable_atmospherics/canister/carpet,
		"iodine" = /obj/machinery/portable_atmospherics/canister/iodine,
		"stable_plasma" = /obj/machinery/portable_atmospherics/canister/stable_plasma,
		"oil" = /obj/machinery/portable_atmospherics/canister/oil,
		"robustharvestnutriment" = /obj/machinery/portable_atmospherics/canister/robustharvestnutriment,
		"left4zednutriment" = /obj/machinery/portable_atmospherics/canister/left4zednutriment,
		"eznutriment" = /obj/machinery/portable_atmospherics/canister/eznutriment,
		"plantnutriment" = /obj/machinery/portable_atmospherics/canister/plantnutriment,
		"white" = /obj/machinery/portable_atmospherics/canister/white,
		"black" = /obj/machinery/portable_atmospherics/canister/black,
		"invisible" = /obj/machinery/portable_atmospherics/canister/invisible,
		"purple" = /obj/machinery/portable_atmospherics/canister/purple,
		"blue" = /obj/machinery/portable_atmospherics/canister/blue,
		"yellow" = /obj/machinery/portable_atmospherics/canister/yellow,
		"orange" = /obj/machinery/portable_atmospherics/canister/orange,
		"red" = /obj/machinery/portable_atmospherics/canister/red,
		"powder" = /obj/machinery/portable_atmospherics/canister/powder,
		"carbondioxide" = /obj/machinery/portable_atmospherics/canister/carbondioxide,
		"diethylamine" = /obj/machinery/portable_atmospherics/canister/diethylamine,
		"ammonia" = /obj/machinery/portable_atmospherics/canister/ammonia,
		"smart_foaming_agent" = /obj/machinery/portable_atmospherics/canister/smart_foaming_agent,
		"foaming_agent" = /obj/machinery/portable_atmospherics/canister/foaming_agent,
		"fluorosurfactant" = /obj/machinery/portable_atmospherics/canister/fluorosurfactant,
		"snail" = /obj/machinery/portable_atmospherics/canister/snail,
		"fungalspores" = /obj/machinery/portable_atmospherics/canister/fungalspores,
		"xenomicrobes" = /obj/machinery/portable_atmospherics/canister/xenomicrobes,
		"nanomachines" = /obj/machinery/portable_atmospherics/canister/nanomachines,
		"impedrezene" = /obj/machinery/portable_atmospherics/canister/impedrezene,
		"cryptobiolin" = /obj/machinery/portable_atmospherics/canister/cryptobiolin,
		"ez_clean" = /obj/machinery/portable_atmospherics/canister/ez_clean,
		"space_cleaner" = /obj/machinery/portable_atmospherics/canister/space_cleaner,
		"fuel" = /obj/machinery/portable_atmospherics/canister/fuel,
		"silicon" = /obj/machinery/portable_atmospherics/canister/silicon,
		"aluminium" = /obj/machinery/portable_atmospherics/canister/aluminium,
		"bluespace" = /obj/machinery/portable_atmospherics/canister/bluespace,
		"radium" = /obj/machinery/portable_atmospherics/canister/radium,
		"uranium" = /obj/machinery/portable_atmospherics/canister/uranium,
		"silver" = /obj/machinery/portable_atmospherics/canister/silver,
		"gold" = /obj/machinery/portable_atmospherics/canister/gold,
		"iron" = /obj/machinery/portable_atmospherics/canister/iron,
		"sterilizine" = /obj/machinery/portable_atmospherics/canister/sterilizine,
		"glycerol" = /obj/machinery/portable_atmospherics/canister/glycerol,
		"lithium" = /obj/machinery/portable_atmospherics/canister/lithium,
		"phosphorus" = /obj/machinery/portable_atmospherics/canister/phosphorus,
		"sodium" = /obj/machinery/portable_atmospherics/canister/sodium,
		"fluorine" = /obj/machinery/portable_atmospherics/canister/fluorine,
		"chlorine" = /obj/machinery/portable_atmospherics/canister/chlorine,
		"carbon" = /obj/machinery/portable_atmospherics/canister/carbon,
		"sulfur" = /obj/machinery/portable_atmospherics/canister/sulfur,
		"mercury" = /obj/machinery/portable_atmospherics/canister/mercury,
		"potassium" = /obj/machinery/portable_atmospherics/canister/potassium,
		"hydrogen" = /obj/machinery/portable_atmospherics/canister/hydrogen,
		"copper" = /obj/machinery/portable_atmospherics/canister/copper,
		"serotrotium" = /obj/machinery/portable_atmospherics/canister/serotrotium,
		"gluttonytoxin" = /obj/machinery/portable_atmospherics/canister/gluttonytoxin,
		"aslimetoxin" = /obj/machinery/portable_atmospherics/canister/aslimetoxin,
		"mulligan" = /obj/machinery/portable_atmospherics/canister/mulligan,
		"slime_toxin" = /obj/machinery/portable_atmospherics/canister/slime_toxin,
		"shadow" = /obj/machinery/portable_atmospherics/canister/shadow,
		"supersoldier" = /obj/machinery/portable_atmospherics/canister/supersoldier,
		"ash" = /obj/machinery/portable_atmospherics/canister/ash,
		"goofzombie" = /obj/machinery/portable_atmospherics/canister/goofzombie,
		"zombie" = /obj/machinery/portable_atmospherics/canister/zombie,
		"skeleton" = /obj/machinery/portable_atmospherics/canister/skeleton,
		"squid" = /obj/machinery/portable_atmospherics/canister/squid,
		"ipc" = /obj/machinery/portable_atmospherics/canister/ipc,
		"android" = /obj/machinery/portable_atmospherics/canister/android,
		"abductor" = /obj/machinery/portable_atmospherics/canister/abductor,
		"golem" = /obj/machinery/portable_atmospherics/canister/golem,
		"jelly" = /obj/machinery/portable_atmospherics/canister/jelly,
		"pod" = /obj/machinery/portable_atmospherics/canister/pod,
		"moth" = /obj/machinery/portable_atmospherics/canister/moth,
		"fly" = /obj/machinery/portable_atmospherics/canister/fly,
		"lizard" = /obj/machinery/portable_atmospherics/canister/lizard,
		"felinid" = /obj/machinery/portable_atmospherics/canister/felinid,
		"unstable" = /obj/machinery/portable_atmospherics/canister/unstable,
		"classic" = /obj/machinery/portable_atmospherics/canister/classic,
		"mutationtoxin" = /obj/machinery/portable_atmospherics/canister/mutationtoxin,
		"spraytan" = /obj/machinery/portable_atmospherics/canister/spraytan,
		"lube" = /obj/machinery/portable_atmospherics/canister/lube,
		"godblood" = /obj/machinery/portable_atmospherics/canister/godblood,
		"hellwater" = /obj/machinery/portable_atmospherics/canister/hellwater,
		"unholywater" = /obj/machinery/portable_atmospherics/canister/unholywater,
		"holywater" = /obj/machinery/portable_atmospherics/canister/holywater,
		"water" = /obj/machinery/portable_atmospherics/canister/water,
		"vaccine" = /obj/machinery/portable_atmospherics/canister/vaccine,
		"liquidgibs" = /obj/machinery/portable_atmospherics/canister/liquidgibs,
		"blood" = /obj/machinery/portable_atmospherics/canister/blood,
		"polypyr" = /obj/machinery/portable_atmospherics/canister/polypyr,
		"silibinin" = /obj/machinery/portable_atmospherics/canister/silibinin,
		"psicodine" = /obj/machinery/portable_atmospherics/canister/psicodine,
		"modafinil" = /obj/machinery/portable_atmospherics/canister/modafinil,
		"muscle_stimulant" = /obj/machinery/portable_atmospherics/canister/muscle_stimulant,
		"corazone" = /obj/machinery/portable_atmospherics/canister/corazone,
		"changelinghaste" = /obj/machinery/portable_atmospherics/canister/changelinghaste,
		"changelingadrenaline" = /obj/machinery/portable_atmospherics/canister/changelingadrenaline,
		"lavaland_extract" = /obj/machinery/portable_atmospherics/canister/lavaland_extract,
		"haloperidol" = /obj/machinery/portable_atmospherics/canister/haloperidol,
		"earthsblood" = /obj/machinery/portable_atmospherics/canister/earthsblood,
		"syndicate_nanites" = /obj/machinery/portable_atmospherics/canister/syndicate_nanites,
		"regen_jelly" = /obj/machinery/portable_atmospherics/canister/regen_jelly,
		"tricordrazine" = /obj/machinery/portable_atmospherics/canister/tricordrazine,
		"inaprovaline" = /obj/machinery/portable_atmospherics/canister/inaprovaline,
		"hepanephrodaxon" = /obj/machinery/portable_atmospherics/canister/hepanephrodaxon,
		"carthatoline" = /obj/machinery/portable_atmospherics/canister/carthatoline,
		"antitoxin" = /obj/machinery/portable_atmospherics/canister/antitoxin,
		"kelotane" = /obj/machinery/portable_atmospherics/canister/kelotane,
		"bicaridine" = /obj/machinery/portable_atmospherics/canister/bicaridine,
		"insulin" = /obj/machinery/portable_atmospherics/canister/insulin,
		"pumpup" = /obj/machinery/portable_atmospherics/canister/pumpup,
		"stimulants" = /obj/machinery/portable_atmospherics/canister/stimulants,
		"antihol" = /obj/machinery/portable_atmospherics/canister/antihol,
		"mutadone" = /obj/machinery/portable_atmospherics/canister/mutadone,
		"neurine" = /obj/machinery/portable_atmospherics/canister/neurine,
		"mannitol" = /obj/machinery/portable_atmospherics/canister/mannitol,
		"strange_reagent" = /obj/machinery/portable_atmospherics/canister/strange_reagent,
		"epinephrine" = /obj/machinery/portable_atmospherics/canister/epinephrine,
		"atropine" = /obj/machinery/portable_atmospherics/canister/atropine,
		"oculine" = /obj/machinery/portable_atmospherics/canister/oculine,
		"morphine" = /obj/machinery/portable_atmospherics/canister/morphine,
		"diphenhydramine" = /obj/machinery/portable_atmospherics/canister/diphenhydramine,
		"ephedrine" = /obj/machinery/portable_atmospherics/canister/ephedrine,
		"perfluorodecalin" = /obj/machinery/portable_atmospherics/canister/perfluorodecalin,
		"salbutamol" = /obj/machinery/portable_atmospherics/canister/salbutamol,
		"sal_acid" = /obj/machinery/portable_atmospherics/canister/sal_acid,
		"pen_acid" = /obj/machinery/portable_atmospherics/canister/pen_acid,
		"potass_iodide" = /obj/machinery/portable_atmospherics/canister/potass_iodide,
		"calomel" = /obj/machinery/portable_atmospherics/canister/calomel,
		"omnizine" = /obj/machinery/portable_atmospherics/canister/omnizine,
		"liquid_solder" = /obj/machinery/portable_atmospherics/canister/liquid_solder,
		"system_cleaner" = /obj/machinery/portable_atmospherics/canister/system_cleaner,
		"charcoal" = /obj/machinery/portable_atmospherics/canister/charcoal,
		"synthflesh" = /obj/machinery/portable_atmospherics/canister/synthflesh,
		"mine_salve" = /obj/machinery/portable_atmospherics/canister/mine_salve,
		"salglu_solution" = /obj/machinery/portable_atmospherics/canister/salglu_solution,
		"styptic_powder" = /obj/machinery/portable_atmospherics/canister/styptic_powder,
		"oxandrolone" = /obj/machinery/portable_atmospherics/canister/oxandrolone,
		"silver_sulfadiazine" = /obj/machinery/portable_atmospherics/canister/silver_sulfadiazine,
		"spaceacillin" = /obj/machinery/portable_atmospherics/canister/spaceacillin,
		"rezadone" = /obj/machinery/portable_atmospherics/canister/rezadone,
		"pyroxadone" = /obj/machinery/portable_atmospherics/canister/pyroxadone,
		"clonexadone" = /obj/machinery/portable_atmospherics/canister/clonexadone,
		"cryoxadone" = /obj/machinery/portable_atmospherics/canister/cryoxadone,
		"inacusiate" = /obj/machinery/portable_atmospherics/canister/inacusiate,
		"synaphydramine" = /obj/machinery/portable_atmospherics/canister/synaphydramine,
		"synaptizine" = /obj/machinery/portable_atmospherics/canister/synaptizine,
		"quantum_heal" = /obj/machinery/portable_atmospherics/canister/quantum_heal,
		"adminordrazine" = /obj/machinery/portable_atmospherics/canister/adminordrazine,
		"leporazine" = /obj/machinery/portable_atmospherics/canister/leporazine,
		"medicine" = /obj/machinery/portable_atmospherics/canister/medicine,
		"char" = /obj/machinery/portable_atmospherics/canister/char,
		"bbqsauce" = /obj/machinery/portable_atmospherics/canister/bbqsauce,
		"caramel" = /obj/machinery/portable_atmospherics/canister/caramel,
		"astrotame" = /obj/machinery/portable_atmospherics/canister/astrotame,
		"liquidelectricity" = /obj/machinery/portable_atmospherics/canister/liquidelectricity,
		"clownstears" = /obj/machinery/portable_atmospherics/canister/clownstears,
		"vitfro" = /obj/machinery/portable_atmospherics/canister/vitfro,
		"tinlux" = /obj/machinery/portable_atmospherics/canister/tinlux,
		"entpoly" = /obj/machinery/portable_atmospherics/canister/entpoly,
		"stabilized" = /obj/machinery/portable_atmospherics/canister/stabilized,
		"tearjuice" = /obj/machinery/portable_atmospherics/canister/tearjuice,
		"mayonnaise" = /obj/machinery/portable_atmospherics/canister/mayonnaise,
		"special" = /obj/machinery/portable_atmospherics/canister/special,
		"honey" = /obj/machinery/portable_atmospherics/canister/honey,
		"corn_syrup" = /obj/machinery/portable_atmospherics/canister/corn_syrup,
		"corn_starch" = /obj/machinery/portable_atmospherics/canister/corn_starch,
		"eggyolk" = /obj/machinery/portable_atmospherics/canister/eggyolk,
		"vanilla" = /obj/machinery/portable_atmospherics/canister/vanilla,
		"rice" = /obj/machinery/portable_atmospherics/canister/rice,
		"bluecherryjelly" = /obj/machinery/portable_atmospherics/canister/bluecherryjelly,
		"cherryjelly" = /obj/machinery/portable_atmospherics/canister/cherryjelly,
		"flour" = /obj/machinery/portable_atmospherics/canister/flour,
		"hell_ramen" = /obj/machinery/portable_atmospherics/canister/hell_ramen,
		"hot_ramen" = /obj/machinery/portable_atmospherics/canister/hot_ramen,
		"dry_ramen" = /obj/machinery/portable_atmospherics/canister/dry_ramen,
		"enzyme" = /obj/machinery/portable_atmospherics/canister/enzyme,
		"cornoil" = /obj/machinery/portable_atmospherics/canister/cornoil,
		"sprinkles" = /obj/machinery/portable_atmospherics/canister/sprinkles,
		"garlic" = /obj/machinery/portable_atmospherics/canister/garlic,
		"mushroomhallucinogen" = /obj/machinery/portable_atmospherics/canister/mushroomhallucinogen,
		"hot_coco" = /obj/machinery/portable_atmospherics/canister/hot_coco,
		"coco" = /obj/machinery/portable_atmospherics/canister/coco,
		"blackpepper" = /obj/machinery/portable_atmospherics/canister/blackpepper,
		"sodiumchloride" = /obj/machinery/portable_atmospherics/canister/sodiumchloride,
		"condensedcapsaicin" = /obj/machinery/portable_atmospherics/canister/condensedcapsaicin,
		"frostoil" = /obj/machinery/portable_atmospherics/canister/frostoil,
		"capsaicin" = /obj/machinery/portable_atmospherics/canister/capsaicin,
		"ketchup" = /obj/machinery/portable_atmospherics/canister/ketchup,
		"soysauce" = /obj/machinery/portable_atmospherics/canister/soysauce,
		"virus_food" = /obj/machinery/portable_atmospherics/canister/virus_food,
		"sugar" = /obj/machinery/portable_atmospherics/canister/sugar,
		"cooking_oil" = /obj/machinery/portable_atmospherics/canister/cooking_oil,
		"vitamin" = /obj/machinery/portable_atmospherics/canister/vitamin,
		"nutriment" = /obj/machinery/portable_atmospherics/canister/nutriment,
		"happiness" = /obj/machinery/portable_atmospherics/canister/happiness,
		"aranesp" = /obj/machinery/portable_atmospherics/canister/aranesp,
		"bath_salts" = /obj/machinery/portable_atmospherics/canister/bath_salts,
		"methamphetamine" = /obj/machinery/portable_atmospherics/canister/methamphetamine,
		"krokodil" = /obj/machinery/portable_atmospherics/canister/krokodil,
		"crank" = /obj/machinery/portable_atmospherics/canister/crank,
		"nicotine" = /obj/machinery/portable_atmospherics/canister/nicotine,
		"space_drugs" = /obj/machinery/portable_atmospherics/canister/space_drugs,
		"drug" = /obj/machinery/portable_atmospherics/canister/drug,
		"bungojuice" = /obj/machinery/portable_atmospherics/canister/bungojuice,
		"red_queen" = /obj/machinery/portable_atmospherics/canister/red_queen,
		"cream_soda" = /obj/machinery/portable_atmospherics/canister/cream_soda,
		"peachjuice" = /obj/machinery/portable_atmospherics/canister/peachjuice,
		"parsnipjuice" = /obj/machinery/portable_atmospherics/canister/parsnipjuice,
		"grenadine" = /obj/machinery/portable_atmospherics/canister/grenadine,
		"menthol" = /obj/machinery/portable_atmospherics/canister/menthol,
		"chocolate_milk" = /obj/machinery/portable_atmospherics/canister/chocolate_milk,
		"grape_soda" = /obj/machinery/portable_atmospherics/canister/grape_soda,
		"triple_citrus" = /obj/machinery/portable_atmospherics/canister/triple_citrus,
		"blumpkinjuice" = /obj/machinery/portable_atmospherics/canister/blumpkinjuice,
		"pumpkinjuice" = /obj/machinery/portable_atmospherics/canister/pumpkinjuice,
		"gibbfloats" = /obj/machinery/portable_atmospherics/canister/gibbfloats,
		"pumpkin_latte" = /obj/machinery/portable_atmospherics/canister/pumpkin_latte,
		"bluecherryshake" = /obj/machinery/portable_atmospherics/canister/bluecherryshake,
		"cherryshake" = /obj/machinery/portable_atmospherics/canister/cherryshake,
		"vanillapudding" = /obj/machinery/portable_atmospherics/canister/vanillapudding,
		"chocolatepudding" = /obj/machinery/portable_atmospherics/canister/chocolatepudding,
		"doctor_delight" = /obj/machinery/portable_atmospherics/canister/doctor_delight,
		"cafe_latte" = /obj/machinery/portable_atmospherics/canister/cafe_latte,
		"soy_latte" = /obj/machinery/portable_atmospherics/canister/soy_latte,
		"ice" = /obj/machinery/portable_atmospherics/canister/ice,
		"monkey_energy" = /obj/machinery/portable_atmospherics/canister/monkey_energy,
		"tonic" = /obj/machinery/portable_atmospherics/canister/tonic,
		"sodawater" = /obj/machinery/portable_atmospherics/canister/sodawater,
		"shamblers" = /obj/machinery/portable_atmospherics/canister/shamblers,
		"pwr_game" = /obj/machinery/portable_atmospherics/canister/pwr_game,
		"lemon_lime" = /obj/machinery/portable_atmospherics/canister/lemon_lime,
		"space_up" = /obj/machinery/portable_atmospherics/canister/space_up,
		"dr_gibb" = /obj/machinery/portable_atmospherics/canister/dr_gibb,
		"spacemountainwind" = /obj/machinery/portable_atmospherics/canister/spacemountainwind,
		"grey_bull" = /obj/machinery/portable_atmospherics/canister/grey_bull,
		"nuka_cola" = /obj/machinery/portable_atmospherics/canister/nuka_cola,
		"space_cola" = /obj/machinery/portable_atmospherics/canister/space_cola,
		"icetea" = /obj/machinery/portable_atmospherics/canister/icetea,
		"icecoffee" = /obj/machinery/portable_atmospherics/canister/icecoffee,
		"arnold_palmer" = /obj/machinery/portable_atmospherics/canister/arnold_palmer,
		"lemonade" = /obj/machinery/portable_atmospherics/canister/lemonade,
		"tea" = /obj/machinery/portable_atmospherics/canister/tea,
		"coffee" = /obj/machinery/portable_atmospherics/canister/coffee,
		"cream" = /obj/machinery/portable_atmospherics/canister/cream,
		"soymilk" = /obj/machinery/portable_atmospherics/canister/soymilk,
		"milk" = /obj/machinery/portable_atmospherics/canister/milk,
		"grapejuice" = /obj/machinery/portable_atmospherics/canister/grapejuice,
		"potato_juice" = /obj/machinery/portable_atmospherics/canister/potato_juice,
		"superlaughter" = /obj/machinery/portable_atmospherics/canister/superlaughter,
		"laughter" = /obj/machinery/portable_atmospherics/canister/laughter,
		"nothing" = /obj/machinery/portable_atmospherics/canister/nothing,
		"banana" = /obj/machinery/portable_atmospherics/canister/banana,
		"lemonjuice" = /obj/machinery/portable_atmospherics/canister/lemonjuice,
		"watermelonjuice" = /obj/machinery/portable_atmospherics/canister/watermelonjuice,
		"poisonberryjuice" = /obj/machinery/portable_atmospherics/canister/poisonberryjuice,
		"applejuice" = /obj/machinery/portable_atmospherics/canister/applejuice,
		"berryjuice" = /obj/machinery/portable_atmospherics/canister/berryjuice,
		"carrotjuice" = /obj/machinery/portable_atmospherics/canister/carrotjuice,
		"limejuice" = /obj/machinery/portable_atmospherics/canister/limejuice,
		"tomatojuice" = /obj/machinery/portable_atmospherics/canister/tomatojuice,
		"orangejuice" = /obj/machinery/portable_atmospherics/canister/orangejuice,
		"beesknees" = /obj/machinery/portable_atmospherics/canister/beesknees,
		"sarsaparilliansunset" = /obj/machinery/portable_atmospherics/canister/sarsaparilliansunset,
		"icewing" = /obj/machinery/portable_atmospherics/canister/icewing,
		"ratvander" = /obj/machinery/portable_atmospherics/canister/ratvander,
		"fourthwall" = /obj/machinery/portable_atmospherics/canister/fourthwall,
		"plasmaflood" = /obj/machinery/portable_atmospherics/canister/plasmaflood,
		"mauna_loa" = /obj/machinery/portable_atmospherics/canister/mauna_loa,
		"planet_cracker" = /obj/machinery/portable_atmospherics/canister/planet_cracker,
		"blazaam" = /obj/machinery/portable_atmospherics/canister/blazaam,
		"trappist" = /obj/machinery/portable_atmospherics/canister/trappist,
		"duplex" = /obj/machinery/portable_atmospherics/canister/duplex,
		"rubberneck" = /obj/machinery/portable_atmospherics/canister/rubberneck,
		"old_timer" = /obj/machinery/portable_atmospherics/canister/old_timer,
		"turbo" = /obj/machinery/portable_atmospherics/canister/turbo,
		"jack_rose" = /obj/machinery/portable_atmospherics/canister/jack_rose,
		"applejack" = /obj/machinery/portable_atmospherics/canister/applejack,
		"bug_spray" = /obj/machinery/portable_atmospherics/canister/bug_spray,
		"wizz_fizz" = /obj/machinery/portable_atmospherics/canister/wizz_fizz,
		"champagne" = /obj/machinery/portable_atmospherics/canister/champagne,
		"fruit_wine" = /obj/machinery/portable_atmospherics/canister/fruit_wine,
		"blank_paper" = /obj/machinery/portable_atmospherics/canister/blank_paper,
		"branca_menta" = /obj/machinery/portable_atmospherics/canister/branca_menta,
		"fanciulli" = /obj/machinery/portable_atmospherics/canister/fanciulli,
		"fernet_cola" = /obj/machinery/portable_atmospherics/canister/fernet_cola,
		"fernet" = /obj/machinery/portable_atmospherics/canister/fernet,
		"mojito" = /obj/machinery/portable_atmospherics/canister/mojito,
		"kamikaze" = /obj/machinery/portable_atmospherics/canister/kamikaze,
		"between_the_sheets" = /obj/machinery/portable_atmospherics/canister/between_the_sheets,
		"sidecar" = /obj/machinery/portable_atmospherics/canister/sidecar,
		"alexander" = /obj/machinery/portable_atmospherics/canister/alexander,
		"peppermint_patty" = /obj/machinery/portable_atmospherics/canister/peppermint_patty,
		"sake" = /obj/machinery/portable_atmospherics/canister/sake,
		"crevice_spike" = /obj/machinery/portable_atmospherics/canister/crevice_spike,
		"sugar_rush" = /obj/machinery/portable_atmospherics/canister/sugar_rush,
		"fringe_weaver" = /obj/machinery/portable_atmospherics/canister/fringe_weaver,
		"squirt_cider" = /obj/machinery/portable_atmospherics/canister/squirt_cider,
		"bastion_bourbon" = /obj/machinery/portable_atmospherics/canister/bastion_bourbon,
		"stinger" = /obj/machinery/portable_atmospherics/canister/stinger,
		"grasshopper" = /obj/machinery/portable_atmospherics/canister/grasshopper,
		"quintuple_sec" = /obj/machinery/portable_atmospherics/canister/quintuple_sec,
		"quadruple_sec" = /obj/machinery/portable_atmospherics/canister/quadruple_sec,
		"creme_de_cacao" = /obj/machinery/portable_atmospherics/canister/creme_de_cacao,
		"creme_de_menthe" = /obj/machinery/portable_atmospherics/canister/creme_de_menthe,
		"triple_sec" = /obj/machinery/portable_atmospherics/canister/triple_sec,
		"narsour" = /obj/machinery/portable_atmospherics/canister/narsour,
		"eggnog" = /obj/machinery/portable_atmospherics/canister/eggnog,
		"hippies_delight" = /obj/machinery/portable_atmospherics/canister/hippies_delight,
		"neurotoxin" = /obj/machinery/portable_atmospherics/canister/neurotoxin,
		"gargle_blaster" = /obj/machinery/portable_atmospherics/canister/gargle_blaster,
		"atomicbomb" = /obj/machinery/portable_atmospherics/canister/atomicbomb,
		"bacchus_blessing" = /obj/machinery/portable_atmospherics/canister/bacchus_blessing,
		"hearty_punch" = /obj/machinery/portable_atmospherics/canister/hearty_punch,
		"fetching_fizz" = /obj/machinery/portable_atmospherics/canister/fetching_fizz,
		"hcider" = /obj/machinery/portable_atmospherics/canister/hcider,
		"whiskey_sour" = /obj/machinery/portable_atmospherics/canister/whiskey_sour,
		"drunkenblumpkin" = /obj/machinery/portable_atmospherics/canister/drunkenblumpkin,
		"silencer" = /obj/machinery/portable_atmospherics/canister/silencer,
		"bananahonk" = /obj/machinery/portable_atmospherics/canister/bananahonk,
		"driestmartini" = /obj/machinery/portable_atmospherics/canister/driestmartini,
		"erikasurprise" = /obj/machinery/portable_atmospherics/canister/erikasurprise,
		"syndicatebomb" = /obj/machinery/portable_atmospherics/canister/syndicatebomb,
		"irishcarbomb" = /obj/machinery/portable_atmospherics/canister/irishcarbomb,
		"changelingsting" = /obj/machinery/portable_atmospherics/canister/changelingsting,
		"amasec" = /obj/machinery/portable_atmospherics/canister/amasec,
		"acid_spit" = /obj/machinery/portable_atmospherics/canister/acid_spit,
		"alliescocktail" = /obj/machinery/portable_atmospherics/canister/alliescocktail,
		"andalusia" = /obj/machinery/portable_atmospherics/canister/andalusia,
		"aloe" = /obj/machinery/portable_atmospherics/canister/aloe,
		"grog" = /obj/machinery/portable_atmospherics/canister/grog,
		"iced_beer" = /obj/machinery/portable_atmospherics/canister/iced_beer,
		"mead" = /obj/machinery/portable_atmospherics/canister/mead,
		"red_mead" = /obj/machinery/portable_atmospherics/canister/red_mead,
		"sbiten" = /obj/machinery/portable_atmospherics/canister/sbiten,
		"singulo" = /obj/machinery/portable_atmospherics/canister/singulo,
		"bahama_mama" = /obj/machinery/portable_atmospherics/canister/bahama_mama,
		"ginfizz" = /obj/machinery/portable_atmospherics/canister/ginfizz,
		"vodkatonic" = /obj/machinery/portable_atmospherics/canister/vodkatonic,
		"devilskiss" = /obj/machinery/portable_atmospherics/canister/devilskiss,
		"demonsblood" = /obj/machinery/portable_atmospherics/canister/demonsblood,
		"snowwhite" = /obj/machinery/portable_atmospherics/canister/snowwhite,
		"barefoot" = /obj/machinery/portable_atmospherics/canister/barefoot,
		"antifreeze" = /obj/machinery/portable_atmospherics/canister/antifreeze,
		"whiskeysoda" = /obj/machinery/portable_atmospherics/canister/whiskeysoda,
		"manhattan_proj" = /obj/machinery/portable_atmospherics/canister/manhattan_proj,
		"manhattan" = /obj/machinery/portable_atmospherics/canister/manhattan,
		"black_russian" = /obj/machinery/portable_atmospherics/canister/black_russian,
		"margarita" = /obj/machinery/portable_atmospherics/canister/margarita,
		"irishcoffee" = /obj/machinery/portable_atmospherics/canister/irishcoffee,
		"b52" = /obj/machinery/portable_atmospherics/canister/b52,
		"moonshine" = /obj/machinery/portable_atmospherics/canister/moonshine,
		"longislandicedtea" = /obj/machinery/portable_atmospherics/canister/longislandicedtea,
		"manly_dorf" = /obj/machinery/portable_atmospherics/canister/manly_dorf,
		"irish_cream" = /obj/machinery/portable_atmospherics/canister/irish_cream,
		"beepsky_smash" = /obj/machinery/portable_atmospherics/canister/beepsky_smash,
		"toxins_special" = /obj/machinery/portable_atmospherics/canister/toxins_special,
		"tequila_sunrise" = /obj/machinery/portable_atmospherics/canister/tequila_sunrise,
		"brave_bull" = /obj/machinery/portable_atmospherics/canister/brave_bull,
		"bloody_mary" = /obj/machinery/portable_atmospherics/canister/bloody_mary,
		"booger" = /obj/machinery/portable_atmospherics/canister/booger,
		"screwdrivercocktail" = /obj/machinery/portable_atmospherics/canister/screwdrivercocktail,
		"salty_water" = /obj/machinery/portable_atmospherics/canister/salty_water,
		"triple_coke" = /obj/machinery/portable_atmospherics/canister/triple_coke,
		"black_roulette" = /obj/machinery/portable_atmospherics/canister/black_roulette,
		"vodka_cola" = /obj/machinery/portable_atmospherics/canister/vodka_cola,
		"white_russian" = /obj/machinery/portable_atmospherics/canister/white_russian,
		"vodkamartini" = /obj/machinery/portable_atmospherics/canister/vodkamartini,
		"martini" = /obj/machinery/portable_atmospherics/canister/martini,
		"whiskey_cola" = /obj/machinery/portable_atmospherics/canister/whiskey_cola,
		"cuba_libre" = /obj/machinery/portable_atmospherics/canister/cuba_libre,
		"rum_coke" = /obj/machinery/portable_atmospherics/canister/rum_coke,
		"gintonic" = /obj/machinery/portable_atmospherics/canister/gintonic,
		"patron" = /obj/machinery/portable_atmospherics/canister/patron,
		"goldschlager" = /obj/machinery/portable_atmospherics/canister/goldschlager,
		"ale" = /obj/machinery/portable_atmospherics/canister/ale,
		"hooch" = /obj/machinery/portable_atmospherics/canister/hooch,
		"absinthe" = /obj/machinery/portable_atmospherics/canister/absinthe,
		"cognac" = /obj/machinery/portable_atmospherics/canister/cognac,
		"grappa" = /obj/machinery/portable_atmospherics/canister/grappa,
		"lizardwine" = /obj/machinery/portable_atmospherics/canister/lizardwine,
		"wine" = /obj/machinery/portable_atmospherics/canister/wine,
		"vermouth" = /obj/machinery/portable_atmospherics/canister/vermouth,
		"tequila" = /obj/machinery/portable_atmospherics/canister/tequila,
		"rum" = /obj/machinery/portable_atmospherics/canister/rum,
		"gin" = /obj/machinery/portable_atmospherics/canister/gin,
		"threemileisland" = /obj/machinery/portable_atmospherics/canister/threemileisland,
		"bilk" = /obj/machinery/portable_atmospherics/canister/bilk,
		"vodka" = /obj/machinery/portable_atmospherics/canister/vodka,
		"thirteenloko" = /obj/machinery/portable_atmospherics/canister/thirteenloko,
		"whiskey" = /obj/machinery/portable_atmospherics/canister/whiskey,
		"kahlua" = /obj/machinery/portable_atmospherics/canister/kahlua,
		"green" = /obj/machinery/portable_atmospherics/canister/green,
		"light" = /obj/machinery/portable_atmospherics/canister/light,
		"ftliver" = /obj/machinery/portable_atmospherics/canister/ftliver,
		"beer" = /obj/machinery/portable_atmospherics/canister/beer,
		"ethanol" = /obj/machinery/portable_atmospherics/canister/ethanol,
		// LIST END
		"miasma" = /obj/machinery/portable_atmospherics/canister/miasma
	)

/obj/machinery/portable_atmospherics/canister/interact(mob/user)
	if(!allowed(user))
		to_chat(user, "<span class='warning'>Error - Unauthorized User</span>")
		playsound(src, 'sound/misc/compiler-failure.ogg', 50, 1)
		return
	..()

/obj/machinery/portable_atmospherics/canister/nitrogen
	name = "n2 canister"
	desc = "Nitrogen gas. Reportedly useful for something."
	icon_state = "red"
	gas_type = /datum/gas/nitrogen

/obj/machinery/portable_atmospherics/canister/oxygen
	name = "o2 canister"
	desc = "Oxygen. Necessary for human life."
	icon_state = "blue"
	gas_type = /datum/gas/oxygen

/obj/machinery/portable_atmospherics/canister/carbon_dioxide
	name = "co2 canister"
	desc = "Carbon dioxide. What the fuck is carbon dioxide?"
	icon_state = "black"
	gas_type = /datum/gas/carbon_dioxide

/obj/machinery/portable_atmospherics/canister/toxins
	name = "plasma canister"
	desc = "Plasma gas. The reason YOU are here. Highly toxic."
	icon_state = "orange"
	gas_type = /datum/gas/plasma

/obj/machinery/portable_atmospherics/canister/bz
	name = "\improper BZ canister"
	desc = "BZ, a powerful hallucinogenic nerve agent."
	icon_state = "purple"
	gas_type = /datum/gas/bz

/obj/machinery/portable_atmospherics/canister/nitrous_oxide
	name = "n2o canister"
	desc = "Nitrous oxide gas. Known to cause drowsiness."
	icon_state = "redws"
	gas_type = /datum/gas/nitrous_oxide

/obj/machinery/portable_atmospherics/canister/air
	name = "air canister"
	desc = "Pre-mixed air."
	icon_state = "grey"

/obj/machinery/portable_atmospherics/canister/tritium
	name = "tritium canister"
	desc = "Tritium. Inhalation might cause irradiation."
	icon_state = "green"
	gas_type = /datum/gas/tritium

/obj/machinery/portable_atmospherics/canister/nob
	name = "hyper-noblium canister"
	desc = "Hyper-Noblium. More noble than all other gases."
	icon_state = "freon"
	gas_type = /datum/gas/hypernoblium

/obj/machinery/portable_atmospherics/canister/nitryl
	name = "nitryl canister"
	desc = "Nitryl gas. Feels great 'til the acid eats your lungs."
	icon_state = "brown"
	gas_type = /datum/gas/nitryl

/obj/machinery/portable_atmospherics/canister/stimulum
	name = "stimulum canister"
	desc = "Stimulum. High energy gas, high energy people."
	icon_state = "darkpurple"
	gas_type = /datum/gas/stimulum

/obj/machinery/portable_atmospherics/canister/pluoxium
	name = "pluoxium canister"
	desc = "Pluoxium. Like oxygen, but more bang for your buck."
	icon_state = "darkblue"
	gas_type = /datum/gas/pluoxium

/obj/machinery/portable_atmospherics/canister/water_vapor
	name = "water vapor canister"
	desc = "Water Vapor. We get it, you vape."
	icon_state = "water_vapor"
	gas_type = /datum/gas/water_vapor
	filled = 1

/obj/machinery/portable_atmospherics/canister/miasma
	name = "miasma canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/miasma
	filled = 1

// BEGIN

/obj/machinery/portable_atmospherics/canister/ethanol
	name = "ethanol canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/ethanol
	filled = 1

/obj/machinery/portable_atmospherics/canister/beer
	name = "beer canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/beer
	filled = 1

/obj/machinery/portable_atmospherics/canister/ftliver
	name = "ftliver canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/ftliver
	filled = 1

/obj/machinery/portable_atmospherics/canister/light
	name = "light canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/light
	filled = 1

/obj/machinery/portable_atmospherics/canister/green
	name = "green canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/green
	filled = 1

/obj/machinery/portable_atmospherics/canister/kahlua
	name = "kahlua canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/kahlua
	filled = 1

/obj/machinery/portable_atmospherics/canister/whiskey
	name = "whiskey canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/whiskey
	filled = 1

/obj/machinery/portable_atmospherics/canister/thirteenloko
	name = "thirteenloko canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/thirteenloko
	filled = 1

/obj/machinery/portable_atmospherics/canister/vodka
	name = "vodka canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/vodka
	filled = 1

/obj/machinery/portable_atmospherics/canister/bilk
	name = "bilk canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/bilk
	filled = 1

/obj/machinery/portable_atmospherics/canister/threemileisland
	name = "threemileisland canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/threemileisland
	filled = 1

/obj/machinery/portable_atmospherics/canister/gin
	name = "gin canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/gin
	filled = 1

/obj/machinery/portable_atmospherics/canister/rum
	name = "rum canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/rum
	filled = 1

/obj/machinery/portable_atmospherics/canister/tequila
	name = "tequila canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/tequila
	filled = 1

/obj/machinery/portable_atmospherics/canister/vermouth
	name = "vermouth canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/vermouth
	filled = 1

/obj/machinery/portable_atmospherics/canister/wine
	name = "wine canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/wine
	filled = 1

/obj/machinery/portable_atmospherics/canister/lizardwine
	name = "lizardwine canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/lizardwine
	filled = 1

/obj/machinery/portable_atmospherics/canister/grappa
	name = "grappa canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/grappa
	filled = 1

/obj/machinery/portable_atmospherics/canister/cognac
	name = "cognac canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/cognac
	filled = 1

/obj/machinery/portable_atmospherics/canister/absinthe
	name = "absinthe canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/absinthe
	filled = 1

/obj/machinery/portable_atmospherics/canister/hooch
	name = "hooch canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/hooch
	filled = 1

/obj/machinery/portable_atmospherics/canister/ale
	name = "ale canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/ale
	filled = 1

/obj/machinery/portable_atmospherics/canister/goldschlager
	name = "goldschlager canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/goldschlager
	filled = 1

/obj/machinery/portable_atmospherics/canister/patron
	name = "patron canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/patron
	filled = 1

/obj/machinery/portable_atmospherics/canister/gintonic
	name = "gintonic canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/gintonic
	filled = 1

/obj/machinery/portable_atmospherics/canister/rum_coke
	name = "rum_coke canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/rum_coke
	filled = 1

/obj/machinery/portable_atmospherics/canister/cuba_libre
	name = "cuba_libre canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/cuba_libre
	filled = 1

/obj/machinery/portable_atmospherics/canister/whiskey_cola
	name = "whiskey_cola canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/whiskey_cola
	filled = 1

/obj/machinery/portable_atmospherics/canister/martini
	name = "martini canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/martini
	filled = 1

/obj/machinery/portable_atmospherics/canister/vodkamartini
	name = "vodkamartini canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/vodkamartini
	filled = 1

/obj/machinery/portable_atmospherics/canister/white_russian
	name = "white_russian canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/white_russian
	filled = 1

/obj/machinery/portable_atmospherics/canister/vodka_cola
	name = "vodka_cola canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/vodka_cola
	filled = 1

/obj/machinery/portable_atmospherics/canister/black_roulette
	name = "black_roulette canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/black_roulette
	filled = 1

/obj/machinery/portable_atmospherics/canister/triple_coke
	name = "triple_coke canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/triple_coke
	filled = 1

/obj/machinery/portable_atmospherics/canister/salty_water
	name = "salty_water canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/salty_water
	filled = 1

/obj/machinery/portable_atmospherics/canister/screwdrivercocktail
	name = "screwdrivercocktail canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/screwdrivercocktail
	filled = 1

/obj/machinery/portable_atmospherics/canister/booger
	name = "booger canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/booger
	filled = 1

/obj/machinery/portable_atmospherics/canister/bloody_mary
	name = "bloody_mary canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/bloody_mary
	filled = 1

/obj/machinery/portable_atmospherics/canister/brave_bull
	name = "brave_bull canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/brave_bull
	filled = 1

/obj/machinery/portable_atmospherics/canister/tequila_sunrise
	name = "tequila_sunrise canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/tequila_sunrise
	filled = 1

/obj/machinery/portable_atmospherics/canister/toxins_special
	name = "toxins_special canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/toxins_special
	filled = 1

/obj/machinery/portable_atmospherics/canister/beepsky_smash
	name = "beepsky_smash canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/beepsky_smash
	filled = 1

/obj/machinery/portable_atmospherics/canister/irish_cream
	name = "irish_cream canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/irish_cream
	filled = 1

/obj/machinery/portable_atmospherics/canister/manly_dorf
	name = "manly_dorf canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/manly_dorf
	filled = 1

/obj/machinery/portable_atmospherics/canister/longislandicedtea
	name = "longislandicedtea canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/longislandicedtea
	filled = 1

/obj/machinery/portable_atmospherics/canister/moonshine
	name = "moonshine canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/moonshine
	filled = 1

/obj/machinery/portable_atmospherics/canister/b52
	name = "b52 canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/b52
	filled = 1

/obj/machinery/portable_atmospherics/canister/irishcoffee
	name = "irishcoffee canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/irishcoffee
	filled = 1

/obj/machinery/portable_atmospherics/canister/margarita
	name = "margarita canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/margarita
	filled = 1

/obj/machinery/portable_atmospherics/canister/black_russian
	name = "black_russian canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/black_russian
	filled = 1

/obj/machinery/portable_atmospherics/canister/manhattan
	name = "manhattan canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/manhattan
	filled = 1

/obj/machinery/portable_atmospherics/canister/manhattan_proj
	name = "manhattan_proj canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/manhattan_proj
	filled = 1

/obj/machinery/portable_atmospherics/canister/whiskeysoda
	name = "whiskeysoda canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/whiskeysoda
	filled = 1

/obj/machinery/portable_atmospherics/canister/antifreeze
	name = "antifreeze canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/antifreeze
	filled = 1

/obj/machinery/portable_atmospherics/canister/barefoot
	name = "barefoot canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/barefoot
	filled = 1

/obj/machinery/portable_atmospherics/canister/snowwhite
	name = "snowwhite canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/snowwhite
	filled = 1

/obj/machinery/portable_atmospherics/canister/demonsblood
	name = "demonsblood canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/demonsblood
	filled = 1

/obj/machinery/portable_atmospherics/canister/devilskiss
	name = "devilskiss canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/devilskiss
	filled = 1

/obj/machinery/portable_atmospherics/canister/vodkatonic
	name = "vodkatonic canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/vodkatonic
	filled = 1

/obj/machinery/portable_atmospherics/canister/ginfizz
	name = "ginfizz canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/ginfizz
	filled = 1

/obj/machinery/portable_atmospherics/canister/bahama_mama
	name = "bahama_mama canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/bahama_mama
	filled = 1

/obj/machinery/portable_atmospherics/canister/singulo
	name = "singulo canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/singulo
	filled = 1

/obj/machinery/portable_atmospherics/canister/sbiten
	name = "sbiten canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/sbiten
	filled = 1

/obj/machinery/portable_atmospherics/canister/red_mead
	name = "red_mead canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/red_mead
	filled = 1

/obj/machinery/portable_atmospherics/canister/mead
	name = "mead canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/mead
	filled = 1

/obj/machinery/portable_atmospherics/canister/iced_beer
	name = "iced_beer canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/iced_beer
	filled = 1

/obj/machinery/portable_atmospherics/canister/grog
	name = "grog canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/grog
	filled = 1

/obj/machinery/portable_atmospherics/canister/aloe
	name = "aloe canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/aloe
	filled = 1

/obj/machinery/portable_atmospherics/canister/andalusia
	name = "andalusia canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/andalusia
	filled = 1

/obj/machinery/portable_atmospherics/canister/alliescocktail
	name = "alliescocktail canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/alliescocktail
	filled = 1

/obj/machinery/portable_atmospherics/canister/acid_spit
	name = "acid_spit canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/acid_spit
	filled = 1

/obj/machinery/portable_atmospherics/canister/amasec
	name = "amasec canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/amasec
	filled = 1

/obj/machinery/portable_atmospherics/canister/changelingsting
	name = "changelingsting canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/changelingsting
	filled = 1

/obj/machinery/portable_atmospherics/canister/irishcarbomb
	name = "irishcarbomb canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/irishcarbomb
	filled = 1

/obj/machinery/portable_atmospherics/canister/syndicatebomb
	name = "syndicatebomb canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/syndicatebomb
	filled = 1

/obj/machinery/portable_atmospherics/canister/erikasurprise
	name = "erikasurprise canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/erikasurprise
	filled = 1

/obj/machinery/portable_atmospherics/canister/driestmartini
	name = "driestmartini canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/driestmartini
	filled = 1

/obj/machinery/portable_atmospherics/canister/bananahonk
	name = "bananahonk canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/bananahonk
	filled = 1

/obj/machinery/portable_atmospherics/canister/silencer
	name = "silencer canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/silencer
	filled = 1

/obj/machinery/portable_atmospherics/canister/drunkenblumpkin
	name = "drunkenblumpkin canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/drunkenblumpkin
	filled = 1

/obj/machinery/portable_atmospherics/canister/whiskey_sour
	name = "whiskey_sour canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/whiskey_sour
	filled = 1

/obj/machinery/portable_atmospherics/canister/hcider
	name = "hcider canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/hcider
	filled = 1

/obj/machinery/portable_atmospherics/canister/fetching_fizz
	name = "fetching_fizz canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/fetching_fizz
	filled = 1

/obj/machinery/portable_atmospherics/canister/hearty_punch
	name = "hearty_punch canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/hearty_punch
	filled = 1

/obj/machinery/portable_atmospherics/canister/bacchus_blessing
	name = "bacchus_blessing canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/bacchus_blessing
	filled = 1

/obj/machinery/portable_atmospherics/canister/atomicbomb
	name = "atomicbomb canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/atomicbomb
	filled = 1

/obj/machinery/portable_atmospherics/canister/gargle_blaster
	name = "gargle_blaster canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/gargle_blaster
	filled = 1

/obj/machinery/portable_atmospherics/canister/neurotoxin
	name = "neurotoxin canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/neurotoxin
	filled = 1

/obj/machinery/portable_atmospherics/canister/hippies_delight
	name = "hippies_delight canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/hippies_delight
	filled = 1

/obj/machinery/portable_atmospherics/canister/eggnog
	name = "eggnog canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/eggnog
	filled = 1

/obj/machinery/portable_atmospherics/canister/narsour
	name = "narsour canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/narsour
	filled = 1

/obj/machinery/portable_atmospherics/canister/triple_sec
	name = "triple_sec canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/triple_sec
	filled = 1

/obj/machinery/portable_atmospherics/canister/creme_de_menthe
	name = "creme_de_menthe canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/creme_de_menthe
	filled = 1

/obj/machinery/portable_atmospherics/canister/creme_de_cacao
	name = "creme_de_cacao canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/creme_de_cacao
	filled = 1

/obj/machinery/portable_atmospherics/canister/quadruple_sec
	name = "quadruple_sec canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/quadruple_sec
	filled = 1

/obj/machinery/portable_atmospherics/canister/quintuple_sec
	name = "quintuple_sec canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/quintuple_sec
	filled = 1

/obj/machinery/portable_atmospherics/canister/grasshopper
	name = "grasshopper canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/grasshopper
	filled = 1

/obj/machinery/portable_atmospherics/canister/stinger
	name = "stinger canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/stinger
	filled = 1

/obj/machinery/portable_atmospherics/canister/bastion_bourbon
	name = "bastion_bourbon canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/bastion_bourbon
	filled = 1

/obj/machinery/portable_atmospherics/canister/squirt_cider
	name = "squirt_cider canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/squirt_cider
	filled = 1

/obj/machinery/portable_atmospherics/canister/fringe_weaver
	name = "fringe_weaver canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/fringe_weaver
	filled = 1

/obj/machinery/portable_atmospherics/canister/sugar_rush
	name = "sugar_rush canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/sugar_rush
	filled = 1

/obj/machinery/portable_atmospherics/canister/crevice_spike
	name = "crevice_spike canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/crevice_spike
	filled = 1

/obj/machinery/portable_atmospherics/canister/sake
	name = "sake canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/sake
	filled = 1

/obj/machinery/portable_atmospherics/canister/peppermint_patty
	name = "peppermint_patty canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/peppermint_patty
	filled = 1

/obj/machinery/portable_atmospherics/canister/alexander
	name = "alexander canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/alexander
	filled = 1

/obj/machinery/portable_atmospherics/canister/sidecar
	name = "sidecar canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/sidecar
	filled = 1

/obj/machinery/portable_atmospherics/canister/between_the_sheets
	name = "between_the_sheets canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/between_the_sheets
	filled = 1

/obj/machinery/portable_atmospherics/canister/kamikaze
	name = "kamikaze canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/kamikaze
	filled = 1

/obj/machinery/portable_atmospherics/canister/mojito
	name = "mojito canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/mojito
	filled = 1

/obj/machinery/portable_atmospherics/canister/fernet
	name = "fernet canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/fernet
	filled = 1

/obj/machinery/portable_atmospherics/canister/fernet_cola
	name = "fernet_cola canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/fernet_cola
	filled = 1

/obj/machinery/portable_atmospherics/canister/fanciulli
	name = "fanciulli canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/fanciulli
	filled = 1

/obj/machinery/portable_atmospherics/canister/branca_menta
	name = "branca_menta canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/branca_menta
	filled = 1

/obj/machinery/portable_atmospherics/canister/blank_paper
	name = "blank_paper canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/blank_paper
	filled = 1

/obj/machinery/portable_atmospherics/canister/fruit_wine
	name = "fruit_wine canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/fruit_wine
	filled = 1

/obj/machinery/portable_atmospherics/canister/champagne
	name = "champagne canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/champagne
	filled = 1

/obj/machinery/portable_atmospherics/canister/wizz_fizz
	name = "wizz_fizz canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/wizz_fizz
	filled = 1

/obj/machinery/portable_atmospherics/canister/bug_spray
	name = "bug_spray canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/bug_spray
	filled = 1

/obj/machinery/portable_atmospherics/canister/applejack
	name = "applejack canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/applejack
	filled = 1

/obj/machinery/portable_atmospherics/canister/jack_rose
	name = "jack_rose canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/jack_rose
	filled = 1

/obj/machinery/portable_atmospherics/canister/turbo
	name = "turbo canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/turbo
	filled = 1

/obj/machinery/portable_atmospherics/canister/old_timer
	name = "old_timer canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/old_timer
	filled = 1

/obj/machinery/portable_atmospherics/canister/rubberneck
	name = "rubberneck canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/rubberneck
	filled = 1

/obj/machinery/portable_atmospherics/canister/duplex
	name = "duplex canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/duplex
	filled = 1

/obj/machinery/portable_atmospherics/canister/trappist
	name = "trappist canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/trappist
	filled = 1

/obj/machinery/portable_atmospherics/canister/blazaam
	name = "blazaam canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/blazaam
	filled = 1

/obj/machinery/portable_atmospherics/canister/planet_cracker
	name = "planet_cracker canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/planet_cracker
	filled = 1

/obj/machinery/portable_atmospherics/canister/mauna_loa
	name = "mauna_loa canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/mauna_loa
	filled = 1

/obj/machinery/portable_atmospherics/canister/plasmaflood
	name = "plasmaflood canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/plasmaflood
	filled = 1

/obj/machinery/portable_atmospherics/canister/fourthwall
	name = "fourthwall canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/fourthwall
	filled = 1

/obj/machinery/portable_atmospherics/canister/ratvander
	name = "ratvander canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/ratvander
	filled = 1

/obj/machinery/portable_atmospherics/canister/icewing
	name = "icewing canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/icewing
	filled = 1

/obj/machinery/portable_atmospherics/canister/sarsaparilliansunset
	name = "sarsaparilliansunset canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/sarsaparilliansunset
	filled = 1

/obj/machinery/portable_atmospherics/canister/beesknees
	name = "beesknees canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/beesknees
	filled = 1

/obj/machinery/portable_atmospherics/canister/orangejuice
	name = "orangejuice canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/orangejuice
	filled = 1

/obj/machinery/portable_atmospherics/canister/tomatojuice
	name = "tomatojuice canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/tomatojuice
	filled = 1

/obj/machinery/portable_atmospherics/canister/limejuice
	name = "limejuice canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/limejuice
	filled = 1

/obj/machinery/portable_atmospherics/canister/carrotjuice
	name = "carrotjuice canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/carrotjuice
	filled = 1

/obj/machinery/portable_atmospherics/canister/berryjuice
	name = "berryjuice canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/berryjuice
	filled = 1

/obj/machinery/portable_atmospherics/canister/applejuice
	name = "applejuice canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/applejuice
	filled = 1

/obj/machinery/portable_atmospherics/canister/poisonberryjuice
	name = "poisonberryjuice canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/poisonberryjuice
	filled = 1

/obj/machinery/portable_atmospherics/canister/watermelonjuice
	name = "watermelonjuice canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/watermelonjuice
	filled = 1

/obj/machinery/portable_atmospherics/canister/lemonjuice
	name = "lemonjuice canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/lemonjuice
	filled = 1

/obj/machinery/portable_atmospherics/canister/banana
	name = "banana canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/banana
	filled = 1

/obj/machinery/portable_atmospherics/canister/nothing
	name = "nothing canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/nothing
	filled = 1

/obj/machinery/portable_atmospherics/canister/laughter
	name = "laughter canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/laughter
	filled = 1

/obj/machinery/portable_atmospherics/canister/superlaughter
	name = "superlaughter canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/superlaughter
	filled = 1

/obj/machinery/portable_atmospherics/canister/potato_juice
	name = "potato_juice canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/potato_juice
	filled = 1

/obj/machinery/portable_atmospherics/canister/grapejuice
	name = "grapejuice canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/grapejuice
	filled = 1

/obj/machinery/portable_atmospherics/canister/milk
	name = "milk canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/milk
	filled = 1

/obj/machinery/portable_atmospherics/canister/soymilk
	name = "soymilk canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/soymilk
	filled = 1

/obj/machinery/portable_atmospherics/canister/cream
	name = "cream canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/cream
	filled = 1

/obj/machinery/portable_atmospherics/canister/coffee
	name = "coffee canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/coffee
	filled = 1

/obj/machinery/portable_atmospherics/canister/tea
	name = "tea canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/tea
	filled = 1

/obj/machinery/portable_atmospherics/canister/lemonade
	name = "lemonade canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/lemonade
	filled = 1

/obj/machinery/portable_atmospherics/canister/arnold_palmer
	name = "arnold_palmer canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/arnold_palmer
	filled = 1

/obj/machinery/portable_atmospherics/canister/icecoffee
	name = "icecoffee canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/icecoffee
	filled = 1

/obj/machinery/portable_atmospherics/canister/icetea
	name = "icetea canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/icetea
	filled = 1

/obj/machinery/portable_atmospherics/canister/space_cola
	name = "space_cola canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/space_cola
	filled = 1

/obj/machinery/portable_atmospherics/canister/nuka_cola
	name = "nuka_cola canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/nuka_cola
	filled = 1

/obj/machinery/portable_atmospherics/canister/grey_bull
	name = "grey_bull canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/grey_bull
	filled = 1

/obj/machinery/portable_atmospherics/canister/spacemountainwind
	name = "spacemountainwind canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/spacemountainwind
	filled = 1

/obj/machinery/portable_atmospherics/canister/dr_gibb
	name = "dr_gibb canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/dr_gibb
	filled = 1

/obj/machinery/portable_atmospherics/canister/space_up
	name = "space_up canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/space_up
	filled = 1

/obj/machinery/portable_atmospherics/canister/lemon_lime
	name = "lemon_lime canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/lemon_lime
	filled = 1

/obj/machinery/portable_atmospherics/canister/pwr_game
	name = "pwr_game canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/pwr_game
	filled = 1

/obj/machinery/portable_atmospherics/canister/shamblers
	name = "shamblers canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/shamblers
	filled = 1

/obj/machinery/portable_atmospherics/canister/sodawater
	name = "sodawater canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/sodawater
	filled = 1

/obj/machinery/portable_atmospherics/canister/tonic
	name = "tonic canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/tonic
	filled = 1

/obj/machinery/portable_atmospherics/canister/monkey_energy
	name = "monkey_energy canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/monkey_energy
	filled = 1

/obj/machinery/portable_atmospherics/canister/ice
	name = "ice canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/ice
	filled = 1

/obj/machinery/portable_atmospherics/canister/soy_latte
	name = "soy_latte canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/soy_latte
	filled = 1

/obj/machinery/portable_atmospherics/canister/cafe_latte
	name = "cafe_latte canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/cafe_latte
	filled = 1

/obj/machinery/portable_atmospherics/canister/doctor_delight
	name = "doctor_delight canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/doctor_delight
	filled = 1

/obj/machinery/portable_atmospherics/canister/chocolatepudding
	name = "chocolatepudding canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/chocolatepudding
	filled = 1

/obj/machinery/portable_atmospherics/canister/vanillapudding
	name = "vanillapudding canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/vanillapudding
	filled = 1

/obj/machinery/portable_atmospherics/canister/cherryshake
	name = "cherryshake canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/cherryshake
	filled = 1

/obj/machinery/portable_atmospherics/canister/bluecherryshake
	name = "bluecherryshake canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/bluecherryshake
	filled = 1

/obj/machinery/portable_atmospherics/canister/pumpkin_latte
	name = "pumpkin_latte canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/pumpkin_latte
	filled = 1

/obj/machinery/portable_atmospherics/canister/gibbfloats
	name = "gibbfloats canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/gibbfloats
	filled = 1

/obj/machinery/portable_atmospherics/canister/pumpkinjuice
	name = "pumpkinjuice canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/pumpkinjuice
	filled = 1

/obj/machinery/portable_atmospherics/canister/blumpkinjuice
	name = "blumpkinjuice canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/blumpkinjuice
	filled = 1

/obj/machinery/portable_atmospherics/canister/triple_citrus
	name = "triple_citrus canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/triple_citrus
	filled = 1

/obj/machinery/portable_atmospherics/canister/grape_soda
	name = "grape_soda canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/grape_soda
	filled = 1

/obj/machinery/portable_atmospherics/canister/chocolate_milk
	name = "chocolate_milk canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/chocolate_milk
	filled = 1

/obj/machinery/portable_atmospherics/canister/menthol
	name = "menthol canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/menthol
	filled = 1

/obj/machinery/portable_atmospherics/canister/grenadine
	name = "grenadine canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/grenadine
	filled = 1

/obj/machinery/portable_atmospherics/canister/parsnipjuice
	name = "parsnipjuice canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/parsnipjuice
	filled = 1

/obj/machinery/portable_atmospherics/canister/peachjuice
	name = "peachjuice canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/peachjuice
	filled = 1

/obj/machinery/portable_atmospherics/canister/cream_soda
	name = "cream_soda canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/cream_soda
	filled = 1

/obj/machinery/portable_atmospherics/canister/red_queen
	name = "red_queen canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/red_queen
	filled = 1

/obj/machinery/portable_atmospherics/canister/bungojuice
	name = "bungojuice canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/bungojuice
	filled = 1

/obj/machinery/portable_atmospherics/canister/drug
	name = "drug canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/drug
	filled = 1

/obj/machinery/portable_atmospherics/canister/space_drugs
	name = "space_drugs canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/space_drugs
	filled = 1

/obj/machinery/portable_atmospherics/canister/nicotine
	name = "nicotine canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/nicotine
	filled = 1

/obj/machinery/portable_atmospherics/canister/crank
	name = "crank canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/crank
	filled = 1

/obj/machinery/portable_atmospherics/canister/krokodil
	name = "krokodil canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/krokodil
	filled = 1

/obj/machinery/portable_atmospherics/canister/methamphetamine
	name = "methamphetamine canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/methamphetamine
	filled = 1

/obj/machinery/portable_atmospherics/canister/bath_salts
	name = "bath_salts canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/bath_salts
	filled = 1

/obj/machinery/portable_atmospherics/canister/aranesp
	name = "aranesp canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/aranesp
	filled = 1

/obj/machinery/portable_atmospherics/canister/happiness
	name = "happiness canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/happiness
	filled = 1

/obj/machinery/portable_atmospherics/canister/nutriment
	name = "nutriment canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/nutriment
	filled = 1

/obj/machinery/portable_atmospherics/canister/vitamin
	name = "vitamin canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/vitamin
	filled = 1

/obj/machinery/portable_atmospherics/canister/cooking_oil
	name = "cooking_oil canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/cooking_oil
	filled = 1

/obj/machinery/portable_atmospherics/canister/sugar
	name = "sugar canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/sugar
	filled = 1

/obj/machinery/portable_atmospherics/canister/virus_food
	name = "virus_food canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/virus_food
	filled = 1

/obj/machinery/portable_atmospherics/canister/soysauce
	name = "soysauce canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/soysauce
	filled = 1

/obj/machinery/portable_atmospherics/canister/ketchup
	name = "ketchup canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/ketchup
	filled = 1

/obj/machinery/portable_atmospherics/canister/capsaicin
	name = "capsaicin canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/capsaicin
	filled = 1

/obj/machinery/portable_atmospherics/canister/frostoil
	name = "frostoil canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/frostoil
	filled = 1

/obj/machinery/portable_atmospherics/canister/condensedcapsaicin
	name = "condensedcapsaicin canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/condensedcapsaicin
	filled = 1

/obj/machinery/portable_atmospherics/canister/sodiumchloride
	name = "sodiumchloride canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/sodiumchloride
	filled = 1

/obj/machinery/portable_atmospherics/canister/blackpepper
	name = "blackpepper canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/blackpepper
	filled = 1

/obj/machinery/portable_atmospherics/canister/coco
	name = "coco canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/coco
	filled = 1

/obj/machinery/portable_atmospherics/canister/hot_coco
	name = "hot_coco canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/hot_coco
	filled = 1

/obj/machinery/portable_atmospherics/canister/mushroomhallucinogen
	name = "mushroomhallucinogen canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/mushroomhallucinogen
	filled = 1

/obj/machinery/portable_atmospherics/canister/garlic
	name = "garlic canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/garlic
	filled = 1

/obj/machinery/portable_atmospherics/canister/sprinkles
	name = "sprinkles canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/sprinkles
	filled = 1

/obj/machinery/portable_atmospherics/canister/cornoil
	name = "cornoil canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/cornoil
	filled = 1

/obj/machinery/portable_atmospherics/canister/enzyme
	name = "enzyme canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/enzyme
	filled = 1

/obj/machinery/portable_atmospherics/canister/dry_ramen
	name = "dry_ramen canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/dry_ramen
	filled = 1

/obj/machinery/portable_atmospherics/canister/hot_ramen
	name = "hot_ramen canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/hot_ramen
	filled = 1

/obj/machinery/portable_atmospherics/canister/hell_ramen
	name = "hell_ramen canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/hell_ramen
	filled = 1

/obj/machinery/portable_atmospherics/canister/flour
	name = "flour canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/flour
	filled = 1

/obj/machinery/portable_atmospherics/canister/cherryjelly
	name = "cherryjelly canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/cherryjelly
	filled = 1

/obj/machinery/portable_atmospherics/canister/bluecherryjelly
	name = "bluecherryjelly canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/bluecherryjelly
	filled = 1

/obj/machinery/portable_atmospherics/canister/rice
	name = "rice canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/rice
	filled = 1

/obj/machinery/portable_atmospherics/canister/vanilla
	name = "vanilla canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/vanilla
	filled = 1

/obj/machinery/portable_atmospherics/canister/eggyolk
	name = "eggyolk canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/eggyolk
	filled = 1

/obj/machinery/portable_atmospherics/canister/corn_starch
	name = "corn_starch canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/corn_starch
	filled = 1

/obj/machinery/portable_atmospherics/canister/corn_syrup
	name = "corn_syrup canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/corn_syrup
	filled = 1

/obj/machinery/portable_atmospherics/canister/honey
	name = "honey canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/honey
	filled = 1

/obj/machinery/portable_atmospherics/canister/special
	name = "special canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/special
	filled = 1

/obj/machinery/portable_atmospherics/canister/mayonnaise
	name = "mayonnaise canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/mayonnaise
	filled = 1

/obj/machinery/portable_atmospherics/canister/tearjuice
	name = "tearjuice canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/tearjuice
	filled = 1

/obj/machinery/portable_atmospherics/canister/stabilized
	name = "stabilized canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/stabilized
	filled = 1

/obj/machinery/portable_atmospherics/canister/entpoly
	name = "entpoly canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/entpoly
	filled = 1

/obj/machinery/portable_atmospherics/canister/tinlux
	name = "tinlux canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/tinlux
	filled = 1

/obj/machinery/portable_atmospherics/canister/vitfro
	name = "vitfro canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/vitfro
	filled = 1

/obj/machinery/portable_atmospherics/canister/clownstears
	name = "clownstears canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/clownstears
	filled = 1

/obj/machinery/portable_atmospherics/canister/liquidelectricity
	name = "liquidelectricity canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/liquidelectricity
	filled = 1

/obj/machinery/portable_atmospherics/canister/astrotame
	name = "astrotame canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/astrotame
	filled = 1

/obj/machinery/portable_atmospherics/canister/caramel
	name = "caramel canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/caramel
	filled = 1

/obj/machinery/portable_atmospherics/canister/bbqsauce
	name = "bbqsauce canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/bbqsauce
	filled = 1

/obj/machinery/portable_atmospherics/canister/char
	name = "char canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/char
	filled = 1

/obj/machinery/portable_atmospherics/canister/medicine
	name = "medicine canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/medicine
	filled = 1

/obj/machinery/portable_atmospherics/canister/leporazine
	name = "leporazine canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/leporazine
	filled = 1

/obj/machinery/portable_atmospherics/canister/adminordrazine
	name = "adminordrazine canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/adminordrazine
	filled = 1

/obj/machinery/portable_atmospherics/canister/quantum_heal
	name = "quantum_heal canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/quantum_heal
	filled = 1

/obj/machinery/portable_atmospherics/canister/synaptizine
	name = "synaptizine canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/synaptizine
	filled = 1

/obj/machinery/portable_atmospherics/canister/synaphydramine
	name = "synaphydramine canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/synaphydramine
	filled = 1

/obj/machinery/portable_atmospherics/canister/inacusiate
	name = "inacusiate canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/inacusiate
	filled = 1

/obj/machinery/portable_atmospherics/canister/cryoxadone
	name = "cryoxadone canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/cryoxadone
	filled = 1

/obj/machinery/portable_atmospherics/canister/clonexadone
	name = "clonexadone canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/clonexadone
	filled = 1

/obj/machinery/portable_atmospherics/canister/pyroxadone
	name = "pyroxadone canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/pyroxadone
	filled = 1

/obj/machinery/portable_atmospherics/canister/rezadone
	name = "rezadone canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/rezadone
	filled = 1

/obj/machinery/portable_atmospherics/canister/spaceacillin
	name = "spaceacillin canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/spaceacillin
	filled = 1

/obj/machinery/portable_atmospherics/canister/silver_sulfadiazine
	name = "silver_sulfadiazine canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/silver_sulfadiazine
	filled = 1

/obj/machinery/portable_atmospherics/canister/oxandrolone
	name = "oxandrolone canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/oxandrolone
	filled = 1

/obj/machinery/portable_atmospherics/canister/styptic_powder
	name = "styptic_powder canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/styptic_powder
	filled = 1

/obj/machinery/portable_atmospherics/canister/salglu_solution
	name = "salglu_solution canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/salglu_solution
	filled = 1

/obj/machinery/portable_atmospherics/canister/mine_salve
	name = "mine_salve canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/mine_salve
	filled = 1

/obj/machinery/portable_atmospherics/canister/synthflesh
	name = "synthflesh canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/synthflesh
	filled = 1

/obj/machinery/portable_atmospherics/canister/charcoal
	name = "charcoal canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/charcoal
	filled = 1

/obj/machinery/portable_atmospherics/canister/system_cleaner
	name = "system_cleaner canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/system_cleaner
	filled = 1

/obj/machinery/portable_atmospherics/canister/liquid_solder
	name = "liquid_solder canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/liquid_solder
	filled = 1

/obj/machinery/portable_atmospherics/canister/omnizine
	name = "omnizine canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/omnizine
	filled = 1

/obj/machinery/portable_atmospherics/canister/calomel
	name = "calomel canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/calomel
	filled = 1

/obj/machinery/portable_atmospherics/canister/potass_iodide
	name = "potass_iodide canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/potass_iodide
	filled = 1

/obj/machinery/portable_atmospherics/canister/pen_acid
	name = "pen_acid canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/pen_acid
	filled = 1

/obj/machinery/portable_atmospherics/canister/sal_acid
	name = "sal_acid canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/sal_acid
	filled = 1

/obj/machinery/portable_atmospherics/canister/salbutamol
	name = "salbutamol canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/salbutamol
	filled = 1

/obj/machinery/portable_atmospherics/canister/perfluorodecalin
	name = "perfluorodecalin canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/perfluorodecalin
	filled = 1

/obj/machinery/portable_atmospherics/canister/ephedrine
	name = "ephedrine canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/ephedrine
	filled = 1

/obj/machinery/portable_atmospherics/canister/diphenhydramine
	name = "diphenhydramine canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/diphenhydramine
	filled = 1

/obj/machinery/portable_atmospherics/canister/morphine
	name = "morphine canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/morphine
	filled = 1

/obj/machinery/portable_atmospherics/canister/oculine
	name = "oculine canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/oculine
	filled = 1

/obj/machinery/portable_atmospherics/canister/atropine
	name = "atropine canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/atropine
	filled = 1

/obj/machinery/portable_atmospherics/canister/epinephrine
	name = "epinephrine canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/epinephrine
	filled = 1

/obj/machinery/portable_atmospherics/canister/strange_reagent
	name = "strange_reagent canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/strange_reagent
	filled = 1

/obj/machinery/portable_atmospherics/canister/mannitol
	name = "mannitol canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/mannitol
	filled = 1

/obj/machinery/portable_atmospherics/canister/neurine
	name = "neurine canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/neurine
	filled = 1

/obj/machinery/portable_atmospherics/canister/mutadone
	name = "mutadone canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/mutadone
	filled = 1

/obj/machinery/portable_atmospherics/canister/antihol
	name = "antihol canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/antihol
	filled = 1

/obj/machinery/portable_atmospherics/canister/stimulants
	name = "stimulants canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/stimulants
	filled = 1

/obj/machinery/portable_atmospherics/canister/pumpup
	name = "pumpup canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/pumpup
	filled = 1

/obj/machinery/portable_atmospherics/canister/insulin
	name = "insulin canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/insulin
	filled = 1

/obj/machinery/portable_atmospherics/canister/bicaridine
	name = "bicaridine canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/bicaridine
	filled = 1

/obj/machinery/portable_atmospherics/canister/kelotane
	name = "kelotane canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/kelotane
	filled = 1

/obj/machinery/portable_atmospherics/canister/antitoxin
	name = "antitoxin canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/antitoxin
	filled = 1

/obj/machinery/portable_atmospherics/canister/carthatoline
	name = "carthatoline canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/carthatoline
	filled = 1

/obj/machinery/portable_atmospherics/canister/hepanephrodaxon
	name = "hepanephrodaxon canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/hepanephrodaxon
	filled = 1

/obj/machinery/portable_atmospherics/canister/inaprovaline
	name = "inaprovaline canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/inaprovaline
	filled = 1

/obj/machinery/portable_atmospherics/canister/tricordrazine
	name = "tricordrazine canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/tricordrazine
	filled = 1

/obj/machinery/portable_atmospherics/canister/regen_jelly
	name = "regen_jelly canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/regen_jelly
	filled = 1

/obj/machinery/portable_atmospherics/canister/syndicate_nanites
	name = "syndicate_nanites canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/syndicate_nanites
	filled = 1

/obj/machinery/portable_atmospherics/canister/earthsblood
	name = "earthsblood canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/earthsblood
	filled = 1

/obj/machinery/portable_atmospherics/canister/haloperidol
	name = "haloperidol canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/haloperidol
	filled = 1

/obj/machinery/portable_atmospherics/canister/lavaland_extract
	name = "lavaland_extract canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/lavaland_extract
	filled = 1

/obj/machinery/portable_atmospherics/canister/changelingadrenaline
	name = "changelingadrenaline canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/changelingadrenaline
	filled = 1

/obj/machinery/portable_atmospherics/canister/changelinghaste
	name = "changelinghaste canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/changelinghaste
	filled = 1

/obj/machinery/portable_atmospherics/canister/corazone
	name = "corazone canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/corazone
	filled = 1

/obj/machinery/portable_atmospherics/canister/muscle_stimulant
	name = "muscle_stimulant canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/muscle_stimulant
	filled = 1

/obj/machinery/portable_atmospherics/canister/modafinil
	name = "modafinil canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/modafinil
	filled = 1

/obj/machinery/portable_atmospherics/canister/psicodine
	name = "psicodine canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/psicodine
	filled = 1

/obj/machinery/portable_atmospherics/canister/silibinin
	name = "silibinin canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/silibinin
	filled = 1

/obj/machinery/portable_atmospherics/canister/polypyr
	name = "polypyr canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/polypyr
	filled = 1

/obj/machinery/portable_atmospherics/canister/blood
	name = "blood canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/blood
	filled = 1

/obj/machinery/portable_atmospherics/canister/liquidgibs
	name = "liquidgibs canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/liquidgibs
	filled = 1

/obj/machinery/portable_atmospherics/canister/vaccine
	name = "vaccine canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/vaccine
	filled = 1

/obj/machinery/portable_atmospherics/canister/water
	name = "water canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/water
	filled = 1

/obj/machinery/portable_atmospherics/canister/holywater
	name = "holywater canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/holywater
	filled = 1

/obj/machinery/portable_atmospherics/canister/unholywater
	name = "unholywater canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/unholywater
	filled = 1

/obj/machinery/portable_atmospherics/canister/hellwater
	name = "hellwater canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/hellwater
	filled = 1

/obj/machinery/portable_atmospherics/canister/godblood
	name = "godblood canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/godblood
	filled = 1

/obj/machinery/portable_atmospherics/canister/lube
	name = "lube canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/lube
	filled = 1

/obj/machinery/portable_atmospherics/canister/spraytan
	name = "spraytan canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/spraytan
	filled = 1

/obj/machinery/portable_atmospherics/canister/mutationtoxin
	name = "mutationtoxin canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/mutationtoxin
	filled = 1

/obj/machinery/portable_atmospherics/canister/classic
	name = "classic canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/classic
	filled = 1

/obj/machinery/portable_atmospherics/canister/unstable
	name = "unstable canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/unstable
	filled = 1

/obj/machinery/portable_atmospherics/canister/felinid
	name = "felinid canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/felinid
	filled = 1

/obj/machinery/portable_atmospherics/canister/lizard
	name = "lizard canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/lizard
	filled = 1

/obj/machinery/portable_atmospherics/canister/fly
	name = "fly canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/fly
	filled = 1

/obj/machinery/portable_atmospherics/canister/moth
	name = "moth canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/moth
	filled = 1

/obj/machinery/portable_atmospherics/canister/pod
	name = "pod canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/pod
	filled = 1

/obj/machinery/portable_atmospherics/canister/jelly
	name = "jelly canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/jelly
	filled = 1

/obj/machinery/portable_atmospherics/canister/golem
	name = "golem canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/golem
	filled = 1

/obj/machinery/portable_atmospherics/canister/abductor
	name = "abductor canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/abductor
	filled = 1

/obj/machinery/portable_atmospherics/canister/android
	name = "android canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/android
	filled = 1

/obj/machinery/portable_atmospherics/canister/ipc
	name = "ipc canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/ipc
	filled = 1

/obj/machinery/portable_atmospherics/canister/squid
	name = "squid canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/squid
	filled = 1

/obj/machinery/portable_atmospherics/canister/skeleton
	name = "skeleton canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/skeleton
	filled = 1

/obj/machinery/portable_atmospherics/canister/zombie
	name = "zombie canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/zombie
	filled = 1

/obj/machinery/portable_atmospherics/canister/goofzombie
	name = "goofzombie canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/goofzombie
	filled = 1

/obj/machinery/portable_atmospherics/canister/ash
	name = "ash canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/ash
	filled = 1

/obj/machinery/portable_atmospherics/canister/supersoldier
	name = "supersoldier canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/supersoldier
	filled = 1

/obj/machinery/portable_atmospherics/canister/shadow
	name = "shadow canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/shadow
	filled = 1

/obj/machinery/portable_atmospherics/canister/slime_toxin
	name = "slime_toxin canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/slime_toxin
	filled = 1

/obj/machinery/portable_atmospherics/canister/mulligan
	name = "mulligan canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/mulligan
	filled = 1

/obj/machinery/portable_atmospherics/canister/aslimetoxin
	name = "aslimetoxin canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/aslimetoxin
	filled = 1

/obj/machinery/portable_atmospherics/canister/gluttonytoxin
	name = "gluttonytoxin canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/gluttonytoxin
	filled = 1

/obj/machinery/portable_atmospherics/canister/serotrotium
	name = "serotrotium canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/serotrotium
	filled = 1

/obj/machinery/portable_atmospherics/canister/copper
	name = "copper canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/copper
	filled = 1

/obj/machinery/portable_atmospherics/canister/hydrogen
	name = "hydrogen canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/hydrogen
	filled = 1

/obj/machinery/portable_atmospherics/canister/potassium
	name = "potassium canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/potassium
	filled = 1

/obj/machinery/portable_atmospherics/canister/mercury
	name = "mercury canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/mercury
	filled = 1

/obj/machinery/portable_atmospherics/canister/sulfur
	name = "sulfur canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/sulfur
	filled = 1

/obj/machinery/portable_atmospherics/canister/carbon
	name = "carbon canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/carbon
	filled = 1

/obj/machinery/portable_atmospherics/canister/chlorine
	name = "chlorine canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/chlorine
	filled = 1

/obj/machinery/portable_atmospherics/canister/fluorine
	name = "fluorine canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/fluorine
	filled = 1

/obj/machinery/portable_atmospherics/canister/sodium
	name = "sodium canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/sodium
	filled = 1

/obj/machinery/portable_atmospherics/canister/phosphorus
	name = "phosphorus canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/phosphorus
	filled = 1

/obj/machinery/portable_atmospherics/canister/lithium
	name = "lithium canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/lithium
	filled = 1

/obj/machinery/portable_atmospherics/canister/glycerol
	name = "glycerol canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/glycerol
	filled = 1

/obj/machinery/portable_atmospherics/canister/sterilizine
	name = "sterilizine canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/sterilizine
	filled = 1

/obj/machinery/portable_atmospherics/canister/iron
	name = "iron canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/iron
	filled = 1

/obj/machinery/portable_atmospherics/canister/gold
	name = "gold canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/gold
	filled = 1

/obj/machinery/portable_atmospherics/canister/silver
	name = "silver canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/silver
	filled = 1

/obj/machinery/portable_atmospherics/canister/uranium
	name = "uranium canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/uranium
	filled = 1

/obj/machinery/portable_atmospherics/canister/radium
	name = "radium canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/radium
	filled = 1

/obj/machinery/portable_atmospherics/canister/bluespace
	name = "bluespace canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/bluespace
	filled = 1

/obj/machinery/portable_atmospherics/canister/aluminium
	name = "aluminium canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/aluminium
	filled = 1

/obj/machinery/portable_atmospherics/canister/silicon
	name = "silicon canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/silicon
	filled = 1

/obj/machinery/portable_atmospherics/canister/fuel
	name = "fuel canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/fuel
	filled = 1

/obj/machinery/portable_atmospherics/canister/space_cleaner
	name = "space_cleaner canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/space_cleaner
	filled = 1

/obj/machinery/portable_atmospherics/canister/ez_clean
	name = "ez_clean canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/ez_clean
	filled = 1

/obj/machinery/portable_atmospherics/canister/cryptobiolin
	name = "cryptobiolin canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/cryptobiolin
	filled = 1

/obj/machinery/portable_atmospherics/canister/impedrezene
	name = "impedrezene canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/impedrezene
	filled = 1

/obj/machinery/portable_atmospherics/canister/nanomachines
	name = "nanomachines canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/nanomachines
	filled = 1

/obj/machinery/portable_atmospherics/canister/xenomicrobes
	name = "xenomicrobes canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/xenomicrobes
	filled = 1

/obj/machinery/portable_atmospherics/canister/fungalspores
	name = "fungalspores canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/fungalspores
	filled = 1

/obj/machinery/portable_atmospherics/canister/snail
	name = "snail canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/snail
	filled = 1

/obj/machinery/portable_atmospherics/canister/fluorosurfactant
	name = "fluorosurfactant canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/fluorosurfactant
	filled = 1

/obj/machinery/portable_atmospherics/canister/foaming_agent
	name = "foaming_agent canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/foaming_agent
	filled = 1

/obj/machinery/portable_atmospherics/canister/smart_foaming_agent
	name = "smart_foaming_agent canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/smart_foaming_agent
	filled = 1

/obj/machinery/portable_atmospherics/canister/ammonia
	name = "ammonia canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/ammonia
	filled = 1

/obj/machinery/portable_atmospherics/canister/diethylamine
	name = "diethylamine canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/diethylamine
	filled = 1

/obj/machinery/portable_atmospherics/canister/carbondioxide
	name = "carbondioxide canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/carbondioxide
	filled = 1

/obj/machinery/portable_atmospherics/canister/powder
	name = "powder canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/powder
	filled = 1

/obj/machinery/portable_atmospherics/canister/red
	name = "red canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/red
	filled = 1

/obj/machinery/portable_atmospherics/canister/orange
	name = "orange canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/orange
	filled = 1

/obj/machinery/portable_atmospherics/canister/yellow
	name = "yellow canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/yellow
	filled = 1

/obj/machinery/portable_atmospherics/canister/blue
	name = "blue canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/blue
	filled = 1

/obj/machinery/portable_atmospherics/canister/purple
	name = "purple canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/purple
	filled = 1

/obj/machinery/portable_atmospherics/canister/invisible
	name = "invisible canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/invisible
	filled = 1

/obj/machinery/portable_atmospherics/canister/black
	name = "black canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/black
	filled = 1

/obj/machinery/portable_atmospherics/canister/white
	name = "white canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/white
	filled = 1

/obj/machinery/portable_atmospherics/canister/plantnutriment
	name = "plantnutriment canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/plantnutriment
	filled = 1

/obj/machinery/portable_atmospherics/canister/eznutriment
	name = "eznutriment canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/eznutriment
	filled = 1

/obj/machinery/portable_atmospherics/canister/left4zednutriment
	name = "left4zednutriment canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/left4zednutriment
	filled = 1

/obj/machinery/portable_atmospherics/canister/robustharvestnutriment
	name = "robustharvestnutriment canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/robustharvestnutriment
	filled = 1

/obj/machinery/portable_atmospherics/canister/oil
	name = "oil canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/oil
	filled = 1

/obj/machinery/portable_atmospherics/canister/stable_plasma
	name = "stable_plasma canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/stable_plasma
	filled = 1

/obj/machinery/portable_atmospherics/canister/iodine
	name = "iodine canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/iodine
	filled = 1

/obj/machinery/portable_atmospherics/canister/carpet
	name = "carpet canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/carpet
	filled = 1

/obj/machinery/portable_atmospherics/canister/bromine
	name = "bromine canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/bromine
	filled = 1

/obj/machinery/portable_atmospherics/canister/phenol
	name = "phenol canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/phenol
	filled = 1

/obj/machinery/portable_atmospherics/canister/acetone
	name = "acetone canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/acetone
	filled = 1

/obj/machinery/portable_atmospherics/canister/colorful_reagent
	name = "colorful_reagent canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/colorful_reagent
	filled = 1

/obj/machinery/portable_atmospherics/canister/hair_dye
	name = "hair_dye canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/hair_dye
	filled = 1

/obj/machinery/portable_atmospherics/canister/barbers_aid
	name = "barbers_aid canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/barbers_aid
	filled = 1

/obj/machinery/portable_atmospherics/canister/concentrated_barbers_aid
	name = "concentrated_barbers_aid canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/concentrated_barbers_aid
	filled = 1

/obj/machinery/portable_atmospherics/canister/saltpetre
	name = "saltpetre canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/saltpetre
	filled = 1

/obj/machinery/portable_atmospherics/canister/lye
	name = "lye canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/lye
	filled = 1

/obj/machinery/portable_atmospherics/canister/drying_agent
	name = "drying_agent canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/drying_agent
	filled = 1

/obj/machinery/portable_atmospherics/canister/mutagenvirusfood
	name = "mutagenvirusfood canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/mutagenvirusfood
	filled = 1

/obj/machinery/portable_atmospherics/canister/synaptizinevirusfood
	name = "synaptizinevirusfood canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/synaptizinevirusfood
	filled = 1

/obj/machinery/portable_atmospherics/canister/plasmavirusfood
	name = "plasmavirusfood canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/plasmavirusfood
	filled = 1

/obj/machinery/portable_atmospherics/canister/weak
	name = "weak canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/weak
	filled = 1

/obj/machinery/portable_atmospherics/canister/uraniumvirusfood
	name = "uraniumvirusfood canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/uraniumvirusfood
	filled = 1

/obj/machinery/portable_atmospherics/canister/stable
	name = "stable canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/stable
	filled = 1

/obj/machinery/portable_atmospherics/canister/laughtervirusfood
	name = "laughtervirusfood canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/laughtervirusfood
	filled = 1

/obj/machinery/portable_atmospherics/canister/advvirusfood
	name = "advvirusfood canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/advvirusfood
	filled = 1

/obj/machinery/portable_atmospherics/canister/viralbase
	name = "viralbase canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/viralbase
	filled = 1

/obj/machinery/portable_atmospherics/canister/royal_bee_jelly
	name = "royal_bee_jelly canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/royal_bee_jelly
	filled = 1

/obj/machinery/portable_atmospherics/canister/romerol
	name = "romerol canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/romerol
	filled = 1

/obj/machinery/portable_atmospherics/canister/magillitis
	name = "magillitis canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/magillitis
	filled = 1

/obj/machinery/portable_atmospherics/canister/growthserum
	name = "growthserum canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/growthserum
	filled = 1

/obj/machinery/portable_atmospherics/canister/plastic_polymers
	name = "plastic_polymers canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/plastic_polymers
	filled = 1

/obj/machinery/portable_atmospherics/canister/glitter
	name = "glitter canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/glitter
	filled = 1

/obj/machinery/portable_atmospherics/canister/pink
	name = "pink canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/pink
	filled = 1

/obj/machinery/portable_atmospherics/canister/pax
	name = "pax canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/pax
	filled = 1

/obj/machinery/portable_atmospherics/canister/bz_metabolites
	name = "bz_metabolites canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/bz_metabolites
	filled = 1

/obj/machinery/portable_atmospherics/canister/concentrated_bz
	name = "concentrated_bz canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/concentrated_bz
	filled = 1

/obj/machinery/portable_atmospherics/canister/fake_cbz
	name = "fake_cbz canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/fake_cbz
	filled = 1

/obj/machinery/portable_atmospherics/canister/peaceborg
	name = "peaceborg canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/peaceborg
	filled = 1

/obj/machinery/portable_atmospherics/canister/confuse
	name = "confuse canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/confuse
	filled = 1

/obj/machinery/portable_atmospherics/canister/inabizine
	name = "inabizine canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/inabizine
	filled = 1

/obj/machinery/portable_atmospherics/canister/tire
	name = "tire canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/tire
	filled = 1

/obj/machinery/portable_atmospherics/canister/tranquility
	name = "tranquility canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/tranquility
	filled = 1

/obj/machinery/portable_atmospherics/canister/liquidadamantine
	name = "liquidadamantine canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/liquidadamantine
	filled = 1

/obj/machinery/portable_atmospherics/canister/spider_extract
	name = "spider_extract canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/spider_extract
	filled = 1

/obj/machinery/portable_atmospherics/canister/ratlight
	name = "ratlight canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/ratlight
	filled = 1

/obj/machinery/portable_atmospherics/canister/invisium
	name = "invisium canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/invisium
	filled = 1

/obj/machinery/portable_atmospherics/canister/thermite
	name = "thermite canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/thermite
	filled = 1

/obj/machinery/portable_atmospherics/canister/nitroglycerin
	name = "nitroglycerin canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/nitroglycerin
	filled = 1

/obj/machinery/portable_atmospherics/canister/stabilizing_agent
	name = "stabilizing_agent canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/stabilizing_agent
	filled = 1

/obj/machinery/portable_atmospherics/canister/clf3
	name = "clf3 canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/clf3
	filled = 1

/obj/machinery/portable_atmospherics/canister/sorium
	name = "sorium canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/sorium
	filled = 1

/obj/machinery/portable_atmospherics/canister/liquid_dark_matter
	name = "liquid_dark_matter canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/liquid_dark_matter
	filled = 1

/obj/machinery/portable_atmospherics/canister/blackpowder
	name = "blackpowder canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/blackpowder
	filled = 1

/obj/machinery/portable_atmospherics/canister/flash_powder
	name = "flash_powder canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/flash_powder
	filled = 1

/obj/machinery/portable_atmospherics/canister/smoke_powder
	name = "smoke_powder canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/smoke_powder
	filled = 1

/obj/machinery/portable_atmospherics/canister/sonic_powder
	name = "sonic_powder canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/sonic_powder
	filled = 1

/obj/machinery/portable_atmospherics/canister/phlogiston
	name = "phlogiston canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/phlogiston
	filled = 1

/obj/machinery/portable_atmospherics/canister/napalm
	name = "napalm canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/napalm
	filled = 1

/obj/machinery/portable_atmospherics/canister/cryostylane
	name = "cryostylane canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/cryostylane
	filled = 1

/obj/machinery/portable_atmospherics/canister/pyrosium
	name = "pyrosium canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/pyrosium
	filled = 1

/obj/machinery/portable_atmospherics/canister/teslium
	name = "teslium canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/teslium
	filled = 1

/obj/machinery/portable_atmospherics/canister/energized_jelly
	name = "energized_jelly canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/energized_jelly
	filled = 1

/obj/machinery/portable_atmospherics/canister/firefighting_foam
	name = "firefighting_foam canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/firefighting_foam
	filled = 1

/obj/machinery/portable_atmospherics/canister/toxin
	name = "toxin canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/toxin
	filled = 1

/obj/machinery/portable_atmospherics/canister/amatoxin
	name = "amatoxin canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/amatoxin
	filled = 1

/obj/machinery/portable_atmospherics/canister/mutagen
	name = "mutagen canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/mutagen
	filled = 1

/obj/machinery/portable_atmospherics/canister/lexorin
	name = "lexorin canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/lexorin
	filled = 1

/obj/machinery/portable_atmospherics/canister/slimejelly
	name = "slimejelly canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/slimejelly
	filled = 1

/obj/machinery/portable_atmospherics/canister/minttoxin
	name = "minttoxin canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/minttoxin
	filled = 1

/obj/machinery/portable_atmospherics/canister/carpotoxin
	name = "carpotoxin canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/carpotoxin
	filled = 1

/obj/machinery/portable_atmospherics/canister/zombiepowder
	name = "zombiepowder canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/zombiepowder
	filled = 1

/obj/machinery/portable_atmospherics/canister/ghoulpowder
	name = "ghoulpowder canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/ghoulpowder
	filled = 1

/obj/machinery/portable_atmospherics/canister/mindbreaker
	name = "mindbreaker canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/mindbreaker
	filled = 1

/obj/machinery/portable_atmospherics/canister/plantbgone
	name = "plantbgone canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/plantbgone
	filled = 1

/obj/machinery/portable_atmospherics/canister/weedkiller
	name = "weedkiller canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/weedkiller
	filled = 1

/obj/machinery/portable_atmospherics/canister/pestkiller
	name = "pestkiller canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/pestkiller
	filled = 1

/obj/machinery/portable_atmospherics/canister/spore
	name = "spore canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/spore
	filled = 1

/obj/machinery/portable_atmospherics/canister/spore_burning
	name = "spore_burning canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/spore_burning
	filled = 1

/obj/machinery/portable_atmospherics/canister/chloralhydrate
	name = "chloralhydrate canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/chloralhydrate
	filled = 1

/obj/machinery/portable_atmospherics/canister/fakebeer
	name = "fakebeer canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/fakebeer
	filled = 1

/obj/machinery/portable_atmospherics/canister/coffeepowder
	name = "coffeepowder canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/coffeepowder
	filled = 1

/obj/machinery/portable_atmospherics/canister/teapowder
	name = "teapowder canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/teapowder
	filled = 1

/obj/machinery/portable_atmospherics/canister/mutetoxin
	name = "mutetoxin canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/mutetoxin
	filled = 1

/obj/machinery/portable_atmospherics/canister/staminatoxin
	name = "staminatoxin canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/staminatoxin
	filled = 1

/obj/machinery/portable_atmospherics/canister/polonium
	name = "polonium canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/polonium
	filled = 1

/obj/machinery/portable_atmospherics/canister/histamine
	name = "histamine canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/histamine
	filled = 1

/obj/machinery/portable_atmospherics/canister/formaldehyde
	name = "formaldehyde canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/formaldehyde
	filled = 1

/obj/machinery/portable_atmospherics/canister/venom
	name = "venom canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/venom
	filled = 1

/obj/machinery/portable_atmospherics/canister/fentanyl
	name = "fentanyl canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/fentanyl
	filled = 1

/obj/machinery/portable_atmospherics/canister/cyanide
	name = "cyanide canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/cyanide
	filled = 1

/obj/machinery/portable_atmospherics/canister/bad_food
	name = "bad_food canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/bad_food
	filled = 1

/obj/machinery/portable_atmospherics/canister/itching_powder
	name = "itching_powder canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/itching_powder
	filled = 1

/obj/machinery/portable_atmospherics/canister/initropidril
	name = "initropidril canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/initropidril
	filled = 1

/obj/machinery/portable_atmospherics/canister/pancuronium
	name = "pancuronium canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/pancuronium
	filled = 1

/obj/machinery/portable_atmospherics/canister/sodium_thiopental
	name = "sodium_thiopental canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/sodium_thiopental
	filled = 1

/obj/machinery/portable_atmospherics/canister/sulfonal
	name = "sulfonal canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/sulfonal
	filled = 1

/obj/machinery/portable_atmospherics/canister/amanitin
	name = "amanitin canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/amanitin
	filled = 1

/obj/machinery/portable_atmospherics/canister/lipolicide
	name = "lipolicide canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/lipolicide
	filled = 1

/obj/machinery/portable_atmospherics/canister/coniine
	name = "coniine canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/coniine
	filled = 1

/obj/machinery/portable_atmospherics/canister/spewium
	name = "spewium canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/spewium
	filled = 1

/obj/machinery/portable_atmospherics/canister/curare
	name = "curare canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/curare
	filled = 1

/obj/machinery/portable_atmospherics/canister/heparin
	name = "heparin canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/heparin
	filled = 1

/obj/machinery/portable_atmospherics/canister/rotatium
	name = "rotatium canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/rotatium
	filled = 1

/obj/machinery/portable_atmospherics/canister/skewium
	name = "skewium canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/skewium
	filled = 1

/obj/machinery/portable_atmospherics/canister/anacea
	name = "anacea canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/anacea
	filled = 1

/obj/machinery/portable_atmospherics/canister/acid
	name = "acid canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/acid
	filled = 1

/obj/machinery/portable_atmospherics/canister/fluacid
	name = "fluacid canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/fluacid
	filled = 1

/obj/machinery/portable_atmospherics/canister/delayed
	name = "delayed canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/delayed
	filled = 1

/obj/machinery/portable_atmospherics/canister/mimesbane
	name = "mimesbane canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/mimesbane
	filled = 1

/obj/machinery/portable_atmospherics/canister/bonehurtingjuice
	name = "bonehurtingjuice canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/bonehurtingjuice
	filled = 1

/obj/machinery/portable_atmospherics/canister/bungotoxin
	name = "bungotoxin canister"
	desc = "Miasma. Makes you wish your nose were blocked."
	icon_state = "miasma"
	gas_type = /datum/gas/bungotoxin
	filled = 1


// END

/obj/machinery/portable_atmospherics/canister/proc/get_time_left()
	if(timing)
		. = round(max(0, valve_timer - world.time) / 10, 1)
	else
		. = timer_set

/obj/machinery/portable_atmospherics/canister/proc/set_active()
	timing = !timing
	if(timing)
		valve_timer = world.time + (timer_set * 10)
	update_icon()

/obj/machinery/portable_atmospherics/canister/proto
	name = "prototype canister"


/obj/machinery/portable_atmospherics/canister/proto/default
	name = "prototype canister"
	desc = "The best way to fix an atmospheric emergency... or the best way to introduce one."
	icon_state = "proto"
	volume = 5000
	max_integrity = 300
	temperature_resistance = 2000 + T0C
	can_max_release_pressure = (ONE_ATMOSPHERE * 30)
	can_min_release_pressure = (ONE_ATMOSPHERE / 30)
	prototype = TRUE


/obj/machinery/portable_atmospherics/canister/proto/default/oxygen
	name = "prototype canister"
	desc = "A prototype canister for a prototype bike, what could go wrong?"
	icon_state = "proto"
	gas_type = /datum/gas/oxygen
	filled = 1
	release_pressure = ONE_ATMOSPHERE*2

/obj/machinery/portable_atmospherics/canister/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION(VV_HK_MODIFY_CANISTER_GAS, "Modify Canister Gas")

/obj/machinery/portable_atmospherics/canister/vv_do_topic(href_list)
	. = ..()
	if(href_list[VV_HK_MODIFY_CANISTER_GAS])
		usr.client.modify_canister_gas(src)

/obj/machinery/portable_atmospherics/canister/New(loc, datum/gas_mixture/existing_mixture)
	. = ..()
	if(existing_mixture)
		air_contents.copy_from(existing_mixture)
	else
		create_gas()
	pump = new(src, FALSE)
	pump.on = TRUE
	pump.stat = 0
	pump.build_network()

	update_icon()

/obj/machinery/portable_atmospherics/canister/Destroy()
	qdel(pump)
	pump = null
	return ..()

/obj/machinery/portable_atmospherics/canister/proc/create_gas()
	if(gas_type)
		if(starter_temp)
			air_contents.set_temperature(starter_temp)
		air_contents.set_moles(gas_type, (maximum_pressure * filled) * air_contents.return_volume() / (R_IDEAL_GAS_EQUATION * air_contents.return_temperature()))

/obj/machinery/portable_atmospherics/canister/air/create_gas()
	if(starter_temp)
		air_contents.set_temperature(starter_temp)
	air_contents.set_moles(/datum/gas/oxygen, (O2STANDARD * maximum_pressure * filled) * air_contents.return_volume() / (R_IDEAL_GAS_EQUATION * air_contents.return_temperature()))
	air_contents.set_moles(/datum/gas/nitrogen, (N2STANDARD * maximum_pressure * filled) * air_contents.return_volume() / (R_IDEAL_GAS_EQUATION * air_contents.return_temperature()))

#define CANISTER_UPDATE_HOLDING		(1<<0)
#define CANISTER_UPDATE_CONNECTED	(1<<1)
#define CANISTER_UPDATE_EMPTY		(1<<2)
#define CANISTER_UPDATE_LOW			(1<<3)
#define CANISTER_UPDATE_MEDIUM		(1<<4)
#define CANISTER_UPDATE_FULL		(1<<5)
#define CANISTER_UPDATE_DANGER		(1<<6)
/obj/machinery/portable_atmospherics/canister/update_icon()
	if(stat & BROKEN)
		cut_overlays()
		icon_state = "[icon_state]-1"
		return

	var/last_update = update
	update = 0

	if(holding)
		update |= CANISTER_UPDATE_HOLDING
	if(connected_port)
		update |= CANISTER_UPDATE_CONNECTED
	var/pressure = air_contents.return_pressure()
	if(pressure < 10)
		update |= CANISTER_UPDATE_EMPTY
	else if(pressure < 5 * ONE_ATMOSPHERE)
		update |= CANISTER_UPDATE_LOW
	else if(pressure < 10 * ONE_ATMOSPHERE)
		update |= CANISTER_UPDATE_MEDIUM
	else if(pressure < 40 * ONE_ATMOSPHERE)
		update |= CANISTER_UPDATE_FULL
	else
		update |= CANISTER_UPDATE_DANGER

	if(update == last_update)
		return

	cut_overlays()
	if(update & CANISTER_UPDATE_HOLDING)
		add_overlay("can-open")
	if(update & CANISTER_UPDATE_CONNECTED)
		add_overlay("can-connector")
	if(update & CANISTER_UPDATE_LOW)
		add_overlay("can-o0")
	else if(update & CANISTER_UPDATE_MEDIUM)
		add_overlay("can-o1")
	else if(update & CANISTER_UPDATE_FULL)
		add_overlay("can-o2")
	else if(update & CANISTER_UPDATE_DANGER)
		add_overlay("can-o3")
#undef CANISTER_UPDATE_HOLDING
#undef CANISTER_UPDATE_CONNECTED
#undef CANISTER_UPDATE_EMPTY
#undef CANISTER_UPDATE_LOW
#undef CANISTER_UPDATE_MEDIUM
#undef CANISTER_UPDATE_FULL
#undef CANISTER_UPDATE_DANGER

/obj/machinery/portable_atmospherics/canister/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > temperature_resistance)
		take_damage(5, BURN, 0)


/obj/machinery/portable_atmospherics/canister/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(!(stat & BROKEN))
			canister_break()
		if(disassembled)
			new /obj/item/stack/sheet/iron (loc, 10)
		else
			new /obj/item/stack/sheet/iron (loc, 5)
	qdel(src)

/obj/machinery/portable_atmospherics/canister/welder_act(mob/living/user, obj/item/I)
	if(user.a_intent == INTENT_HARM)
		return FALSE

	if(stat & BROKEN)
		if(!I.tool_start_check(user, amount=0))
			return TRUE
		to_chat(user, "<span class='notice'>You begin cutting [src] apart...</span>")
		if(I.use_tool(src, user, 30, volume=50))
			deconstruct(TRUE)
	else
		to_chat(user, "<span class='notice'>You cannot slice [src] apart when it isn't broken.</span>")

	return TRUE

/obj/machinery/portable_atmospherics/canister/obj_break(damage_flag)
	if((stat & BROKEN) || (flags_1 & NODECONSTRUCT_1))
		return
	canister_break()

/obj/machinery/portable_atmospherics/canister/proc/canister_break()
	disconnect()
	var/datum/gas_mixture/expelled_gas = air_contents.remove(air_contents.total_moles())
	var/turf/T = get_turf(src)
	T.assume_air(expelled_gas)
	air_update_turf()

	stat |= BROKEN
	density = FALSE
	playsound(src.loc, 'sound/effects/spray.ogg', 10, 1, -3)
	update_icon()
	investigate_log("was destroyed.", INVESTIGATE_ATMOS)

	if(holding)
		holding.forceMove(T)
		holding = null

/obj/machinery/portable_atmospherics/canister/replace_tank(mob/living/user, close_valve)
	. = ..()
	if(.)
		if(close_valve)
			valve_open = FALSE
			update_icon()
			investigate_log("Valve was <b>closed</b> by [key_name(user)].", INVESTIGATE_ATMOS)
		else if(valve_open && holding)
			investigate_log("[key_name(user)] started a transfer into [holding].", INVESTIGATE_ATMOS)

/obj/machinery/portable_atmospherics/canister/process_atmos()
	..()
	if(stat & BROKEN)
		return PROCESS_KILL
	if(timing && valve_timer < world.time)
		valve_open = !valve_open
		timing = FALSE
	if(valve_open)
		var/turf/T = get_turf(src)
		pump.airs[1] = air_contents
		pump.airs[2] = holding ? holding.air_contents : T.return_air()
		pump.target_pressure = release_pressure

		pump.process_atmos() // Pump gas.
		if(!holding)
			air_update_turf() // Update the environment if needed.
	else
		pump.airs[1] = null
		pump.airs[2] = null

	update_icon()

/obj/machinery/portable_atmospherics/canister/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
															datum/tgui/master_ui = null, datum/ui_state/state = GLOB.physical_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "Canister", name, ui_x, ui_y, master_ui, state)
		ui.open()

/obj/machinery/portable_atmospherics/canister/ui_data()
	var/data = list()
	data["portConnected"] = connected_port ? 1 : 0
	data["tankPressure"] = round(air_contents.return_pressure() ? air_contents.return_pressure() : 0)
	data["releasePressure"] = round(release_pressure ? release_pressure : 0)
	data["defaultReleasePressure"] = round(CAN_DEFAULT_RELEASE_PRESSURE)
	data["minReleasePressure"] = round(can_min_release_pressure)
	data["maxReleasePressure"] = round(can_max_release_pressure)
	data["valveOpen"] = valve_open ? 1 : 0

	data["isPrototype"] = prototype ? 1 : 0
	if (prototype)
		data["restricted"] = restricted
		data["timing"] = timing
		data["time_left"] = get_time_left()
		data["timer_set"] = timer_set
		data["timer_is_not_default"] = timer_set != default_timer_set
		data["timer_is_not_min"] = timer_set != minimum_timer_set
		data["timer_is_not_max"] = timer_set != maximum_timer_set

	data["hasHoldingTank"] = holding ? 1 : 0
	if (holding)
		data["holdingTank"] = list()
		data["holdingTank"]["name"] = holding.name
		data["holdingTank"]["tankPressure"] = round(holding.air_contents.return_pressure())
	return data

/obj/machinery/portable_atmospherics/canister/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("relabel")
			var/label = input("New canister label:", name) as null|anything in sortList(label2types)
			if(label && !..())
				var/newtype = label2types[label]
				if(newtype)
					var/obj/machinery/portable_atmospherics/canister/replacement = newtype
					name = initial(replacement.name)
					desc = initial(replacement.desc)
					icon_state = initial(replacement.icon_state)
		if("restricted")
			restricted = !restricted
			if(restricted)
				req_access = list(ACCESS_ENGINE)
			else
				req_access = list()
				. = TRUE
		if("pressure")
			var/pressure = params["pressure"]
			if(pressure == "reset")
				pressure = CAN_DEFAULT_RELEASE_PRESSURE
				. = TRUE
			else if(pressure == "min")
				pressure = can_min_release_pressure
				. = TRUE
			else if(pressure == "max")
				pressure = can_max_release_pressure
				. = TRUE
			else if(pressure == "input")
				pressure = input("New release pressure ([can_min_release_pressure]-[can_max_release_pressure] kPa):", name, release_pressure) as num|null
				if(!isnull(pressure) && !..())
					. = TRUE
			else if(text2num(pressure) != null)
				pressure = text2num(pressure)
				. = TRUE
			if(.)
				release_pressure = clamp(round(pressure), can_min_release_pressure, can_max_release_pressure)
				investigate_log("was set to [release_pressure] kPa by [key_name(usr)].", INVESTIGATE_ATMOS)
		if("valve")
			var/logmsg
			valve_open = !valve_open
			if(valve_open)
				logmsg = "Valve was <b>opened</b> by [key_name(usr)], starting a transfer into \the [holding || "air"].<br>"
				if(!holding)
					var/list/danger = list()
					for(var/id in air_contents.get_gases())
						if(!GLOB.meta_gas_info[id][META_GAS_DANGER])
							continue
						if(air_contents.get_moles(id) > (GLOB.meta_gas_info[id][META_GAS_MOLES_VISIBLE] || MOLES_GAS_VISIBLE)) //if moles_visible is undefined, default to default visibility
							danger[GLOB.meta_gas_info[id][META_GAS_NAME]] = air_contents.get_moles(id) //ex. "plasma" = 20

					if(danger.len)
						message_admins("[ADMIN_LOOKUPFLW(usr)] opened a canister that contains the following at [ADMIN_VERBOSEJMP(src)]:")
						log_admin("[key_name(usr)] opened a canister that contains the following at [AREACOORD(src)]:")
						for(var/name in danger)
							var/msg = "[name]: [danger[name]] moles."
							log_admin(msg)
							message_admins(msg)
			else
				logmsg = "Valve was <b>closed</b> by [key_name(usr)], stopping the transfer into \the [holding || "air"].<br>"
			investigate_log(logmsg, INVESTIGATE_ATMOS)
			release_log += logmsg
			. = TRUE
		if("timer")
			var/change = params["change"]
			switch(change)
				if("reset")
					timer_set = default_timer_set
				if("decrease")
					timer_set = max(minimum_timer_set, timer_set - 10)
				if("increase")
					timer_set = min(maximum_timer_set, timer_set + 10)
				if("input")
					var/user_input = input(usr, "Set time to valve toggle.", name) as null|num
					if(!user_input)
						return
					var/N = text2num(user_input)
					if(!N)
						return
					timer_set = clamp(N,minimum_timer_set,maximum_timer_set)
					log_admin("[key_name(usr)] has activated a prototype valve timer")
					. = TRUE
				if("toggle_timer")
					set_active()
		if("eject")
			if(holding)
				if(valve_open)
					message_admins("[ADMIN_LOOKUPFLW(usr)] removed [holding] from [src] with valve still open at [ADMIN_VERBOSEJMP(src)] releasing contents into the <span class='boldannounce'>air</span>.")
					investigate_log("[key_name(usr)] removed the [holding], leaving the valve open and transferring into the <span class='boldannounce'>air</span>.", INVESTIGATE_ATMOS)
				replace_tank(usr, FALSE)
				. = TRUE
	update_icon()
