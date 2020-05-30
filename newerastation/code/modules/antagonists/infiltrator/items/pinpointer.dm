//yoinked from hippie (infiltrators)
#define MODE_CUTTER 1
#define MODE_TARGET 2

/obj/item/pinpointer/infiltrator
	name = "infiltration pinpointer"
	icon = 'icons/obj/device.dmi'
	var/upgraded = FALSE
	var/datum/team/team
	var/mode = MODE_CUTTER
	var/current_target

/obj/item/pinpointer/infiltrator/Initialize()
	. = ..()
	current_target = SSshuttle.getShuttle("syndicatecutter")
	scan_for_target()
	update_icon()

/obj/item/pinpointer/infiltrator/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It is tracking [mode == MODE_CUTTER ? "the syndicate cutter" : "an objective target"].</span>"

/obj/item/pinpointer/infiltrator/scan_for_target()
	target = current_target
	..()

/obj/item/pinpointer/infiltrator/proc/check_menu(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

/obj/item/pinpointer/infiltrator/proc/get_targets()
	var/list/targets = list()
	if(team && LAZYLEN(team.objectives))
		for(var/A in team.objectives)
			var/datum/objective/O = A
			if(istype(O) && !O.check_completion())
				if(istype(O.target, /datum/mind))
					var/datum/mind/M = O.target
					targets[M.current.real_name] = M.current
				else if(istype(O, /datum/objective/steal))
					var/datum/objective/steal/S = O
					targets[S.targetinfo.name] = locate(S.targetinfo.targetitem)
	return targets

/obj/item/pinpointer/infiltrator/attack_self(mob/user)
	if(!upgraded)
		return ..()
	if(!active)
		active = TRUE
		START_PROCESSING(SSfastprocess, src)
	var/list/radial_list = list()
	var/list/targets = get_targets()
	for(var/A in targets)
		if(istype(targets[A], /mob))
			radial_list[A] = getFlatIcon(targets[A])
		else if(istype(targets[A], /atom))
			var/atom/AT = targets[A]
			radial_list[A] = image(AT.icon, AT.icon_state)
	radial_list["ship"] = image(icon = 'icons/turf/shuttle.dmi', icon_state = "burst_s")
	var/chosen = show_radial_menu(user, src, radial_list, custom_check = CALLBACK(src, .proc/check_menu, user))
	if(!check_menu(user))
		return
	if(chosen)
		if (chosen == "ship")
			current_target = SSshuttle.getShuttle("syndicatecutter")
		else
			current_target = targets[chosen]
	scan_for_target()
	update_icon()

/obj/item/pinpointer/infiltrator/attackby(obj/item/I, mob/user, params)
	if(!upgraded && istype(I, /obj/item/infiltrator_pinpointer_upgrade) && user.mind)
		var/datum/antagonist/infiltrator/DAI = user.mind.has_antag_datum(ANTAG_DATUM_INFILTRATOR)
		if(!DAI || !DAI.infiltrator_team)
			return ..()
		team = DAI.infiltrator_team
		icon = 'newerastation/icons/obj/device.dmi'
		icon_state = "pinpointer_upgraded"
		upgraded = TRUE
		to_chat(user, "<span class='notice'>You attach the new antenna to [src].</span>")
		qdel(I)
	else
		return ..()



/obj/item/infiltrator_pinpointer_upgrade
	name = "infiltration pinpointer upgrade"
	desc = "Upgrades your pinpointer to allow for tracking objective targets."
	icon = 'newerastation/icons/obj/device.dmi'
	icon_state = "shitty_antenna"

#undef MODE_CUTTER
#undef MODE_TARGET
