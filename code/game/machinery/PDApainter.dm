/obj/machinery/pdapainter
	name = "\improper Tablet & ID Painter"
	desc = "A painting machine that can be used to paint PDAs and IDs with ease. To use, simply insert the item and choose the desired preset."
	icon = 'icons/obj/pda.dmi'
	icon_state = "coloriser"
	max_integrity = 200
	density = TRUE
	/// Current ID card inserted into the machine.
	var/obj/item/card/id/stored_id_card = null
	/// Current PDA inserted into the machine.
	var/obj/item/modular_computer/tablet/pda/stored_pda = null
	var/pda_icons = list(
		"Misc: Neutral" = "pda",
		"Misc: Assistant" = "pda-assistant",
		"Command (Standard)" = "pda-heads",
		"Command: Captain" = "pda-captain",
		"Service (Standard)" = "pda-service",
		"Service: Head of Personnel" = "pda-hop",
		"Service: Bartender" = "pda-bartender",
		"Service: Chaplain" = "pda-chaplain",
		"Service: Clown" = "pda-clown",
		"Service: Cook" = "pda-cook",
		"Service: Curator" = "pda-library",
		"Service: Janitor" = "pda-janitor",
		"Service: Lawyer" = "pda-lawyer",
		"Service: Mime" = "pda-mime",
		"Cargo (Standard)" = "pda-cargo",
		"Cargo: Quartermaster" = "pda-qm",
		"Cargo: Cargo Technician" = "pda-cargo",
		"Cargo: Shaft Miner" = "pda-miner",
		"Engineering (Standard)" = "pda-engineer",
		"Engineering: Chief Engineer" = "pda-ce",
		"Engineering: Station Engineer" = "pda-engineer",
		"Engineering: Atmospheric Technician" = "pda-atmos",
		"Science (Standard)" = "pda-science",
		"Science: Research Director" = "pda-rd",
		"Science: Roboticist" = "pda-roboticist",
		"Science: Scienctist" = "pda-science",
		"Science: Exploration Crew" = "pda-exploration",
		"Medical (Standard)" = "pda-medical",
		"Medical: Chief Medical Officer" = "pda-cmo",
		"Medical: Medical Doctor" = "pda-medical",
		"Medical: Chemist" = "pda-chemistry",
		"Medical: Paramedic" = "pda-paramedical",
		"Medical: Geneticist" = "pda-genetics",
		"Medical: Virologist" = "pda-virology",
		"Security (Standard)" = "pda-security",
		"Security: Head of Security" = "pda-hos",
		"Security: Warden" = "pda-warden",
		"Security: Security Officier" = "pda-security",
		"Security: Detective" = "pda-detective",
		"Security: Brig Physician" = "pda-brigphys",
		"Security: Deputy" = "pda-deputy",
		"Misc: Prisoner" = "pda-prisoner"
	)

/obj/machinery/pdapainter/on_emag(mob/user)
	..()
	pda_icons += list(
		"Transparent" = "pda-clear",
		"Syndicate" = "pda-syndi"
	)
	to_chat(user, span_warning("You short out the design locking circuitry, allowing contraband and special designs."))

/obj/machinery/pdapainter/update_icon()
	cut_overlays()

	if(machine_stat & BROKEN)
		icon_state = "coloriser-broken"
		return

	if(stored_pda)
		add_overlay("coloriser-pda-in")

	if(stored_id_card)
		add_overlay("coloriser-id-in")

	if(powered())
		icon_state = initial(icon_state)
	else
		icon_state = "coloriser-off"

	return

/obj/machinery/pdapainter/Destroy()
	QDEL_NULL(stored_pda)
	QDEL_NULL(stored_id_card)
	return ..()

/obj/machinery/pdapainter/on_deconstruction()
	if(stored_pda)
		stored_pda.forceMove(loc)
		stored_pda = null
	if(stored_id_card)
		stored_id_card.forceMove(loc)
		stored_id_card = null

/obj/machinery/pdapainter/contents_explosion(severity, target)
	if(stored_pda)
		stored_pda.ex_act(severity, target)
	if(stored_id_card)
		stored_id_card.ex_act(severity, target)

/obj/machinery/pdapainter/handle_atom_del(atom/A)
	if(A == stored_pda)
		stored_pda = null
		update_icon()
	if(A == stored_id_card)
		stored_id_card = null
		update_icon()

/obj/machinery/pdapainter/attackby(obj/item/O, mob/living/user, params)
	if(default_unfasten_wrench(user, O))
		power_change()
		return

	else if(istype(O, /obj/item/modular_computer/tablet/pda))
		if(stored_pda)
			to_chat(user, span_warning("There is already a PDA inside!"))
			return
		else if(!user.transferItemToLoc(O, src))
			return
		stored_pda = O
		O.add_fingerprint(user)
		update_icon()

	else if(istype(O, /obj/item/card/id))
		var/obj/item/card/id/new_id = O
		if(!new_id.electric)
			return
		if(stored_id_card)
			to_chat(user, span_warning("There is already an ID card inside!"))
			return
		else if(!user.transferItemToLoc(O, src))
			return
		stored_id_card = O
		O.add_fingerprint(user)
		update_icon()

	else if(O.tool_behaviour == TOOL_WELDER && !user.combat_mode)
		if(machine_stat & BROKEN)
			if(!O.tool_start_check(user, amount=0))
				return
			user.visible_message("[user] is repairing [src].", \
							span_notice("You begin repairing [src]..."), \
							span_italics("You hear welding."))
			if(O.use_tool(src, user, 40, volume=50))
				if(!(machine_stat & BROKEN))
					return
				to_chat(user, span_notice("You repair [src]."))
				set_machine_stat(machine_stat & ~BROKEN)
				atom_integrity = max_integrity
				update_icon()
		else
			to_chat(user, span_notice("[src] does not need repairs."))
	else
		return ..()

/obj/machinery/pdapainter/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(stored_pda)
		eject_pda(user)
	else
		eject_id_card(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/pdapainter/deconstruct(disassembled = TRUE)
	atom_break()

/obj/machinery/pdapainter/attack_hand(mob/user, list/modifiers)
	if(!..())
		add_fingerprint(user)
		if(stored_pda || stored_id_card)
			if(stored_pda)
				var/newpdaskin
				newpdaskin = input(user, "Select a PDA skin!", "PDA Painting") as null|anything in pda_icons
				if(!newpdaskin)
					return
				if(!in_range(src, user))
					return
				if(!stored_pda)//is the pda still there?
					return
				stored_pda.icon_state = pda_icons[newpdaskin]
				eject_pda()
			if(stored_id_card)
				var/newidskin
				newidskin = input(user, "Select an ID skin!", "ID  Painting") as null|anything in get_card_style_list(obj_flags & EMAGGED)
				if(!newidskin)
					return
				if(newidskin[1] == "-")
					return
				if(!in_range(src, user))
					return
				if(!stored_id_card)//is the ID still there?
					return
				stored_id_card.icon_state = get_cardstyle_by_jobname(newidskin)
				stored_id_card.hud_state = get_hud_by_jobname(newidskin)

				// QoL to correct the system behavior
				GLOB.manifest.modify(stored_id_card.registered_name, stored_id_card.assignment, stored_id_card.hud_state) // update crew manifest
				// There are the same code lines in `card.dm`
				eject_id_card(user)
		else
			to_chat(user, span_notice("[src] is empty."))

/obj/machinery/pdapainter/AltClick(mob/user)
	if(!user.canUseTopic(src, !issilicon(user)) || user.stat != CONSCIOUS || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	if(stored_pda || stored_id_card)
		eject_id_card(user)
		eject_pda()
		to_chat(usr, span_notice("You eject the contents."))
	else
		to_chat(usr, span_notice("[src] is empty."))


/**
 * Eject the stored PDA into the user's hands if possible, otherwise on the floor.
 *
 * Arguments:
 * * user - The user to try and eject the PDA into the hands of.
 */
/obj/machinery/pdapainter/proc/eject_pda(mob/living/user)
	if(stored_pda)
		if(user && !issilicon(user) && in_range(src, user))
			user.put_in_hands(stored_pda)
		else
			stored_pda.forceMove(drop_location())

		stored_pda = null
		update_icon()

/obj/machinery/pdapainter/add_context_self(datum/screentip_context/context, mob/user, obj/item/item)
	if(stored_pda || stored_id_card)
		context.add_attack_hand_action("Paint Item")
		context.add_attack_hand_secondary_action("Eject Item")
	else
		context.add_left_click_item_action("Insert", /obj/item/modular_computer/tablet/pda)
		context.add_left_click_item_action("Insert", /obj/item/card/id)
	if (machine_stat & BROKEN)
		context.add_left_click_tool_action("Repair", TOOL_WELDER)
	context.add_generic_unfasten_actions(src)

/**
 * Eject the stored ID card into the user's hands if possible, otherwise on the floor.
 *
 * Arguments:
 * * user - The user to try and eject the ID card into the hands of.
 */
/obj/machinery/pdapainter/proc/eject_id_card(mob/living/user)
	if(stored_id_card)
		if(user && !issilicon(user) && in_range(src, user))
			user.put_in_hands(stored_id_card)
		else
			stored_id_card.forceMove(drop_location())

		stored_id_card = null
		update_appearance(UPDATE_ICON)

/proc/get_card_style_list(emagged)
	var/static/valid_jobs = list(
		"----Command----", "Command (Custom)",JOB_NAME_CAPTAIN,"Acting Captain",
		"----Service----", "Service (Custom)", JOB_NAME_ASSISTANT, JOB_NAME_HEADOFPERSONNEL, JOB_NAME_BARTENDER, JOB_NAME_COOK,
			JOB_NAME_BOTANIST, JOB_NAME_JANITOR, JOB_NAME_CURATOR,JOB_NAME_CHAPLAIN, JOB_NAME_LAWYER,
			JOB_NAME_CLOWN, JOB_NAME_MIME, JOB_NAME_BARBER, JOB_NAME_STAGEMAGICIAN,
		"----Cargo----","Cargo (Custom)",JOB_NAME_QUARTERMASTER, JOB_NAME_CARGOTECHNICIAN,JOB_NAME_SHAFTMINER,
		"----Engineering----","Engineering (Custom)",JOB_NAME_CHIEFENGINEER, JOB_NAME_STATIONENGINEER, JOB_NAME_ATMOSPHERICTECHNICIAN,
		"----Science----","Science (Custom)",JOB_NAME_RESEARCHDIRECTOR, JOB_NAME_SCIENTIST, JOB_NAME_ROBOTICIST, JOB_NAME_EXPLORATIONCREW,
		"----Medical----","Medical (Custom)",JOB_NAME_CHIEFMEDICALOFFICER, JOB_NAME_MEDICALDOCTOR, JOB_NAME_CHEMIST, JOB_NAME_GENETICIST,
			JOB_NAME_VIROLOGIST, JOB_NAME_PARAMEDIC, JOB_NAME_PSYCHIATRIST,
		"----Security----","Security (Custom)",JOB_NAME_HEADOFSECURITY, JOB_NAME_WARDEN, JOB_NAME_DETECTIVE, JOB_NAME_SECURITYOFFICER,
			JOB_NAME_BRIGPHYSICIAN, JOB_NAME_DEPUTY,
		"----MISC----","Unassigned",JOB_NAME_PRISONER
	)
	var/static/emagged_jobs = list(
		"CentCom (Custom)",
		"CentCom",
		"ERT",
		"VIP",
		"King",
		"Syndicate Agent",
		"Clown Operative"
	)
	if(emagged)
		return valid_jobs+emagged_jobs
	return valid_jobs
