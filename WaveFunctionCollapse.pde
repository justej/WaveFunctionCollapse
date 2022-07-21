import java.util.List;
import java.util.stream.Collectors;
import java.util.concurrent.ThreadLocalRandom;

static final String TILES_DIR = "tiles";

final List<Tile> tiles = new ArrayList<>(); 

public class Tile {
  public static final int LEFT = 0;
  public static final int UP = 1;
  public static final int RIGHT = 2;
  public static final int DOWN = 3;
  
  private PImage image;
  private boolean[] connectors;
  private String file;
  
  public Tile(PImage image, boolean[] connectors, String file) {
    this.image = image;
    this.connectors = connectors;
    this.file = file;
  }
  
  public boolean connector(int side) {
    return connectors[side];
  }
  
  public PImage image() {
    return image;
  }
  
  public String file() {
    return file;
  }
  
  public String toString() {
    return "[" + file +
    ": l=" + connectors[LEFT] +
    ", u=" + connectors[UP] +
    ", r=" + connectors[RIGHT] +
    ", d=" + connectors[DOWN] + "]";
  }
}


void loadTiles(File dir, List<Tile> tiles) {
  for (File f : dir.listFiles()) {
    if (!f.getName().endsWith(".png")) {
      continue;
    }
    
    println("Found file " + f.getAbsolutePath());
    
    PImage img = loadImage(f.getAbsolutePath());

    // It's assumed that tiles have transparent pixels in places without a... route (?)
    boolean[] connectors = {
      alpha(img.get(0, img.height / 2)) != 0,
      alpha(img.get(img.width / 2, 0)) != 0,
      alpha(img.get(img.width - 1, img.height / 2)) != 0,
      alpha(img.get(img.width / 2, img.height - 1)) != 0
    };
    
    tiles.add(new Tile(img, connectors, f.getAbsolutePath()));
  }
}

void showAllTiles(List<Tile> tiles, int w, int h) {
  if (tiles.size() < 1) {
    return;
  }
  
  int x = 0;
  int y = 0;
  int maxTileHeightInRow = tiles.get(0).image().height;

  for (Tile tile : tiles) {
    println(tile);
    
    if (x > w) {
      y += maxTileHeightInRow;
      if (y > height) {
        println("Canvas size is too small to show all tiles");
        return;
      }

      x = 0;
      maxTileHeightInRow = tile.image().height;
    }
    
    if (tile.image().height > maxTileHeightInRow) {
      maxTileHeightInRow = tile.image().height;
    }
    
   image(tile.image(), x, y);
    x += tile.image().width;
  }
}

void fillOut(List<Tile> tiles, int w, int h) {
  if (tiles.size() < 1) {
    return;
  }
  
  // Fill out map
  Tile[][] tileMap = new Tile[int(w / tiles.get(0).image().width)][int(h / tiles.get(0).image().height)];
  for (int i = 0; i < tileMap[0].length; i++) {
    for (int j = 0; j < tileMap.length; j++) {
      List<Tile> options = new ArrayList<>(tiles);
      
      if (j > 0) {
        boolean topTileConnector = tileMap[i][j - 1].connector(Tile.DOWN);
        options = options.stream()
          .filter(tile -> tile.connector(Tile.UP) == topTileConnector)
          .collect(Collectors.toList());
      }
      
      if (i > 0) {
        boolean leftTileConnector = tileMap[i - 1][j].connector(Tile.RIGHT);
        options = options.stream()
          .filter(tile -> tile.connector(Tile.LEFT) == leftTileConnector)
          .collect(Collectors.toList());
      }
      
      tileMap[i][j] = options.get(ThreadLocalRandom.current().nextInt(0, options.size()));
      
      println("(" + i + ", " + j + "): " + tileMap[i][j]); 
    }
  }
  
  // Show map
  background(0);
  for (int i = 0, x = 0; x < w; i++, x += tiles.get(0).image().width) {
    for (int j = 0, y = 0; y < h; j++, y += tiles.get(0).image().height) {
      image(tileMap[i][j].image(), x, y);
    }
  }
}

void setup() {  
  frameRate(1);
  size(640, 640);

  final File dir = new File(sketchPath(), TILES_DIR);
  loadTiles(dir, tiles);
  //showAllTiles(tiles, width, height);
  fillOut(tiles, width, height);
}

void draw() {
  fillOut(tiles, width, height);
}
