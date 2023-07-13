
#define QUALIFY_TYPE_DENY_ANY "deny_any"
#define QUALIFY_TYPE_ACCEPT_SINGLE "accept_single"
#define QUALIFY_TYPE_ACCEPT_FULL "accept_full"



#define EXPJOB_TIMEREQ_LIVING_DEFAULT 5

#define EXP_CHECK_PASS "pass"
#define EXP_CHECK_DESC "desc"

#define INIT_EXP_LIST list(EXP_CHECK_PASS=TRUE, EXP_CHECK_DESC=list())
#define ADD_EXP_REQ_FORMAT(v, x...) ##v += new /datum/job_playtime_req(##x)
