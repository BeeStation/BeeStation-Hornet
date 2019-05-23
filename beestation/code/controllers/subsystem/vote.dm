
/datum/controller/subsystem/vote/submit_vote(vote)
	if(mode)
		if(CONFIG_GET(flag/no_dead_vote) && (usr.stat == DEAD && !isnewplayer(usr)) && !usr.client.holder) // BEE EDIT: newplayers can vote even if nodeadvote is enabled
			return 0
		if(!(usr.ckey in voted))
			if(vote && 1<=vote && vote<=choices.len)
				voted += usr.ckey
				choices[choices[vote]]++	//check this
				return vote
	return 0