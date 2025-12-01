include("aoc_utils.jl")
aocbuild(1, rebuild = false)
data = aocload(1, test = false)

turns = [parse(Int64, q[2:end])*(q[1]=='L' ? -1 : 1) for q in data]
pos = cumsum([50, turns...])

count(x -> mod(x,100) == 0, pos) |> println

p = 50
n = 0
for t in turns
    rr = t > 0 ? (1:t) : (-1:-1:t)
    n += count(iszero, mod.(p .+ rr, 100))
    p = mod(p+t,100)
end
n  |> println