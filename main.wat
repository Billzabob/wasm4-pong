(import "env" "memory" (memory 1))
(import "env" "rect" (func $rect (param i32 i32 i32 i32)))
(import "env" "text" (func $text (param i32 i32 i32)))
(import "env" "tone" (func $tone (param i32 i32 i32 i32)))

(global $PALETTE0 i32 (i32.const 0x04))
(global $PALETTE2 i32 (i32.const 0x0c))
(global $GAMEPAD1 i32 (i32.const 0x16))
(global $GAMEPAD2 i32 (i32.const 0x17))
(global $NETPLAY i32 (i32.const 0x20))
(global $BUTTON_UP i32 (i32.const 64))
(global $BUTTON_DOWN i32 (i32.const 128))
(global $TONE_TRIANGLE i32 (i32.const 2))

(global $PLAYER1 i32 (i32.const 0x19a0))
(global $PLAYER2 i32 (i32.const 0x19a1))
(global $BALL_X i32 (i32.const 0x19a2))
(global $BALL_Y i32 (i32.const 0x19a3))
(global $DIRECTION_X i32 (i32.const 0x19a4))
(global $BALL_Y_SPEED i32 (i32.const 0x19a5))
(global $PADDLE_SPEED i32 (i32.const 1))
(global $BALL_SPEED i32 (i32.const 1))
(global $MIN_PADDLE i32 (i32.const 6))
(global $MAX_PADDLE i32 (i32.const 124))
(global $SCORE_TO_WIN i32 (i32.const 0x39))

(global $P1_SCORE_TEXT i32 (i32.const 0x2000))
(global $P2_SCORE_TEXT i32 (i32.const 0x2002))
(global $WINNER_TEXT i32 (i32.const 0x2004))
(global $WINNER i32 (i32.const 0x200b))

(data (i32.const 0x2000) "\30\00")
(data (i32.const 0x2002) "\30\00")
(data (i32.const 0x2004) "PLAYER 0 WINS!\00")

(func (export "start")
  (i32.store (global.get $PALETTE0) (i32.const 0x000000))
  (i32.store (global.get $PALETTE2) (i32.const 0xffffff))
  (i32.store8 (global.get $PLAYER1) (i32.const 64))
  (i32.store8 (global.get $PLAYER2) (i32.const 64))
  (i32.store8 (global.get $BALL_X) (i32.const 78))
  (i32.store8 (global.get $BALL_Y) (i32.const 78))
  (i32.store8 (global.get $DIRECTION_X) (i32.const 1))
)

(func (export "update")
  (local $gamepad1 i32)
  (local $gamepad2 i32)
  (local $player1 i32)
  (local $player2 i32)
  (local $p1_score i32)
  (local $p2_score i32)
  (local $direction_x i32)
  (local $ball_x i32)
  (local $ball_y i32)
  (local $ball_y_speed i32)
  (local $scored i32)
  (local $winner i32)

  ;; Load locals from memory
  (local.set $gamepad1 (i32.load8_u (global.get $GAMEPAD1)))
  (local.set $gamepad2 (i32.load8_u (global.get $GAMEPAD2)))
  (local.set $player1 (i32.load8_u (global.get $PLAYER1)))
  (local.set $player2 (i32.load8_u (global.get $PLAYER2)))
  (local.set $p1_score (i32.load8_u (global.get $P1_SCORE_TEXT)))
  (local.set $p2_score (i32.load8_u (global.get $P2_SCORE_TEXT)))
  (local.set $ball_x (i32.load8_u (global.get $BALL_X)))
  (local.set $ball_y (i32.load8_u (global.get $BALL_Y)))
  (local.set $direction_x (i32.load8_s (global.get $DIRECTION_X)))
  (local.set $ball_y_speed (i32.load8_s (global.get $BALL_Y_SPEED)))
  (local.set $winner (i32.load8_u (global.get $WINNER)))

  ;; Paddle movement
  (local.set $player1 (call $move_down (local.get $gamepad1) (local.get $player1)))
  (local.set $player2 (call $move_down (local.get $gamepad2) (local.get $player2)))
  (local.set $player1 (call $move_up (local.get $gamepad1) (local.get $player1)))
  (local.set $player2 (call $move_up (local.get $gamepad2) (local.get $player2)))

  ;; Move ball
  (local.set $ball_x (i32.add (local.get $ball_x) (i32.mul (local.get $direction_x) (global.get $BALL_SPEED))))
  (local.set $ball_y (i32.add (local.get $ball_y) (local.get $ball_y_speed)))

  ;; Change direction of ball if hits left paddle
  (if
    (i32.and
      (i32.le_s (local.get $ball_x) (i32.const 8))
      (call $hit_paddle (local.get $player1) (local.get $ball_y)))
    (then
      (local.set $direction_x (i32.const 1))
      (call $tone (i32.const 500) (i32.const 4) (i32.const 100) (global.get $TONE_TRIANGLE))
      (local.set $ball_y_speed (call $calc_ball_y_speed (local.get $ball_y) (local.get $player1)))
    )
  )

  ;; Change direction of ball if hits right paddle
  (if
    (i32.and
      (i32.ge_s (local.get $ball_x) (i32.const 148))
      (call $hit_paddle (local.get $player2) (local.get $ball_y)))
        (then
          (local.set $direction_x (i32.const -1))
          (call $tone (i32.const 500) (i32.const 4) (i32.const 100) (global.get $TONE_TRIANGLE))
          (local.set $ball_y_speed (call $calc_ball_y_speed (local.get $ball_y) (local.get $player2)))
        )
  )

  ;; Change direction of ball if hits top or bottom
  (if
    (i32.or
      (i32.le_s (local.get $ball_y) (i32.const 2))
      (i32.ge_s (local.get $ball_y) (i32.const 154))
    )
    (then
      (call $tone (i32.const 500) (i32.const 4) (i32.const 100) (global.get $TONE_TRIANGLE))
      (local.set $ball_y_speed (i32.mul (local.get $ball_y_speed) (i32.const -1)))
    )
  )

  ;; Update p1 score
  (if (i32.ge_s (local.get $ball_x) (i32.const 156))
    (then
      (if (i32.lt_u (local.get $p1_score) (global.get $SCORE_TO_WIN))
        (then
          (local.set $p1_score (i32.add (i32.const 1) (local.get $p1_score)))
        )
      )
      (local.set $ball_x (i32.const 136))
      (local.set $scored (i32.const 1))
    )
  )

  ;; Update p2 score
  (if (i32.le_s (local.get $ball_x) (i32.const 0))
    (then
      (if (i32.lt_u (local.get $p2_score) (global.get $SCORE_TO_WIN))
        (then
          (local.set $p2_score (i32.add (i32.const 1) (local.get $p2_score)))
        )
      )
      (local.set $ball_x (i32.const 20))
      (local.set $scored (i32.const 1))
    )
  )

  ;; Check for winner
  (if (i32.eq (local.get $winner) (i32.const 0x30))
    (then
      (if (i32.eq (local.get $p1_score) (global.get $SCORE_TO_WIN))
        (then
          (local.set $winner (i32.const 0x31))
        )
      )

      (if (i32.eq (local.get $p2_score) (global.get $SCORE_TO_WIN))
        (then
          (local.set $winner (i32.const 0x32))
        )
      )
    )
  )

  ;; Reset and sound on score
  (if (local.get $scored)
    (then
      (local.set $ball_y (i32.const 78))
      (local.set $ball_y_speed (i32.const 0))
      (local.set $direction_x (i32.mul (local.get $direction_x) (i32.const -1)))
      (call $tone
        (i32.or
          (i32.const 0)
          (i32.shl (i32.const 1000) (i32.const 16)))
        (i32.const 40)
        (i32.const 100)
        (global.get $TONE_TRIANGLE))
    )
  )

  ;; Update memory for next frame
  (i32.store8 (global.get $PLAYER1) (local.get $player1))
  (i32.store8 (global.get $PLAYER2) (local.get $player2))
  (i32.store8 (global.get $P1_SCORE_TEXT) (local.get $p1_score))
  (i32.store8 (global.get $P2_SCORE_TEXT) (local.get $p2_score))
  (i32.store8 (global.get $WINNER) (local.get $winner))
  (i32.store8 (global.get $BALL_X) (local.get $ball_x))
  (i32.store8 (global.get $BALL_Y) (local.get $ball_y))
  (i32.store8 (global.get $DIRECTION_X) (local.get $direction_x))
  (i32.store8 (global.get $BALL_Y_SPEED) (local.get $ball_y_speed))

  ;; Left player
  (call $rect (i32.const 4) (local.get $player1) (i32.const 4) (i32.const 32))

  ;; Right player
  (call $rect (i32.const 152) (local.get $player2) (i32.const 4) (i32.const 32))

  ;; Ball
  (call $rect (local.get $ball_x) (local.get $ball_y) (i32.const 4) (i32.const 4))

  ;; Top line
  (call $rect (i32.const 0) (i32.const 0) (i32.const 160) (i32.const 2))

  ;; Bottom line
  (call $rect (i32.const 0) (i32.const 158) (i32.const 160) (i32.const 2))

  ;; P1 score
  (call $text (global.get $P1_SCORE_TEXT) (i32.const 69) (i32.const 5))

  ;; P2 score
  (call $text (global.get $P2_SCORE_TEXT) (i32.const 84) (i32.const 5))

  ;; Print winner
  (if (i32.ne (local.get $winner) (i32.const 0x30))
    (then
      (call $text (global.get $WINNER_TEXT) (i32.const 29) (i32.const 25))
    )
  )

  ;; Mid line
  (call $rect (i32.const 79) (i32.const 4) (i32.const 2) (i32.const 152))
)

(func $move_up (param $gamepad i32) (param $player i32) (result i32)
  (if (i32.and (local.get $gamepad) (global.get $BUTTON_UP))
    (then
      (if (i32.gt_s (local.get $player) (global.get $MIN_PADDLE))
        (then
          (return (i32.sub (local.get $player) (global.get $PADDLE_SPEED)))
      ))
    )
  )
  (return (local.get $player))
)

(func $move_down (param $gamepad i32) (param $player i32) (result i32)
  (if (i32.and (local.get $gamepad) (global.get $BUTTON_DOWN))
    (then
      (if (i32.lt_s (local.get $player) (global.get $MAX_PADDLE))
        (then
          (return (i32.add (local.get $player) (global.get $PADDLE_SPEED)))
      ))
    )
  )
  (return (local.get $player))
)

(func $hit_paddle (param $player i32) (param $ball_y i32) (result i32)
  (i32.and
    (i32.gt_s (local.get $ball_y) (i32.sub (local.get $player) (i32.const 4)))
    (i32.lt_s (local.get $ball_y) (i32.add (local.get $player) (i32.const 32)))
  )
)

(func $calc_ball_y_speed (param $ball_y i32) (param $player i32) (result i32)
  (i32.div_s
    (i32.sub
      (local.get $ball_y)
      (i32.add
        (local.get $player) (i32.const 14)
      )
    )
    (i32.const 6)
  )
)
