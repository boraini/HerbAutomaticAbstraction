module Lisp
    function abstract(sym, e2)
        return sym -> e2
    end

    function apply(fn, val)
        fn(val)
    end

    # TODO: y-combinator
    # y = apply(abstract(:f, abstract(:x, apply(:x, :x))), abstract(:f, apply(:x, :x)))

    function head(l)
        return l[0]
    end

    function tail(l)
        return l[1:length(l)]
    end

    function cons(el, l)
        new_l = clone(l)
        pushfirst!(el, new_l)
        return new_l
    end

    function nil()
        return []
    end

    export
      abstract,
      apply,
      head,
      tail,
      cons,
      nil
end