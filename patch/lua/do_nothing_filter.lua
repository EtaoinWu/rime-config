local do_nothing = {}

function do_nothing.func(input)
    for cand in input:iter() do
        yield(cand)
    end
end

return do_nothing
