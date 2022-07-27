// This proc is only used in `PDApainter.dm`, but for better readability, it's declared as global proc and stored here.
// This returns a card icon style by given job name. Check `card.dmi` for the card list.
/proc/get_cardstyle_by_jobname(jobname)
	if(!jobname)
		CRASH("The proc has taken a null value")

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
		"Scientist" = "sci",
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
	return id_style[jobname] || "noname" // default: a card with no shape

// This returns a hud icon (from `hud.dmi`) by given job name.
// Some custom title is from `PDApainter.dm`. You neec to check it if you're going to remove custom job.
/proc/get_hud_by_jobname(jobname)
	if(!jobname)
		CRASH("The proc has taken a null value")

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
	return id_to_hud[jobname] || JOB_HUD_UNKNOWN // default: a grey unknown hud

// This returns a department for banking system by given hud icon.
// currently used in `card.dm` and `PDApainter.dm` to set a card's paycheck department
/proc/get_department_by_hud(jobname)
	if(!jobname)
		CRASH("The proc has taken a null value")

	var/static/hud_to_department_acc = list(
		// Command
		JOB_HUD_RAWCOMMAND = ACCOUNT_SEC,
		JOB_HUD_CAPTAIN = ACCOUNT_SEC,
		JOB_HUD_ACTINGCAPTAIN = ACCOUNT_SEC,

		// Service + Civilian
		JOB_HUD_RAWSERVICE = ACCOUNT_SRV,
		JOB_HUD_HEADOFPERSONNEL = ACCOUNT_SRV,
		JOB_HUD_ASSISTANT = ACCOUNT_CIV,
		JOB_HUD_BARTENDER = ACCOUNT_SRV,
		JOB_HUD_COOK = ACCOUNT_SRV,
		JOB_HUD_BOTANIST = ACCOUNT_SRV,
		JOB_HUD_CURATOR = ACCOUNT_CIV,
		JOB_HUD_CHAPLAIN = ACCOUNT_CIV,
		JOB_HUD_JANITOR = ACCOUNT_SRV,
		JOB_HUD_LAWYER = ACCOUNT_CIV,
		JOB_HUD_MIME = ACCOUNT_SRV,
		JOB_HUD_CLOWN = ACCOUNT_SRV,
		JOB_HUD_STAGEMAGICIAN = ACCOUNT_SRV,
		JOB_HUD_BARBER = ACCOUNT_CIV,

		// Cargo
		JOB_HUD_RAWCARGO = ACCOUNT_CAR,
		JOB_HUD_QUARTERMASTER = ACCOUNT_CAR,
		JOB_HUD_CARGOTECHNICIAN = ACCOUNT_CAR,
		JOB_HUD_SHAFTMINER = ACCOUNT_CAR,

		// R&D
		JOB_HUD_RAWSCIENCE = ACCOUNT_SCI,
		JOB_HUD_RESEARCHDIRECTOR = ACCOUNT_SCI,
		JOB_HUD_SCIENTIST = ACCOUNT_SCI,
		JOB_HUD_ROBOTICIST = ACCOUNT_SCI,
		JOB_HUD_EXPLORATIONCREW = ACCOUNT_SCI,

		// Engineering
		JOB_HUD_RAWENGINEERING = ACCOUNT_ENG,
		JOB_HUD_CHIEFENGINEER = ACCOUNT_ENG,
		JOB_HUD_STATIONENGINEER = ACCOUNT_ENG,
		JOB_HUD_ATMOSPHERICTECHNICIAN = ACCOUNT_ENG,

		// Medical
		JOB_HUD_RAWMEDICAL = ACCOUNT_MED,
		JOB_HUD_CHEIFMEDICALOFFICIER = ACCOUNT_MED,
		JOB_HUD_MEDICALDOCTOR = ACCOUNT_MED,
		JOB_HUD_PARAMEDIC = ACCOUNT_MED,
		JOB_HUD_VIROLOGIST = ACCOUNT_MED,
		JOB_HUD_CHEMIST = ACCOUNT_MED,
		JOB_HUD_GENETICIST = ACCOUNT_MED,
		JOB_HUD_PSYCHIATRIST = ACCOUNT_MED,

		// Security
		JOB_HUD_RAWSECURITY = ACCOUNT_SEC,
		JOB_HUD_HEADOFSECURITY = ACCOUNT_SEC,
		JOB_HUD_SECURITYOFFICER = ACCOUNT_SEC,
		JOB_HUD_WARDEN = ACCOUNT_SEC,
		JOB_HUD_DETECTIVE = ACCOUNT_SEC,
		JOB_HUD_BRIGPHYSICIAN = ACCOUNT_SEC,
		JOB_HUD_DEPUTY = ACCOUNT_SEC,

		// CentCom
		JOB_HUD_RAWCENTCOM = ACCOUNT_CIV,
		JOB_HUD_CENTCOM = ACCOUNT_CIV,

		// ETC
		JOB_HUD_VIP = ACCOUNT_CIV,
		JOB_HUD_KING = ACCOUNT_CIV,
		JOB_HUD_SYNDICATE = ACCOUNT_CIV,
		JOB_HUD_UNKNOWN = ACCOUNT_CIV,
		JOB_HUD_PRISONER = ACCOUNT_CIV
	)
	return hud_to_department_acc[jobname] || ACCOUNT_CIV // default: Civ budget department

// used to determine chat color by HUD in `chatmessage.dm`
// Note: custom colors are what I really didn't put much attention into. feel free to change its color when you feel off.
/datum/chatmessage/proc/get_chatcolor_by_hud(jobname)
	if(!jobname)
		CRASH("The proc has taken a null value")

	var/static/hud_to_chatcolor = list(
		// Command
		JOB_HUD_RAWCOMMAND = JOB_CHATCOLOR_RAWCOMMAND,
		JOB_HUD_CAPTAIN = JOB_CHATCOLOR_CAPTAIN,
		JOB_HUD_ACTINGCAPTAIN  = JOB_CHATCOLOR_ACTINGCAPTAIN,

		// Service
		JOB_HUD_RAWSERVICE = JOB_CHATCOLOR_RAWSERVICE,
		JOB_HUD_HEADOFPERSONNEL = JOB_CHATCOLOR_HEADOFPERSONNEL,
		JOB_HUD_ASSISTANT = JOB_CHATCOLOR_ASSISTANT,
		JOB_HUD_BARTENDER = JOB_CHATCOLOR_BARTENDER,
		JOB_HUD_COOK = JOB_CHATCOLOR_COOK,
		JOB_HUD_BOTANIST = JOB_CHATCOLOR_BOTANIST,
		JOB_HUD_CURATOR = JOB_CHATCOLOR_CURATOR,
		JOB_HUD_CHAPLAIN = JOB_CHATCOLOR_CHAPLAIN,
		JOB_HUD_JANITOR = JOB_CHATCOLOR_JANITOR,
		JOB_HUD_LAWYER = JOB_CHATCOLOR_LAWYER,
		JOB_HUD_MIME = JOB_CHATCOLOR_MIME,
		JOB_HUD_CLOWN = JOB_CHATCOLOR_CLOWN,
		JOB_HUD_STAGEMAGICIAN = JOB_CHATCOLOR_STAGEMAGICIAN,
		JOB_HUD_BARBER = JOB_CHATCOLOR_BARBER,

		// Cargo
		JOB_HUD_RAWCARGO = JOB_CHATCOLOR_RAWCARGO,
		JOB_HUD_QUARTERMASTER = JOB_CHATCOLOR_QUARTERMASTER,
		JOB_HUD_CARGOTECHNICIAN = JOB_CHATCOLOR_CARGOTECHNICIAN,
		JOB_HUD_SHAFTMINER = JOB_CHATCOLOR_SHAFTMINER,

		// R&D
		JOB_HUD_RAWSCIENCE = JOB_CHATCOLOR_RAWSCIENCE,
		JOB_HUD_RESEARCHDIRECTOR = JOB_CHATCOLOR_RESEARCHDIRECTOR,
		JOB_HUD_SCIENTIST = JOB_CHATCOLOR_SCIENTIST,
		JOB_HUD_ROBOTICIST = JOB_CHATCOLOR_ROBOTICIST,
		JOB_HUD_EXPLORATIONCREW = JOB_CHATCOLOR_EXPLORATIONCREW,

		// Engineering
		JOB_HUD_RAWENGINEERING = JOB_CHATCOLOR_RAWENGINEERING,
		JOB_HUD_CHIEFENGINEER = JOB_CHATCOLOR_CHIEFENGINEER,
		JOB_HUD_STATIONENGINEER = JOB_CHATCOLOR_STATIONENGINEER,
		JOB_HUD_ATMOSPHERICTECHNICIAN = JOB_CHATCOLOR_ATMOSPHERICTECHNICIAN,

		// Medical
		JOB_HUD_RAWMEDICAL = JOB_CHATCOLOR_RAWMEDICAL,
		JOB_HUD_CHEIFMEDICALOFFICIER = JOB_CHATCOLOR_CHEIFMEDICALOFFICIER,
		JOB_HUD_MEDICALDOCTOR = JOB_CHATCOLOR_MEDICALDOCTOR,
		JOB_HUD_PARAMEDIC = JOB_CHATCOLOR_PARAMEDIC,
		JOB_HUD_VIROLOGIST = JOB_CHATCOLOR_VIROLOGIST,
		JOB_HUD_CHEMIST = JOB_CHATCOLOR_CHEMIST,
		JOB_HUD_GENETICIST = JOB_CHATCOLOR_GENETICIST,
		JOB_HUD_PSYCHIATRIST = JOB_CHATCOLOR_PSYCHIATRIST,

		// Security
		JOB_HUD_RAWSECURITY = JOB_CHATCOLOR_RAWSECURITY,
		JOB_HUD_HEADOFSECURITY = JOB_CHATCOLOR_HEADOFSECURITY,
		JOB_HUD_WARDEN = JOB_CHATCOLOR_WARDEN,
		JOB_HUD_SECURITYOFFICER = JOB_CHATCOLOR_SECURITYOFFICER,
		JOB_HUD_DETECTIVE = JOB_CHATCOLOR_DETECTIVE,
		JOB_HUD_BRIGPHYSICIAN = JOB_CHATCOLOR_BRIGPHYSICIAN,
		JOB_HUD_DEPUTY = JOB_CHATCOLOR_DEPUTY,

		// CentCom
		JOB_HUD_RAWCENTCOM = JOB_CHATCOLOR_RAWCENTCOM,
		JOB_HUD_CENTCOM = JOB_CHATCOLOR_CENTCOM,

		// ETC
		JOB_HUD_VIP = JOB_CHATCOLOR_VIP,
		JOB_HUD_KING = JOB_CHATCOLOR_KING,
		JOB_HUD_SYNDICATE = JOB_CHATCOLOR_SYNDICATE,
		JOB_HUD_NOTCENTCOM = JOB_CHATCOLOR_NOTCENTCOM,
		JOB_HUD_PRISONER = JOB_CHATCOLOR_PRISONER,
		JOB_HUD_UNKNOWN = JOB_CHATCOLOR_UNKNOWN
	)
	return hud_to_chatcolor[jobname] || JOB_CHATCOLOR_UNKNOWN

