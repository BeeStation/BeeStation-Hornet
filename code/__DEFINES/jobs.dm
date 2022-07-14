
#define ENGSEC			(1<<0)

#define CAPTAIN			(1<<0)
#define HOS				(1<<1)
#define WARDEN			(1<<2)
#define DETECTIVE		(1<<3)
#define OFFICER			(1<<4)
#define CHIEF			(1<<5)
#define ENGINEER		(1<<6)
#define ATMOSTECH		(1<<7)
#define ROBOTICIST		(1<<8)
#define AI_JF			(1<<9)
#define CYBORG			(1<<10)
#define BRIG_PHYS		(1<<11)
#define DEPUTY  		(1<<12)


#define MEDSCI			(1<<1)

#define RD_JF			(1<<0)
#define SCIENTIST		(1<<1)
#define EXPLORATION_CREW (1<<2)
#define CHEMIST			(1<<3)
#define CMO_JF			(1<<4)
#define DOCTOR			(1<<5)
#define GENETICIST		(1<<6)
#define VIROLOGIST		(1<<7)
#define EMT				(1<<8)


#define CIVILIAN		(1<<2)

#define HOP				(1<<0)
#define BARTENDER		(1<<1)
#define BOTANIST		(1<<2)
#define COOK			(1<<3)
#define JANITOR			(1<<4)
#define CURATOR			(1<<5)
#define QUARTERMASTER	(1<<6)
#define CARGOTECH		(1<<7)
#define MINER			(1<<8)
#define LAWYER			(1<<9)
#define CHAPLAIN		(1<<10)
#define CLOWN			(1<<11)
#define MIME			(1<<12)
#define ASSISTANT		(1<<13)
#define GIMMICK 		(1<<14)
#define BARBER		    (1<<15)
#define MAGICIAN        (1<<16)
#define SHRINK          (1<<17)
#define CELEBRITY       (1<<18)

#define JOB_AVAILABLE 0
#define JOB_UNAVAILABLE_GENERIC 1
#define JOB_UNAVAILABLE_BANNED 2
#define JOB_UNAVAILABLE_PLAYTIME 3
#define JOB_UNAVAILABLE_ACCOUNTAGE 4
#define JOB_UNAVAILABLE_SLOTFULL 5

#define DEFAULT_RELIGION "Christianity"
#define DEFAULT_DEITY "Space Jesus"

#define JOB_DISPLAY_ORDER_DEFAULT 0

#define JOB_DISPLAY_ORDER_ASSISTANT 1
#define JOB_DISPLAY_ORDER_CAPTAIN 2
#define JOB_DISPLAY_ORDER_HEAD_OF_PERSONNEL 3
#define JOB_DISPLAY_ORDER_QUARTERMASTER 4
#define JOB_DISPLAY_ORDER_CARGO_TECHNICIAN 5
#define JOB_DISPLAY_ORDER_SHAFT_MINER 6
#define JOB_DISPLAY_ORDER_BARTENDER 7
#define JOB_DISPLAY_ORDER_COOK 8
#define JOB_DISPLAY_ORDER_BOTANIST 9
#define JOB_DISPLAY_ORDER_JANITOR 10
#define JOB_DISPLAY_ORDER_CLOWN 11
#define JOB_DISPLAY_ORDER_MIME 12
#define JOB_DISPLAY_ORDER_CURATOR 13
#define JOB_DISPLAY_ORDER_LAWYER 14
#define JOB_DISPLAY_ORDER_CHAPLAIN 15
#define JOB_DISPLAY_ORDER_CHIEF_ENGINEER 16
#define JOB_DISPLAY_ORDER_STATION_ENGINEER 17
#define JOB_DISPLAY_ORDER_ATMOSPHERIC_TECHNICIAN 18
#define JOB_DISPLAY_ORDER_CHIEF_MEDICAL_OFFICER 19
#define JOB_DISPLAY_ORDER_MEDICAL_DOCTOR 20
#define JOB_DISPLAY_ORDER_CHEMIST 21
#define JOB_DISPLAY_ORDER_GENETICIST 22
#define JOB_DISPLAY_ORDER_VIROLOGIST 23
#define JOB_DISPLAY_ORDER_RESEARCH_DIRECTOR 24
#define JOB_DISPLAY_ORDER_SCIENTIST 25
#define JOB_DISPLAY_ORDER_EXPLORATION 26
#define JOB_DISPLAY_ORDER_ROBOTICIST 27
#define JOB_DISPLAY_ORDER_HEAD_OF_SECURITY 28
#define JOB_DISPLAY_ORDER_WARDEN 29
#define JOB_DISPLAY_ORDER_DETECTIVE 30
#define JOB_DISPLAY_ORDER_SECURITY_OFFICER 31
#define JOB_DISPLAY_ORDER_BRIG_PHYS 32
#define JOB_DISPLAY_ORDER_DEPUTY 33
#define JOB_DISPLAY_ORDER_AI 34
#define JOB_DISPLAY_ORDER_CYBORG 35

#define DEPARTMENT_SECURITY (1<<0)
#define DEPARTMENT_COMMAND (1<<1)
#define DEPARTMENT_SERVICE (1<<2)
#define DEPARTMENT_CARGO (1<<3)
#define DEPARTMENT_ENGINEERING (1<<4)
#define DEPARTMENT_SCIENCE (1<<5)
#define DEPARTMENT_MEDICAL (1<<6)
#define DEPARTMENT_SILICON (1<<7)



////////// Job names based on hud icon names
// Command
#define JOB_HUD_RAWCOMMAND "rawcommand"
#define JOB_HUD_CAPTAIN  "captain"
#define JOB_HUD_ACTINGCAPTAIN  "actingcaptain"

// Service
#define JOB_HUD_RAWSERVICE "rawservice"
#define JOB_HUD_HEADOFPERSONNEL "headofpersonnel"
#define JOB_HUD_ASSISTANT "assistant"
#define JOB_HUD_BARTENDER "bartender"
#define JOB_HUD_COOK "cook"
#define JOB_HUD_BOTANIST "botanist"
#define JOB_HUD_CHAPLAIN "chaplain"
#define JOB_HUD_CURATOR "curator"
#define JOB_HUD_JANITOR "janitor"
#define JOB_HUD_LAWYER "lawyer"
#define JOB_HUD_MIME "mime"
#define JOB_HUD_CLOWN "clown"
#define JOB_HUD_STAGEMAGICIAN "stagemagician"
#define JOB_HUD_BARBER "barber"

// Cargo
#define JOB_HUD_RAWCARGO "rawcargo"
#define JOB_HUD_QUARTERMASTER "quartermaster"
#define JOB_HUD_CARGOTECHNICIAN "cargotechnician"
#define JOB_HUD_SHAFTMINER "shaftminer"

// R&D
#define JOB_HUD_RAWSCIENCE "rawscience"
#define JOB_HUD_RESEARCHDIRECTOR "researchdirector"
#define JOB_HUD_SCIENTIST "scientist"
#define JOB_HUD_ROBOTICIST "roboticist"
#define JOB_HUD_EXPLORATIONCREW "explorationcrew"

// Engineering
#define JOB_HUD_RAWENGINEERING "rawengineering"
#define JOB_HUD_CHIEFENGINEER "chiefengineer"
#define JOB_HUD_STATIONENGINEER "stationengineer"
#define JOB_HUD_ATMOSPHERICTECHNICIAN "atmospherictechnician"

// Medical
#define JOB_HUD_RAWMEDICAL "rawmedical"
#define JOB_HUD_CHEIFMEDICALOFFICIER "chiefmedicalofficer"
#define JOB_HUD_MEDICALDOCTOR "medicaldoctor"
#define JOB_HUD_PARAMEDIC "paramedic"
#define JOB_HUD_VIROLOGIST "virologist"
#define JOB_HUD_CHEMIST "chemist"
#define JOB_HUD_GENETICIST "geneticist"
#define JOB_HUD_PSYCHIATRIST "psychiatrist"

// Security
#define JOB_HUD_RAWSECURITY "rawsecurity"
#define JOB_HUD_HEADOFSECURITY "headofsecurity"
#define JOB_HUD_SECURITYOFFICER "securityofficer"
#define JOB_HUD_WARDEN "warden"
#define JOB_HUD_DETECTIVE "detective"
#define JOB_HUD_BRIGPHYSICIAN "brigphysician"
#define JOB_HUD_DEPUTY "deputy"

// CentCom
#define JOB_HUD_RAWCENTCOM "rawcentcom"
#define JOB_HUD_CENTCOM "centcom"
#define JOB_HUD_NOTCENTCOM "notcentcom" // used for police or something like

// MISC
#define JOB_HUD_VIP "vip"
#define JOB_HUD_KING "king"
#define JOB_HUD_SYNDICATE "syndicate"
#define JOB_HUD_PRISONER "prisoner"
#define JOB_HUD_UNKNOWN "unknown"


//////////// Color defines
// Command
#define JOB_CHATCOLOR_RAWCOMMAND    "#FFECCA" // custom command color
#define JOB_CHATCOLOR_CAPTAIN       "#FFDC9B"
#define JOB_CHATCOLOR_ACTINGCAPTAIN "#FFDC9B"

// Service
#define JOB_CHATCOLOR_RAWSERVICE      "#BFE4B0" // custom service color
#define JOB_CHATCOLOR_HEADOFPERSONNEL "#7979D3"
#define JOB_CHATCOLOR_ASSISTANT "#BDBDBD"
#define JOB_CHATCOLOR_BARTENDER "#B2CEB3"
#define JOB_CHATCOLOR_COOK      "#A2FBB9"
#define JOB_CHATCOLOR_BOTANIST  "#95DE85"
#define JOB_CHATCOLOR_CURATOR   "#88C999"
#define JOB_CHATCOLOR_CHAPLAIN  "#8AB48C"
#define JOB_CHATCOLOR_JANITOR   "#97FBEA"
#define JOB_CHATCOLOR_LAWYER    "#C07D7D"
#define JOB_CHATCOLOR_MIME      "#BAD3BB"
#define JOB_CHATCOLOR_CLOWN     "#FF83D7"
#define JOB_CHATCOLOR_STAGEMAGICIAN  "#B898B3"
#define JOB_CHATCOLOR_BARBER    "#BD9E86"

// Cargo
#define JOB_CHATCOLOR_RAWCARGO        "#ECCE9A" // custom cargo color
#define JOB_CHATCOLOR_QUARTERMASTER   "#C79C52"
#define JOB_CHATCOLOR_CARGOTECHNICIAN "#D3A372"
#define JOB_CHATCOLOR_SHAFTMINER      "#CE957E"

// R&D
#define JOB_CHATCOLOR_RAWSCIENCE       "#F3BFF3" // custom R&D color
#define JOB_CHATCOLOR_RESEARCHDIRECTOR "#974EA9"
#define JOB_CHATCOLOR_SCIENTIST        "#C772C7"
#define JOB_CHATCOLOR_ROBOTICIST       "#AC71BA"
#define JOB_CHATCOLOR_EXPLORATIONCREW  "#85D8B8"

// Engineering
#define JOB_CHATCOLOR_RAWENGINEERING        "#E9D1A8" // custom engineering color
#define JOB_CHATCOLOR_CHIEFENGINEER         "#CFBB72"
#define JOB_CHATCOLOR_STATIONENGINEER       "#D9BC89"
#define JOB_CHATCOLOR_ATMOSPHERICTECHNICIAN "#D4A07D"

// Medical
#define JOB_CHATCOLOR_RAWMEDICAL           "#B1E5EC" // custom medical color
#define JOB_CHATCOLOR_CHEIFMEDICALOFFICIER "#7A97DA"
#define JOB_CHATCOLOR_MEDICALDOCTOR "#6CB1C5"
#define JOB_CHATCOLOR_PARAMEDIC     "#8FBEB4"
#define JOB_CHATCOLOR_VIROLOGIST    "#75AEA3"
#define JOB_CHATCOLOR_CHEMIST       "#82BDCE"
#define JOB_CHATCOLOR_GENETICIST    "#83BBBF"
#define JOB_CHATCOLOR_PSYCHIATRIST  "#A2DFDC"

// Security
#define JOB_CHATCOLOR_RAWSECURITY     "#F3BDC0" // custom security color, has some color than deputy
#define JOB_CHATCOLOR_HEADOFSECURITY  "#D33049"
#define JOB_CHATCOLOR_WARDEN          "#EA545E"
#define JOB_CHATCOLOR_SECURITYOFFICER "#E6A3A3"
#define JOB_CHATCOLOR_DETECTIVE       "#C78B8B"
#define JOB_CHATCOLOR_BRIGPHYSICIAN   "#B16789"
#define JOB_CHATCOLOR_DEPUTY          "#FFEEEE"

// CentCom
#define JOB_CHATCOLOR_RAWCENTCOM "#A7F08F" // custom CC Color
#define JOB_CHATCOLOR_CENTCOM    "#90FD6D"

// ETC
#define JOB_CHATCOLOR_VIP        "#EBC96B"
#define JOB_CHATCOLOR_KING       "#DCEC49" // somehow golden?
#define JOB_CHATCOLOR_SYNDICATE  "#997272" // I really didn't care the color
#define JOB_CHATCOLOR_NOTCENTCOM "#6D6AEC" // i.e. space police
#define JOB_CHATCOLOR_PRISONER   "#D38A5C"
#define JOB_CHATCOLOR_UNKNOWN    "#DDA583" // grey hud icon gets this


// This proc is only used in `PDApainter.dm`, but for better readability, it's declared as global proc and stored here.
// This returns a card icon style by given job name. Check `card.dmi` for the card list.
/proc/get_cardstyle_by_jobname(jobname)
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

// This returns a hud icon (from `hud.dmi`) by given job name.
// Some custom title is from `PDApainter.dm`. You neec to check it if you're going to remove custom job.
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

// This returns a department for banking system by given hud icon.
// currently used in `card.dm` and `PDApainter.dm` to set a card's paycheck department
/proc/get_department_by_hud(jobname)
	if(jobname)
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
		if(jobname in hud_to_department_acc)
			return hud_to_department_acc[jobname]
	return ACCOUNT_CIV

// used to determine chat color by HUD in `chatmessage.dm`
// Note: custom colors are what I really didn't put much attention into. feel free to change its color when you feel off.
/datum/chatmessage/proc/get_chatcolor_by_hud(jobname)
	if(jobname)
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
		if(jobname in hud_to_chatcolor)
			return hud_to_chatcolor[jobname]
	return JOB_CHATCOLOR_UNKNOWN

