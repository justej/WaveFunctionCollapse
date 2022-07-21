// A sketch for creating tiles rotated by 90, 180 and 270 degrees

void setup() {
  final String TILES_DIR = "../tiles";
  
  File dir = new File(sketchPath(), TILES_DIR);
  
  println(dir);
  
  for (File f : dir.listFiles()) {
    if (!f.getName().endsWith(".png")) {
      continue;
    }
    
    String fullFileName = f.getAbsolutePath();
    println("Found file " + fullFileName);
    
    PImage originalImage = loadImage(fullFileName);
    String fileName = fullFileName.substring(0, fullFileName.length() - ".png".length());
    
    PImage rotatedImage = createImage(originalImage.width, originalImage.height, ARGB);
    rotatedImage.copy(originalImage, 0, 0, originalImage.width, originalImage.height, 0, 0, originalImage.width, originalImage.height);
    
    for (int i = 1; i < 4; i++) {
      rotatedImage = rotate90deg(rotatedImage);
      String angle = String.valueOf(90 * i);
      String rotatedFileName = fileName + angle + ".png";
      
      println("Rotated by " + angle + " degrees. Saving file to " + rotatedFileName);
      
      rotatedImage.save(rotatedFileName);
    }
  }
}

PImage rotate90deg(PImage img) {
  PImage rotatedImg = createImage(img.height, img.width, ARGB);
  for (int x = 0; x < img.width; x++) {
    for (int y = 0; y < img.height; y++) {
      rotatedImg.pixels[x * rotatedImg.width + (rotatedImg.width - 1 - y)] = img.pixels[y * img.width + x];
    }
  }
  return rotatedImg;
}
