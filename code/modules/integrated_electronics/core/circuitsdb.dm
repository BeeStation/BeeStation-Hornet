/datum/controller/subsystem/circuitdb/save(var/ckey, var/circuit)
var/datum/DBQuery/circuit_saving_query = SSdbcore.NewQuery(
		"INSERT INTO [format_table_name("SS13_circuits")] (ckey, content) VALUES (:ckey, :circuits)")
