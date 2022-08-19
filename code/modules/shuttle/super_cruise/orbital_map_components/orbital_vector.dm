//Orbital vectors
// Improved to know which ones modify self and which ones return a new vector
// - bacon

/datum/orbital_vector
	VAR_PRIVATE/x = 0
	VAR_PRIVATE/y = 0
	var/protected = FALSE

/datum/orbital_vector/New(_x = 0, _y = 0)
	. = ..()
	x = _x
	y = _y

/datum/orbital_vector/proc/Set(x, y)
	if(protected)
		CRASH("Attempted to translate a protected vector.")
	src.x = x
	src.y = y

/datum/orbital_vector/proc/SetUnsafely(x, y)
	src.x = x
	src.y = y

/datum/orbital_vector/proc/GetX()
	return x

/datum/orbital_vector/proc/GetY()
	return y

//Returns a new vector equal to the current vector + other
/datum/orbital_vector/proc/Add(datum/orbital_vector/other)
	return new /datum/orbital_vector(
		other.x + x,
		other.y + y
	)

//Returns a new vector equal to the current vector * scalar_amount
/datum/orbital_vector/proc/Scale(scalar_amount)
	return new /datum/orbital_vector(
		x * scalar_amount,
		y * scalar_amount
	)

//Adds the other vector to our current vector.
/datum/orbital_vector/proc/AddSelf(datum/orbital_vector/other)
	if(protected)
		CRASH("Attempted to translate a protected vector.")
	src.x += other.x
	src.y += other.y
	return src

//Scales our current vector by a scalar amount
/datum/orbital_vector/proc/ScaleSelf(scalar_amount)
	if(protected)
		CRASH("Attempted to scale a protected vector.")
	x *= scalar_amount
	y *= scalar_amount
	return src

//Returns magnitude of the vector
/datum/orbital_vector/proc/Length()
	return sqrt(x * x + y * y)

//Returns distanace between 2 positional vectors
/datum/orbital_vector/proc/DistanceTo(datum/orbital_vector/other)
	var/delta_x = other.x - x
	var/delta_y = other.y - y
	return sqrt(delta_x * delta_x + delta_y * delta_y)

///Returns the angle from B to A
//90 is right, -90 is left, 0 is up
/datum/orbital_vector/proc/AngleFrom(datum/orbital_vector/other)
	var/delta_x = other.x - x
	var/delta_y = other.y - y
	//This is between -90 and 90
	var/rawAngle = delta_x ? arctan(delta_y / delta_x) : 90
	//Allow for it to be -180 to 180
	if(delta_y < 0)
		return -rawAngle
	return rawAngle

//Make the vector length 1
/datum/orbital_vector/proc/NormalizeSelf()
	if(protected)
		CRASH("Attempted to normalize a protected vector.")
	var/total = Length()
	if(!total)
		x = 0
		y = 1
		return src
	x = x / total
	y = y / total
	return src

/datum/orbital_vector/proc/RotateSelf(angle)
	if(protected)
		CRASH("Attempted to rotate a protected vector.")
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
	return closestPoint.DistanceTo(src)
