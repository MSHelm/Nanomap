function hists;


photo=dlmread('photo_unclear.txt'); % photoconverted vesicles from 20 terminals from two different experiments

unphoto=dlmread('photo_clear.txt'); % unphotoconverted vesicles from the same 20 terminals

control=dlmread('unphoto_clear.txt'); % all vesicles from 15 terminals from 20 microM LY294002 (10) and Dextran 15% treated temrinals (5)


for i=1:30
 x(i)=5*i;
end;

subplot(3,1,1);
hist(photo,x);
subplot(3,1,2);
hist(unphoto,x);
subplot(3,1,3);
hist(control,x);
return;

%aphoto=hist(photo,x);
%aunphoto=hist(unphoto,x);
%aphoto(:)=aphoto(:)*100/sum(aphoto);
%aunphoto(:)=aunphoto(:)*100/sum(aunphoto);

%disp(aphoto);
%disp(aunphoto);




exp=[];

exp(1:numel(photo))=photo(1:numel(photo));
exp(numel(photo)+1:numel(photo)+numel(unphoto))=unphoto(1:numel(unphoto));

subplot(2,1,1);
hist(exp,x);
subplot(2,1,2);
hist(control,x);
