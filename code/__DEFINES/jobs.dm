
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
#define PARAMEDIC		(1<<8)


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
#define PSYCHIATRIST    (1<<17)
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


#define DEPARTMENT_BITFLAG_COMMAND (1<<0)
#define DEPARTMENT_BITFLAG_SERVICE (1<<1)
#define DEPARTMENT_BITFLAG_CARGO   (1<<2)
#define DEPARTMENT_BITFLAG_ENGINEERING (1<<3)
#define DEPARTMENT_BITFLAG_MEDICAL  (1<<4)
#define DEPARTMENT_BITFLAG_SCIENCE  (1<<5)
#define DEPARTMENT_BITFLAG_SECURITY (1<<6)
#define DEPARTMENT_BITFLAG_SILICON  (1<<7)

//-------------------------------------------------------------------------------------------
//------------------------------------- Job names -------------------------------------------
//-------------------------------------------------------------------------------------------
// Command
#define JOB_NAME_CAPTAIN "Captain"

// Service
#define JOB_NAME_HEADOFPERSONNEL "Head of Personnel"
#define JOB_NAME_ASSISTANT  "Assistant"
#define JOB_NAME_BARTENDER  "Bartender"
#define JOB_NAME_BOTANIST   "Botanist"
#define JOB_NAME_COOK     "Cook"
#define JOB_NAME_JANITOR  "Janitor"
#define JOB_NAME_CURATOR  "Curator"
#define JOB_NAME_LAWYER   "Lawyer"
#define JOB_NAME_CHAPLAIN "Chaplain"
#define JOB_NAME_MIME   "Mime"
#define JOB_NAME_CLOWN  "Clown"
#define JOB_NAME_STAGEMAGICIAN "Stage Magician" // gimmick
#define JOB_NAME_BARBER "Barber" // gimmick
#define JOB_NAME_VIP    "VIP" // gimmick

// Cargo
#define JOB_NAME_QUARTERMASTER   "Quartermaster"
#define JOB_NAME_CARGOTECHNICIAN "Cargo Technician"
#define JOB_NAME_SHAFTMINER      "Shaft Miner"

// Engineering
#define JOB_NAME_CHIEFENGINEER   "Chief Engineer"
#define JOB_NAME_STATIONENGINEER "Station Engineer"
#define JOB_NAME_ATMOSPHERICTECHNICIAN "Atmospheric Technician"

// Medical
#define JOB_NAME_CHIEFMEDICALOFFICER "Chief Medical Officer"
#define JOB_NAME_MEDICALDOCTOR "Medical Doctor"
#define JOB_NAME_PARAMEDIC  "Paramedic"
#define JOB_NAME_CHEMIST    "Chemist"
#define JOB_NAME_VIROLOGIST "Virologist"
#define JOB_NAME_GENETICIST "Geneticist"
#define JOB_NAME_BRIGPHYSICIAN "Brig Physician"
#define JOB_NAME_PSYCHIATRIST  "Psychiatrist" // gimmick

// R&D
#define JOB_NAME_RESEARCHDIRECTOR "Research Director"
#define JOB_NAME_SCIENTIST  "Scientist"
#define JOB_NAME_ROBOTICIST "Roboticist"
#define JOB_NAME_EXPLORATIONCREW "Exploration Crew"

// Security
#define JOB_NAME_HEADOFSECURITY "Head of Security"
#define JOB_NAME_WARDEN "Warden"
#define JOB_NAME_SECURITYOFFICER "Security Officer"
#define JOB_NAME_DETECTIVE "Detective"
#define JOB_NAME_DEPUTY  "Deputy"

// Silicon
#define JOB_NAME_AI     "AI"
#define JOB_NAME_CYBORG "Cyborg"
#define JOB_NAME_PAI    "Personal AI"

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

// Misc & Off-Station
#define JOB_NAME_GIMMICK "Gimmick" // gimmick
#define JOB_NAME_KING    "King"
#define JOB_NAME_PRISONER "Prisoner"
#define JOB_SPACE_POLICE "Space Police"



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

// R&D
#define JOB_HUD_RAWSCIENCE "rawscience"
#define JOB_HUD_RESEARCHDIRECTOR "researchdirector"
#define JOB_HUD_SCIENTIST "scientist"
#define JOB_HUD_ROBOTICIST "roboticist"
#define JOB_HUD_EXPLORATIONCREW "explorationcrew"

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

// R&D
#define JOB_CHATCOLOR_RAWSCIENCE       "#F3BFF3" // custom R&D color
#define JOB_CHATCOLOR_RESEARCHDIRECTOR "#974EA9"
#define JOB_CHATCOLOR_SCIENTIST        "#C772C7"
#define JOB_CHATCOLOR_ROBOTICIST       "#AC71BA"
#define JOB_CHATCOLOR_EXPLORATIONCREW  "#85D8B8"

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
