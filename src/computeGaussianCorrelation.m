function [k] = computeGaussianCorrelation(x, y, sigma)
% Computes the phi(x).phi(x')

xx = x(:)' * x(:);
yy = y(:)' * y(:);

xf = fft2(x);
yf = fft2(y);
xyf = xf .* conj(yf);
xy = real(ifft2(xyf));

k = exp(-1/sigma^2 * max(0, xx + yy - 2 * xy));

end