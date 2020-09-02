/*
	This proc makes the input taper off above cap. But there's no absolute cutoff.
	Chunks of the input value above cap, are reduced more and more with each successive one and added to the output
	A higher input value always makes a higher output value. but the rate of growth slows
*/
/proc/soft_cap(var/input, var/cap = 0, var/groupsize = 1, var/groupmult = 0.9)

	//The cap is a ringfenced amount. If we're below that, just return the input
	if (input <= cap)
		return input

	var/output = 0
	var/buffer = 0
	var/power = 1//We increment this after each group, then apply it to the groupmult as a power

	//Ok its above, so the cap is a safe amount, we move that to the output
	input -= cap
	output += cap

	//Now we start moving groups from input to buffer


	while (input > 0)
		buffer = min(input, groupsize)	//We take the groupsize, or all the input has left if its less
		input -= buffer

		buffer *= groupmult**power //This reduces the group by the groupmult to the power of which index we're on.
		//This ensures that each successive group is reduced more than the previous one

		output += buffer
		power++ //Transfer to output, increment power, repeat until the input pile is all used

	return output
