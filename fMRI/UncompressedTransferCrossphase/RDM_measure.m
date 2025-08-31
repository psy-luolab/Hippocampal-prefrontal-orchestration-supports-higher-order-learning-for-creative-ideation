function my_results=my_measure(ds,args)
my_results=struct();
n = size(ds.samples,1);
my_dsm=cosmo_pdist(ds.samples, 'correlation');
RSM=cosmo_squareform(my_dsm);
RSM=1-RSM;
RSM=atanh(RSM);
RSM(RSM==inf)=0;
myRSM=RSM(n/2+1:n,1:n/2);
ALL=mean(myRSM,2);
R=mean(ALL);
my_results.samples=R;
end