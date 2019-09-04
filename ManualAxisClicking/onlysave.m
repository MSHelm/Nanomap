function onlysave
global counter angles scaling bottomx topx rightx leftx bottomy topy righty lefty classification no_sted_images...
    rotation_angles vertical_shifts horizontal_shifts...
    bottomneckx bottomnecky shafttopleftx shafttoplefty shafttoprightx shafttoprighty shaftbottomrightx shaftbottomrighty shaftbottomleftx shaftbottomlefty...
    spineline_x spineline_y cd_path

cd(cd_path);

[stat, mess]=fileattrib(strcat('*_spots*','.txt'));

classification(classification==0)=4;
% 
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

disp('YOU ARE DONE! YOU ARE FKN AMAZING! GREAT JOB!')
disp('YOU ARE DONE! YOU ARE FKN AMAZING! GREAT JOB!')
disp('YOU ARE DONE! YOU ARE FKN AMAZING! GREAT JOB!')
disp('YOU ARE DONE! YOU ARE FKN AMAZING! GREAT JOB!')
disp('YOU ARE DONE! YOU ARE FKN AMAZING! GREAT JOB!')
close all
end