require 'dxruby'    #dxrubyを使うためのファイルを読み込む

Window.width = 400  #ウィンドウの横幅設定
Window.height = 600 #ウィンドウの縦幅設定

class Shooting
    @@image_fighter = Image.load("./fighter.png") #クラス変数@@image_fighterを宣言し、fighter.pngファイルを代入
    @@image_bullets = Image.load("./bullet.png") #クラス変数@@image_bulletsを宣言し、bullet.pngファイルを代入
    @@image_ufo = Image.load("./ufo.png") #クラス変数@@image_ufoを宣言し、ufo.pngファイルを代入
    @@image_background = Image.load("./a.png") #クラス変数@@image_backgroundを宣言し、bg.pngファイルを代入

    def initialize #initializeメソッドが呼び出された際(newメソッドによって)に、メソッド内の処理を行う。
        @fighter_x = 180    #インスタンス変数@fighter_xを100で初期化、戦闘機の初期位置のｘ座標
        @fighter_y = 450    #インスタンス変数@fighter_yを450で初期化、戦闘機の初期位置y座標
        @ufo_x = 65    #インスタンス変数@ufo_xを65で初期化、UFOの初期位置のx座標
        @ufo_y = 25    #インスタンス変数@ufo_yを25で初期化、UFOの初期位置のy座標
        @bullets_y = 420    #インスタンス変数@bullets_yを420で初期化、弾丸の初期位置(戦闘機から射出される位置)のy座標、x座標は戦闘機のx座標によって決まる
        @bullets_y_array = []    #インスタンス変数@bullets_y_arrayを[]で初期化、弾丸のy座標の空配列を作成
        @bullets = []    #インスタンス変数@bulletsを[]で初期化、弾丸の空配列を作成
        @move_fighter = 6    #インスタンス変数@move_fighterを6で初期化、戦闘機の移動量
        @move_bullet = 4    #インスタンス変数@move_bulletを4で初期化、弾丸の移動量
        @move_ufo = 4    #インスタンス変数@move_ufoを2で初期化、UFOの移動量
        @fighter_coo_x = 0    #インスタンス変数@fighter_coo_xを0で初期化、戦闘機のx座標、あとから値を入れるため最初は0にしておく
        @ufo_HP = 100    #インスタンス変数@ufo_HPを100で初期化、UFOのHP(体力)l
        @bullets_attack = 1    #インスタンス変数@bullets_attackを1で初期化、弾丸がUFOにあたったときの攻撃力(一回当たればUFOのHPは99になる)
    end

    def background  #背景を表示
        Window.draw(0,0,@@image_background) #背景を表示
    end

    def timelimit(start_time)   #タイムリミットの設定、この後クラスの外で宣言する変数start_timeを引数に受け取る、タイムリミットは90秒
        font = Font.new(32) #タイムリミット表示のフォントサイズを32に設定
        end_time = Time.now #変数end_timeを現在の時間で初期化
        processing_time = end_time - start_time #変数processing_timeをend_time-start_timeで初期化、時間計測から現在までの経過時間を表す
        countdown = (60 - processing_time).to_i #変数countdownを(90-processing_time).to_iで初期化、残り時間を表す
        if (countdown >= 1) & (@ufo_HP >= 1)    #countdownの時間がまだ残っていて(0ではなくて)、UFOのHPが1以上のとき(UFOが0以下になったときにcountdown表示を消さなければいけないから)
            Window.draw_font(330, 20, "#{countdown}", font) #ウィンドウの右上当たりに残り時間を秒単位で表示する
        elsif (countdown <= 0) & (@ufo_HP >= 1) #countdownが0以下のとき
            @@image_fighter.clear   #戦闘機の画像を消す
            @@image_bullets.clear #弾丸の画像を消す
            @@image_ufo.clear   #UFOの画像を消す
            lose = Font.new(64) #You Lose表示のフォントサイズを64に設定
            Window.draw_font(70, 180, "You Lose", lose) #ウィンドウの中央あたりに「You Lose」の文字を表示する
            if Input.key_push?(K_RETURN)    #この処理によって「You Lose」と表示された後にエンターキーを押してもUFOが倒されることがなくなる
                @ufo_HP += 1    #UFOのHPを増やして弾丸の攻撃と相殺するようにする
            end

            if countdown <= -1 #countdownが-1以下の場合、ウィンドウを閉じる
                Window.close    #ウィンドウを閉じる
            end
        end
    end

    def draw_fighter    #戦闘機を表示する
        Window.draw(@fighter_x, @fighter_y, @@image_fighter)    #戦闘機を表示する
    end

    def draw_ufo    #UFOを表示する
        Window.draw(@ufo_x, @ufo_y, @@image_ufo)    #UFOを表示する
    end

    def motion_ufo  #UFOを動かす
        @ufo_x += @move_ufo #@ufo_xに@move_ufoを代入、UFOを動かす

        if @ufo_x >= 150    #UFOが右端に来たときを表す(150=400(ウィンドウの横幅)-250(UFO画像の横幅))、また、左端についても同様だがどちらの場合もUFOが完全にウィンドウの端につかないようにしている。
            @move_ufo = -@move_ufo  #UFOの移動方向を逆にする
        elsif @ufo_x <= 0   #UFOが左端に来たら
            @move_ufo = -@move_ufo  #UFOの移動方向を逆にする
        end
    end

    def motion_fighter  #戦闘機を動かす
        if Input.key_down?(K_RIGHT) #右方向キーを押しているとき
            @fighter_x += @move_fighter #戦闘機を右に移動させる
            if @fighter_x + 30 >= 400   #戦闘機の右端がウィンドウの右端よりも右に行ったら
                @fighter_x -= @move_fighter #戦闘機がそれ以上右に行かないように止める
            end
        elsif Input.key_down?(K_LEFT)   #左方向キーを押しているとき
            @fighter_x -= @move_fighter #戦闘機を左に移動させる
            if @fighter_x + 8 <= 0  #戦闘機の左端がウィンドウの左端よりも左に行ったら
                @fighter_x += @move_fighter #戦闘機がそれ以上左に行かないように止める
            end
        end

        @fighter_coo_x = @fighter_x + 20    #戦闘機のx座標を設定、@fighter_xは戦闘機の画像のx座標で、戦闘機自体の座標ではないため余白分(20)を足す
    end

    def fire #弾丸の射出
        if Input.key_push?(K_RETURN) & (@ufo_HP >= 1)    #エンターキーを押したとき(@ufo_HP >= 1が無いと、下のcollisionメソッドで表示した「You　Win!」の文字がエンターキーを押すことで消えてしまう、これは@ufo_HPが0未満になってif @ufo_HP == 0の条件を満たさなくなってしまうからである。)
            if  (@fighter_coo_x-15+30 >= @ufo_x+30) && (@fighter_coo_x+15 <= @ufo_x+230)    #弾丸のx座標がUFOの横幅よりも内側にある時(数字が足されているのは画像の余白等を考慮した結果)
                while @bullets_y >= 130 #弾丸がUFOにあたっていない間
                    Window.draw(@fighter_coo_x-15, @bullets_y, @@image_bullets) #戦闘機の先端(の座標)から弾丸を打ち出す(この段階では表示のみ)
                        @bullets_y -= @move_bullet  #弾丸を移動させる(縦方向)
                end   

                if  @bullets_y <= 130   #弾丸がUFOにあたったとき
                    @ufo_HP -= @bullets_attack  #UFOのHPを減らす
                    @bullets_y = 420    #この処理がないと次の射出場所のy座標がずれてしまう
                end

            elsif (@fighter_coo_x-15+30 <= @ufo_x+30) || (@fighter_coo_x-15 >= @ufo_x+230)  #弾丸のx座標がUFOの横幅よりも外側にある時(数字が足されているのは画像の余白等を考慮した結果)
                while @bullets_y >= 0   #弾丸がウィンドウの上端にあっていないとき
                    Window.draw(@fighter_coo_x-15, @bullets_y, @@image_bullets)  #引き続き弾丸を表示
                    @bullets_y -= @move_bullet  #引き続き弾丸を動かす
                end   

                if  @bullets_y <= 0 #弾丸がウィンドウの上端にあたったとき
                    @bullets_y = 420    #弾丸を消し、弾丸の表示位置がずれないようにする
                end
            end
        end
    end

    def collision   #弾丸の衝突によって起こることを記述
        if @ufo_HP <= 0   #UFOのHPがなくなったら
            @@image_fighter.clear#戦闘機の画像を消す
            @@image_bullets.clear  #弾丸の画像を消す
            @@image_ufo.clear #UFOの画像を消す
            win = Font.new(64)  #「You Win!」表示のフォントサイズを64にする
            Window.draw_font(80, 180, "You Win!", win)  #ウィンドウの中央あたりに「You Win!」の文字を表示する
            if Input.key_push?(K_SPACE) #スペースキーを押したとき
                Window.close    #ウィンドウを閉じる
            end
        end
    end           
end

shooting = Shooting.new()   #Shootingクラスのインスタンスメソッドを呼び出して変数shootingに代入
start_time = Time.now   #タイムリミット用の時間計測、開始時間を表す

Window.loop do  #loopは繰り返し．1秒間60回繰り返しが実行される
    shooting.background #backgroundメソッドを呼び出す
    shooting.draw_fighter #draw_fighterメソッドを呼び出す
    shooting.draw_ufo   #draw_ufoメソッドを呼び出す
    shooting.motion_ufo #motion_ufoメソッドを呼び出す
    shooting.timelimit(start_time)  #timelimitメソッドを呼び出す
    shooting.motion_fighter #motion_fighterメソッドを呼び出す
    shooting.fire   #fireメソッドを呼び出す
    shooting.collision  #collisionメソッドを呼び出す
end 