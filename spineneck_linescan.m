function spineneck_linescan()

the_folder='';

cd(the_folder);

%look for all the subfolder names
files=[];
files=dir;
folders={};
for i=3:numel(files)
    if files(i).isdir
        folders{numel(folders)+1}=files(i).name;
    end
end


for i=1:numel(folders)
    cd(folders{i});
    
    
    %read in all spineline file names
    names_lines_x=dir('spineline_x_*');
    [~,order]=sort({names_lines_x.name}); names_lines_x=names_lines_x(order); clear order %sort to avoid unordered files due to server bugs
    names_lines_y=dir('spineline_y_*');
    [~,order]=sort({names_lines_y.name}); names_lines_y=names_lines_y(order); clear order
    
     %also read in spot files to later do the line scans on the actual image
    [~, mess]=fileattrib('*_spots*.txt');
    [~,order]=sort({mess.Name});mess=mess(order); clear order

    %read in the actual spineline data only for mushroom
    class=dlmread('classification.txt');
    k=1;
    for j=1:numel(names_lines_x)
        if class(j)==1
            temp_line_x=dlmread(names_lines_x(j).name);
            temp_line_y=dlmread(names_lines_y(j).name);
            lines{1,k}=cat(2,temp_line_x,temp_line_y); %first row of the cell contains the coordinates
            img=dlmread(mess(j).Name);
            img=img(1:301,603:903); %only need STED part of the image
            img_linescan(:)=img(round(temp_line_x(:,1)),round(temp_line_y(:,1)))
            neckLengths(k)=numel(temp_line_x);
            k=k+1;
            clear temp_line_*
        else
            continue
        end
    end
    
    max_length=max(neckLengths);
    min_length=min(neckLengths);
    


end