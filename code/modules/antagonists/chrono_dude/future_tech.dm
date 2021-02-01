/*
	- FUTURE TECH -

	CONTENTS
		Chrono Trap - holobarier projector that lays swarmer traps
		Teleport Hourglass - one click teleport
		Click Remote - like seen in the movie Click. Ok, the movie is shit, but the remote is a good idea, ok?!
		The selfdust implant - triggers when agent dies, drops all their non agent items and calls in another agent to take out the target (if needed)

*/


/*
 * CHRONOTRAP PROJECTOR
 */

/obj/item/holosign_creator/chrono_trap
	name = "electric trap projector"
	desc = "A holographic projector that creates energy traps."
	holosign_type = /obj/structure/swarmer/trap
	creation_time = 50
	max_signs = 10
	icon_state = "signmaker_med"
	slot_flags = ITEM_SLOT_BELT
	var/protected = FALSE

/obj/item/holosign_creator/chrono_trap/proc/protection_check(mob/user)
	return !(protected && !user.mind?.has_antag_datum(/datum/antagonist/tca))

/obj/item/holosign_creator/chrono_trap/afterattack(atom/A, mob/user, proximity)
	if (protection_check(user))
		. = ..()
	else
		to_chat(user, "<span class='warning'>As you try to use it, the [src] shines blue for a second, then teleports away!</span>")
		qdel(src)

/obj/item/holosign_creator/chrono_trap/attack_self(mob/user)
	if (protection_check(user))
		. = ..()
	else
		to_chat(user, "<span class='warning'>As you try to use it, the [src] shines blue for a second, then teleports away!</span>")
		qdel(src)
/*
 * TIMESPACE DISPLACEMENT TECH
 */

/obj/item/chrono_tele
	name = "Space Relocator"
	desc = "In the future, the Space Wizard Federation works alongside humans to correct mistakes from the past."
	icon = 'icons/obj/hourglass.dmi'
	icon_state = "hourglass_idle"
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 30, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/protected = FALSE

/obj/item/chrono_tele/proc/protection_check(mob/user)
	return !(protected && !user.mind?.has_antag_datum(/datum/antagonist/tca))

/obj/item/chrono_tele/afterattack(atom/A, mob/user, proximity)
	if (protection_check(user))
		. = ..()
		do_teleport(user, A, 0, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_WORMHOLE)
	else
		to_chat(user, "<span class='warning'>As you try to use it, the [src] shines blue for a second, then teleports away!</span>")
		qdel(src)

/obj/item/chrono_tele/attack_self(mob/user)
	if (protection_check(user))
		. = ..()
		var/atom/A = get_ranged_target_turf(get_turf(user), user.dir, 3)
		do_teleport(user, A, 0, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_WORMHOLE)
	else
		to_chat(user, "<span class='warning'>As you try to use it, the [src] shines blue for a second, then teleports away!</span>")
		qdel(src)

/*
 * CLICK REMOTE
 */
#define UR_PAUSE 0
#define UR_SLOW 1
#define UR_MUTE 2
#define UR_STOP 3
#define UR_MODES 4

/obj/item/click_remote
	name = "Universal Remote Control"
	desc = "A remote able to manipulate the universe itself. Not to be used by architects."
	icon = 'icons/obj/device.dmi'
	icon_state = "hand_tele"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 30, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/mode = 0
	var/protected = FALSE

/obj/item/click_remote/proc/protection_check(mob/user)
	if (protected && !user.mind?.has_antag_datum(/datum/antagonist/tca))
		return FALSE
	return TRUE

/obj/item/click_remote/afterattack(atom/A, mob/user, proximity)
	if (protection_check(user))
		. = ..()
		var/mob/living/carbon/target = A
		if (target)
			playsound(user, 'sound/machines/click.ogg', 50, TRUE, -1)
			log_combat(user, target, "used universal remote on")
			switch (mode)
				if (UR_PAUSE)	//pause
					target.Stun(500)
					to_chat(target, "<span class='warning'>You feel like you cannot move!</span>")
				if (UR_SLOW)	//legcuff
					if (ishuman(target))
						var/obj/item/restraints/legcuffs/beartrap/B = new /obj/item/restraints/legcuffs/beartrap/energy(get_turf(target))
						B.Crossed(target)
				if (UR_MUTE)	//mute
					target.silent = max(500,target.silent)
					to_chat(target, "<span class='warning'>Your voice disappeared!</span>")
				else	//off
					target.Sleeping(500)
					to_chat(target, "<span class='warning'>Everything turns black...</span>")
	else
		to_chat(user, "<span class='warning'>As you try to use it, the [src] shines blue for a second, then teleports away!</span>")
		qdel(src)


/obj/item/click_remote/attack_self(mob/user)
	if (protection_check(user))
		. = ..()
		mode++
		if (mode>=UR_MODES)
			mode = 0
		switch (mode)
			if (UR_PAUSE)
				to_chat(user,"<span='notice'>The [src] is now set to PAUSE.</span>")
			if (UR_SLOW)
				to_chat(user,"<span='notice'>The [src] is now set to SLOW.</span>")
			if (UR_MUTE)
				to_chat(user,"<span='notice'>The [src] is now set to MUTE.</span>")
			else
				to_chat(user,"<span='notice'>The [src] is now set to OFF.</span>")
	else
		to_chat(user, "<span class='warning'>As you try to use it, the [src] shines blue for a second, then teleports away!</span>")
		qdel(src)

#undef UR_PAUSE
#undef UR_SLOW
#undef UR_MUTE
#undef UR_STOP
#undef UR_MODES

/*
 * DUST SELF IMPLANTER - in case things go wrong
 */

/obj/item/implant/dust_self
	name = "recall implant"
	desc = "Implant that recalls an agent if the mission is concluded or things go terribly wrong."
	icon_state = "explosive"
	actions_types = list(/datum/action/item_action/dust_self)
	var/popup = FALSE

/datum/action/item_action/dust_self
	check_flags = NONE
	name = "Recall"

/obj/item/implant/dust_self/on_mob_death(mob/living/L, gibbed)
	activate("death")

/obj/item/implant/dust_self/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> FUTURE-TECH 2577 TimeSpace Agent Recall<BR>
				<b>Life:</b> Activates upon death.<BR>
				<b>Important Notes:</b> The target is teleported somewhere in the future.<BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> Advanced Bluespace Technology that recalls an agent if the mission is concluded or things go terribly wrong.<BR>
				"}
	return dat

/obj/item/implant/dust_self/activate(cause)
	. = ..()
	if(!cause || !imp_in)
		return 0
	if(cause == "action_button")
		popup = TRUE
		var/response = alert(imp_in, "Are you sure you want to conclude your mission? A new agent will be dispatched if your target is still alive.", "[name] Confirmation", "Yes", "No")
		popup = FALSE
		if(response == "No")
			return 0
	if(imp_in)
		var/datum/antagonist/tca/timeagent = imp_in.mind?.has_antag_datum(/datum/antagonist/tca)
		if (!timeagent?.mission_concluded())
			to_chat(imp_in, "<span class='notice'>You have failed your mission. A new agent will be dispatched.</span>")
			var/datum/antagonist/ta/prey = timeagent.prey
			if (prey)
				var/datum/round_event/ghost_role/chronos/hunter = new()
				hunter.target = prey
		else
			to_chat(imp_in, "<span class='notice'>You mission was succesful. You will be rewarded generously.</span>")

		var/turf/T = get_turf(imp_in)
		var/obj/item/suit = imp_in.get_item_by_slot(SLOT_WEAR_SUIT)
		if (suit?.type!=/obj/item/clothing/suit/space/chronos)
			suit.forceMove(T)
		var/obj/item/bag = imp_in.get_item_by_slot(SLOT_BACK)
		if (bag?.type!=/obj/item/chrono_eraser)
			bag.forceMove(T)
		var/obj/item/helm = imp_in.get_item_by_slot(SLOT_HEAD)
		if (helm?.type!=/obj/item/clothing/head/helmet/space/chronos)
			helm.forceMove(T)
		var/obj/item/gadget = imp_in.get_item_by_slot(SLOT_BELT)
		if (gadget && gadget.type!=/obj/item/holosign_creator/chrono_trap && gadget.type!=/obj/item/chrono_tele && gadget.type!=/obj/item/click_remote)
			gadget.forceMove(T)
		var/obj/item/pocket_r = imp_in.get_item_by_slot(SLOT_R_STORE)
		if (pocket_r && pocket_r.type!=/obj/item/holosign_creator/chrono_trap && pocket_r.type!=/obj/item/chrono_tele && pocket_r.type!=/obj/item/click_remote)
			pocket_r.forceMove(T)
		var/obj/item/pocket_l = imp_in.get_item_by_slot(SLOT_L_STORE)
		if (pocket_l && pocket_l.type!=/obj/item/holosign_creator/chrono_trap && pocket_l.type!=/obj/item/chrono_tele && pocket_l.type!=/obj/item/click_remote)
			pocket_l.forceMove(T)

		imp_in.dust()

		qdel(src)