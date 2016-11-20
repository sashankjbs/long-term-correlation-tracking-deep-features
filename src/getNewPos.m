function [pos, max_value] = getNewPos(img, pos, patch_size, x, A)

patch = getPatch(img, pos, patch_size);
z = computeFeatures(patch, 4);

global kernel_width;
xzk = computeGaussianCorrelation(z, x, kernel_width);
xzkf = fft2(xzk);

y = ifft2(A.*xzkf);

max_value = max(y(:));

[dx, dy] = find(y == max_value, 1);
pos = pos + [dx, dy];

end