// Atom movement signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

///signal sent out by an atom when it is no longer being pulled by something else : (atom/puller)
#define COMSIG_ATOM_NO_LONGER_PULLED "movable_no_longer_pulled"
///signal sent out by an atom when it is no longer pulling something : (atom/pulling)
#define COMSIG_ATOM_NO_LONGER_PULLING "movable_no_longer_pulling"
