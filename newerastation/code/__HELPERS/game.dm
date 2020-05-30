//yoinked from hippie (infiltrators)
/proc/get_area_by_type(N) // This is only here due to the shittiness of locate in world, and the fact that infiltrators seem to love throwing their objectives on the table.
	for(var/area/A in world)
		if(A.type == N)
			return A
	return FALSE
