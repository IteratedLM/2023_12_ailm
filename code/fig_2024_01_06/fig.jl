

using Statistics,DataFrames,Gadfly,ProgressMeter,Colors
import Cairo, Fontconfig

include("../utilities/m2m_agent.jl")
include("../utilities/utilities.jl")
    
bitN=10
generationN=30
bottleN=100
reflectionN=300

same=false

#
#numEpochs=50
#filename="ailm_50e.csv"
#


#
numEpochs=20
filename="ailm_epoch.csv"
#


lossMSE(nn, x,y)= Flux.mse(nn(x), y)

learningRate=5.0
optimizer=Flux.Optimise.Descent(learningRate)


mutable struct TotalLoss
    total::Float64
end

function makeLoss(totalLoss::TotalLoss,lossMSE)

    function(nn,x,y)
        loss=lossMSE(nn,x,y)
        totalLoss.total+=loss
        loss
    end

end




trialsN=25

reflectionE=8

firstRun=true

if firstRun
    header1 = "generation,trial,epoch,propertyType,property\n"
    header2 = "$generationN,-1,-1,m,-1.0\n"
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
        shuffledAutos  = Vector{Int64}[]
        if same
            shuffledAutos=copy(shuffledMeanings)
        else            
            shuffledAutos=randperm(2^bitN)
        end
        
        exemplars1 = shuffledMeanings[1:bottleN]
        exemplars2 = copy(exemplars1)
        autos = shuffledAutos[1:reflectionN]
        
        makeTable(child)
        oldParent=copy(parentTable)
        parentTable=child.m2sTable
        
        express=rebased(expressivity(child),bgExpress)
        compose=rebased(compositionality(child),bgCompose)
        stable =rebased(stability(parentTable,oldParent),bgStable)

        write(file,"$generation,$trialC,-1,e,$express\n")
        write(file,"$generation,$trialC,-1,c,$compose\n")
        write(file,"$generation,$trialC,-1,s,$stable\n")
        flush(file)
        
        child=makeAgent(bitN)

        for epoch in 1:numEpochs
            
            shuffle!(exemplars1)
            shuffle!(exemplars2)
            totalLossD=TotalLoss(0.0)
            totalLossE=TotalLoss(0.0)
            totalLossA=TotalLoss(0.0)

            thisLossD=makeLoss(totalLossD,lossMSE)
            thisLossE=makeLoss(totalLossE,lossMSE)
            thisLossA=makeLoss(totalLossA,lossMSE)

            
            for meaningC in 1:bottleN

                meaning1=exemplars1[meaningC]
                meaning2=exemplars2[meaningC]
                
                dataI=[(v2BV(bitN,parentTable[meaning1]-1),v2BV(bitN,meaning1-1))]
                Flux.train!(thisLossD, child.s2m, dataI, optimizer)
                
                dataI=[(v2BV(bitN,meaning2-1),v2BV(bitN,parentTable[meaning2]-1))]
                Flux.train!(thisLossE, child.m2s, dataI, optimizer)
                
                for _ in 1:reflectionE
                    auto=rand(autos)-1
                    dataI=[(v2BV(bitN,auto),v2BV(bitN,auto))]
                    Flux.train!(thisLossA, child.m2m, dataI, optimizer)
                end
            end

            totalD=totalLossD.total
            totalE=totalLossE.total
            totalA=totalLossA.total
            write(file,"$generation,$trialC,$epoch,tD,$totalD\n")
            write(file,"$generation,$trialC,$epoch,tE,$totalE\n")
            write(file,"$generation,$trialC,$epoch,tA,$totalA\n")
            flush(file)
            
        end

        
    next!(progress)
        
    end

end 
