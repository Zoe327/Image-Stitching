function draw_circle(extrema)
num_keypoint = size(extrema, 1);
colors = ['b', 'g', 'y', 'r'];
for c = 1: num_keypoint
    point = extrema(c, :);
    centers = [ point(2), point(1)];
    viscircles(centers,point(3),'Color',colors(log2(point(3))),'LineWidth', 0.1);
end
end