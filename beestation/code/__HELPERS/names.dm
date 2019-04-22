proc/squid_name(gender)
	if(gender == MALE)
		return "[pick(GLOB.squid_names_male)] [pick(GLOB.last_names)]"
	else
		return "[pick(GLOB.squid_names_female)] [pick(GLOB.last_names)]"