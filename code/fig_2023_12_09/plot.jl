
using CSV, DataFrames
import("../plotting/plotting.jl")


df = CSV.File("ailm_va.csv") |> DataFrame

function makeMatrix(df::DataFrame,type::String)
    filtered_df = filter(row -> row.propertyType == type, df)

    max_aut = maximum(filtered_df.aut)
    max_trial = maximum(filtered_df.trial)


    matrix = fill(NaN, max_aut, max_trial)  # or use zeros() if you prefer

    
    for row in eachrow(filtered_df)
        matrix[row.aut, row.trial] = row.property
    end

    matrix

end

expressMatrix0=makeMatrix(df,"e0")
expressMatrix1=makeMatrix(df,"e1")
composeMatrix0=makeMatrix(df,"c0")
composeMatrix1=makeMatrix(df,"c1")
stableMatrix0=makeMatrix(df,"s0")
stableMatrix1=makeMatrix(df,"s1")

plotProperty(expressMatrix1,expressMatrix0,autV,"ailm_express_vb.png",colorant"blue","e")
plotProperty(composeMatrix1,composeMatrix0,autV,"ailm_compose_vb.png",colorant"orange","c")
plotProperty(stableMatrix1,  stableMatrix0,autV,"ailm_stable_vb.png",colorant"purple","s")
