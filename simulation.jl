using DataFrames
using Feather
using Distributions

# params
LAMBDA = 0.6882627
ALPHA = 1.3441739239406807
SIGMA = 0.4203008

function bias_lambda(slice, alpha=ALPHA, sd=SIGMA)
    sd * (- alpha * sin(2 * pi  * slice))
end

function draw_arrival_rate(slice, n, arrival_rate_mean=LAMBDA; alpha=ALPHA, arrival_rate_sd=SIGMA)
    rel_slice = slice / n
    lambda = arrival_rate_mean + bias_lambda(rel_slice, alpha, arrival_rate_sd)
    dist = Poisson(lambda)
    return rand(dist)
end


# one repetition simulation
n = 1440
average_day = [(i, draw_arrival_rate(i, n)) for i in 0:n-1]
average_day_df = DataFrame(average_day)
rename!(average_day_df, [1 => :time_index, 2 => :arr_count])
average_day_df[:, :hour_of_day] = [i for i in 0:23 for j in 1:60]
Feather.write(joinpath("data", "simulated_arrivals.feather"), average_day_df)

# bootstrap simulation (100 repititions)
n = 1440
average_day = [(i, mean([draw_arrival_rate(i, n) for j in 1:100])) for i in 0:n-1 ]
average_day_df = DataFrame(average_day)
rename!(average_day_df, [1 => :time_index, 2 => :arr_count])
average_day_df[:, :hour_of_day] = [i for i in 0:23 for j in 1:60]
Feather.write(joinpath("data", "simulated_arrivals.feather"), average_day_df)