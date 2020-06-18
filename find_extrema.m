function  index = find_extrema(sigma, up, im, down, thre)
[m, n] = size(im);
up = imresize(up, 2);  % upsampling
down = imresize(down, 0.5);  % downsampling
index = [0, 0, 0];  % [x, y, sigma]
N = 1;

for i = 2:m-1
    for j = 2:n-1
        window(1:3, 1:3) = down((i-1):(i+1), (j-1):(j+1));
        window(4:6, 1:3) = im((i-1):(i+1), (j-1):(j+1));
        window(7:9, 1:3) = up((i-1):(i+1), (j-1):(j+1));
        window(5, 2) = window(1,1);
        minn =  min(min(window));
        maxx = max(max(window));
       
        if ((im(i, j)- maxx) > thre)||((im(i, j)- minn) < -thre)

            index(N, :) = [i, j, sigma];
            N = N+1;
        end
        
    end
end

end