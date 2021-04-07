// Andrew Barlow
// custom implementation of Daniel Shiffman / Coding train's dithering vid
PImage myImage;

// set the image to dither
String imagePath = "coop.jpg";

// effectively defines how many color values are allowed
// 0.5 < factor < 255
// most visible effects at lower vals though
float factor = 1;

// image preproccessing filter
// 0 for none
int myFilter = GRAY;

//options: 
//THRESHOLD     *parameters can be used but not neccessary
//GRAY
//OPAQUE
//INVERT
//POSTERIZE     *requires params not implemented here
//BLUR          *parameters can be used but not neccessary
//ERODE
//DILATE

void setup() {
  // create canvas
  // since processing doesn't let u use vars, this needs to be hand coded
  size(1000, 500);

  // load image into global var
  myImage = loadImage(imagePath);
  
  // apply a preprocessing filter to image
  // defined above in global vars
  if (myFilter != 0) {
    myImage.filter(myFilter);
  }
  
  // display image on left half of canvas
  image(myImage, 0, 0, width / 2, height);
}

// save image of the canvas if the user presses the space bar
void keyPressed() {
  if (key == ' ') {
    save("dithered.jpg");
  }
}

// calculate pixel indices of an image (processing quirk)
int index(int x, int y) {
  return x + y * myImage.width;
}

// determine a rounded color in range of (factor + 1) color values
color newColor(color pix) {
  
  float oldR = red(pix);
  float oldG = green(pix);
  float oldB = blue(pix);
  
  float newR = round(factor * oldR / 255) * (255 / factor);
  float newG = round(factor * oldG / 255) * (255 / factor);
  float newB = round(factor * oldB / 255) * (255 / factor);
  
  pix = color(newR, newG, newB);
  
  return pix;
}

// dither an individual pixel with parametized weight and error val
color dither(color c, color err, int f) {
  float r, g, b;
  r = red(c);
  g = green(c);
  b = blue(c);
  
  r += red(err) * f / 16.0;
  g += green(err) * f / 16.0;
  b += blue(err) * f / 16.0;
  c += err * f / 16;
  return color(r, g, b);
}

// subtract channel vals of two pixels, the old & the new
color getError(color oldC, color newC) {
  float oldR, oldG, oldB, newR, newG, newB;
  oldR = red(oldC);
  oldG = green(oldC);
  oldB = blue(oldC);
  
  newR = red(newC);
  newG = green(newC);
  newB = blue(newC);
  
  return color(oldR - newR, oldG - newG, oldB - newB);
}

// this function recieves an image and dithers it
// all important paremeters defined globally
PImage ditherImage(PImage img) {
  // prepare pixels to be worked with
  img.loadPixels();
  
  // Weird implementation, check link for more info on algo 
  //https://en.wikipedia.org/wiki/Floyd–Steinberg_dithering
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {

      // calculate new color of current pixel
      color newC = newColor(img.pixels[index(x, y)]);
      
      // calculate difference between correct val and new val
      color err = getError(img.pixels[index(x, y)], newC);

      // change current pixel to the new val
      img.pixels[index(x, y)] = newC;
       
      // very specific to the algo, dither with different weights
      // defs check out the wiki on this one
      // out of order due to bounds checking
      if (x + 1 < img.width) {
        img.pixels[index(x+1, y  )] = dither(img.pixels[index(x+1, y  )], err, 7);

        if (y + 1 < img.height) {
          img.pixels[index(x+1, y+1)] = dither(img.pixels[index(x+1, y+1)], err, 1);
        }
      }
       
       if (y + 1 < img.height) {

         if (x - 1 >= 0) {
           img.pixels[index(x-1, y+1)] = dither(img.pixels[index(x-1, y+1)], err, 3);
         }

         img.pixels[index(x  , y+1)] = dither(img.pixels[index(x, y+1)], err, 5);
       }
       
    }
  }

  // update the image pixels
  img.updatePixels();

  // return it
  return img;
}

// main loop
void draw() {

  // calculate dithered image
  PImage img = ditherImage(myImage);
  
  // display on second half of screen
  image(img, width / 2, 0, width/2, height);
  
  // don't keep doing this
  noLoop();
}