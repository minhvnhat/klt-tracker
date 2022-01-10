function [rows,cols] = myHarris(im)

    % Hyper params
    threshold = 0.0015;
    sigma = 5;
    g = fspecial('gaussian', 2*sigma*3 + 1, sigma);
    dx = [-1 0 1; -1 0 1; -1 0 1];

    Ix = imfilter(im, dx, 'symmetric', 'same');
    Iy = imfilter(im, dx', 'symmetric', 'same');

    Ix2 = imfilter(Ix.^2, g, 'symmetric', 'same');
    Iy2 = imfilter(Iy.^2, g, 'symmetric', 'same');
    Ixy = imfilter(Ix.*Iy, g, 'symmetric', 'same');

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

end

