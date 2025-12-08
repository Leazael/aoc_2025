include("aoc_utils.jl")
aocbuild(2, rebuild = false)
data = aocload(2, test = false, type= Matrix{Int64},re=",", columnre="-")

# qq = [sum([10^(m*k) for k in 0:n]) => (n,m) for n in 1:1, m in 1:12 if n*m<11] |> sort 
out = Int64[]
for cc in eachrow(data)
    rr = cc[1]:cc[2]
    n1, n2 = ndigits(rr[1]), ndigits(rr[end])
    for j = 2:12 
        for k = 1:12 # length of segment
            if j*k > n2
                break
            end
            a = sum([10^(k*i) for i in 0:j-1])

            x = 10^(k-1)
            while a*x <= rr[end] && ndigits(x) <= k
                if x*a in rr
                    push!(out,x*a) 
                end
                x += 1
            end
        end
    end
end
out |> unique! |> sum |> println
out |> unique! |> sum |> clipboard 

48778605167