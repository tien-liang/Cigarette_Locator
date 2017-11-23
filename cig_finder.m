%read and show image
image=imread('Cig08.JPG'); 
imshow(image);
%turn image to binary image where the color is close to white and orange
white = like_white(image(:,:,1),image(:,:,2),image(:,:,3)); 
orange = like_orange(image(:,:,1),image(:,:,2),image(:,:,3));
% if like_white can find less than 200 pixels, picture is not bright
% enough, try to use hsv and find high value and low saturation points
if sum(white(:)==1) < 200
    m = rgb2hsv(image);
    bright = find(m(:,:,3)>0.6 & m(:,:,2)<0.2);
    w = zeros(size(m(:,:,3)));
    w(bright) = 1;
    w = im2bw(w);
else
    w = white;
end
%fill small holes to make object clear
w = imfill(w,'holes');  
orange = imfill(orange,'holes');
%extract object with approx area of cig butt
w = bwareafilt(w,[800 2000]); 
orange = bwareafilt(orange,[470 2000]);
%calculate property of each remaining object
%BoundingBox is for drawing rectangles
prop_w = regionprops(w,'BoundingBox','MajorAxisLength','MinorAxisLength','Area'); 
prop_o = regionprops(orange,'BoundingBox','MajorAxisLength','MinorAxisLength','Area');
%calculatae number of objects 
num_rec_w = size(prop_w,1);  
num_rec_o = size(prop_o,1);
for i = 1:num_rec_w
    %extract object that looks closer to a rectangle
    if prop_w(i).MajorAxisLength/prop_w(i).MinorAxisLength >1.9 && prop_w(i).Area/(prop_w(i).MajorAxisLength*prop_w(i).MinorAxisLength) > 0.6
        %draw rectangle on the image
        rectangle('Position',prop_w(i).BoundingBox,'LineWidth',3,'EdgeColor','r');
        %print cig butt locations
        fprintf('White Cig butt %d location:\n  x: %0.1f, y: %0.1f, width: %0.1f, height: %0.1f\n',i,prop_w(i).BoundingBox(1),prop_w(i).BoundingBox(2),prop_w(i).BoundingBox(3),prop_w(i).BoundingBox(4));
    end
end
for i = 1:num_rec_o
    if prop_o(i).MajorAxisLength/prop_o(i).MinorAxisLength >2 && prop_o(i).Area/(prop_o(i).MajorAxisLength*prop_o(i).MinorAxisLength) > 0.6
        rectangle('Position',prop_o(i).BoundingBox,'LineWidth',3,'EdgeColor','r');
        fprintf('Orange Cig butt %d location:\n  x: %0.1f, y: %0.1f, width: %0.1f, height: %0.1f\n',i,prop_o(i).BoundingBox(1),prop_o(i).BoundingBox(2),prop_o(i).BoundingBox(3),prop_o(i).BoundingBox(4));
    end
end

function white = like_white(R,G,B)
    white = R>200 & G>200 & B>200;
end
function orange = like_orange(R,G,B)
    orange = R>140 & R<230 & G>90 & G<190 & B>40 & B<140;
end