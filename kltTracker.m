imageDir = 'Hotel Sequence';
imageList = dir(sprintf('%s/*.png',imageDir));
nImages = length(imageList);

% import sequence
im1 = im2double(im2gray(imread(sprintf('%s/%s',imageDir,imageList(1).name))));

new_imageDir = 'hotelTrace';
mkdir(new_imageDir);
new_imageBasename = 'hotel';

% img size
imsize_col = size(im1, 2);
imsize_row = size(im1, 1);

% harris corner in the first img
[rows, cols] = myHarris(im1);

% for each subsequence image:
% Step: create optical flow between the curr & next img

% Hyper param optical flow
% size_ratio = 64/max(size(im1));
window_sz = 15;
leng = (window_sz-1)/2;

% save the trajectory
trail = zeros(20,4,1);

% mark for deleting
delete_mark = zeros(20, 1);

for i=2:nImages
    hold off
    imshow(im1);
    hold on
    im2 = im2single(imread(sprintf('%s/%s',imageDir,imageList(i).name)));
    
    gaussian_five = (1/12)*[-1 8 0 -8 1];

    Ix = imfilter(im1, gaussian_five, 'symmetric', 'same','conv');
    Iy = imfilter(im1, gaussian_five', 'symmetric', 'same','conv');

    % Gaussian filter
    g = fspecial('gaussian', 3, 1);
    Ig_1 = imfilter(im1, g, 'symmetric', 'same');
    Ig_2 = imfilter(im2, g, 'symmetric', 'same');

    It = Ig_1 - Ig_2;
    flow = zeros(20, 2);
    
    curr_trail = zeros(20, 4);
    for j = 1:20
        if delete_mark(j) == 0
            row = round(rows(j));
            col = round(cols(j));
            r_ind = row-leng:row+leng;
            c_ind = col-leng:col+leng;

            ix = Ix(r_ind, c_ind);
            iy = Iy(r_ind, c_ind);
            it = It(r_ind, c_ind);

            A = [ix(:) iy(:)];
            b = it(:);
            V = A\b;      
            % velocity in x (col)
            flow(j,1) = V(1);
            % velocity in y (row)
            flow(j,2) = V(2);
            
            % if flow too high
            if (abs(V(1)) > 7) || (abs(V(2)) > 7)
                delete_mark(j) = 1;
            end
            % if too close to the border
            if (col+V(1) < leng) || (col+V(1) >  imsize_col-leng) ...
                    || (row+V(2) < leng) || (row+V(2) > imsize_row-leng)
                delete_mark(j) = 1;
            end
            % save trail
            curr_trail(j,:) = [col+V(1) col, row+V(2) row];   
        end
    end
    % save the trajectory
    trail = cat(3, trail, curr_trail);      
    
    % draw
    for j=1:size(trail,3)
        for k=1:20
            if delete_mark(k) == 0
                line([trail(k,1,j) trail(k,2,j)], [trail(k,3,j) trail(k,4,j)], 'Color','green','LineWidth',3); 
            end
        end
    end
    for j = 1:20
        if delete_mark(j) == 0
            row = round(rows(j));
            col = round(cols(j));
            plot(col, row, 'o', 'Color','y', 'MarkerSize', 3, 'LineWidth',2);
        end
    end
    pause(0.1);
    % shift windows
    rows = rows + flow(:, 2);
    cols = cols + flow(:, 1);    
    im1 = im2;
    
    imwrite(getframe(gcf).cdata, sprintf("%s/%s_%d.tiff", new_imageDir, new_imageBasename, i));
end
hold off

