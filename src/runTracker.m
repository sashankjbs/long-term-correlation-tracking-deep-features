function runTracker(file_path)
% file_path should contain the path to the folder with the .jpg files

files = dir(strcat(file_path, '*.jpg'));
num_files = length(files);

global lambda = 1e-4;
global learning_rate = 0.01;
global kernel_width = 0.1;

for i = 1:num_files
    % Read the next image
    current_image_name = files(i).name;
    current_image_path = strcat(file_path, current_image_name);
    img = imread(current_image_path);
    
    % If it is the first image, then prompt user to select the object to be
    % tracked
    
    if(i == 1)
        imshow(img);
        rect = getrect;
        rect = floor(rect);
        
        % pos has [x, y] values. patch_size has width and height.
        pos = rect(1:2);
        patch_size = rect(3:4);
        
        patch = getPatch(img, pos, patch_size);
        
        x = computeFeatures(patch, 4);
        xk = computeGaussianCorrelation(x, x, kernel_width);
        xkf = fft2(xk);
        
        yf = getLabelImage(size_x, size_y, 20);
        
        % Equation 2
        A = yf./(xkf + lambda);
    else
        pos = getNewPos(img, pos, patch_size, x, A);
        
    end

end