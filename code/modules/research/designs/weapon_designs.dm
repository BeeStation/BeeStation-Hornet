/////////////////////////////////////////
/////////////////Weapons/////////////////
/////////////////////////////////////////

/datum/design/c38/sec
	id = "sec_38"
	build_type = PROTOLATHE
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/c38b/sec
	id = "sec_38b"
	build_type = PROTOLATHE
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/c38_trac
	name = "Speed Loader (.38 TRAC)"
	desc = "Designed to quickly reload revolvers. TRAC bullets embed a tracking implant within the target's body."
	id = "c38_trac"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 20000, /datum/material/silver = 5000, /datum/material/gold = 1000)
	build_path = /obj/item/ammo_box/c38/trac
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/c38_hotshot
	name = "Speed Loader (.38 Hot Shot)"
	desc = "Designed to quickly reload revolvers. Hot Shot bullets contain an incendiary payload."
	id = "c38_hotshot"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 20000, /datum/material/plasma = 5000)
	build_path = /obj/item/ammo_box/c38/hotshot
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/c38_iceblox
	name = "Speed Loader (.38 Iceblox)"
	desc = "Designed to quickly reload revolvers. Iceblox bullets contain a cryogenic payload."
	id = "c38_iceblox"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 20000, /datum/material/plasma = 5000)
	build_path = /obj/item/ammo_box/c38/iceblox
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/rubbershot/sec
	id = "sec_rshot"
	build_type = PROTOLATHE
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/beanbag_slug/sec
	id = "sec_beanbag_slug"
	build_type = PROTOLATHE
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/shotgun_slug/sec
	id = "sec_slug"
	build_type = PROTOLATHE
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/buckshot_shell/sec
	id = "sec_bshot"
	build_type = PROTOLATHE
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/shotgun_dart/sec
	id = "sec_dart"
	build_type = PROTOLATHE
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/incendiary_slug/sec
	id = "sec_Islug"
	build_type = PROTOLATHE
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/breaching_slug/sec
	name = "Breaching Slug"
	desc = "A 12 gauge anti-material slug. Great for breaching airlocks and windows with minimal shots."
	id = "sec_Brslug"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000)
	build_path = /obj/item/ammo_casing/shotgun/breacher
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/pin_testing
	name = "Test-Range Firing Pin"
	desc = "This safety firing pin allows firearms to be operated within proximity to a firing range."
	id = "pin_testing"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 300)
	build_path = /obj/item/firing_pin/test_range
	category = list("Firing Pins")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/pin_mindshield
	name = "Mindshield Firing Pin"
	desc = "This is a security firing pin which only authorizes users who are mindshield-implanted."
	id = "pin_loyalty"
	build_type = PROTOLATHE
	materials = list(/datum/material/silver = 600, /datum/material/diamond = 600, /datum/material/uranium = 200)
	build_path = /obj/item/firing_pin/implant/mindshield
	category = list("Firing Pins")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/stunmine/sec/
	name = "Stun Mine"
	desc = "A basic nonlethal stunning mine. Does very heavy stamina damage to anyone who walks over it."
	id = "stunmine"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 1000, /datum/material/copper = 400)
	build_path = /obj/item/deployablemine/stun
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/adv_stunmine/sec
	name = "Smart Stun Mine"
	desc = "A advanced nonlethal stunning mine. Uses advanced detection software to only trigger when activated by someone without a mindshield implant."
	id = "stunmine_adv"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 8000, /datum/material/glass = 3000, /datum/material/copper = 1000, /datum/material/silver = 200)
	build_path = /obj/item/deployablemine/smartstun
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/lm6_stunmine/sec
	name = "Rapid Deployment Smartmine"
	desc = "A advanced nonlethal stunning mine. Uses advanced detection software to only trigger when activated by someone without a mindshield implant. Can be rapidly placed and disarmed."
	id = "stunmine_rapid"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 4000, /datum/material/copper = 1000, /datum/material/silver = 500, /datum/material/uranium = 200)
	build_path = /obj/item/deployablemine/rapid
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/lm12_stunmine/sec
	name = "Sledgehammer Smartmine"
	desc = "A advanced nonlethal stunning mine. Uses advanced detection software to only trigger when activated by someone without a mindshield implant. Very powerful and hard to disarm."
	id = "stunmine_heavy"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 4000, /datum/material/copper = 1000, /datum/material/silver = 500, /datum/material/uranium = 200)
	build_path = /obj/item/deployablemine/heavy
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/honkmine
	name = "Honkblaster 1000"
	desc = "An advanced pressure activated pranking mine, honk!"
	id = "clown_mine"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 1000, /datum/material/bananium = 500)
	build_path = /obj/item/deployablemine/honk
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/stunrevolver
	name = "Tesla Revolver"
	desc = "A high-tech revolver that fires internal, reusable shock cartridges in a revolving cylinder. The cartridges can be recharged using conventional rechargers."
	id = "stunrevolver"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 10000, /datum/material/silver = 10000)
	build_path = /obj/item/gun/energy/tesla_revolver
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/nuclear_gun
	name = "Advanced Energy Gun"
	desc = "An energy gun with an experimental miniaturized reactor."
	id = "nuclear_gun"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 2000, /datum/material/uranium = 3000, /datum/material/titanium = 1000)
	build_path = /obj/item/gun/energy/e_gun/nuclear
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/tele_shield
	name = "Telescopic Riot Shield"
	desc = "An advanced riot shield made of lightweight materials that collapses for easy storage."
	id = "tele_shield"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 4000, /datum/material/silver = 300, /datum/material/titanium = 200)
	build_path = /obj/item/shield/riot/tele
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/beamrifle
	name = "Beam Marksman Rifle"
	desc = "A powerful long ranged anti-material rifle that fires charged particle beams to obliterate targets."
	id = "beamrifle"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 5000, /datum/material/diamond = 5000, /datum/material/uranium = 8000, /datum/material/silver = 4500, /datum/material/gold = 5000)
	build_path = /obj/item/gun/energy/beam_rifle
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/decloner
	name = "Decloner"
	desc = "Your opponent will bubble into a messy pile of goop."
	id = "decloner"
	build_type = PROTOLATHE
	materials = list(/datum/material/gold = 5000,/datum/material/uranium = 10000)
	reagents_list = list(/datum/reagent/toxin/mutagen = 40)
	build_path = /obj/item/gun/energy/decloner
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/rapidsyringe
	name = "Rapid Syringe Gun"
	desc = "A gun that fires many syringes."
	id = "rapidsyringe"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 1000)
	build_path = /obj/item/gun/syringe/rapidsyringe
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL		//uwu

/datum/design/temp_gun
	name = "Temperature Gun"
	desc = "A gun that shoots temperature bullet energythings to change temperature."//Change it if you want
	id = "temp_gun"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 500, /datum/material/silver = 3000)
	build_path = /obj/item/gun/energy/temperature
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/flora_gun
	name = "Floral Somatoray"
	desc = "A tool that discharges controlled radiation which induces mutation in plant cells. Harmless to other organic life."
	id = "flora_gun"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 500)
	reagents_list = list(/datum/reagent/uranium/radium = 20)
	build_path = /obj/item/gun/energy/floragun
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/large_grenade
	name = "Large Grenade"
	desc = "A grenade that affects a larger area and use larger containers."
	id = "large_Grenade"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 3000)
	build_path = /obj/item/grenade/chem_grenade/large
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/pyro_grenade
	name = "Pyro Grenade"
	desc = "An advanced grenade that is able to self ignite its mixture."
	id = "pyro_Grenade"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/plasma = 500)
	build_path = /obj/item/grenade/chem_grenade/pyro
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cryo_grenade
	name = "Cryo Grenade"
	desc = "An advanced grenade that rapidly cools its contents upon detonation."
	id = "cryo_Grenade"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/silver = 500)
	build_path = /obj/item/grenade/chem_grenade/cryo
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/adv_grenade
	name = "Advanced Release Grenade"
	desc = "An advanced grenade that can be detonated several times, best used with a repeating igniter."
	id = "adv_Grenade"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 500)
	build_path = /obj/item/grenade/chem_grenade/adv_release
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/xray
	name = "X-ray Laser Gun"
	desc = "Not quite as menacing as it sounds"
	id = "xray_laser"
	build_type = PROTOLATHE
	materials = list(/datum/material/gold = 5000, /datum/material/uranium = 4000, /datum/material/iron = 5000, /datum/material/titanium = 2000, /datum/material/bluespace = 2000)
	build_path = /obj/item/gun/energy/xray
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/ioncarbine
	name = "Ion Carbine"
	desc = "How to dismantle a cyborg : The gun."
	id = "ioncarbine"
	build_type = PROTOLATHE
	materials = list(/datum/material/silver = 6000, /datum/material/iron = 8000, /datum/material/uranium = 2000)
	build_path = /obj/item/gun/energy/ionrifle/carbine
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/wormhole_projector
	name = "Bluespace Wormhole Projector"
	desc = "A projector that emits high density quantum-coupled bluespace beams."
	id = "wormholeprojector"
	build_type = PROTOLATHE
	materials = list(/datum/material/silver = 2000, /datum/material/iron = 5000, /datum/material/diamond = 2000, /datum/material/bluespace = 3000)
	build_path = /obj/item/gun/energy/wormhole_projector
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

//WT550 Mags

/datum/design/mag_oldsmg
	name = "WT-550 Auto Gun Magazine (4.6x30mm)"
	desc = "A 20 round magazine for the out of date security WT-550 Auto Rifle"
	id = "mag_oldsmg"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000)
	build_path = /obj/item/ammo_box/magazine/wt550m9
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/mag_oldsmg/rubber
	name = "WT-550 Rubber Auto Gun Magazine (4.6x30mm Rubber)"
	desc = "A 20 round magazine for the out of date security WT-550 Auto Rifle"
	id = "mag_oldsmg_rubber"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 3000)
	build_path = /obj/item/ammo_box/magazine/wt550m9/rubber
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/mag_oldsmg/ap_mag
	name = "WT-550 Auto Gun Armour Piercing Magazine (4.6x30mm AP)"
	desc = "A 20 round armour piercing magazine for the out of date security WT-550 Auto Rifle"
	id = "mag_oldsmg_ap"
	materials = list(/datum/material/iron = 6000, /datum/material/silver = 600)
	build_path = /obj/item/ammo_box/magazine/wt550m9/wtap
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/mag_oldsmg/ic_mag
	name = "WT-550 Auto Gun Incendiary Magazine (4.6x30mm IC)"
	desc = "A 20 round armour piercing magazine for the out of date security WT-550 Auto Rifle"
	id = "mag_oldsmg_ic"
	materials = list(/datum/material/iron = 6000, /datum/material/silver = 600, /datum/material/glass = 1000)
	build_path = /obj/item/ammo_box/magazine/wt550m9/wtic
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/stunshell
	name = "Stun Shell"
	desc = "A stunning shell for a shotgun."
	id = "stunshell"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 200)
	build_path = /obj/item/ammo_casing/shotgun/stunslug
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/techshell
	name = "Unloaded Technological Shotshell"
	desc = "A high-tech shotgun shell which can be loaded with materials to produce unique effects."
	id = "techshotshell"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 200)
	build_path = /obj/item/ammo_casing/shotgun/techshell
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/suppressor
	name = "Suppressor"
	desc = "A reverse-engineered suppressor that fits on most small arms with threaded barrels."
	id = "suppressor"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/silver = 500)
	build_path = /obj/item/suppressor
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/gravitygun
	name = "One-point Bluespace-gravitational Manipulator"
	desc = "A multi-mode device that blasts one-point bluespace-gravitational bolts that locally distort gravity."
	id = "gravitygun"
	build_type = PROTOLATHE
	materials = list(/datum/material/silver = 8000, /datum/material/uranium = 8000, /datum/material/glass = 12000, /datum/material/iron = 12000, /datum/material/diamond = 3000, /datum/material/bluespace = 3000)
	build_path = /obj/item/gun/energy/gravity_gun
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/largecrossbow
	name = "Energy Crossbow"
	desc = "A reverse-engineered energy crossbow favored by syndicate infiltration teams and carp hunters."
	id = "largecrossbow"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 1500, /datum/material/uranium = 1500, /datum/material/silver = 1500)
	build_path = /obj/item/gun/energy/kinetic_accelerator/crossbow/large
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/cryostasis_shotgun_dart
	name = "Cryostasis Shotgun Dart"
	desc = "A shotgun dart designed with similar internals to that of a cryostasis beaker, allowing reagents to not react when inside."
	id = "shotgundartcryostasis"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 3500)
	build_path = /obj/item/ammo_casing/shotgun/dart/noreact
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/flashbulb
	name = "Security Flashbulb"
	desc = "A powerful bulb that, when placed into a flash device can emit a bright light that will disorientate and subdue targets."
	id = "flashbulb"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 300, /datum/material/glass = 150)
	build_path = /obj/item/flashbulb
	category = list("Weapons")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

//=======================================
// Shuttle Weapons
//=======================================

/datum/design/board/weapons
	name = "Shuttle Weapons Control Computer"
	desc = "A computer board that allows for the control of weapons on a linked shuttle."
	id = "computer_weapons"
	build_type = IMPRINTER
	materials = list(/datum/material/glass = 1000, /datum/material/copper = 300)
	build_path = /obj/item/circuitboard/computer/shuttle/weapons
	category = list("Shuttle Weapons", "Shuttle Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/loader_railgun
	name = "Laser Charging Unit"
	desc = "An ammunition loader for charging laser turrets."
	id = "loader_laser"
	build_type = IMPRINTER
	materials = list(/datum/material/iron = 15 * MINERAL_MATERIAL_AMOUNT, /datum/material/copper = 15 * MINERAL_MATERIAL_AMOUNT, /datum/material/crilium = 1 * MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/circuitboard/machine/loader_laser
	category = list("Shuttle Weapons", "Shuttle Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/loader_railgun
	name = "Railgun Loader"
	desc = "An ammunition loader for loading railgun shells."
	id = "loader_railgun"
	build_type = IMPRINTER
	materials = list(/datum/material/iron = 25 * MINERAL_MATERIAL_AMOUNT, /datum/material/copper = 5 * MINERAL_MATERIAL_AMOUNT, /datum/material/diamond = 8 * MINERAL_MATERIAL_AMOUNT, /datum/material/crilium = 3 * MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/circuitboard/machine/loader_railgun
	category = list("Shuttle Weapons", "Shuttle Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/loader_ballistic
	name = "Ballistic Ammo Box Loader"
	desc = "An ammunition loader for loading ballistic ammunition boxes."
	id = "loader_ballistic"
	build_type = IMPRINTER
	materials = list(/datum/material/iron = 15 * MINERAL_MATERIAL_AMOUNT, /datum/material/copper = 5 * MINERAL_MATERIAL_AMOUNT, /datum/material/gold = 5 * MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/circuitboard/machine/loader_ballistic
	category = list("Shuttle Weapons", "Shuttle Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/loader_missile
	name = "Missile Ammo Box Loader"
	desc = "An ammunition loader for loading missiles."
	id = "loader_missile"
	build_type = IMPRINTER
	materials = list(/datum/material/iron = 20 * MINERAL_MATERIAL_AMOUNT, /datum/material/copper = 5 * MINERAL_MATERIAL_AMOUNT, /datum/material/gold = 20 * MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/circuitboard/machine/loader_missile
	category = list("Shuttle Weapons", "Shuttle Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/shuttle_weapon
	name = "Laser Cannon Mount"
	desc = "A wall mounted laser cannon, designed for use on shuttles."
	id = "shuttle_laser"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT * 15, /datum/material/glass = MINERAL_MATERIAL_AMOUNT * 15)
	category = list("Shuttle Weapons")
	build_path = /obj/item/wallframe/shuttle_weapon/laser
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/shuttle_weapon/laser_triple
	name = "Burst Laser MKI Mount"
	desc=  "A wall mounted burst laser, designed for use on shuttles."
	id = "shuttle_laser_burst"
	materials = list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT * 20, /datum/material/glass = MINERAL_MATERIAL_AMOUNT * 15, /datum/material/gold = MINERAL_MATERIAL_AMOUNT * 5)
	build_path = /obj/item/wallframe/shuttle_weapon/laser/triple
	category = list("Shuttle Weapons")

/datum/design/shuttle_weapon/laser_triple_mark2
	name = "Burst Laser MKII Mount"
	desc=  "An upgraded version of the wall mounted burst laser, designed for use on shuttles."
	id = "shuttle_laser_burst_two"
	materials = list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT * 25, /datum/material/glass = MINERAL_MATERIAL_AMOUNT * 20, /datum/material/gold = MINERAL_MATERIAL_AMOUNT * 10, /datum/material/titanium = MINERAL_MATERIAL_AMOUNT * 5)
	build_path = /obj/item/wallframe/shuttle_weapon/laser/triple/mark2
	category = list("Shuttle Weapons")

/datum/design/shuttle_weapon/missile
	name = "Centaur I Mount"
	desc=  "A wall mounted missile launcher, designed for use on shuttles."
	id = "shuttle_missile"
	materials = list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT * 20, /datum/material/gold = MINERAL_MATERIAL_AMOUNT * 5)
	build_path = /obj/item/wallframe/shuttle_weapon/missile
	category = list("Shuttle Weapons")

/datum/design/shuttle_weapon/point_defense_one
	name = "Hades MKI Chaincannon Mount"
	desc=  "A wall mounted automatic chain channon with limited capability to destroy hull, but extremely powerful at taking down crews and machinery. Designed for use on shuttles."
	id = "shuttle_point_defense"
	materials = list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT * 15, /datum/material/glass = MINERAL_MATERIAL_AMOUNT * 10)
	build_path = /obj/item/wallframe/shuttle_weapon/point_defense
	category = list("Shuttle Weapons")

/datum/design/shuttle_weapon/scatter_shot
	name = "Ares Scattershot Mount"
	desc=  "A powerful flak cannon that fires 8 projectiles at once. Designed for use on shuttles."
	id = "shuttle_scatter_shot"
	materials = list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT * 20, /datum/material/glass = MINERAL_MATERIAL_AMOUNT * 10)
	build_path = /obj/item/wallframe/shuttle_weapon/scatter
	category = list("Shuttle Weapons")

/datum/design/shuttle_weapon/railgun
	name = "Zeus MKI Railgun Mount"
	desc=  "A kinetic weapon designed for long ranged precision shots. Designed for use on shuttles."
	id = "shuttle_railgun"
	materials = list(/datum/material/iron = 35 * MINERAL_MATERIAL_AMOUNT, /datum/material/glass = 15 * MINERAL_MATERIAL_AMOUNT, /datum/material/copper = 30 * MINERAL_MATERIAL_AMOUNT, /datum/material/diamond = 3 * MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/wallframe/shuttle_weapon/railgun
	category = list("Shuttle Weapons")

//=======================================
// Shuttle Weapon Ammo
//=======================================

/datum/design/shuttle_ammo
	name = "Chaincannon Ammo Box (Plasma)"
	desc=  "A box of chaincannon rounds for use in ballistic ammunition loaders. Uses plasma as propellent."
	id = "shuttle_chaingun"
	materials = list(/datum/material/iron = 5 * MINERAL_MATERIAL_AMOUNT, /datum/material/plasma = 10 * MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/ammo_box/chaingun
	build_type = PROTOLATHE | AUTOLATHE
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_SCIENCE
	category = list("Shuttle Weapons", "Security")

/datum/design/shuttle_ammo_heavy
	name = "Chaincannon Armor Peircing Ammo Box (Plasma)"
	desc=  "A box of chaincannon rounds for use in ballistic ammunition loaders. Tipped with a strong diamond coating and uses plasma as propellent."
	id = "shuttle_chaingun_heavy"
	materials = list(/datum/material/iron = 10 * MINERAL_MATERIAL_AMOUNT, /datum/material/plasma = 10 * MINERAL_MATERIAL_AMOUNT, /datum/material/diamond = 1 * MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/ammo_box/chaingun
	build_type = PROTOLATHE | AUTOLATHE
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_SCIENCE
	category = list("Shuttle Weapons", "Security")

/datum/design/shuttle_missile
	name = "Shuttle-Fired Missile"
	desc=  "A small explosive missile, fired from a shuttle turret."
	id = "shuttle_missile_projectile"
	materials = list(/datum/material/iron = 5 * MINERAL_MATERIAL_AMOUNT, /datum/material/plasma = 8 * MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/ammo_casing/caseless/shuttle_missile
	build_type = PROTOLATHE
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_SCIENCE
	category = list("Shuttle Weapons", "Security")

/datum/design/shuttle_missile/fire
	name = "Shuttle-Fired Incendiary Missile"
	desc=  "A small incendiary missile, fired from a shuttle turret."
	id = "shuttle_missile_fire"
	materials = list(/datum/material/iron = 5 * MINERAL_MATERIAL_AMOUNT, /datum/material/plasma = 15 * MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/ammo_casing/caseless/shuttle_missile/fire
	build_type = PROTOLATHE
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_SCIENCE
	category = list("Shuttle Weapons", "Security")

/datum/design/shuttle_missile/emp
	name = "Shuttle-Fired Electromagnetic Disruption Missile"
	desc=  "An electromagnetic disruption missile, fired from a shuttle turret."
	id = "shuttle_missile_emp"
	materials = list(/datum/material/iron = 15 * MINERAL_MATERIAL_AMOUNT, /datum/material/plasma = 5 * MINERAL_MATERIAL_AMOUNT, /datum/material/copper = 5 * MINERAL_MATERIAL_AMOUNT, /datum/material/crilium = 2 * MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/ammo_casing/caseless/shuttle_missile/emp
	build_type = PROTOLATHE
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_SCIENCE
	category = list("Shuttle Weapons", "Security")

/datum/design/shuttle_missile/breach
	name = "Shuttle-Fired Breaching Missile"
	desc=  "A high-explosive breaching missile, fired from a shuttle turret."
	id = "shuttle_missile_breach"
	materials = list(/datum/material/iron = 15 * MINERAL_MATERIAL_AMOUNT, /datum/material/plasma = 5 * MINERAL_MATERIAL_AMOUNT, /datum/material/crilium = 1 * MINERAL_MATERIAL_AMOUNT, /datum/material/diamond = 3 * MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/ammo_casing/caseless/shuttle_missile/breach
	build_type = PROTOLATHE
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_SCIENCE
	category = list("Shuttle Weapons", "Security")
