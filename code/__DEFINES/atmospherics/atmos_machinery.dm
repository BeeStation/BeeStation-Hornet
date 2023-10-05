/*
// Air alarm buildstage [/obj/machinery/airalarm/buildstage]
/// Air alarm missing circuit
#define AIR_ALARM_BUILD_NO_CIRCUIT 0
/// Air alarm has circuit but is missing wires
#define AIR_ALARM_BUILD_NO_WIRES 1
/// Air alarm has all components but isn't completed
#define AIR_ALARM_BUILD_COMPLETE 2
*/

///TLV datums wont check limits set to this
#define TLV_DONT_CHECK -1
///the gas mixture is within the bounds of both warning and hazard limits
#define TLV_NO_DANGER 0
///the gas value is outside the warning limit but within the hazard limit, the air alarm will go into warning mode
#define TLV_OUTSIDE_WARNING_LIMIT 1
///the gas is outside the hazard limit, the air alarm will go into hazard mode
#define TLV_OUTSIDE_HAZARD_LIMIT 2
