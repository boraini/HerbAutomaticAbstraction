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
        return l[1]
    end

    function tail(l)
        return l[2:length(l)]
    end

    function cons(el, l)
        new_l = copy(l)
        pushfirst!(new_l, el)
        return new_l
    end

    function times(n, h)
        return n * h
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