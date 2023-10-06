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
	"[DEPT_BITFLAG_SILICON]" = "Silicon",
	"[DEPT_BITFLAG_CAPTAIN]" = "Captain",
	"[DEPT_BITFLAG_ASSISTANT]" = "Assistant"
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
