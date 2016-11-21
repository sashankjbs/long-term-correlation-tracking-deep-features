function runTracker(file_path)
% file_path should contain the path to the folder with the .jpg files

files = dir(strcat(file_path, '*.jpg'));
num_files = length(files);

lambda = 1e-4;
learning_rate = 0.01;
global kernel_width;
kernel_width = 1;
visualize = 1;
cell_size = 4;
label_sigma = 0.1;

for i = 1:num_files
    % Read the next image
    current_image_name = files(i).name;
    current_image_path = strcat(file_path, current_image_name);
    img = imread(current_image_path);
    img = rgb2gray(img);
    
    % If it is the first image, then prompt user to select the object to be
    % tracked
    
    if(i == 1)
        imshow(img);
        rect = getrect;
        rect = floor(rect)
        close;
        
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
    else
        % Equation 3
        patch = getPatch(img, pos, patch_size);
        
        zf = fft2(computeFeatures(patch, cell_size, cos_window));
        diff = getNewPos(zf, xf, A)
        %pos = pos + cell_size * [diff(2) diff(1)];
        pos = pos + cell_size * [diff(2) - floor(size_x/2)-1, diff(1) - floor(size_y/2)-1];
        
        if(visualize == 1)
            imshow(img); hold on;
            rectangle('Position', [pos, patch_size], 'EdgeColor', 'r');
            drawnow;
        end
        
        zkf = computeGaussianCorrelation(zf, zf, kernel_width);
        
        A_z = yf./(zkf + lambda);
        
        % Equation 4
        x = (1 - learning_rate) * xf + learning_rate * zf;
        A = (1 - learning_rate) * A + learning_rate * A_z;
        
    end

end