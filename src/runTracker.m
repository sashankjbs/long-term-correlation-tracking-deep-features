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

avg_frame_rate = 0;

for i = 1:num_files
    
    % Read the next image
    current_image_name = files(i).name;
    current_image_path = strcat(file_path, current_image_name);
    img = imread(current_image_path);
    img = rgb2gray(img);
    
    % If it is the first image, then prompt user to select the object to be
    % tracked
    start_time = clock();
    if(i == 1)
        %imshow(img);
        %rect = getrect;
        rect = [254, 215, 81, 34];
        rect = floor(rect);
        %close;
        
        % pos has [x, y] values. patch_size has width and height.
        pos = rect(1:2);
        target_size = rect(3:4);
        motion_model_patch_size = floor(target_size .* [1.4, 2.8]);
        app_model_patch_size = target_size + 8;
        
        patch = getPatch(img, pos, motion_model_patch_size);
        
        motion_model_output_size = [floor(size(patch, 1)/cell_size),...
            floor(size(patch, 2)/cell_size)];
        
        label_sigma = sqrt(prod(target_size)) * label_sigma / cell_size;
        yf = fft2(getLabelImage(motion_model_output_size(2),...
            motion_model_output_size(1), label_sigma));
        
        cos_window = hann(motion_model_output_size(1)) * hann(motion_model_output_size(2))';
        
        xf = fft2(computeFeatures(patch, cell_size, cos_window));
        xkf = computeGaussianCorrelation(xf, xf, kernel_width);
        
        % Equation 2
        A = yf./(xkf + lambda);
    else
        % Equation 3
        patch = getPatch(img, pos, motion_model_patch_size);
        
        zf = fft2(computeFeatures(patch, cell_size, cos_window));
        diff = getNewPos(zf, xf, A);
        %pos = pos + cell_size * [diff(2) diff(1)];
        pos = pos + cell_size * [diff(1) - floor(size(zf,1)/2)-1,...
            diff(2) - floor(size(zf,2)/2)-1];
        
        
        zkf = computeGaussianCorrelation(zf, zf, kernel_width);
        
        A_z = yf./(zkf + lambda);
        
        % Equation 4
        xf = (1 - learning_rate) * xf + learning_rate * zf;
        A = (1 - learning_rate) * A + learning_rate * A_z;
        
    end
    elapsed_time = etime(clock(), start_time);
    if(visualize == 1)
        imshow(imread(current_image_path)); hold on;
        rectangle('Position', [pos([2,1]) - motion_model_patch_size([2,1])/2,...
            motion_model_patch_size([2,1])], 'EdgeColor', 'r');
        drawnow;
    end
    avg_frame_rate = avg_frame_rate + 1/elapsed_time;
    disp(1/elapsed_time);
end

avg_frame_rate = avg_frame_rate/num_files