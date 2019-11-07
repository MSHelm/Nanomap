function img_bw = foregrounddetect(img,sigma)
img = imgaussfilt(img,sigma);
img = img/max(img(:));
mean = nanmean(img(:));
std = nanstd(img(:));
img = img-1.2*mean; %heuristic that works from Anthony Bilodeau
img = img/std;
img_bw = imbinarize(mat2gray(img));
end