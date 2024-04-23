
using CSV, DataFrames,Gadfly,Statistics,GLM
import Cairo, Fontconfig
include("../plotting/plot_best.jl")


df = CSV.File("best_ailm.csv") |> DataFrame


dfFiltered=filter(row -> row[:generation] != 15*row[:n]+1, df)

# Assuming your DataFrame is named `df` and has columns: "n", "trial", "bottle", "generation"

# Step 1: Calculate the average of 'generation' for each 'n', 'bottle' pair across all trials
avgGen = combine(groupby(df, [:n, :bottle]), :generation => mean => :generation)
avgGenFiltered = combine(groupby(dfFiltered, [:n, :bottle]), :generation => mean => :generation)

# Step 2: Find the minimum 'generation' value for each 'n' and retain the corresponding 'bottle' value
minGen = combine(groupby(avgGen, :n)) do sdf
    idxmin = argmin(sdf.generation)
    return sdf[idxmin, [:bottle, :generation]]
end

minGenFiltered = combine(groupby(avgGenFiltered, :n)) do sdf
    idxmin = argmin(sdf.generation)
    return sdf[idxmin, [:bottle, :generation]]
end


# Rename columns appropriately
#rename!(minGen, :bottle => :bottle, :generation => :generation)

# Your final DataFrame will have columns: 'n', 'bottle', and 'min_generation
println(minGen)

#plot_best(minGen,"ailm_best",5.9,6.81,10.0)
plot_best(minGen,"ailm_best",-5.4,9.3,20.0)
plot_best(minGen,"ailm_best")

plot_best(minGen,minGenFiltered,"ailm_best")

# Assuming your DataFrame is named df and has columns 'bottle' and 'generation'

# Perform the linear regression
lm_model = lm(@formula(bottle ~ n), minGen)

# Extract the parameters
intercept, slope = coef(lm_model)

println("Slope (m): $slope")
println("Intercept (c): $intercept")
