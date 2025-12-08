include("aoc_utils.jl")
aocbuild(7, rebuild = false)
data = aocload(7, type = Matrix{Char},test = false)

N = size(data,2)

tc = [c[2] for c in findall(data .== 'S')]

function scotty(W, tt)
    jj = Int64[]
    s = 0
    for t in tt 
        if W[t] == '^'
            append!(jj, [t-1,t+1])
            s += 1
        else
            push!(jj, t)
        end
    end

    return s, unique!(jj)
end

out = 0
for k in 2:size(data, 1)
    s, tc = scotty(data[k,:], tc)
    out += s 
end
join(join.(eachrow(data)), '\n') |> println
out |> output

function spock(W, dd)
    jj = zeros(Int64, N)
    for k in 1:N
        if W[k] == '^'
            jj[k-1] += dd[k] 
            jj[k+1] += dd[k] 
        else
            jj[k] += dd[k] 
        end
    end

    return jj
end

d0 = zeros(Int64, N)
d0[findfirst(data .== 'S')[2]] = 1
for k in 1:size(data,1)
    d0[:] = spock(data[k,:], d0)
end
d0 |> sum |> output