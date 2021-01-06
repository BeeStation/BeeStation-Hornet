/datum/ntnet_service
	var/name = "Unidentified Network Service"
	var/id
	var/list/networks_by_id = list()			//Yes we support multinetwork services!

/datum/ntnet_service/New()
	var/datum/component/ntnet_interface/N = AddComponent(/datum/component/ntnet_interface, id, name, FALSE)
	id = N.hardware_id

/datum/ntnet_service/Destroy()
	for(var/i in networks_by_id)
		var/datum/ntnet/N = i
		disconnect(N, TRUE)
	networks_by_id = null
	return ..()

/datum/ntnet_service/proc/connect(datum/ntnet/net)
	if(!istype(net))
		return EF_FALSE
	var/datum/component/ntnet_interface/interface = GetComponent(/datum/component/ntnet_interface)
	if(!interface.register_connection(net))
		return EF_FALSE
	if(!net.register_service(src))
		interface.unregister_connection(net)
		return EF_FALSE
	networks_by_id[net.network_id] = net
	return EF_TRUE

/datum/ntnet_service/proc/disconnect(datum/ntnet/net, force = FALSE)
	if(!istype(net) || (!net.unregister_service(src) && !force))
		return EF_FALSE
	var/datum/component/ntnet_interface/interface = GetComponent(/datum/component/ntnet_interface)
	interface.unregister_connection(net)
	networks_by_id -= net.network_id
	return EF_TRUE

/datum/ntnet_service/proc/ntnet_intercept(datum/netdata/data, datum/ntnet/net, datum/component/ntnet_interface/sender)
	return
