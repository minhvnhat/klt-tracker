# klt-tracker
 
Kanade-Lucas-Tomasi (KLT) tracker implementation in MATLAB with Harris Corner detector and Optical Flow estimator.

 ![Kanade-Lucas-Tomasi (KLT) tracker implementation in MATLAB with Harris Corner detector and Optical Flow estimator](https://github.com/minhvnhat2711/klt-tracker/blob/main/hotel_traced.gif)

## How to run
 
 ### Run `kltTracker.m`
 
 ## Flow
 
 ### Use Harris Corner Detector to extract keypoints
 ```
% Calculate gradients 
...
k = 0.04;
r = (Ix2.*Iy2 - Ixy.^2) - k*(Ix2 + Iy2).^2;

local_max = imregionalmax(r);
% local maximum
r(local_max == 0) = 0;
% threshold
r(r <= threshold) = 0;
% random 20 key points
selected = randsample(find(r), 20);
% turn linear index into 2d
[rows,cols] = ind2sub([size(im,1) size(im,2)],selected);
```

### For each image, estimate Optical Flow around the keypoints and visualize the trajectory
```
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
```

