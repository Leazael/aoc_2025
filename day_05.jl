include("aoc_utils.jl")
aocbuild(5, rebuild = false)
data1, data2 = split(aocload(5, type = String, test = false), r"\r?\n\r?\n")

rr = [parse(Int64,m[1]):parse(Int64,m[2]) for m in eachmatch(r"(\d+)-(\d+)", data1) |> collect]
id = parse.(Int64, split(data2))

count(i -> any(r -> i in r, rr), id) |> output

function smash(rr0)
    rr = copy(rr0)
    ss = UnitRange{Int64}[]
    while !isempty(rr)
        r = pop!(rr)
        # println(r => ss)
        i = findfirst(s -> (r[1] in s )|| (r[end] in s), ss)
        if isnothing(i)
            push!(ss, r)
        else
            ss[i] = min(r[1], ss[i][1]):max(r[end], ss[i][end])
        end
    end
    return ss
end

for _ in 1:10
    rr = smash(rr)
end
length.(rr) |> sum |> output