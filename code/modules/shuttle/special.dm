// Special objects for shuttle templates go here if nowhere else

// Wabbajack statue, a sleeping frog statue that shoots bolts of change if
// living carbons are put on its altar/tables

/obj/machinery/power/emitter/energycannon/magical
	name = "wabbajack statue"
	desc = "Who am I? What is my purpose in life? What do I mean by who am I?"
	projectile_type = /obj/item/projectile/magic/change
	icon = 'icons/obj/machines/magic_emitter.dmi'
	icon_state = "wabbajack_statue"
	icon_state_on = "wabbajack_statue_on"
	active = FALSE
	allow_switch_interact = FALSE
	var/list/active_tables = list()
	var/tables_required = 2

/obj/machinery/power/emitter/energycannon/magical/Initialize()
	. = ..()
	if(prob(50))
		desc = "Oh no, not again."
	update_icon()

/obj/machinery/power/emitter/energycannon/magical/update_icon()
	if(active)
		icon_state = icon_state_on
	else
		icon_state = initial(icon_state)

/obj/machinery/power/emitter/energycannon/magical/process()
	. = ..()
	if(active_tables.len >= tables_required)
		if(!active)
			visible_message("<span class='revenboldnotice'>\
				[src] opens its eyes.</span>")
		active = TRUE
	else
		if(active)
			visible_message("<span class='revenboldnotice'>\
				[src] closes its eyes.</span>")
		active = FALSE
	update_icon()

/obj/machinery/power/emitter/energycannon/magical/attackby(obj/item/W, mob/user, params)
	return

/obj/machinery/power/emitter/energycannon/magical/ex_act(severity)
	return

/obj/machinery/power/emitter/energycannon/magical/emag_act(mob/user)
	return

/obj/structure/table/abductor/wabbajack
	name = "wabbajack altar"
	desc = "Whether you're sleeping or waking, it's going to be quite chaotic."
	max_integrity = 1000
	verb_say = "chants"
	var/obj/machinery/power/emitter/energycannon/magical/our_statue
	var/list/mob/living/sleepers = list()
	var/never_spoken = TRUE
	flags_1 = NODECONSTRUCT_1

/obj/structure/table/abductor/wabbajack/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/table/abductor/wabbajack/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/structure/table/abductor/wabbajack/process()
	var/area = orange(4, src)
	if(!our_statue)
		for(var/obj/machinery/power/emitter/energycannon/magical/M in area)
			our_statue = M
			break

	if(!our_statue)
		name = "inert [initial(name)]"
		return
	else
		name = initial(name)

	var/turf/T = get_turf(src)
	var/list/found = list()
	for(var/mob/living/carbon/C in T)
		if(C.stat != DEAD)
			found += C

	// New sleepers
	for(var/i in found - sleepers)
		var/mob/living/L = i
		L.add_atom_colour("#800080", TEMPORARY_COLOUR_PRIORITY)
		L.visible_message("<span class='revennotice'>A strange purple glow wraps itself around [L] as [L.p_they()] suddenly fall[L.p_s()] unconscious.</span>",
			"<span class='revendanger'>[desc]</span>")
		// Don't let them sit suround unconscious forever
		addtimer(CALLBACK(src, .proc/sleeper_dreams, L), 100)

	// Existing sleepers
	for(var/i in found)
		var/mob/living/L = i
		L.SetSleeping(200)

	// Missing sleepers
	for(var/i in sleepers - found)
		var/mob/living/L = i
		L.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, "#800080")
		L.visible_message("<span class='revennotice'>The glow from [L] fades \
			away.</span>")
		L.grab_ghost()

	sleepers = found

	if(sleepers.len)
		our_statue.active_tables |= src
		if(never_spoken || prob(5))
			say(desc)
			never_spoken = FALSE
	else
		our_statue.active_tables -= src

/obj/structure/table/abductor/wabbajack/proc/sleeper_dreams(mob/living/sleeper)
	if(sleeper in sleepers)
		to_chat(sleeper, "<span class='revennotice'>While you slumber, you have the strangest dream, like you can see yourself from the outside.</span>")
		sleeper.ghostize(TRUE)

/obj/structure/table/abductor/wabbajack/left
	desc = "You sleep so it may wake."

/obj/structure/table/abductor/wabbajack/right
	desc = "It wakes so you may sleep."

// Bar staff, GODMODE mobs that just want to make sure people have drinks
// and a good time.

/mob/living/simple_animal/drone/snowflake/bardrone
	name = "Bardrone"
	desc = "A barkeeping drone, an indestructible robot built to tend bars."
	hacked = TRUE
	laws = "1. Serve drinks.\n\
		2. Talk to patrons.\n\
		3. Don't get messed up in their affairs."
	status_flags = GODMODE // Please don't punch the barkeeper
	unique_name = FALSE // disables the (123) number suffix
	initial_language_holder = /datum/language_holder/universal

/mob/living/simple_animal/drone/snowflake/bardrone/Initialize()
	. = ..()
	access_card.access |= ACCESS_CENT_BAR

/mob/living/simple_animal/hostile/alien/maid/barmaid
	gold_core_spawnable = NO_SPAWN
	name = "Barmaid"
	desc = "A barmaid, a maiden found in a bar."
	pass_flags = PASSTABLE
	status_flags = GODMODE
	unique_name = FALSE
	AIStatus = AI_OFF
	stop_automated_movement = TRUE
	initial_language_holder = /datum/language_holder/universal

/mob/living/simple_animal/hostile/alien/maid/barmaid/Initialize()
	. = ..()
	access_card = new /obj/item/card/id(src)
	var/datum/job/captain/C = new /datum/job/captain
	access_card.access = C.get_access()
	access_card.access |= ACCESS_CENT_BAR
	ADD_TRAIT(access_card, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)

/mob/living/simple_animal/hostile/alien/maid/barmaid/Destroy()
	qdel(access_card)
	. = ..()

// Bar table, a wooden table that kicks you in a direction if you're not
// barstaff (defined as someone who was a roundstart bartender or someone
// with CENTCOM_BARSTAFF)

/obj/structure/table/wood/bar
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	flags_1 = NODECONSTRUCT_1
	max_integrity = 1000
	var/boot_dir = 1

/obj/structure/table/wood/bar/Crossed(atom/movable/AM)
	if(isliving(AM) && !is_barstaff(AM))
		// No climbing on the bar please
		var/mob/living/M = AM
		var/throwtarget = get_edge_target_turf(src, boot_dir)
		M.Paralyze(40)
		M.throw_at(throwtarget, 5, 1,src)
		to_chat(M, "<span class='notice'>No climbing on the bar please.</span>")
	else
		. = ..()

/obj/structure/table/wood/bar/proc/is_barstaff(mob/living/user)
	. = FALSE
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.mind?.assigned_role == "Bartender")
			return TRUE

	var/obj/item/card/id/ID = user.get_idcard(FALSE)
	if(ID && (ACCESS_CENT_BAR in ID.access))
		return TRUE

//Luxury Shuttle Blockers

/obj/effect/forcefield/luxury_shuttle
	name = "Luxury shuttle ticket booth"
	desc = "A forceful money collector."
	timeleft = 0
	var/threshold = 500
	var/static/list/approved_passengers = list()
	var/static/list/check_times = list()
	var/list/payees = list()

/obj/effect/forcefield/luxury_shuttle/CanPass(atom/movable/mover, turf/target)
	if(mover in approved_passengers)
		return TRUE

	if(!isliving(mover)) //No stowaways
		return FALSE

	return FALSE


#define LUXURY_MESSAGE_COOLDOWN 100
/obj/effect/forcefield/luxury_shuttle/Bumped(atom/movable/AM)
	if(!isliving(AM))
		return ..()

	var/list/counted_money = list()

	for(var/obj/item/coin/C in AM.GetAllContents())
		if(payees[AM] >= threshold)
			break
		payees[AM] += C.value
		counted_money += C
	for(var/obj/item/stack/spacecash/S in AM.GetAllContents())
		if(payees[AM] >= threshold)
			break
		payees[AM] += S.value * S.amount
		counted_money += S
	for(var/obj/item/holochip/H in AM.GetAllContents())
		if(payees[AM] >= threshold)
			break
		payees[AM] += H.credits
		counted_money += H

	if(payees[AM] < threshold && istype(AM.pulling, /obj/item/coin))
		var/obj/item/coin/C = AM.pulling
		payees[AM] += C.value
		counted_money += C

	else if(payees[AM] < threshold && istype(AM.pulling, /obj/item/stack/spacecash))
		var/obj/item/stack/spacecash/S = AM.pulling
		payees[AM] += S.value * S.amount
		counted_money += S

	else if(payees[AM] < threshold && istype(AM.pulling, /obj/item/holochip))
		var/obj/item/holochip/H = AM.pulling
		payees[AM] += H.credits
		counted_money += H

	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		if(H.get_bank_account())
			var/datum/bank_account/account = H.get_bank_account()

			if(account.account_balance < threshold)
				payees[AM] += account.account_balance
				account.adjust_money(-account.account_balance)
			else
				var/money_owed = threshold - payees[AM]
				payees[AM] += money_owed
				account.adjust_money(-money_owed)

	if(payees[AM] >= threshold)
		for(var/obj/I in counted_money)
			qdel(I)
		payees[AM] -= threshold
		say("<span class='robot'>Welcome aboard, [AM]!</span>")
		approved_passengers += AM

		if(payees[AM] > 0 && ishuman(AM))
			var/mob/living/carbon/human/H = AM
			if(H.get_bank_account())
				var/datum/bank_account/account = H.get_bank_account()
				account.adjust_money(payees[AM])
				payees[AM] -= payees[AM]

		check_times -= AM
		return
	else if (payees[AM] > 0)
		for(var/obj/I in counted_money)
			qdel(I)
		if(!check_times[AM] || check_times[AM] < world.time) //Let's not spam the message
			say("<span class='robot'>$[payees[AM]] received, [AM]. You need $[threshold-payees[AM]] more.</span>")
			check_times[AM] = world.time + LUXURY_MESSAGE_COOLDOWN
		return ..()
	else
		return ..()

/mob/living/simple_animal/hostile/bear/fightpit
	name = "fight pit bear"
	desc = "This bear's trained through ancient Russian secrets to fear the walls of its glass prison."
	environment_smash = ENVIRONMENT_SMASH_NONE

/obj/effect/decal/hammerandsickle
	name = "hammer and sickle"
	desc = "Communism powerful force."
	icon = 'icons/effects/96x96.dmi'
	icon_state = "communist"
	layer = ABOVE_OPEN_TURF_LAYER
	pixel_x = -32
	pixel_y = -32

/obj/effect/decal/hammerandsickle/shuttleRotate(rotation)
	setDir(angle2dir(rotation+dir2angle(dir))) // No parentcall, rest of the rotate code breaks the pixel offset.
