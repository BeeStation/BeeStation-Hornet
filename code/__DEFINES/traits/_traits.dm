#define SIGNAL_ADDTRAIT(trait_ref) "addtrait [trait_ref]"
#define SIGNAL_REMOVETRAIT(trait_ref) "removetrait [trait_ref]"

/datum/trait
	/// Source of the trait
	var/source
	/// The value contained in this trait
	var/value
	/// The priority of this value trait, or null if there is no value
	var/priority

/datum/trait/New(source, value = null, priority = 0)
	. = ..()
	src.source = source
	src.value = value
	src.priority = priority

/datum/trait/proc/operator~=(b)
	return source == b

// TODO: Figure out a way of merging ADD_TRAIT and ADD_VALUE_TRAIT with variadic macros
// without making the opendream/dreamchecker unhappy through the use of compile-time
// constant if statements.

/// Add a trait to a target
/// Parameters:
/// 1: The target to receive the trait
/// 2: The key of the trait
/// 3: The source of the trait
#define ADD_TRAIT(target, _trait, source) do { \
		var/list/_L; \
		if (!target.status_traits) { \
			target.status_traits = list(); \
		}; \
		_L = target.status_traits; \
		var/list/target_heap = _L[_trait];\
		if (target_heap != null) { \
			target_heap += source;\
		} else { \
			target_heap = list(source); \
			_L[_trait] = target_heap;\
			SEND_SIGNAL(target, SIGNAL_ADDTRAIT(_trait), _trait); \
		} \
	} while (0)

/// Add a trait to a target
/// Parameters:
/// 1: The target to receive the trait
/// 2: The key of the trait
/// 3: The source of the trait
/// 4: The priority of the trait value
/// 5: The value stored in the trait
#define ADD_VALUE_TRAIT(target, _trait, source, _trait_value, _trait_priority) do { \
		var/list/_L; \
		if (!target.status_traits) { \
			target.status_traits = list(); \
		}; \
		_L = target.status_traits; \
		var/list/target_heap = _L[_trait];\
		if (target_heap != null) { \
			ADD_HEAP(target_heap, new /datum/trait(source, _trait_value, _trait_priority), priority);\
		} else { \
			target_heap = list(); \
			ADD_HEAP(target_heap, new /datum/trait(source, _trait_value, _trait_priority), priority);\
			_L[_trait] = target_heap;\
			SEND_SIGNAL(target, SIGNAL_ADDTRAIT(_trait), _trait); \
		} \
	} while (0)

/// Removes a trait from a specific source
#define REMOVE_TRAIT(target, _trait, sources) \
	do { \
		var/list/_L = target.status_traits; \
		var/list/_S; \
		if (sources && !islist(sources)) { \
			_S = list(sources); \
		} else { \
			_S = sources;\
		}; \
		if (_L && _L[_trait]) { \
			var/list/_heap = _L[_trait];\
			for (var/_T in _heap) { \
				if ((!_S && (!(_T ~= ROUNDSTART_TRAIT))) || ((istype(_T, /datum/trait) ? _T:source : _T) in _S)) { \
					if (istype(_T, /datum/trait)) {\
						REMOVE_HEAP(_heap, _T, priority); \
					} else {\
						_heap -= _T;\
					};\
				}; \
			};\
			if (!length(_heap)) { \
				_L -= _trait; \
				SEND_SIGNAL(target, SIGNAL_REMOVETRAIT(_trait), _trait); \
			}; \
			if (!length(_L)) { \
				target.status_traits = null; \
			}; \
		} \
	} while (0)

/// Remove all sources of a trait unless it comes from one of the provided sources
#define REMOVE_TRAIT_NOT_FROM(target, _trait, sources) \
	do { \
		var/list/_traits_list = target.status_traits; \
		var/list/_sources_list; \
		if (sources && !islist(sources)) { \
			_sources_list = list(sources); \
		} else { \
			_sources_list = sources\
		}; \
		if (_traits_list && _traits_list[_trait]) { \
			var/list/_heap = _traits_list[_trait];\
			for (var/_T as anything in _heap) { \
				if (!((istype(_T, /datum/trait) ? _T:source : _T) in _sources_list)) { \
					if (istype(_T, /datum/trait)) {\
						REMOVE_HEAP(_heap, _T, priority); \
					} else {\
						_heap -= _T;\
					};\
				}; \
			};\
			if (!length(_heap)) { \
				_traits_list -= _trait; \
				SEND_SIGNAL(target, SIGNAL_REMOVETRAIT(_trait), _trait); \
			}; \
			if (!length(_traits_list)) { \
				target.status_traits = null; \
			}; \
		}; \
	} while (0)

// You probably shouldn't be using this
/// Remove all traits that don't come from the specified source
#define REMOVE_TRAITS_NOT_IN(target, sources) \
	do { \
		var/list/_L = target.status_traits; \
		var/list/_S = islist(sources) ? sources : list(sources); \
		if (_L) { \
			for (var/_trait_key as anything in _L) { \
				var/list/_heap = _L[_trait_key];\
				for (var/_trait in _heap) { \
					if (!((istype(_trait, /datum/trait) ? _trait:source : _trait) in _S)) { \
						if (istype(_trait, /datum/trait)) {\
							REMOVE_HEAP(_heap, _trait, priority); \
						} else {\
							_heap -= _trait;\
						};\
					}; \
				};\
				if (!length(_heap)) { \
					_L -= _trait_key; \
					SEND_SIGNAL(target, SIGNAL_REMOVETRAIT(_trait_key), _trait_key); \
				}; \
			};\
			if (!length(_L)) { \
				target.status_traits = null;\
			};\
		};\
	} while (0)

/// Removes all traits that come from a specific source
#define REMOVE_TRAITS_IN(target, sources) \
	do { \
		var/list/_L = target.status_traits; \
		var/list/_S = sources; \
		if (sources && !islist(sources)) { \
			_S = list(sources); \
		} else { \
			_S = sources;\
		}; \
		if (_L) { \
			for (var/_trait_key as anything in _L) { \
				var/list/_heap = _L[_trait_key];\
				for (var/_T in _heap) { \
					if ((istype(_T, /datum/trait) ? _T:source : _T) in _S) { \
						if (istype(_T, /datum/trait)) {\
							REMOVE_HEAP(_heap, _T, priority); \
						} else {\
							_heap -= _T;\
						};\
					}; \
				};\
				if (!length(_heap)) { \
					_L -= _trait_key; \
					SEND_SIGNAL(target, SIGNAL_REMOVETRAIT(_trait_key), _trait_key); \
				}; \
			};\
			if (!length(_L)) { \
				target.status_traits = null;\
			};\
		};\
	} while (0)

/// Checks if the mob has the specified trait
#define HAS_TRAIT(target, trait) (target.status_traits ? (target.status_traits[trait] ? TRUE : FALSE) : FALSE)
/// Checks if the mob has the specified trait from a specific source.
/// Slightly slower than HAS_TRAIT and should be avoided when proc-overhead matters (roughly >1000 calls per second)
#define HAS_TRAIT_FROM(target, trait, source) has_trait_from(target, trait, source)
/// Checks if the mob has the specified trait from a specific source and only that source.
/// Slightly slower than HAS_TRAIT and should be avoided when proc-overhead matters (roughly >1000 calls per second)
#define HAS_TRAIT_FROM_ONLY(target, trait, source) has_trait_from_only(target, trait, source)
/// Checks if the mob has the specified trait from any source except from the ones specified
/// Slightly slower than HAS_TRAIT and should be avoided when proc-overhead matters (roughly >1000 calls per second)
#define HAS_TRAIT_NOT_FROM(target, trait, source) has_trait_not_from(target, trait, source)

// Note: a?:b is used because : alone breaks the terniary operator
/// Get the value of the specified trait
#define GET_TRAIT_VALUE(target, trait) (target.status_traits ? (length(target.status_traits[trait]) ? (target.status_traits[trait][1]?:value) : null) : null)

/proc/has_trait_not_from(datum/target, trait, source)
	var/list/heap
	if ((heap = target.status_traits[trait]) == null)
		return FALSE
	for (var/contained_trait in heap)
		if (!(contained_trait ~= source))
			return TRUE
	return FALSE

/proc/has_trait_from(datum/target, trait, source)
	var/list/heap
	if ((heap = target.status_traits[trait]) == null)
		return FALSE
	for (var/contained_trait in heap)
		if (contained_trait ~= source)
			return TRUE
	return FALSE

/proc/has_trait_from_only(datum/target, trait, source)
	var/list/heap
	if ((heap = target.status_traits[trait]) == null)
		return FALSE
	. = FALSE
	for (var/contained_trait in heap)
		if (!(contained_trait ~= source))
			return FALSE
		. = TRUE
	return
