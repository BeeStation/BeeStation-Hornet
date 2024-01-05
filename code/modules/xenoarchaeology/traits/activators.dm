//These traits cause the xenoartifact to trigger, activate
/datum/xenoartifact_trait/activator
    ///Do we override the artifact's generic cooldown?
    var/override_cooldown = FALSE

//Throw custom cooldown logic in here
/datum/xenoartifact_trait/activator/proc/trigger_artifact()
    SIGNAL_HANDLER

    parent.trigger()
    return

/*
    Sturdy
    This trait activates the artifact when it's used, like a generic item
*/

/datum/xenoartifact_trait/activator/strudy

/datum/xenoartifact_trait/activator/strudy/New()
    . = ..()
    RegisterSignal(parent.parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(trigger_artifact))
