#define SIGNAL_ADDTRAIT(trait_ref) "addtrait [trait_ref]"
#define SIGNAL_REMOVETRAIT(trait_ref) "removetrait [trait_ref]"
#define SIGNAL_UPDATETRAIT(trait_ref) "updatetrait [trait_ref]"

/datum/trait
	/// Source of the trait
	var/source
	/// The value contained in this trait
	var/value

/datum/trait/New(source, value = null)
	. = ..()
	src.source = source
	src.value = value

/datum/trait/priority
	/// The priority of this value trait, or null if there is no value
	var/priority

/datum/trait/priority/New(source, value = null, priority = 0)
	. = ..()
	src.priority = priority

/datum/trait/value_head
	var/add_cum = 0
	var/mult_cum = 1

/datum/trait/add

/datum/trait/multiply

/// Add a trait to a target
/// Parameters:
/// 1: The target to receive the trait
/// 2: The key of the trait
/// 3: The source of the trait
#define ADD_TRAIT(target, _trait, source) do { \
		if (!target.status_traits) { \
			target.status_traits = list(); \
		}; \
		var/list/_L = target.status_traits; \
		var/list/target_heap = _L[_trait];\
		if (target_heap != null) { \
			target_heap += source;\
		} else { \
			_L[_trait] = list(source); \
			SEND_SIGNAL(target, SIGNAL_ADDTRAIT(_trait), _trait); \
		} \
	} while (0)

/// Add a trait to a target
/// Parameters:
/// 1: The target to receive the trait
/// 2: The key of the trait
/// 3: The source of the trait
/// 4: The value stored in the trait
/// 5: The priority of the trait value
#define ADD_VALUE_TRAIT(_target, _trait, source, _trait_value, _trait_priority) do { \
		if (!_target.status_traits) { \
			_target.status_traits = list(); \
		}; \
		var/list/_L = _target.status_traits; \
		var/list/target_heap = _L[_trait];\
		if (target_heap != null) { \
			ADD_HEAP(target_heap, new /datum/trait/priority(source, _trait_value, _trait_priority), priority, /datum/trait/priority);\
		} else { \
			target_heap = list(); \
			ADD_HEAP(target_heap, new /datum/trait/priority(source, _trait_value, _trait_priority), priority, /datum/trait/priority);\
			_L[_trait] = target_heap;\
			SEND_SIGNAL(_target, SIGNAL_ADDTRAIT(_trait), _trait); \
			SEND_SIGNAL(_target, SIGNAL_UPDATETRAIT(_trait), _trait); \
		} \
	} while (0)

/// Add a cumulative trait to the target, this allows you to perform cross-module independance sums
/// that support multiplicative modification, for example:
/// - Add 5 movespeed
/// - Add 20% movespeed
/// - etc.
/// Ordering is deterministic and so is independant.
/// Parameters:
/// 1: The target to receive the trait
/// 2: The key of the trait
/// 3: The source of the trait
/// 4: The amount to add to the trait
#define ADD_CUMULATIVE_TRAIT(_target, _trait, _source, _additive_amount) do { \
		if (!_target.status_traits) { \
			_target.status_traits = list(); \
		}; \
		var/list/_L = _target.status_traits; \
		var/list/_target_list = _L[_trait];\
		if (_target_list != null) { \
			var/datum/trait/value_head/_head = _target_list[1];\
			_head.add_cum += _additive_amount;\
			_head.value = _head.add_cum * _head.mult_cum;\
			_target_list += new /datum/trait/add(_source, _additive_amount);\
		} else { \
			_target_list = list(); \
			_L[_trait] = _target_list;\
			_target_list += new /datum/trait/value_head();\
			var/datum/trait/value_head/_head = _target_list[1];\
			_head.add_cum += _additive_amount;\
			_head.value = _additive_amount;\
			_target_list += new /datum/trait/add(_source, _additive_amount);\
			SEND_SIGNAL(_target, SIGNAL_ADDTRAIT(_trait), _trait); \
			SEND_SIGNAL(_target, SIGNAL_UPDATETRAIT(_trait), _trait); \
		} \
	} while (0)

/// Add a multiplicative trait to the target, this allows you to perform cross-module independance sums
/// that support multiplicative modification, for example:
/// - Add 5 movespeed
/// - Add 20% movespeed
/// - etc.
/// Ordering is deterministic and so is independant.
/// Parameters:
/// 1: The target to receive the trait
/// 2: The key of the trait
/// 3: The source of the trait
/// 4: The amount to multiply the trait by
#define ADD_MULTIPLICATIVE_TRAIT(_target, _trait, _source, _multiplicative_amount) do { \
		if (!_target.status_traits) { \
			_target.status_traits = list(); \
		}; \
		var/list/_L = _target.status_traits; \
		var/list/_target_list = _L[_trait];\
		if (_target_list != null) { \
			var/datum/trait/value_head/_head = _target_list[1];\
			_head.mult_cum *= _multiplicative_amount;\
			_head.value = _head.add_cum * _head.mult_cum;\
			_target_list += new /datum/trait/multiply(_source, _multiplicative_amount);\
		} else { \
			_target_list = list(); \
			_L[_trait] = _target_list;\
			_target_list += new /datum/trait/value_head();\
			var/datum/trait/value_head/_head = _target_list[1];\
			_head.mult_cum *= _multiplicative_amount;\
			_head.value = 0;\
			_target_list += new /datum/trait/multiply(_source, _multiplicative_amount);\
			SEND_SIGNAL(_target, SIGNAL_ADDTRAIT(_trait), _trait); \
			SEND_SIGNAL(_target, SIGNAL_UPDATETRAIT(_trait), _trait); \
		} \
	} while (0)

/// Cleans up some define code, don't use this.
/// Condition: _T is the trait object
#define REMOVE_TRAIT_IF(_target, _trait, _trait_list, _condition) \
	if (_trait_list) { \
		var/_cached_source = _trait_list[1]; \
		if (!istype(_cached_source, /datum/trait)) { \
			for (var/_T in _trait_list) { \
				if (##_condition) { \
					_trait_list -= _T;\
				} \
			}\
		} else if (istype(_cached_source, /datum/trait/priority)) { \
			for (var/datum/trait/_trait_datum as anything in _trait_list) { \
				var/_T = _trait_datum.source;\
				if (##_condition) { \
					REMOVE_HEAP(_trait_list, _trait_datum, priority, /datum/trait/priority); \
					if (length(_trait_list) && _trait_list[1] != _cached_source) {\
						SEND_SIGNAL(_target, SIGNAL_UPDATETRAIT(_trait), _trait); \
					}\
				} \
			}\
		} else if (istype(_cached_source, /datum/trait/value_head)) { \
			var/_changed = FALSE;\
			for (var/__i = length(_trait_list); __i >= 2; __i--) {\
				var/datum/trait/_trait_datum = _trait_list[__i]; \
				var/_T = _trait_datum.source;\
				if (##_condition) { \
					_trait_list -= _trait_datum;\
					_changed = TRUE;\
				} \
			} /* We have to perform a full recalculation as infinity and 0 lose precision */ \
			if (_changed) {\
				var/datum/trait/value_head/value_head = _trait_list[1];\
				value_head.add_cum = 0;\
				value_head.mult_cum = 1;\
				for (var/__j = 2; __j <= length(_trait_list); __j++) {\
					var/datum/trait/scanned_trait = _trait_list[__j];\
					if (istype(_trait_list[__j], /datum/trait/add)) {\
						value_head.add_cum += scanned_trait.value;\
					} else {\
						value_head.mult_cum *= scanned_trait.value;\
					}\
				}\
				value_head.value = value_head.add_cum * value_head.mult_cum;\
				SEND_SIGNAL(_target, SIGNAL_UPDATETRAIT(_trait), _trait); \
			}\
			if (length(_trait_list) == 1) {\
				_trait_list.Cut();\
			}\
		} else { \
			stack_trace("Invalid trait type found in trait list, [_cached_source]"); \
		} \
	}

/// Removes a trait from a specific source
#define REMOVE_TRAIT(_target, _trait, _sources) \
	do { \
		var/list/_L = _target.status_traits; \
		var/list/_S; \
		if (_sources && !islist(_sources)) { \
			_S = list(_sources); \
		} else { \
			_S = _sources;\
		}; \
		if (_L && _L[_trait]) { \
			var/list/_heap = _L[_trait];\
			REMOVE_TRAIT_IF(_target, _trait, _heap, (!_S && (_T != ROUNDSTART_TRAIT)) || (_T in _S)); \
			if (!length(_heap)) { \
				_L -= _trait; \
				SEND_SIGNAL(_target, SIGNAL_REMOVETRAIT(_trait), _trait); \
				SEND_SIGNAL(_target, SIGNAL_UPDATETRAIT(_trait), _trait); \
			}; \
			if (!length(_L)) { \
				_target.status_traits = null; \
			}; \
		} \
	} while (0)

/// Remove all sources of a trait unless it comes from one of the provided sources
#define REMOVE_TRAIT_NOT_FROM(_target, _trait, _sources) \
	do { \
		var/list/_L = _target.status_traits; \
		var/list/_S; \
		if (_sources && !islist(_sources)) { \
			_S = list(_sources); \
		} else { \
			_S = _sources;\
		}; \
		if (_L && _L[_trait]) { \
			var/list/_heap = _L[_trait];\
			REMOVE_TRAIT_IF(_target, _trait, _heap, !(_T in _S)); \
			if (!length(_heap)) { \
				_L -= _trait; \
				SEND_SIGNAL(_target, SIGNAL_REMOVETRAIT(_trait), _trait); \
				SEND_SIGNAL(_target, SIGNAL_UPDATETRAIT(_trait), _trait); \
			}; \
			if (!length(_L)) { \
				_target.status_traits = null; \
			}; \
		} \
	} while (0)

// You probably shouldn't be using this
/// Remove all traits that don't come from the specified source
#define REMOVE_TRAITS_NOT_IN(_target, _sources) \
	do { \
		var/list/_L = _target.status_traits; \
		var/list/_sources_list = islist(_sources) ? _sources : list(_sources); \
		if (_L) { \
			for (var/_trait_key as anything in _L) { \
				var/list/_heap = _L[_trait_key];\
				REMOVE_TRAIT_IF(_target, _trait_key, _heap, !(_T in _sources_list)); \
				if (!length(_heap)) { \
					_L -= _trait_key; \
					SEND_SIGNAL(_target, SIGNAL_REMOVETRAIT(_trait_key), _trait_key); \
					SEND_SIGNAL(_target, SIGNAL_UPDATETRAIT(_trait_key), _trait_key); \
				}; \
			};\
			if (!length(_L)) { \
				_target.status_traits = null;\
			};\
		};\
	} while (0)

/// Removes all traits that come from a specific source
#define REMOVE_TRAITS_IN(_target, _sources) \
	do { \
		var/list/_L = _target.status_traits; \
		var/list/_sources_list = islist(_sources) ? _sources : list(_sources); \
		if (_L) { \
			for (var/_trait_key as anything in _L) { \
				var/list/_heap = _L[_trait_key];\
				REMOVE_TRAIT_IF(_target, _trait_key, _heap, (_T in _sources_list)); \
				if (!length(_heap)) { \
					_L -= _trait_key; \
					SEND_SIGNAL(_target, SIGNAL_REMOVETRAIT(_trait_key), _trait_key); \
					SEND_SIGNAL(_target, SIGNAL_UPDATETRAIT(_trait_key), _trait_key); \
				}; \
			};\
			if (!length(_L)) { \
				_target.status_traits = null;\
			};\
		};\
	} while (0)

/// Checks if the mob has the specified trait
#define HAS_TRAIT(target, trait) (target.status_traits ? (target.status_traits[trait] ? TRUE : FALSE) : FALSE)
/// Checks if the mob has the specified trait from a specific source.
/// Slightly slower than HAS_TRAIT and should be avoided when proc-overhead matters (roughly >1000 calls per second)
#define HAS_TRAIT_FROM(target, trait, source) (target.status_traits && ____has_trait_from(target, trait, source))
/// Checks if the mob has the specified trait from a specific source and only that source.
/// Slightly slower than HAS_TRAIT and should be avoided when proc-overhead matters (roughly >1000 calls per second)
#define HAS_TRAIT_FROM_ONLY(target, trait, source) (target.status_traits && ____has_trait_from_only(target, trait, source))
/// Checks if the mob has the specified trait from any source except from the ones specified
/// Slightly slower than HAS_TRAIT and should be avoided when proc-overhead matters (roughly >1000 calls per second)
#define HAS_TRAIT_NOT_FROM(target, trait, source) (target.status_traits && ____has_trait_not_from(target, trait, source))
/// A simple helper for checking traits in a mob's mind
#define HAS_MIND_TRAIT(target, trait) (HAS_TRAIT(target, trait) || (target.mind ? HAS_TRAIT(target.mind, trait) : FALSE))
/// Returns a list of trait sources for this trait. Only useful for wacko cases and internal futzing
#define GET_TRAIT_SOURCES(target, trait) (target.status_traits?[trait] || list())

GLOBAL_DATUM_INIT(_trait_located, /datum/trait, null)

// Note: a?:b is used because : alone breaks the terniary operator
/// Get the value of the specified trait
#define GET_TRAIT_VALUE(target, trait) (target.status_traits ? (length(target.status_traits[trait]) ? ((GLOB._trait_located = target.status_traits[trait][1]) && GLOB._trait_located.value) : null) : null)

/proc/____has_trait_not_from(datum/target, trait, source)
	var/list/heap
	if ((heap = target.status_traits[trait]) == null)
		return FALSE
	for (var/contained_trait in heap)
		if (!(contained_trait == source))
			return TRUE
	return FALSE

/proc/____has_trait_from(datum/target, trait, source)
	var/list/heap
	if ((heap = target.status_traits[trait]) == null)
		return FALSE
	for (var/contained_trait in heap)
		if (contained_trait == source)
			return TRUE
	return FALSE

/proc/____has_trait_from_only(datum/target, trait, source)
	var/list/heap
	if ((heap = target.status_traits[trait]) == null)
		return FALSE
	. = FALSE
	for (var/contained_trait in heap)
		if (!(contained_trait == source))
			return FALSE
		. = TRUE
	return
