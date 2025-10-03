// station departments
#define DEPT_NAME_COMMAND "Command"
#define DEPT_BITFLAG_COM (1<<0)
#define DEPT_NAME_CIVILIAN "Civilian"
#define DEPT_BITFLAG_CIV (1<<1)
#define DEPT_NAME_SERVICE "Service"
#define DEPT_BITFLAG_SRV (1<<2)
#define DEPT_NAME_CARGO "Cargo"
#define DEPT_BITFLAG_CAR (1<<3)
#define DEPT_NAME_SCIENCE "Science"
#define DEPT_BITFLAG_SCI (1<<4)
#define DEPT_NAME_ENGINEERING "Engineering"
#define DEPT_BITFLAG_ENG (1<<5)
#define DEPT_NAME_MEDICAL "Medical"
#define DEPT_BITFLAG_MED (1<<6)
#define DEPT_NAME_SECURITY "Security"
#define DEPT_BITFLAG_SEC (1<<7)
#define DEPT_NAME_VIP "VIP"
#define DEPT_BITFLAG_VIP (1<<8)
#define DEPT_NAME_SILICON "Silicon"
#define DEPT_BITFLAG_SILICON  (1<<9)
#define DEPT_NAME_UNASSIGNED "Misc"
#define DEPT_BITFLAG_UNASSIGNED (1<<10)

#define DEPT_NAME_CENTCOM "CentCom"
#define DEPT_BITFLAG_CENTCOM (1<<11)
#define DEPT_NAME_OTHER "Other"
#define DEPT_BITFLAG_OTHER (1<<12)

// not real department. These exist for pref grouping
#define DEPT_NAME_ASSISTANT "Assistant"
#define DEPT_NAME_CAPTAIN "Captain"


// Crew Manifest will show crew data in this order
// in favour of our downstreams, sort order is increased by 10, so that they can add anything between these (i.e NSV munition dept)
#define DEPT_MANIFEST_ORDER_COMMAND 10
#define DEPT_MANIFEST_ORDER_CENTCOM 13 // generally it won't be used
#define DEPT_MANIFEST_ORDER_VIP 16
#define DEPT_MANIFEST_ORDER_SECURITY 20
#define DEPT_MANIFEST_ORDER_ENGINEERING 30
#define DEPT_MANIFEST_ORDER_MEDICAL 40
#define DEPT_MANIFEST_ORDER_SCIENCE 50
#define DEPT_MANIFEST_ORDER_CARGO 60
#define DEPT_MANIFEST_ORDER_SERVICE 70
#define DEPT_MANIFEST_ORDER_CIVILIAN 80
#define DEPT_MANIFEST_ORDER_SILICON 90
#define DEPT_MANIFEST_ORDER_UNASSIGNED 666 // dummy department for people with no department


// used for /mob/dead/new_player/authenticated/proc/LateChoices()
#define DEPT_PREF_ORDER_COMMAND 	10
#define DEPT_PREF_ORDER_SECURITY 	20
#define DEPT_PREF_ORDER_ENGINEERING 30
#define DEPT_PREF_ORDER_MEDICAL 	40
#define DEPT_PREF_ORDER_SCIENCE 	50
#define DEPT_PREF_ORDER_CARGO 		60
#define DEPT_PREF_ORDER_SERVICE 	70
#define DEPT_PREF_ORDER_CIVILIAN 	80
#define DEPT_PREF_ORDER_SILICON 	90
