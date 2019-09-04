function CombineAndAlignCoordinatFiles_Homeostatic(cd_path)

% cd_path='Z:\user\mhelm1\Nanomap_Analysis\Data';
cd(cd_path);
% 
% dirs = regexp(genpath(cd_path),['[^;]*'],'match');

files=[];
files=dir;
folders={};
for i=3:numel(files)
    if files(i).isdir && isempty(regexp(files(i).name,'^[_]','once'))
        folders{numel(folders)+1}=files(i).name;
    end
end

w=waitbar(0,'Please Wait...');

for k=1:numel(folders)
%     try
        waitbar(k/numel(folders))
        cd([cd_path filesep folders{k}])
%         if exist('coordinates.mat')==2
%             continue
%         end
        
        classification=dlmread('classification.txt')';
%         Because of a stupid bug in the beginning of the clicking the
%         files for the coordinates can be longer than how many actual
%         spots are there. This is probably because the variables were not
%         properly cleared between clicking different proteins -.- Since
%         classification is always correct I use this to rectify it.

        bottomx=double(dlmread('bottomx.txt'))'; bottomx=bottomx(1:numel(classification));
        bottomy=double(dlmread('bottomy.txt'))';bottomy=bottomy(1:numel(classification));
        topx=double(dlmread('topx.txt'))'; topx=topx(1:numel(classification));
        topy=double(dlmread('topy.txt'))'; topy=topy(1:numel(classification));
        leftx=double(dlmread('leftx.txt'))'; leftx=leftx(1:numel(classification));
        lefty=double(dlmread('lefty.txt'))'; lefty=lefty(1:numel(classification));
        rightx=double(dlmread('rightx.txt'))'; rightx=rightx(1:numel(classification));
        righty=double(dlmread('righty.txt'))'; righty=righty(1:numel(classification));
        bottomneckx=dlmread('bottomneckx.txt')'; bottomneckx=bottomneckx(1:numel(classification));
        bottomnecky=dlmread('bottomnecky.txt')'; bottomnecky=bottomnecky(1:numel(classification));
        shafttopleftx=dlmread('shafttopleftx.txt')'; shafttopleftx=shafttopleftx(1:numel(classification));
        shafttoplefty=dlmread('shafttoplefty.txt')'; shafttoplefty=shafttoplefty(1:numel(classification));
        shafttoprightx=dlmread('shafttoprightx.txt')'; shafttoprightx=shafttoprightx(1:numel(classification));
        shafttoprighty=dlmread('shafttoprighty.txt')'; shafttoprighty=shafttoprighty(1:numel(classification));
        shaftbottomrightx=dlmread('shaftbottomrightx.txt')'; shaftbottomrightx=shaftbottomrightx(1:numel(classification));
        shaftbottomrighty=dlmread('shaftbottomrighty.txt')'; shaftbottomrighty=shaftbottomrighty(1:numel(classification));
        shaftbottomleftx=dlmread('shaftbottomleftx.txt')'; shaftbottomleftx=shaftbottomleftx(1:numel(classification));
        shaftbottomlefty=dlmread('shaftbottomlefty.txt')'; shaftbottomlefty=shaftbottomlefty(1:numel(classification));
        rot_angles=dlmread('rotation_angles_150px_myfilt.txt')';
        h_shift=dlmread('horizontal_shifts_150px_myfilt.txt')';
        v_shift=dlmread('vertical_shifts_150px_myfilt.txt')';
        
        coordinates=padcat(classification,bottomx,bottomy,topx,topy,rightx,righty,leftx,lefty,bottomneckx,bottomnecky,shafttopleftx,shafttoplefty,shafttoprightx,shafttoprighty,shaftbottomrightx,shaftbottomrighty,shaftbottomleftx,shaftbottomlefty,rot_angles,h_shift,v_shift);
        coordinates=array2table(coordinates,'VariableNames',{'classification','bottomx','bottomy','topx','topy','rightx','righty','leftx','lefty','bottomneckx','bottomnecky','shafttopleftx','shafttoplefty','shafttoprightx','shafttoprighty','shaftbottomrightx','shaftbottomrighty','shaftbottomleftx','shaftbottomlefty','rot_angles','h_shift','v_shift'});
        coordinates=fillmissing(coordinates,'constant',0);
%         coordinates=table(classification,bottomx,bottomy,topx,topy,rightx,righty,leftx,lefty,bottomneckx,bottomnecky,shafttopleftx,shafttoplefty,shafttoprightx,shafttoprighty,shaftbottomrightx,shaftbottomrighty,shaftbottomleftx,shaftbottomlefty,rot_angles,h_shift,v_shift);
        %     coordinates.classification=classification;
        %     coordinates.bottomx=bottomx;
        %     coordinates.bottomy=bottomy;
        %     coordinates.topx=topx;
        %     coordinates.topy=topy;
        %     coordinates.rightx=rightx;
        %     coordinates.righty=righty;
        %     coordinates.leftx=leftx;
        %     coordinates.lefty=lefty;
        %     coordinates.bottomneckx=bottomneckx;
        %     coordinates.bottomnecky=bottomnecky;
        %     coordinates.shafttopleftx=shafttopleftx;
        %     coordinates.shafttoplefty=shafttoplefty;
        %     coordinates.shafttoprightx=shafttoprightx;
        %     coordinates.shafttoprighty=shafttoprighty;
        %     coordinates.shaftbottomrightx=shaftbottomrightx;
        %     coordinates.shaftbottomrighty=shaftbottomrighty;
        %     coordinates.shaftbottomleftx=shaftbottomleftx;
        %     coordinates.shaftbottomlefty=shaftbottomlefty;
        %     coordinates.rot_angles=rot_angles;
        %     coordinates.h_shift=h_shift;
        %     coordinates.v_shift=v_shift;
        
        save coordinates.mat coordinates
        
        coordinates_aligned=coordinates;
        
        %apply shifts and rotation to coordinates, 1 is classification and the last
        %3 are the shifts!
        
        for j=1:size(coordinates,1)
            %create 2d affine rotation, since the loop is going over the
            %coordinates of 1 image, I only need to create it once.
            temp=zeros(301);
            Rdefault = imref2d(size(temp));
            tX = mean(Rdefault.XWorldLimits);
            tY = mean(Rdefault.YWorldLimits);
            theta = coordinates.rot_angles(j);
            
            tTranslationToCenterAtOrigin = [1 0 0; 0 1 0; -tX -tY 1];
            tRotation = [cosd(theta) -sind(theta) 0; sind(theta) cosd(theta) 0; 0 0 1];
            tTranslationBackToOriginalCenter = [1 0 0; 0 1 0; tX tY 1];
            tformCenteredRotation = tTranslationToCenterAtOrigin*tRotation*tTranslationBackToOriginalCenter;
            tform= affine2d(tformCenteredRotation);
            
            for i=2:2:size(coordinates,2)-3
                clear temp2
                temp=zeros(301);
                %read in coordinates in reverse order, since the x/y
                %coordinates of image and the row/column indexes of matrix are
                %interswitched
                temp(round(coordinates{j,i+1}),round(coordinates{j,i}))=100;
                temp=circshift(temp,[coordinates.v_shift(j) coordinates.h_shift(j)]);
                temp=imwarp(temp,tform);
                
                
                %pad array to a total size of 501x501. I need this for the
                %alignment later, to pad all images there also to 501x501
                temp2=padarray(temp,[floor((501-size(temp,1))/2), floor((501-size(temp,2))/2)],'pre');
                temp2=padarray(temp2,[ceil((501-size(temp,1))/2), ceil((501-size(temp,2))/2)],'post');
                
                [temp_a,temp_b]=ind2sub(size(temp2),find(temp2==max(max(temp2)),1));
                
                coordinates_aligned{j,i}=temp_b;
                coordinates_aligned{j,i+1}=temp_a;
            end
        end
        
        
        save coordinates_aligned.mat coordinates_aligned
%     catch
%         disp(['Error in ' folders{k} ' Skipping it.']);
%         continue
%     end
    
end

close(w)
end