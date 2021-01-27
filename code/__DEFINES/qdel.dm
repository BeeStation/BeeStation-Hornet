//defines that give qdel hints. these can be given as a return in destory() or by calling


#define QDEL_HINT_QUEUE 		0 //qdel should queue the object for deletion.
#define QDEL_HINT_LETMELIVE		1 //qdel should let the object live after calling destory.
#define QDEL_HINT_IWILLGC		2 //functionally the same as the above. qdel should assume the object will gc on its own, and not check it.
#define QDEL_HINT_HARDDEL		3 //qdel should assume this object won't gc, and queue a hard delete using a hard reference.
#define QDEL_HINT_HARDDEL_NOW	4 //qdel should assume this object won't gc, and hard del it post haste.
//defines for the gc_destroyed var

#ifdef LEGACY_REFERENCE_TRACKING
/** If LEGACY_REFERENCE_TRACKING is enabled, qdel will call this object's find_references() verb.
  *
  * Functionally identical to QDEL_HINT_QUEUE if GC_FAILURE_HARD_LOOKUP is not enabled in _compiler_options.dm.
*/
#define QDEL_HINT_FINDREFERENCE	5
/// Behavior as QDEL_HINT_FINDREFERENCE, but only if the GC fails and a hard delete is forced.
#define QDEL_HINT_IFFAIL_FINDREFERENCE 6
#endif

#define GC_QUEUE_CHECK 1
#define GC_QUEUE_HARDDELETE 2
#define GC_QUEUE_COUNT 2 //increase this when adding more steps.

#define GC_QUEUED_FOR_QUEUING -1
#define GC_CURRENTLY_BEING_QDELETED -2

#define QDELING(X) (X.gc_destroyed)
#define QDELETED(X) (!X || QDELING(X))
#define QDESTROYING(X) (!X || X.gc_destroyed == GC_CURRENTLY_BEING_QDELETED)

