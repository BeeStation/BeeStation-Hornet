#define GENERAL_PROTECT_DATUM(Path)\
##Path/can_vv_get(var_name){\
    return EF_FALSE;\
}\
##Path/vv_edit_var(var_name, var_value){\
    return EF_FALSE;\
}\
##Path/CanProcCall(procname){\
    return EF_FALSE;\
}
