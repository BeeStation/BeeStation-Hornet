//pepperspray
/obj/item/reagent_containers/peppercloud_deployer
	name = "pepper-cloud deployer"
	desc = "Manufactured by UhangInc, upon activation a pepper-cloud will be deployed slowing down and disorienting anyone who enters it."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "pepperspray"
	item_state = "pepperspray"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	volume = 50
	list_reagents = list(/datum/reagent/consumable/condensedcapsaicin = 50)

	item_flags = NOBLUDGEON | ISWEAPON
	reagent_flags = OPENCONTAINER
	slot_flags = ITEM_SLOT_BELT
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 7

	var/cooldown_time = 0
	var/activation_cooldown = 2 SECONDS

/obj/item/reagent_containers/peppercloud_deployer/empty //for protolathe printing
	list_reagents = null

/obj/item/reagent_containers/peppercloud_deployer/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] begins huffing \the [src]! It looks like [user.p_theyre()] getting a dirty high!</span>")
	deploy(get_turf(user), user, TRUE)
	return OXYLOSS

/obj/item/reagent_containers/peppercloud_deployer/attack_self(mob/user)
	// Deploy in the forward facing direction
	deploy_direction(user, user.dir)

// Fix pepperspraying yourself
/obj/item/reagent_containers/peppercloud_deployer/afterattack(atom/target, mob/user)
	if(istype(target, /obj/structure/reagent_dispensers/peppertank) && get_dist(src, target) <= 1)
		if(!target.reagents.total_volume)
			to_chat(user, "<span class='warning'>[target] is empty.</span>")
			return

		if(reagents.holder_full())
			to_chat(user, "<span class='warning'>[src] is full.</span>")
			return

		playsound(src.loc, 'sound/effects/spray.ogg', 50, 1, -6)
		var/trans = target.reagents.trans_to(src, 50, transfered_by = user) //transfer 50u , using the spray's transfer amount would take too long to refill
		to_chat(user, "<span class='notice'>You fill \the [src] with [trans] units of the contents of \the [target].</span>")
		return

	if(reagents.total_volume < amount_per_transfer_from_this)
		to_chat(user, "<span class='warning'>Not enough left!</span>")
		return

	user.changeNext_move(CLICK_CD_RANGE*2)
	user.newtonian_move(get_dir(target, user))

	if (get_turf(user) == get_turf(target))
		// Deploy in the facing direction
		deploy_direction(user, user.dir)
	else
		// Deploy in the clicked direction
		deploy_direction(user, get_cardinal_dir(user, target))

/obj/item/reagent_containers/peppercloud_deployer/proc/deploy_direction(mob/user, direction)
	// Take 2 steps away from the user
	var/turf/previous = get_turf(user)
	var/turf/next = get_step(user, direction)
	for (var/i in 1 to 2)
		if (!CANATMOSPASS(next, previous))
			break
		previous = next
		next = get_step(previous, direction)
	deploy(previous, user)

/obj/item/reagent_containers/peppercloud_deployer/proc/deploy(turf/center, mob/user, force = FALSE)
	// Check if we are currently on cooldown
	if (world.time < cooldown_time && !force)
		to_chat(user, "<span class='warning'>[src] isn't ready to be activated yet.<span>")
		return
	// Clear any reagents that are not pepperspray
	var/reagents_removed = FALSE
	for (var/datum/reagent/reagent in reagents.reagent_list)
		if (istype(reagent, /datum/reagent/consumable/condensedcapsaicin))
			continue
		reagents.remove_reagent(reagent.type, reagent.volume, TRUE)
		reagents_removed = TRUE
	if (reagents_removed)
		reagents.handle_reactions()
	// Check that we have enough pepperspray remaining
	if (reagents.get_reagent_amount(/datum/reagent/consumable/condensedcapsaicin) < 25)
		to_chat(user, "<span class='warning'>[src] doesn't contain enough capsaicin to deploy, refill it!<span>")
		return
	cooldown_time = world.time + activation_cooldown
	var/datum/reagents/R = new/datum/reagents(25)
	R.my_atom = src
	reagents.trans_to(R, 25)
	var/datum/effect_system/smoke_spread/chem/smoke = new
	smoke.set_up(R, 1, center, silent = TRUE, circle = FALSE)
	playsound(src, 'sound/weapons/grenadelaunch.ogg', 70, FALSE, -2)
	playsound(src, 'sound/effects/smoke.ogg', 50, TRUE, -2)
	smoke.start()
	investigate_log("[key_name(user)] deployed a peppercloud at [COORD(center)].", INVESTIGATE_EXPERIMENTOR)
