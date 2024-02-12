#makes a a ILM agent
#does this for n=8
#sweeps over some metaparameter such as bottleneck size
#prints out the results


using Statistics,DataFrames,Gadfly,ProgressMeter,Colors
import Cairo, Fontconfig

include("../utilities/two_way_agent.jl")
include("../utilities/utilities.jl")
    
bitN=8

reflectionE=8

same=true

generation0=15
generation1=40

bottle0=10
bottle1=150
bottleStep=10

lambdaR=1

bottleSize=length(collect(bottle0:bottleStep:bottle1))
if same
    filename="ailm_vb_same.csv"
else
    filename="ailm_vb_unsame.csv"
end
    
loss(nn, x,y)= Flux.mse(nn(x), y)

learningRate=5.0
optimizer=Flux.Optimise.Descent(learningRate)

numEpochs=20

trialsN=25

firstRun=true

if firstRun
    header = "bottle,trial,propertyType,property\n"
    open(filename, "w") do file
        write(file, header)
    end
end

progress= Progress(trialsN)

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

    for (bottleIndex,bottleC) in enumerate(collect(bottle0:bottleStep:bottle1))

        reflectionC=lambdaR*bottleC
        
        child=makeAgent(bitN)
        parentTable=randomTable(bitN)
    
        for generation in 1:generation1
        
            shuffledMeanings = randperm(2^bitN)
            shuffledSignals  = Vector{Int64}[]
            if same
                shuffledSignals=copy(shuffledMeanings)
            else            
                shuffledSignals=randperm(2^bitN)
            end
            
            exemplars1 = shuffledMeanings[1:bottleC]
            exemplars2 = copy(exemplars1)
            
            signals =   shuffledSignals[1:reflectionC]
            
            makeTable(child)
            oldParent=copy(parentTable)
            parentTable=child.m2sTable

            if generation==generation0||generation==generation1

                express=rebased(expressivity(child),bgExpress)
                compose=rebased(compositionality(child),bgCompose)
                stable=rebased(stability(parent,oldParent),bgStable)    

                gen="1"
                if generation==generation0
                    gen="0"
                end
                
                open(filename, "a") do file                   
                    write(file, "$bottleIndex,$trialC,e"*gen*",$express\n")
                    write(file, "$bottleIndex,$trialC,c"*gen*",$compose\n")
                    write(file, "$bottleIndex,$trialC,s"*gen*",$stable\n")
                    flush(file)
                end
            end
            
            child=makeAgent(bitN)
            
            for epoch in 1:numEpochs
                
                shuffle!(exemplars1)
                shuffle!(exemplars2)
                
                for meaningC in 1:bottleC
                    
                    meaning1=exemplars1[meaningC]
                    meaning2=exemplars2[meaningC]
                    
                    dataI=[(v2BV(bitN,parentTable[meaning1]-1),v2BV(bitN,meaning1-1))]
                    Flux.train!(loss, child.s2m, dataI, optimizer)
                    
                    dataI=[(v2BV(bitN,meaning2-1),v2BV(bitN,parentTable[meaning2]-1))]
                    Flux.train!(loss, child.m2s, dataI, optimizer)
                    
                    for _ in 1:reflectionE
                        signal=rand(signals)
                        dataI=[(v2BV(bitN,signal-1),v2BV(bitN,signal-1))]
                        Flux.train!(loss, child.s2s, dataI, optimizer)
                    end
                end
                
            end
            
        end
        
    end 

    next!(progress)
    
end
