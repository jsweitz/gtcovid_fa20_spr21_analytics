nyt <- read.csv("https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv") #load county-level COVID-19 data from the New York Times.

par(mfrow=c(1,1))#number of subplots

stlong <- nyt[nyt$state == "Georgia",] #choose state

Cty = stlong[which(stlong$county == "Fulton"),] #choose county
CountyPopulation = 1077402 #2020 estimate
DIM=dim(Cty)

CaseDiff = c()
for(aa in 1:(DIM[1]-14)){ #NB: measuring from back to front!
	CaseDiff[aa] = (Cty$cases[DIM[1]-(aa-1)]-Cty$cases[DIM[1]-(aa+13)])
}
CaseDiff=rev(CaseDiff) #reverse case difference object so timing is right

DATES = as.Date(Cty$date[15:DIM[1]])
percapitaInfectious1 = 3*CaseDiff/CountyPopulation
percapitaInfectious2 = 5*CaseDiff/CountyPopulation

#set x-limits
XLIM=c(as.Date("2020-08-01"),as.Date("2021-05-01"))
#set timing labels
TIMES = sort(as.Date(c(paste0("2020-",1:12,"-",rep("01",12)),paste0("2020-",1:12,"-",rep("15",12)))))
TIMES = c(TIMES, sort(as.Date(c(paste0("2021-",1:12,"-",rep("01",12)),paste0("2021-",1:12,"-",rep("15",12))))))
TIMES = sort(TIMES)

#plot data
png('FultonCounty.png', width=8, height=6,units='in',res=300)

plot(DATES,percapitaInfectious2,xaxt = "n",ylab="Circulating per capita infectious",xlab="",xlim=XLIM,pch=19,main="Fulton, GA")
points(DATES,percapitaInfectious1,col="red",pch=19)

axis.Date(1,at=TIMES,format="%e %b %Y",las=2,cex.axis=0.8)
legend("topleft",c("AB = 5","AB = 3"),col=c("black","red"),pch=19,bty="n")

dev.off()