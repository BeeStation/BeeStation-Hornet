/obj/machinery/pdapainter
	name = "\improper color manipulator"
	desc = "A machine able to color PDAs and IDs with ease. Insert an ID card or PDA and pick a color scheme."
	icon = 'icons/obj/pda.dmi'
	icon_state = "coloriser"
	max_integrity = 200
	density = TRUE
	anchored = TRUE
	var/obj/item/pda/storedpda = null
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

	var/valid_jobs = list(
		"----Command----","Command (Custom)", "Captain", "Acting Captain",
		"----Service----","Service (Custom)", "Assistant", "Head of Personnel", "Bartender", "Cook", "Botanist", "Janitor", "Curator",
		"Chaplain", "Lawyer", "Clown", "Mime", "Barber", "Stage Magician",
		"----Cargo----","Cargo (Custom)","Quartermaster", "Cargo Technician","Shaft Miner",
		"----Engineering----","Engineering (Custom)","Chief Engineer", "Station Engineer", "Atmospheric Technician",
		"----Science----","Science (Custom)","Research Director", "Scientist", "Roboticist", "Exploration Crew",
		"----Medical----","Medical (Custom)","Chief Medical Officer", "Medical Doctor", "Chemist", "Geneticist", "Virologist", "Paramedic", "Psychiatrist",
		"----Security----","Security (Custom)","Head of Security", "Warden", "Detective", "Security Officer", "Brig Physician", "Deputy",
		"----MISC----","Unassigned","Prisoner"
		)
	max_integrity = 200
	var/list/colorlist = list()

/obj/machinery/pdapainter/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	pda_icons += list(
		"Transparent" = "pda-clear",
		"Syndicate" = "pda-syndi"
		)
	valid_jobs += list(
		"CentCom (Custom)",
		"CentCom",
		"ERT",
		"VIP",
		"KING",
		"Syndicate",
		"Clown Operative"
		)
	to_chat(user, "<span class='warning'>You short out the design locking circuitry, allowing contraband and special designs.</span>")
	obj_flags |= EMAGGED
/obj/machinery/pdapainter/update_icon()
	cut_overlays()

	if(stat & BROKEN)
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
		/obj/item/pda/ai/pai,
		/obj/item/pda/ai,
		/obj/item/pda/heads,
		/obj/item/pda/clear,
		/obj/item/pda/syndicate,
		/obj/item/pda/chameleon,
		/obj/item/pda/chameleon/broken)

	for(var/P in typesof(/obj/item/pda) - blocked)
		var/obj/item/pda/D = new P

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

	else if(istype(O, /obj/item/pda))
		if(storedpda)
			to_chat(user, "<span class='warning'>There is already a PDA inside!</span>")
			return
		else if(!user.transferItemToLoc(O, src))
			return
		storedpda = O
		O.add_fingerprint(user)
		update_icon()

	else if(istype(O, /obj/item/card/id))
		if(storedid)
			to_chat(user, "<span class='warning'>There is already an ID card inside!</span>")
			return
		else if(!user.transferItemToLoc(O, src))
			return
		storedid = O
		O.add_fingerprint(user)
		update_icon()

	else if(O.tool_behaviour == TOOL_WELDER && user.a_intent != INTENT_HARM)
		if(stat & BROKEN)
			if(!O.tool_start_check(user, amount=0))
				return
			user.visible_message("[user] is repairing [src].", \
							"<span class='notice'>You begin repairing [src]...</span>", \
							"<span class='italics'>You hear welding.</span>")
			if(O.use_tool(src, user, 40, volume=50))
				if(!(stat & BROKEN))
					return
				to_chat(user, "<span class='notice'>You repair [src].</span>")
				stat &= ~BROKEN
				obj_integrity = max_integrity
				update_icon()
		else
			to_chat(user, "<span class='notice'>[src] does not need repairs.</span>")
	else
		return ..()

/obj/machinery/pdapainter/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(!(stat & BROKEN))
			stat |= BROKEN
			update_icon()

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
				newidskin = input(user, "Select an ID skin!", "ID  Painting") as null|anything in valid_jobs
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
				GLOB.data_core.manifest_modify(storedid.registered_name, storedid.assignment, storedid.hud_state)
				ejectid()
		else
			to_chat(user, "<span class='notice'>[src] is empty.</span>")

/obj/machinery/pdapainter/AltClick(mob/user)
	if(usr.stat || usr.restrained())
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


/obj/machinery/pdapainter/proc/get_cardstyle_by_jobname(jobname)
	if(jobname)
		var/static/id_style = list(
			// Command
			"Command (Custom)" = "captain",
			"Captain" = "captain",
			"Acting Captain" = "captain",
			// Service
			"Service (Custom)" = "rawservice",
			"Head of Personnel" = "hop",
			"Assistant" = "id",
			"Botanist" = "serv",
			"Bartender" = "serv",
			"Cook" = "serv",
			"Janitor" = "janitor",
			"Curator" = "chap",
			"Chaplain" = "chap",
			"Lawyer" = "lawyer",
			"Clown" = "clown",
			"Mime" = "mime",
			"Stage Magician" = "serv",
			"Barber" = "serv",
			// Cargo
			"Cargo (Custom)" = "rawcargo",
			"Quartermaster" = "qm",
			"Cargo Technician" = "cargo",
			"Shaft Miner" = "miner",
			// R&D
			"Science (Custom)" = "rawscience",
			"Research Director" = "rd",
			"Science" = "sci",
			"Roboticist" = "roboticist",
			"Exploration Crew" = "exploration",
			// Engineering
			"Engineering (Custom)" = "rawengineering",
			"Chief Engineer" = "ce",
			"Station Engineer" = "engi",
			"Atmospheric Technician" = "atmos",
			// Medical
			"Medical (Custom)" = "rawmedical",
			"Chief Medical Officer" = "cmo",
			"Medical Doctor" = "med",
			"Paramedic" = "paramed",
			"Virologist" = "viro",
			"Geneticist" = "gene",
			"Chemist" = "chemist",
			"Psychiatrist" = "med",
			// Security
			"Security (Custom)" = "rawsecurity",
			"Head of Security" = "hos",
			"Security Officer" = "sec",
			"Warden" = "warden",
			"Detective" = "detective",
			"Brig Physician" = "brigphys",
			"Deputy" = "deputy",
			// ETC
			"Unassigned" = "id",
			"Prisoner" = "orange",
			// EMAG
			"CentCom (Custom)" = "centcom",
			"CentCom" = "centcom",
			"ERT" = "ert",
			"VIP" = "gold",
			"King" = "gold",
			"Syndicate" = "syndicate",
			"Clown Operative" = "clown_op",
			"Unknown" = "unknown",
			// ETC2
			"Ratvar" = "ratvar"
			)
		if(jobname in id_style)
			return id_style[jobname]
	return "noname"

/proc/get_hud_by_jobname(jobname)
	if(jobname)
		var/static/id_to_hud = list(
			// Command
			"Command (Custom)" = JOB_HUD_RAWCOMMAND,
			"Captain" = JOB_HUD_CAPTAIN,
			"Acting Captain" = JOB_HUD_ACTINGCAPTAIN ,

			// Service
			"Service (Custom)" = JOB_HUD_RAWSERVICE,
			"Head of Personnel" = JOB_HUD_HEADOFPERSONNEL,
			"Assistant" = JOB_HUD_ASSISTANT,
			"Bartender" = JOB_HUD_BARTENDER,
			"Cook" = JOB_HUD_COOK,
			"Botanist" = JOB_HUD_BOTANIST,
			"Curator" = JOB_HUD_CURATOR,
			"Chaplain" = JOB_HUD_CHAPLAIN,
			"Janitor" = JOB_HUD_JANITOR,
			"Lawyer" = JOB_HUD_LAWYER,
			"Mime" = JOB_HUD_MIME,
			"Clown" = JOB_HUD_CLOWN,
			"Stage Magician" = JOB_HUD_STAGEMAGICIAN,
			"Barber" = JOB_HUD_BARBER,

			// Cargo
			"Cargo (Custom)" = JOB_HUD_RAWCARGO,
			"Quartermaster" = JOB_HUD_QUARTERMASTER,
			"Cargo Technician" = JOB_HUD_CARGOTECHNICIAN,
			"Shaft Miner" = JOB_HUD_SHAFTMINER,

			// R&D
			"Science (Custom)" = JOB_HUD_RAWSCIENCE,
			"Research Director" = JOB_HUD_RESEARCHDIRECTOR,
			"Scientist" = JOB_HUD_SCIENTIST,
			"Roboticist" = JOB_HUD_ROBOTICIST,
			"Exploration Crew" = JOB_HUD_EXPLORATIONCREW,

			// Engineering
			"Engineering (Custom)" = JOB_HUD_RAWENGINEERING,
			"Chief Engineer" = JOB_HUD_CHIEFENGINEER,
			"Station Engineer" = JOB_HUD_STATIONENGINEER,
			"Atmospheric Technician" = JOB_HUD_ATMOSPHERICTECHNICIAN,

			// Medical
			"Medical (Custom)" = JOB_HUD_RAWMEDICAL,
			"Chief Medical Officer" = JOB_HUD_CHEIFMEDICALOFFICIER,
			"Medical Doctor" = JOB_HUD_MEDICALDOCTOR,
			"Paramedic" = JOB_HUD_PARAMEDIC,
			"Virologist" = JOB_HUD_VIROLOGIST,
			"Chemist" = JOB_HUD_CHEMIST,
			"Geneticist" = JOB_HUD_GENETICIST,
			"Psychiatrist" = JOB_HUD_PSYCHIATRIST,

			// Security
			"Security (Custom)" = JOB_HUD_RAWSECURITY,
			"Head of Security" = JOB_HUD_HEADOFSECURITY,
			"Security Officer" = JOB_HUD_SECURITYOFFICER,
			"Warden" = JOB_HUD_WARDEN,
			"Detective" = JOB_HUD_DETECTIVE,
			"Brig Physician" = JOB_HUD_BRIGPHYSICIAN,
			"Deputy" = JOB_HUD_DEPUTY,

			// CentCom
			"CentCom (Custom)" = JOB_HUD_RAWCENTCOM,
			"CentCom" = JOB_HUD_CENTCOM,
			"ERT" = JOB_HUD_CENTCOM,

			// ETC
			"VIP" = JOB_HUD_VIP,
			"King" = JOB_HUD_KING,
			"Syndicate" = JOB_HUD_SYNDICATE,
			"Clown Operative" = JOB_HUD_SYNDICATE,
			"Unassigned" = JOB_HUD_UNKNOWN,
			"Prisoner" = JOB_HUD_PRISONER
			)
		if(jobname in id_to_hud)
			return id_to_hud[jobname]
	return JOB_HUD_UNKNOWN
