
using CSV, DataFrames,Gadfly
import Cairo, Fontconfig
include("../plotting/density.jl")

filename="ailm_density"

df = CSV.File(filename*".csv") |> DataFrame

plotPropertyLines(df, colorant"blue",40,"e",filename*"_express.png")
plotPropertyLines(df, colorant"orange",40,"c",filename*"_compose.png")
plotPropertyLines(df, colorant"purple",40,"s",filename*"_stable.png")
