/client/New()
	..()
	dir = NORTH

/client/verb/spinleft()
	set name = "Spin View Counter-CW"
	set category = "OOC"
	dir = turn(dir, 90)

/client/verb/spinright()
	set name = "Spin View CW"
	set category = "OOC"
	dir = turn(dir, -90)
