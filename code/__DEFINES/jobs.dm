
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



// Job names based on hud icon names
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

// MISC
#define JOB_HUD_VIP "vip"
#define JOB_HUD_KING "king"
#define JOB_HUD_SYNDICATE "syndicate"
#define JOB_HUD_PRISONER "prisoner"
#define JOB_HUD_UNKNOWN "unknown"
