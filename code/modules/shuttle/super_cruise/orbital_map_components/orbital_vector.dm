/datum/orbital_vector
	var/x = 0
	var/y = 0

/datum/orbital_vector/New(_x = 0, _y = 0)
	. = ..()
	x = _x
	y = _y

//Adds 2 vectors together
/datum/orbital_vector/proc/Add(datum/orbital_vector/other)
	src.x += other.x
	src.y += other.y
	return src

//Scales the vector by scalar_amount
/datum/orbital_vector/proc/Scale(scalar_amount)
	x *= scalar_amount
	y *= scalar_amount
	return src

//Returns magnitude of the vector
/datum/orbital_vector/proc/Length()
	return sqrt(x * x + y * y)

//Returns distanace between 2 positional vectors
/datum/orbital_vector/proc/Distance(datum/orbital_vector/other)
	var/delta_x = other.x - x
	var/delta_y = other.y - y
	return sqrt(delta_x * delta_x + delta_y * delta_y)

//Make the vector length 1
/datum/orbital_vector/proc/Normalize()
	var/total = Length()
	if(!total)
		x = 0
		y = 1
		return src
	x = x / total
	y = y / total
	return src

/datum/orbital_vector/proc/Rotate(angle)
	var/_x = x
	x = x * cos(angle) - y * sin(angle)
	y = _x * sin(angle) + y * cos(angle)
	return src

//Assuming we are a position vector
//Takes in position and direction of a line.
/datum/orbital_vector/proc/ShortestDistanceToLine(datum/orbital_vector/position, datum/orbital_vector/direction)
	if(!direction.x && !direction.y)
		return INFINITY
	//Uhhhhhhhhhh.
	if(!x && !y)
		x = 1
		y = 1
	var/lambda = (x * x + y * y - position.x * x - position.y * y) / (direction.x * x + direction.y * y)
	var/datum/orbital_vector/closestPoint = new(position.x + direction.x * lambda, position.y + direction.y * lambda)
	return closestPoint.Distance(src)
