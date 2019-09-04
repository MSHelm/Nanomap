function sort_axis_synapses_previous
global counter dio homer sted top bottomx bottomy topx topy leftx lefty rightx righty classification clickno curX curY...
    bottomneckx bottomnecky shafttopleftx shafttoplefty shafttoprightx shafttoprighty shaftbottomrightx shaftbottomrighty shaftbottomleftx shaftbottomlefty...
    spineline_x spineline_y cd_path
cd(cd_path);

[stat, mess]=fileattrib('*_spots*.txt');
[blub,order]=sort({mess.Name});mess=mess(order);order=[]; %sort to avoid unordered spot files due to server bugs

counter=counter-1;

spots_full=dlmread(mess(counter).Name);
dio=spots_full(1:301,302:602);
homer=spots_full(1:301,1:301);


guiaxis
end