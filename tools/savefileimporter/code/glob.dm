/datum/global_var_holder
	var/DBConnection/dbcon = new
	var/list/config = list()
	var/failed_db_connections = 0

var/datum/global_var_holder/GLOB = new()
