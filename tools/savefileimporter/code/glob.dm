/datum/global_var_holder
	var/dbconnection // Arbitrary handle from RUSTG
	var/list/config = list()
	var/failed_db_connections = 0

	// List of all character "directories"
	var/list/all_cdirs = list(
		"character1",
		"character2",
		"character3",
		"character4",
		"character5",
		"character6",
		"character7",
		"character8",
		"character9"
	)

var/datum/global_var_holder/GLOB = new()
