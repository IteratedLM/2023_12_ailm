#makes a a ILM agent
#does this for n=8
#trains it using different exemplar and reflection sets
#prints out the results


using Statistics,DataFrames,Gadfly,ProgressMeter,Colors
import Cairo, Fontconfig

include("../utilities/two_way_agent.jl")
include("../utilities/utilities.jl")
    
bitN=8

#=
bottleN=95
reflectionN=3*bottleN
=#

#same A-C
#=
bottleN=100
reflectionN=100
same=true
filename="ailm_100.csv"
=#


#same D-E
#=
bottleN=50
reflectionN=50
same=true
filename="ailm_50.csv"
=#


#different A-C
bottleN=100
reflectionN=100
same=false
filename="ailm_100_100.csv"
#


#different D-F
bottleN=50
reflectionN=150
same=false
filename="ailm_50_150.csv"
#



loss(nn, x,y)= Flux.mse(nn(x), y)

learningRate=5.0
optimizer=Flux.Optimise.Descent(learningRate)

numEpochs=round(Int64,200*100/bottleN)

generationN=80
trialsN=25

mu1=0.125
mu2=0.125

firstRun=true

if firstRun
    header1 = "generation,trial,propertyType,property\n"
    header2 = "$generationN,-1,m,-1.0\n"
    open(filename, "w") do file
        write(file, header1)
        write(file, header2)
    end
end

progress= Progress(trialsN*generationN)

bgCompose=0.0::Float64
bgExpress=0.0::Float64
bgStable =0.0::Float64
backgroundN=20

for backgroundC in 1:backgroundN

    global(bgCompose,bgExpress,bgStable)
    child=makeAgent(bitN)
    anotherChild=makeAgent(bitN)
    makeTable(child)
    makeTable(anotherChild)
    bgCompose+=0.5*(compositionality(child)+compositionality(anotherChild))/backgroundN
    bgExpress+=0.5*(expressivity(child)+expressivity(anotherChild))/backgroundN
    bgStable+=stability(child.m2sTable,anotherChild.m2sTable)/backgroundN
    
end



println("background")
println("compose"," ",bgCompose)
println("express"," ",bgExpress)
println("stable "," ",bgStable)

file=open(filename, "a")                   

for trialC in 1:trialsN

    global(bgCompose,bgExpress,bgStable,file,bitN)
    
    child=makeAgent(bitN)
    parentTable=randomTable(bitN)
    
    for generation in 1:generationN
        
        shuffledMeanings = randperm(2^bitN)
        shuffledSignals  = Vector{Int64}[]
        if same
            shuffledSignals=copy(shuffledMeanings)
        else            
            shuffledSignals=randperm(2^bitN)
        end
        
        exemplars = shuffledMeanings[1:bottleN]
        signals = shuffledSignals[1:reflectionN]
        
        makeTable(child)
        oldParent=copy(parentTable)
        parentTable=child.m2sTable
        
        express=rebased(expressivity(child),bgExpress)
        compose=rebased(compositionality(child),bgCompose)
        stable =rebased(stability(parentTable,oldParent),bgStable)

        write(file,"$generation,$trialC,e,$express\n")
        write(file,"$generation,$trialC,c,$compose\n")
        write(file,"$generation,$trialC,s,$stable\n")
        flush(file)
        
        child=makeAgent(bitN)

        for epoch in 1:numEpochs
            
            shuffle!(exemplars)
            
            for meaning in exemplars

                p=rand()
                if p<mu1
                    dataI=[(v2BV(bitN,parentTable[meaning]-1),v2BV(bitN,meaning-1))]
                    Flux.train!(loss, child.s2m, dataI, optimizer)
                elseif p<mu1+mu2
                    dataI=[(v2BV(bitN,meaning-1),v2BV(bitN,parentTable[meaning]-1))]
                    Flux.train!(loss, child.m2s, dataI, optimizer)
                else
                    signal=rand(signals)
                    dataI=[(v2BV(bitN,signal-1),v2BV(bitN,signal-1))]
                    Flux.train!(loss, child.s2s, dataI, optimizer)
                end
                
            end
        end

        
    next!(progress)
        
    end

end 
