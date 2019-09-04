function sort_axis_synapses_skip
global counter dio homer sted top bottomx bottomy topx topy leftx lefty rightx righty classification clickno curX curY...
    bottomneckx bottomnecky shafttopleftx shafttoplefty shafttoprightx shafttoprighty shaftbottomrightx shaftbottomrighty shaftbottomleftx shaftbottomlefty...
    spineline_x spineline_y cd_path zoom_correction
cd(cd_path);

[stat, mess]=fileattrib('*_spots*.txt');
[blub,order]=sort({mess.Name});mess=mess(order);order=[]; %sort to avoid unordered spot files due to server bugs

bottomx(counter)=(1)+zoom_correction
bottomy(counter)=(1)+zoom_correction
topx(counter)=(2)+zoom_correction
topy(counter)=(2)+zoom_correction
rightx(counter)=(3)+zoom_correction
righty(counter)=(3)+zoom_correction
leftx(counter)=(4)+zoom_correction
lefty(counter)=(4)+zoom_correction
bottomneckx(counter)=(5)+zoom_correction
bottomnecky(counter)=(5)+zoom_correction
shafttopleftx(counter)=(6)+zoom_correction
shafttoplefty(counter)=(6)+zoom_correction
shafttoprightx(counter)=(7)+zoom_correction
shafttoprighty(counter)=(7)+zoom_correction
shaftbottomrightx(counter)=(8)+zoom_correction
shaftbottomrighty(counter)=(8)+zoom_correction
shaftbottomleftx(counter)=(9)+zoom_correction
shaftbottomlefty(counter)=(9)+zoom_correction
dlmwrite(strcat('spineline_x_',num2str(counter),'.txt'),(zoom_correction));
dlmwrite(strcat('spineline_y_',num2str(counter),'.txt'),(zoom_correction));

clickno=1;

counter=counter+1;

if rem(counter,50)==0
    disp('saving')
    dlmwrite('bottomx.txt',bottomx);
    dlmwrite('bottomy.txt',bottomy);
    dlmwrite('topx.txt',topx);
    dlmwrite('topy.txt',topy);
    dlmwrite('rightx.txt',rightx);
    dlmwrite('righty.txt',righty);
    dlmwrite('leftx.txt',leftx);
    dlmwrite('lefty.txt',lefty);
    dlmwrite('classification.txt',classification);
    dlmwrite('bottomneckx.txt',bottomneckx);
    dlmwrite('bottomnecky.txt',bottomnecky);
    dlmwrite('shafttopleftx.txt',shafttopleftx);
    dlmwrite('shafttoplefty.txt',shafttoplefty);
    dlmwrite('shafttoprightx.txt',shafttoprightx);
    dlmwrite('shafttoprighty.txt',shafttoprighty);
    dlmwrite('shaftbottomrightx.txt',shaftbottomrightx);
    dlmwrite('shaftbottomrighty.txt',shaftbottomrighty);
    dlmwrite('shaftbottomleftx.txt',shaftbottomleftx);
    dlmwrite('shaftbottomlefty.txt',shaftbottomlefty);
end

if counter>numel(mess)
    onlysave
else
spots_full=dlmread(mess(counter).Name);
dio=spots_full(1:301,302:602);
homer=spots_full(1:301,1:301);


guiaxis
end
end
