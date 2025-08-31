function r=my_measure_dsm_corr(my_ds,args)
    r=struct();
    my_dsm=cosmo_pdist(my_ds.samples, 'correlation');
    my_dsm=1-my_dsm; 
    my_dsm=atanh(my_dsm);
    r.samples= cosmo_corr(my_dsm(:), args.target_dsm(:), 'Pearson');
end