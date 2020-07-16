cleanf0 = function(x) {
n=length(x)

#exclude f0 samples below a threshold (i.e. 70 Hz) (choose your threshold for each person) 
for (i in 1:n) {
	if(is.na(x[i]) == FALSE && (x[i] < 50 || x[i] > 300)) {x[i] = NA}
	}

#exclude leading and trailing NA 
while(is.na(x[1])==TRUE) {
			x=x[-1]
			}
while(is.na(x[n])==TRUE) {
			 x=x[-n]
			 n=length(x)
			 }
return(x)
}

# the input files are *.f0.p, which are generated by

# for i in *.f0
# do
# awk -f ../f0.awk $i > $i.p
# done

# then collect the filenames into ilist and nlist

# ls i/*f0.p > ilist
# ls ni/*f0.p > nlist


ilist=scan("ilist", "")
N=length(ilist)

idata=array(1:(N*75), dim=c(N,75))
for (i in 1:N) {
  idata[i,] = approx(cleanf0(scan(ilist[i])),n=75)$y
}

nlist=scan("nlist", "")
N=length(nlist)
ndata=array(1:(N*75), dim=c(N,75))
for (i in 1:N) {
  ndata[i,] = approx(cleanf0(scan(nlist[i])),n=75)$y
}

inlab=rep(c("i", "n"), each=(N*75))
intime=rep(c(1:75), (N*2))
indata=c(t(idata)[1:75,],t(ndata)[1:75,])

mydata=list(inlab, intime, indata)
mydata=as.data.frame(mydata)
colnames(mydata) = list("lab", "time", "f0")

#add "speaker" column. Maybe try separating out samples based on %H and %L boundary tones
#four populations per person: irony rising, irony falling, non-irony rising, non-irony falling

# http://www.sfs.uni-tuebingen.de/~jvanrij/Tutorial/GAMM.html
library(mgcv)
library(devtools)
library(itsadug)
postscript(file="gammB.ps", horizontal=F, width=7, height=5)
par(mfrow=c(1,2))
m1y=bam(f0 ~ lab + te(time, by=lab) , data=mydata)
summary(m1b)
plot(m1y,select=1)
plot(m1y,select=2)
plot_diff(m1y, view = 'time', comp=list(lab = c("i", "n")))




