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
  size(1000, 500);
  myImage = loadImage(imagePath);
  
  if (myFilter != 0) {
    myImage.filter(myFilter);
  }
  
  image(myImage, 0, 0, width / 2, height);
}

void keyPressed() {
  if (key == ' ') {
    save("dithered.jpg");
  }
}

int index(int x, int y) {
  return x + y * myImage.width;
}

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


color dither(color c, color err, int f) {
  float r = red(c);
  float g = green(c);
  float b = blue(c);
  
  r += red(err) * f / 16.0;
  g += green(err) * f / 16.0;
  b += blue(err) * f / 16.0;
  c += err * f / 16;
  return color(r, g, b);
}

color getError(color oldC, color newC) {
  float oldR = red(oldC);
  float oldG = green(oldC);
  float oldB = blue(oldC);
  
  float newR = red(newC);
  float newG = green(newC);
  float newB = blue(newC);
  
  return color(oldR - newR, oldG - newG, oldB - newB);
}
PImage ditherImage(PImage img) {
  // prepare pixels to be worked with
  img.loadPixels();
  
  // Weird implementation, check link for more info on algo 
  //https://en.wikipedia.org/wiki/Floyd–Steinberg_dithering
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      color newC = newColor(img.pixels[index(x, y)]);
      
      color err = getError(img.pixels[index(x, y)], newC);
      img.pixels[index(x, y)] = newC;
       
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
  img.updatePixels();
  return img;
}

void draw() {

  PImage img = ditherImage(myImage);
  
  image(img, width / 2, 0, width/2, height);
  
  noLoop();
}
