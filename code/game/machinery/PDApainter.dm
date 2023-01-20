/obj/machinery/pdapainter
	name = "\improper color manipulator"
	desc = "A machine able to color PDAs and IDs with ease. Insert an ID card or PDA and pick a color scheme."
	icon = 'icons/obj/pda.dmi'
	icon_state = "coloriser"
	max_integrity = 200
	density = TRUE
	anchored = TRUE
	var/obj/item/modular_computer/tablet/pda/storedpda = null
	var/obj/item/card/id/storedid = null
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
	max_integrity = 200
	var/list/colorlist = list()

/obj/machinery/pdapainter/on_emag(mob/user)
	..()
	pda_icons += list(
		"Transparent" = "pda-clear",
		"Syndicate" = "pda-syndi"
	)
	to_chat(user, "<span class='warning'>You short out the design locking circuitry, allowing contraband and special designs.</span>")

/obj/machinery/pdapainter/update_icon()
	cut_overlays()

	if(machine_stat & BROKEN)
		icon_state = "coloriser-broken"
		return

	if(storedpda)
		add_overlay("coloriser-pda-in")

	if(storedid)
		add_overlay("coloriser-id-in")

	if(powered())
		icon_state = initial(icon_state)
	else
		icon_state = "coloriser-off"

	return

/obj/machinery/pdapainter/Initialize(mapload)
	. = ..()
	var/list/blocked = list(
		/obj/item/modular_computer/tablet/pda/heads,
		/obj/item/modular_computer/tablet/pda/clear,
		/obj/item/modular_computer/tablet/pda/syndicate,
		/obj/item/modular_computer/tablet/pda/chameleon,
		/obj/item/modular_computer/tablet/pda/chameleon/broken)

	for(var/P in typesof(/obj/item/modular_computer/tablet/pda) - blocked)
		var/obj/item/modular_computer/tablet/pda/D = new P

		//D.name = "PDA Style [colorlist.len+1]" //Gotta set the name, otherwise it all comes up as "PDA"
		D.name = D.icon_state //PDAs don't have unique names, but using the sprite names works.

		src.colorlist += D

/obj/machinery/pdapainter/Destroy()
	QDEL_NULL(storedpda)
	QDEL_NULL(storedid)
	return ..()

/obj/machinery/pdapainter/on_deconstruction()
	if(storedpda)
		storedpda.forceMove(loc)
		storedpda = null
	if(storedid)
		storedid.forceMove(loc)
		storedid = null

/obj/machinery/pdapainter/contents_explosion(severity, target)
	if(storedpda)
		storedpda.ex_act(severity, target)
	if(storedid)
		storedid.ex_act(severity, target)

/obj/machinery/pdapainter/handle_atom_del(atom/A)
	if(A == storedpda)
		storedpda = null
		update_icon()
	if(A == storedid)
		storedid = null
		update_icon()

/obj/machinery/pdapainter/attackby(obj/item/O, mob/user, params)
	if(default_unfasten_wrench(user, O))
		power_change()
		return

	else if(istype(O, /obj/item/modular_computer/tablet/pda))
		if(storedpda)
			to_chat(user, "<span class='warning'>There is already a PDA inside!</span>")
			return
		else if(!user.transferItemToLoc(O, src))
			return
		storedpda = O
		O.add_fingerprint(user)
		update_icon()

	else if(istype(O, /obj/item/card/id))
		var/obj/item/card/id/new_id = O
		if(!new_id.electric)
			return
		if(storedid)
			to_chat(user, "<span class='warning'>There is already an ID card inside!</span>")
			return
		else if(!user.transferItemToLoc(O, src))
			return
		storedid = O
		O.add_fingerprint(user)
		update_icon()

	else if(O.tool_behaviour == TOOL_WELDER && user.a_intent != INTENT_HARM)
		if(machine_stat & BROKEN)
			if(!O.tool_start_check(user, amount=0))
				return
			user.visible_message("[user] is repairing [src].", \
							"<span class='notice'>You begin repairing [src]...</span>", \
							"<span class='italics'>You hear welding.</span>")
			if(O.use_tool(src, user, 40, volume=50))
				if(!(machine_stat & BROKEN))
					return
				to_chat(user, "<span class='notice'>You repair [src].</span>")
				set_machine_stat(machine_stat & ~BROKEN)
				obj_integrity = max_integrity
				update_icon()
		else
			to_chat(user, "<span class='notice'>[src] does not need repairs.</span>")
	else
		return ..()

/obj/machinery/pdapainter/deconstruct(disassembled = TRUE)
	obj_break()

/obj/machinery/pdapainter/attack_hand(mob/user)
	if(!..())
		add_fingerprint(user)
		if(storedpda || storedid)
			if(storedpda)
				var/newpdaskin
				newpdaskin = input(user, "Select a PDA skin!", "PDA Painting") as null|anything in pda_icons
				if(!newpdaskin)
					return
				if(!in_range(src, user))
					return
				if(!storedpda)//is the pda still there?
					return
				storedpda.icon_state = pda_icons[newpdaskin]
				ejectpda()
			if(storedid)
				var/newidskin
				newidskin = input(user, "Select an ID skin!", "ID  Painting") as null|anything in get_card_style_list(obj_flags & EMAGGED)
				if(!newidskin)
					return
				if(newidskin[1] == "-")
					return
				if(!in_range(src, user))
					return
				if(!storedid)//is the ID still there?
					return
				storedid.icon_state = get_cardstyle_by_jobname(newidskin)
				storedid.hud_state = get_hud_by_jobname(newidskin)

				// QoL to correct the system behavior
				GLOB.data_core.manifest_modify(storedid.registered_name, storedid.assignment, storedid.hud_state) // update crew manifest
				// There are the same code lines in `card.dm`
				ejectid()
		else
			to_chat(user, "<span class='notice'>[src] is empty.</span>")

/obj/machinery/pdapainter/AltClick(mob/user)
	if(!user.canUseTopic(src, !issilicon(user)) || usr.stat || usr.restrained())
		return
	if(storedpda || storedid)
		ejectid()
		ejectpda()
		to_chat(usr, "<span class='notice'>You eject the contents.</span>")
	else
		to_chat(usr, "<span class='notice'>[src] is empty.")


/obj/machinery/pdapainter/proc/ejectpda()
	if(storedpda)
		storedpda.forceMove(drop_location())
		storedpda = null
		update_icon()
	else
		to_chat(usr, "<span class='notice'>[src] is empty.</span>")

/obj/machinery/pdapainter/proc/ejectid()
	if(storedid)
		storedid.loc = get_turf(src.loc)
		storedid = null
		update_icon()

/obj/machinery/pdapainter/power_change()
	..()
	update_icon()


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
