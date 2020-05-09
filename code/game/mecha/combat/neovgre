/obj/mecha/combat/neovgre
	name = "Neovgre, the Anima Bulwark"
	desc = "Nezbere's most powerful creation, a mighty war machine of unmatched power said to have ended wars in a single night."
	icon = 'icons/mecha/neovgre.dmi'
	icon_state = "neovgre"
	max_integrity = 500 //This is THE ratvarian superweaon, its deployment is an investment
	armor = list("melee" = 50, "bullet" = 40, "laser" = 25, "energy" = 25, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100) //Its similar to the clockwork armour albeit with a few buffs becuase RATVARIAN SUPERWEAPON!!
	force = 50 //SMASHY SMASHY!!
	internal_damage_threshold = 0
	step_in = 3
	pixel_x = -16
	layer = ABOVE_MOB_LAYER
	breach_time = 100 //ten seconds till all goes to shit
	recharge_rate = 100
	wreckage = /obj/structure/mecha_wreckage/durand/neovgre

/obj/mecha/combat/neovgre/GrantActions(mob/living/user, human_occupant = 0) //No Eject action for you sonny jim, your life for Ratvar!
	internals_action.Grant(user, src)
	cycle_action.Grant(user, src)
	lights_action.Grant(user, src)
	stats_action.Grant(user, src)
	strafing_action.Grant(user, src)

/obj/mecha/combat/neovgre/RemoveActions(mob/living/user, human_occupant = 0)
	internals_action.Remove(user)
	cycle_action.Remove(user)
	lights_action.Remove(user)
	stats_action.Remove(user)
	strafing_action.Remove(user)

/obj/mecha/combat/neovgre/MouseDrop_T(mob/M, mob/user)
	if(!is_servant_of_ratvar(user))
		to_chat(user, "<span class='brass'>BEGONE HERETIC!</span>")
		return
	else
		..()

/obj/mecha/combat/neovgre/moved_inside(mob/living/carbon/human/H)
	var/list/Itemlist = H.get_contents()
	for(var/obj/item/clockwork/slab/W in Itemlist)
		to_chat(H, "<span class='brass'>You safely store [W] inside [src].</span>")
		qdel(W)
	. = ..()

/obj/mecha/combat/neovgre/obj_destruction()
	for(var/mob/M in src)
		to_chat(M, "<span class='brass'>You are consumed by the fires raging within Neovgre...</span>")
		M.dust()
	playsound(src, 'sound/magic/lightning_chargeup.ogg', 100, 0)
	src.visible_message("<span class = 'userdanger'>The reactor has gone critical, its going to blow!</span>")
	addtimer(CALLBACK(src,.proc/go_critical),breach_time)

/obj/mecha/combat/neovgre/proc/go_critical()
	explosion(get_turf(loc), 3, 5, 10, 20, 30)
	Destroy(src)

/obj/mecha/combat/neovgre/container_resist(mob/living/user)
	to_chat(user, "<span class='brass'>Neovgre requires a lifetime commitment friend, no backing out now!</span>")
	return

/obj/mecha/combat/neovgre/process()
	..()
	if(GLOB.ratvar_awakens) // At this point only timley intervention by lord singulo could hople to stop the superweapon
		cell.charge = INFINITY
		max_integrity = INFINITY
		obj_integrity = max_integrity
		CHECK_TICK //Just to be on the safe side lag wise
	else if(cell.charge < cell.maxcharge)
		for(var/obj/effect/clockwork/sigil/transmission/T in range(SIGIL_ACCESS_RANGE, src))
			var/delta = min(recharge_rate, cell.maxcharge - cell.charge)
			if (get_clockwork_power() <= delta)
				cell.charge += delta
				adjust_clockwork_power(-delta)
			CHECK_TICK

/obj/mecha/combat/neovgre/Initialize()
	.=..()
	GLOB.neovgre_exists ++
	var/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy/neovgre/N = new
	N.attach(src)

/obj/structure/mecha_wreckage/durand/neovgre
	name = "\improper Neovgre wreckage?"
	desc = "On closer inspection this looks like the wreck of a durand with some spraypainted cardboard duct taped to it!"

/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy/neovgre
	equip_cooldown = 8 //Rapid fire heavy laser cannon, simple yet elegant
	energy_drain = 30
	name = "Aribter Laser Cannon"
	desc = "Please re-attach this to neovgre and stop asking questions about why it looks like a normal Nanotrasen issue Solaris laser cannon - Nezbere"
	fire_sound = "sound/weapons/neovgre_laser.ogg"

/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy/neovgre/can_attach(obj/mecha/combat/neovgre/M)
	if(istype(M))
		return 1
	return 0
