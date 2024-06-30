#define DEPT_BITFLAG_COM (1<<0)
#define DEPARTMENT_COMMAND "Command"
#define DEPT_BITFLAG_CIV (1<<1)
#define DEPARTMENT_CIVILIAN "Civilian"
#define DEPT_BITFLAG_SRV (1<<2)
#define DEPARTMENT_SERVICE "Service"
#define DEPT_BITFLAG_CAR (1<<3)
#define DEPARTMENT_CARGO "Cargo"
#define DEPT_BITFLAG_SCI (1<<4)
#define DEPARTMENT_SCIENCE "Science"
#define DEPT_BITFLAG_ENG (1<<5)
#define DEPARTMENT_ENGINEERING "Engineering"
#define DEPT_BITFLAG_MED (1<<6)
#define DEPARTMENT_MEDICAL "Medical"
#define DEPT_BITFLAG_SEC (1<<7)
#define DEPARTMENT_SECURITY "Security"
#define DEPT_BITFLAG_VIP (1<<8)
#define DEPARTMENT_VIP "VIP"
#define DEPT_BITFLAG_SILICON  (1<<9)
#define DEPARTMENT_SILICON "Silicon"
#define DEPT_BITFLAG_CENTCOM (1<<10)
#define DEPARTMENT_CENTCOM "CentCom"
#define DEPT_BITFLAG_OTHER (1<<11)
#define DEPARTMENT_OTHER "Other"


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
#define DEPT_MANIFEST_ORDER_OTHER 999 // not used but just in case


#define DEPT_PREF_ORDER_COMMAND 10
#define DEPT_PREF_ORDER_SECURITY 20
#define DEPT_PREF_ORDER_ENGINEERING 30
#define DEPT_PREF_ORDER_MEDICAL 40
#define DEPT_PREF_ORDER_SCIENCE 50
#define DEPT_PREF_ORDER_CARGO 60
#define DEPT_PREF_ORDER_SERVICE 70
#define DEPT_PREF_ORDER_CIVILIAN 80
#define DEPT_PREF_ORDER_SILICON 90


#define DEPT_AUTHCHECK_DOMINANT "dominant"
#define DEPT_AUTHCHECK_SUPERVISOR "supervisor"
#define DEPT_AUTHCHECK_ACCESS_MANAGER "domi_super"
#define DEPT_AUTHCHECK_MANIFEST "manifest"
#define DEPT_AUTHCHECK_BUDGET "budget"

GLOBAL_LIST_INIT(dept_name_all_station_dept_list, list(
	DEPARTMENT_COMMAND,
	DEPARTMENT_CIVILIAN,
	DEPARTMENT_SERVICE,
	DEPARTMENT_CARGO,
	DEPARTMENT_SCIENCE,
	DEPARTMENT_ENGINEERING,
	DEPARTMENT_MEDICAL,
	DEPARTMENT_SECURITY,
	DEPARTMENT_VIP,
	DEPARTMENT_SILICON))

/// A list of each bitflag and the name of its associated department. For use in the preferences menu.
GLOBAL_LIST_INIT(dept_bitflag_to_name, list(
	"[DEPT_BITFLAG_COM]" = "Command",
	"[DEPT_BITFLAG_CIV]" = "Civilian",
	"[DEPT_BITFLAG_SRV]" = "Service",
	"[DEPT_BITFLAG_CAR]" = "Cargo",
	"[DEPT_BITFLAG_SCI]" = "Science",
	"[DEPT_BITFLAG_ENG]" = "Engineering",
	"[DEPT_BITFLAG_MED]" = "Medical",
	"[DEPT_BITFLAG_SEC]" = "Security",
	"[DEPT_BITFLAG_VIP]" = "Very Important People",
	"[DEPT_BITFLAG_SILICON]" = "Silicon"
))

/// A list of each department and its associated bitflag.
GLOBAL_LIST_INIT(departments, list(
	"Command" = DEPT_BITFLAG_COM,
	"Very Important People" = DEPT_BITFLAG_VIP,
	"Security" = DEPT_BITFLAG_SEC,
	"Engineering" = DEPT_BITFLAG_ENG,
	"Medical" = DEPT_BITFLAG_MED,
	"Science" = DEPT_BITFLAG_SCI,
	"Supply" = DEPT_BITFLAG_CAR,
	"Cargo" = DEPT_BITFLAG_CAR, // code seems to switch between calling it Supply and Cargo. not going to fix that today, let's just split the difference.
	"Service" = DEPT_BITFLAG_SRV,
	"Civilian" = DEPT_BITFLAG_CIV,
	"Silicon" = DEPT_BITFLAG_SILICON
))
