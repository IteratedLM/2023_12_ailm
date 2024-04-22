#makes a a ILM agent
#does this for n=8
#takes the bottle size from the command line
#prints out the results


using Statistics,DataFrames,Gadfly,Colors
import Cairo, Fontconfig

include("../utilities/m2m_agent.jl")
include("../utilities/utilities.jl")
    
bitN=10

reflectionE=20

same=true

generation0=15
generation1=40

lambdaR=3

bottleN = parse(Int, ARGS[1])

if same
    filename="results/ailm_vb_same_"*ARGS[1]*".csv"
else
    filename="results/ailm_vb_unsame_"*ARGS[1]*".csv"
end
    
loss(nn, x,y)= Flux.mse(nn(x), y)

learningRate=5.0
optimizer=Flux.Optimise.Descent(learningRate)

numEpochs=30

trialsN=25

header = "bottle,trial,propertyType,property\n"
open(filename, "w") do file
    write(file, header)
end

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

for trialC in 1:trialsN

    global(bgCompose,bgExpress,bgStable,filename,bitN)

    autoN=lambdaR*bottleN
        
    child=makeAgent(bitN)
    parentTable=randomTable(bitN)
    
    for generation in 1:generation1
        
        shuffledMeanings = randperm(2^bitN)
        shuffledAutos  = Vector{Int64}[]
        if same
            shuffledAutos=copy(shuffledMeanings)
        else            
            shuffledAutos=randperm(2^bitN)
        end
        
        exemplars1 = shuffledMeanings[1:bottleN]
        exemplars2 = copy(exemplars1)
        
        autos =   shuffledAutos[1:autoN]
        
        makeTable(child)
        oldParent=copy(parentTable)
        parentTable=child.m2sTable
        
        if generation==generation0||generation==generation1
            
            express=rebased(expressivity(child),bgExpress)
            compose=rebased(compositionality(child),bgCompose)
            stable=rebased(stability(parentTable,oldParent),bgStable)    

            gen="1"
            if generation==generation0
                gen="0"
            end
            
            open(filename, "a") do file                   
                write(file, "$bottleN,$trialC,e"*gen*",$express\n")
                write(file, "$bottleN,$trialC,c"*gen*",$compose\n")
                write(file, "$bottleN,$trialC,s"*gen*",$stable\n")
                flush(file)
            end
        end
        
        child=makeAgent(bitN)
        
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
