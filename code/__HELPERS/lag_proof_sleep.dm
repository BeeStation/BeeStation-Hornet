// This is used to cause less lag when you need to do excessive amount of process in a loop.
// i.e.) lubricate 10,000 tiles, a big explosion like SM delam
/datum/lag_proof_sleep/proc/lag_proof_sleep(maximum=200, sleep_time=1)
	var/static/count = 0
	count++
	if(count >= maximum)
		count=0
		sleep(sleep_time)

/* [How to use `lag_proof_sleep()`]
	------------------------------------------------------------------------------
	var/static/datum/lag_proof_sleep/loop_counter = new /datum/lag_proof_sleep()

	for(var/i in `something 100,000 turfs`)
		i.does_something()
		loop_counter.lag_proof_sleep()
	------------------------------------------------------------------------------
	NOTE: There is the same example in `cluwne_tiles.dm`
	the results after excessive amount of process can cause lag to player clients(or server)
	this is why we need this.
*/
