
using CSV, DataFrames,Gadfly,Images, ImageMagick
import Cairo, Fontconfig
include("../plotting/plotting.jl")


df = CSV.File("ailm_epoch.csv") |> DataFrame

using DataFrames
using Gadfly

# Filter out rows where :propertyType is not "t"
df_filteredD = filter(row -> row[:propertyType] == "tD", df)
df_filteredE = filter(row -> row[:propertyType] == "tE", df)
df_filteredA = filter(row -> row[:propertyType] == "tA", df)

# Group by :generation, :epoch, and :propertyType, then calculate the mean of :property
dfD_grouped = combine(groupby(df_filteredD, [:generation, :epoch]), :property => mean => :property_mean)
dfE_grouped = combine(groupby(df_filteredE, [:generation, :epoch]), :property => mean => :property_mean)
dfA_grouped = combine(groupby(df_filteredA, [:generation, :epoch]), :property => mean => :property_mean)

dfD_grouped[:, :dataset] .= "decoder"
dfE_grouped[:, :dataset] .= "encoder"
dfA_grouped[:, :dataset] .= "autoencoder"

dfA_grouped.property_mean = dfA_grouped.property_mean./8

combined_df = vcat(dfD_grouped, dfE_grouped, dfA_grouped)

xlabel="epoch"
ylabel="loss"


# Create the faceted plot
p = plot(combined_df,  xgroup=:dataset,x=:epoch, y=:property_mean, color=:generation,
         Geom.subplot_grid(Geom.line),
         Guide.xlabel(xlabel),
         Guide.ylabel(ylabel),
         Guide.colorkey(title="g"),
         Theme(background_color=colorant"white",
               major_label_font="Arial",
               major_label_font_size=10pt,
               minor_label_font="Arial",
               minor_label_font_size=10pt,
               key_position=:right
               )
         )

# Display the plot
draw(PDF("ailm_epoch.eps", 7.5inch, 2.75inch), p)
