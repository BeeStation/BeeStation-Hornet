#ifndef SPACELIZARD_HEADER
#define SPACELIZARD_HEADER
#ifdef SPACELIZARD
#define SHOULD_CALL_ALL_PARAMS(X) set __spacelizard_call_all_params = X
#define SHOULD_CALL_REQUIRED_PARAMS(X) set __spacelizard_call_required_params = X
#define SHOULD_STATE_PARAM_NAMES(X) set __spacelizard_state_param_names = X
#define SHOULD_KEEP_PARAM_ORDER(X) set __spacelizard_keep_param_order = X
#define PARAM_LINT_SKIP(X) __spacelizard_skip_param(X)
#define SET_VAR_RULE(TARGET, RULES...) __spacelizard_var_rule() { __spacelizard_rule(#TARGET, RULES); }
#define BYPASS_VAR_RULE(X) __spacelizard_bypass_var_rule(X)
#define BYPASS_VAR_RULE_BLOCK if(__spacelizard_bypass_block())
#else
#define SHOULD_CALL_ALL_PARAMS(X)
#define SHOULD_CALL_REQUIRED_PARAMS(X)
#define SHOULD_STATE_PARAM_NAMES(X)
#define SHOULD_KEEP_PARAM_ORDER(X)
#define PARAM_LINT_SKIP(X) (X)
#define SET_VAR_RULE(TARGET, RULES...)
#define BYPASS_VAR_RULE(X) (X)
#define BYPASS_VAR_RULE_BLOCK if(1)
#endif
#endif
