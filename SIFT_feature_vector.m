function SIFT_newI = SIFT_feature_vector(I, threshold)
    
% Gaussian Pyramid
g_pyr = gaussian_py(7, I);

% Laplacian Pyramid
lap_pyr = laplacian_py(6, g_pyr);

%find extrema across scales and levels
extrema = [0, 0, 0];
key_point = cell(1, 4);   % 4 levels
for s = 1:4
    key_point{s} = find_extrema(2^s,lap_pyr{s+2},lap_pyr{s+1},lap_pyr{s}, threshold); % find_extrema(sigma, up, im, down)
    extrema = [extrema; key_point{s}];
end
extrema = extrema(2:end,:);

% find SIFT feature vector
mag = cell(1,7);  % gradient magnitude
ori = cell(1,7);  % gradient orientation
gx = cell(1,7);   % gx
gy = cell(1,7);   % gy

for t = 1:7
    [mag{t},ori{t}] = imgradient(g_pyr{t});
    [gx{t}, gy{t}] = imgradientxy(g_pyr{t});
end

num_extrema = size(extrema, 1);
patch = cell(1, num_extrema);
patch_mag = cell(1, num_extrema);
mag_weighted = cell(1, num_extrema);
patch_gx = cell(1, num_extrema);
patch_gy = cell(1, num_extrema);
patch_ori = cell(1, num_extrema);
for i= 1: num_extrema
    % randomly choose a keypoint
    points = extrema;  % level 1; sigma = 2
    
    % find the level of the keypoints and correspond gaussian image
    l = log2(points(i, 3))+1;
    I_selected = g_pyr{l};
    
    % define the patch
    window_size = 16;
    rmin = uint64(max(1, points(i, 1)- round(window_size/2)));
    rmax = uint64(min(size(I_selected,1),rmin + window_size));
    cmin = uint64(max(1, points(i, 2)- round(window_size/2)));
    cmax = uint64(min(size(I_selected,2),cmin + window_size));
    
    patch{i} = I_selected(rmin:rmax, cmin:cmax);
    patch_mag{i} = mag{l}(rmin:rmax, cmin:cmax);
    
    sigma = 8;
    I_weighted = I_selected(rmin:rmax, cmin:cmax);
    weight = fspecial('gaussian', [size(I_weighted, 1), size(I_weighted, 2)], sigma); % 2D Gaussian weighted version
    
    patch_ori{i} = ori{l}(rmin:rmax, cmin:cmax);
    
    mag_weighted{i} = double(I_weighted) .* weight;
    patch_gx{i} = gx{l}(rmin:rmax, cmin:cmax);
    patch_gy{i} = gy{l}(rmin:rmax, cmin:cmax);
end

% create an orientation histogram
SIFT_feature = zeros(num_extrema, 39);
SIFT_feature(:,1:3) = extrema;
bins = 36;
histograms = zeros(num_extrema, bins);

for m = 1:num_extrema
    ind = floor((patch_ori{m}+180)/10)+1;
    for u = 1:size(ind,1)
        for v = 1:size(ind, 2)
            histograms(m, ind(u,v)) = histograms(m, ind(u,v))+ mag_weighted{m}(u, v);
        end
    end
    
    
    [~, idx] = max(histograms(m,:));
    if idx ==1
        ccw = histograms(m);
    else
        ccw = [histograms(m, idx:36) histograms(m, 1: (idx-1))];
    end
    SIFT_feature(m, 4:39) = ccw;  %./sum(ccw);
end

SIFT_newI = SIFT_feature;
SIFT_newI(:, 1) = SIFT_newI(:, 1).*SIFT_newI(:, 3); %.*s1;
SIFT_newI(:, 2) = SIFT_newI(:, 2).*SIFT_newI(:, 3); %.*s1;
end