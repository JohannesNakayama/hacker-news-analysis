using Distributions

pdist = Poisson(0.68)

samp = rand(pdist, 100)

function daily_trend_bias(slice)
    sin(-6.4 * slice)
end

n = 1440
λ = 0.68
λ = 2
arrivals_at_slice = [rand(Poisson(λ + (λ * daily_trend_bias(i)))) for i in 1:n] 

using DataFrames

simulated_data = DataFrame(
    simulated_arrivals = arrivals_at_slice,
    time_index = 1:length(arrivals_at_slice)
)


using Feather

Feather.write(joinpath("data", "simulated_arrivals3.feather"), simulated_data)