// Inherit the new values passed to the component
#define ISWIELDED(O) (SEND_SIGNAL(O, COMSIG_ITEM_CHECK_WIELDED) & COMPONENT_IS_WIELDED)
