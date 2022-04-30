using Test

struct BoardPosition
    x::Int
    y::Int
end

Base.abs(position::BoardPosition) = BoardPosition(abs(position.x), abs(position.y))
Base.:+(a::BoardPosition, b::BoardPosition) = BoardPosition(a.x + b.x, a.y + b.y)
Base.:-(a::BoardPosition, b::BoardPosition) = BoardPosition(a.x - b.x, a.y - b.y)
Base.:(==)(a::BoardPosition, b::BoardPosition) = (a.x == b.x) && (a.y == b.y)

isinboard(a::BoardPosition) = 0 < a.x < 11 && 0 < a.y < 11
isknightmove(position::BoardPosition) = (abs(position) == BoardPosition(1, 2) || abs(position) == BoardPosition(2, 1))
Base.print_to_string(position::BoardPosition) = string("(", position.x, ", ", position.y, ")")

function octopus(position::BoardPosition)::Array
    all = [position + BoardPosition(1, 2),
    position + BoardPosition(2, 1) ,
    position + BoardPosition(-1, 2),
    position + BoardPosition(2, -1),
    position + BoardPosition(1, -2),
    position + BoardPosition(-2, 1),
    position + BoardPosition(-1, -2),
    position + BoardPosition(-2, -1)]
    return filter(p -> isinboard(p), all)
end

function collectfixedpositions()
    return Dict(2 => BoardPosition(2, 5), 
                5 => BoardPosition(7, 9), 
                8 => BoardPosition(7, 8), 
                12 => BoardPosition(1, 10),
                14 => BoardPosition(4, 7), 
                20 => BoardPosition(5, 4), 
                23 => BoardPosition(9, 9), 
                28 => BoardPosition(10, 1),
                33 => BoardPosition(5, 3))
end

pathdoesntfold(moves::Array)::Bool = length(moves) == length(unique(moves))

function lastpointisnotoff(moves::Array)::Bool
    fixedpositions = collectfixedpositions()
    value = get(fixedpositions, length(moves), 0)
    if value != 0 && value != last(moves)
        return false
    end
    return true
end

function pathsbetweentwopoints(departure::BoardPosition, arrival::BoardPosition, steps::Int)::Array{Array{BoardPosition}}
    if steps == 1
        if isknightmove(departure - arrival)
            return [[departure, arrival]]
        else
            return []
        end
    end
    solutions = []
    if steps > 1
        continuations = []
        possiblefirststeps = octopus(departure)
        for firststep in possiblefirststeps
            union!(continuations, pathsbetweentwopoints(firststep, arrival, steps - 1))
        end
        for continuation in continuations
            pushfirst!(continuation, departure)
            push!(solutions, continuation)
        end
    end
    #check
    for s in solutions
        if last(s) != arrival || first(s) != departure
            error("strange")
        end
    end
    #end check
    return filter(s -> pathdoesntfold(s) && length(s) == steps + 1, solutions)
end

function onestepforward(path::Array{BoardPosition})::Array{Array{BoardPosition}}
    paths = []
    for next in octopus(last(path))
        if !(next in path)
            copiedpath = copy(path)
            push!(copiedpath, next)
            push!(paths, copiedpath)
        end
    end
    paths
end

function onestepbackward(arrival::BoardPosition)
    paths = []
    for previous in octopus(arrival)
        push!(paths, [previous, arrival])
    end
    return filter(p -> pathdoesntfold(p), paths)
end

function valueinarea(area::Array, path::Array{BoardPosition})::Int
    tot = 0
    for i in 1:length(path)
        if path[i] in area
            tot += i
        end
    end
    return tot
end

function regions()::Array{Array{BoardPosition}}
    yellowMonster = []
    for i in 1:10
        push!(yellowMonster, BoardPosition(i, 10))
        if i != 4 && i != 9
            push!(yellowMonster, BoardPosition(i, 9))
            push!(yellowMonster, BoardPosition(i, 8))
        end
    end
    union!(yellowMonster, [BoardPosition(1, 7), BoardPosition(2, 7), BoardPosition(2, 6), BoardPosition(4, 6), BoardPosition(5, 6), BoardPosition(2, 5), BoardPosition(3, 5), BoardPosition(4, 5)])

    return [[BoardPosition(2, 4), BoardPosition(3, 4), BoardPosition(3, 3)], #bluetriangle
    [BoardPosition(6, 3), BoardPosition(7, 3), BoardPosition(8, 3)], #bluehorizontal
    [BoardPosition(4, 1), BoardPosition(5, 1), BoardPosition(6, 1), BoardPosition(7, 1), BoardPosition(8, 1)], #bluelow
    [BoardPosition(7, 6), BoardPosition(7, 7), BoardPosition(8, 6), BoardPosition(9, 6), BoardPosition(10, 6), BoardPosition(10, 5)],#blueZ
    [BoardPosition(8, 2), BoardPosition(9, 2), BoardPosition(9, 1)], #greentriangle
    [BoardPosition(5, 4), BoardPosition(5, 5), BoardPosition(6, 5), BoardPosition(7, 5), BoardPosition(6, 6)], #greenmonster
    [BoardPosition(1, 1), BoardPosition(2, 1), BoardPosition(2, 2), BoardPosition(2, 3)], #greenL
    [BoardPosition(6, 4), BoardPosition(7, 4)], #yellowcentral
    [BoardPosition(3, 2), BoardPosition(3, 1)], #yelloleft
    [BoardPosition(5, 2), BoardPosition(6, 2), BoardPosition(7, 2)], #yellowlower
    [BoardPosition(10, 1), BoardPosition(10, 2), BoardPosition(10, 3), BoardPosition(10, 4)], #yellowright
    [BoardPosition(1, 2), BoardPosition(1, 3), BoardPosition(1, 4), BoardPosition(1, 5), BoardPosition(1, 6)],#rosalateral
    [BoardPosition(4, 2), BoardPosition(4, 3), BoardPosition(4, 4), BoardPosition(5, 3)], #rosasmallT
    [BoardPosition(8, 7), BoardPosition(9, 7), BoardPosition(10, 7), BoardPosition(9, 8), BoardPosition(9, 9)], #rosabigT
    [BoardPosition(3, 6), BoardPosition(3, 7), BoardPosition(4, 7), BoardPosition(4, 8), BoardPosition(4, 9), BoardPosition(5, 7), BoardPosition(6, 7)],#rosaLT
    [BoardPosition(8, 4), BoardPosition(8, 5), BoardPosition(9, 3), BoardPosition(9, 4), BoardPosition(9, 5)],#rosainverseP
    yellowMonster] 
end

function valueinsideyellowarea(path)
    return valueinarea([BoardPosition(3, 1), BoardPosition(3, 2)] , path)
end

function hasconsistentvalues(path)
    areas::Array{Array{BoardPosition}} = regions()
    referencevalue = valueinsideyellowarea(path)
    for area in areas
        if referencevalue != valueinarea(area, path)
            return false
        end
    end
    return true
end

function printpath(path::Array{BoardPosition})
    msg = ""
    for position in path
        msg = string(msg, " -> ", Base.print_to_string(position))
    end
    println(msg)
end

function mergepaths(firstpath::Array{BoardPosition}, secondpath::Array{BoardPosition})
    if last(firstpath) != secondpath[1]
        printpath(firstpath)
        printpath(secondpath)
        error("the two paths don't meet")
    end
    fp = copy(firstpath)
    deleteat!(fp, length(fp)) #remove last element
    union!(fp, secondpath)
    return fp
end

function combinepaths(paths1::Array{Array{BoardPosition}}, paths2::Array{Array{BoardPosition}})::Array{Array{BoardPosition}}
    resultingpaths::Array{Array{BoardPosition}} = []
    i = 1
    for path1 in paths1
        for path2 in paths2
            if rem(i, 1000000) == 0
                println(i)
            end
            if length(intersect(path1, path2)) == 1
                push!(resultingpaths, mergepaths(path1, path2))
            end
            i += 1
        end
    end
    return resultingpaths
end

function findtotalsolution(n)
    paths1::Array{Array{BoardPosition}} = onestepbackward(BoardPosition(2, 5))
    paths2::Array{Array{BoardPosition}} = pathsbetweentwopoints(BoardPosition(2, 5), BoardPosition(7, 9), 3) # from 2 to 5
    paths3::Array{Array{BoardPosition}} = pathsbetweentwopoints(BoardPosition(7, 9), BoardPosition(7, 8), 3) # from 5 to 8 
    paths4::Array{Array{BoardPosition}} = pathsbetweentwopoints(BoardPosition(7, 8), BoardPosition(1, 10), 4) # from 8 to 12
    paths5::Array{Array{BoardPosition}} = pathsbetweentwopoints(BoardPosition(1, 10), BoardPosition(4, 7), 2) # from 12 to 14
    paths6::Array{Array{BoardPosition}} = pathsbetweentwopoints(BoardPosition(4, 7), BoardPosition(5, 4), 6) # from 14 to 20
    paths7::Array{Array{BoardPosition}} = pathsbetweentwopoints(BoardPosition(5, 4), BoardPosition(9, 9), 3) # from 20 to 23
    paths8::Array{Array{BoardPosition}} = pathsbetweentwopoints(BoardPosition(9, 9), BoardPosition(10, 1), 5) # from 23 to 28
    paths9::Array{Array{BoardPosition}} = pathsbetweentwopoints(BoardPosition(10, 1), BoardPosition(5, 3), 5) # from 28 to 33

    for p in [paths1, paths2, paths3, paths4, paths5, paths6, paths7, paths8, paths9]
        println(length(p))
    end


    println("combining first paths")
    firstpaths = combinepaths(combinepaths(combinepaths(combinepaths(combinepaths(paths1, paths2), paths3), paths4), paths5), paths6)
    println("combining last paths")
    lastpaths = combinepaths(combinepaths(paths7, paths8), paths9)
    f = length(firstpaths)
    l = length(lastpaths)
    println("combining all paths: $f and $l")
    totalpaths = combinepaths(firstpaths, lastpaths)
    println("combined")
    printtotalandadmissiblepaths(totalpaths)

    for s in 1:n
        continuedpaths::Array{Array{BoardPosition}} = []
        for p in totalpaths
            union!(continuedpaths, onestepforward(p))
        end
        allpaths = filter(p -> pathdoesntfold(p), continuedpaths)
        printtotalandadmissiblepaths(allpaths)
    end
end

function printtotalandadmissiblepaths(somepaths::Array{Array{BoardPosition}})
    if length(somepaths) != 0 
        println(string("step ", length(first(somepaths)), ": ", length(somepaths), " -> ", length(filter(p -> hasconsistentvalues(p), somepaths))))
    end
end 

@testset begin    
    @testset "basic operations" begin
        @test isknightmove(BoardPosition(1, 0) + BoardPosition(0, 2))
        @test isknightmove(BoardPosition(-1, 0) + BoardPosition(0, 2))
        @test isknightmove(BoardPosition(-1, 0) - BoardPosition(1, 1))
        @test !isknightmove(BoardPosition(2, 3) - BoardPosition(3, 4))
    end

    @testset "isknightmove" begin
        @test isknightmove(BoardPosition(1, 2))
        @test isknightmove(BoardPosition(-1, 2))
        @test isknightmove(BoardPosition(-1, -2))
        @test !isknightmove(BoardPosition(1, 3))
        @test !isknightmove(BoardPosition(2, 3))
        @test !isknightmove(BoardPosition(-2, 0))

        @test isknightmove(abs(BoardPosition(-1, -1)) + BoardPosition(0, 1))
        @test !isknightmove(BoardPosition(-1, -1) + BoardPosition(0, 1))
        @test BoardPosition(-1, -1) + BoardPosition(0, 1) == BoardPosition(-1, 0)
        @test !(BoardPosition(-1, -1) + BoardPosition(0, 1) == BoardPosition(-1, 1))
    end

    @testset "pathdoesntfold" begin
        @test pathdoesntfold([BoardPosition(1, 1), BoardPosition(2, 3)])
        @test pathdoesntfold([BoardPosition(1, 1), BoardPosition(2, 3), BoardPosition(3, 5), BoardPosition(2, 7)])
        @test !pathdoesntfold([BoardPosition(2, 3), BoardPosition(2, 3)])
        @test !pathdoesntfold([BoardPosition(1, 1), BoardPosition(2, 3), BoardPosition(2, 3)])
        @test !pathdoesntfold([BoardPosition(1, 1), BoardPosition(2, 3), BoardPosition(1, 1)])
    end

    @testset "octopus" begin
        @test BoardPosition(2, 3) in octopus(BoardPosition(1, 1))
        @test !(BoardPosition(0, 3) in octopus(BoardPosition(1, 1)))
        @test BoardPosition(5, 6) in octopus(BoardPosition(4, 8))
    end

    @testset "path" begin
        @test length(pathsbetweentwopoints(BoardPosition(1, 1), BoardPosition(2, 3), 1)) == 1
        @test length(pathsbetweentwopoints(BoardPosition(1, 2), BoardPosition(2, 3), 1)) == 0
        @test BoardPosition(1, 1) in pathsbetweentwopoints(BoardPosition(1, 1), BoardPosition(2, 3), 1)[1]
        @test BoardPosition(2, 3) in pathsbetweentwopoints(BoardPosition(1, 1), BoardPosition(2, 3), 1)[1]

        @test length(pathsbetweentwopoints(BoardPosition(1, 1), BoardPosition(3, 5), 2)) == 1
        @test length(pathsbetweentwopoints(BoardPosition(1, 1), BoardPosition(4, 4), 2)) == 2
        @test length(pathsbetweentwopoints(BoardPosition(1, 1), BoardPosition(5, 6), 3)) == 3
        @test length(pathsbetweentwopoints(BoardPosition(1, 1), BoardPosition(1, 5), 2)) == 1
        @test length(pathsbetweentwopoints(BoardPosition(1, 1), BoardPosition(1, 5), 2)) == 1
        @test length(pathsbetweentwopoints(BoardPosition(4, 7), BoardPosition(5, 4), 6)) == 1162
    end

    @testset "mergepaths" begin
        @test length(mergepaths([BoardPosition(3, 5), BoardPosition(4, 7)], [BoardPosition(4, 7), BoardPosition(5, 9)])) == 3
        @test BoardPosition(4, 7) in mergepaths([BoardPosition(3, 5), BoardPosition(4, 7)], pathsbetweentwopoints(BoardPosition(4, 7), BoardPosition(7, 8), 2)[1])
    end

    @testset "onestepforward" begin
        @test [BoardPosition(1, 1), BoardPosition(2, 3)] in onestepforward([BoardPosition(1, 1)])
        @test [BoardPosition(1, 1), BoardPosition(2, 3), BoardPosition(3, 5)] in onestepforward([BoardPosition(1, 1), BoardPosition(2, 3)])
        @test [BoardPosition(1, 1), BoardPosition(2, 3), BoardPosition(4, 4)] in onestepforward([BoardPosition(1, 1), BoardPosition(2, 3)])
        @test !([BoardPosition(1, 1), BoardPosition(2, 3), BoardPosition(1, 1)] in onestepforward([BoardPosition(1, 1), BoardPosition(2, 3)]))
        @test length(onestepforward([BoardPosition(1, 1)])) == 2
    end

    @testset "lastpointisnotoff" begin
        @test lastpointisnotoff([BoardPosition(1, 1), BoardPosition(2, 5)])
        @test lastpointisnotoff([BoardPosition(1, 1), BoardPosition(2, 5), BoardPosition(1, 1)])
        @test !lastpointisnotoff([BoardPosition(1, 1), BoardPosition(3, 2)])
    end

    @testset "check all suqares in areas" begin
        allsquares = []
        for i in 1:10
            for j in 1:10
                push!(allsquares, BoardPosition(i, j))
            end
        end
        @testset for area in regions()
            @test issubset(area, allsquares)
        end
        totalareas = []
        for area in regions()
            union!(totalareas, area)
        end
        @test length(totalareas) == 100
        @test length(unique(totalareas)) == 100
        @test issubset(allsquares, totalareas)
    end
end

allfoundpaths = findtotalsolution(1)



