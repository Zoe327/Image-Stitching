function g_pyr = gaussian_py(level, I)
    g_pyr = cell(1, level);
    g_pyr{1} = imgaussfilt(I, 1);
    [M, N] = size(g_pyr{1});
for n = 1: level-1   %  level 1 - max
    sigma = 2^n; 
    I_blur = imgaussfilt(I,sigma);  % gaussian filtering
    
    g_pyr{n+1} = imresize(I_blur, [M/sigma, N/sigma]); % 0.5^n); % subsampling
    
end
end