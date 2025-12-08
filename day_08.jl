include("aoc_utils.jl")
aocbuild(8, rebuild = false)

tst = true
data = aocload(8, test = tst, type=Matrix{Int64}, columnre = ",")

m = size(data, 1)
n = tst ? 10 : 1000
nrm(x) = sum(x.*x)
