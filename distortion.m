function output=distortion(image, pointY, pointX, angle, s)
% Initialization.
[imageHeight, imageWidth] = size(image);
centerX = floor(imageWidth/2+1);
centerY = floor(imageHeight/2+1);

dy = centerY-pointY;
dx = centerX-pointX;
% How much would the "rotate around" point shift if the 
% image was rotated about the image center. 
[theta, rho] = cart2pol(-dx,dy);
[newX, newY] = pol2cart(theta+angle*(pi/180), rho);
shiftX = round(pointX-(centerX+newX));
shiftY = round(pointY-(centerY-newY));
% Pad the image to preserve the whole image during the rotation.
padX = abs(shiftX);
padY = abs(shiftY);
padded = padarray(image, [padY padX]);
% Rotate the image around the center.
rot = imrotate(padded, angle,  'crop');
% Crop the image.
output = rot(padY+1-shiftY:end-padY-shiftY, padX+1-shiftX:end-padX-shiftX, :);
output = imresize(output, s);
end 