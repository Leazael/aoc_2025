include("aoc_utils.jl")
aocbuild(4, rebuild = false)
data = aocload(4, type = Matrix{Char}, test = false)

function get_acc(M, r ='@')
    out = CartesianIndex{2}[]
    for i in CartesianIndices(M)
        if M[i] == r
            if count(p -> isassigned(M, p) && data[p] == r, i .+ Cartesians8) < 4
                push!(out, i)
            end
        end
    end
    return out 
end

n1 = count(==('@'), data)
ii = get_acc(data)
ii |> length |> output

while !isempty(ii)
    data[ii] .= ' ' 
    ii = get_acc(data)
end
n2 = count(==('@'), data)
n1 - n2 |> output