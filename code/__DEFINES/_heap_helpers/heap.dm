//////////////////////
//datum/heap object
//////////////////////

#define ADD_HEAP(_heap_list, _item, _compare_value) do {\
		_heap_list += _item;\
		SWIM_HEAP(_heap_list, length(_heap_list), _compare_value);\
	} while (0)

#define POP_HEAP_ACTION(_heap_list, _compare_value) do {\
		if(length(_heap_list)) {\
			_heap_list[1] = _heap_list[length(_heap_list)];\
			_heap_list.len --;\
			if(length(_heap_list)) {\
				SINK_HEAP(_heap_list, 1, _compare_value);\
			};\
		};\
	} while (0)

#define REMOVE_HEAP(_heap_list, _item, _compare_value) do {\
		var/_index = _heap_list.Find(_item);\
		if(_index != 0) {\
			_heap_list[_index] = _heap_list[length(_heap_list)];\
			_heap_list.len --;\
			if(length(_heap_list)) {\
				SINK_HEAP(_heap_list, _index, _compare_value);\
			};\
		};\
	} while (0)

#define GREATER_CHILD_HEAP(_heap_list, _index, _compare_value) (_index * 2 > length(_heap_list))\
	? (0)\
	: ((_index * 2 + 1 > length(_heap_list))\
		? (_index * 2)\
		: ((_heap_list[_index * 2]?:##_compare_value - _heap_list[_index * 2 + 1]?:##_compare_value < 0)\
			? (_index * 2 + 1)\
			: (_index * 2)))

#define SINK_HEAP(_heap_list, _index, _compare_value) do {\
		var/_sink_index = _index;\
		var/g_child = GREATER_CHILD_HEAP(_heap_list, _sink_index, _compare_value);\
		while(g_child > 0 && (_heap_list[_sink_index]:##_compare_value - _heap_list[g_child]:##_compare_value < 0)) {\
			_heap_list.Swap(_sink_index,g_child);\
			_sink_index = g_child;\
			g_child = GREATER_CHILD_HEAP(_heap_list, _sink_index, _compare_value);\
		};\
	} while (0)

#define SWIM_HEAP(_heap_list, _index, _compare_value) do {\
		var/_swim_index = _index;\
		var/parent = round(_swim_index * 0.5);\
		while(parent > 0 && (_heap_list[_swim_index]:##_compare_value - _heap_list[parent]:##_compare_value > 0)) {\
			_heap_list.Swap(_swim_index,parent);\
			_swim_index = parent;\
			parent = round(_swim_index * 0.5);\
		};\
	} while (0)

#define HEAP_TYPE(typepath, compare_value) ##typepath/var/list/elements;\
##typepath/New(...) {\
		elements = args.Copy();\
	}\
##typepath/Destroy(force, ...) {\
		for(var/i in elements) {\
			qdel(i);\
		}\
		elements = null;\
		return ..();\
	}\
##typepath/proc/is_empty() {\
		return !length(elements);\
	}\
##typepath/proc/insert(atom/A) {\
		elements.Add(A);\
		swim(length(elements));\
	}\
##typepath/proc/pop() {\
		if(!length(elements)) {\
			return 0;\
		}\
		. = elements[1];\
		elements[1] = elements[length(elements)];\
		elements.Cut(length(elements));\
		if(length(elements)) {\
			sink(1);\
		}\
	}\
##typepath/proc/swim(index) {\
		var/parent = round(index * 0.5);\
		while(parent > 0 && (elements[index]:##compare_value - elements[parent]:##compare_value > 0)) {\
			elements.Swap(index,parent);\
			index = parent;\
			parent = round(index * 0.5);\
		}\
	}\
##typepath/proc/sink(index) {\
		var/g_child = get_greater_child(index);\
		while(g_child > 0 && (elements[index]?:##compare_value - elements[g_child]?:##compare_value < 0)) {\
			elements.Swap(index,g_child);\
			index = g_child;\
			g_child = get_greater_child(index);\
		}\
	}\
##typepath/proc/get_greater_child(index) {\
		return GREATER_CHILD_HEAP(elements, index, compare_value);\
	}\
##typepath/proc/resort(atom/A) {\
		var/index = elements.Find(A);\
		swim(index);\
		sink(index);\
	}\
##typepath/proc/List() {\
		. = elements.Copy();\
	}\
##typepath/proc/operator+=(A) {\
		elements.Add(A);\
		swim(length(elements));\
	}\
##typepath/proc/operator|=(A) {\
		var/original_length = length(elements);\
		elements |= A;\
		if (original_length != length(elements)) {\
			swim(length(elements));\
		}\
	}\
##typepath/proc/operator-=(A) {\
		var/index = elements.Find(A);\
		if(index == 0) {\
			return src;\
		}\
		elements[index] = elements[length(elements)];\
		elements.Cut(length(elements));\
		if(length(elements)) {\
			sink(index);\
		}\
	}
