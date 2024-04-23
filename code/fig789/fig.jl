#makes a a ILM agent
#does this for n=8
#trains it using different exemplar and reflection sets
#prints out the results


using Statistics,DataFrames


include("../utilities/m2m_agent.jl")
include("../utilities/utilities.jl")
    
bitN=8
hiddenExtra=0
generationN=50
bottleN=75

autoN=bottleN

same=false

numEpochs=30
filename="results/ailm_"*ARGS[1]*".csv"

loss(nn, x,y)= Flux.mse(nn(x), y)

learningRate=5.0
optimizer=Flux.Optimise.Descent(learningRate)

trialC=parse(Int,ARGS[1])

reflectionE=20

firstRun=true

if firstRun
    header1 = "generation,trial,propertyType,property\n"
    header2 = "$generationN,-1,m,-1.0\n"
    open(filename, "w") do file
        write(file, header1)
        write(file, header2)
    end
end


bgCompose=0.0::Float64
bgExpress=0.0::Float64
bgStable =0.0::Float64
backgroundN=20

for backgroundC in 1:backgroundN

    global(bgCompose,bgExpress,bgStable)
    child=makeAgent(bitN,bitN+hiddenExtra)
    anotherChild=makeAgent(bitN,bitN+hiddenExtra)
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

flush(stdout)

file=open(filename, "a")                   

function writeOut(file,generation,trial,propertyType,property)
    write(file,"$generation,$trial,"*propertyType*",$property\n")
    println("$generation,$trial,"*propertyType*",$property")
end

let
    
    global(bgCompose,bgExpress,bgStable,file,bitN,trialC)
    
    child=makeAgent(bitN,bitN+hiddenExtra)
    parentTable=randomTable(bitN)
    
    for generation in 1:generationN
        
        shuffledMeanings = randperm(2^bitN)
        shuffledAutos  = Vector{Int64}[]
        if same
            shuffledAutos=copy(shuffledMeanings)
        else            
            shuffledAutos=randperm(2^bitN)
        end
        
        exemplars1 = shuffledMeanings[1:bottleN]
        exemplars2 = copy(exemplars1)
        autos = shuffledAutos[1:autoN]
        
        makeTable(child)
        oldParent=copy(parentTable)
        parentTable=child.m2sTable
        
        express=rebased(expressivity(child),bgExpress)
        compose=rebased(compositionality(child),bgCompose)
        stable =rebased(stability(parentTable,oldParent),bgStable)

        writeOut(file,generation,trialC,"e",express)
        writeOut(file,generation,trialC,"c",compose)
        writeOut(file,generation,trialC,"s",stable)
        flush(file)
        flush(stdout)
        
        child=makeAgent(bitN,bitN+hiddenExtra)

        for epoch in 1:numEpochs
            
            shuffle!(exemplars1)
            shuffle!(exemplars2)
            
            for meaningC in 1:bottleN

                meaning1=exemplars1[meaningC]
                meaning2=exemplars2[meaningC]
                
                dataI=[(v2BV(bitN,parentTable[meaning1]-1),v2BV(bitN,meaning1-1))]
                Flux.train!(loss, child.s2m, dataI, optimizer)
                
                dataI=[(v2BV(bitN,meaning2-1),v2BV(bitN,parentTable[meaning2]-1))]
                Flux.train!(loss, child.m2s, dataI, optimizer)

                for _ in 1:reflectionE
                            meaning=rand(autos)-1
                            dataI=[(v2BV(bitN,meaning),v2BV(bitN,meaning))]
                            Flux.train!(loss, child.m2m, dataI, optimizer)
                end
            end
        end

        
    end

end 
