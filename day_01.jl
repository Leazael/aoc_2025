include("aoc_utils.jl")
aocbuild(1, rebuild = false)
data = aocload(1, test = false, type = Vector{Char}) .- '0'

N = length(data)

[data[k] for k in 1:N if queue[k] == queue[mod(k,         N) + 1]] |> sum |> println
[data[k] for k in 1:N if queue[k] == queue[mod(k+(N÷2)-1, N) + 1]] |> sum |> println