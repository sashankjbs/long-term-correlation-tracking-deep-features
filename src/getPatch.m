function [patch] = getPatch(img, pos, patch_size)

x = pos(1);
y = pos(2);
width = patch_size(1);
height = patch_size(2);

patch = img(x:x+width, y:y+height);

end