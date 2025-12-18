/// From /obj/item/shockpaddles/proc/do_success(): (obj/item/shockpaddles/source)
#define COMSIG_DEFIBRILLATOR_SUCCESS "defib_success"
	#define COMPONENT_DEFIB_STOP (1<<0)

/// From /datum/surgery/can_start(): (mob/source, datum/surgery/surgery, mob/living/patient)
#define COMSIG_SURGERY_STARTING "surgery_starting"
	#define COMPONENT_CANCEL_SURGERY (1<<0)
	#define COMPONENT_FORCE_SURGERY (1<<1)
