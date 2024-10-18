//////////////////////
//datum/heap object
//////////////////////

/datum/heap
	var/list/L
	var/cmp

/datum/heap/New(compare)
	L = new()
	cmp = compare

/datum/heap/Destroy(force, ...)
	for(var/i in L) // because this is before the list helpers are loaded
		qdel(i)
	L = null
	return ..()

/datum/heap/proc/is_empty()
	return !length(L)

//insert and place at its position a new node in the heap
/datum/heap/proc/insert(atom/A)

	L.Add(A)
	return swim(length(L))

//removes and returns the first element of the heap
//(i.e the max or the min dependant on the comparison function)
/datum/heap/proc/pop()
	if(!length(L))
		return 0
	. = L[1]

	L[1] = L[length(L)]
	L.Cut(length(L))
	if(length(L))
		sink(1)

/datum/heap/proc/delete_at(index)
	if (index <= 0)
		CRASH("Attempted to delete from heap where index is less than 0. This is an error.")
	if (index > length(L))
		CRASH("Attempted to delete from a heap outside of the bounds of the heap.")
	var/deleted = L[index]
	L.Swap(index, length(L))
	L.len--
	// Edge case where we remove the sole element of the heap
	if (index <= L.len)
		swim(index)
	return deleted

//Get a node up to its right position in the heap
/datum/heap/proc/swim(index)
	var/parent = round(index * 0.5)

	while(parent > 0 && (call(cmp)(L[index],L[parent]) > 0))
		L.Swap(index,parent)
		index = parent
		parent = round(index * 0.5)
	return index

//Get a node down to its right position in the heap
/datum/heap/proc/sink(index)
	var/g_child = get_greater_child(index)

	while(g_child > 0 && (call(cmp)(L[index],L[g_child]) < 0))
		L.Swap(index,g_child)
		index = g_child
		g_child = get_greater_child(index)

#define parent_index(index) (index == 1 ? index : index / 2)

#define left_child_index(index) (index * 2)

#define right_child_index(index) (index * 2 + 1)

//Returns the greater (relative to the comparison proc) of a node children
//or 0 if there's no child
/datum/heap/proc/get_greater_child(index)
	if(left_child_index(index) > length(L))
		return 0

	if(right_child_index(index) > length(L))
		return left_child_index(index)

	if(call(cmp)(L[index * 2],L[index * 2 + 1]) < 0)
		return left_child_index(index)
	else
		return right_child_index(index)

//Replaces a given node so it verify the heap condition
/datum/heap/proc/resort(atom/A)
	var/index = L.Find(A)

	swim(index)
	sink(index)

/datum/heap/proc/List()
	. = L.Copy()

#undef parent_index

#undef left_child_index

#undef right_child_index
