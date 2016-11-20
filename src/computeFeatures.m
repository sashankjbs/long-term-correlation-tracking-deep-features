function [H] = computeFeatures(img, cell_size)

img = single(img);
img = img/255;
H = fhog(img, cell_size);

end