SUBSYSTEM_DEF(ipintel)
	name = "XKeyScore"
	init_order = INIT_ORDER_XKEYSCORE
	flags = SS_NO_FIRE
	var/enabled = 0 //disable at round start to avoid checking reconnects
	var/throttle = 0
	var/errors = 0

	var/list/cache = list()

/datum/controller/subsystem/ipintel/Initialize()
	enabled = 1
	return SS_INIT_SUCCESS
