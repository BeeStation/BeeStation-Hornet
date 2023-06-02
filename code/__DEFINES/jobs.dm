// RL PK = Role List 'Primary Key'
#define RLPK_DISPLAY_STATION_ROLE "title_station_role"
#define RLPK_DISPLAY_SPECIAL_ROLE "title_special_role"
#define RLPK_HOLDER_JOBS "jobs"
#define RLPK_HOLDER_SPECIAL_ROLES "special_roles"

/*
	// Display types: these are for aesthestics
		mind_roles[RLPK_DISPLAY_STATION_ROLE] // Your station job. Only used for displaying purpose (i.e Roundend)
		mind_roles[RLPK_DISPLAY_SPECIAL_ROLE] // Your special job. Only used for displaying purpose as well

	// Holder types: these can possibly contain multiple list inside of itself.
		mind_roles[RLPK_HOLDER_JOBS] // Your jobs. The top one is mostly prioritised
		mind_roles[RLPK_HOLDER_SPECIAL_ROLES] // Your 'special' roles

	// Example:
		"Chaplain of Honkmother" job will be like this

	```
		mind_roles[RLPK_DISPLAY_STATION_ROLE] = "Chaplain of Honkmother"
		mind_roles[RLPK_HOLDER_JOBS][JOB_KEY_CLOWNCHAP] = JOB_KEY_CLOWNCHAP // top one
		mind_roles[RLPK_HOLDER_JOBS][JOB_KEY_CLOWN] = JOB_KEY_CLOWN
		mind_roles[RLPK_HOLDER_JOBS][JOB_KEY_CHAPLAIN] = JOB_KEY_CHAPLAIN

		mind_roles[RLPK_DISPLAY_SPECIAL_ROLE] = "Traitor, Changeling"
		mind_roles[RLPK_HOLDER_SPECIAL_ROLES][ROLE_KEY_TRAITOR] = ROLE_KEY_TRAITOR // and you are a traitor!
		mind_roles[RLPK_HOLDER_SPECIAL_ROLES][ROLE_KEY_CHANGELING] = ROLE_KEY_CHANGELING // and maybe ling too!
	```
*/

// used in job_bitflags
#define JOB_BITFLAG_SELECTABLE (1<<0) // basically given to all 'standard' jobs (not gimmicks). if a gimmick job has with this flag, it will be shown in 'job pref' window and people can join a round with that job.
#define JOB_BITFLAG_GIMMICK  (1<<1) // basically given to all gimmick jobs. this is alwo used to block HoP to touch the amount of a job
#define JOB_BITFLAG_MANAGE_LOCKED (1<<2) // this flag blocks job manager control. given to heads and silicon job

// return values for job selection results
#define JOB_AVAILABLE 0
#define JOB_UNAVAILABLE_GENERIC 1
#define JOB_UNAVAILABLE_BANNED 2
#define JOB_UNAVAILABLE_PLAYTIME 3
#define JOB_UNAVAILABLE_ACCOUNTAGE 4
#define JOB_UNAVAILABLE_SLOTFULL 5
#define JOB_UNAVAILABLE_NOT_INTRODUCED 6

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


// Bitflags for department crew manifest for each job
// should check the ones in `\_DEFINES\economy.dm`
// It's true that bitflags shouldn't be separated in two DEFINES if these are same, but just in case the system can be devided, it's remained separated.
#define DEPT_BITFLAG_COM (1<<0)
#define DEPT_BITFLAG_CIV (1<<1)
#define DEPT_BITFLAG_SRV (1<<2)
#define DEPT_BITFLAG_CAR (1<<3)
#define DEPT_BITFLAG_SCI (1<<4)
#define DEPT_BITFLAG_ENG (1<<5)
#define DEPT_BITFLAG_MED (1<<6)
#define DEPT_BITFLAG_SEC (1<<7)
#define DEPT_BITFLAG_VIP (1<<8)
#define DEPT_BITFLAG_SILICON  (1<<9) // currently not used, but remained here just in case someone wants it

//-------------------------------------------------------------------------------------------
//------------------------------------- Job names -------------------------------------------
//-------------------------------------------------------------------------------------------
// ****** WARNING:
// 	   DO NOT CHANGE KEY. You are fine to change TITLE defines, but DO NOT DO to KEY defines
#define JOB_UNASSIGNED "Unassigned"
#define JOB_DEMOTED "Demoted"

// Command
#define JOB_TITLE_CAPTAIN "Captain"
#define JOB_KEY_CAPTAIN "Captain"

// Service
#define JOB_TITLE_HEADOFPERSONNEL "Head of Personnel"
#define JOB_KEY_HEADOFPERSONNEL "Head of Personnel"
#define JOB_TITLE_ASSISTANT  "Assistant"
#define JOB_KEY_ASSISTANT  "Assistant"
#define JOB_TITLE_BARTENDER  "Bartender"
#define JOB_KEY_BARTENDER  "Bartender"
#define JOB_TITLE_BOTANIST   "Botanist"
#define JOB_KEY_BOTANIST   "Botanist"
#define JOB_TITLE_COOK     "Cook"
#define JOB_KEY_COOK     "Cook"
#define JOB_TITLE_JANITOR  "Janitor"
#define JOB_KEY_JANITOR  "Janitor"
#define JOB_TITLE_CURATOR  "Curator"
#define JOB_KEY_CURATOR  "Curator"
#define JOB_TITLE_LAWYER   "Lawyer"
#define JOB_KEY_LAWYER   "Lawyer"
#define JOB_TITLE_CHAPLAIN "Chaplain"
#define JOB_KEY_CHAPLAIN "Chaplain"
#define JOB_TITLE_MIME   "Mime"
#define JOB_KEY_MIME   "Mime"
#define JOB_TITLE_CLOWN  "Clown"
#define JOB_KEY_CLOWN  "Clown"
#define JOB_TITLE_STAGEMAGICIAN "Stage Magician" // gimmick
#define JOB_KEY_STAGEMAGICIAN "Stage Magician" // gimmick
#define JOB_TITLE_BARBER "Barber" // gimmick
#define JOB_KEY_BARBER "Barber" // gimmick
#define JOB_TITLE_VIP    "VIP" // gimmick
#define JOB_KEY_VIP    "VIP" // gimmick

// Cargo
#define JOB_TITLE_QUARTERMASTER   "Quartermaster"
#define JOB_KEY_QUARTERMASTER   "Quartermaster"
#define JOB_TITLE_CARGOTECHNICIAN "Cargo Technician"
#define JOB_KEY_CARGOTECHNICIAN "Cargo Technician"
#define JOB_TITLE_SHAFTMINER      "Shaft Miner"
#define JOB_KEY_SHAFTMINER      "Shaft Miner"

// R&D
#define JOB_TITLE_RESEARCHDIRECTOR "Research Director"
#define JOB_KEY_RESEARCHDIRECTOR "Research Director"
#define JOB_TITLE_SCIENTIST  "Scientist"
#define JOB_KEY_SCIENTIST  "Scientist"
#define JOB_TITLE_ROBOTICIST "Roboticist"
#define JOB_KEY_ROBOTICIST "Roboticist"
#define JOB_TITLE_EXPLORATIONCREW "Exploration Crew"
#define JOB_KEY_EXPLORATIONCREW "Exploration Crew"

// Engineering
#define JOB_TITLE_CHIEFENGINEER   "Chief Engineer"
#define JOB_KEY_CHIEFENGINEER   "Chief Engineer"
#define JOB_TITLE_STATIONENGINEER "Station Engineer"
#define JOB_KEY_STATIONENGINEER "Station Engineer"
#define JOB_TITLE_ATMOSPHERICTECHNICIAN "Atmospheric Technician"
#define JOB_KEY_ATMOSPHERICTECHNICIAN "Atmospheric Technician"

// Medical
#define JOB_TITLE_CHIEFMEDICALOFFICER "Chief Medical Officer"
#define JOB_KEY_CHIEFMEDICALOFFICER "Chief Medical Officer"
#define JOB_TITLE_MEDICALDOCTOR "Medical Doctor"
#define JOB_KEY_MEDICALDOCTOR "Medical Doctor"
#define JOB_TITLE_PARAMEDIC  "Paramedic"
#define JOB_KEY_PARAMEDIC  "Paramedic"
#define JOB_TITLE_CHEMIST    "Chemist"
#define JOB_KEY_CHEMIST    "Chemist"
#define JOB_TITLE_VIROLOGIST "Virologist"
#define JOB_KEY_VIROLOGIST "Virologist"
#define JOB_TITLE_GENETICIST "Geneticist"
#define JOB_KEY_GENETICIST "Geneticist"
#define JOB_TITLE_BRIGPHYSICIAN "Brig Physician"
#define JOB_KEY_BRIGPHYSICIAN "Brig Physician"
#define JOB_TITLE_PSYCHIATRIST  "Psychiatrist" // gimmick
#define JOB_KEY_PSYCHIATRIST  "Psychiatrist" // gimmick

// Security
#define JOB_TITLE_HEADOFSECURITY "Head of Security"
#define JOB_KEY_HEADOFSECURITY "Head of Security"
#define JOB_TITLE_WARDEN "Warden"
#define JOB_KEY_WARDEN "Warden"
#define JOB_TITLE_SECURITYOFFICER "Security Officer"
#define JOB_KEY_SECURITYOFFICER "Security Officer"
#define JOB_TITLE_DETECTIVE "Detective"
#define JOB_KEY_DETECTIVE "Detective"
#define JOB_TITLE_DEPUTY  "Deputy"
#define JOB_KEY_DEPUTY  "Deputy"

// Silicon
#define JOB_TITLE_AI     "AI"
#define JOB_KEY_AI     "AI"
#define JOB_TITLE_CYBORG "Cyborg"
#define JOB_KEY_CYBORG "Cyborg"

// Misc & Off-Station
#define JOB_TITLE_KING    "King"
#define JOB_TITLE_PRISONER "Prisoner"
#define JOB_SPACE_POLICE "Space Police"

// ERTs
#define JOB_ERT_DEATHSQUAD      "Death Commando"
#define JOB_ERT_COMMANDER       "Emergency Response Team Commander"
#define JOB_ERT_OFFICER         "Security Response Officer"
#define JOB_ERT_ENGINEER        "Engineering Response Officer"
#define JOB_ERT_MEDICAL_DOCTOR  "Medical Response Officer"
#define JOB_ERT_CHAPLAIN        "Religious Response Officer"
#define JOB_ERT_JANITOR         "Janitorial Response Officer"

// CentCom
#define JOB_CENTCOM_CENTRAL_COMMAND "Central Command"
#define JOB_CENTCOM_OFFICIAL  "CentCom Official"
#define JOB_CENTCOM_ADMIRAL   "Admiral"
#define JOB_CENTCOM_COMMANDER "CentCom Commander"
#define JOB_CENTCOM_VIP       "VIP Guest"
#define JOB_CENTCOM_BARTENDER "CentCom Bartender"
#define JOB_CENTCOM_CUSTODIAN "Custodian"
#define JOB_CENTCOM_THUNDERDOME_OVERSEER "Thunderdome Overseer"
#define JOB_CENTCOM_MEDICAL_DOCTOR   "Medical Officer"
#define JOB_CENTCOM_RESEARCH_OFFICER "Research Officer"



//-------------------------------------------------------------------------------------------
//---------------------------------------- HUD ----------------------------------------------
//-------------------------------------------------------------------------------------------
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
#define JOB_HUD_COOK     "cook"
#define JOB_HUD_BOTANIST "botanist"
#define JOB_HUD_CHAPLAIN "chaplain"
#define JOB_HUD_CURATOR  "curator"
#define JOB_HUD_JANITOR  "janitor"
#define JOB_HUD_LAWYER   "lawyer"
#define JOB_HUD_MIME  "mime"
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
#define JOB_HUD_PAPER "paper"


//////////// Color defines
// Command
#define JOB_CHATCOLOR_RAWCOMMAND    "#AFB4D3" // custom command color
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
