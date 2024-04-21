
using CSV, DataFrames,Gadfly
import Cairo, Fontconfig
include("../plotting/plotting.jl")

#filename="ailm_50"
#filename="ailm_100"
#filename="ailm_100_100"
filename="ailm0.85"

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

#filteredDf=filter(row -> row[:generation] >1, df)

expressMatrix=makeMatrix(filteredDf,"e")
composeMatrix=makeMatrix(filteredDf,"c")
stableMatrix =makeMatrix(filteredDf,"s")
aMatrix =makeMatrix(filteredDf,"a")
bMatrix =makeMatrix(filteredDf,"b")

generations=collect(0:generationN-1)

plotPropertyLines(expressMatrix,filename*"_express.png",  colorant"blue","x")
plotPropertyLines(composeMatrix,filename*"_compose.png",colorant"orange","c")
plotPropertyLines(stableMatrix ,filename*"_stable.png" ,colorant"purple","s")
plotPropertyLines(aMatrix ,filename*"_a.png" ,colorant"purple","a")
plotPropertyLines(bMatrix ,filename*"_b.png" ,colorant"purple","b")
