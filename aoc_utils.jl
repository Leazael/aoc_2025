using LinearAlgebra

function aocfile(d::Int64; test = false)
    dStr = lpad(string(d), 2, '0')
    return test ? "test/tst_d$(dStr).dat" : "input/inp_d$(dStr).dat"
end

function parse_aoc_data(rawData::AbstractString; type::Type = Vector{String}, re = r"\r?\n", columnre = r"(?<=\S)[\s,]+")
    if type <: AbstractString return rawData end

    if type <: Vector{<:Real}
        return parse.(eltype(type), parse_aoc_data(rawData, type = Vector{String}, re = re))
    end

    if type <: Vector{Char}
        return collect(rawData)
    end
    
    if type <: Matrix{<:Real}
        return parse.(eltype(type), parse_aoc_data(rawData, type = Matrix{String}, re = re, columnre = columnre))
    end

    data = filter(!isempty, split(rawData , re))

    if type <: Vector{Vector{String}} return [string.(split(d, columnre)) for d in data] end 
    if type <: Vector{<:AbstractString} return String.(data) end
    if type <: Matrix{Char}   return vcat([reshape(collect.(r), 1, :) for r in data]...) end 
    if type <: Matrix{String} return String.(vcat([reshape(strip.(split(s, columnre)), 1, :) for s in data]...)) end 

    if type <: Vector{Vector{Int64}} return [parse.(Int64, split(s, columnre)) for s in data] end

    throw(DomainError(type, "Could not properly parse type = $type"))
end

function aocload(n::Int64; test = false, type::Type = Vector{String}, re = r"\r?\n", columnre = r"(?<=\S)[\s,]+")
    f = aocfile(n, test = test)
    rawData = read(f, String)
    return parse_aoc_data(rawData, type = type, re = re, columnre = columnre)
end

function aocbuild(d::Int64; rebuild = true)

    if rebuild 
        cmd = `bash ./aoc_build.sh $d`
        run(cmd)
        return nothing
    end

    if !isdir("test")
        mkdir("test")
    end
    
    if !isdir("input")
        mkdir("input")
    end

    dStr = lpad(string(d), 2, '0')
    f1, f2, f3 = "test/tst_d$(dStr).dat", "input/inp_d$(dStr).dat", "day_$(dStr).jl"
    if !isfile(f1)
        open(f1, "w") do io
        end
    end

    if !isfile(f2)
        open(f2, "w") do io
        end
    end

    if !isfile(f3)
        open(f3, "w") do io
            println(io, "include(\"aoc_utils.jl\")")
            println(io, "aocbuild($d, rebuild = false)")
            println(io, "data = aocload($d, test = true)")
        end
    end
end

parseints(s::AbstractString) = [parse(Int64, q.match) for q in eachmatch(r"\d+", s)]

function edsger(cMatrix::AbstractMatrix{Bool}, wMatrix::AbstractMatrix, src::Int64, tgt::Int64; inf = typemax(wMatrix[1,1]), halt::Bool = true)
    # cMatrix is the connectivity matirx. wMatrix is the weights between any two given nodes.
    # shortest distance is given by dist[tgt], path can be reconstructed from prev[tgt], prev[prev[tgt]], etc.
    n = size(cMatrix, 1)
    dist = [inf for _ in 1:n]
    prev = [0 for _ in 1:n] # undefined! 
    Q = collect(1:n)
    dist[src] = 0

    while !isempty(Q)
        _, uInd = findmin(dist[Q])
        u = popat!(Q, uInd)
        if halt && u == tgt 
            break 
        end
        
        for v in findall(cMatrix[u, :])
            alt = dist[u] + wMatrix[u, v]
            if alt < dist[v]
                dist[v] = alt 
                prev[v] = u 
            end
        end
    end

    return dist, prev
end
function edsger(mMatrix::AbstractMatrix, src::Int64, tgt::Int64; inf = typemax(mMatrix[1,1]), halt::Bool = true)
    cMatrix = mMatrix .!= 0 
    return edsger(cMatrix, mMatrix, src, tgt; inf = inf, halt = halt)
end

function iedsger(start::N, fnext::Function, distance::Function  = (x,y) -> 1; finish::Function = x -> false, maxDist = Inf) where N
    # iedsger(start, fnext; finish = finish, maxDist = 10)
    # NTS: really make sure N has proper == and hash properties, or this will suck!

    # start is the starting state 
    # fnext returns all subsequent valid states 
    # distance(x,y) returns the distance from x to y. It must be non-negative
    # finish returns if the state is in a valid final state. (Optional)
    # hfun is an optional hash hunction to match states.

    # for faster checkig, add a native hash-type to start, and overload '=='
    T = typeof(distance(start, start))

    dist = Dict{N, T}(start => zero(T)) # total distance to the discovered states
    prev = Dict{N, Vector{N}}()         # which elements preceed which in the shortest-path graph

    queue = N[start]                    # the queue of next states. Keep sorted such that the closest is last.
    visited = N[]                       # visited nodes that need no further expansion
    
    while !isempty(queue)
        currentState = pop!(queue)      # start with the node with the smallest distance (NTS: queue is sorted!)

        if finish(currentState) || dist[currentState]  > maxDist        # Desired node has been reached!
            break 
        end

        for nextState in fnext(currentState)    # List the next valid states from the current one
            if !haskey(dist, nextState)         # this should be fast?
                dist[nextState] = typemax(T)    # if not in the distance dict yet, add it with dist = ∞
            elseif nextState in visited
                continue                        # if node already visited, no need to continue
            end

            currentDistance = dist[currentState]
            newDistance = currentDistance + distance(currentState, nextState)

            if newDistance < dist[nextState]
                dist[nextState] = newDistance
                prev[nextState] = [currentState]

                # test if already in queue, if so, kick it out!
                tInd = findall(x -> x == nextState, queue)
                deleteat!(queue, tInd)
                
                # insert into queue with the right, cooler,  priority
                qInd = searchsortedfirst([dist[k] for k in queue], newDistance, rev = true)
                insert!(queue, qInd, nextState)
            elseif newDistance == dist[nextState]
                push!(prev[nextState], currentState)
            end
        end

        push!(visited, currentState)
    end 

    return dist, prev
end

function allpaths(destination, prev) # returns all possible paths to the destination given the prev output of iedsger
    undone = [ [destination] ]
    pths = Vector{Int64}[]

    while !isempty(undone)
        pth = pop!(undone)
        for pv in prev[pth[end]]
            if pv == 0
                push!(pths, [pth; pv])
            else
                push!(undone, [pth; pv])
            end
        end
    end
    return pths
end

function permutations(n::Int64)
    pp = [ [1] ]
    for k = 2:n 
        qq = Vector{Int64}[]
        for p in pp
            for j in 0:(k-1)
                push!(qq, vcat(p[1:j], k, p[j+1:end]))
            end
        end
        pp = qq
    end
    return pp
end


function subsets(v::Vector{N}) where N
    if length(v) == 1
        return [v, N[]]
    else 
        ss = subsets(v[2:end])
        out = copy(ss)
        append!(out, [[v[1];s] for s in ss])        
        return out
    end
end

# subsets of a given max length
function subsets(v::Vector{N}, maxLength::Int64; proper::Bool = false) where N
    if maxLength == 0 
        return [ N[] ]
    elseif isempty(v)
        return [ N[] ]
    end

    ss_sans_v1 = subsets(v[2:end], maxLength)
    for ss in subsets(v[2:end], maxLength-1)
        push!(ss_sans_v1, [v[1]; ss])
    end
    if proper 
        popfirst!(ss_sans_v1)
    end
    return ss_sans_v1
end

const Cartesians4 = (CartesianIndex(0,1), CartesianIndex(0,-1), CartesianIndex(1,0), CartesianIndex(-1,0))
const Cartesians8 = (CartesianIndex(0,1), CartesianIndex(0,-1), CartesianIndex(1,0), CartesianIndex(-1,0), 
                     CartesianIndex(1,1), CartesianIndex(1,-1), CartesianIndex(-1,1), CartesianIndex(-1,-1))

disp(W::Matrix{Char}) = join(join.(eachrow(W), ' '),'\n') |> println

function mazenext2d(w::Matrix{Char}, p::CartesianIndex{2}; wall::Char = '#')
    out = [p + c for c in Cartesians4]
    return filter!(c -> isassigned(w, c) && (w[c] != wall), out)
end