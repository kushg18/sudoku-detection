Sudoku Detection
=============================

### About ###
-----------------------------
This project is about ***image processing*** on the given newspaper clip to perform ***sudoku detection***

### Technology Stack ### 
-----------------------------
1. MATLAB
2. Image processing chain using the in-build packages provided by MATLAB
3. Optical Character Recognition

### Image Processing Chain ### 
-----------------------------
The general imaging chain used for the given sample images is as follows – 
1.	Firstly, read the image and convert it into double format for image processing and performing arithmetic operations with better precision while doing noise removal, morphology or binarizing the image.
2.	Remove the unnecessary black background that might create potential problem while blob detection. Crop just the newspaper clip from the given image for further processing. 
3.	Binarize the cropped image of the newspaper clip using greythresh() and imbinarize() to convert the pixels signifying two values namely,  black(0) and white(1). This will convert the Sudoku grid and other objects on the newspaper with black pixels and newspaper background as white pixels. 
4.	Invert the binarized image to convert objects on newspaper from black pixels to white pixels for white blob detection.
5.	Use structuring element function strel() as ‘squares’ and ‘line’ to detect the square and line objects on the newspaper and perform imclose() operation to eliminate all the unnecessary letters and other objects that does not show evidence of a Sudoku object. 
6.	Finally, use Hough transform to detect Sudoku grid lines which will prominently show on the image at a particular location thereby finding the same location and the angle at which the Sudoku is tilted. 
7.	Crop the Sudoku location using the blob detection with largest area and then outline the same using visboundaries() function with magenta color. 
8.	Use bwareafilt() function to get rid of the small minute blobs that appear in some of the sample images popping up touching the boundaries and just get big white Sudoku blob. 
9.	Display the cropped Sudoku image with magenta box outlining the outer box of the Sudoku. 
10.	Again perform the morphology using line as the structuring element for the strel() function to obtain the lines representing thee vertical lines of the sudoku grid. These vertical lines will help to find the rotation of the image.
11.	Use Hough transform to detect the prominent vertical lines and check whether there exists 10 such lines with similar lengths and angle of rotation. 
12.	Finally, rotate the original cropped sudoku image with the angle of rotation of one of those prominent lines to bring it in the upright position.
13.	Again, binarize the original cropped sudoku image and perform filtering operation to get rid of the noise created while rotating the image.
14.	Perform the morphology using square structuring element with strel() function to obtain clear 81 cells that are represented in the sudoku grid. These 81 cells contains the information about the digits required for  extraction. 
15.	Use bwlabel() function to label these cell objects and crop each such cell object from the original cropped upright sudoku image.
16.	Perform imclearborder() function to get rid of the noise and make the digit look prominent before performing optical character recognition on the same.
17.	Finally, perform optical character recognition on the filtered & cropped cell object image using certain parameters to make the algorithm only expect the outcome to be digits. The parameters used are as follows - 
ocr(cell, 'CharacterSet', '123456789', 'TextLayout', 'Block');
Here, cell is the actual cell object image, the character set that needs to be recognized are digits in the range 1-9 and the text layout is block making the algorithm to learn that everything should be counted as a single outcome. 
18.	Outcome of step 17 might include unnecessary erroneous characters. To get rid of such characters, use regular expression match to filter out the same and only obtain a single digit. 
19.	Final string obtained might be empty as well representing no digit. Check if the string length is 0 or not. If it is 0, then assume that digit value to be 0. Store each of these digits obtained in a 9X9 matrix in MATLAB.
20.	Future work: Use these sudoku matrices obtained from different newspaper clips and stored in the MATLAB variable to actually solve the puzzle.
After running the above imaging chain to perform object segmentation on the given sample images, I was able to achieve perfect Sudoku box segmentation from the given newspapers, but this imaging chain might not work for all possible combinations of erroneous images that might fail this imaging chain process. 

### Result Example ###
-----------------------------

#### Newspaper Clip of Sudoku ####
![alt text](https://github.com/kushg18/sudoku-detection/blob/master/SudokuImages/SCAN00051.JPG)

#### Detected Sudoku Matrix ####
![alt text](https://github.com/kushg18/sudoku-detection/blob/master/SudokuResults/SCAN0051_Sudoku.png)