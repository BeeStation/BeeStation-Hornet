#define JOB_MODIFICATION_MAP_NAME "PubbyStation"

/datum/job/head_of_security/New()
	..()
	MAP_JOB_CHECK
	access |= ACCESS_CREMATORIUM
	minimal_access |= ACCESS_CREMATORIUM

/datum/job/warden/New()
	..()
	MAP_JOB_CHECK
	access |= ACCESS_CREMATORIUM
	minimal_access |= ACCESS_CREMATORIUM

/datum/job/security_officer/New()
	..()
	MAP_JOB_CHECK
	access |= ACCESS_CREMATORIUM
	minimal_access |= ACCESS_CREMATORIUM

/datum/job/exploration_crew/New()
	. = ..()
	MAP_JOB_CHECK
	access |= ACCESS_MAINT_TUNNELS
	minimal_access |= ACCESS_MAINT_TUNNELS
