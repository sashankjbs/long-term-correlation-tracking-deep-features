function [y] = getLabelImage(size_x, size_y, sigma)
% Returns the Gaussian label image.
% Since the FFT of gaussian is also a gaussian, this function can be used
% to generate the labels and the fourier transform of the labels.

% Get x, y positions
[x, y] = meshgrid(1:size_x, 1:size_y);

% Make the center as the peak of the gaussian
x = x - floor(size_x/2);
y = y - floor(size_y/2);

% Use gaussian function to get the 2D gaussian image.
% The center has the maximum value of 1.
y = exp(-(x.^2 + y.^2)./2./sigma^2);

end