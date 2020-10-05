/datum/world_topic/whois
	keyword = "whoIs"

/datum/world_topic/whois/Run(list/input)
	. = list()
	.["players"] = GLOB.clients

	return list2params(.)

/datum/world_topic/getadmins
	keyword = "getAdmins"

/datum/world_topic/getadmins/Run(list/input)
	. = list()
	var/list/adm = get_admin_counts()
	var/list/presentmins = adm["present"]
	var/list/afkmins = adm["afk"]
	.["admins"] = presentmins
	.["admins"] += afkmins

	return list2params(.)
