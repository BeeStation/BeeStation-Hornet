//
#define CLIVIS_KEY_HOLYTURF "holyturf"



// Flags for /datum/element/client_vision_element
/// This image is shared across multiple client vision keys
#define CVE_FLAGS_SHARED_IMAGE (1<<0)
/// This image will be deleted by qdel of its parent
#define CVE_FLAGS_CUT_IMAGE_ON_QDEL (1<<1)
/// Once parent is deleted, all images bound to a vision key will be removed from the game. Be careful of using this. Do not use this if a vision key will be reused again.
#define CVE_FLAGS_NULLIFY_VISION_KEY_ON_QDEL (1<<2)
/// It looks you used wrong flag. Failsafe code.
#define CVE_FLAGS_ERROR (1<<3)
