include("aoc_utils.jl")
aocbuild(6, rebuild = false)
tst = false
data = aocload(6, test = tst)

nn = parse.(Int64, hcat(split.(data[1:end-1,:])...)) |> permutedims
pp = [getfield(Main, s) for s in Symbol.(split(data[end]))]

[p(n...) for (p,n) in zip(pp, eachcol(nn))] |> sum |> output

data2 = aocload(6, test = tst, type=Matrix{Char})[1:end-1,:]
rr = Int64[]
rrList = Vector{Int64}[]
out = 0
for c in reverse(eachcol(data2))
    s = strip(join(c))
    if isempty(s)
        # println(rr)
        push!(rrList, copy(rr))
        rr = Int64[]
    else
        # println(s)
        push!(rr, parse(Int64, s))
    end
end
reverse!(push!(rrList, copy(rr)))


[p(n...) for (p,n) in zip(pp, rrList)] |> sum |> output