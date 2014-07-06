module Processing

macro version(v)
    quote
        local v = $v
        local file = "Processing/src/Processing$(v).jl"

        # These two Base library calls are being used instead of just
        # require()-ing the file because the require() function itself has a
        # hardcoded context value of 'Main' when it evals the file contents.
        #
        # The only workaround I can think of is to make the same call that
        # the require function makes, ourselves, in the context of our module.
        Processing.eval(:(Base.include_from_node1(Base.find_in_path($file))))
        # Unlike the require() function, the `using` builtin accepts a module
        # context to operate within.
        Processing.eval(Expr(:using, :Processing, :ProcessingStd))

    end
end

macro load()
    quote
        Processing.eval(Expr(:export, names(Processing.eval(:ProcessingStd))...))
    end
end

end # module Processing
