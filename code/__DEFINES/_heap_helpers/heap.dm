//////////////////////
//datum/heap object
//////////////////////

#define ADD_HEAP(_heap_list, _item, _compare_value, _heap_type) do {\
		_heap_list += _item;\
		SWIM_HEAP(_heap_list, length(_heap_list), _compare_value, _heap_type);\
	} while (0)

#define POP_HEAP_ACTION(_heap_list, _compare_value, _heap_type) do {\
		if(length(_heap_list)) {\
			_heap_list[1] = _heap_list[length(_heap_list)];\
			_heap_list.len --;\
			if(length(_heap_list)) {\
				SINK_HEAP(_heap_list, 1, _compare_value, _heap_type);\
			};\
		};\
	} while (0)

#define REMOVE_HEAP(_heap_list, _item, _compare_value, _heap_type) do {\
		var/_index = _heap_list.Find(_item);\
		if(_index != 0) {\
			_heap_list[_index] = _heap_list[length(_heap_list)];\
			_heap_list.len --;\
			if(length(_heap_list)) {\
				SINK_HEAP(_heap_list, _index, _compare_value, _heap_type);\
			};\
		};\
	} while (0)

#if defined(SPACEMAN_DMM)

#define GREATER_CHILD_HEAP(_heap_list, _index, _compare_value, tmp) (_index * 2 > length(_heap_list))\
	? (0)\
	: ((_index * 2 + 1 > length(_heap_list))\
		? (_index * 2)\
		: ((_heap_list[_index * 2]:##_compare_value - _heap_list[_index * 2 + 1]:##_compare_value < 0)\
			? (_index * 2 + 1)\
			: (_index * 2)))

#else

#define GREATER_CHILD_HEAP(_heap_list, _index, _compare_value, tmp) (_index * 2 > length(_heap_list))\
	? (0)\
	: ((_index * 2 + 1 > length(_heap_list))\
		? (_index * 2)\
		: (((tmp = _heap_list[_index * 2]).##_compare_value - (tmp = _heap_list[_index * 2 + 1]).##_compare_value < 0)\
			? (_index * 2 + 1)\
			: (_index * 2)))

#endif

#define SINK_HEAP(_heap_list, _index, _compare_value, _heap_type) do {\
		var/_sink_index = _index;\
		var##_heap_type/tmp;\
		var/g_child = GREATER_CHILD_HEAP(_heap_list, _sink_index, _compare_value, tmp);\
		if (g_child > 0) {\
			var##_heap_type/left = _heap_list[_sink_index];\
			var##_heap_type/right = _heap_list[g_child];\
			while(g_child > 0 && (left.##_compare_value - right.##_compare_value < 0)) {\
				_heap_list.Swap(_sink_index,g_child);\
				_sink_index = g_child;\
				g_child = GREATER_CHILD_HEAP(_heap_list, _sink_index, _compare_value, tmp);\
				if (g_child <= 0) {\
					break;\
				}\
				left = _heap_list[_sink_index];\
				right = _heap_list[g_child];\
			};\
		}\
	} while (0)

#define SWIM_HEAP(_heap_list, _index, _compare_value, _heap_type) do {\
		var/_swim_index = _index;\
		var/parent = round(_swim_index * 0.5);\
		if (parent > 0) {\
			var##_heap_type/left = _heap_list[_swim_index];\
			var##_heap_type/right = _heap_list[parent];\
			while(parent > 0 && (left.##_compare_value - right.##_compare_value > 0)) {\
				_heap_list.Swap(_swim_index,parent);\
				_swim_index = parent;\
				parent = round(_swim_index * 0.5);\
				if (parent <= 0) {\
					break;\
				}\
				left = _heap_list[_swim_index];\
				right = _heap_list[parent];\
			};\
		}\
	} while (0)

#define DECLARE_HEAP_TYPE(typepath, stored_type, comparison) ##typepath/var/list/elements;\
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
		if (parent <= 0) {\
			return;\
		}\
		var##stored_type/a = elements[index];\
		var##stored_type/b = elements[parent];\
		while(parent > 0 && (##comparison > 0)) {\
			elements.Swap(index,parent);\
			index = parent;\
			parent = round(index * 0.5);\
			if (parent <= 0) {\
				break;\
			}\
			a = elements[index];\
			b = elements[parent];\
		}\
	}\
##typepath/proc/sink(index) {\
		var/g_child = get_greater_child(index);\
		if (g_child <= 0) {\
			return;\
		}\
		var##stored_type/a = elements[index];\
		var##stored_type/b = elements[g_child];\
		while(##comparison < 0) {\
			elements.Swap(index,g_child);\
			index = g_child;\
			g_child = get_greater_child(index);\
			if (g_child <= 0) {\
				break;\
			}\
			a = elements[index];\
			b = elements[g_child];\
		}\
	}\
##typepath/proc/get_greater_child(index) {\
		if (index * 2 > length(elements)) {\
			return 0;\
		}\
		if (index * 2 + 1 > length(elements)) {\
			return index * 2;\
		}\
		var##stored_type/a = elements[index * 2];\
		var##stored_type/b = elements[index * 2 + 1];\
		return (##comparison) < 0 ? (index * 2 + 1) : (index * 2);\
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
