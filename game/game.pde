import java.util.ArrayList;
import processing.sound.*;

// CLASSES

public enum Direction
{
  UP,
    DOWN,
    LEFT,
    RIGHT
}

public class Grid
{

  private int rows, columns;
  private int gridBoxSize;
  private int firstCoordsX, firstCoordsY;

  /**
   
   @param _rows Amount of rows in the grid
   @param _columns Amount of columns in the grid
   @param _gridBoxSize The size of each box in the grid (pixels)
   @param _firstCoordsX The X position of the top left corner of the grid
   @param _firstCoordsY The Y position of the top left corner of the grid
   
   */
  public Grid(int _rows, int _columns, int _gridBoxSize, int _firstCoordsX, int _firstCoordsY)
  {
    rows = _rows;
    columns = _columns;
    gridBoxSize = _gridBoxSize;
    firstCoordsX = _firstCoordsX;
    firstCoordsY = _firstCoordsY;
  }

  public PVector getRealSquarePosition(int _row, int _column)
  {
    _row -= 1;
    _column -= 1;

    if (_row > rows - 1 || _column > columns - 1 || _row < 0 || _column < 0) return null;

    int realX = firstCoordsX + (_row * gridBoxSize);
    int realY = firstCoordsY + (_column * gridBoxSize);

    return new PVector(realX, realY);
  }
}

public class Fruit
{
  public PVector position;
  public Snake snake;
  public Grid grid;

  public Fruit(Snake _snake, Grid _grid)
  {
    snake = _snake;
    grid = _grid;

    // Random Position:
    PVector newPos = new PVector((int) random(1, _grid.rows), (int) random(1, _grid.rows));

    while (true)
    {
      if (!snake.IsSpaceOccupied(newPos)) break;

      newPos = new PVector((int) random(0, _grid.rows), (int) random(0, _grid.rows));
    }

    position = newPos;
  }
}

public class Snake
{
  public PVector position;
  public Grid gameGrid;

  public Direction dir;

  public ArrayList<PVector> bodyPositions = new ArrayList<PVector>();
  private int defaultLength = 3;

  // Game Loop
  public float loopTime = 0.25f;
  public float currentTimer = 0;
  public boolean loopEnabled = false, dead = false;


  public Snake(PVector _position, Grid _gameGrid)
  {
    gameGrid = _gameGrid;
    position = _position;

    for (int i = defaultLength - 1; i >= 0; i--)
    {
      PVector temp = new PVector(position.x, position.y - i);
      bodyPositions.add(temp);
    }

    dir = Direction.DOWN;
  }

  public void Move(int x, int y)
  {
    PVector pos = new PVector(bodyPositions.get(bodyPositions.size() - 1).x, bodyPositions.get(bodyPositions.size() - 1).y);
    pos.x += x;
    pos.y += y;

    bodyPositions.remove(0);
    bodyPositions.add(pos);
    position.add(new PVector(x, y));
  }

  public void ChangeDirection(Direction _dir)
  {
    if (dir == _dir) return;
    if (dir == Direction.UP && _dir == Direction.DOWN) return;
    if (dir == Direction.DOWN && _dir == Direction.UP) return;
    if (dir == Direction.LEFT && _dir == Direction.RIGHT) return;
    if (dir == Direction.RIGHT && _dir == Direction.LEFT) return;

    dir = _dir;

    currentTimer = loopTime;
  }

  public void Grow(int amount)
  {
    if (amount <= 0) return;

    for (int i = 0; i < amount; i++)
    {
      PVector pos = new PVector(bodyPositions.get(bodyPositions.size() - 1).x, bodyPositions.get(bodyPositions.size() - 1).y);

      if (dir == Direction.UP) pos.y -= 1;
      else if (dir == Direction.DOWN) pos.y += 1;
      else if (dir == Direction.RIGHT) pos.x += 1;
      else if (dir == Direction.LEFT) pos.x -= 1;

      bodyPositions.add(pos);

      position.add(new PVector(dir == Direction.RIGHT ? 1 : dir == Direction.LEFT ? -1 : 0, dir == Direction.DOWN ? 1 : dir == Direction.UP ? -1 : 0));

      currentTimer = 0;
      
      grow.play();
    }
  }

  public boolean IsSpaceOccupied(PVector pos)
  {
    for (int i = 0; i < bodyPositions.size(); i++)
    {
      if (bodyPositions.get(i) == pos)
      {
        return true;
      }
    }

    return false;
  }
}

// VARIABLES

boolean drawGrid = false;
boolean sprint = false;
boolean canChangeDir = true;
boolean deathSoundPlayed = false;


double deltaTime, lastTime;

float deathTimer = 0f;

int rows = 14;
int columns = 14;
int cellSizeX = 700 / columns;

int highScore = 0;

SoundFile walk, grow, click, die;


// Grid(rows, columns, tileSize, startingPixelPositionX, startingPixelPositionY);
Grid gameGrid;
Snake snake;


ArrayList<Fruit> fruits = new ArrayList<Fruit>();
int fruitAmount = 3;

// METHODS

void setup()
{
  size(800, 900);
  frameRate(60);
  
  walk = new SoundFile(this, "blipSelect.wav");
  grow = new SoundFile(this, "powerUp.wav");
  click = new SoundFile(this, "click.wav");
  die = new SoundFile(this, "explosion.wav");
  
  setup_game(14,14);
}

void setup_game(int _rows, int _columns)
{
  rows = _rows;
  columns = _columns;
  cellSizeX = 700 / columns;

  gameGrid = new Grid(rows, columns, cellSizeX, 50, 50);
  snake = new Snake(new PVector(gameGrid.columns / 2, gameGrid.rows / 2), gameGrid);

  fruits.clear();

  for (int i = 0; i < fruitAmount; i++)
  {
    fruits.add(new Fruit(snake, gameGrid));
  }

  snake.loopEnabled = true;
  
  deathSoundPlayed = false;
  
  
}

void draw()
{
  background(#5EA030);

  deltaTime = (millis() - lastTime) / 1000;  // Calculate delta time (time since last frame)

  // Inside Square
  fill(#5e5636);
  strokeWeight(0);
  rect(50, 50, 700, 700);

  if (drawGrid)
  {
    // Grid (28x28)
    for (int i = 0; i <= columns; i++)
    {
      // Columns (vertical)
      strokeWeight(4);
      stroke(#716841);
      line(50 + (cellSizeX*i), 50, 50 + (cellSizeX*i), 750);
    }
    for (int i = 0; i <= rows; i++)
    {
      // Rows (horizontal)
      strokeWeight(4);
      stroke(#716841);
      line(50, 50 + (cellSizeX*i), 750, 50 + (cellSizeX*i));
    }
  }


  // Loop Snake Move
  if (snake.loopEnabled)
  {
    snake.currentTimer += deltaTime;
    
    

    if (snake.currentTimer >= (sprint ? snake.loopTime / 4 : snake.loopTime))
    {
      snake.currentTimer = 0;

      PVector tempPos = new PVector(snake.position.x, snake.position.y);
      tempPos.add(snake.dir == Direction.RIGHT ? 1 : snake.dir == Direction.LEFT ? -1 : 0, snake.dir == Direction.DOWN ? 1 : snake.dir == Direction.UP ? -1 : 0);
      boolean snakeGrew = false;

      // Check for food
      for (int i = 0; i < fruits.size(); i++)
      {
        PVector tempFruitPos = fruits.get(i).position;

        if (tempPos.x == tempFruitPos.x && tempPos.y == tempFruitPos.y)
        {
          fruits.remove(i);
          fruits.add(new Fruit(snake, gameGrid));
          snake.Grow(1);

          snakeGrew = true;
        }
      }

      if (!snakeGrew) snake.Move(snake.dir == Direction.RIGHT ? 1 : snake.dir == Direction.LEFT ? -1 : 0, snake.dir == Direction.DOWN ? 1 : snake.dir == Direction.UP ? -1 : 0);
    }
  }


  for (int i = 0; i < snake.bodyPositions.size(); i++)
  { 
    if (i != snake.bodyPositions.size() - 1)
    {
      if (snake.bodyPositions.get(snake.bodyPositions.size() - 1).x == snake.bodyPositions.get(i).x && snake.bodyPositions.get(snake.bodyPositions.size() - 1).y == snake.bodyPositions.get(i).y)
      {
        die();
      }
    }
    print("\n\n");
    
    PVector pos = gameGrid.getRealSquarePosition((int)snake.bodyPositions.get(i).x, (int)snake.bodyPositions.get(i).y);
    if (pos != null)
    {
      // Smooth Blue Gradient
      int r = (int)(26 * ((i + 1f) / snake.bodyPositions.size()));
      int g = (int)(122 * ((i + 1f) / snake.bodyPositions.size()));
      int b = (int)(230 * ((i + 1f) / snake.bodyPositions.size()));

      noStroke();
      fill(r, g, b);
      rect(pos.x, pos.y, cellSizeX, cellSizeX);
    } else {
      die();
    }
    
    
  }

  // Draw Fruits
  for (int i = 0; i < fruits.size(); i++)
  {
    PVector pos = gameGrid.getRealSquarePosition((int)fruits.get(i).position.x, (int)fruits.get(i).position.y);
    if (pos != null)
    {
      noStroke();
      fill(#d92626);
      rect(pos.x, pos.y, cellSizeX, cellSizeX);
    }
  }

  // Draw Score

  fill(#ffffff);
  textSize(25);
  text("WASD/Arrow Keys to move\nSpace to pause/restart\nShift to sprint", 50, 800);
  text("Score: " + (snake.bodyPositions.size() - 3) + "\nHigh Score: " + highScore, 400, 800);

  rectMode(CORNER);
  fill(#267ad9);
  rect(400, 845, 150, 40);
  rect(575, 845, 150, 40);

  fill(#ffffff);
  text("Normal Map", 405, 875);
  text("Large Map", 580, 875);

  lastTime = millis(); // Save the time at the end of the loop
}

void die()
{
  snake.loopEnabled = false;
      snake.dead = true;

      int score = snake.bodyPositions.size() - 3;
      if (score > highScore)
      {
        highScore = score;
      }
      
      if (!deathSoundPlayed)
      {
        die.play();
        deathSoundPlayed = true;
      }
}

void mouseClicked()
{
  // Normal Map Button
  if (mouseX > 400 & mouseX < 550 && mouseY > 845 && mouseY < 885)
  {
    fruitAmount = 3;
    setup_game(14,14);
    rows = 14;
    columns = 14;
    
    click.play();
  }

  // Large Map Button
  if (mouseX > 575 & mouseX < 725 && mouseY > 845 && mouseY < 885)
  {
    fruitAmount = 6;
    setup_game(28,28);
    rows = 28;
    columns = 28;
    
    click.play();
  }

  print (mouseX + ", " + mouseY);
}

void keyPressed()
{
  if (key == CODED)
  {
    if (canChangeDir)
    {
      if (keyCode == UP)
      {
        snake.ChangeDirection(Direction.UP);
        walk.play();
      }
      if (keyCode == DOWN)
      {
        snake.ChangeDirection(Direction.DOWN);
        walk.play();
      }
      if (keyCode == RIGHT)
      {
        snake.ChangeDirection(Direction.RIGHT);
        walk.play();
      }
      if (keyCode == LEFT)
      {
        snake.ChangeDirection(Direction.LEFT);
        walk.play();
      }
      
    }

    if (keyCode == SHIFT)
    {
      sprint = true;
    }
  }



  if (canChangeDir)
  {
    if (key == 'w')
    {
      snake.ChangeDirection(Direction.UP);
      walk.play();
    }
    if (key == 's')
    {
      snake.ChangeDirection(Direction.DOWN);
      walk.play();
    }
    if (key == 'd')
    {
      snake.ChangeDirection(Direction.RIGHT);
      walk.play();
    }
    if (key == 'a')
    {
      snake.ChangeDirection(Direction.LEFT);
      walk.play();
    }
  }

  if (key == ' ')
  {
    click.play();
    
    if (snake.loopEnabled)
    {
      snake.loopEnabled = false;
    } else
    {
      if (snake.dead)
      {
        setup_game(rows,columns);
      } else
      {
        snake.loopEnabled = true;
      }
    }
  }
}

void keyReleased()
{
  if (key == CODED)
  {
    if (keyCode == SHIFT)
    {
      sprint = false;
    }
  }
}
