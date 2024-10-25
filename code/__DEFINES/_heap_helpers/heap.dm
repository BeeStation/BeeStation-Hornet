//////////////////////
//datum/heap object
//////////////////////

#define HEAP_TYPE(typepath, compare_value) ##typepath {\
	var/list/elements;\
	New(...) {\
		elements = args.Copy();\
	}\
	Destroy(force, ...) {\
		for(var/i in elements) {\
			qdel(i);\
		}\
		elements = null;\
		return ..();\
	}\
	proc/is_empty() {\
		return !length(elements);\
	}\
	proc/insert(atom/A) {\
		elements.Add(A);\
		swim(length(elements));\
	}\
	proc/pop() {\
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
	proc/swim(index) {\
		var/parent = round(index * 0.5);\
		while(parent > 0 && (elements[index]:##compare_value - elements[parent]:##compare_value > 0)) {\
			elements.Swap(index,parent);\
			index = parent;\
			parent = round(index * 0.5);\
		}\
	}\
	proc/sink(index) {\
		var/g_child = get_greater_child(index);\
		while(g_child > 0 && (elements[index]:##compare_value - elements[g_child]:##compare_value < 0)) {\
			elements.Swap(index,g_child);\
			index = g_child;\
			g_child = get_greater_child(index);\
		}\
	}\
	proc/get_greater_child(index) {\
		if(index * 2 > length(elements)) {\
			return 0;\
		}\
		if(index * 2 + 1 > length(elements)) {\
			return index * 2;\
		}\
		if(elements[index * 2]:##compare_value - elements[index * 2 + 1]:##compare_value < 0) {\
			return index * 2 + 1;\
		} else {\
			return index * 2;\
		}\
	}\
	proc/resort(atom/A) {\
		var/index = elements.Find(A);\
		swim(index);\
		sink(index);\
	}\
	proc/List() {\
		. = elements.Copy();\
	}\
	proc/operator+=(A) {\
		elements.Add(A);\
		swim(length(elements));\
	}\
	proc/operator|=(A) {\
		var/original_length = length(elements);\
		elements |= A;\
		if (original_length != length(elements)) {\
			swim(length(elements));\
		}\
	}\
	proc/operator-=(A) {\
		var/index = elements.Find(A);\
		if(index == 0) {\
			return src;\
		}\
		elements[index] = elements[length(elements)];\
		elements.Cut(length(elements));\
		if(length(elements)) {\
			sink(index);\
		}\
	}\
}
