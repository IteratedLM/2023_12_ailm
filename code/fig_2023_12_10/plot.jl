
using CSV, DataFrames,Gadfly
import Cairo, Fontconfig
include("../plotting/plotting.jl")


df = CSV.File("oilm.csv") |> DataFrame

function makeMatrix(df::DataFrame,type::String)
    filtered_df = filter(row -> row.propertyType == type, df)

    max_generation = maximum(filtered_df.generation)
    max_trial = maximum(filtered_df.trial)


    matrix = fill(NaN, max_generation, max_trial)  # or use zeros() if you prefer

    
    for row in eachrow(filtered_df)
        matrix[row.generation, row.trial] = row.property
    end

    matrix

end



autMin=30
autMax=180
autStep=5

autV=collect(autMin:autStep:autMax)

expressMatrix=makeMatrix(df,"e")
composeMatrix=makeMatrix(df,"c")
stableMatrix=makeMatrix(df,"s")

generationN=filter(row-> row.propertyType=="m",df)[1,:generation]

generations=collect(0:generationN-1)

plotPropertyLines(expressMatrix,"oilm_express.png",colorant"blue","e")
plotPropertyLines(composeMatrix,"oilm_compose.png",colorant"orange","c")
plotPropertyLines(stableMatrix,"oilm_stable.png" ,colorant"purple","s")
