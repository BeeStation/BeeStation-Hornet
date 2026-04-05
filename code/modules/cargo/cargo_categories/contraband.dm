/**
 * # Contraband Cargo Crates
 *
 * All contraband cargo entries consolidated into one file.
 * Includes illicit goods, syndicate surplus, and special ops supplies.
 */

// =============================================================================
// CONTRABAND CRATES
// =============================================================================

/datum/cargo_crate/contraband

/datum/cargo_crate/contraband/goods
	name = "Contraband Crate"
	desc = "Psst.. bud... want some contraband? I can get you a poster, some nice cigs, dank, even some sponsored items...you know, the good stuff. Just keep it away from the cops, kay?"
	cost = 3000
	max_supply = 2
	contraband = TRUE
	contains = list(
		/obj/item/poster/random_contraband,
		/obj/item/poster/random_contraband,
		/obj/item/food/grown/cannabis,
		/obj/item/food/grown/cannabis/rainbow,
		/obj/item/food/grown/cannabis/white,
		/obj/item/storage/pill_bottle/zoom,
		/obj/item/storage/pill_bottle/happy,
		/obj/item/storage/pill_bottle/lsd,
		/obj/item/storage/pill_bottle/aranesp,
		/obj/item/storage/pill_bottle/stimulant,
		/obj/item/toy/cards/deck/syndicate,
		/obj/item/reagent_containers/cup/glass/bottle/absinthe,
		/obj/item/clothing/under/syndicate/tacticool,
		/obj/item/storage/fancy/cigarettes/cigpack_syndicate,
		/obj/item/storage/fancy/cigarettes/cigpack_shadyjims,
		/obj/item/clothing/mask/gas/syndicate,
		/obj/item/clothing/neck/necklace/dope,
		/obj/item/vending_refill/donksoft,
		/obj/item/clothing/neck/cloak/fakehalo,
	)

/datum/cargo_crate/contraband/goods/fill(obj/structure/closet/crate/C)
	var/list/L = contains.Copy()
	for(var/i in 1 to 7)
		var/item = pick_n_take(L)
		new item(C)

/datum/cargo_crate/contraband/specialops
	name = "Special Ops Supplies"
	desc = "(*!&@#OPERATIVE THIS LITTLE ORDER CAN STILL HELP YOU OUT IN A PINCH. CONTAINS A BOX OF FIVE EMP GRENADES, THREE SMOKEBOMBS, AN INCENDIARY GRENADE, AND A \"SLEEPY PEN\" FULL OF NICE TOXINS!#@*$"
	cost = 800
	max_supply = 2
	syndicate_contraband = TRUE
	contains = list(
		/obj/item/storage/box/emps,
		/obj/item/grenade/smokebomb,
		/obj/item/grenade/smokebomb,
		/obj/item/grenade/smokebomb,
		/obj/item/pen/paralytic,
		/obj/item/grenade/chem_grenade/incendiary,
	)
	crate_type = /obj/structure/closet/crate/internals

/datum/cargo_crate/contraband/syndieclothes
	name = "Syndicate Uniform Supplies"
	desc = "(*!&@#OPERATIVE THIS LITTLE ORDER WILL MAKE YOU STYLISH SYNDICATE STYLE. CONTAINS A COLLECTION OF THREE TACTICAL TURTLENECKS, THREE COMBAT BOOTS, THREE COMBAT GLOVES, THREE BALACLAVAS, THREE SYNDICATE BERETS AND THREE ARMOR VESTS!#@*$"
	cost = 3000
	max_supply = 3
	syndicate_contraband = TRUE
	contains = list(
		/obj/item/clothing/under/syndicate,
		/obj/item/clothing/under/syndicate,
		/obj/item/clothing/under/syndicate,
		/obj/item/clothing/shoes/combat,
		/obj/item/clothing/shoes/combat,
		/obj/item/clothing/shoes/combat,
		/obj/item/clothing/mask/balaclava,
		/obj/item/clothing/mask/balaclava,
		/obj/item/clothing/mask/balaclava,
		/obj/item/clothing/gloves/tackler/combat,
		/obj/item/clothing/gloves/tackler/combat,
		/obj/item/clothing/gloves/tackler/combat,
		/obj/item/clothing/head/hats/hos/beret/syndicate,
		/obj/item/clothing/head/hats/hos/beret/syndicate,
		/obj/item/clothing/head/hats/hos/beret/syndicate,
		/obj/item/clothing/suit/armor/vest,
		/obj/item/clothing/suit/armor/vest,
		/obj/item/clothing/suit/armor/vest,
	)
	crate_type = /obj/structure/closet/crate/internals

/datum/cargo_crate/contraband/syndicate
	name = "Syndicate Surplus Crate"
	desc = "(#@&^$THIS PACKAGE CONTAINS 30TC WORTH OF SOME RANDOM SYNDICATE GEAR WE HAD LYING AROUND THE WAREHOUSE. GIVE EM HELL, OPERATIVE.@&!*()"
	cost = 20000
	max_supply = 2
	syndicate_contraband = TRUE
	dangerous = TRUE
	contains = list()
	crate_type = /obj/structure/closet/crate/internals

/datum/cargo_crate/contraband/syndicate/fill(obj/structure/closet/crate/C)
	var/crate_value = 30
	var/list/uplink_items = get_uplink_items(UPLINK_NULL_CRATE, FALSE, FALSE)
	var/max_items = 10
	while(crate_value && max_items-- > 0)
		var/category = pick(uplink_items)
		var/item = pick(uplink_items[category])
		var/datum/uplink_item/I = uplink_items[category][item]
		if(!I.surplus || prob(100 - I.surplus))
			continue
		if(crate_value < I.cost)
			continue
		crate_value -= I.cost
		new I.item(C)

/datum/cargo_crate/contraband/foamforce_pistols
	name = "Foam Force Pistols Crate"
	desc = "Psst.. hey bud... remember those old foam force pistols that got discontinued for being too cool? Well I got two of those right here with your name on em. I'll even throw in a spare mag for each, waddya say?"
	cost = 4000
	max_supply = 1
	contraband = TRUE
	contains = list(
		/obj/item/gun/ballistic/automatic/toy/pistol,
		/obj/item/gun/ballistic/automatic/toy/pistol,
		/obj/item/ammo_box/magazine/toy/pistol,
		/obj/item/ammo_box/magazine/toy/pistol,
	)

/datum/cargo_crate/contraband/clownpin
	name = "Hilarious Firing Pin Crate"
	desc = "I uh... I'm not really sure what this does. Wanna buy it?"
	cost = 5000
	max_supply = 4
	contraband = TRUE
	contains = list(/obj/item/firing_pin/clown)
	crate_type = /obj/structure/closet/crate/wooden

/datum/cargo_crate/contraband/lasertagpins
	name = "Laser Tag Firing Pins Crate"
	desc = "Three laser tag firing pins used in laser-tag units to ensure users are wearing their vests."
	cost = 3000
	max_supply = 5
	contraband = TRUE
	contains = list(/obj/item/storage/box/lasertagpins)

/datum/cargo_crate/contraband/plush_no_moths
	name = "Plushie Crate Without Moth Plushies"
	desc = "A crate filled with 5 plushies without all those pesky moth plushies! Might contain dangerous plushies."
	cost = 1500
	max_supply = 5
	contraband = TRUE
	contains = list()
	crate_type = /obj/structure/closet/crate/wooden

/datum/cargo_crate/contraband/plush_no_moths/fill(obj/structure/closet/crate/C)
	var/plush_nomoth
	var/_temporary_list_plush_nomoth = subtypesof(/obj/item/toy/plush) - typesof(/obj/item/toy/plush/moth)
	for(var/i in 1 to 5)
		plush_nomoth = pick(_temporary_list_plush_nomoth)
		new plush_nomoth(C)

/datum/cargo_crate/contraband/cream_pie
	name = "High-yield Clown-grade Cream Pie Crate"
	desc = "Designed by Aussec's Advanced Warfare Research Division, these high-yield, Clown-grade cream pies are powered by a synergy of performance and efficiency. Guaranteed to provide maximum results."
	cost = 6000
	max_supply = 4
	contraband = TRUE
	contains = list(/obj/item/storage/backpack/duffelbag/clown/cream_pie)
	crate_type = /obj/structure/closet/crate/secure

/datum/cargo_crate/contraband/beefbroth
	name = "Beef Broth Bulk Crate"
	desc = "No one really wants to order beef broth so we're selling it in bulk!"
	cost = 5000
	max_supply = 3
	contraband = TRUE
	contains = list(
		/obj/item/food/canned/beefbroth,
		/obj/item/food/canned/beefbroth,
		/obj/item/food/canned/beefbroth,
		/obj/item/food/canned/beefbroth,
		/obj/item/food/canned/beefbroth,
		/obj/item/food/canned/beefbroth,
		/obj/item/food/canned/beefbroth,
		/obj/item/food/canned/beefbroth,
		/obj/item/food/canned/beefbroth,
		/obj/item/food/canned/beefbroth,
	)

/datum/cargo_crate/contraband/vehicle
	name = "Biker Gang Kit"
	desc = "TUNNEL SNAKES OWN THIS TOWN. Contains an unbranded All Terrain Vehicle, and a complete gang outfit -- consists of black gloves, a menacing skull bandanna, and a SWEET leather overcoat!"
	cost = 1500
	max_supply = 2
	contraband = TRUE
	contains = list(
		/obj/vehicle/ridden/atv,
		/obj/item/key/atv,
		/obj/item/clothing/suit/jacket/leather/overcoat,
		/obj/item/clothing/gloves/color/black,
		/obj/item/clothing/head/soft/cargo,
		/obj/item/clothing/mask/bandana/skull/black,
	)
	crate_type = /obj/structure/closet/crate/large

/datum/cargo_crate/contraband/lawnmower
	name = "Lawnmower Crate"
	desc = "Contains an unstable and slow lawnmower. Use with caution!"
	cost = 3000
	max_supply = 3
	contraband = TRUE
	contains = list(/obj/vehicle/ridden/lawnmower)

/datum/cargo_crate/contraband/justiceinbound
	name = "Standard Justice Enforcer Crate"
	desc = "This is it. The Bee's Knees. The Creme of the Crop. The Pick of the Litter. The best of the best of the best. The Crown Jewel of Nanotrasen. The Alpha and the Omega of security headwear. Guaranteed to strike fear into the hearts of each and every criminal aboard the station. Also comes with a security gasmask."
	cost = 5700
	max_supply = 3
	contraband = TRUE
	contains = list(
		/obj/item/clothing/head/helmet/toggleable/justice,
		/obj/item/clothing/mask/gas/sechailer,
	)
	crate_type = /obj/structure/closet/crate/secure/gear

/datum/cargo_crate/contraband/butterfly
	name = "Butterflies Crate"
	desc = "Not a very dangerous insect, but they do give off a better image than, say, flies or cockroaches."
	cost = 5000
	max_supply = 4
	contraband = TRUE
	contains = list(/mob/living/simple_animal/butterfly)
	crate_type = /obj/structure/closet/crate/critter

/datum/cargo_crate/contraband/butterfly/generate(atom/A, datum/bank_account/paying_account)
	. = ..()
	for(var/i in 1 to 49)
		new /mob/living/simple_animal/butterfly(.)

/datum/cargo_crate/contraband/virus
	name = "Virus Crate"
	cost = 3000
	max_supply = 1
	contraband = TRUE
	dangerous = TRUE
	contains = list(
		/obj/item/reagent_containers/cup/bottle/fake_gbs,
		/obj/item/reagent_containers/cup/bottle/magnitis,
		/obj/item/reagent_containers/cup/bottle/pierrot_throat,
		/obj/item/reagent_containers/cup/bottle/brainrot,
		/obj/item/reagent_containers/cup/bottle/anxiety,
		/obj/item/reagent_containers/cup/bottle/beesease,
	)
	crate_type = /obj/structure/closet/crate/secure/plasma

/datum/cargo_crate/contraband/russian
	name = "Russian Surplus Crate"
	cost = 7500
	max_supply = 1
	contraband = TRUE
	contains = list(
		/obj/item/food/rationpack,
		/obj/item/ammo_box/a762,
		/obj/item/storage/toolbox/ammo,
		/obj/item/clothing/suit/armor/vest/russian,
		/obj/item/clothing/head/helmet/rus_helmet,
		/obj/item/clothing/shoes/russian,
		/obj/item/clothing/gloves/tackler/combat,
		/obj/item/clothing/under/syndicate/rus_army,
		/obj/item/clothing/under/costume/soviet,
		/obj/item/clothing/mask/russian_balaclava,
		/obj/item/clothing/head/helmet/rus_ushanka,
		/obj/item/clothing/suit/armor/vest/russian_coat,
		/obj/item/gun/ballistic/rifle/boltaction,
		/obj/item/gun/ballistic/rifle/boltaction,
	)

/datum/cargo_crate/contraband/russian/fill(obj/structure/closet/crate/C)
	for(var/i in 1 to 10)
		var/item = pick(contains)
		new item(C)

/datum/cargo_crate/contraband/western
	name = "Western Frontier Crate"
	cost = 7500
	max_supply = 1
	contraband = TRUE
	contains = list(
		/obj/item/ammo_box/c38/box,
		/obj/item/storage/toolbox/ammo/c38,
		/obj/item/mob_lasso,
		/obj/item/clothing/shoes/workboots/mining,
		/obj/item/clothing/gloves/botanic_leather,
		/obj/item/clothing/gloves/color/black,
		/obj/item/clothing/head/cowboy,
		/obj/item/clothing/head/costume/sombrero,
		/obj/item/clothing/head/costume/sombrero/green,
		/obj/item/storage/belt/bandolier/western,
		/obj/item/gun/ballistic/rifle/leveraction,
		/obj/item/gun/ballistic/rifle/leveraction,
	)
	var/wear_outer = list(
		/obj/item/clothing/suit/apron/overalls,
		/obj/item/clothing/suit/costume/poncho,
		/obj/item/clothing/suit/costume/poncho/green,
		/obj/item/clothing/suit/costume/poncho/red,
	)
	var/wear_under = list(
		/obj/item/clothing/under/misc/overalls,
		/obj/item/clothing/under/misc/overalls,
		/obj/item/clothing/under/misc/overalls,
		/obj/item/clothing/under/suit/sl,
		/obj/item/clothing/under/suit/sl,
	)
	var/cursed = list(
		/obj/item/clothing/head/helmet/outlaw,
		/obj/item/clothing/mask/fakemoustache,
		/obj/item/clothing/suit/costume/poncho/ponchoshame/outlaw,
		/obj/item/clothing/under/suit/sl,
		/obj/item/clothing/shoes/workboots/mining,
		/obj/item/clothing/gloves/color/black,
		/obj/item/storage/belt/bandolier/western/filled,
		/obj/item/gun/ballistic/rifle/leveraction,
		/obj/item/gun/ballistic/revolver/detective/cowboy,
		/obj/item/clothing/accessory/holster,
		/obj/item/paper/crumpled/bloody/cursed_western,
	)

/datum/cargo_crate/contraband/western/fill(obj/structure/closet/crate/C)
	if(prob(1) && prob(10)) //0.001% chance of cursed variant
		C.name = "cursed gunslinger crate"
		C.color = COLOR_GRAY
		for(var/item in cursed)
			new item(C)
	else
		for(var/i in 1 to 6)
			var/item = pick(contains)
			new item(C)
		for(var/i in 1 to 2)
			var/item_outer = pick(wear_outer)
			new item_outer(C)
		for(var/i in 1 to 3)
			var/item_under = pick(wear_under)
			new item_under(C)
		new /obj/item/clothing/mask/fakemoustache(C)
		new /obj/item/clothing/mask/fakemoustache(C)
