//A set of defines to be used by the alarm datums
///Sent by air alarms, indecates something wrong with thier attached atmosphere
#define ALARM_ATMOS "Atmosphere"
///Sent by firelocks when they detect fire, and by fire alarms when a user pulls them
#define ALARM_FIRE "Fire"
///Sent by apcs when their power starts to fail
#define ALARM_POWER "Power"
///Sent by cameras when they're disabled in some manner
#define ALARM_CAMERA "Camera"
///Sent by display cases when they're broken into
#define ALARM_BURGLAR "Burglar"
///Sent by motion detecting cameras when they well, detect motion
#define ALARM_MOTION "Motion"

//Readout IDs
///power grid layer.
#define ALERT_LAYER_GRID "apc"
///structural damage layer.
#define ALERT_LAYER_INTEGRITY "integrity"

///How a work order claim ended, for the records SSwork_orders keeps.
#define WORK_OUTCOME_COMPLETED "completed"
#define WORK_OUTCOME_DROPPED "dropped"
#define WORK_OUTCOME_REASSIGNED "reassigned"

///Work order urgency, lowest number first on the board
#define WORK_PRIORITY_CRITICAL 0
#define WORK_PRIORITY_HIGH 1
#define WORK_PRIORITY_NORMAL 2
#define WORK_PRIORITY_LOW 3
