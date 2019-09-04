function determineSpineTypeComposition()

addpath(genpath('Z:\user\mhelm1\Subcellular Distribution Analysis\Matlab Programs')); 
the_folder='Z:\user\mhelm1\Nanomap_Analysis\Data';
cd(the_folder);
class_total=[];


dirs = regexp(genpath(the_folder),'[^;]*','match');

w=waitbar(0,'Please wait');

for i=2:numel(dirs) %1 is the parent folder
    waitbar(i/numel(dirs));
    try
        cd(dirs{i});
        class_temp=dlmread('classification.txt');
        class_total=cat(2,class_total,class_temp);
        class_temp=[];
        cd ..
    catch
        disp(['No classification file found in ' dirs{i}])
        cd ..
        continue
    end
end

close(w)

num_total=length(class_total);
num_mush=sum(class_total(:)==1);
num_stubby=sum(class_total(:)==2);
num_other=sum(class_total(:)==3);
num_skip=sum(class_total(:)==4);
num_errors=sum(class_total(:)==0);
num_synapses=num_mush+num_stubby+num_other;

perc_mush=num_mush/num_synapses;
perc_stubby=num_stubby/num_synapses;
perc_other=num_other/num_synapses;
perc_skip=num_skip/num_total;

results={};
results{1,1}='Spine class'; results{1,2}='Total number'; results{1,3}='Percentage of class by real spine';

results{2,1}='Number of Mushroom spines'; results{2,2}=num_mush; results{2,3}=perc_mush;
results{3,1}='Number of Stubby spines'; results{3,2}=num_stubby; results{3,3}=perc_stubby;
results{4,1}='Number of other spines'; results{4,2}=num_other; results{4,3}=perc_other;
results{5,1}='Sum of real spines'; results{5,2}=num_synapses;
results{6,1}='Number of skipped spines'; results{6,2}=num_skip; results{6,3}=perc_skip;
results{7,1}='Number of error spots'; results{7,2}=num_errors;
results{8,1}='Number of total spots'; results{8,2}=num_total;

cd(the_folder);
xlswrite('Z:\user\mhelm1\Nanomap_Analysis\Data\total\SpineTypeComposition.xlsx',results);

end

