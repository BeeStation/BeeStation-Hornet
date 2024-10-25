#define SIGNAL_ADDTRAIT(trait_ref) "addtrait [trait_ref]"
#define SIGNAL_REMOVETRAIT(trait_ref) "removetrait [trait_ref]"

HEAP_TYPE(/datum/trait_heap, priority)

/datum/trait
	/// Source of the trait
	var/source
	/// The value contained in this trait
	var/value
	/// The priority of this value trait, or null if there is no value
	var/priority

/datum/trait/New(source, value = null, priority = null)
	. = ..()
	src.source = source
	src.value = value
	// If we have a value, we must have a priority. Default to 0.
	src.priority = priority || (value ? 0 : null)

/// Add a trait to a target
/// Parameters:
/// 1: The target to recieve the trait
/// 2: The key of the trait
/// 3: The source of the trait
/// 4 (optional): The value associated with this trait
/// 5 (optional): The priority of this trait, if it has a value
#define ADD_TRAIT(target, _trait, source, args...) \
	do { \
		var/_L; \
		if (!target.status_traits) { \
			target.status_traits = list(); \
		} \
		_L = target.status_traits; \
		if (_L[_trait]) { \
			var/datum/trait/created_trait = new /datum/trait(source, args);\
			_L[_trait] |= created_trait; \
		} else { \
			_L[_trait] = new /datum/trait_heap(new /datum/trait(source, args)); \
			SEND_SIGNAL(target, SIGNAL_ADDTRAIT(_trait), _trait); \
		} \
	} while (0)

#define REMOVE_TRAIT(target, _trait, sources) \
	do { \
		var/list/_L = target.status_traits; \
		var/list/_S; \
		if (sources && !islist(sources)) { \
			_S = list(sources); \
		} else { \
			_S = sources\
		}; \
		if (_L && _L[_trait]) { \
			var/datum/trait_heap/heap = _L[_trait];\
			for (var/datum/trait/_T as anything in heap.elements) { \
				if ((!_S && (_T.source != ROUNDSTART_TRAIT)) || (_T.source in _S)) { \
					heap -= _T \
				} \
			};\
			if (!length(heap.elements)) { \
				_L -= _trait; \
				SEND_SIGNAL(target, SIGNAL_REMOVETRAIT(_trait), _trait); \
			}; \
			if (!length(_L)) { \
				target.status_traits = null \
			}; \
		} \
	} while (0)

#define REMOVE_TRAIT_NOT_FROM(target, trait, sources) \
	do { \
		var/list/_traits_list = target.status_traits; \
		var/list/_sources_list; \
		if (sources && !islist(sources)) { \
			_sources_list = list(sources); \
		} else { \
			_sources_list = sources\
		}; \
		if (_traits_list && _traits_list[trait]) { \
			var/datum/trait_heap/heap = _L[_trait];\
			for (var/datum/trait/_trait in heap.elements) { \
				if (!(_trait.source in _sources_list)) { \
					_traits_list[trait] -= _trait \
				} \
			};\
			if (!length(heap.elements)) { \
				_traits_list -= trait; \
				SEND_SIGNAL(target, SIGNAL_REMOVETRAIT(trait), trait); \
			}; \
			if (!length(_traits_list)) { \
				target.status_traits = null \
			}; \
		} \
	} while (0)

#define REMOVE_TRAITS_NOT_IN(target, sources) \
	do { \
		var/list/_L = target.status_traits; \
		var/list/_S = sources; \
		if (_L) { \
			for (var/_T in _L) { \
				_L[_T] &= _S;\
				var/datum/trait_heap/heap = _L[_T];\
				if (!length(heap.elements)) { \
					_L -= _T; \
					SEND_SIGNAL(target, SIGNAL_REMOVETRAIT(_T), _T); \
					}; \
				};\
			if (!length(_L)) { \
				target.status_traits = null\
			};\
		}\
	} while (0)

#define REMOVE_TRAITS_IN(target, sources) \
	do { \
		var/list/_L = target.status_traits; \
		var/list/_S = sources; \
		if (sources && !islist(sources)) { \
			_S = list(sources); \
		} else { \
			_S = sources\
		}; \
		if (_L) { \
			for (var/_T in _L) { \
				_L[_T] -= _S;\
				var/datum/trait_heap/heap = _L[_T];\
				if (!length(heap.elements)) { \
					_L -= _T; \
					SEND_SIGNAL(target, SIGNAL_REMOVETRAIT(_T)); \
					}; \
				};\
			if (!length(_L)) { \
				target.status_traits = null\
			};\
		}\
	} while (0)

#define HAS_TRAIT(target, trait) (target.status_traits ? (target.status_traits[trait] ? TRUE : FALSE) : FALSE)
#define HAS_TRAIT_FROM(target, trait, source) (target.status_traits ? (target.status_traits[trait] ? (source in target.status_traits[trait]) : FALSE) : FALSE)
#define HAS_TRAIT_FROM_ONLY(target, trait, source) (\
	target.status_traits ?\
		(target.status_traits[trait] ?\
			((source in target.status_traits[trait]) && (length(target.status_traits) == 1))\
			: FALSE)\
		: FALSE)
#define HAS_TRAIT_NOT_FROM(target, trait, source) (target.status_traits ? (target.status_traits[trait] ? (length(target.status_traits[trait] - source) > 0) : FALSE) : FALSE)

// Note: a?:b is used because : alone breaks the terniary operator
/// Get the value of the specified trait
#define GET_TRAIT_VALUE(target, trait) (target.status_traits ? (length(target.status_traits[trait]?:elements) ? (target.status_traits[trait]?:elements[1]?:value) : null) : null)
