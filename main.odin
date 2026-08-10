package main

import "core:c"
import "core:fmt"
import rl "vendor:raylib"
WINDOW_WIDTH :: 1280
WINDOW_HEIGHT :: 720
GameState :: enum{
        Menu,
        Playing,
        GameeOver,
        PlayerWin,
    }

clampPaddle :: proc(paddle: ^rl.Rectangle){
    if paddle.y < 0 {
            paddle.y = 0
        }
        if paddle.y + paddle.height > WINDOW_HEIGHT{
            paddle.y = WINDOW_HEIGHT - paddle.height
        }
}

ballMove :: proc(ball: ^rl.Rectangle, speedX, speedY, dt: f32){
    ball.x -= speedX * dt
    ball.y -= speedY * dt
}

bounceBall :: proc(ball: ^rl.Rectangle, speedY: ^f32){
    
        if ball.y < 0 {
            ball.y = 0
            speedY^ = -speedY^
        }
        if ball.y + ball.height > WINDOW_HEIGHT {
            ball.y = WINDOW_HEIGHT - ball.height
            speedY^ = -speedY^
        }
    }

paddleController :: proc(paddle: ^rl.Rectangle,paddleSpeed, dt: f32){
    
    // Event handling
        if rl.IsKeyDown(.UP){
            paddle.y -= paddleSpeed * dt
        }
        if rl.IsKeyDown(.DOWN){
            paddle.y += paddleSpeed * dt
        }

}
enemyAI :: proc(ball: ^rl.Rectangle, enemy: ^ rl.Rectangle, speed: f32, dt: f32){
    enemyCenter := enemy.y + enemy.height / 2
    ballCenter := ball.y + ball.height / 2
    if ballCenter > enemyCenter{
        enemy.y += speed * dt


    }
    if ballCenter < enemyCenter{
        enemy.y -= speed * dt

    }

}
collisionChecker :: proc(ball: rl.Rectangle, playerCollision: rl.Rectangle, enemyCollision: rl.Rectangle, speedX: ^f32){
    if rl.CheckCollisionRecs(ball,playerCollision){
            speedX^ = -speedX^
           

        }
        if rl.CheckCollisionRecs(ball, enemyCollision){
            speedX^ = -speedX^

        }

}
scoreCalculation :: proc(ball: ^rl.Rectangle, playerScore: ^int, enemyScore: ^int){
    
    if ball.x  < 0  {
            enemyScore^ += 1
            ball.x =  WINDOW_WIDTH / 2 - 20 / 2
            ball.y = WINDOW_HEIGHT / 2 - 20 / 2
            
            
        }
        if ball.x > WINDOW_WIDTH {
            playerScore^ += 1
            ball.x = WINDOW_WIDTH / 2 - 20 / 2
            ball.y = WINDOW_HEIGHT / 2 - 20 / 2
            

        }

}
drawText :: proc (playerS: int, enemyS: int){
    scoreText := fmt.caprintf("Player: %d | Enemy: %d",playerS, enemyS)
    rl.DrawText(scoreText, 500, 0, 20, rl.BLACK)

}

resetGame :: proc(state: ^GameState){
    if rl.IsKeyDown(.R){
        state^ = .Playing
        
    }
}
main :: proc() {
    rl.InitWindow(WINDOW_WIDTH,WINDOW_HEIGHT, "My First Pong")
    rl.SetTargetFPS(60)
    


    playerPaddel := rl.Rectangle{ x = 10, y = WINDOW_HEIGHT / 2 - 120 / 2, width = 20, height = 120 }
    playerSpeed: f32 = 600;


    enemyPaddle := rl.Rectangle{ x = 1250, y = WINDOW_HEIGHT / 2 - 120 / 2, width = 20, height = 120 }
    enemySpeed: f32 = 200
    
    enemyScore := 0
    playerScore := 0


    ball := rl.Rectangle{ x = WINDOW_WIDTH / 2 - 20 / 2, y = WINDOW_HEIGHT / 2 - 20 / 2, width = 20, height = 20}
    ballSpeedX : f32 = 300
    ballSpeedY : f32 = 300
    
    state := GameState.Menu
    
   
    for !rl.WindowShouldClose(){
        dt := rl.GetFrameTime()
        switch state {
            case .Menu:
                if rl.IsKeyPressed(.SPACE){
                    state = .Playing
                }
            case .Playing:
                paddleController(&playerPaddel,playerSpeed,dt)
                ballMove(&ball, ballSpeedX,ballSpeedY, dt)
                clampPaddle(&playerPaddel)
                bounceBall(&ball, &ballSpeedY)
                enemyAI(&ball,&enemyPaddle,enemySpeed,dt)
                clampPaddle(&enemyPaddle)
                collisionChecker(ball,playerPaddel,enemyPaddle,&ballSpeedX)
                scoreCalculation(&ball,&playerScore, &enemyScore)
                if playerScore >= 5{
                    state = .PlayerWin
                    playerScore = 0
                    enemyScore = 0 
                }
                if enemyScore >= 5{
                    state = .GameeOver
                    playerScore = 0
                    enemyScore = 0
                }     
            case .PlayerWin:
                resetGame(&state)

            case .GameeOver:
                resetGame(&state)
        }    
        rl.BeginDrawing()
        rl.ClearBackground(rl.RAYWHITE)
        switch state{
            case .Menu:
                rl.DrawText("Press SPACE to Start", 400, 300, 30, rl.BLACK)
            case .Playing:
                rl.DrawRectangleRec(playerPaddel, rl.BLACK)
                rl.DrawRectangleRec(enemyPaddle, rl.BLACK)
                rl.DrawRectangleRec(ball, rl.BLACK)
                drawText(playerScore,enemyScore)
                rl.DrawFPS(10,10)
            case .PlayerWin:
                rl.DrawText("You Win! Press R to Restart", 350, 300, 30, rl.BLACK)
            case .GameeOver:
                rl.DrawText("Game Over! Press R to Restart", 350, 300, 30, rl.BLACK)
        }
        rl.EndDrawing()
    }
    rl.CloseWindow()
}