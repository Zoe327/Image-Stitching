function l_pyr = laplacian_py(level, g_pyr)
l_pyr = cell(1, level);
[M, N] = size(g_pyr{1});

for p = 1 : level
    sigma = 2^(p-1);
    I_exp = imresize(g_pyr{p+1}, [M/sigma,N/sigma]);  % upsampling
    l_pyr{p} =  g_pyr{p}-I_exp ;

end
end