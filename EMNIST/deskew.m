function deskewed_image = deskew(image)
    %calculate the hough transform of the image
    [H, theta, rho] = hough(image);
    P = houghpeaks(H, 5);
    %find the mean skew angle
    theta_tot = mean(P, 1);
    %Note that we rotate by theta_tot rather than 90-theta_tot; this is
    %because the deskewing happens after the data reduction stage
    theta_tot = theta_tot(1);
    deskewed_image = imrotate(image, theta_tot,"bilinear", "crop");
end