// Higher priority = comes out first
/datum/priority_queue
	var/list/queue_elements = list()

/datum/priority_queue/proc/enqueue(priority, element)
	var/datum/queue_element/created = new()
	created.priority = priority
	created.value = element
	BINARY_INSERT(created, queue_elements, /datum/queue_element, created, priority, COMPARE_KEY)

/datum/priority_queue/proc/dequeue()
	var/datum/queue_element/created = queue_elements[queue_elements.len]
	queue_elements.len --
	return created.value

/datum/priority_queue/proc/has_elements()
	return queue_elements.len > 0

/datum/queue_element
	var/priority
	var/value
