/// A list of each bitflag and the name of its associated department. For use in the preferences menu.
GLOBAL_LIST_INIT(dept_bitflag_to_name, list(
	"[DEPARTMENT_BITFLAG_COMMAND]" = "Command",
	"[DEPARTMENT_BITFLAG_CIVILIAN]" = "Civilian",
	"[DEPARTMENT_BITFLAG_SERVICE]" = "Service",
	"[DEPARTMENT_BITFLAG_CARGO]" = "Cargo",
	"[DEPARTMENT_BITFLAG_SCIENCE]" = "Science",
	"[DEPARTMENT_BITFLAG_ENGINEERING]" = "Engineering",
	"[DEPARTMENT_BITFLAG_MEDICAL]" = "Medical",
	"[DEPARTMENT_BITFLAG_SECURITY]" = "Security",
	"[DEPARTMENT_BITFLAG_VIP]" = "Very Important People",
	"[DEPARTMENT_BITFLAG_SILICON]" = "Silicon"
))

/// A list of each department and its associated bitflag.
GLOBAL_LIST_INIT(departments, list(
	"Command" = DEPARTMENT_BITFLAG_COMMAND,
	"Very Important People" = DEPARTMENT_BITFLAG_VIP,
	"Security" = DEPARTMENT_BITFLAG_SECURITY,
	"Engineering" = DEPARTMENT_BITFLAG_ENGINEERING,
	"Medical" = DEPARTMENT_BITFLAG_MEDICAL,
	"Science" = DEPARTMENT_BITFLAG_SCIENCE,
	"Supply" = DEPARTMENT_BITFLAG_CARGO,
	"Cargo" = DEPARTMENT_BITFLAG_CARGO, // code seems to switch between calling it Supply and Cargo. not going to fix that today, let's just split the difference.
	"Service" = DEPARTMENT_BITFLAG_SERVICE,
	"Civilian" = DEPARTMENT_BITFLAG_CIVILIAN,
	"Silicon" = DEPARTMENT_BITFLAG_SILICON
))
