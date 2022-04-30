using Test

function createallquotients()
    allpossibilities = []
    for i in 1:2
        for j in 0:9
            for k in 1:4
                push!(allpossibilities, i * 400 + j * 10 + k * 2)
            end
        end
    end
    return allpossibilities
end

function createalldivisors()
    allpossibilities = []
    for i in 1:3
        for j in 0:9
            for k in 1:4
                for l in 1:4
                    push!(allpossibilities, i * 3000 + j * 100 + k * 20 + l * 2)
                end
            end
        end
    end
    return allpossibilities
end

function givecipher(number, position)
    return trunc(Int, number / 10^(position - 1)) - trunc(Int, number / 10^position) * 10
end

function containsfactor(number, factor)
    return number != 0 && number % factor == 0
end

function checkconditions(divisor::Int, quotient::Int)
    firstmultiplication = givecipher(quotient, 1) * divisor
    if !containsfactor(givecipher(firstmultiplication, 1), 2) return 0 end
    if !containsfactor(givecipher(firstmultiplication, 2), 7) return 0 end
    if !containsfactor(givecipher(firstmultiplication, 3), 2) return 0 end
    if !containsfactor(givecipher(firstmultiplication, 4), 3) return 0 end

    secondmultiplication = givecipher(quotient, 2) * divisor
    if !containsfactor(givecipher(secondmultiplication, 1), 8) return 0 end
    if !containsfactor(givecipher(secondmultiplication, 2), 3) return 0 end
    if !containsfactor(givecipher(secondmultiplication, 4), 9) return 0 end

    thirdmultiplication = givecipher(quotient, 3) * divisor
    if !containsfactor(givecipher(thirdmultiplication, 1), 2) return 0 end

    for remainder in [37, 67, 97]
        res = divisor * quotient + remainder
        if !containsfactor(givecipher(res, 1), 3) continue end
        if !containsfactor(givecipher(res, 2), 2) continue end
        if !containsfactor(givecipher(res, 6), 7) continue end
        intermediate1 = (trunc(Int, res / 100) - thirdmultiplication) * 10 + givecipher(res, 2)
        intermediate2 = (intermediate1 - secondmultiplication) * 10 + givecipher(res, 1)
        cond1 = containsfactor(givecipher(intermediate2, 1), 3)
        cond2 = containsfactor(givecipher(intermediate2, 2), 2)
        cond3 = containsfactor(givecipher(intermediate2, 4), 3)
        if cond1 && cond2 && cond3
            if divisor != 9168 
                println("\r\nreal solution")
            else
                println("\r\nfake solution")
            end
            println(string(thirdmultiplication, " ", intermediate2, " ", secondmultiplication, " ", intermediate1, " ", firstmultiplication))
            return remainder
        end
    end
    return 0
end


function findsolutions()
    println("-----------------------------------")
    println("starting the process")
    allquotients = createallquotients()
    println(string("created ", length(allquotients), " quotiens"))
    alldivisors = createalldivisors()
    println(string("created ", length(alldivisors), " divisors"))
    counter = 0
    for quotient in allquotients
        for divisor in alldivisors
            remainder = checkconditions(divisor, quotient)
            if remainder != 0
                counter += 1
                println(string(divisor, " ", quotient, " -> " , divisor * quotient, " r ", remainder, " -> " , divisor * quotient + remainder))
            end
        end
    end
    println(string("\r\nwe found ", counter, " solutions"))
    println("-----------------------------------")
end



@test givecipher(384, 1) == 4
@test givecipher(234, 2) == 3
@test givecipher(234903, 3) == 9
@test givecipher(234903, 5) == 3
@test givecipher(23490, 6) == 0

findsolutions()





