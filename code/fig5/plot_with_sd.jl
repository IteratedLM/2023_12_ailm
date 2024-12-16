
using CSV, DataFrames,Gadfly,Statistics,GLM
import Cairo, Fontconfig
include("../plotting/plot_best.jl")


df = CSV.File("best_oilm.csv") |> DataFrame


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

minPGen = DataFrame()
for row in eachrow(minGen)
    # Find the row in avgGen where :n is the same and :bottle is one higher
    filtered_rows = filter(r -> r.n == row.n && r.bottle == row.bottle + 1, avgGen)
    if nrow(filtered_rows) > 0
        push!(minPGen, filtered_rows[1, :])  # Add the first match to minPGen
    end
end

# Step 2: Create minMGen by matching rows where :bottle in avgGen is one lower than in minGen
minMGen = DataFrame()
for row in eachrow(minGen)
    # Find the row in avgGen where :n is the same and :bottle is one lower
    filtered_rows = filter(r -> r.n == row.n && r.bottle == row.bottle - 1, avgGen)
    if nrow(filtered_rows) > 0
        push!(minMGen, filtered_rows[1, :])  # Add the first match to minMGen
    end
end


# Rename columns appropriately
#rename!(minGen, :bottle => :bottle, :generation => :generation)

# Your final DataFrame will have columns: 'n', 'bottle', and 'min_generation
println(minGen)
println(minPGen)
println(minMGen)





plot_bestPLoS(minGen,minMGen,minPGen,"oilm_best")

# Assuming your DataFrame is named df and has columns 'bottle' and 'generation'

# Perform the linear regression
lm_model = lm(@formula(bottle ~ n), minGen)

# Extract the parameters
intercept, slope = coef(lm_model)

println("Slope (m): $slope")
println("Intercept (c): $intercept")
