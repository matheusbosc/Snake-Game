// --  TODO  --
// - Add array for body part positions
// - Add fruits
// - Make snake grow
// - Add UI



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

public class Snake
{
  public PVector position;
  public Grid gameGrid;

  public Direction dir;

  // Game Loop
  public float loopTime = 0.25f;
  public float currentTimer = 0;
  public boolean loopEnabled = false;


  public Snake(PVector _position, Grid _gameGrid)
  {
    gameGrid = _gameGrid;
    position = _position;

    dir = Direction.RIGHT;
  }

  public void Move(int x, int y)
  {
    position.x += x;
    position.y += y;
  }

  public void ChangeDirection(Direction _dir)
  {
    if (dir == Direction.UP && _dir == Direction.DOWN) return;
    if (dir == Direction.DOWN && _dir == Direction.UP) return;
    if (dir == Direction.LEFT && _dir == Direction.RIGHT) return;
    if (dir == Direction.RIGHT && _dir == Direction.LEFT) return;

    dir = _dir;

    currentTimer = loopTime;
  }
}

// VARIABLES

boolean drawGrid = false;

boolean canChangeDir = true;

double deltaTime, lastTime;

Grid gameGrid = new Grid(28, 28, 25, 50, 50);

Snake snake = new Snake(new PVector(gameGrid.columns / 2, gameGrid.rows / 2), gameGrid);

// METHODS

void setup()
{
  size(800, 800);
  frameRate(60);
  snake.loopEnabled = true;
}

void draw()
{
  background(#719d58);

  deltaTime = (millis() - lastTime) / 1000;  // Calculate delta time (time since last frame)

  // Inside Square
  fill(#5e5636);
  strokeWeight(0);
  rect(50, 50, 700, 700);

  if (drawGrid)
  {
    // Grid (28x28)
    for (int i = 0; i <= 28; i++)
    {
      // Columns (vertical)
      strokeWeight(1);
      line(50 + (25*i), 50, 50 + (25*i), 750);
    }
    for (int i = 0; i <= 28; i++)
    {
      // Rows (horizontal)
      strokeWeight(1);
      line(50, 50 + (25*i), 750, 50 + (25*i));
    }
  }


  // Loop Snake Move
  if (snake.loopEnabled)
  {
    snake.currentTimer += deltaTime;

    if (snake.currentTimer > snake.loopTime)
    {
      snake.currentTimer = 0;
      snake.Move(snake.dir == Direction.RIGHT ? 1 : snake.dir == Direction.LEFT ? -1 : 0, snake.dir == Direction.DOWN ? 1 : snake.dir == Direction.UP ? -1 : 0);
    }
  }


  PVector pos = gameGrid.getRealSquarePosition((int)snake.position.x, (int)snake.position.y);
  if (pos != null)
  {
    fill(#f61313);
    rect(pos.x, pos.y, 25, 25);
  }

  lastTime = millis(); // Save the time at the end of the loop
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
      }
      if (keyCode == DOWN)
      {
        snake.ChangeDirection(Direction.DOWN);
      }
      if (keyCode == RIGHT)
      {
        snake.ChangeDirection(Direction.RIGHT);
      }
      if (keyCode == LEFT)
      {
        snake.ChangeDirection(Direction.LEFT);
      }
      canChangeDir = false;
    }
  }



  if (canChangeDir)
  {
    if (key == 'w')
    {
      snake.ChangeDirection(Direction.UP);
    }
    if (key == 's')
    {
      snake.ChangeDirection(Direction.DOWN);
    }
    if (key == 'd')
    {
      snake.ChangeDirection(Direction.RIGHT);
    }
    if (key == 'a')
    {
      snake.ChangeDirection(Direction.LEFT);
    }
    canChangeDir = false;
  }
}

void keyReleased()
{
  canChangeDir = true;
}

