% Author: Kushal Gevaria
% This is the main method used to call the functions to perform sudoku
% detection using the given set of images of the newspaper clips.
function GevariaKushal_SudokuProject()
    % put images in any of these below three directories
    addpath('./TEST_IMAGES');
    addpath( '../TEST_IMAGES/' );
    addpath('../../TEST_IMAGES');
    
    % I would recommend to comment all the below lines and then uncomment
    % one at a time for the execution to prevent pops of multiple images as a
    % result of imaging chain process that can slow down your pc. 
    % Thankyou!
    
    %getSudokuGrid('SCAN0011.JPG');
    %getSudokuGrid('SCAN0035.JPG');
    %getSudokuGrid('SCAN0043.JPG');
    %getSudokuGrid('SCAN00051.JPG');
    %getSudokuGrid('SCAN0066.JPG');
    %getSudokuGrid('SCAN0097.JPG');
    %getSudokuGrid('SCAN00101.JPG');
    getSudokuGrid('SCAN00281.JPG');
end

% This method is used to detect the sudoku box from the given newspaper
% clip and pass on to next function to make the same sudoku box in the
% upright direction based on the found rotation angle.
% This method calls other methods namely, getPaperOrientation(),
% getLines()
function getSudokuGrid(input_image)
    im_orig = imread(input_image);
    im_orig = getPaperOrientation(im_orig); % get rid of paper background
    titleImage = strcat(input_image,': Original Image with Sudoku position detection');
    showImage(im_orig, titleImage);
    im = rgb2gray(im_orig);
    im = im2double(im);
    level = graythresh(im); 
    im = imbinarize(im,level); % binarize the image
    im = ~im;
    % perform morphology
    se = strel('square', 3);       
    im = imopen( im, se);     
    se = strel('line',6,0);       
    im = imclose( im, se);
    % fill the white blobs
    im = imfill(im,'holes');
    im = bwareaopen(im, 400);
    stats = regionprops(im, 'Area', 'Orientation', 'BoundingBox');
    for ii= 1 : length(stats)
        Areai(ii)= stats(ii).Area;
    end
    % get the largest blob
    largestBlobID= find(Areai==max(Areai));
    x1 = stats(largestBlobID).BoundingBox(1);
    x2 = stats(largestBlobID).BoundingBox(3);
    y1 = stats(largestBlobID).BoundingBox(2);
    y2 = stats(largestBlobID).BoundingBox(4);
    location = [x1, y1, x2, y2];
    % find out the location of the sudoku and mark it with magenta phase 1
    rectangle('Position', location, 'Linewidth', 5, 'EdgeColor', 'red');
    upright_im = im;
    upright_im_orig = im_orig;
    showImage(upright_im, 'Semi Filtered Image');
    % perform hough transform to detect lines and squares
    [H,T,R] = hough(upright_im);    
    P  = houghpeaks(H);
    L = houghlines(upright_im, T, R, P);
    I = imoverlay(upright_im_orig, upright_im, [0.9 0.1 0.1]);
    stats = regionprops(upright_im, 'Area', 'Orientation', 'BoundingBox');
    for ii= 1 : length(stats)
        Areai(ii)= stats(ii).Area;
    end
    largestBlobID= find(Areai==max(Areai));  
    croppedSudoku = imcrop(upright_im, stats(largestBlobID).BoundingBox);
    croppedSudoku_orig = imcrop(upright_im_orig, stats(largestBlobID).BoundingBox);
    % perform final cleaning
    se = strel('square',6);       
    croppedSudoku = imclose( croppedSudoku, se);  
    croppedSudoku = bwareafilt(croppedSudoku, 1);
    croppedSudoku = imfill(croppedSudoku,'holes');
    croppedSudoku = bwareaopen(croppedSudoku, 400);
    B = bwboundaries(croppedSudoku);  
    % display the final sudoku
    showImage(croppedSudoku_orig, 'Final cropped Sudoku with Magenta Outline');
    hold on;
    % to box the cropped sudoku with magenta colored square phase 2
    visboundaries(B, 'Color','magenta','LineWidth',5);
    hold off;
    % get the vertical lines defining the sudoku grid to find approriate 
    % rotation angle to make the image upright
    getLines(croppedSudoku_orig, input_image);
end

% This method is used to remove the background of the newspaper which can
% create potential errors while detecting the sudoku. So, get the cropped
% portion of just the newspaper cut(with sudoku), eliminating the background.
function im_orig = getPaperOrientation(im)
    showImage(im, 'Original Image without background removal');
    im_orig1 = im;
    im = rgb2gray(im);
    im = im2double(im);
    im = 2 * (im.^2); % perform gamma correction 
    %showImage(im, 'Gamma Correction');
    level = graythresh(im); 
    im = imbinarize(im,level); % get rid of paper background
    %showImage(im, 'Gamma Correction');
    im = imfill(im,'holes'); % get white paper blob
    im = bwareaopen(im, 400); % fill black spots 
    %showImage(im, 'Greythresh');    
    stats = regionprops(im, 'Area', 'Orientation', 'BoundingBox');
    % get the biggest paper blob subtracting the background
    for ii= 1 : length(stats)
        Areai(ii)= stats(ii).Area;
    end
    largestBlobID= find(Areai==max(Areai)); % get the biggest paper blob
    upright_im_orig = imcrop(im_orig1, stats(largestBlobID).BoundingBox);
    im_orig = upright_im_orig;
end

% This method is used on just the cropped sudoku box from the newspaper
% clip to get the vertical lines using the hough transform and rotate the
% image to make it upright based on the angle those vertical line makes.
% This method calls other methods namely, getCharacters()
function getLines(im_orig, imageName)
    im = rgb2gray(im_orig);
    im = im2double(im);
    level = graythresh(im); 
    im = imbinarize(im,level); % binarize the image
    im = ~im;
    % perform morphology to get rid of noise and only get the vertical
    % lines
    se = strel('line',6,90);       
    im = imclose( im, se);
    se = strel('line',20,90);       
    im = imopen( im, se);
    showImage(im,'Morphology to get vertical lines of the sudoku grid');
    % use hough transform to detect those vertical lines and get their
    % stats
    [H,T,R] = hough(im);
    P  = houghpeaks(H,10,'threshold',ceil(0.3*max(H(:))));
    lines = houghlines(im,T,R,P,'FillGap',5,'MinLength',7);
    showImage(im_orig,'Detected lines using hough transform');
    hold on
    max_len = 0;
    max_theta = 0;
    for k = 1:length(lines)
       xy = [lines(k).point1; lines(k).point2];
       plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
       % Plot beginnings and ends of lines
       plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
       plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
       % Determine the endpoints of the longest line segment
       len = norm(lines(k).point1 - lines(k).point2);
       if ( len > max_len)
          max_len = len;
          xy_long = xy;
          max_theta = lines(k).theta;
       end
    end
    plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','cyan');
    hold off;
    % rotate the image based on the rotation angle of the promising
    % vertical line
    im = imrotate(im_orig,max_theta,'bilinear','crop');
    showImage(im,'Upright Rotated Sudoku');
    getCharacters(im, imageName);
end

% This method is used on the upright version of the cropped sudoku clip to
% extract each digit from those 81 cells of the sudoku matrix using optical
% character recognition search engine of the MATLAB and finally displaying
% those digits in the matrix format
function getCharacters(im_orig, imageName)
    sudokuMatrix = zeros(9,9); % initialized the sudoku matrix
    showImage(im_orig,"Image For Character Recognition");
    im = rgb2gray(im_orig);
    im = im2double(im);
    level = graythresh(im); 
    im = imbinarize(im,level); % binarize the image
    im = imclearborder(im,26);
    im = medfilt2(im); % filter background noise
    binarized_im = im;
    im = imfill(im,'holes');
    se = strel('square',20);       
    im = imopen( im, se);
    showImage(im,'Morphology open to get each cell of Sudoku');
    [labeledImage1, numberOfCells] = bwlabel(im);
    s  = regionprops(im,'Centroid', 'BoundingBox', 'Area');
    % sort labeled object according to their location from the top left
    % position
    coords = vertcat(s.Centroid);  
    [~, ~, coords(:, 2)] = histcounts(coords(:, 2), 9); 
    [~, sortIndex] = sortrows(coords, [2 1]);  
    s = s(sortIndex);  
    row = 1; % to go through row of sudoku matrix
    column = 1; % to go through column of sudoku matrix
    for cellIndex = 1:length(s)        
        cell = imcrop(im_orig, s(cellIndex).BoundingBox);
        %showImage(cell,'dice');
        cell = rgb2gray(cell);
        cell = im2double(cell);
        level = graythresh(cell); 
        cell = imbinarize(cell,level); % binarize the image
        cell = ~cell;
        cell = imclearborder(cell,26);
        regularExpr = '\d';
        %showImage(cell,'Binarize for lines')
        results = ocr(cell, 'CharacterSet', '123456789', ...
                    'TextLayout', 'Block');
        results.Text;
        digits = regexp(results.Text, regularExpr, 'match');
        if isempty(digits)
            cellDigit = 0;
        else
            cellDigit = str2num(char(digits(1)));
        end
        if column == 9
            sudokuMatrix(row,column) = cellDigit;
            row = row + 1;
            column = 1;
        else 
            sudokuMatrix(row,column) = cellDigit;
            column = column + 1;
        end
    end
    fprintf('The final sudoku from the newspaper clip %s --->',imageName);
    sudokuMatrix % print the matrix 
end

% This method is used to print the images which are being processed in
% the given imaging chain
function showImage(im, imTitle)
    figure;
    imshow(im);
    title(imTitle, 'FontSize', 15);
end