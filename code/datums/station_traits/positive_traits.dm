/datum/station_trait/lucky_winner
	name = "Lucky winner"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 1
	show_in_report = TRUE
	report_message = "Your station has won the grand prize of the annual station charity event. Free snacks will be delivered to the bar every now and then."
	trait_processes = TRUE

	COOLDOWN_DECLARE(party_cooldown)

/datum/station_trait/lucky_winner/process(delta_time)
	if(!COOLDOWN_FINISHED(src, party_cooldown))
		return

	var/turf/turf = get_safe_random_station_turfs(GLOB.bar_areas)
	if(!turf)
		return

	COOLDOWN_START(src, party_cooldown, rand(6 MINUTES, 12 MINUTES))

	var/obj/structure/closet/supplypod/centcompod/drop_pod = new()
	var/obj/item/pizzabox/pizza_to_spawn = pick(list(/obj/item/pizzabox/margherita, /obj/item/pizzabox/mushroom, /obj/item/pizzabox/meat, /obj/item/pizzabox/vegetable)) //no pineapple pizza you monster
	new pizza_to_spawn(drop_pod)
	for(var/i in 1 to 6)
		new /obj/item/reagent_containers/cup/glass/bottle/beer(drop_pod)

	new /obj/effect/pod_landingzone(turf, drop_pod)

/datum/station_trait/galactic_grant
	name = "Galactic grant"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Your station has been selected for a special grant. Some extra funds has been made available to your cargo department."

/datum/station_trait/galactic_grant/on_round_start()
	var/datum/bank_account/cargo_bank = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)
	cargo_bank.adjust_money(rand(2000, 5000))

/datum/station_trait/premium_internals_box
	name = "Premium internals boxes"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 10
	show_in_report = TRUE
	report_message = "The internals boxes for your crew have been filled with bonus equipment."
	trait_to_give = STATION_TRAIT_PREMIUM_INTERNALS

/datum/station_trait/bountiful_bounties
	name = "Bountiful bounties"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	cost = STATION_TRAIT_COST_LOW
	show_in_report = TRUE
	report_message = "It seems collectors in this system are extra keen to on bounties, and will pay more to see their completion."

/datum/station_trait/bountiful_bounties/on_round_start()
	SSeconomy.bounty_modifier *= 1.2

/datum/station_trait/strong_supply_lines
	name = "Strong supply lines"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Prices are low in this system, BUY BUY BUY!"
	blacklist = list(/datum/station_trait/distant_supply_lines)
	trait_to_give = STATION_TRAIT_STRONG_SUPPLY_LINES

/datum/station_trait/scryers
	name = "Scryers"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 2
	cost = STATION_TRAIT_COST_LOW
	show_in_report = TRUE
	report_message = "Nanotrasen has chosen your station for an experiment - everyone has free scryers! Use these to talk to other people easily and privately."

/datum/station_trait/scryers/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_after_spawn))

/datum/station_trait/scryers/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/spawned, client/player_client)
	SIGNAL_HANDLER
	if(!ishuman(spawned))
		return
	var/mob/living/carbon/human/humanspawned = spawned
	// Put their silly little scarf or necktie somewhere else
	var/obj/item/silly_little_scarf = humanspawned.wear_neck
	if(silly_little_scarf)
		var/list/backup_slots = list(
			"in your left pocket" = ITEM_SLOT_LPOCKET,
			"in your right pocket" = ITEM_SLOT_RPOCKET,
			"in your backpack" = ITEM_SLOT_BACKPACK
		)
		humanspawned.temporarilyRemoveItemFromInventory(silly_little_scarf)
		silly_little_scarf.forceMove(get_turf(humanspawned))
		humanspawned.equip_in_one_of_slots(silly_little_scarf, backup_slots, qdel_on_fail = FALSE)

	var/obj/item/clothing/neck/link_scryer/loaded/new_scryer = new(spawned)
	new_scryer.label = spawned.name
	new_scryer.update_name()

	spawned.equip_to_slot_or_del(new_scryer, ITEM_SLOT_NECK, initial = FALSE)

/datum/station_trait/filled_maint
	name = "Filled up maintenance"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	cost = STATION_TRAIT_COST_LOW
	show_in_report = TRUE
	report_message = "Our workers accidentally forgot more of their personal belongings in the maintenance areas."
	blacklist = list(/datum/station_trait/empty_maint)
	trait_to_give = STATION_TRAIT_FILLED_MAINT
	can_revert = FALSE

/datum/station_trait/quick_shuttle
	name = "Quick Shuttle"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Due to proximity to our supply station, the cargo shuttle will have a quicker flight time to your cargo department."
	blacklist = list(/datum/station_trait/slow_shuttle)

/datum/station_trait/quick_shuttle/on_round_start()
	. = ..()
	SSshuttle.supply.callTime *= 0.5
