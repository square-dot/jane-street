using Distributions

results = Dict("Aron"=> 0, "Barron"=> 0, "Caren"=> 0, "Darrin"=> 0)

for k in 1:10 
    players = ["Aron", "Barron", "Caren", "Darrin"]

    i = 0
    best = 1
    while length(players) > 1
        r = rand()
        if r < best
            best = r
            i += 1
        else
            players = setdiff(players, players[i + 1])
        end
        i %= length(players)
    results[players[1]] += 1
    end
end

println(results)