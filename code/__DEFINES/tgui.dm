/// Green eye; fully interactive
#define UI_INTERACTIVE 2
/// Orange eye; updates but is not interactive
#define UI_UPDATE 1
/// Red eye; disabled, does not update
#define UI_DISABLED 0
/// UI Should close
#define UI_CLOSE -1

/// Maximum number of windows that can be suspended/reused
#define TGUI_WINDOW_SOFT_LIMIT 5
/// Maximum number of open windows
#define TGUI_WINDOW_HARD_LIMIT 9

/// Maximum ping timeout allowed to detect zombie windows
#define TGUI_PING_TIMEOUT 4 SECONDS
/// Used for rate-limiting to prevent DoS by excessively refreshing a TGUI window
#define TGUI_REFRESH_FULL_UPDATE_COOLDOWN 5 SECONDS

/// Window does not exist
#define TGUI_WINDOW_CLOSED 0
/// Window was just opened, but is still not ready to be sent data
#define TGUI_WINDOW_LOADING 1
/// Window is free and ready to receive data
#define TGUI_WINDOW_READY 2

/// Get a window id based on the provided pool index
#define TGUI_WINDOW_ID(index) "tgui-window-[index]"
/// Get a pool index of the provided window id
#define TGUI_WINDOW_INDEX(window_id) text2num(copytext(window_id, 13))

/// Creates a message packet for sending via output()
// This is {"type":type,"payload":payload}, but pre-encoded. This is much faster
// than doing it the normal way.
// To ensure this is correct, this is unit tested in tgui_create_message.
#define TGUI_CREATE_MESSAGE(type, payload) ( \
	"%7b%22type%22%3a%22[type]%22%2c%22payload%22%3a[url_encode(json_encode(payload))]%7d" \
)

/// Creates a message packet for sending via output() with no payload
#define TGUI_CREATE_MESSAGE_EMPTY(type) ( \
	"%7b%22type%22%3a%22[type]%22%7d" \
)

/// Telemetry

/**
 * Maximum number of connection records allowed to analyze.
 * Should match the value set in the browser.
 */
#define TGUI_TELEMETRY_MAX_CONNECTIONS 10

/**
 * Maximum time allocated for sending a telemetry packet.
 */
#define TGUI_TELEMETRY_RESPONSE_WINDOW 2 MINUTES

/// Telemetry statuses
#define TGUI_TELEMETRY_STAT_NOT_REQUESTED 0 //Not Yet Requested
#define TGUI_TELEMETRY_STAT_AWAITING      1 //Awaiting request response
#define TGUI_TELEMETRY_STAT_ANALYZED      2 //Retrieved and validated
#define TGUI_TELEMETRY_STAT_MISSING       3 //Telemetry response window miss without valid telemetry
#define TGUI_TELEMETRY_STAT_OVERSEND      4 //Telemetry was already processed but was repeated

/// Telem Trigger Defines
#define TGUI_TELEM_CKEY_WARNING "TELEM_CKEY_TEXT"
#define TGUI_TELEM_IP_WARNING "TELEM_IP_TEXT"
#define TGUI_TELEM_CID_WARNING "TELEM_CID_TEXT"

//unmagic-strings for types of polls
#define POLLTYPE_OPTION "OPTION"
#define POLLTYPE_TEXT "TEXT"
#define POLLTYPE_RATING "NUMVAL"
#define POLLTYPE_MULTI "MULTICHOICE"
#define POLLTYPE_IRV "IRV"
