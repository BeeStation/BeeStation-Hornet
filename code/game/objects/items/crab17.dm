/obj/item/suspiciousphone
	name = "suspicious phone"
	desc = "This device raises pink levels to unknown highs."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "suspiciousphone"
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("dumped")
	var/activated = FALSE

/obj/item/suspiciousphone/attack_self(mob/user)
	if(!ishuman(user))
		to_chat(user, "<span class='warning'>This device is too advanced for you!</span>")
		return
	if(activated)
		to_chat(user, "<span class='warning'>You already activated Protocol CRAB-17.</span>")
		return FALSE
	if(alert(user, "Are you sure you want to crash this market with no survivors?", "Protocol CRAB-17", "Yes", "No") == "Yes")
		if(activated || QDELETED(src)) //Prevents fuckers from cheesing alert
			return FALSE
		var/turf/targetturf = get_safe_random_station_turfs()
		if (!targetturf)
			return FALSE
		new /obj/effect/dumpeetTarget(targetturf, user)
		activated = TRUE

#define RUN_AWAY_THRESHOLD_HP 140
#define RUN_AWAY_DELAYED_HP 30

/obj/structure/checkoutmachine
	name = "\improper Nanotrasen Space-Coin Market"
	desc = "This is good for spacecoin because"
	icon = 'icons/obj/money_machine.dmi'
	icon_state = "bogdanoff"
	layer = TABLE_LAYER //So that the crate inside doesn't appear underneath
	armor = list("melee" = 30, "bullet" = 50, "laser" = 50, "energy" = 100, "bomb" = 100, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 80, "stamina" = 0)
	density = TRUE
	pixel_z = -8
	layer = LARGE_MOB_LAYER
	max_integrity = 600
	/// when this gets at this hp, it will run away! oh no!
	var/next_health_to_teleport
	var/mob/living/carbon/human/bogdanoff
	var/canwalk = FALSE
	var/static/existing_machines = 0
	var/protected_accounts = list()


/obj/structure/checkoutmachine/Initialize(mapload, mob/living/user)
	bogdanoff = user
	add_overlay("flaps")
	add_overlay("hatch")
	add_overlay("legs_retracted")
	addtimer(CALLBACK(src, PROC_REF(startUp)), 50)
	next_health_to_teleport = max_integrity - RUN_AWAY_THRESHOLD_HP
	existing_machines++
	. = ..()

/obj/structure/checkoutmachine/examine(mob/living/user)
	. = ..()
	. += "<span class='info'>It's integrated integrity meter reads: <b>HEALTH: [obj_integrity]</b>.</span>"

/obj/structure/checkoutmachine/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/card/id))
		var/obj/item/card/id/card = W
		if(!card.registered_account)
			to_chat(user, "<span class='warning'>This card does not have a registered account!</span>")
			return
		if(protected_accounts["[card.registered_account.account_id]"])
			to_chat(user, "<span class='warning'>It appears that your funds are safe from draining!</span>")
			return
		if(do_after(user, 40, target = src))
			if(protected_accounts["[card.registered_account.account_id]"])
				return
			to_chat(user, "<span class='warning'>You quickly cash out your funds to a more secure banking location. Funds are safu.</span>") // This is a reference and not a typo
			protected_accounts["[card.registered_account.account_id]"] = TRUE
			card.registered_account.withdrawDelay = 0
			next_health_to_teleport -= RUN_AWAY_DELAYED_HP // swipe your card, then it will likely less run away
	else
		return ..()


/obj/structure/checkoutmachine/proc/startUp() //very VERY snowflake code that adds a neat animation when the pod lands.
	start_dumping() //The machine doesnt move during this time, giving people close by a small window to grab their funds before it starts running around
	sleep(10)
	if(QDELETED(src))
		return
	playsound(src, 'sound/machines/click.ogg', 15, 1, -3)
	cut_overlay("flaps")
	sleep(10)
	if(QDELETED(src))
		return
	playsound(src, 'sound/machines/click.ogg', 15, 1, -3)
	cut_overlay("hatch")
	sleep(30)
	if(QDELETED(src))
		return
	playsound(src,'sound/machines/twobeep.ogg',50,0)
	var/mutable_appearance/hologram = mutable_appearance(icon, "hologram")
	hologram.pixel_y = 16
	add_overlay(hologram)
	var/mutable_appearance/holosign = mutable_appearance(icon, "holosign")
	holosign.pixel_y = 16
	add_overlay(holosign)
	add_overlay("legs_extending")
	cut_overlay("legs_retracted")
	pixel_z += 4
	sleep(5)
	if(QDELETED(src))
		return
	add_overlay("legs_extended")
	cut_overlay("legs_extending")
	pixel_z += 4
	sleep(20)
	if(QDELETED(src))
		return
	add_overlay("screen_lines")
	sleep(5)
	if(QDELETED(src))
		return
	cut_overlay("screen_lines")
	sleep(5)
	if(QDELETED(src))
		return
	add_overlay("screen_lines")
	add_overlay("screen")
	sleep(5)
	if(QDELETED(src))
		return
	playsound(src,'sound/machines/triple_beep.ogg',50,0)
	add_overlay("text")
	sleep(10)
	if(QDELETED(src))
		return
	add_overlay("legs")
	cut_overlay("legs_extended")
	cut_overlay("screen")
	add_overlay("screen")
	cut_overlay("screen_lines")
	add_overlay("screen_lines")
	cut_overlay("text")
	add_overlay("text")
	canwalk = TRUE
	START_PROCESSING(SSfastprocess, src)

/obj/structure/checkoutmachine/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	existing_machines--
	if(!existing_machines)
		for(var/datum/bank_account/B in SSeconomy.bank_accounts)
			B.withdrawDelay = 0
	priority_announce("The credit deposit machine at [get_area(src)] has been destroyed. Station funds have stopped draining!", sound = SSstation.announcer.get_rand_alert_sound(), sender_override = "CRAB-17 Protocol", )
	explosion(src, 0,0,1, flame_range = 2)
	return ..()

/obj/structure/checkoutmachine/proc/start_dumping()
	for(var/datum/bank_account/B in SSeconomy.bank_accounts)
		if(protected_accounts["[B.account_id]"])
			continue
		B.withdrawDelay = world.time + 4 MINUTES
	dump()

/obj/structure/checkoutmachine/proc/dump()
	var/percentage_lost = (rand(10, 30) / 1000) // 1~3% randomly chosen. the value is nerfed since the market machine will run away
	var/datum/bank_account/crab_account = bogdanoff.get_bank_account()
	var/total_credits_stolen = 0
	var/victim_count = 0
	for(var/datum/bank_account/B in SSeconomy.bank_accounts)
		if(protected_accounts["[B.account_id]"])
			continue
		var/amount = 0
		if(B.account_balance)
			amount = max(round(B.account_balance * percentage_lost), 1) // we'll steal at least 1 credit
		if(crab_account)
			if(amount)
				crab_account.transfer_money(B, amount)
				total_credits_stolen += amount
				victim_count += 1
				B.bank_card_talk("You have lost [percentage_lost * 100]% of your funds! A spacecoin credit deposit machine is located at: [get_area(src)].")
		else
			if(amount)
				B.adjust_money(-amount)
				total_credits_stolen += amount
				victim_count += 1
				B.bank_card_talk("You have lost [percentage_lost * 100]% of your funds! A spacecoin credit deposit machine is located at: [get_area(src)].")
		B.withdrawDelay += 30 SECONDS // we apologize for the extended maintenance, but we need to steal your credits
	for(var/M in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(M, src)
		to_chat(M, "<span class='deadsay'>[link] [name] [total_credits_stolen ? "siphons total [total_credits_stolen] credits from [victim_count] bank accounts." : "tried to siphon bank accounts, but there're no victims."] location: [get_area(src)]</span>")
	addtimer(CALLBACK(src, PROC_REF(dump)), 150) //Drain every 15 seconds

/obj/structure/checkoutmachine/process()
	var/anydir = pick(GLOB.cardinals)
	if(Process_Spacemove(anydir))
		Move(get_step(src, anydir), anydir)

	// Oh no, it RUNS AWAY!!!
	if(obj_integrity && obj_integrity < next_health_to_teleport) // checks if obj_integrity is positive first
		next_health_to_teleport -= RUN_AWAY_THRESHOLD_HP
		var/turf/targetturf = get_safe_random_station_turfs()
		if(targetturf)
			var/turf/message_turf = get_turf(src) // 'visible_message' from teleported mob will be visible after it's teleported...
			if(do_teleport(src, targetturf, 0, channel = TELEPORT_CHANNEL_BLUESPACE))
				message_turf.visible_message("<span class='danger'>[name] violently whirs before disappearing with a flash of light!</span>")
				visible_message("<span class='danger'>[name] suddenly appears with a flash of light!</span>")

/obj/effect/dumpeetFall //Falling pod
	name = ""
	icon = 'icons/obj/money_machine_64.dmi'
	pixel_z = 300
	desc = "Get out of the way!"
	layer = FLY_LAYER//that wasn't flying, that was falling with style!
	icon_state = "missile_blur"

/obj/effect/dumpeetTarget
	name = "Landing Zone Indicator"
	desc = "A holographic projection designating the landing zone of something. It's probably best to stand back."
	icon = 'icons/mob/actions/actions_items.dmi'
	icon_state = "sniper_zoom"
	layer = PROJECTILE_HIT_THRESHOLD_LAYER
	light_range = 2
	var/obj/effect/dumpeetFall/DF
	var/obj/structure/checkoutmachine/dump
	var/mob/living/carbon/human/bogdanoff

/obj/effect/ex_act()
	return

/obj/effect/dumpeetTarget/Initialize(mapload, user)
	. = ..()
	bogdanoff = user
	addtimer(CALLBACK(src, PROC_REF(startLaunch)), 100)
	sound_to_playing_players('sound/items/dump_it.ogg', 20)
	deadchat_broadcast("<span class='deadsay'>Protocol CRAB-17 has been activated. A space-coin market has been launched at the station!</span>", turf_target = get_turf(src))

/obj/effect/dumpeetTarget/proc/startLaunch()
	DF = new /obj/effect/dumpeetFall(drop_location())
	dump = new /obj/structure/checkoutmachine(null, bogdanoff)
	priority_announce("The spacecoin bubble has popped! Get to the credit deposit machine at [get_area(src)] and cash out before you lose all of your funds!", sound = SSstation.announcer.get_rand_alert_sound(), sender_override = "CRAB-17 Protocol")
	animate(DF, pixel_z = -8, time = 5, , easing = LINEAR_EASING)
	playsound(src,  'sound/weapons/mortar_whistle.ogg', 70, 1, 6)
	addtimer(CALLBACK(src, PROC_REF(endLaunch)), 5, TIMER_CLIENT_TIME) //Go onto the last step after a very short falling animation



/obj/effect/dumpeetTarget/proc/endLaunch()
	QDEL_NULL(DF) //Delete the falling machine effect, because at this point its animation is over. We dont use temp_visual because we want to manually delete it as soon as the pod appears
	playsound(src, "explosion", 80, 1)
	dump.forceMove(get_turf(src))
	qdel(src) //The target's purpose is complete. It can rest easy now

#undef RUN_AWAY_THRESHOLD_HP
#undef RUN_AWAY_DELAYED_HP
