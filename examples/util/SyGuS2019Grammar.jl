using HerbGrammar

"""
Grammar designed to solve SyGuS 2019 problems with the same grammar for each
"""
sygus_2019_grammar = @csgrammar begin
        Start = ntString
        ntString = _arg_1
        # ntString = ""
        ntStringDelim = " "
        ntStringDelim = "."
        ntStringDelim = ","
        ntStringDelim = "-"
        ntStringDelim = "_"
        ntStringDelim = "/"
        ntStringDelim = "="
        ntStringDelim = "<"
        ntStringDelim = ">"
        ntString = substr_cvc(ntString, ntInt, ntInt)
        # ntString = concat_cvc(ntString, ntString)
        # ntString = replace_cvc(ntString, ntStringDelim, ntStringDelim)
        # ntString = at_cvc(ntString, ntInt)
        # ntString = int_to_str_cvc(ntInt)
        ntInt = -1
        ntInt = 0
        ntInt = 1
        ntInt = 2
        # ntInt = 1
        ntInt = ntInt + ntInt
        # ntInt = ntInt - ntInt
        ntInt = len_cvc(ntString)
        # ntInt = str_to_int_cvc(ntString)
        # ntInt = ntBool ? ntInt : ntInt
        ntInt = indexof_cvc(ntString, ntStringDelim, ntInt)
        ntString = ntBool ? ntString : ntString
        #ntBool = true
        #ntBool = false
        ntBool = _arg_2 == ntInt
        ntBool = prefixof_cvc(ntStringDelim, ntString)
        ntBool = suffixof_cvc(ntStringDelim, ntString)
        ntBool = contains_cvc(ntString, ntStringDelim)
        # ntInt = val2
        # ntInt = val3
        ntStringDelim = ntString # this is just short circuited somehow
    end

    ruleid_substr = 12
    ruleid_plus = 17

    # do not chain substr_cvc
    # addconstraint!(g, Forbidden(
    #     RuleNode(5, [
    #         RuleNode(5, [RuleNode(5, [
    #             RuleNode(5, [RuleNode(5, [
    #                 RuleNode(5, [VarNode(:a), VarNode(:b), VarNode(:c)])
    #                 VarNode(:d)
    #                 VarNode(:e)
    #             ]), VarNode(:f), VarNode(:g)])
    #             VarNode(:h)
    #             VarNode(:i)
    #         ]), VarNode(:j), VarNode(:k)])
    #         VarNode(:l)
    #         VarNode(:m)
    #     ])
    # ))

    # do not chain substr_cvc
    # addconstraint!(g, Forbidden(
    #     RuleNode(ruleid_substr, [
    #         RuleNode(ruleid_substr, [VarNode(:a), VarNode(:b), VarNode(:c)])
    #         VarNode(:d)
    #         VarNode(:e)
    #     ])
    # ))

    # addconstraint!(g, ForbiddenSequence([ruleid_substr, ruleid_substr])) # do not nest substr_cvc
    # addconstraint!(g, ForbiddenSequence([ruleid_plus, ruleid_plus])) # do not chain (+)