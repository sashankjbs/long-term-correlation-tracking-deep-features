clear all;
cam = webcam(1);

videoFrame = snapshot(cam);
frameSize = size(videoFrame);

videoPlayer = vision.VideoPlayer('Position', [100 100 [frameSize(2), frameSize(1)]+30]);

runLoop = true;

lambda = 1e-4;
learning_rate = 0.01;
global kernel_width;
kernel_width = 1;
visualize = 1;
cell_size = 4;
label_sigma = 0.1;

while(runLoop)
    img = snapshot(cam);
    imshow(img);
    rect = getrect;
    rect = floor(rect);
    runLoop = false;
    
    % pos has [x, y] values. patch_size has width and height.
    pos = rect(1:2);
    patch_size = rect(3:4);

    patch = getPatch(img, pos, patch_size);

    size_y = floor(size(patch, 1)/cell_size);
    size_x = floor(size(patch, 2)/cell_size);

    label_sigma = sqrt(size_x * size_y) * label_sigma / 2;
    yf = fft2(getLabelImage(size_x, size_y, label_sigma));

    cos_window = hann(size_y) * hann(size_x)';

    xf = fft2(computeFeatures(patch, cell_size, cos_window));
    xkf = computeGaussianCorrelation(xf, xf, kernel_width);

    % Equation 2
    A = yf./(xkf + lambda);
end

runLoop = true;

while(runLoop)
    img = snapshot(cam);
    img = rgb2gray(img);
    patch = getPatch(img, pos, patch_size);

    zf = fft2(computeFeatures(patch, cell_size, cos_window));
    diff = getNewPos(zf, xf, A)
    %pos = pos + cell_size * [diff(2) diff(1)];
    pos = pos + cell_size * [diff(2) - floor(size_x/2)-1, diff(1) - floor(size_y/2)-1];

    if(visualize == 1)
        %imshow(img); hold on;
        %rectangle('Position', [pos, patch_size], 'EdgeColor', 'r');
        %drawnow;
        bboxPolygon = [pos(1), pos(2), pos(1) + patch_size(1), pos(2), pos(1) + patch_size(1),...
            pos(2) + patch_size(2), pos(1), pos(2) + patch_size(2)];
        img = insertShape(img, 'Polygon', bboxPolygon, 'LineWidth', 3);
        step(videoPlayer, img);
    end

    zkf = computeGaussianCorrelation(zf, zf, kernel_width);

    A_z = yf./(zkf + lambda);

    % Equation 4
    x = (1 - learning_rate) * xf + learning_rate * zf;
    A = (1 - learning_rate) * A + learning_rate * A_z;
    runLoop = isOpen(videoPlayer);
end

clear cam;
release(videoPlayer);
