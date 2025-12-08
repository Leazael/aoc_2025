include("aoc_utils.jl")
aocbuild(3, rebuild = false)
data = aocload(3, type=Matrix{Char}, test = false) .- '0'

function maxdigits(r, l)
    if l == 1 #only 1 
        return maximum(r)
    end
    # println(r)
    m, i = findmax(r[1:end-l+1])
    return 10^(l-1) * m + maxdigits(r[i+1:end], l-1)
end

[maxdigits(collect(r), 2) for r in eachrow(data)] |> sum |> output

[maxdigits(collect(r), 12) for r in eachrow(data)] |> sum |> output