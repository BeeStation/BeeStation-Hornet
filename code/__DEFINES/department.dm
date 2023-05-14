#define DEPT_NAME_COMMAND "Command"
#define DEPT_BITFLAG_COMMAND (1<<0)

#define DEPT_NAME_CIVILIAN "Civilian"
#define DEPT_BITFLAG_CIVILIAN (1<<1)

#define DEPT_NAME_SERVICE "Service"
#define DEPT_BITFLAG_SERVICE (1<<2)

#define DEPT_NAME_SUPPLY "Supply"
#define DEPT_BITFLAG_SUPPLY (1<<3)

#define DEPT_NAME_SCIENCE "Science"
#define DEPT_BITFLAG_SCIENCE (1<<4)

#define DEPT_NAME_ENGINEERING "Engineering"
#define DEPT_BITFLAG_ENGINEERING (1<<5)

#define DEPT_NAME_MEDICAL "Medical"
#define DEPT_BITFLAG_MEDICAL (1<<6)

#define DEPT_NAME_SECURITY "Security"
#define DEPT_BITFLAG_SECURITY (1<<7)

#define DEPT_NAME_SILICON "Silicon"
#define DEPT_BITFLAG_SILICON (1<<8)

#define DEPT_NAME_VIP "VIP"
#define DEPT_BITFLAG_VIP (1<<9)

#define DEPT_NAME_CENTCOM "CentCom"
#define DEPT_BITFLAG_CENTCOM (1<<10)

#define DEPT_NAME_OTHER "Other"
#define DEPT_BITFLAG_OTHER (1<<11)



// Crew Manifest will show crew data in this order
// in favour of our downstreams, sort order is increased by 10, so that they can add anything between these (i.e NSV munition dept)
#define DEPT_MANIFEST_ORDER_COMMAND 10
#define DEPT_MANIFEST_ORDER_CENTCOM 13 // generally it won't be used
#define DEPT_MANIFEST_ORDER_VIP 16
#define DEPT_MANIFEST_ORDER_SECURITY 20
#define DEPT_MANIFEST_ORDER_ENGINEERING 30
#define DEPT_MANIFEST_ORDER_MEDICAL 40
#define DEPT_MANIFEST_ORDER_SCIENCE 50
#define DEPT_MANIFEST_ORDER_SUPPLY 60
#define DEPT_MANIFEST_ORDER_SERVICE 70
#define DEPT_MANIFEST_ORDER_CIVILIAN 80
#define DEPT_MANIFEST_ORDER_SILICON 90 // not used - can be used if we want silicons in datacore
#define DEPT_MANIFEST_ORDER_OTHER 999 // not used but just in case


#define DEPT_PREF_ORDER_COMMAND 10
#define DEPT_PREF_ORDER_SECURITY 20
#define DEPT_PREF_ORDER_ENGINEERING 30
#define DEPT_PREF_ORDER_MEDICAL 40
#define DEPT_PREF_ORDER_SCIENCE 50
#define DEPT_PREF_ORDER_SUPPLY 60
#define DEPT_PREF_ORDER_SERVICE 70
#define DEPT_PREF_ORDER_CIVILIAN 80
#define DEPT_PREF_ORDER_SILICON 90


#define DEPT_AUTHCHECK_DOMINANT "dominant"
#define DEPT_AUTHCHECK_SUPERVISOR "supervisor"
#define DEPT_AUTHCHECK_ACCESS_MANAGER "domi_super"
#define DEPT_AUTHCHECK_MANIFEST "manifest"
#define DEPT_AUTHCHECK_BUDGET "budget"
