% Computer Vision Assignment 3
% Load Images 
clear all; close all;clc;
flag = 1;
N = 3;
I = cell(1, N);
rgb = cell(1, N);

for x = 1:N
    if flag == 1
        rgb{x} = imread(strcat(num2str(x),'.png'));
    else
        rgb{x} = imread(strcat(num2str(x),'.jpg'));
    end
    figure(1);
    subplot(1,3,x);
    imshow(rgb{x});
    rgb{x} = imresize(rgb{x}, 0.5);
    I{x} = single(rgb2gray(rgb{x}));
    imageSize(x, :) = size(I{x});
end


%% Q1 Compare SIFT features 

% USE IMAGE 1 FOR THIS PART 
theta = 45;
rotated = imrotate(I{1},theta,'crop');
[keypoints1, features1] = sift(I{1},'Levels',4,'PeakThresh',5);
figure(2);
imshow(rgb{1});hold on;
viscircles(keypoints1(1:2,:)',keypoints1(3,:)');
title('SIFT feature of image 1 - with given code');

% ROTATE IMAGE AND DETECT FETURES
[keypoints_rotate, features1_rotate] = sift(rotated,'Levels',4,'PeakThresh',5);
figure(3);
imshow(imrotate(rgb{1},theta,'crop'));hold on;
viscircles(keypoints_rotate(1:2,:)',keypoints_rotate(3,:)');
title('SIFT feature of rotated image 1 - with given code ')

detect1 = SIFT_feature_vector(I{1}, 1);
figure(4);
imshow(rgb{1}); hold on;
draw_circle(detect1);
title('SIFT feature of image 1 - with my code');

% ROTATED IMAGE 
detect2 = SIFT_feature_vector(rotated, 0.9);
figure(5);
imshow(imrotate(rgb{1},theta,'crop')); hold on;
draw_circle(detect2);
title('SIFT feature of rotated image 1 -with my code');

% gnerate histograms for method 1 
indexPairs1 = matchFeatures(features1',features1_rotate', 'Metric', 'SSD', 'MatchThreshold', 2);
pt = randperm(size(indexPairs1, 1), 1);
figure, sgtitle('histogram of a randomly selected feature pairs');
subplot(1, 2, 1);
bar(features1(:, indexPairs1(pt, 1)));
subplot(1, 2, 2);
bar(features1_rotate(:, indexPairs1(pt, 2)));

% generate histograms for method 2 
indexPairs2 = matchFeatures(detect1(:, 4:39),detect2(:, 4:39), 'Metric', 'SSD', 'MatchThreshold', 2);
pt = randperm(size(indexPairs2, 1), 1);
figure, sgtitle('histogram of a randomly selected feature pairs');
subplot(1, 2, 1);
bar(features1(indexPairs2(pt, 1), 4:39));
subplot(1, 2, 2);
bar(features1_rotate(indexPairs2(pt, 2), 4:39));


%% Q2 Feature matching 
% create SIFT features in two consecutive images 
[matchedPoints11, matchedPoints12] = feature_matching(rgb{1}, rgb{2}, I{1}, I{2});

[matchedPoints22, matchedPoints23]= feature_matching(rgb{2}, rgb{3}, I{2}, I{3});


%% Q3  RANSAC Algorithm to optimize feature mathching 
% show the feature pairs in Consensus set 
tuples(:,1:2) = matchedPoints11(:,1:2);
tuples(:,3:4) = matchedPoints12(:,1:2);
[Hc, inliers] = RANSAC(tuples, 500, 0.5);
showMatchedFeatures(rgb{1},rgb{2},inliers(:,1:2), inliers(:,3:4));
title('Matched Features with Inliers');


%%  Q4 panoramas
% CALCULATE HOMOGRAPHIES  H{images}
H = cell(1, N-1);

tuples1(:,1:2) = matchedPoints11(:,1:2);
tuples1(:,3:4) = matchedPoints12(:,1:2);

tuples2(:,1:2) = matchedPoints22(:,1:2);
tuples2(:,3:4) = matchedPoints23(:,1:2);

[H{1}, ~] = RANSAC(tuples1, 500, 0.5);
[H{2}, ~] = RANSAC(tuples2, 500, 0.5);

% TFORMS 
tforms(N) = projective2d(eye(3));
for i = 2: N
    tforms(i) = projective2d(H{i-1}');
    tforms(i).T = tforms(i).T * tforms(i-1).T;
end

Tinv = invert(tforms(2));
for i = 1: numel(tforms)
    tforms(i).T = tforms(i).T * Tinv.T;
    tforms(i) = invert(tforms(i));
end

% INITIATE CANVAS 
for i = 1:numel(tforms)           
    [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 imageSize(i, 2)], [1 imageSize(i, 1)]);    
end

maxImageSize = max(imageSize);

% Find the minimum and maximum output limits 
xMin = min([1; xlim(:)]);
xMax = max([maxImageSize(2); xlim(:)]);

yMin = min([1; ylim(:)]);
yMax = max([maxImageSize(1); ylim(:)]);

% Width and height of panorama.
width  = round(xMax - xMin);
height = round(yMax - yMin);

% Initialize the "empty" panorama.
panorama = zeros([height width 3], 'like', rgb{1});

% create the Panorama
blender = vision.AlphaBlender('Operation', 'Binary mask', ...
    'MaskSource', 'Input port');  

% Create a 2-D spatial reference object defining the size of the panorama.
xLimits = [xMin xMax];
yLimits = [yMin yMax];
panoramaView = imref2d([height width], xLimits, yLimits);

for j = 1:N
    % Transform I into the panorama.
    warpedImage = imwarp(rgb{j}, tforms(j), 'OutputView', panoramaView);       
    % Generate a binary mask.    
    mask = imwarp(true(size(rgb{j},1),size(rgb{j},2)), tforms(j), 'OutputView', panoramaView);
    % Overlay the warpedImage onto the panorama.
    panorama = step(blender, panorama, warpedImage, mask);
end
figure
imshow(panorama)


function [matchedPoints1, matchedPoints2] = feature_matching(rgb1,rgb2, image1, image2)
    [keypoints1, features1] = sift(image1,'Levels',4,'PeakThresh',5);
    [keypoints2, features2] = sift(image2,'Levels',4,'PeakThresh',5);
    
    % match features
    indexPairs_12 = matchFeatures(features1',features2', 'Metric', 'SSD', 'MatchThreshold', 2);
    % visualize the matched points
    
    matchedPoints1 = keypoints1(1:2, indexPairs_12(:, 1))';
    matchedPoints2 = keypoints2(1:2, indexPairs_12(:, 2))';
    figure;
    showMatchedFeatures(rgb1,rgb2,matchedPoints1,matchedPoints2);
    title('Matched Features')
end
