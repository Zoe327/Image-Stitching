% find an area in an image
% SIFT_plot for plotting
% hist is the feature vector with size N x 39
function [area,hist] = find_area(image, X, Y, window_size, all_SIFT)
%hist = [];
rmin = uint64(max(1, X- round(window_size/2)));
rmax = uint64(min(size(image,1),rmin + window_size));
cmin = uint64(max(1, Y - round(window_size/2)));
cmax = uint64(min(size(image,1),cmin + window_size));
area = image(rmin:rmax, cmin:cmax);
N = 0;
for r = 1: size(all_SIFT,1)
    sift = all_SIFT(r,:);
    if (sift(1)>=rmin)&&(sift(1)<=rmax)&&(sift(2)>=cmin)&&(sift(2)<=cmax)
        N = N + 1;
        %  area_SIFT(N, :) = [sift(1), sift(2), sift(3)];  % histogram
        hist(N,1) = double(sift(1)-rmin +1);
        hist(N,2) = double(sift(2)-cmin + 1);
        hist(N,3:39) = sift(3:39);
       % hist(N, :) = hist(:);
       % SIFT_plot(N, :) = [double(sift(1)-rmin +1), double(sift(2)-cmin + 1), sift(3)];
    end
end
end