
using CSV, DataFrames
include("../plotting/plotting.jl")

filename="ailm"

df = CSV.File(filename*".csv") |> DataFrame

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

generationN=120
filteredDf=filter(row -> row[:generation] <=generationN, df)


expressMatrix=makeMatrix(filteredDf,"e")
composeMatrix=makeMatrix(filteredDf,"c")
stableMatrix =makeMatrix(filteredDf,"s")

generations=collect(0:generationN-1)

plotPropertyLines(expressMatrix,filename*"_express.png",  colorant"blue","e")
plotPropertyLines(composeMatrix,filename*"_compose.png",colorant"orange","c")
plotPropertyLines(stableMatrix ,filename*"_stable.png" ,colorant"purple","s")
