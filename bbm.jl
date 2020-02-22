using Parameters, Statistics, Random, LinearAlgebra, Distributions,
	DifferentialEquations, StatsBase, StatsPlots, Plots, DataFrames, CSV, Optim

include("/home/bob/Research/Branching Brownian Motion/bbm_functions_structs.jl")

#
# a branching Brownian motion
#

# number of generations to halt at
T = 200

# parameter values
r = 2.0
a = 0.01
θ = 0.0
c = 0.00001
μ = 1.0
V = 20.0

# equilibrium abundance
# we use this as the initial abundance
N̂ = Int64(floor((r-.5*√(μ*a))/c))

# initial trait values
x₀ = rand(Normal(0.0,1.0),N̂)

##
## VERY IMPORTANT REQUIREMENT   -->  V >= exp(r)
##
## this inequality must be satisfied to use negative binomial sampling
##
##
## TWO MORE IMPORTANT REQUIREMENTS --> 2*r > √(μ*a) && c > r - √(μ*a)/2
##
## these inequalities must be satisfied for positive equilibrium abundance
##

# set up initial population
X = population(x=x₀, x̄=mean(x₀), σ²=var(x₀), N=N̂,
	r=r, a=a, θ=θ, c=c, μ=μ, V=V)

# always a good idea to inspect a single iteration
update(X)

# set up history of population
Xₕ = fill(X,T)

# set up containers for paths of N, x\bar and σ²
Nₕ = fill(X.N,T)
x̄ₕ = fill(X.x̄,T)
σ²ₕ = fill(X.σ²,T)

# simulate
for i in 2:T

	if Xₕ[i-1].N > 0

		Xₕ[i] = update(Xₕ[i-1])

	else

		Xₕ[i] = Xₕ[i-1]

	end

	Nₕ[i] = Xₕ[i].N
	x̄ₕ[i] = Xₕ[i].x̄
	σ²ₕ[i] = Xₕ[i].σ²

end


plot(1:T,Nₕ)
plot(1:T,x̄ₕ,title="Mean Trait: N ~ 195000",ylabel="Value",xlabel="Iteration",ylim=(-1,1))
png("mean2.png")
plot(1:T,σ²ₕ,title="Trait Variance: N ~ 195000",ylabel="Value",xlabel="Iteration",ylim=(0,15))
png("var2.png")


# rescale time
Tₛ = fill(1/N₀,T)
for i in 2:T
	Tₛ[i] = Tₛ[i-1]+1/n
end

# plotting the rescaled process

plot(Tₛ,Nₕ)
plot(Tₛ,x̄ₕ)
plot(Tₛ,σ²ₕ)
