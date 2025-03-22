GLOBAL_LIST_INIT(uplink_items, subtypesof(/datum/uplink_item))
/proc/get_uplink_items(uplink_flag, allow_sales = TRUE, allow_restricted = TRUE)
	var/list/filtered_uplink_items = list()
	var/list/sale_items = list()

	for(var/path in GLOB.uplink_items)
		var/datum/uplink_item/I = new path
		if(!I.item)
			continue
		if (I.disabled)
			continue
		if (!(I.purchasable_from & uplink_flag))
			continue
		if(I.player_minimum && I.player_minimum > GLOB.joined_player_list.len)
			continue
		if (I.restricted && !allow_restricted)
			continue
		if(!filtered_uplink_items[I.category])
			filtered_uplink_items[I.category] = list()
		filtered_uplink_items[I.category][I.name] = I
		if(I.limited_stock < 0 && !I.cant_discount && I.item)
			sale_items += I

	if(allow_sales)
		var/datum/team/nuclear/nuclear_team
		if (uplink_flag & UPLINK_NUKE_OPS) 					// uplink code kind of needs a redesign
			nuclear_team = locate() in GLOB.antagonist_teams	// the team discounts could be a in a GLOB with this design but it would make sense for them to be team specific...
		if (!nuclear_team)
			create_uplink_sales(3, "Discounted Gear", 1, sale_items, filtered_uplink_items)
		else
			if (!nuclear_team.team_discounts)
				// create 5 unlimited stock discounts
				create_uplink_sales(5, "Discounted Team Gear", -1, sale_items, filtered_uplink_items)
				// Create 10 limited stock discounts
				create_uplink_sales(10, "Limited Stock Team Gear", 1, sale_items, filtered_uplink_items)
				nuclear_team.team_discounts = list("Discounted Team Gear" = filtered_uplink_items["Discounted Team Gear"], "Limited Stock Team Gear" = filtered_uplink_items["Limited Stock Team Gear"])
			else
				for(var/cat in nuclear_team.team_discounts)
					for(var/item in nuclear_team.team_discounts[cat])
						var/datum/uplink_item/D = nuclear_team.team_discounts[cat][item]
						var/datum/uplink_item/O = filtered_uplink_items[initial(D.category)][initial(D.name)]
						O.refundable = FALSE

				filtered_uplink_items["Discounted Team Gear"] = nuclear_team.team_discounts["Discounted Team Gear"]
				filtered_uplink_items["Limited Stock Team Gear"] = nuclear_team.team_discounts["Limited Stock Team Gear"]


	return filtered_uplink_items

/proc/create_uplink_sales(num, category_name, limited_stock, sale_items, uplink_items)
	if (num <= 0)
		return

	if(!uplink_items[category_name])
		uplink_items[category_name] = list()

	for (var/i in 1 to num)
		var/datum/uplink_item/origin_entry = pick_n_take(sale_items)
		var/datum/uplink_item/sale_entry = new origin_entry.type
		var/list/disclaimer = list("Void where prohibited.", "Not recommended for children.", "Contains small parts.", "Check local laws for legality in region.", "Do not taunt.", "Not responsible for direct, indirect, incidental or consequential damages resulting from any defect, error or failure to perform.", "Keep away from fire or flames.", "Product is provided \"as is\" without any implied or expressed warranties.", "As seen on TV.", "For recreational use only.", "Use only as directed.", "16% sales tax will be charged for orders originating within Space Nebraska.")
		origin_entry.refundable = FALSE //THIS MAN USES ONE WEIRD TRICK TO GAIN FREE TC, CODERS HATES HIM!
		sale_entry.limited_stock = limited_stock
		sale_entry.category = category_name
		sale_entry.refundable = FALSE
		switch(sale_entry.cost == 1 ? 1 : rand(1, 5))
			if(1 to 3)
				if(sale_entry.cost <= 3)
					//Bulk discount
					var/count = rand(3,7)
					var/discount = sale_entry.get_discount()
					sale_entry.name += " (Bulk discount - [count] for [((1-discount)*100)]% off!)"
					sale_entry.cost = max(round(sale_entry.cost*count*discount), 1)
					sale_entry.desc += " Normally costs [initial(sale_entry.cost)*count] TC. All sales final. [pick(disclaimer)]"
					sale_entry.spawn_amount = count
				else
					//X% off!
					var/discount = sale_entry.get_discount()
					if(sale_entry.cost >= 20) //Tough love for nuke ops
						discount *= 0.5
					sale_entry.cost = max(round(sale_entry.cost * discount), 1)
					sale_entry.name += " ([round(((initial(sale_entry.cost)-sale_entry.cost)/initial(sale_entry.cost))*100)]% off!)"
					sale_entry.desc += " Normally costs [initial(sale_entry.cost)] TC. All sales final. [pick(disclaimer)]"
			if(4)
				//Buy 1 get 1 free!
				sale_entry.name += " (Buy 1 get 1 free!)"
				sale_entry.desc += " Obtain 2 for the price of 1. All sales final. [pick(disclaimer)]"
				sale_entry.spawn_amount = 2
			if(5)
				//Get 2 items with their combined price reduced.
				var/datum/uplink_item/bonus_entry = pick_n_take(sale_items)
				bonus_entry = new bonus_entry.type
				var/total_cost = bonus_entry.cost + sale_entry.cost
				var/discount = sale_entry.get_discount()
				var/final_cost = max(round(total_cost * discount), 1)
				bonus_entry.cost = 0
				bonus_entry.is_bonus = TRUE
				//Setup the item
				sale_entry.cost = final_cost
				sale_entry.name += " + [bonus_entry.name] (Discounted Bundle - [100-(round((final_cost / total_cost)*100))]% off!)"
				sale_entry.desc += " Also contains [bonus_entry.name]. Normally costs [total_cost] TC when bought together. All sales final. [pick(disclaimer)]"
				sale_entry.additional_uplink_entry = list(bonus_entry)
		sale_entry.discounted = TRUE
		sale_entry.item = origin_entry.item
		uplink_items[category_name][sale_entry.name] = sale_entry


// some items are not good to tell to have illegal tech, especially boxes, bottles
GLOBAL_LIST_INIT(illegal_tech_blacklist, typecacheof(list(
	/obj/item/storage/box,
	/obj/item/reagent_containers)))

/**
 * Uplink Items
 *
 * Items that can be spawned from an uplink. Can be limited by gamemode.
**/
/datum/uplink_item
	var/name = "item name"
	var/category = "item category"
	var/desc = "item description"
	var/item = null // Path to the item to spawn.
	var/refund_path = null // Alternative path for refunds, in case the item purchased isn't what is actually refunded (ie: holoparasites).
	var/cost = 0
	var/refund_amount = 0 // specified refund amount in case there needs to be a TC penalty for refunds.
	var/refundable = FALSE
	var/surplus = 100 // Chance of being included in the surplus crate.
	var/cant_discount = FALSE
	var/murderbone_type = FALSE
	var/limited_stock = -1 //Setting this above zero limits how many times this item can be bought by the same traitor in a round, -1 is unlimited
	var/purchasable_from = ALL
	var/list/restricted_roles = list() //If this uplink item is only available to certain roles. Roles are dependent on the frequency chip or stored ID.
	var/player_minimum //The minimum crew size needed for this item to be added to uplinks.
	var/purchase_log_vis = TRUE // Visible in the purchase log?
	var/restricted = FALSE // Adds restrictions for VR/Events
	var/list/restricted_species //Limits items to a specific species. Hopefully.
	var/illegal_tech = TRUE // Can this item be deconstructed to unlock certain techweb research nodes? (Some items will be forcefully set to FALSE, especially boxes, bottles)
	var/contents_are_illegal_tech = TRUE // the same one above, but all items within a box will become illegal tech.
	var/discounted = FALSE
	var/spawn_amount = 1	//How many times we should run the spawn
	var/additional_uplink_entry	= null	//Bonus items you gain if you purchase it
	var/is_bonus = FALSE // entry in 'additional_uplink_entry' will have this as TRUE. Used for logging detail
	var/disabled = FALSE

/datum/uplink_item/New()
	. = ..()
	// this is important because wrong items can be said to tell it can be used for illegal
	if(!ispath(item, /obj/item) || is_type_in_typecache(item, GLOB.illegal_tech_blacklist))
		illegal_tech = FALSE

/datum/uplink_item/proc/get_discount()
	return pick(4;0.75,2;0.5,1;0.25)

/datum/uplink_item/proc/purchase(mob/user, datum/component/uplink/U)
	//Spawn base items
	var/tmp = is_bonus
	for(var/i in 1 to spawn_amount)
		var/atom/A = spawn_item(item, user, U)
		if(purchase_log_vis && U.purchase_log)
			U.purchase_log.LogPurchase(A, src, cost, is_bonus = is_bonus)
		is_bonus = TRUE // additional spawn after first loop? that must be bonus item.
	//Spawn bonus items
	for(var/datum/uplink_item/bonus_entry in additional_uplink_entry)
		for(var/i in 1 to bonus_entry.spawn_amount)
			bonus_entry.spawn_item(bonus_entry.item, user, U)
	is_bonus = tmp

/datum/uplink_item/proc/spawn_item(spawn_path, mob/user, datum/component/uplink/U)
	if(!spawn_path)
		return
	var/atom/A
	if(ispath(spawn_path))
		A = new spawn_path(get_turf(user))
	else
		A = spawn_path
	put_illegal_bitflag(A, illegal_tech, contents_are_illegal_tech)
	if(istype(A, /obj/item))
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.put_in_hands(A))
				to_chat(H, "[A] materializes into your hands!")
				log_uplink_purchase(user, A, is_bonus = is_bonus)
				return A
	to_chat(user, "[A] materializes onto the floor.")
	log_uplink_purchase(user, A, is_bonus = is_bonus)
	return A

/// Uplink purchased items get ILLEGAL tech bitflag based on given parameter.
/// Note: This should be a global proc because of surplus crate
/proc/put_illegal_bitflag(obj/item/target_item, illegal_tech, contents_are_illegal_tech)
	if(contents_are_illegal_tech)
		for(var/obj/item/each_item in target_item.contents)
			put_illegal_bitflag(each_item, contents_are_illegal_tech, TRUE)
	if(!illegal_tech)
		return
	target_item.item_flags |= ILLEGAL


/datum/uplink_item/proc/can_be_refunded(obj/item/item, datum/component/uplink/uplink)
	return refundable

//Discounts (dynamically filled above)
/datum/uplink_item/discounts
	category = "Discounts"

//All bundles and telecrystals
/datum/uplink_item/bundles_TC
	category = "Bundles"
	surplus = 0
	cant_discount = TRUE

/datum/uplink_item/bundles_TC/chemical
	name = "Bioterror bundle"
	desc = "For the madman: Contains a handheld Bioterror chem sprayer, a Bioterror foam grenade, a box of lethal chemicals, a dart pistol, \
			box of syringes, Donksoft assault rifle, and some riot darts. Remember: Seal suit and equip internals before use."
	item = /obj/item/storage/backpack/duffelbag/syndie/med/bioterrorbundle
	cost = 30 // normally 42
	purchasable_from = UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS

/datum/uplink_item/bundles_TC/bulldog
	name = "Bulldog bundle"
	desc = "Lean and mean: Optimized for people that want to get up close and personal. Contains the popular \
			Bulldog shotgun, two 12g buckshot drums, and a pair of Thermal imaging goggles."
	item = /obj/item/storage/backpack/duffelbag/syndie/bulldogbundle
	cost = 13 // normally 16
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/bundles_TC/c20r
	name = "C-20r bundle"
	desc = "Old Faithful: The classic C-20r, bundled with two magazines and a (surplus) suppressor at discount price."
	item = /obj/item/storage/backpack/duffelbag/syndie/c20rbundle
	cost = 14 // normally 16
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/bundles_TC/cyber_implants
	name = "Cybernetic Implants Bundle"
	desc = "A random selection of cybernetic implants. Guaranteed 5 high quality implants. Comes with an autosurgeon."
	item = /obj/item/storage/box/cyber_implants
	cost = 40
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/bundles_TC/medical
	name = "Medical bundle"
	desc = "The support specialist: Aid your fellow operatives with this medical bundle. Contains a tactical medkit, \
			a Donksoft LMG, a box of riot darts and a pair of magboots to rescue your friends in no-gravity environments."
	item = /obj/item/storage/backpack/duffelbag/syndie/med/medicalbundle
	cost = 15 // normally 20
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/bundles_TC/sniper
	name = "Sniper bundle"
	desc = "Elegant and refined: Contains a collapsed sniper rifle in an expensive carrying case, \
			two soporific knockout magazines, a free surplus suppressor, and a sharp-looking tactical turtleneck suit. \
			We'll throw in a free red tie if you order NOW."
	item = /obj/item/storage/briefcase/sniperbundle
	cost = 20 // normally 26
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/bundles_TC/firestarter
	name = "Spetsnaz Pyro bundle"
	desc = "For systematic suppression of carbon lifeforms in close quarters: Contains a lethal Flamethrower, Two plasma tanks, Elite hardsuit, \
			Stechkin APS pistol, two magazines, a tactical medkit and a stimulant syringe. \
			Order NOW and comrade Boris will throw in an extra tracksuit."
	item = /obj/item/storage/backpack/duffelbag/syndie/firestarter
	cost = 30
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/bundles_TC/machoman
	name = "The Macho Wrestler Bundle"
	desc = "For the STRONGEST operatives! Master your wrasslin' abilities with this bundle. \
			Contains: A wrestling belt, only for the strongest machos, an adrenaline implanter, a luchador mask to strike fear into your enemies, and a combat hypospray!"
	item = /obj/item/storage/backpack/duffelbag/syndie/macho
	cost = 18
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/bundles_TC/contract_kit
	name = "Contract Kit"
	desc = "The Syndicate have offered you the chance to become a contractor, take on kidnapping contracts for TC and cash payouts. Upon purchase, \
			you'll be granted your own contract uplink embedded within the supplied tablet computer. Additionally, you'll be granted \
			standard contractor gear to help with your mission - comes supplied with the tablet, specialised space suit, chameleon jumpsuit and mask, \
			agent card, specialised contractor baton, and three randomly selected low cost items. Can include otherwise unobtainable items."
	item = /obj/item/storage/box/syndie_kit/contract_kit
	cost = 20
	player_minimum = 15
	purchasable_from = ~(UPLINK_INCURSION | UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/bundles_TC/bundle_A
	name = "Syndi-kit Tactical"
	desc = "Syndicate Bundles, also known as Syndi-Kits, are specialized groups of items that arrive in a plain box. \
			These items are collectively worth more than 20 telecrystals, but you do not know which specialization \
			you will receive. May contain discontinued and/or exotic items."
	item = /obj/item/storage/box/syndie_kit/bundle_A
	cost = 20
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/bundles_TC/bundle_B
	name = "Syndi-kit Special"
	desc = "Syndicate Bundles, also known as Syndi-Kits, are specialized groups of items that arrive in a plain box. \
			In Syndi-kit Special, you will receive items used by famous syndicate agents of the past. Collectively worth more than 20 telecrystals, the syndicate loves a good throwback."
	item = /obj/item/storage/box/syndie_kit/bundle_B
	cost = 20
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/bundles_TC/surplus
	name = "Syndicate Surplus Crate"
	desc = "A dusty crate from the back of the Syndicate warehouse. Rumored to contain a valuable assortment of items, \
			but you never know. Contents are sorted to always be worth 50 TC."
	item = /obj/structure/closet/crate
	cost = 20
	player_minimum = 20
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	var/starting_crate_value = 50
	var/uplink_contents = UPLINK_TRAITORS

/datum/uplink_item/bundles_TC/surplus/super
	name = "Super Surplus Crate"
	desc = "A dusty SUPER-SIZED from the back of the Syndicate warehouse. Rumored to contain a valuable assortment of items, \
			but you never know. Contents are sorted to always be worth 125 TC."
	cost = 40
	player_minimum = 30
	starting_crate_value = 125
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/bundles_TC/surplus/purchase(mob/user, datum/component/uplink/user_uplink)
	var/list/uplink_items = get_uplink_items(uplink_contents, FALSE)

	var/remaining_crate_value = starting_crate_value
	var/obj/structure/closet/crate/target_crate = spawn_item(/obj/structure/closet/crate, user, user_uplink)
	if(user_uplink.purchase_log)
		user_uplink.purchase_log.LogPurchase(target_crate, src, cost)
	while(remaining_crate_value)
		var/category = pick(uplink_items)
		var/item = pick(uplink_items[category])
		var/datum/uplink_item/uplink_entry = uplink_items[category][item]

		if(!uplink_entry.surplus || prob(100 - uplink_entry.surplus))
			continue
		if(remaining_crate_value < uplink_entry.cost)
			continue
		remaining_crate_value -= uplink_entry.cost
		var/obj/goods = new uplink_entry.item(target_crate)
		put_illegal_bitflag(goods, uplink_entry.illegal_tech, uplink_entry.contents_are_illegal_tech)
		if(user_uplink.purchase_log)
			user_uplink.purchase_log.LogPurchase(goods, uplink_entry, uplink_entry.cost, is_bonus = TRUE)
	return target_crate

//Will either give you complete crap or overpowered as fuck gear
/datum/uplink_item/bundles_TC/surplus/random
	name = "Syndicate Lootbox"
	desc = "A dusty crate from the back of the Syndicate warehouse. Rumored to contain a valuable assortment of items, \
			With their all new kit, codenamed 'scam' the syndicate attempted to extract the energy of the die of fate to \
			make a loot-box style system but failed, so instead just fake their randomness using a corgi to sniff out the items to shove in it.\
			Item price not guaranteed. Can contain normally unobtainable items."
	purchasable_from = ~(UPLINK_INCURSION | UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	uplink_contents = (UPLINK_TRAITORS | UPLINK_NUKE_OPS)
	player_minimum = 30

/datum/uplink_item/bundles_TC/surplus/random/purchase(mob/user, datum/component/uplink/U)
	var/index = rand(1, 20)
	starting_crate_value = index * 5
	if(index == 1)
		to_chat(user, span_warning("<b>Incoming transmission from the syndicate.</b>"))
		to_chat(user, span_warning("You feel an overwhelming sense of pride and accomplishment."))
		var/obj/item/clothing/mask/joy/funny_mask = new(get_turf(user))
		ADD_TRAIT(funny_mask, TRAIT_NODROP, CURSED_ITEM_TRAIT)
		var/obj/item/I = user.get_item_by_slot(ITEM_SLOT_MASK)
		if(I)
			user.dropItemToGround(I, TRUE)
		user.equip_to_slot_if_possible(funny_mask, ITEM_SLOT_MASK)
	else if(index == 20)
		starting_crate_value = 200
		print_command_report("Congratulations to [user] for being the [rand(4, 9)]th lucky winner of the syndicate lottery! \
		Dread Admiral Sabertooth has authorised the beaming of your special equipment immediately! Happy hunting operative.",
		"Syndicate Gambling Division High Command", TRUE)
	var/obj/item/implant/weapons_auth/W = new
	W.implant(user)	//Gives them the ability to use restricted weapons
	. = ..()

/datum/uplink_item/bundles_TC/random
	name = "Random Item"
	desc = "Picking this will purchase a random item. Useful if you have some TC to spare or if you haven't decided on a strategy yet."
	item = /obj/effect/gibspawner/generic // non-tangible item because techwebs use this path to determine illegal tech
	cost = 0

/datum/uplink_item/bundles_TC/random/purchase(mob/user, datum/component/uplink/U)
	var/list/uplink_items = U.uplink_items
	var/list/possible_items = list()
	for(var/category in uplink_items)
		for(var/item in uplink_items[category])
			var/datum/uplink_item/I = uplink_items[category][item]
			if(src == I || !I.item)
				continue
			if(U.telecrystals < I.cost)
				continue
			if(I.limited_stock == 0)
				continue
			possible_items += I

	if(possible_items.len)
		var/datum/uplink_item/I = pick(possible_items)
		SSblackbox.record_feedback("tally", "traitor_random_uplink_items_gotten", 1, initial(I.name))
		U.MakePurchase(user, I)

/datum/uplink_item/bundles_TC/telecrystal
	name = "1 Raw Telecrystal"
	desc = "A telecrystal in its rawest and purest form; can be utilized on active uplinks to increase their telecrystal count."
	item = /obj/item/stack/sheet/telecrystal
	cost = 1
	// Don't add telecrystals to the purchase_log since
	// it's just used to buy more items (including itself!)
	purchase_log_vis = FALSE

/datum/uplink_item/bundles_TC/telecrystal/five
	name = "5 Raw Telecrystals"
	desc = "Five telecrystals in their rawest and purest form; can be utilized on active uplinks to increase their telecrystal count."
	item = /obj/item/stack/sheet/telecrystal/five
	cost = 5

/datum/uplink_item/bundles_TC/telecrystal/twenty
	name = "20 Raw Telecrystals"
	desc = "Twenty telecrystals in their rawest and purest form; can be utilized on active uplinks to increase their telecrystal count."
	item = /obj/item/stack/sheet/telecrystal/twenty
	cost = 20

/datum/uplink_item/bundles_TC/crate
	name = "Bulk Hardsuit Bundle"
	desc = "A crate containing 4 valueable syndicate hardsuits."
	cost = 18
	purchasable_from = UPLINK_INCURSION
	item = /obj/effect/gibspawner/generic
	var/list/contents = list(
		/obj/item/clothing/suit/space/hardsuit/syndi = 4,
		/obj/item/clothing/mask/gas/syndicate = 4,
		/obj/item/tank/internals/oxygen = 4
	)

/datum/uplink_item/bundles_TC/crate/purchase(mob/user, datum/component/uplink/U)
	var/obj/structure/closet/crate/C = spawn_item(/obj/structure/closet/crate, user, U)
	if(U.purchase_log)
		U.purchase_log.LogPurchase(C, src, cost)
	for(var/I in contents)
		var/count = contents[I]
		for(var/index in 1 to count)
			new I(C)
	return C

/datum/uplink_item/bundles_TC/crate/medical
	name = "Syndicate Medical Bundle"
	desc = "Contains an assortment of syndicate medical equipment for you and your team.\
			Comes with a variety of first-aid kits, pill bottles, a compact defibrillator and 4 stimpacks."
	cost = 12
	contents = list(
		/obj/item/storage/firstaid/tactical = 2,	//8 TC
		/obj/item/storage/firstaid/brute = 2,
		/obj/item/storage/firstaid/fire = 2,
		/obj/item/storage/firstaid/toxin = 1,
		/obj/item/storage/firstaid/o2 = 1,
		/obj/item/storage/pill_bottle/mutadone = 1,
		/obj/item/storage/pill_bottle/neurine = 1,
		/obj/item/reagent_containers/hypospray/medipen/stimpack/traitor = 4
	)

/datum/uplink_item/bundles_TC/crate/shuttle
	name = "Stolen Shuttle Creation Kit"
	desc = "Every syndicate team needs their own shuttle. It's a shame you weren't supplied with one, but thats not a problem\
			if you can spare some TC! The all new shuttle creation kit (produced by the syndicate) contains everything you need\
			to get flying! All syndicate agents are advised to ignore the Nanotrasen labels on products. Space proof suits not included."
	cost = 15	//There are multiple uses for the RCD and plasma canister, but both are easilly accessible for items that cost less than all of their TC.
	contents = list(
		/obj/machinery/portable_atmospherics/canister/plasma = 1,
		/obj/item/construction/rcd/combat = 1,
		/obj/item/rcd_ammo/large = 2,
		/obj/item/shuttle_creator = 1,
		/obj/item/pipe_dispenser = 2,
		/obj/item/storage/toolbox/syndicate = 2,
		/obj/item/storage/toolbox/electrical = 1,
		/obj/item/circuitboard/computer/shuttle/flight_control = 1,
		/obj/item/circuitboard/machine/shuttle/engine/plasma = 2,
		/obj/item/circuitboard/machine/shuttle/heater = 2,
		/obj/item/storage/part_replacer/cargo = 1,
		/obj/item/electronics/apc = 1,
		/obj/item/wallframe/apc = 1
	)

// Dangerous Items
/datum/uplink_item/dangerous
	category = "Conspicuous Weapons"

/datum/uplink_item/dangerous/poisonknife
	name = "Poisoned Knife"
	desc = "A knife that is made of two razor sharp blades, it has a secret compartment in the handle to store liquids which are injected when stabbing something. Can hold up to forty units of reagents but comes empty."
	item = /obj/item/knife/poison
	cost = 6 // all in all it's not super stealthy and you have to get some chemicals yourself

/datum/uplink_item/dangerous/rawketlawnchair
	name = "84mm Rocket Propelled Grenade Launcher"
	desc = "A reusable rocket propelled grenade launcher preloaded with a low-yield 84mm HE round. \
		Guaranteed to send your target out with a bang or your money back!"
	item = /obj/item/gun/ballistic/rocketlauncher
	cost = 8
	surplus = 30
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/dangerous/grenadelauncher
	name = "Universal Grenade Launcher"
	desc = "A reusable grenade launcher. Has a capacity of 3 ammo but isn't preloaded. Works with grenades and several other types of explosives."
	item = /obj/item/gun/grenadelauncher
	cost = 6
	surplus = 30
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/dangerous/pie_cannon
	name = "Banana Cream Pie Cannon"
	desc = "A special pie cannon for a special clown, this gadget can hold up to 20 pies and automatically fabricates one every two seconds!"
	cost = 10
	item = /obj/item/pneumatic_cannon/pie/selfcharge
	surplus = 0
	purchasable_from = UPLINK_CLOWN_OPS

/datum/uplink_item/dangerous/bananashield
	name = "Bananium Energy Shield"
	desc = "A clown's most powerful defensive weapon, this personal shield provides near immunity to ranged energy attacks \
		by bouncing them back at the ones who fired them. It can also be thrown to bounce off of people, slipping them, \
		and returning to you even if you miss. WARNING: DO NOT ATTEMPT TO STAND ON SHIELD WHILE DEPLOYED, EVEN IF WEARING ANTI-SLIP SHOES."
	item = /obj/item/shield/energy/bananium
	cost = 16
	surplus = 0
	purchasable_from = UPLINK_CLOWN_OPS

/datum/uplink_item/dangerous/clownsword
	name = "Bananium Energy Sword"
	desc = "An energy sword that deals no damage, but will slip anyone it contacts, be it by melee attack, thrown \
	impact, or just stepping on it. Beware friendly fire, as even anti-slip shoes will not protect against it."
	item = /obj/item/melee/transforming/energy/sword/bananium
	cost = 3
	surplus = 0
	purchasable_from = UPLINK_CLOWN_OPS

/datum/uplink_item/dangerous/bioterror
	name = "Biohazardous Chemical Sprayer"
	desc = "A handheld chemical sprayer that allows a wide dispersal of selected chemicals. Especially tailored by the Tiger \
			Cooperative, the deadly blend it comes stocked with will disorient, damage, and disable your foes... \
			Use with extreme caution, to prevent exposure to yourself and your fellow operatives."
	item = /obj/item/reagent_containers/spray/chemsprayer/bioterror
	cost = 20
	surplus = 0
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/dangerous/throwingweapons
	name = "Box of Throwing Weapons"
	desc = "A box of shurikens and reinforced bolas from ancient Earth martial arts. They are highly effective \
			throwing weapons. The bolas can knock a target down and the shurikens will embed into limbs."
	item = /obj/item/storage/box/syndie_kit/throwing_weapons
	cost = 3

/datum/uplink_item/dangerous/shotgun
	name = "Bulldog Shotgun"
	desc = "A fully-loaded semi-automatic drum-fed shotgun. Compatible with all 12g rounds. Designed for close \
			quarter anti-personnel engagements."
	item = /obj/item/gun/ballistic/shotgun/automatic/bulldog
	cost = 8
	surplus = 40
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/dangerous/smg
	name = "C-20r Submachine Gun"
	desc = "A fully-loaded Scarborough Arms bullpup submachine gun. The C-20r fires .45 rounds with a \
			24-round magazine and is compatible with suppressors."
	item = /obj/item/gun/ballistic/automatic/c20r
	cost = 10
	surplus = 40
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/dangerous/superechainsaw
	name = "Super Energy Chainsaw"
	desc = "An incredibly deadly modified chainsaw with plasma-based energy blades instead of metal and a slick black-and-red finish. While it rips apart matter with extreme efficiency, it is heavy, large, and monstrously loud. It's blade has been enhanced to do even more damage and knock victims down briefly."
	item = /obj/item/chainsaw/energy/doom
	cost = 22
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/dangerous/doublesword
	name = "Double-Bladed Energy Sword"
	desc = "The double-bladed energy sword does slightly more damage than a standard energy sword and will deflect \
			all energy projectiles, but requires two hands to wield."
	item = /obj/item/dualsaber
	player_minimum = 25
	cost = 18
	purchasable_from = ~UPLINK_CLOWN_OPS

/datum/uplink_item/dangerous/doublesword/get_discount()
	return pick(4;0.8,2;0.65,1;0.5)

/datum/uplink_item/dangerous/sword
	name = "Energy Sword"
	desc = "The energy sword is an edged weapon with a blade of pure energy. The sword is small enough to be \
			pocketed when inactive. Activating it produces a loud, distinctive noise."
	item = /obj/item/melee/transforming/energy/sword/saber
	cost = 8
	purchasable_from = ~UPLINK_CLOWN_OPS

/datum/uplink_item/dangerous/shield
	name = "Energy Shield"
	desc = "An incredibly useful personal shield projector, capable of reflecting energy projectiles and defending \
			against other attacks. Pair with an Energy Sword for a killer combination."
	item = /obj/item/shield/energy
	cost = 16
	surplus = 20
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/dangerous/syndicate_teleporter
	name = "Experimental Syndicate Jaunter"
	desc = "The Syndicate jaunter is a handheld device that jaunts the user 4-8 meters forward. \
		Anyone caught in the wake of the jaunter will be knocked off their feet and receive minor damage. \
		Due to the Syndicate's more limited research of teleportation technologies, it is incapable of phasing the user \
		through solid matter nor is it capable of teleporting them across longer ranges."
	item = /obj/item/teleporter
	cost = 7

/datum/uplink_item/dangerous/flamethrower
	name = "Flamethrower"
	desc = "A flamethrower, fueled by a portion of highly flammable biotoxins stolen previously from Nanotrasen \
			stations. Make a statement by roasting the filth in their own greed. Use with caution."
	item = /obj/item/flamethrower/full/tank
	cost = 4
	surplus = 40
	purchasable_from = UPLINK_NUKE_OPS
	illegal_tech = FALSE
	contents_are_illegal_tech = FALSE

/datum/uplink_item/dangerous/rapid
	name = "Gloves of the North Star"
	desc = "These gloves let the user punch people very fast. Does not improve weapon attack speed or the meaty fists of a hulk."
	item = /obj/item/clothing/gloves/rapid
	cost = 8

/datum/uplink_item/dangerous/holoparasite
	name = "Holoparasites"
	desc = "Though capable of near sorcerous feats via use of hardlight holograms and nanomachines, they require an \
			organic host as a home base and source of fuel. Holoparasites come in various types and share damage with their host."
	item = /obj/item/holoparasite_creator/tech
	cost = 18
	surplus = 10
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	player_minimum = 25
	restricted = TRUE
	refundable = TRUE

/**
 * Only allow holoparasites to be refunded if the injector is unused.
 */
/datum/uplink_item/dangerous/holoparasite/can_be_refunded(obj/item/item, datum/component/uplink/uplink)
	if(!istype(item, /obj/item/holoparasite_creator/tech))
		return FALSE
	var/obj/item/holoparasite_creator/tech/holopara_creator = item
	return (holopara_creator.builder.uses == initial(holopara_creator.uses)) && !holopara_creator.builder.waiting

/datum/uplink_item/dangerous/machinegun
	name = "L6 Squad Automatic Weapon"
	desc = "A fully-loaded Aussec Armoury belt-fed machine gun. \
			This deadly weapon has a massive 50-round magazine of devastating 7.12x82mm ammunition."
	item = /obj/item/gun/ballistic/automatic/l6_saw
	cost = 18
	surplus = 0
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/dangerous/carbine
	name = "M-90gl Carbine"
	desc = "A fully-loaded, specialized three-round burst carbine that fires 5.56mm ammunition from a 30 round magazine \
			with a 40mm underbarrel grenade launcher. Use secondary-fire to fire the grenade launcher."
	item = /obj/item/gun/ballistic/automatic/m90
	cost = 14
	surplus = 50
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/dangerous/powerfist
	name = "Power Fist"
	desc = "The power-fist is a metal gauntlet with a built-in piston-ram powered by an external gas supply.\
			Upon hitting a target, the piston-ram will extend forward to make contact for some serious damage. \
			Using a wrench on the piston valve will allow you to tweak the amount of gas used per punch to \
			deal extra damage and hit targets further. Use a screwdriver to take out any attached tanks."
	item = /obj/item/melee/powerfist
	cost = 6

/datum/uplink_item/dangerous/sniper
	name = "Sniper Rifle"
	desc = "Ranged fury, Syndicate style. Guaranteed to cause shock and awe or your TC back!"
	item = /obj/item/gun/ballistic/sniper_rifle/syndicate
	cost = 16
	surplus = 25
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/dangerous/pistol
	name = "Stechkin Pistol"
	desc = "A small, easily concealable handgun that uses 10mm auto rounds in 8-round magazines and is compatible \
			with suppressors."
	item = /obj/item/gun/ballistic/automatic/pistol
	cost = 7
	purchasable_from = ~UPLINK_CLOWN_OPS

/datum/uplink_item/dangerous/pistolAPS
	name = "Stechkin APS"
	desc = "The original Russian version of a widely used Syndicate sidearm. Uses 9mm ammo, not compatible with suppressors."
	item = /obj/item/gun/ballistic/automatic/pistol/APS
	purchasable_from = UPLINK_NUKE_OPS
	cost = 6
	surplus = 0

/datum/uplink_item/dangerous/derringer
	name = "'Infiltrator' Coat Pistol"
	desc = "For the deeply embedded agent; a very compact dual-barreled handgun chambered with highly powerful .357 rounds. \
		It's small ammo capacity and difficult to obtain ammo make it poor at prolonged engagements, but it's saved the lives of \
		many agents that find themselves in sticky situations."
	item = /obj/item/storage/box/syndie_kit/derringer
	cost = 4
	purchasable_from = ~UPLINK_CLOWN_OPS

/datum/uplink_item/dangerous/bolt_action
	name = "Surplus Rifle"
	desc = "A horribly outdated bolt action weapon. You've got to be desperate to use this."
	item = /obj/item/gun/ballistic/rifle/boltaction
	cost = 2
	purchasable_from = UPLINK_NUKE_OPS
	illegal_tech = FALSE
	contents_are_illegal_tech = FALSE

/datum/uplink_item/dangerous/revolver
	name = "Syndicate Revolver"
	desc = "A brutally simple Syndicate revolver that fires .357 Magnum rounds and has 7 chambers."
	item = /obj/item/gun/ballistic/revolver
	player_minimum = 25
	cost = 12
	surplus = 50
	purchasable_from = ~UPLINK_CLOWN_OPS

/datum/uplink_item/dangerous/foamsmg
	name = "Toy Submachine Gun"
	desc = "A fully-loaded Donksoft bullpup submachine gun that fires riot grade darts with a 20-round magazine."
	item = /obj/item/gun/ballistic/automatic/c20r/toy
	cost = 5
	surplus = 0
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/dangerous/foammachinegun
	name = "Toy Machine Gun"
	desc = "A fully-loaded Donksoft belt-fed machine gun. This weapon has a massive 50-round magazine of devastating \
			riot grade darts, that can briefly incapacitate someone in just one volley."
	item = /obj/item/gun/ballistic/automatic/l6_saw/toy
	cost = 10
	surplus = 0
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/dangerous/foampistol
	name = "Toy Pistol with Riot Darts"
	desc = "An innocent-looking toy pistol designed to fire foam darts. Comes loaded with riot-grade \
			darts effective at incapacitating a target."
	item = /obj/item/gun/ballistic/automatic/toy/pistol/riot
	cost = 2
	surplus = 10

/datum/uplink_item/dangerous/semiautoturret
	name = "Semi-Auto Turret"
	desc = "An autoturret which shoots semi-automatic ballistic rounds. The turret is bulky \
			and cannot be moved; upon ordering this item, a smaller beacon will be transported to you \
			that will teleport the actual turret to it upon activation."
	item = /obj/item/sbeacondrop/semiautoturret
	cost = 8
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/dangerous/heavylaserturret
	name = "Heavy Laser Turret"
	desc = "An autoturret which shoots heavy lasers. The turret is bulky \
			and cannot be moved; upon ordering this item, a smaller beacon will be transported to you \
			that will teleport the actual turret to it upon activation."
	item = /obj/item/sbeacondrop/heavylaserturret
	cost = 12
	purchasable_from = UPLINK_NUKE_OPS


// Stealthy Weapons
/datum/uplink_item/stealthy_weapons
	category = "Stealthy Weapons"

/datum/uplink_item/stealthy_weapons/combatglovesplus
	name = "Combat Gloves Plus"
	desc = "A pair of gloves that are fireproof and shock resistant, however unlike the regular Combat Gloves this one uses nanotechnology \
			to learn the abilities of krav maga to the wearer."
	item = /obj/item/clothing/gloves/krav_maga/combatglovesplus
	cost = 5
	purchasable_from = UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS
	surplus = 0

/datum/uplink_item/stealthy_weapons/cqc
	name = "CQC Manual"
	desc = "A manual that teaches a single user tactical Close-Quarters Combat before self-destructing."
	item = /obj/item/book/granter/martial/cqc
	purchasable_from = UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS
	cost = 12
	surplus = 0

/datum/uplink_item/stealthy_weapons/art_of_thievery
	name = "The Art of Thievery"
	desc = "A manual that teaches a single user how to pickpocket people without them noticing. Not guaranteed to work on all targets."
	item = /obj/item/book/granter/art_of_thievery
	cost = 5
	surplus = 40

/datum/uplink_item/stealthy_weapons/dart_pistol
	name = "Dart Pistol"
	desc = "A miniaturized version of a normal syringe gun. It is very quiet when fired and can fit into any \
			space a small item can."
	item = /obj/item/gun/syringe/syndicate
	cost = 3
	surplus = 50

/datum/uplink_item/stealthy_weapons/dehy_carp
	name = "Dehydrated Space Carp"
	desc = "Looks like a plush toy carp, but just add water and it becomes a real-life space carp! Activate in \
			your hand before use so it knows not to kill you."
	item = /obj/item/toy/plush/carpplushie/dehy_carp
	cost = 1

/datum/uplink_item/stealthy_weapons/edagger
	name = "Energy Dagger"
	desc = "A dagger made of energy that looks and functions as a pen when off."
	item = /obj/item/pen/edagger
	cost = 3

/datum/uplink_item/stealthy_weapons/martialartskarate
	name = "Karate Scroll"
	desc = "This scroll contains the secrets of the ancient martial arts technique of Karate. You will learn \
			various ways to incapacitate and defeat downed foes."
	item = /obj/item/book/granter/martial/karate
	cost = 4
	surplus = 40

/datum/uplink_item/stealthy_weapons/martialarts
	name = "Martial Arts Scroll"
	desc = "This scroll contains the secrets of an ancient martial arts technique. You will master unarmed combat, \
			deflecting all ranged weapon fire, but you also refuse to use dishonorable ranged weaponry."
	item = /obj/item/book/granter/martial/carp
	cost = 16
	player_minimum = 20
	surplus = 10
	purchasable_from = ~(UPLINK_INCURSION | UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/stealthy_weapons/radbow
	name = "Gamma-Bow"
	desc = "The energy crossbow's newly developed lethal cousin. Has considerably increased lethality \
	at the cost of its disabling power. It will synthesize \
	and fire bolts tipped with dangerous toxins that will disorient and \
	irradiate targets. It can produce an infinite number of bolts \
	which automatically recharge roughly 25 seconds after each shot."
	item = /obj/item/gun/energy/recharge/ebow/radbow
	cost = 8
	surplus = 50

/datum/uplink_item/stealthy_weapons/crossbow
	name = "Miniature Energy Crossbow"
	desc = "A short bow mounted across a tiller in miniature. \
	Small enough to fit into a pocket or slip into a bag unnoticed. \
	It will synthesize and fire bolts tipped with a disabling \
	toxin that will damage and disorient targets, causing them to \
	slur as if inebriated. It can produce an infinite number \
	of bolts, but takes a small amount of time to automatically recharge after each shot."
	item = /obj/item/gun/energy/recharge/ebow
	cost = 12
	surplus = 50
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)


/datum/uplink_item/stealthy_weapons/origami_kit
	name = "Boxed Origami Kit"
	desc = "This box contains a guide on how to craft masterful works of origami, allowing you to transform normal pieces of paper into \
			perfectly aerodynamic (and potentially lethal) paper airplanes."
	item = /obj/item/storage/box/syndie_kit/origami_bundle
	cost = 6
	surplus = 20
	purchasable_from = ~UPLINK_NUKE_OPS

/datum/uplink_item/stealthy_weapons/traitor_chem_bottle
	name = "Poison Kit"
	desc = "An assortment of deadly chemicals packed into a compact box. Comes with a syringe for more precise application."
	item = /obj/item/storage/box/syndie_kit/chemical
	cost = 7
	surplus = 50

/datum/uplink_item/stealthy_weapons/romerol_kit
	name = "Romerol"
	desc = "A highly experimental bioterror agent which creates dormant nodules to be etched into the grey matter of the brain. \
			On death, these nodules take control of the dead body, causing limited revivification, \
			along with slurred speech, aggression, and the ability to infect others with this agent."
	item = /obj/item/storage/box/syndie_kit/romerol
	cost = 20
	cant_discount = TRUE
	murderbone_type = TRUE
	surplus = 0

/datum/uplink_item/stealthy_weapons/sleepy_pen
	name = "Sleepy Pen"
	desc = "A spring loaded, single-use syringe disguised as a functional pen, filled with a potent mix of drugs, including a \
			strong anesthetic and a chemical that prevents the target from speaking. \
			The mixture that the pen comes with can be replaced as long as the pen hasn't been used already. Note that the mechanism takes time to \
			trigger, is obvious to anyone nearby (excluding the target) and the victim may still be able to move and act for a brief period of time before falling unconcious."
	item = /obj/item/pen/sleepy
	cost = 5
	purchasable_from = ~UPLINK_NUKE_OPS

/datum/uplink_item/stealthy_weapons/suppressor
	name = "Suppressor"
	desc = "This suppressor will silence the shots of the weapon it is attached to for increased stealth and superior ambushing capability. It is compatible with many small ballistic guns including the Stechkin and C-20r, but not revolvers or energy guns."
	item = /obj/item/suppressor
	cost = 2
	surplus = 10
	purchasable_from = ~UPLINK_CLOWN_OPS

// Ammunition
/datum/uplink_item/ammo
	category = "Ammunition"
	surplus = 40

/datum/uplink_item/ammo/pistol
	name = "10mm Handgun Magazine"
	desc = "An additional 8-round 10mm magazine; compatible with the Stechkin Pistol."
	item = /obj/item/ammo_box/magazine/m10mm
	cost = 1
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE
	contents_are_illegal_tech = FALSE

/datum/uplink_item/ammo/pistolap
	name = "10mm Armour Piercing Magazine"
	desc = "An additional 8-round 10mm magazine; compatible with the Stechkin Pistol. \
			These rounds are less effective at injuring the target but penetrate protective gear."
	item = /obj/item/ammo_box/magazine/m10mm/ap
	cost = 2
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE
	contents_are_illegal_tech = FALSE

/datum/uplink_item/ammo/pistolhp
	name = "10mm Hollow Point Magazine"
	desc = "An additional 8-round 10mm magazine; compatible with the Stechkin Pistol. \
			These rounds are more damaging but ineffective against armour."
	item = /obj/item/ammo_box/magazine/m10mm/hp
	cost = 3
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE
	contents_are_illegal_tech = FALSE

/datum/uplink_item/ammo/pistolfire
	name = "10mm Incendiary Magazine"
	desc = "An additional 8-round 10mm magazine; compatible with the Stechkin Pistol. \
			Loaded with incendiary rounds which inflict little damage, but ignite the target."
	item = /obj/item/ammo_box/magazine/m10mm/fire
	cost = 2
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE
	contents_are_illegal_tech = FALSE

/datum/uplink_item/ammo/pistolaps
	name = "9mm Handgun Magazine"
	desc = "An additional 15-round 9mm magazine, compatible with the Stechkin APS pistol, found in the Spetsnaz Pyro bundle."
	item = /obj/item/ammo_box/magazine/pistolm9mm
	cost = 2
	purchasable_from = UPLINK_NUKE_OPS
	illegal_tech = FALSE
	contents_are_illegal_tech = FALSE

/datum/uplink_item/ammo/pistolaps/inc
	name = "9mm Incendiary Handgun Magazine"
	desc = "An additional 15-round 9mm Incendiary magazine, compatible with the Stechkin APS pistol."
	item = /obj/item/ammo_box/magazine/pistolm9mm/inc
	cost = 2
	purchasable_from = UPLINK_NUKE_OPS
	illegal_tech = FALSE
	contents_are_illegal_tech = FALSE

/datum/uplink_item/ammo/pistolaps/ap
	name = "9mm AP Handgun Magazine"
	desc = "An additional 15-round 9mm AP magazine, compatible with the Stechkin APS pistol."
	item = /obj/item/ammo_box/magazine/pistolm9mm/ap
	cost = 2
	purchasable_from = UPLINK_NUKE_OPS
	illegal_tech = FALSE
	contents_are_illegal_tech = FALSE

/datum/uplink_item/ammo/pistolaps/hp
	name = "9mm HP Handgun Magazine"
	desc = "An additional 15-round 9mm HP magazine, compatible with the Stechkin APS pistol."
	item = /obj/item/ammo_box/magazine/pistolm9mm/hp
	cost = 3
	purchasable_from = UPLINK_NUKE_OPS
	illegal_tech = FALSE
	contents_are_illegal_tech = FALSE

/datum/uplink_item/ammo/shotgun
	cost = 2
	purchasable_from = UPLINK_NUKE_OPS
	illegal_tech = FALSE
	contents_are_illegal_tech = FALSE

/datum/uplink_item/ammo/shotgun/bag
	name = "12g Ammo Duffel Bag"
	desc = "A duffel bag filled with enough 12g ammo to supply an entire team, at a discounted price."
	item = /obj/item/storage/backpack/duffelbag/syndie/ammo/shotgun
	cost = 14

/datum/uplink_item/ammo/shotgun/buck
	name = "12g Buckshot Drum"
	desc = "An additional 8-round buckshot magazine for use with the Bulldog shotgun. Front towards enemy."
	item = /obj/item/ammo_box/magazine/m12g

/datum/uplink_item/ammo/shotgun/dragon
	name = "12g Dragon's Breath Drum"
	desc = "An alternative 8-round dragon's breath magazine for use in the Bulldog shotgun. \
			'I'm a fire starter, twisted fire starter!'"
	item = /obj/item/ammo_box/magazine/m12g/dragon
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/ammo/shotgun/meteor
	name = "12g Meteorslug Shells"
	desc = "An alternative 8-round meteorslug magazine for use in the Bulldog shotgun. \
			Great for blasting airlocks off their frames and knocking down enemies."
	item = /obj/item/ammo_box/magazine/m12g/meteor
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/ammo/shotgun/slug
	name = "12g Slug Drum"
	desc = "An additional 8-round slug magazine for use with the Bulldog shotgun. \
			Now 8 times less likely to shoot your pals."
	cost = 3
	item = /obj/item/ammo_box/magazine/m12g/slug

/datum/uplink_item/ammo/shotgun/breacher
	name = "12g Breaching Slugs Drum"
	desc = "An alternative 8-round breaching slug magazine for use with the Bulldog shotgun. \
			Great for quickly destroying light barricades such as airlocks and windows."
	item = /obj/item/ammo_box/magazine/m12g/breacher

/datum/uplink_item/ammo/revolver
	name = ".357 Speed Loader"
	desc = "A speed loader that contains seven additional .357 Magnum rounds; usable with the Syndicate revolver. \
			For when you really need a lot of things dead."
	item = /obj/item/ammo_box/a357
	player_minimum = 25
	cost = 2
	purchasable_from = ~UPLINK_CLOWN_OPS
	illegal_tech = FALSE
	contents_are_illegal_tech = FALSE

/datum/uplink_item/ammo/a40mm
	name = "40mm Grenade Box"
	desc = "A box of 40mm HE grenades for use with the M-90gl's under-barrel grenade launcher. \
			Your teammates will ask you to not shoot these down small hallways."
	item = /obj/item/ammo_box/a40mm
	cost = 6
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/ammo/smg/bag
	name = ".45 Ammo Duffel Bag"
	desc = "A duffel bag filled with enough .45 ammo to supply an entire team, at a discounted price."
	item = /obj/item/storage/backpack/duffelbag/syndie/ammo/smg
	cost = 22 //instead of 27 TC
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/ammo/smg
	name = ".45 SMG Magazine"
	desc = "An additional 24-round .45 magazine suitable for use with the C-20r submachine gun."
	item = /obj/item/ammo_box/magazine/smgm45
	cost = 3
	purchasable_from = UPLINK_NUKE_OPS
	illegal_tech = FALSE
	contents_are_illegal_tech = FALSE

/datum/uplink_item/ammo/sniper
	purchasable_from = UPLINK_NUKE_OPS
	illegal_tech = FALSE
	contents_are_illegal_tech = FALSE

/datum/uplink_item/ammo/sniper/magazine
	name = ".50 Magazine"
	desc = "An additional standard 6-round magazine for use with .50 sniper rifles. Bullets are not included."
	item = /obj/item/ammo_box/magazine/sniper_rounds/empty
	cost = 2

/datum/uplink_item/ammo/sniper/basic
	name = ".50 Rounds"
	desc = "An ammo box containing 6 highly powerful .50 caliber projectiles which can be inserted into .50 magazines to be used in a sniper rifle."
	item = /obj/item/ammo_box/sniper
	cost = 2

/datum/uplink_item/ammo/sniper/penetrator
	name = ".50 Penetrator Rounds"
	desc = "2 rounds of penetrator ammo designed for use with .50 sniper rifles. \
			Can pierce walls and multiple enemies."
	item = /obj/item/ammo_box/sniper/penetrator
	cost = 2

/datum/uplink_item/ammo/sniper/soporific
	name = ".50 Soporific Rounds"
	desc = "2 rounds of .50 cal soporific bullets, for use in a sniper rifle's magazine. Put your enemies to sleep today!"
	item = /obj/item/ammo_box/sniper/soporific
	cost = 3

/datum/uplink_item/ammo/sniper/emp
	name = ".50 Emp Shell"
	desc = "A single EMP shell for the sniper rifle. Upon impact will release an EMP which disables nearby electronics \
		temporarilly."
	item = /obj/item/ammo_casing/p50/emp
	cost = 1

/datum/uplink_item/ammo/sniper/explosive
	name = ".50 Explosive Shell"
	desc = "An explosive shell for the sniper rifle, upon impact will create a small explosion which damages nearby targets."
	item = /obj/item/ammo_casing/p50/explosive
	cost = 3

/datum/uplink_item/ammo/sniper/inferno
	name = ".50 Inferno Shell"
	desc = "A shell for the sniper rifle with a highly volatile flammable core. Upon impact will release a fireball which consumes anything nearby."
	item = /obj/item/ammo_casing/p50/inferno
	cost = 2

/datum/uplink_item/ammo/sniper/antimatter
	name = ".50 Antimatter-tipped Shell"
	desc = "An antimatter-tipped sniper rifle shell. Upon impact the antimatter core will collapse, releasing the energy contained within. Handle with extreme care."
	item = /obj/item/ammo_casing/p50/antimatter
	cost = 14

/datum/uplink_item/ammo/carbine
	name = "5.56mm Toploader Magazine"
	desc = "An additional 30-round 5.56mm magazine; suitable for use with the M-90gl carbine. \
			These bullets pack less punch than 7.12x82mm rounds, but they still offer more power than .45 ammo."
	item = /obj/item/ammo_box/magazine/m556
	cost = 3
	purchasable_from = UPLINK_NUKE_OPS
	illegal_tech = FALSE
	contents_are_illegal_tech = FALSE

/datum/uplink_item/ammo/machinegun
	cost = 6
	surplus = 0
	purchasable_from = UPLINK_NUKE_OPS
	illegal_tech = FALSE
	contents_are_illegal_tech = FALSE

/datum/uplink_item/ammo/machinegun/basic
	name = "7.12x82mm Box Magazine"
	desc = "A 50-round magazine of 7.12x82mm ammunition for use with the L6 SAW. \
			By the time you need to use this, you'll already be standing on a pile of corpses."
	item = /obj/item/ammo_box/magazine/mm712x82

/datum/uplink_item/ammo/machinegun/ap
	name = "7.12x82mm (Armor Penetrating) Box Magazine"
	desc = "A 50-round magazine of 7.12x82mm ammunition for use in the L6 SAW; equipped with special properties \
			to puncture even the most durable armor."
	item = /obj/item/ammo_box/magazine/mm712x82/ap
	cost = 9

/datum/uplink_item/ammo/machinegun/hollow
	name = "7.12x82mm (Hollow-Point) Box Magazine"
	desc = "A 50-round magazine of 7.12x82mm ammunition for use in the L6 SAW; equipped with hollow-point tips to help \
			with the unarmored masses of crew."
	item = /obj/item/ammo_box/magazine/mm712x82/hollow

/datum/uplink_item/ammo/machinegun/incen
	name = "7.12x82mm (Incendiary) Box Magazine"
	desc = "A 50-round magazine of 7.12x82mm ammunition for use in the L6 SAW; tipped with a special flammable \
			mixture that'll ignite anyone struck by the bullet. Some men just want to watch the world burn."
	item = /obj/item/ammo_box/magazine/mm712x82/incen

/datum/uplink_item/ammo/machinegun/match
	name = "7.12x82mm (Match) Box Magazine"
	desc = "A 50-round magazine of 7.12x82mm ammunition for use in the L6 SAW; you didn't know there was a demand for match grade \
			precision bullet hose ammo, but these rounds are finely tuned and perfect for ricocheting off walls all fancy-like."
	item = /obj/item/ammo_box/magazine/mm712x82/match
	cost = 10

/datum/uplink_item/ammo/rocket
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/ammo/rocket/basic
	name = "84mm HE Rocket"
	desc = "A low-yield anti-personnel HE rocket. Gonna take you out in style!"
	item = /obj/item/ammo_casing/caseless/rocket
	cost = 3

/datum/uplink_item/ammo/rocket/hedp
	name = "84mm HEDP Rocket"
	desc = "A high-yield HEDP rocket; extremely effective against armored targets, as well as surrounding personnel. \
			Strike fear into the hearts of your enemies."
	item = /obj/item/ammo_casing/caseless/rocket/hedp
	cost = 5

/datum/uplink_item/ammo/toydarts
	name = "Box of Riot Darts"
	desc = "A box of 40 Donksoft riot darts, for reloading any compatible foam dart magazine. Don't forget to share!"
	item = /obj/item/ammo_box/foambox/riot
	cost = 2
	surplus = 0
	illegal_tech = FALSE
	contents_are_illegal_tech = FALSE

/datum/uplink_item/ammo/bioterror
	name = "Box of Bioterror Syringes"
	desc = "A box full of preloaded syringes, containing various chemicals that seize up the victim's motor \
			and broca systems, making it impossible for them to move or speak for some time."
	item = /obj/item/storage/box/syndie_kit/bioterror
	cost = 6
	purchasable_from = UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS

/datum/uplink_item/ammo/bolt_action
	name = "Surplus Rifle Clip"
	desc = "A stripper clip used to quickly load bolt action rifles. Contains 5 rounds."
	item = 	/obj/item/ammo_box/a762
	cost = 1
	purchasable_from = UPLINK_NUKE_OPS
	illegal_tech = FALSE
	contents_are_illegal_tech = FALSE

/datum/uplink_item/ammo/dark_gygax/bag
	name = "Dark Gygax Ammo Bag"
	desc = "A duffel bag containing ammo for three full reloads of the incendiary carbine and flash bang launcher that are equipped on a standard Dark Gygax exosuit."
	item = /obj/item/storage/backpack/duffelbag/syndie/ammo/dark_gygax
	cost = 4
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/ammo/mauler/bag
	name = "Mauler Ammo Bag"
	desc = "A duffel bag containing ammo for three full reloads of the LMG, scattershot carbine, and SRM-8 missile laucher that are equipped on a standard Mauler exosuit."
	item = /obj/item/storage/backpack/duffelbag/syndie/ammo/mauler
	cost = 6
	purchasable_from = UPLINK_NUKE_OPS

//Grenades and Explosives
/datum/uplink_item/explosives
	category = "Explosives"

/datum/uplink_item/explosives/bioterrorfoam
	name = "Bioterror Foam Grenade"
	desc = "A powerful chemical foam grenade which creates a deadly torrent of foam that will mute, blind, confuse, \
			mutate, and irritate carbon lifeforms. Specially brewed by Tiger Cooperative chemical weapons specialists \
			using additional spore toxin. Ensure suit is sealed before use."
	item = /obj/item/grenade/chem_grenade/bioterrorfoam
	cost = 7
	surplus = 35
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/explosives/bombanana
	name = "Bombanana"
	desc = "A banana with an explosive taste! discard the peel quickly, as it will explode with the force of a Syndicate minibomb \
		a few seconds after the banana is eaten."
	item = /obj/item/food/grown/banana/bombanana
	cost = 4 //it is a bit cheaper than a minibomb because you have to take off your helmet to eat it, which is how you arm it
	surplus = 0
	purchasable_from = UPLINK_CLOWN_OPS

/datum/uplink_item/explosives/buzzkill
	name = "Buzzkill Grenade Box"
	desc = "A box with three grenades that release a swarm of angry bees upon activation. These bees indiscriminately attack friend or foe \
			with random toxins. Courtesy of the BLF and Tiger Cooperative."
	item = /obj/item/storage/box/syndie_kit/bee_grenades
	cost = 16
	surplus = 35
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/explosives/c4
	name = "Composition C-4"
	desc = "C-4 is plastic explosive of the common variety Composition C. You can use it to breach walls, sabotage equipment, or connect \
			an assembly to it in order to alter the way it detonates. It can be attached to almost all objects and has a modifiable timer with a \
			minimum setting of 10 seconds."
	item = /obj/item/grenade/plastic/c4
	cost = 1

/datum/uplink_item/explosives/c4bag
	name = "Bag of C-4 explosives"
	desc = "Because sometimes quantity is quality. Contains 10 C-4 plastic explosives."
	item = /obj/item/storage/backpack/duffelbag/syndie/c4
	cost = 8 //20% discount!
	cant_discount = TRUE

/datum/uplink_item/explosives/x4bag
	name = "Bag of X-4 explosives"
	desc = "Contains 3 X-4 shaped plastic explosives. Similar to C4, but with a stronger blast that is directional instead of circular. \
			X-4 can be placed on a solid surface, such as a wall or window, and it will blast through the wall, injuring anything on the opposite side, while being safer to the user. \
			For when you want a controlled explosion that leaves a wider, deeper, hole."
	item = /obj/item/storage/backpack/duffelbag/syndie/x4
	cost = 4 //
	cant_discount = TRUE

/datum/uplink_item/explosives/clown_bomb_clownops
	name = "Clown Bomb"
	desc = "The Clown bomb is a hilarious device capable of massive pranks. It has an adjustable timer, \
			with a minimum of 60 seconds, and can be bolted to the floor with a wrench to prevent \
			movement. The bomb is bulky and cannot be moved; upon ordering this item, a smaller beacon will be \
			transported to you that will teleport the actual bomb to it upon activation. Note that this bomb can \
			be defused, and some crew may attempt to do so."
	item = /obj/item/sbeacondrop/clownbomb
	cost = 15
	surplus = 0
	purchasable_from = UPLINK_CLOWN_OPS

/datum/uplink_item/explosives/detomatix
	name = "Detomatix PDA Disk"
	desc = "When inserted into a personal digital assistant, this disk gives you four opportunities to \
			detonate PDAs of crewmembers who have their message feature enabled. \
			The concussive effect from the explosion will knock the recipient out for a short period, and deafen them for longer."
	item = /obj/item/computer_hardware/hard_drive/role/virus/syndicate
	cost = 6
	restricted = TRUE

/datum/uplink_item/explosives/emp
	name = "EMP Grenades and Implanter Kit"
	desc = "A box that contains five EMP grenades and an EMP implant with three uses. Useful to disrupt communications, \
			security's energy weapons and silicon lifeforms when you're in a tight spot."
	item = /obj/item/storage/box/syndie_kit/emp
	cost = 4

/datum/uplink_item/explosives/ducky
	name = "Exploding Rubber Duck"
	desc = "A seemingly innocent rubber duck. When placed, it arms, and will violently explode when stepped on."
	item = /obj/item/deployablemine/traitor
	cost = 4

/datum/uplink_item/explosives/doorCharge
	name = "Airlock Charge"
	desc = "A small explosive device that can be used to sabotage airlocks to cause an explosion upon opening. \
			To apply, remove the airlock's maintenance panel and place it within."
	item = /obj/item/doorCharge
	cost = 4

/datum/uplink_item/explosives/virus_grenade
	name = "Fungal Tuberculosis Grenade"
	desc = "A primed bio-grenade packed into a compact box. Comes with five Bio Virus Antidote Kit (BVAK) \
			autoinjectors for rapid application on up to two targets each, a syringe, and a bottle containing \
			the BVAK solution."
	item = /obj/item/storage/box/syndie_kit/tuberculosisgrenade
	cost = 14
	surplus = 35
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	restricted = TRUE

/datum/uplink_item/explosives/grenadier
	name = "Grenadier's belt"
	desc = "A belt containing 26 lethally dangerous and destructive grenades. Comes with an extra multitool and screwdriver."
	item = /obj/item/storage/belt/grenade/full
	purchasable_from = UPLINK_NUKE_OPS
	cost = 24
	surplus = 0

/datum/uplink_item/explosives/bigducky
	name = "High Yield Exploding Rubber Duck"
	desc = "A seemingly innocent rubber duck. When placed, it arms, and will violently explode when stepped on. \
			This variant has been fitted with high yield X4 charges for a larger explosion."
	item = /obj/item/deployablemine/traitor/bigboom
	cost = 10

/datum/uplink_item/explosives/pizza_bomb
	name = "Pizza Bomb"
	desc = "A pizza box with a bomb cunningly attached to the lid. The timer needs to be set by opening the box; afterwards, \
			opening the box again will trigger the detonation after the timer has elapsed. Comes with free pizza, for you or your target!"
	item = /obj/item/pizzabox/bomb
	cost = 3
	surplus = 8

/datum/uplink_item/explosives/soap_clusterbang
	name = "Slipocalypse Clusterbang"
	desc = "A traditional clusterbang grenade with a payload consisting entirely of Syndicate soap. Useful in any scenario!"
	item = /obj/item/grenade/clusterbuster/soap
	cost = 4

/datum/uplink_item/explosives/syndicate_bomb
	name = "Syndicate Bomb"
	desc = "The Syndicate bomb is a fearsome device capable of massive destruction. It has an adjustable timer, \
			with a minimum of 60 seconds, and can be bolted to the floor with a wrench to prevent \
			movement. The bomb is bulky and cannot be moved; upon ordering this item, a smaller beacon will be \
			transported to you that will teleport the actual bomb to it upon activation. Note that this bomb can \
			be defused, and some crew may attempt to do so. \
			The bomb core can be pried out and manually detonated with other explosives."
	item = /obj/item/sbeacondrop/bomb
	cost = 12

/datum/uplink_item/explosives/syndicate_detonator
	name = "Syndicate Detonator"
	desc = "The Syndicate detonator is a companion device to the Syndicate bomb. Simply press the included button \
			and an encrypted radio frequency will instruct all live Syndicate bombs to detonate. \
			Useful for when speed matters or you wish to synchronize multiple bomb blasts. Be sure to stand clear of \
			the blast radius before using the detonator."
	item = /obj/item/syndicatedetonator
	cost = 1
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/explosives/syndicate_minibomb
	name = "Syndicate Minibomb"
	desc = "The minibomb is a grenade with a five-second fuse. Upon detonation, it will create a small hull breach \
			in addition to dealing high amounts of damage to nearby personnel."
	item = /obj/item/grenade/syndieminibomb
	cost = 4
	purchasable_from = ~UPLINK_CLOWN_OPS

/datum/uplink_item/explosives/tearstache
	name = "Teachstache Grenade"
	desc = "A teargas grenade that launches sticky moustaches onto the face of anyone not wearing a clown or mime mask. The moustaches will \
		remain attached to the face of all targets for one minute, preventing the use of breath masks and other such devices."
	item = /obj/item/grenade/chem_grenade/teargas/moustache
	cost = 3
	surplus = 0
	purchasable_from = UPLINK_CLOWN_OPS

/datum/uplink_item/explosives/viscerators
	name = "Viscerator Delivery Grenade"
	desc = "A unique grenade that deploys a swarm of viscerators upon activation, which will chase down and shred \
			any non-operatives in the area."
	item = /obj/item/grenade/spawnergrenade/manhacks
	cost = 6
	surplus = 35
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/explosives/explosive_flashbulbs
	name = "Explosive Flash"
	desc = "A flash with a bulb stuffed with explosives that when used by an oblivious security officers, will cause a violent explosion."
	item = /obj/item/assembly/flash/bomb
	cost = 1
	surplus = 8

//Support and Mechs
/datum/uplink_item/support
	category = "Support and Exosuits"
	surplus = 0
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/support/clown_reinforcement
	name = "Clown Reinforcements"
	desc = "Call in an additional clown to share the fun, equipped with full starting gear, but no telecrystals."
	item = /obj/item/antag_spawner/nuke_ops/clown
	cost = 18
	purchasable_from = UPLINK_CLOWN_OPS
	restricted = TRUE

/datum/uplink_item/support/reinforcement
	name = "Reinforcements"
	desc = "Call in an additional team member. They won't come with any gear, so you'll have to save some telecrystals \
			to arm them as well."
	item = /obj/item/antag_spawner/nuke_ops
	cost = 24
	refundable = TRUE
	purchasable_from = UPLINK_NUKE_OPS
	restricted = TRUE

/datum/uplink_item/support/reinforcement/assault_borg
	name = "Syndicate Assault Cyborg"
	desc = "A cyborg designed and programmed for systematic extermination of non-Syndicate personnel. \
			Comes equipped with a self-resupplying LMG, a grenade launcher, energy sword, emag, pinpointer, flash and crowbar."
	item = /obj/item/antag_spawner/nuke_ops/borg_tele/assault
	refundable = TRUE
	cost = 64
	restricted = TRUE

/datum/uplink_item/support/reinforcement/medical_borg
	name = "Syndicate Medical Cyborg"
	desc = "A combat medical cyborg. Has limited offensive potential, but makes more than up for it with its support capabilities. \
			It comes equipped with a nanite hypospray, a medical beamgun, combat defibrillator, full surgical kit including an energy saw, an emag, pinpointer and flash. \
			Thanks to its organ storage bag, it can perform surgery as well as any humanoid."
	item = /obj/item/antag_spawner/nuke_ops/borg_tele/medical
	refundable = TRUE
	cost = 32
	restricted = TRUE

/datum/uplink_item/support/reinforcement/saboteur_borg
	name = "Syndicate Saboteur Cyborg"
	desc = "A streamlined engineering cyborg, equipped with covert modules. Also incapable of leaving the welder in the shuttle. \
			Aside from regular Engineering equipment, it comes with a special destination tagger that lets it traverse disposals networks. \
			Its chameleon projector lets it disguise itself as a Nanotrasen cyborg, on top it has thermal vision and a pinpointer."
	item = /obj/item/antag_spawner/nuke_ops/borg_tele/saboteur
	refundable = TRUE
	cost = 32
	restricted = TRUE

/datum/uplink_item/support/gygax
	name = "Dark Gygax Exosuit"
	desc = "A lightweight exosuit, painted in a dark scheme. Its speed and equipment selection make it excellent \
			for hit-and-run style attacks. Features an incendiary carbine, flash bang launcher, teleporter, ion thrusters and a Tesla energy array."
	item = /obj/vehicle/sealed/mecha/combat/gygax/dark/loaded
	cost = 80

/datum/uplink_item/support/honker
	name = "Dark H.O.N.K."
	desc = "A clown combat mech equipped with bombanana peel and tearstache grenade launchers, as well as the ubiquitous HoNkER BlAsT 5000."
	item = /obj/vehicle/sealed/mecha/combat/honker/dark/loaded
	cost = 80
	purchasable_from = UPLINK_CLOWN_OPS

/datum/uplink_item/support/mauler
	name = "Mauler Exosuit"
	desc = "A massive and incredibly deadly military-grade exosuit. Features long-range targeting, thrust vectoring \
			and deployable smoke. Comes equipped with an LMG, scattershot carbine, missile rack, an antiprojectile armor booster and a Tesla energy array."
	item = /obj/vehicle/sealed/mecha/combat/marauder/mauler/loaded
	cost = 140

// Stealth Items
/datum/uplink_item/stealthy_tools
	category = "Stealth Gadgets"

/datum/uplink_item/stealthy_tools/agent_card
	name = "Agent Identification Card"
	desc = "Agent cards prevent artificial intelligences from tracking the wearer, and can copy access \
			from other identification cards. The access is cumulative, so scanning one card does not erase the \
			access gained from another. In addition, they can be forged to display a new assignment and name. \
			This can be done an unlimited amount of times. Some Syndicate areas and devices can only be accessed \
			with these cards."
	item = /obj/item/card/id/syndicate
	cost = 2

/datum/uplink_item/stealthy_tools/ai_detector
	name = "Artificial Intelligence Detector"
	desc = "A functional multitool that turns red when it detects an artificial intelligence watching it, and can be \
			activated to display their exact viewing location and nearby security camera blind spots. Knowing when \
			an artificial intelligence is watching you is useful for knowing when to maintain cover, and finding nearby \
			blind spots can help you identify escape routes."
	item = /obj/item/multitool/ai_detect
	cost = 1

/datum/uplink_item/stealthy_tools/chameleon
	name = "Chameleon Kit"
	desc = "A set of items that contain chameleon technology allowing you to disguise as pretty much anything on the station, and more! \
			Due to budget cuts, the shoes don't provide protection against slipping."
	item = /obj/item/storage/box/syndie_kit/chameleon
	cost = 2
	purchasable_from = ~UPLINK_NUKE_OPS

/datum/uplink_item/stealthy_tools/chameleon_proj
	name = "Chameleon Projector"
	desc = "Projects an image across a user, disguising them as an object scanned with it, as long as they don't \
			move the projector from their hand. Disguised users move slowly, and projectiles pass over them."
	item = /obj/item/chameleon
	cost = 7

/datum/uplink_item/stealthy_tools/codespeak_manual
	name = "Codespeak Manual"
	desc = "Syndicate agents can be trained to use a series of codewords to convey complex information, which sounds like random concepts and drinks to anyone listening. \
			This manual teaches you this Codespeak. You can also hit someone else with the manual in order to teach them. This is the deluxe edition, which has unlimited uses."
	item = /obj/item/codespeak_manual/unlimited
	cost = 2

/datum/uplink_item/stealthy_tools/combatbananashoes
	name = "Combat Banana Shoes"
	desc = "While making the wearer immune to most slipping attacks like regular combat clown shoes, these shoes \
		can generate a large number of synthetic banana peels as the wearer walks, slipping up would-be pursuers. They also \
		squeak significantly louder."
	item = /obj/item/clothing/shoes/clown_shoes/banana_shoes/combat
	cost = 8
	surplus = 0
	purchasable_from = UPLINK_CLOWN_OPS

/datum/uplink_item/stealthy_tools/taeclowndo_shoes
	name = "Tae-clown-do Shoes"
	desc = "A pair of shoes for the most elite agents of the honkmotherland. They grant the mastery of taeclowndo with some honk-fu moves as long as they're worn."
	cost = 12
	item = /obj/item/clothing/shoes/clown_shoes/taeclowndo
	purchasable_from = UPLINK_CLOWN_OPS

/datum/uplink_item/stealthy_tools/emplight
	name = "EMP Flashlight"
	desc = "A small, self-recharging, short-ranged EMP device disguised as a working flashlight. \
			Useful for disrupting headsets, cameras, doors, lockers and borgs during stealth operations. \
			Attacking a target with this flashlight will direct an EM pulse at it and consumes a charge."
	item = /obj/item/flashlight/emp
	cost = 3
	surplus = 30

/datum/uplink_item/stealthy_tools/mulligan
	name = "Mulligan"
	desc = "Screwed up and have security on your tail? This handy syringe will give you a completely new identity \
			and appearance."
	item = /obj/item/reagent_containers/syringe/mulligan
	cost = 3
	surplus = 30
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/stealthy_tools/syndigaloshes
	name = "No-Slip Chameleon Shoes"
	desc = "These shoes will allow the wearer to run on wet floors and slippery objects without falling down. \
			They do not work on heavily lubricated surfaces."
	item = /obj/item/clothing/shoes/chameleon/noslip
	cost = 3
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/stealthy_tools/syndigaloshes/nuke
	item = /obj/item/clothing/shoes/chameleon/noslip
	cost = 4
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/stealthy_tools/chambowman
	name = "Chameleon Bangproof Headset"
	desc = "A headset reinforced to protect the ears from flashbangs, enhanced with chameleon disguise technology."
	item = /obj/item/radio/headset/chameleon/bowman
	cost = 2

/datum/uplink_item/stealthy_tools/chamweldinggoggles
	name = "Chameleon Flashproof Glasses"
	desc = "A pair of glasses reinforced to protect the eyes from welding flashes, enhanced with chameleon disguise technology."
	item = /obj/item/clothing/glasses/chameleon/flashproof
	cost = 2

/datum/uplink_item/stealthy_tools/chaminsuls
	name = "Chameleon Combat Gloves"
	desc = "A pair of gloves reinforced with fire and shock resistance, enhanced with chameleon disguise technology."
	item = /obj/item/clothing/gloves/chameleon/combat
	cost = 1

/datum/uplink_item/stealthy_tools/jammer
	name = "Signal Jammer"
	desc = "This device will disrupt any nearby outgoing wireless signals when activated."
	item = /obj/item/jammer
	cost = 5

/datum/uplink_item/stealthy_tools/smugglersatchel
	name = "Smuggler's Satchel"
	desc = "This satchel is thin enough to be hidden in the gap between plating and tiling; great for stashing \
			your stolen goods. Comes with a crowbar, a floor tile and some contraband inside."
	item = /obj/item/storage/backpack/satchel/flat/with_tools
	cost = 1
	surplus = 30
	illegal_tech = FALSE

//Space Suits and Hardsuits
/datum/uplink_item/suits
	category = "Space Suits"
	surplus = 40

/datum/uplink_item/suits/space_suit
	name = "Syndicate Space Suit"
	desc = "This red and black Syndicate space suit is less encumbering than Nanotrasen variants, \
			fits inside bags, and has a weapon slot. Nanotrasen crew members are trained to report red space suit \
			sightings, however."
	item = /obj/item/storage/box/syndie_kit/space
	cost = 3

/datum/uplink_item/suits/hardsuit
	name = "Syndicate Hardsuit"
	desc = "The feared suit of a Syndicate nuclear agent. Features slightly better armoring, a built in jetpack \
			that runs off standard atmospheric tanks and an advanced team location system. Toggling the suit in and out of \
			combat mode will allow you all the mobility of a loose fitting uniform without sacrificing armoring. \
			Additionally the suit is collapsible, making it small enough to fit within a backpack. \
			Nanotrasen crew who spot these suits are known to panic."
	item = /obj/item/clothing/suit/space/hardsuit/syndi
	cost = 7
	purchasable_from = ~UPLINK_NUKE_OPS //you can't buy it in nuke, because the elite hardsuit costs the same while being better

/datum/uplink_item/suits/hardsuit/spawn_item(spawn_path, mob/user, datum/component/uplink/U)
	var/obj/item/clothing/suit/space/hardsuit/suit = ..()
	var/datum/component/tracking_beacon/beacon = suit.GetComponent(/datum/component/tracking_beacon)
	var/datum/component/team_monitor/worn/hud = suit.helmet.GetComponent(/datum/component/team_monitor/worn)

	var/datum/antagonist/nukeop/nukie = is_nuclear_operative(user)
	if(nukie?.nuke_team?.team_frequency)
		if(hud)
			hud.set_frequency(nukie.nuke_team.team_frequency)
		if(beacon)
			beacon.set_frequency(nukie.nuke_team.team_frequency)
	return suit

/datum/uplink_item/suits/hardsuit/elite
	name = "Elite Syndicate Hardsuit"
	desc = "An upgraded, elite version of the Syndicate hardsuit. It features fireproofing, and also \
			provides the user with superior armor and mobility compared to the standard Syndicate hardsuit."
	item = /obj/item/clothing/suit/space/hardsuit/syndi/elite
	cost = 8
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/suits/hardsuit/shielded
	name = "Shielded Syndicate Hardsuit"
	desc = "An upgraded version of the standard Syndicate hardsuit. It features a built-in energy shielding system. \
			The shields can handle up to three impacts within a short duration and will rapidly recharge while not under fire."
	item = /obj/item/clothing/suit/space/hardsuit/shielded/syndi
	cost = 30
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

// Devices and Tools
/datum/uplink_item/device_tools
	category = "Misc. Gadgets"

/datum/uplink_item/device_tools/cutouts
	name = "Adaptive Cardboard Cutouts"
	desc = "These cardboard cutouts are coated with a thin material that prevents discoloration and makes the images on them appear more lifelike. \
			This pack contains three as well as a crayon for changing their appearances."
	item = /obj/item/storage/box/syndie_kit/cutouts
	cost = 1
	surplus = 20

/datum/uplink_item/device_tools/assault_pod
	name = "Assault Pod Targeting Device"
	desc = "Use this to select the landing zone of your assault pod."
	item = /obj/item/assault_pod
	cost = 30
	surplus = 0
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	restricted = TRUE

/datum/uplink_item/device_tools/binary
	name = "Binary Translator Key"
	desc = "A key that, when inserted into a radio headset, allows you to listen to and talk with silicon-based lifeforms, \
			such as AI units and cyborgs, over their private binary channel. Caution should \
			be taken while doing this, as unless they are allied with you, they are programmed to report such intrusions."
	item = /obj/item/encryptionkey/binary
	cost = 4
	surplus = 75
	restricted = TRUE

/datum/uplink_item/device_tools/compressionkit
	name = "Bluespace Compression Kit"
	desc = "A modified version of a BSRPED that can be used to reduce the size of most items while retaining their original functions! \
			Does not work on storage items. \
			Recharge using bluespace crystals. \
			Comes with 5 charges."
	item = /obj/item/compressionkit
	cost = 5

/datum/uplink_item/device_tools/shuttlecapsule
	name = "Bluespace Shuttle Capsule"
	desc = "Need a mobile base of operations? Those pesky exploration crews keep flying off? Want to do a hit and run on security? Then this \
			product is for you! The all new bluespace shuttle capsule contains an ENTIRE shuttle withing a capsule you can hold in your hand! \
			The shuttle provided is a state-of-the-art ship complete with a hacked autolathe, syndicate toolbox, playing cards for those long journeys, \
			an in-built shuttle interdictor and a single canister of plasma to fuel your adventures! \
			This innovative shuttle can seat up to 4 passengers, willing or not! Shuttle must be deployed in space or on lavaland, space suits not included."
	item = /obj/item/survivalcapsule/shuttle/traitor
	cost = 8
	purchasable_from = (UPLINK_INCURSION | UPLINK_TRAITORS)

/datum/uplink_item/device_tools/magboots
	name = "Blood-Red Magboots"
	desc = "A pair of magnetic boots with a Syndicate paintjob that assist with freer movement in space or on-station \
			during gravitational generator failures. These reverse-engineered knockoffs of Nanotrasen's \
			'Advanced Magboots' slow you down in simulated-gravity environments much like the standard issue variety."
	item = /obj/item/clothing/shoes/magboots/syndie
	cost = 2
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/device_tools/brainwash_disk
	name = "Brainwashing Surgery Program"
	desc = "A disk containing the procedure to perform a brainwashing surgery, allowing you to implant an objective onto a target. \
	Insert into an Operating Console to enable the procedure."
	item = /obj/item/disk/surgery/brainwashing
	player_minimum = 10
	cost = 5

/datum/uplink_item/device_tools/briefcase_launchpad
	name = "Briefcase Launchpad"
	desc = "A briefcase containing a launchpad, a device able to teleport items and people to and from targets up to eight tiles away from the briefcase. \
			Also includes a remote control, disguised as an ordinary folder. Touch the briefcase with the remote to link it."
	surplus = 30
	item = /obj/item/storage/briefcase/launchpad
	cost = 5

/datum/uplink_item/device_tools/camera_bug
	name = "Camera Bug"
	desc = "Enables you to view all cameras on the main network, set up motion alerts and track a target. \
			Bugging cameras allows you to disable them remotely."
	item = /obj/item/camera_bug
	cost = 1

/datum/uplink_item/device_tools/military_belt
	name = "Chest Rig"
	desc = "A robust seven-slot set of webbing that is capable of holding all manner of tactical equipment."
	item = /obj/item/storage/belt/military
	cost = 1

/datum/uplink_item/device_tools/emag
	name = "Cryptographic Sequencer"
	desc = "The cryptographic sequencer, electromagnetic card, or emag, is a small card that unlocks hidden functions \
			in electronic devices, subverts intended functions, and easily breaks security mechanisms."
	item = /obj/item/card/emag
	cost = 6

/datum/uplink_item/device_tools/fakenucleardisk
	name = "Decoy Nuclear Authentication Disk"
	desc = "It's just a normal disk. Visually it's identical to the real deal, but it won't hold up under closer scrutiny by the Captain. \
			Don't try to give this to us to complete your objective, we know better!"
	item = /obj/item/disk/nuclear/fake
	cost = 1
	surplus = 1
	illegal_tech = FALSE


/datum/uplink_item/device_tools/frame
	name = "F.R.A.M.E. PDA Disk"
	desc = "When inserted into a personal digital assistant, this disk gives you five PDA viruses which \
			when used cause the targeted PDA to become a new uplink with zero TCs, and immediately become unlocked. \
			You will receive the unlock code upon activating the virus, and the new uplink may be charged with \
			telecrystals normally."
	item = /obj/item/computer_hardware/hard_drive/role/virus/frame
	cost = 4
	restricted = TRUE

/datum/uplink_item/device_tools/failsafe
	name = "Failsafe Uplink Code"
	desc = "When entered the uplink will self-destruct immediately."
	item = /obj/effect/gibspawner/generic
	cost = 1
	surplus = 0
	restricted = TRUE
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/device_tools/failsafe/spawn_item(spawn_path, mob/user, datum/component/uplink/U)
	if(!U || !U.unlock_code)
		to_chat(user, span_warning("A failsafe code could not be assigned to this uplink."))
		return
	do
		U.failsafe_code = U.generate_code()
	while(islist(U.failsafe_code) ? compare_list(U.failsafe_code, U.unlock_code) : U.failsafe_code == U.unlock_code)
	var/code = "[islist(U.failsafe_code) ? english_list(U.failsafe_code) : U.failsafe_code]"
	to_chat(user, span_warning("The new failsafe code for this uplink is now : [code]."))
	if(user.mind)
		user.mind.store_memory("Failsafe code for [U.parent] : [code]")
	return U.parent //For log icon

/datum/uplink_item/device_tools/toolbox
	name = "Full Syndicate Toolbox"
	desc = "The Syndicate toolbox is a suspicious black and red. It comes loaded with a full tool set including a \
			multitool and combat gloves that are resistant to shocks and heat."
	item = /obj/item/storage/toolbox/syndicate
	cost = 1
	illegal_tech = FALSE

/datum/uplink_item/device_tools/syndie_glue
	name = "Glue"
	desc = "A cheap bottle of one use syndicate brand super glue. \
			Use on any item to make it undroppable. \
			When applied, will stick the item in either thirty seconds or instantly upon dropping or picking it up. \
			Be careful not to glue an item you're already holding!"
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	item = /obj/item/syndie_glue
	cost = 2

/datum/uplink_item/device_tools/hacked_module
	name = "Hacked AI Law Upload Module"
	desc = "When used with an upload console, this module allows you to upload priority laws to an artificial intelligence. \
			Be careful with wording, as artificial intelligences may look for loopholes to exploit."
	item = /obj/item/aiModule/syndicate
	cost = 3

/datum/uplink_item/device_tools/hypnotic_flash
	name = "Hypnotic Flash"
	desc = "A modified flash able to hypnotize targets. If the target is not in a mentally vulnerable state, it will only confuse and pacify them temporarily."
	item = /obj/item/assembly/flash/hypnotic
	player_minimum = 20
	cost = 7

/datum/uplink_item/device_tools/medgun
	name = "Medbeam Gun"
	desc = "A wonder of Syndicate engineering, the Medbeam gun, or Medi-Gun enables a medic to keep his fellow \
			operatives in the fight, even while under fire. Don't cross the streams!"
	item = /obj/item/gun/medbeam
	cost = 14
	purchasable_from = UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS

/datum/uplink_item/device_tools/singularity_beacon
	name = "Power Beacon"
	desc = "When screwed to wiring attached to an electric grid and activated, this large device pulls any \
			active gravitational singularities or tesla balls towards it. This will not work when the engine is still \
			in containment. Because of its size, it cannot be carried. Ordering this \
			sends you a small beacon that will teleport the larger beacon to your location upon activation."
	item = /obj/item/sbeacondrop
	cost = 10

/datum/uplink_item/device_tools/powersink
	name = "Power Sink"
	desc = "When screwed to wiring attached to a power grid and activated, this large device lights up and places excessive \
			load on the grid, causing a station-wide blackout. The sink is large and cannot be stored in most \
			traditional bags and boxes. Caution: Will explode if the powernet contains sufficient amounts of energy."
	item = /obj/item/powersink
	cost = 10
	player_minimum = 35

/datum/uplink_item/device_tools/stimpack
	name = "Stimpack"
	desc = "Stimpacks, the tool for many great heroes, make you mostly immune to any form of slowdown (including damage slowdown) \
			or stamina damage for about 5 minutes after injection."
	item = /obj/item/reagent_containers/hypospray/medipen/stimulants
	cost = 5
	surplus = 90

/datum/uplink_item/device_tools/medkit
	name = "Syndicate Combat Medic Kit"
	desc = "This first aid kit is a suspicious brown and red. Included is a combat stimulant injector \
			for rapid healing, a medical night vision HUD for quick identification of injured personnel, \
			and other supplies helpful for a field medic."
	item = /obj/item/storage/firstaid/tactical
	cost = 4
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/device_tools/medkit_infiltration
	name = "Syndicate Infiltrator's Medical Kit"
	desc = "This first aid kit, filled with supplies stolen from Nanotrasen forces, is intended to be \
			used by infiltrators on enemy stations. It contains some basic first-aid tools for self-treatment \
			in dire situations. Fits in your bag, but is visually obvious as non-Nanotrasen."
	item = /obj/item/storage/firstaid/infiltrator
	cost = 2

/datum/uplink_item/device_tools/soap
	name = "Syndicate Soap"
	desc = "A sinister-looking surfactant used to clean blood stains to hide murders and prevent DNA analysis. \
			You can also drop it underfoot to slip people."
	item = /obj/item/soap/syndie
	cost = 1
	surplus = 50
	illegal_tech = FALSE

/datum/uplink_item/device_tools/surgerybag
	name = "Syndicate Surgery Duffel Bag"
	desc = "The Syndicate surgery duffel bag is a toolkit containing all surgery tools, surgical drapes, \
			a Syndicate brand MMI, a straitjacket, and a muzzle."
	item = /obj/item/storage/backpack/duffelbag/syndie/surgery
	cost = 3

/datum/uplink_item/device_tools/encryptionkey
	name = "Syndicate Encryption Key"
	desc = "A key that, when inserted into a radio headset, allows you to listen to all station department channels \
			as well as talk on an encrypted Syndicate channel with other agents that have the same key."
	item = /obj/item/encryptionkey/syndicate
	cost = 2
	surplus = 75
	purchasable_from = ~(UPLINK_INCURSION | UPLINK_EXCOMMUNICATE)
	restricted = TRUE

/datum/uplink_item/device_tools/syndietome
	name = "Syndicate Tome"
	desc = "Using rare artifacts acquired at great cost, the Syndicate has reverse engineered \
			the seemingly magical books of a certain cult. Though lacking the esoteric abilities \
			of the originals, these inferior copies are still quite useful, being able to provide \
			both weal and woe on the battlefield, even if they do occasionally bite off a finger."
	item = /obj/item/storage/book/bible/syndicate
	cost = 3

/datum/uplink_item/device_tools/potion
	name = "Syndicate Sentience Potion"
	item = /obj/item/slimepotion/slime/sentience/nuclear
	desc = "A potion recovered at great risk by undercover Syndicate operatives and then subsequently modified with Syndicate technology. \
			Using it will make any animal sentient, and bound to serve you, as well as implanting an internal radio for communication and an internal ID card for opening doors."
	cost = 4
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	restricted = TRUE

/datum/uplink_item/device_tools/suspiciousphone
	name = "Protocol CRAB-17 Phone"
	desc = "The Protocol CRAB-17 Phone, a phone borrowed from an unknown third party, it can be used to crash the space market, funneling the losses of the crew to your bank account.\
	The crew can move their funds to a new banking site though, unless they HODL, in which case they deserve it."
	item = /obj/item/suspiciousphone
	restricted = TRUE
	cost = 8

/datum/uplink_item/device_tools/thermal
	name = "Thermal Imaging Glasses"
	desc = "These goggles can be turned to resemble common eyewear found throughout the station. \
			They allow you to see organisms through walls by capturing the upper portion of the infrared light spectrum, \
			emitted as heat and light by objects. Hotter objects, such as warm bodies, cybernetic organisms \
			and artificial intelligence cores emit more of this light than cooler objects like walls and airlocks."
	item = /obj/item/clothing/glasses/thermal/syndi
	cost = 2


/datum/uplink_item/device_tools/guerrillagloves
	name = "Guerrilla Gloves"
	desc = "A pair of highly robust combat gripper gloves that excels at performing takedowns at close range, with an added lining of insulation. Careful not to hit a wall!"
	item = /obj/item/clothing/gloves/tackler/combat/insulated
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	cost = 2

// Implants
/datum/uplink_item/implants
	category = "Implants"
	surplus = 50

/datum/uplink_item/implants/adrenal
	name = "Adrenal Implant"
	desc = "An implant injected into the body, and later activated at the user's will. It will inject a chemical \
			cocktail which removes all incapacitating effects, lets the user run faster and has a mild healing effect."
	item = /obj/item/storage/box/syndie_kit/imp_adrenal
	cost = 8
	player_minimum = 20

/datum/uplink_item/implants/antistun
	name = "CNS Rebooter Implant"
	desc = "This implant will help you get back up on your feet faster after being stunned. Comes with an autosurgeon."
	item = /obj/item/autosurgeon/syndicate/anti_stun
	cost = 12
	surplus = 0
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/implants/freedom
	name = "Freedom Implant"
	desc = "An implant injected into the body and later activated at the user's will. It will attempt to free the \
			user from common restraints such as handcuffs."
	item = /obj/item/storage/box/syndie_kit/imp_freedom
	cost = 4

/datum/uplink_item/implants/microbomb
	name = "Microbomb Implant"
	desc = "An implant injected into the body, and later activated either manually or automatically upon death. \
			The more implants inside of you, the higher the explosive power. \
			This will permanently destroy your body, however."
	item = /obj/item/storage/box/syndie_kit/imp_microbomb
	cost = 3
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/implants/macrobomb
	name = "Macrobomb Implant"
	desc = "An implant injected into the body, and later activated either manually or automatically upon death. \
			Upon death, releases a massive explosion that will wipe out everything nearby."
	item = /obj/item/storage/box/syndie_kit/imp_macrobomb
	cost = 20
	purchasable_from = UPLINK_NUKE_OPS
	restricted = TRUE

/datum/uplink_item/implants/radio
	name = "Internal Syndicate Radio Implant"
	desc = "An implant injected into the body, allowing the use of an internal Syndicate radio. \
			Used just like a regular headset, but can be disabled to use external headsets normally and to avoid detection."
	item = /obj/item/storage/box/syndie_kit/imp_radio
	cost = 4
	purchasable_from = ~(UPLINK_INCURSION | UPLINK_EXCOMMUNICATE) //To prevent traitors from immediately outing the hunters to security.
	restricted = TRUE

/datum/uplink_item/implants/reviver
	name = "Reviver Implant"
	desc = "This implant will attempt to revive and heal you if you lose consciousness. Comes with an autosurgeon."
	item = /obj/item/autosurgeon/syndicate/reviver
	cost = 7
	surplus = 0
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/implants/stealthimplant
	name = "Stealth Implant"
	desc = "This one-of-a-kind implant will make you almost invisible if you play your cards right. \
			On activation, it will conceal you inside a chameleon cardboard box that is only revealed once someone bumps into it."
	item = /obj/item/storage/box/syndie_kit/imp_stealth
	cost = 7

/datum/uplink_item/implants/storage
	name = "Storage Implant"
	desc = "An implant injected into the body, and later activated at the user's will. It will open a small bluespace \
			pocket capable of storing two regular-sized items."
	item = /obj/item/storage/box/syndie_kit/imp_storage
	cost = 7

/datum/uplink_item/implants/thermals
	name = "Thermal Eyes"
	desc = "These cybernetic eyes will give you thermal vision. Comes with a free autosurgeon."
	item = /obj/item/autosurgeon/syndicate/thermal_eyes
	cost = 7
	surplus = 0
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/implants/uplink
	name = "Uplink Implant"
	desc = "An implant injected into the body, and later activated at the user's will. Has no telecrystals and must be charged by the use of physical telecrystals. \
			Undetectable (except via surgery), and excellent for escaping confinement."
	item = /obj/item/storage/box/syndie_kit // the actual uplink implant is generated later on in spawn_item
	cost = UPLINK_IMPLANT_TELECRYSTAL_COST
	// An empty uplink is kinda useless.
	surplus = 0
	restricted = TRUE

/datum/uplink_item/implants/uplink/spawn_item(spawn_path, mob/user, datum/component/uplink/purchaser_uplink)
	var/obj/item/storage/box/syndie_kit/uplink_box = ..()
	uplink_box.name = "Uplink Implant Box"
	new /obj/item/implanter/uplink(uplink_box, purchaser_uplink.uplink_flag)
	return uplink_box


/datum/uplink_item/implants/xray
	name = "X-ray Vision Implant"
	desc = "These cybernetic eyes will give you X-ray vision. Comes with an autosurgeon."
	item = /obj/item/autosurgeon/syndicate/xray_eyes
	cost = 9
	surplus = 0
	purchasable_from = UPLINK_NUKE_OPS


//Race-specific items
/datum/uplink_item/race_restricted
	category = "Species-Restricted"
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	surplus = 0

/datum/uplink_item/race_restricted/syndilamp
	name = "Extra-Bright Lantern"
	desc = "We heard that moths such as yourself really like lamps, so we decided to grant you early access to a prototype \
	Syndicate brand \"Extra-Bright Lantern™\". Enjoy."
	cost = 2
	item = /obj/item/flashlight/lantern/syndicate
	restricted_species = list(SPECIES_MOTH)

/datum/uplink_item/race_restricted/ethereal_grenade
	name = "Ethereal Dance Grenade"
	desc = "Syndicate scientists have cunningly stuffed the bodies of multiple Ethereals into a special package! Activating it will cause anyone nearby to dance, excluding Ethereals, who might just get offended."
	cost = 4
	item = /obj/item/grenade/discogrenade
	restricted_species = list(SPECIES_ETHEREAL)

/datum/uplink_item/race_restricted/plasmachameleon
	name = "Plasmaman Chameleon Kit"
	desc = "A set of items that contain chameleon technology allowing you to disguise as pretty much anything on the station, and more! \
			Due to budget cuts, the shoes don't provide protection against slipping. The normal bells and whistles of a plasmaman's jumpsuit and helmet are gutted to make room for the chameleon machinery."
	item = /obj/item/storage/box/syndie_kit/plasmachameleon
	cost = 2
	restricted_species = list(SPECIES_PLASMAMAN)

/datum/uplink_item/race_restricted/tribal_claw
	name = "Old Tribal Scroll"
	desc = "We found this scroll in a abandoned lizard settlement of the Knoises clan. \
			It teaches you how to use your claws and tail to gain an advantage in combat, \
			don't buy this unless you are a lizard or plan to give it to one as only they can understand the ancient draconic words."
	item = /obj/item/book/granter/martial/tribal_claw
	cost = 6
	surplus = 0
	restricted_species = list(SPECIES_LIZARD)

// Role-specific items
/datum/uplink_item/role_restricted
	category = "Role-Restricted"
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	surplus = 0

/datum/uplink_item/role_restricted/ancient_jumpsuit
	name = "Ancient Jumpsuit"
	desc = "A tattered old jumpsuit that will provide absolutely no benefit to you. It fills the wearer with a strange compulsion to blurt out 'glorf'."
	item = /obj/item/clothing/under/color/grey/glorf
	cost = 20
	restricted_roles = list(JOB_NAME_ASSISTANT)
	surplus = 1

/datum/uplink_item/role_restricted/oldtoolboxclean
	name = "Ancient Toolbox"
	desc = "An iconic toolbox design notorious with Assistants everywhere, this design was especially made to become more robust the more telecrystals it has inside it! Tools and insulated gloves included."
	item = /obj/item/storage/toolbox/mechanical/old/clean
	cost = 2
	restricted_roles = list(JOB_NAME_ASSISTANT)
	surplus = 0

/datum/uplink_item/role_restricted/pie_cannon
	name = "Banana Cream Pie Cannon"
	desc = "A special pie cannon for a special clown, this gadget can hold up to 20 pies and automatically fabricates one every two seconds!"
	cost = 11
	item = /obj/item/pneumatic_cannon/pie/selfcharge
	restricted_roles = list(JOB_NAME_CLOWN)
	surplus = 0 //No fun unless you're the clown!

/datum/uplink_item/role_restricted/blastcannon
	name = "Blast Cannon"
	desc = "A highly specialized weapon, the Blast Cannon is actually relatively simple. It contains an attachment for a tank transfer valve mounted to an angled pipe specially constructed \
			withstand extreme pressure and temperatures, and has a mechanical trigger for triggering the transfer valve. Essentially, it turns the explosive force of a bomb into a narrow-angle \
			blast wave \"projectile\". Aspiring scientists may find this highly useful, as forcing the pressure shockwave into a narrow angle seems to be able to bypass whatever quirk of physics \
			disallows explosive ranges above a certain distance, allowing for the device to use the theoretical yield of a transfer valve bomb, instead of the factual yield."
	item = /obj/item/gun/blastcannon
	cost = 14							//High cost because of the potential for extreme damage in the hands of a skilled scientist.
	restricted_roles = list(JOB_NAME_RESEARCHDIRECTOR, JOB_NAME_SCIENTIST)
	disabled = TRUE // ! #11288 - Reported as non-functional

/datum/uplink_item/role_restricted/crushmagboots
	name = "Crushing Magboots"
	desc = "A pair of extra-strength magboots that crush anyone you walk over."
	cost = 7
	item = /obj/item/clothing/shoes/magboots/crushing
	restricted_roles = list(JOB_NAME_CHIEFENGINEER, JOB_NAME_STATIONENGINEER, JOB_NAME_ATMOSPHERICTECHNICIAN)

/datum/uplink_item/role_restricted/gorillacubes
	name = "Box of Gorilla Cubes"
	desc = "A box with three Waffle Co. brand gorilla cubes. Eat big to get big. \
			Caution: Product may rehydrate when exposed to water."
	item = /obj/item/storage/box/gorillacubes
	cost = 6
	restricted_roles = list(JOB_NAME_GENETICIST, JOB_NAME_CHIEFMEDICALOFFICER)

/datum/uplink_item/role_restricted/rad_laser
	name = "Radioactive Microlaser"
	desc = "A radioactive microlaser disguised as a standard Nanotrasen health analyzer. When used, it emits a \
			powerful burst of radiation, which, after a short delay, can incapacitate all but the most protected \
			of humanoids. It has two settings: intensity, which controls the power of the radiation, \
			and wavelength, which controls the delay before the effect kicks in."
	item = /obj/item/healthanalyzer/rad_laser
	restricted_roles = list(JOB_NAME_MEDICALDOCTOR, JOB_NAME_CHIEFMEDICALOFFICER, JOB_NAME_ROBOTICIST, JOB_NAME_PARAMEDIC, JOB_NAME_BRIGPHYSICIAN)
	cost = 3

/datum/uplink_item/role_restricted/syndicate_mmi
	name = "Syndicate MMI"
	desc = "An MMI which autmatically applies the Syndimov laws to any borg it is placed in. Great for adding known allies to assist you with a little more stealth than a fully emagged borg."
	item = /obj/item/mmi/syndie
	restricted_roles = list(JOB_NAME_ROBOTICIST, JOB_NAME_RESEARCHDIRECTOR)
	cost = 2

/datum/uplink_item/role_restricted/upgrade_wand
	name = "Upgrade Wand"
	desc = "A powerful, single-use wand containing nanomachines that will calibrate the high-tech gadgets commonly employed by magicians to nearly double their potential."
	item = /obj/item/upgradewand
	restricted_roles = list(JOB_NAME_STAGEMAGICIAN)
	cost = 5

/datum/uplink_item/role_restricted/floorpill_bottle
	name = "Bottle of Mystery Pills"
	desc = "We found these lying around Warehouse R1O-GN, which was decommissioned years ago. We were going to throw them out but we heard you might be interested in them."
	item = /obj/item/storage/pill_bottle/floorpill/full
	restricted_roles = list(JOB_NAME_ASSISTANT)
	cost = 2
	illegal_tech = FALSE
	contents_are_illegal_tech = FALSE

/datum/uplink_item/role_restricted/clown_bomb
	name = "Clown Bomb"
	desc = "The Clown bomb is a hilarious device capable of massive pranks. It has an adjustable timer, \
			with a minimum of 60 seconds, and can be bolted to the floor with a wrench to prevent \
			movement. The bomb is bulky and cannot be moved; upon ordering this item, a smaller beacon will be \
			transported to you that will teleport the actual bomb to it upon activation. Note that this bomb can \
			be defused, and some crew may attempt to do so."
	item = /obj/item/sbeacondrop/clownbomb
	cost = 10
	restricted_roles = list(JOB_NAME_CLOWN)

/datum/uplink_item/role_restricted/clown_grenade
	name = "C.L.U.W.N.E"
	desc = "The C.L.U.W.N.E will create one of the honkmother's own completely randomly!\
			It will only attack if attacked first, and is not loyal to you, so be careful!"
	item = /obj/item/grenade/spawnergrenade/clown
	cost = 3
	restricted_roles = list(JOB_NAME_CLOWN)


/datum/uplink_item/role_restricted/clown_grenade_broken
	name = "Stuffed C.L.U.W.N.E"
	desc = "The C.L.U.W.N.E will create one of the honkmother's own completely randomly!\
			It will only attack if attacked first, and is not loyal to you, so be careful!\
			This one is stuffed to the brim with extra clown action! use with caution!"
	item = /obj/item/grenade/spawnergrenade/clown_broken
	cost = 5
	restricted_roles = list(JOB_NAME_CLOWN)

/datum/uplink_item/role_restricted/clowncar
	name = "Clown Car"
	desc = "The Clown Car is the ultimate transportation method for any worthy clown! \
			Simply insert your bikehorn and get in, and get ready to have the funniest ride of your life! \
			You can ram any spacemen you come across and stuff them into your car, kidnapping them and locking them inside until \
			someone saves them or they manage to crawl out. Be sure not to ram into any walls or vending machines, as the springloaded seats \
			are very sensitive. Now with our included lube defense mechanism which will protect you against any angry shitcurity! \
			Premium features can be unlocked with a cryptographic sequencer!"
	item = /obj/vehicle/sealed/car/clowncar
	cost = 20
	restricted_roles = list(JOB_NAME_CLOWN)
	purchasable_from = ~UPLINK_INCURSION

/datum/uplink_item/role_restricted/taeclowndo_shoes
	name = "Tae-clown-do Shoes"
	desc = "A pair of shoes for the most elite agents of the honkmotherland. They grant the mastery of taeclowndo with some honk-fu moves as long as they're worn."
	cost = 12
	item = /obj/item/clothing/shoes/clown_shoes/taeclowndo
	restricted_roles = list(JOB_NAME_CLOWN)

/datum/uplink_item/role_restricted/bananashield
	name = "Bananium Energy Shield"
	desc = "A clown's most powerful defensive weapon, this personal shield provides near immunity to ranged energy attacks \
		by bouncing them back at the ones who fired them. It can also be thrown to bounce off of people, slipping them, \
		and returning to you even if you miss. WARNING: DO NOT ATTEMPT TO STAND ON SHIELD WHILE DEPLOYED, EVEN IF WEARING ANTI-SLIP SHOES."
	item = /obj/item/shield/energy/bananium
	cost = 15
	surplus = 0
	restricted_roles = list(JOB_NAME_CLOWN)

/datum/uplink_item/role_restricted/clownsword
	name = "Bananium Energy Sword"
	desc = "An energy sword that deals no damage, but will slip anyone it contacts, be it by melee attack, thrown \
	impact, or just stepping on it. Beware friendly fire, as even anti-slip shoes will not protect against it."
	item = /obj/item/melee/transforming/energy/sword/bananium
	cost = 5
	surplus = 0
	restricted_roles = list(JOB_NAME_CLOWN)

/datum/uplink_item/role_restricted/superior_honkrender
	name = "Superior Honkrender"
	desc = "An ancient artifact recovered from an ancient cave. Opens the way to the Dark Carnival"
	item = /obj/item/veilrender/honkrender
	cost = 8
	restricted = TRUE
	restricted_roles = list(JOB_NAME_CLOWN, JOB_NAME_CHAPLAIN)

/datum/uplink_item/role_restricted/superior_honkrender
	name = "Superior Honkrender"
	desc = "An ancient artifact recovered from -. Opens the way to TRANSMISSION OFFLINE\
			All praise be to the honkmother"
	item = /obj/item/veilrender/honkrender/honkhulkrender
	cost = 20
	restricted = TRUE
	restricted_roles = list(JOB_NAME_CLOWN, JOB_NAME_CHAPLAIN)

/datum/uplink_item/role_restricted/concealed_weapon_bay
	name = "Concealed Weapon Bay"
	desc = "A modification for non-combat mechas that allows them to equip one piece of equipment designed for combat mechs. \
			It also hides the equipped weapon from plain sight. \
			Only one can fit on a mecha."
	item = /obj/item/mecha_parts/concealed_weapon_bay
	cost = 3
	restricted_roles = list(JOB_NAME_ROBOTICIST, JOB_NAME_RESEARCHDIRECTOR)

/datum/uplink_item/role_restricted/haunted_magic_eightball
	name = "Haunted Magic Eightball"
	desc = "Most magic eightballs are toys with dice inside. Although identical in appearance to the harmless toys, this occult device reaches into the spirit world to find its answers. \
			Be warned, that spirits are often capricious or just little assholes. To use, simply speak your question aloud, then begin shaking."
	item = /obj/item/toy/eightball/haunted
	cost = 2
	restricted_roles = list(JOB_NAME_CURATOR)
	limited_stock = 1 //please don't spam deadchat

/datum/uplink_item/role_restricted/voodoo
	name = "Wicker Doll"
	desc = "A wicker voodoo doll with a cavity for storing a small item. Once an item has been stored within it, the doll may be used to manipulate the actions of another person that has previously been in contact with the stored item."
	item = /obj/item/voodoo
	cost = 12
	restricted_roles = list(JOB_NAME_CURATOR, JOB_NAME_STAGEMAGICIAN)

/datum/uplink_item/role_restricted/prison_cube
	name = "Prison Cube"
	desc = "A very strange artifact recovered from a volcanic planet that is useful for keeping people locked away, but not very useful for keeping their disappearance unknown"
	item = /obj/item/prisoncube
	cost = 6
	restricted_roles = list(JOB_NAME_CURATOR)

/datum/uplink_item/role_restricted/his_grace
	name = "His Grace"
	desc = "An incredibly dangerous weapon recovered from a station overcome by the grey tide. Once activated, He will thirst for blood and must be used to kill to sate that thirst. \
	His Grace grants gradual regeneration and complete stun immunity to His wielder, but be wary: if He gets too hungry, He will become impossible to drop and eventually kill you if not fed. \
	However, if left alone for long enough, He will fall back to slumber. \
	To activate His Grace, simply unlatch Him."
	item = /obj/item/his_grace
	cost = 20
	restricted_roles = list(JOB_NAME_CHAPLAIN)
	murderbone_type = TRUE
	surplus = 0

/datum/uplink_item/role_restricted/cultconstructkit
	name = "Cult Construct Kit"
	desc = "Recovered from an abandoned Nar'sie cult lair two construct shells and a stash of empty soulstones was found. These were purified to prevent occult contamination and have been put in a belt so they may be used as an accessible source of disposable minions. The construct shells have been packaged into two beacons for rapid and portable deployment."
	item = /obj/item/storage/box/syndie_kit/cultconstructkit
	cost = 20
	restricted_roles = list(JOB_NAME_CHAPLAIN)

/datum/uplink_item/role_restricted/spanish_flu
	name = "Spanish Flu Culture"
	desc = "A bottle of cursed blood, full of angry spirits which will burn all the heretics with the fires of hell. \
			At least, that's what the label says"
	item = /obj/item/reagent_containers/cup/bottle/fluspanish
	cost = 12
	restricted_roles = list(JOB_NAME_CHAPLAIN, JOB_NAME_VIROLOGIST)

/datum/uplink_item/role_restricted/retrovirus
	name = "Retrovirus Culture Bottle"
	desc = "A bottle of contagious DNA bugs, which will manually rearrange the DNA of hosts. \
			At least, that's what the label says."
	item = /obj/item/reagent_containers/cup/bottle/retrovirus
	cost = 12
	restricted_roles = list(JOB_NAME_VIROLOGIST, JOB_NAME_GENETICIST)

/datum/uplink_item/role_restricted/anxiety
	name = "Anxiety Culture Bottle"
	desc = "A bottle of contagious anxiety-inducing virus. \
			At least, that's what the label says"
	item = /obj/item/reagent_containers/cup/bottle/anxiety
	cost = 4
	restricted_roles = list(JOB_NAME_VIROLOGIST)

/datum/uplink_item/role_restricted/explosive_hot_potato
	name = "Exploding Hot Potato"
	desc = "A potato rigged with explosives. On activation, a special mechanism is activated that prevents it from being dropped. \
			The only way to get rid of it if you are holding it is to attack someone else with it, causing it to latch to that person instead."
	item = /obj/item/hot_potato/syndicate
	cost = 3
	surplus = 0
	restricted_roles = list(JOB_NAME_COOK, JOB_NAME_BOTANIST, JOB_NAME_CLOWN, JOB_NAME_MIME)

/datum/uplink_item/role_restricted/echainsaw
	name = "Energy Chainsaw"
	desc = "An incredibly deadly modified chainsaw with plasma-based energy blades instead of metal and a slick black-and-red finish. While it rips apart matter with extreme efficiency, it is heavy, large, and monstrously loud."
	item = /obj/item/chainsaw/energy
	cost = 10
	player_minimum = 25
	restricted_roles = list(JOB_NAME_BOTANIST, JOB_NAME_COOK, JOB_NAME_BARTENDER)

/datum/uplink_item/role_restricted/holocarp
	name = "Holocarp Parasites"
	desc = "Fishsticks prepared through ritualistic means in honor of the god Carp-sie, capable of binding a holocarp \
			to act as a servant and guardian to their host."
	item = /obj/item/holoparasite_creator/carp
	cost = 18
	surplus = 5
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)
	player_minimum = 25
	restricted = TRUE
	restricted_roles = list(JOB_NAME_COOK, JOB_NAME_CHAPLAIN)

/datum/uplink_item/role_restricted/ez_clean_bundle
	name = "EZ Clean Grenade Bundle"
	desc = "A box with three cleaner grenades using the trademark Waffle Co. formula. Serves as a cleaner and causes acid damage to anyone standing nearby. \
			The acid only affects carbon-based creatures."
	item = /obj/item/storage/box/syndie_kit/ez_clean
	cost = 6
	surplus = 20
	restricted_roles = list(JOB_NAME_JANITOR)

/datum/uplink_item/role_restricted/mimery
	name = "Guide to Advanced Mimery Series"
	desc = "The classical two part series on how to further hone your mime skills. Upon studying the series, the user should be able to make 3x1 invisible walls, and shoot bullets out of their fingers. \
			Obviously only works for Mimes."
	cost = 11
	item = /obj/item/storage/box/syndie_kit/mimery
	restricted_roles = list(JOB_NAME_MIME)
	surplus = 0

/datum/uplink_item/role_restricted/mimesabrekit
	name = "Baguette blade bundle"
	desc = "A very stealthy blade located inside an even stealthier baguette-shaped sheath."
	cost = 	12
	item = /obj/item/storage/box/syndie_kit/mimesabrekit
	restricted_roles = list(JOB_NAME_MIME)
	surplus = 5

/datum/uplink_item/role_restricted/pressure_mod
	name = "Kinetic Accelerator Pressure Mod"
	desc = "A modification kit which allows Kinetic Accelerators to do greatly increased damage while indoors. \
			Occupies 35% mod capacity."
	item = /obj/item/borg/upgrade/modkit/indoors
	cost = 5 //you need one for full damage, so total of 5 for maximum damage
	limited_stock = 1 //you can't use more than one!
	restricted_roles = list(JOB_NAME_SHAFTMINER)

/datum/uplink_item/role_restricted/esaw
	name = "Energy Saw"
	desc = "A deadly energy saw. Comes in a slick black finish."
	cost = 5
	item = /obj/item/melee/transforming/energy/sword/esaw
	restricted_roles = list("Medical Doctor", "Chief Medical Officer", "Paramedic", "Brig Physician")

/datum/uplink_item/role_restricted/esaw_arm
	name = "Energy Saw Arm Implant"
	desc = "An implant that grants you a deadly energy saw inside your arm. Comes with a syndicate autosurgeon for immediate self-application."
	cost = 8
	item = /obj/item/autosurgeon/syndicate/esaw_arm
	restricted_roles = list(JOB_NAME_MEDICALDOCTOR, JOB_NAME_CHIEFMEDICALOFFICER, JOB_NAME_PARAMEDIC, JOB_NAME_BRIGPHYSICIAN)

/datum/uplink_item/role_restricted/magillitis_serum
	name = "Magillitis Serum Autoinjector"
	desc = "A single-use autoinjector which contains an experimental serum that causes rapid muscular growth in Hominidae. \
			Side-affects may include hypertrichosis, violent outbursts, and an unending affinity for bananas."
	item = /obj/item/reagent_containers/hypospray/medipen/magillitis
	cost = 15
	restricted_roles = list(JOB_NAME_GENETICIST, JOB_NAME_CHIEFMEDICALOFFICER)

/datum/uplink_item/role_restricted/modified_syringe_gun
	name = "Modified Syringe Gun"
	desc = "A syringe gun that fires DNA injectors instead of normal syringes."
	item = /obj/item/gun/syringe/dna
	cost = 14
	restricted_roles = list(JOB_NAME_GENETICIST, JOB_NAME_CHIEFMEDICALOFFICER)

/datum/uplink_item/role_restricted/chemical_gun
	name = "Reagent Dartgun"
	desc = "A heavily modified syringe gun which is capable of synthesizing its own chemical darts using input reagents. Can hold 100u of reagents."
	item = /obj/item/gun/chem
	cost = 12
	restricted_roles = list(JOB_NAME_CHEMIST, JOB_NAME_CHIEFMEDICALOFFICER)

/datum/uplink_item/role_restricted/reverse_bear_trap
	name = "Reverse Bear Trap"
	desc = "An ingenious execution device worn on (or forced onto) the head. Arming it starts a 1-minute kitchen timer mounted on the bear trap. When it goes off, the trap's jaws will \
	violently open, instantly killing anyone wearing it by tearing their jaws in half. To arm, attack someone with it while they're not wearing headgear, and you will force it onto their \
	head after three seconds uninterrupted."
	cost = 4
	item = /obj/item/reverse_bear_trap
	restricted_roles = list(JOB_NAME_CLOWN)

/datum/uplink_item/role_restricted/reverse_revolver
	name = "Reverse Revolver"
	desc = "A revolver that always fires at its user. \"Accidentally\" drop your weapon, then watch as the greedy corporate pigs blow their own brains all over the wall. \
	The revolver itself is actually real. Only clumsy people, and clowns, can fire it normally. Comes in a box of hugs. Honk."
	cost = 13
	item = /obj/item/storage/box/hug/reverse_revolver
	restricted_roles = list(JOB_NAME_CLOWN)

/datum/uplink_item/role_restricted/laser_arm
	name = "Laser Arm Implant"
	desc = "An implant that grants you a recharging laser gun inside your arm. Weak to EMPs. Comes with a syndicate autosurgeon for immediate self-application."
	cost = 12
	item = /obj/item/autosurgeon/syndicate/laser_arm
	restricted_roles = list(JOB_NAME_ROBOTICIST, JOB_NAME_RESEARCHDIRECTOR)

/datum/uplink_item/role_restricted/tc_rod
	name = "Telecrystal Fuel Rod"
	desc = "This special fuel rod has eight material slots that can be inserted with telecrystals, \
			once the rod has been fully depleted, you will be able to harvest the extra telecrystals. \
			Please note: This Rod fissiles much faster than it's nanotrasen counterpart, it doesn't take \
			much to overload the reactor with these..."
	item = /obj/item/fuel_rod/material/telecrystal
	cost = 7
	restricted_roles = list(JOB_NAME_STATIONENGINEER, JOB_NAME_ATMOSPHERICTECHNICIAN, JOB_NAME_CHIEFENGINEER)

// Pointless
/datum/uplink_item/badass
	category = "(Pointless) Badassery"
	surplus = 0


/datum/uplink_item/badass/costumes
	surplus = 0
	cost = 4
	cant_discount = TRUE
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/badass/costumes/obvious_chameleon
	name = "Broken Chameleon Kit"
	desc = "A set of items that contain chameleon technology allowing you to disguise as pretty much anything on the station, and more! \
			Please note that this kit did NOT pass quality control."
	item = /obj/item/storage/box/syndie_kit/chameleon/broken
	cost = 2
	purchasable_from = ALL

/datum/uplink_item/badass/costumes/centcom_official
	name = "CentCom Official Costume"
	desc = "Ask the crew to \"inspect\" their nuclear disk and weapons system, and then when they decline, pull out a fully automatic rifle and gun down the Captain. \
			Radio headset does not include encryption key. No gun included."
	item = /obj/item/storage/box/syndie_kit/centcom_costume

/datum/uplink_item/badass/costumes/clown
	name = "Clown Costume"
	desc = "Nothing is more terrifying than clowns with fully automatic weaponry."
	item = /obj/item/storage/backpack/duffelbag/clown/syndie

/datum/uplink_item/badass/surprise_cake
	name = "Rigged Towering Cake"
	desc = "For hosting a surprise birthday party for the Captain, with a flashy surprise."
	item = /obj/structure/popout_cake/nukeop
	cost = 4
	purchasable_from = (UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/badass/balloon
	name = "Syndicate Balloon"
	desc = "For showing that you are THE BOSS: A useless red balloon with the Syndicate logo on it. \
			Can blow the deepest of covers."
	item = /obj/item/toy/syndicateballoon
	cost = 20
	cant_discount = TRUE
	illegal_tech = FALSE
	surplus = 0

/datum/uplink_item/badass/syndiebeer
	name = "Syndicate Beer"
	desc = "Syndicate brand 'beer' designed to flush toxins out of your system. \
			Warning: Do not consume more than one!"
	item = /obj/item/reagent_containers/cup/glass/bottle/beer/syndicate
	cost = 4
	illegal_tech = FALSE

/datum/uplink_item/badass/syndiecash
	name = "Syndicate Briefcase Full of Cash"
	desc = "A secure briefcase containing 5000 space credits. Useful for bribing personnel, or purchasing goods \
			and services at lucrative prices. The briefcase also feels a little heavier to hold; it has been \
			manufactured to pack a little bit more of a punch if your client needs some convincing."
	item = /obj/item/storage/secure/briefcase/syndie
	cost = 1
	restricted = TRUE
	illegal_tech = FALSE
	contents_are_illegal_tech = FALSE

/datum/uplink_item/badass/syndiecards
	name = "Syndicate Playing Cards"
	desc = "A special deck of space-grade playing cards with a mono-molecular edge and metal reinforcement, \
			making them slightly more robust than a normal deck of cards. \
			You can also play card games with them or leave them on your victims."
	item = /obj/item/toy/cards/deck/syndicate
	cost = 1
	surplus = 40

/datum/uplink_item/badass/syndiecigs
	name = "Syndicate Smokes"
	desc = "Strong flavor, dense smoke, infused with omnizine."
	item = /obj/item/storage/fancy/cigarettes/cigpack_syndicate
	cost = 2
	illegal_tech = FALSE
	contents_are_illegal_tech = FALSE

/datum/uplink_item/badass/toy_box
	name = "Box of DonkCo. Toys"
	desc = "A special package box for children who want to have awesome gifts from their parents, full of DonkCo. toys. \
	Toys inside of the box are totally safe and not harmful, approved by Nanotrasen safety assurance even, that can be said as non-contraband stuff literally. \
	This package will be special when you're going to present funny toys to your beloved child. Don't ask why the box is red."
	item = /obj/item/storage/box/syndie_kit/toy_box
	cost = 2
	surplus = 0
	illegal_tech = FALSE
	contents_are_illegal_tech = FALSE

/datum/uplink_item/implants/deathrattle
	name = "Box of Deathrattle Implants"
	desc = "A collection of implants (and one reusable implanter) that should be injected into the team. When one of the team \
	dies, all other implant holders receive a mental message informing them of their teammates' name \
	and the location of their death. Unlike most implants, these are designed to be implanted \
	in any creature, biological or mechanical."
	item = /obj/item/storage/box/syndie_kit/imp_deathrattle
	cost = 4
	surplus = 0
	purchasable_from = UPLINK_NUKE_OPS

/datum/uplink_item/device_tools/antag_lasso
	name = "Mindslave Lasso"
	desc = "A state of the art taming device.\n Use this device to tame almost any animal by lassoing and untying them.\n Tamed animals can be rode & commanded!"
	item = /obj/item/mob_lasso/traitor
	cost = 3
	surplus = 0
	disabled = TRUE	// #11346 Currently in a broken state, lasso'd mobs will never unregister a target once they have locked onto one, making them unusable.

