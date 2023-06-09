require 'dxruby'

# ウィンドウサイズ
WINDOW_WIDTH = 640
WINDOW_HEIGHT = 480

# ゲームステート
STATE_PLAYING = 0
STATE_GAMEOVER = 1

# プレイヤーの情報
class Player
  attr_accessor :x, :y, :vel_y, :on_ground

  def initialize
    @image = Image.load('player.png')
    @x = 100
    @y = 100
    @vel_y = 0
    @on_ground = false
  end

  def draw
    Window.draw(@x, @y, @image)
  end
end

# プラットフォームの情報
class Platform
  attr_reader :x, :y, :width, :height

  def initialize(x, y, width, height)
    @image = Image.new(width, height, C_GREEN)
    @x = x
    @y = y
    @width = width
    @height = height
  end

  def draw
    Window.draw(@x, @y, @image)
  end
end

# ゲームの状態を管理する変数
game_state = STATE_PLAYING

# プレイヤーとプラットフォームのインスタンスを作成
player = Player.new
platforms = []
platforms << Platform.new(0, WINDOW_HEIGHT - 20, WINDOW_WIDTH, 20) # 地面

# 初期化処理
Window.width = WINDOW_WIDTH
Window.height = WINDOW_HEIGHT

Window.loop do
  case game_state
  when STATE_PLAYING
    # ゲームプレイ中
    if Input.key_push?(K_ESCAPE)
      break
    end

    # プレイヤーの移動
    player.vel_y += 0.5  # 重力
    player.y += player.vel_y
    player.on_ground = false

    # プレイヤーとプラットフォームの衝突判定
    platforms.each do |platform|
      if player.y + player.image.height > platform.y && player.y < platform.y + platform.height &&
         player.x + player.image.width > platform.x && player.x < platform.x + platform.width
        player.y = platform.y - player.image.height
        player.vel_y = 0
        player.on_ground = true
      end
    end

    if Input.key_push?(K_SPACE) && player.on_ground
      player.vel_y = -10  # ジャンプ力
    end

    # 描画
    Window.draw_box_fill(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, C_WHITE)
    platforms.each(&:draw)
    player.draw

    # ゲームオーバー判定
    if player.y > WINDOW_HEIGHT
      game_state = STATE_GAMEOVER
    end

  when STATE_GAMEOVER
    # ゲームオーバー
    if Input.key_push?(K_RETURN)
      # リトライ
      game_state = STATE_PLAYING
      player = Player.new
    end

    Window.draw_font(200, 200, "Game Over", Font.default)
    Window.draw_font(180, 250, "Press ENTER to retry", Font.default)
  end

  break if Input.key_push?(K_ESCAPE)
end
