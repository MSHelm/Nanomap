function make_autocorr_files;

% defining the "mother" folder
thefolder='C:\data_2008\may2008\Dirk_FRAP-imaging\directly_imaged';

cellb{1}='FRAP_002-12min';
cellb{2}='FRAP_003-12min';
cellb{3}='FRAP_004-21min';
cellb{4}='FRAP_005-21min';

autocorr=[];
for abcdef=1:numel(cellb)


    cds=cellb{abcdef};
    cd(strcat(thefolder,'\',cds));
try
    a=dlmread('autocorrelation_distances.txt');
    autocorr=cat(1,autocorr,a);
catch
end

end;
cd ..

dlmwrite('autocorr_file.txt',autocorr);
    
