using Test
using Printf

function collisionprobability(robots, races, i)
    val = (races - 1) / races
    val = val^(robots - i)
    val *= (1 / races)^i     
    bin = binomial(BigInt(robots), BigInt(robots - i))
    val * bin # checks the prob of having i other robots chosing to compete in the first race
end

function naivewinningprobability(robots, races)
    tot = 0
    if robots == 1
        return 1
    end
    for i in 1:robots
        prob = (1 / i) * collisionprobability(robots-1, races, i - 1)
        tot += prob
    end
    return tot
end

@test collisionprobability(1, 2, 0) == 0.5
@test collisionprobability(1, 2, 1) == 0.5
@test collisionprobability(2, 2, 2) == 0.25
@test collisionprobability(3, 2, 3) == 0.125

@test collisionprobability(3, 3, 0) + collisionprobability(3, 3, 1) + collisionprobability(3, 3, 2) + collisionprobability(3, 3, 3) ≈ 1 atol=1e-8
@test collisionprobability(4, 4, 0) + collisionprobability(4, 4, 1) + collisionprobability(4, 4, 2) + collisionprobability(4, 4, 3) + collisionprobability(4, 4, 4) ≈ 1 atol=1e-8

@test collisionprobability(2, 2, 1) == 0.5
@test collisionprobability(3, 2, 1) == 1/8 * 3
@test collisionprobability(2, 3, 0) == 2/3 * (2/3)
@test collisionprobability(2, 3, 2) == 1/3 * (1/3)

@test naivewinningprobability(1, 1) == 1

@test naivewinningprobability(2, 1) == 0.5
@test naivewinningprobability(2, 2) == 1/2 + (1/2)*(1/2)
@test naivewinningprobability(2, 3) ≈ 2/3 + (1/3)*(1/2) atol=1e-8
@test naivewinningprobability(3, 3) ≈ 2/3 *(2/3) + (2/3)*(2/3)*(1/2) + 1/9 *(1/3) atol=1e-8


@test naivewinningprobability(3, 1) ≈ 1/3 atol=1e-8

@test isinf(collisionprobability(23, 8, 0)) == false


for n in 1:10
    print(string(n), "; ")
    @printf("%.8f", naivewinningprobability(3*n, n))
    print("; ")
    @printf("%.8f", collisionprobability(3*n - 1, n, 0) * n)
    print("; ")
    println(string(naivewinningprobability(3*n-2, n) < collisionprobability(3*n - 2, n, 0) * n))
end