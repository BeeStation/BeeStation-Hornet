/obj/item/vending_refill/wardrobe
	icon_state = "refill_clothes"

/obj/machinery/vending/wardrobe
	default_price = 50
	extra_price = 75
	payment_department = NO_FREEBIES

/obj/machinery/vending/wardrobe/sec_wardrobe
	name = "\improper SecDrobe"
	desc = "A vending machine for security and security-related clothing!"
	icon_state = "secdrobe"
	product_ads = "Beat perps in style!;It's red so you can't see the blood!;You have the right to be fashionable!;Now you can be the fashion police you always wanted to be!"
	vend_reply = "Thank you for using the SecDrobe!"
	light_color = LIGHT_COLOR_RED
	products = list(/obj/item/clothing/suit/hooded/wintercoat/security = 3,
					/obj/item/storage/backpack/security = 3,
					/obj/item/storage/backpack/satchel/sec = 3,
					/obj/item/storage/backpack/duffelbag/sec = 3,
					/obj/item/clothing/under/rank/security/officer = 3,
					/obj/item/clothing/under/plasmaman/security = 3,
					/obj/item/clothing/suit/armor/vest/corporate = 3,
					/obj/item/clothing/under/rank/security/officer/corporate = 3,
					/obj/item/clothing/head/helmet/space/plasmaman/replacement/security = 3,
					/obj/item/clothing/head/beret/corpsec = 3,
					/obj/item/clothing/shoes/jackboots = 3,
					/obj/item/clothing/head/beret/sec = 3,
					/obj/item/clothing/head/soft/sec = 3,
					/obj/item/clothing/mask/bandana/red = 3,
					/obj/item/clothing/mask/gas/sechailer = 6,
					/obj/item/clothing/under/rank/security/officer/skirt = 3,
					/obj/item/clothing/under/rank/security/officer/white = 3,
					/obj/item/clothing/under/pants/khaki = 3,
					/obj/item/clothing/under/rank/security/officer/blueshirt = 3,
					/obj/item/clothing/under/rank/security/officer/mallcop = 3,
					/obj/item/clothing/neck/tie/red = 6,
					/obj/item/clothing/neck/tie/black = 6,)
	premium = list(/obj/item/clothing/under/rank/security/officer/formal = 3,
					/obj/item/clothing/suit/security/officer = 3,
					/obj/item/clothing/head/beret/sec/navyofficer = 3)
	refill_canister = /obj/item/vending_refill/wardrobe/sec_wardrobe
	payment_department = ACCOUNT_SEC

/obj/item/vending_refill/wardrobe/sec_wardrobe
	machine_name = "SecDrobe"

/obj/machinery/vending/wardrobe/medi_wardrobe
	name = "\improper MediDrobe"
	desc = "A vending machine rumoured to be capable of dispensing clothing for medical personnel."
	icon_state = "medidrobe"
	product_ads = "Make those blood stains look fashionable!!"
	vend_reply = "Thank you for using the MediDrobe!"
	light_color = LIGHT_COLOR_WHITE
	products = list(/obj/item/clothing/accessory/pocketprotector = 4,
					/obj/item/storage/backpack/duffelbag/med = 4,
					/obj/item/storage/backpack/medic = 4,
					/obj/item/storage/backpack/satchel/med = 4,
					/obj/item/clothing/suit/hooded/wintercoat/medical = 4,
					/obj/item/clothing/under/rank/medical/doctor/nurse = 4,
					/obj/item/clothing/head/nursehat = 4,
					/obj/item/clothing/under/rank/medical/doctor/blue = 4,
					/obj/item/clothing/under/rank/medical/doctor/green = 4,
					/obj/item/clothing/under/rank/medical/doctor/purple = 4,
					/obj/item/clothing/under/rank/medical/doctor = 4,
					/obj/item/clothing/under/plasmaman/medical = 4,
					/obj/item/clothing/head/helmet/space/plasmaman/replacement/medical = 4,
					/obj/item/clothing/suit/toggle/labcoat = 4,
					/obj/item/clothing/suit/toggle/labcoat/emt = 4,
					/obj/item/clothing/shoes/sneakers/white = 4,
					/obj/item/clothing/head/soft/emt = 4,
					/obj/item/clothing/suit/apron/surgical = 4,
					/obj/item/clothing/mask/surgical = 4)
	refill_canister = /obj/item/vending_refill/wardrobe/medi_wardrobe
	payment_department = ACCOUNT_MED
/obj/item/vending_refill/wardrobe/medi_wardrobe
	machine_name = "MediDrobe"

/obj/machinery/vending/wardrobe/engi_wardrobe
	name = "EngiDrobe"
	desc = "A vending machine renowned for vending industrial grade clothing."
	icon_state = "engidrobe"
	product_ads = "Guaranteed to protect your feet from industrial accidents!;Afraid of radiation? Then wear yellow!"
	vend_reply = "Thank you for using the EngiDrobe!"
	light_color = LIGHT_COLOR_YELLOW
	products = list(/obj/item/clothing/accessory/pocketprotector = 3,
					/obj/item/storage/backpack/duffelbag/engineering = 3,
					/obj/item/storage/backpack/industrial = 3,
					/obj/item/storage/backpack/satchel/eng = 3,
					/obj/item/clothing/under/plasmaman/engineering = 3,
					/obj/item/clothing/head/helmet/space/plasmaman/replacement/engineering = 3,
					/obj/item/clothing/suit/hooded/wintercoat/engineering = 3,
					/obj/item/clothing/under/rank/engineering/engineer = 3,
					/obj/item/clothing/under/rank/engineering/engineer/hazard = 3,
					/obj/item/clothing/suit/hazardvest = 3,
					/obj/item/clothing/shoes/workboots = 3,
					/obj/item/clothing/head/hardhat = 3,
					/obj/item/clothing/head/hardhat/weldhat = 3,
					/obj/item/clothing/head/beret/eng = 3)
	refill_canister = /obj/item/vending_refill/wardrobe/engi_wardrobe
	payment_department = ACCOUNT_ENG
/obj/item/vending_refill/wardrobe/engi_wardrobe
	machine_name = "EngiDrobe"

/obj/machinery/vending/wardrobe/atmos_wardrobe
	name = "AtmosDrobe"
	desc = "This relatively unknown vending machine delivers clothing for Atmospherics Technicians, an equally unknown job."
	icon_state = "atmosdrobe"
	product_ads = "Get your inflammable clothing right here!!!"
	vend_reply = "Thank you for using the AtmosDrobe!"
	light_color = LIGHT_COLOR_YELLOW
	products = list(/obj/item/clothing/accessory/pocketprotector = 2,
					/obj/item/storage/backpack/duffelbag/engineering = 2,
					/obj/item/storage/backpack/satchel/eng = 2,
					/obj/item/storage/backpack/industrial = 2,
					/obj/item/clothing/under/plasmaman/atmospherics = 3,
					/obj/item/clothing/head/helmet/space/plasmaman/replacement/atmospherics = 3,
					/obj/item/clothing/suit/hooded/wintercoat/engineering/atmos = 3,
					/obj/item/clothing/under/rank/engineering/atmospheric_technician = 3,
					/obj/item/clothing/shoes/sneakers/black = 3)
	refill_canister = /obj/item/vending_refill/wardrobe/atmos_wardrobe
	payment_department = ACCOUNT_ENG
/obj/item/vending_refill/wardrobe/atmos_wardrobe
	machine_name = "AtmosDrobe"

/obj/machinery/vending/wardrobe/cargo_wardrobe
	name = "CargoDrobe"
	desc = "A highly advanced vending machine for buying cargo related clothing for free."
	icon_state = "cargodrobe"
	product_ads = "Upgraded Assistant Style! Pick yours today!;These shorts are comfy and easy to wear, get yours now!"
	vend_reply = "Thank you for using the CargoDrobe!"
	light_color = LIGHT_COLOR_YELLOW
	products = list(/obj/item/clothing/suit/hooded/wintercoat/cargo = 3,
					/obj/item/clothing/under/rank/cargo/tech = 3,
					/obj/item/clothing/under/plasmaman/cargo = 3,
					/obj/item/clothing/head/helmet/space/plasmaman/replacement/cargo = 3,
					/obj/item/clothing/shoes/sneakers/black = 3,
					/obj/item/clothing/gloves/fingerless = 3,
					/obj/item/clothing/head/soft = 3,
					/obj/item/radio/headset/headset_cargo = 3)
	premium = list(/obj/item/clothing/under/rank/cargo/miner = 3)
	refill_canister = /obj/item/vending_refill/wardrobe/cargo_wardrobe
	payment_department = ACCOUNT_CAR
/obj/item/vending_refill/wardrobe/cargo_wardrobe
	machine_name = "CargoDrobe"

/obj/machinery/vending/wardrobe/robo_wardrobe
	name = "RoboDrobe"
	desc = "A vending machine designed to dispense clothing known only to roboticists."
	icon_state = "robodrobe"
	product_ads = "You turn me TRUE, use defines!;0110001101101100011011110111010001101000011001010111001101101000011001010111001001100101"
	vend_reply = "Thank you for using the RoboDrobe!"
	light_color = LIGHT_COLOR_WHITE
	products = list(/obj/item/clothing/glasses/hud/diagnostic = 2,
					/obj/item/reagent_containers/medspray/sterilizine = 3,
					/obj/item/clothing/under/rank/rnd/roboticist = 2,
					/obj/item/clothing/under/plasmaman/robotics = 2,
					/obj/item/clothing/head/helmet/space/plasmaman/replacement/robotics = 2,
					/obj/item/clothing/suit/toggle/labcoat = 2,
					/obj/item/clothing/shoes/sneakers/black = 2,
					/obj/item/clothing/gloves/fingerless = 2,
					/obj/item/clothing/head/soft/black = 2,
					/obj/item/clothing/mask/bandana/skull = 2,
					/obj/item/clothing/head/beret/sci = 2)

	contraband = list(/obj/item/clothing/suit/hooded/techpriest = 2,
					/obj/item/organ/tongue/robot = 2)
	refill_canister = /obj/item/vending_refill/wardrobe/robo_wardrobe
	extra_price = 300
	payment_department = ACCOUNT_SCI
/obj/item/vending_refill/wardrobe/robo_wardrobe
	machine_name = "RoboDrobe"

/obj/machinery/vending/wardrobe/science_wardrobe
	name = "SciDrobe"
	desc = "A simple vending machine suitable to dispense well tailored science clothing. Endorsed by Space Cubans."
	icon_state = "scidrobe"
	product_ads = "Longing for the smell of plasma burnt flesh? Buy your science clothing now!;Made with 10% Auxetics, so you don't have to worry about losing your arm!"
	vend_reply = "Thank you for using the SciDrobe!"
	light_color = LIGHT_COLOR_WHITE
	products = list(/obj/item/clothing/accessory/pocketprotector = 3,
					/obj/item/storage/backpack/science = 3,
					/obj/item/storage/backpack/satchel/tox = 3,
					/obj/item/clothing/suit/hooded/wintercoat/science = 3,
					/obj/item/clothing/under/rank/rnd/scientist = 3,
					/obj/item/clothing/under/plasmaman/science = 3,
					/obj/item/clothing/head/helmet/space/plasmaman/replacement/science = 3,
					/obj/item/clothing/suit/toggle/labcoat/science = 3,
					/obj/item/clothing/shoes/sneakers/white = 3,
					/obj/item/radio/headset/headset_sci = 3,
					/obj/item/clothing/mask/gas = 3,
					/obj/item/clothing/head/beret/sci = 3)
	refill_canister = /obj/item/vending_refill/wardrobe/science_wardrobe
	payment_department = ACCOUNT_SCI
/obj/item/vending_refill/wardrobe/science_wardrobe
	machine_name = "SciDrobe"

/obj/machinery/vending/wardrobe/hydro_wardrobe
	name = "Hydrobe"
	desc = "A machine with a catchy name. It dispenses botany related clothing and gear."
	icon_state = "hydrobe"
	product_ads = "Do you love soil? Then buy our clothes!;Get outfits to match your green thumb here!"
	vend_reply = "Thank you for using the Hydrobe!"
	light_color = LIGHT_COLOR_GREEN
	products = list(/obj/item/storage/backpack/botany = 2,
					/obj/item/storage/backpack/satchel/hyd = 2,
					/obj/item/clothing/suit/hooded/wintercoat/hydro = 2,
					/obj/item/clothing/suit/apron = 2,
					/obj/item/clothing/suit/apron/overalls = 3,
					/obj/item/clothing/under/rank/civilian/hydroponics = 3,
					/obj/item/clothing/under/plasmaman/botany = 3,
					/obj/item/clothing/head/helmet/space/plasmaman/replacement/botany = 3,
					/obj/item/clothing/mask/bandana = 3,
					/obj/item/clothing/accessory/armband/hydro = 3)
	refill_canister = /obj/item/vending_refill/wardrobe/hydro_wardrobe
	payment_department = ACCOUNT_SRV
/obj/item/vending_refill/wardrobe/hydro_wardrobe
	machine_name = "HyDrobe"

/obj/machinery/vending/wardrobe/curator_wardrobe
	name = "CuraDrobe"
	desc = "A lowstock vendor only capable of vending clothing for curators and librarians."
	icon_state = "curadrobe"
	product_ads = "Glasses for your eyes and literature for your soul, Curadrobe has it all!; Impress & enthrall your library guests with Curadrobe's extended line of pens!"
	vend_reply = "Thank you for using the CuraDrobe!"
	light_color = LIGHT_COLOR_WHITE
	products = list(/obj/item/pen = 4,
					/obj/item/pen/red = 2,
					/obj/item/pen/blue = 2,
					/obj/item/pen/fourcolor = 1,
					/obj/item/pen/fountain = 2,
					/obj/item/clothing/accessory/pocketprotector = 2,
					/obj/item/storage/backpack/satchel/explorer = 1,
					/obj/item/clothing/glasses/regular = 2,
					/obj/item/clothing/glasses/regular/jamjar = 1,
					/obj/item/storage/bag/books = 1,
					/obj/item/clothing/under/plasmaman/curator = 1,
					/obj/item/clothing/head/helmet/space/plasmaman/replacement/curator = 1)
	refill_canister = /obj/item/vending_refill/wardrobe/curator_wardrobe
	payment_department = ACCOUNT_CIV
/obj/item/vending_refill/wardrobe/curator_wardrobe
	machine_name = "CuraDrobe"

/obj/machinery/vending/wardrobe/bar_wardrobe
	name = "BarDrobe"
	desc = "A stylish vendor to dispense the most stylish bar clothing!"
	icon_state = "bardrobe"
	product_ads = "Guaranteed to prevent stains from spilled drinks!"
	vend_reply = "Thank you for using the BarDrobe!"
	light_color = LIGHT_COLOR_WHITE
	products = list(/obj/item/clothing/head/that = 2,
					/obj/item/radio/headset/headset_srv = 2,
					/obj/item/clothing/under/suit/sl = 2,
					/obj/item/clothing/under/rank/civilian/bartender = 2,
					/obj/item/clothing/under/rank/civilian/bartender/purple = 2,
					/obj/item/clothing/under/plasmaman/enviroslacks = 2,
					/obj/item/clothing/head/helmet/space/plasmaman/replacement/white = 2,
					/obj/item/clothing/accessory/waistcoat = 2,
					/obj/item/clothing/suit/apron/purple_bartender = 2,
					/obj/item/clothing/head/soft/black = 2,
					/obj/item/clothing/shoes/sneakers/black = 2,
					/obj/item/reagent_containers/glass/rag = 2,
					/obj/item/storage/box/beanbag = 1,
					/obj/item/clothing/suit/armor/vest/alt = 1,
					/obj/item/circuitboard/machine/dish_drive = 1,
					/obj/item/clothing/glasses/sunglasses/advanced/reagent = 1,
					/obj/item/clothing/neck/petcollar = 1,
					/obj/item/storage/belt/bandolier = 1,
					/obj/item/clothing/neck/tie/black = 2,
					/obj/item/clothing/neck/tie/blue = 2)
	premium = list(/obj/item/storage/box/dishdrive = 1)
	refill_canister = /obj/item/vending_refill/wardrobe/bar_wardrobe
	payment_department = ACCOUNT_SRV
/obj/item/vending_refill/wardrobe/bar_wardrobe
	machine_name = "BarDrobe"

/obj/machinery/vending/wardrobe/chef_wardrobe
	name = "ChefDrobe"
	desc = "This vending machine might not dispense meat, but it certainly dispenses chef related clothing."
	icon_state = "chefdrobe"
	product_ads = "Our clothes are guaranteed to protect you from food splatters!"
	vend_reply = "Thank you for using the ChefDrobe!"
	products = list(/obj/item/clothing/under/suit/waiter = 2,
					/obj/item/radio/headset/headset_srv = 2,
					/obj/item/clothing/accessory/waistcoat = 2,
					/obj/item/clothing/suit/apron/chef = 3,
					/obj/item/clothing/head/soft/mime = 2,
					/obj/item/storage/box/mousetraps = 2,
					/obj/item/circuitboard/machine/dish_drive = 1,
					/obj/item/clothing/suit/toggle/chef = 1,
					/obj/item/clothing/under/plasmaman/chef = 1,
					/obj/item/clothing/head/helmet/space/plasmaman/replacement/white = 1,
					/obj/item/clothing/under/rank/civilian/chef = 1,
					/obj/item/clothing/under/rank/civilian/altchef = 1,
					/obj/item/clothing/head/chefhat = 3,
					/obj/item/reagent_containers/glass/rag = 1,
					/obj/item/clothing/suit/hooded/wintercoat = 2)
	refill_canister = /obj/item/vending_refill/wardrobe/chef_wardrobe
	payment_department = ACCOUNT_SRV
/obj/item/vending_refill/wardrobe/chef_wardrobe
	machine_name = "ChefDrobe"

/obj/machinery/vending/wardrobe/jani_wardrobe
	name = "JaniDrobe"
	desc = "A self cleaning vending machine capable of dispensing clothing for janitors."
	icon_state = "janidrobe"
	product_ads = "Come and get your janitorial clothing, now endorsed by lizard janitors everywhere!"
	vend_reply = "Thank you for using the JaniDrobe!"
	products = list(/obj/item/clothing/under/rank/civilian/janitor = 2,
					/obj/item/clothing/under/plasmaman/janitor = 2,
					/obj/item/clothing/head/helmet/space/plasmaman/replacement/janitor = 2,
					/obj/item/cartridge/janitor = 2,
					/obj/item/clothing/gloves/color/black = 2,
					/obj/item/clothing/head/soft/purple = 2,
					/obj/item/twohanded/pushbroom = 2,
					/obj/item/paint/paint_remover = 2,
					/obj/item/melee/flyswatter = 2,
					/obj/item/flashlight = 2,
					/obj/item/clothing/suit/caution = 6,
					/obj/item/holosign_creator/janibarrier = 2,
					/obj/item/lightreplacer = 2,
					/obj/item/soap/nanotrasen = 2,
					/obj/item/storage/bag/trash = 2,
					/obj/item/clothing/shoes/galoshes = 2,
					/obj/item/watertank/janitor = 1,
					/obj/item/storage/belt/janitor = 2)
	refill_canister = /obj/item/vending_refill/wardrobe/jani_wardrobe
	payment_department = ACCOUNT_SRV
/obj/item/vending_refill/wardrobe/jani_wardrobe
	machine_name = "JaniDrobe"

/obj/machinery/vending/wardrobe/law_wardrobe
	name = "LawDrobe"
	desc = "Objection! This wardrobe dispenses the rule of law... and lawyer clothing."
	icon_state = "lawdrobe"
	product_ads = "OBJECTION! Get the rule of law for yourself!"
	vend_reply = "Thank you for using the LawDrobe!"
	products = list(/obj/item/clothing/under/rank/civilian/lawyer/bluesuit = 1,
					/obj/item/clothing/suit/toggle/lawyer = 1,
					/obj/item/clothing/under/rank/civilian/lawyer/purpsuit = 1,
					/obj/item/clothing/suit/toggle/lawyer/purple = 1,
					/obj/item/clothing/under/suit/black = 1,
					/obj/item/clothing/suit/toggle/lawyer/black = 1,
					/obj/item/clothing/under/rank/civilian/lawyer/female = 1,
					/obj/item/clothing/under/suit/black_really = 1,
					/obj/item/clothing/under/rank/civilian/lawyer/blue = 1,
					/obj/item/clothing/under/rank/civilian/lawyer/red = 1,
					/obj/item/clothing/under/rank/civilian/lawyer/black = 1,
					/obj/item/clothing/shoes/laceup = 2,
					/obj/item/clothing/neck/tie/red = 6,
					/obj/item/clothing/neck/tie/black = 6,
					/obj/item/clothing/accessory/lawyers_badge = 2)
	refill_canister = /obj/item/vending_refill/wardrobe/law_wardrobe
	payment_department = ACCOUNT_CIV
/obj/item/vending_refill/wardrobe/law_wardrobe
	machine_name = "LawDrobe"

/obj/machinery/vending/wardrobe/chap_wardrobe
	name = "ChapDrobe"
	desc = "This most blessed and holy machine vends clothing only suitable for chaplains to gaze upon."
	icon_state = "chapdrobe"
	product_ads = "Are you being bothered by cultists or pesky revenants? Then come and dress like the holy man!;Clothes for men of the cloth!"
	vend_reply = "Thank you for using the ChapDrobe!"
	light_color = LIGHT_COLOR_WHITE
	products = list(/obj/item/choice_beacon/holy = 1,
					/obj/item/storage/backpack/cultpack = 1,
					/obj/item/clothing/accessory/pocketprotector/cosmetology = 1,
					/obj/item/clothing/under/rank/civilian/chaplain = 1,
					/obj/item/clothing/under/plasmaman/chaplain = 1,
					/obj/item/clothing/head/helmet/space/plasmaman/replacement/chaplain = 1,
					/obj/item/clothing/shoes/sneakers/black = 1,
					/obj/item/clothing/suit/chaplainsuit/nun = 1,
					/obj/item/clothing/head/nun_hood = 1,
					/obj/item/clothing/suit/chaplainsuit/holidaypriest = 1,
					/obj/item/storage/fancy/candle_box = 2,
					/obj/item/clothing/head/kippah = 3,
					/obj/item/clothing/suit/chaplainsuit/whiterobe = 1,
					/obj/item/clothing/head/taqiyahwhite = 1,
					/obj/item/clothing/head/taqiyahred = 3,
					/obj/item/clothing/head/beanie/rasta = 1)
	contraband = list(/obj/item/toy/plush/plushvar = 1,
					/obj/item/toy/plush/narplush = 1,
					/obj/item/clothing/head/medievaljewhat = 3,
					/obj/item/clothing/suit/chaplainsuit/clownpriest = 1,
					/obj/item/clothing/head/clownmitre = 1)
	premium = list(/obj/item/clothing/suit/chaplainsuit/bishoprobe = 1,
					/obj/item/clothing/head/bishopmitre = 1)
	refill_canister = /obj/item/vending_refill/wardrobe/chap_wardrobe
	payment_department = ACCOUNT_CIV
/obj/item/vending_refill/wardrobe/chap_wardrobe
	machine_name = "ChapDrobe"

/obj/machinery/vending/wardrobe/chem_wardrobe
	name = "ChemDrobe"
	desc = "A vending machine for dispensing chemistry related clothing."
	icon_state = "chemdrobe"
	product_ads = "Our clothes are 0.5% more resistant to acid spills! Get yours now!"
	vend_reply = "Thank you for using the ChemDrobe!"
	products = list(/obj/item/clothing/under/rank/medical/chemist = 2,
					/obj/item/clothing/under/plasmaman/chemist = 2,
					/obj/item/clothing/head/helmet/space/plasmaman/replacement/chemist = 2,
					/obj/item/clothing/shoes/sneakers/white = 2,
					/obj/item/clothing/suit/toggle/labcoat/chemist = 2,
					/obj/item/storage/backpack/chemistry = 2,
					/obj/item/storage/backpack/satchel/chem = 2,
					/obj/item/storage/bag/chemistry = 2,
					/obj/item/clothing/head/beret/med = 2)
	refill_canister = /obj/item/vending_refill/wardrobe/chem_wardrobe
	payment_department = ACCOUNT_MED
/obj/item/vending_refill/wardrobe/chem_wardrobe
	machine_name = "ChemDrobe"

/obj/machinery/vending/wardrobe/gene_wardrobe
	name = "GeneDrobe"
	desc = "A machine for dispensing clothing related to genetics."
	icon_state = "genedrobe"
	product_ads = "Perfect for the mad scientist in you!"
	vend_reply = "Thank you for using the GeneDrobe!"
	products = list(/obj/item/clothing/under/rank/medical/geneticist = 2,
					/obj/item/clothing/under/plasmaman/genetics = 2,
					/obj/item/clothing/head/helmet/space/plasmaman/replacement/genetics = 2,
					/obj/item/clothing/shoes/sneakers/white = 2,
					/obj/item/clothing/suit/toggle/labcoat/genetics = 2,
					/obj/item/storage/backpack/genetics = 2,
					/obj/item/storage/backpack/satchel/gen = 2)
	refill_canister = /obj/item/vending_refill/wardrobe/gene_wardrobe
	payment_department = ACCOUNT_MED
/obj/item/vending_refill/wardrobe/gene_wardrobe
	machine_name = "GeneDrobe"

/obj/machinery/vending/wardrobe/viro_wardrobe
	name = "ViroDrobe"
	desc = "An unsterilized machine for dispending virology related clothing."
	icon_state = "virodrobe"
	product_ads = " Viruses getting you down? Then upgrade to sterilized clothing today!"
	vend_reply = "Thank you for using the ViroDrobe"
	products = list(/obj/item/clothing/under/rank/medical/virologist = 2,
					/obj/item/clothing/under/plasmaman/viro = 2,
					/obj/item/clothing/head/helmet/space/plasmaman/replacement/viro = 2,
					/obj/item/clothing/shoes/sneakers/white = 2,
					/obj/item/clothing/suit/toggle/labcoat/virologist = 2,
					/obj/item/clothing/mask/surgical = 2,
					/obj/item/storage/backpack/virology = 2,
					/obj/item/storage/backpack/satchel/vir = 2)
	contraband = list(/obj/item/clothing/suit/bio_suit/plaguedoctorsuit = 1,
					/obj/item/clothing/head/plaguedoctorhat = 1,
					/obj/item/clothing/mask/gas/plaguedoctor = 1)
	refill_canister = /obj/item/vending_refill/wardrobe/viro_wardrobe
	payment_department = ACCOUNT_MED
/obj/item/vending_refill/wardrobe/viro_wardrobe
	machine_name = "ViroDrobe"
