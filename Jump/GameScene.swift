//
//  GameScene.swift
//  Jump
//
//  Created by KSlusarczyk on 7/10/17.
//  Copyright © 2017 KSlusarczyk. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation //for sound

class GameScene: SKScene, SKPhysicsContactDelegate //needed for proper physics

{
    //nodes
    var backgroundMusicPlayer: AVAudioPlayer?
    var player: SKSpriteNode!
    var background: SKSpriteNode!
    var brick: SKSpriteNode!
    var loseZone:SKSpriteNode!
    var scoreBoard:SKLabelNode!
    var level:SKSpriteNode!
    var gameOver:SKLabelNode!
    var winner:SKLabelNode!
    var start:SKLabelNode!
    var click:SKLabelNode!
    var highScore:SKLabelNode!
    //variables
    var gamesOver = false
    var started = false
    var win = false
    var difficulty = 10
    var score = 0
    var highscore = 0
    
    //view did load
    override func didMove(to view: SKView)
    {
        physicsWorld.contactDelegate = self
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        createStart()
        playBackgroundMusic(filename: "music")
    }
    
    
    //contact began
    func didBegin(_ contact: SKPhysicsContact)
    {
        //if player comes in contact with the lose zone
        if contact.bodyA.node?.name == "loseZone" || contact.bodyB.node?.name == "loseZone"        {
           
            gamesOver = true
            print("lose")
            lose()
        }
        //if player comes in contact with the brick
        if contact.bodyA.node?.name == "brick" || contact.bodyB.node?.name == "brick"
        {
            
            //boosts player
            let jumpUpAction = SKAction.moveBy(x: 0 , y: 20, duration: 0.5)
            let jumpDownAction = SKAction.moveBy(x: 0, y: -20, duration: 0.5)
            let jumpSequence = SKAction.sequence([jumpUpAction,jumpDownAction])
            
            player.run(jumpSequence)
            print("floor")
            
            //score increases
            score += 10
            scoreBoard.removeFromParent()
            scoreKeep()
            print("score:\(score)")
        }
    }
    

    //tapping began
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        
        for touch in touches
        {
            let location = touch.location(in: self)
            
            //if tap to start was tapped
            if started == true
            {
            //jumping
            let jumpUpAction = SKAction.moveBy(x: location.x , y: location.y, duration: 0.5)
            let jumpDownAction = SKAction.moveBy(x: location.x, y: -location.y, duration: 0.5)
            let jumpSequence = SKAction.sequence([jumpUpAction,jumpDownAction])
            
            player.run(jumpSequence)
            
            
            //player touches side
            if self.player.position.x < self.frame.minX - (player.size.width / 2)
            {
                
                self.player.position.x = self.frame.maxX - (self.player.size.width / 2)
                
            }
                
            else if self.player.position.x > self.frame.maxX + (player.size.width / 2)
            {
                
                self.player.position.x = self.frame.minX + (self.player.size.width / 2)
            }
                //when game is over
                if gamesOver == true
                {
                    //gameover tapped to restart
                    if gameOver.contains(location)
                    {
                        score = 0
                        removeAllActions()
                        removeAllChildren()
                        gamesOver = false
                        createGame()
                        
                        
                    }
                }
                
                if win == true
                {
                    if winner.contains(location)
                    {
                        score = 0
                        removeAllActions()
                        removeAllChildren()
                        win = false
                        createGame()
                    }
                }
            
            }
            
            //start tapped
            if click.contains(location)
            {
                start.text = ""
                click.text = " "
                started = true
                createGame()
            }
            
        }
    }
    
    
    
    //creates falling bricks
    func makeBricks()
    {
        let blockWidth = (Int)((frame.width - 60)/5)
        let blockHight = 20
        let create = SKAction.run
        {
            
            self.makeBrick(yPoint: Int(self.frame.maxY), brickWidth: blockWidth, brickHight: blockHight)
        }
       
        let wait = SKAction.wait(forDuration: 2.0)
        
        if gamesOver == false
        {
        let sequence = SKAction.sequence([create,wait])
        run(SKAction.repeatForever(sequence))
        }
    }

    //brick shape
    func makeBrick(yPoint: Int, brickWidth: Int, brickHight: Int)
    {
        var xValues: [Int] = [-80, 0, 80, -120, 120]
        
        let randomIndex = Int(arc4random_uniform(UInt32(xValues.count)))

        brick = SKSpriteNode(color: UIColor.brown, size: CGSize(width: brickWidth, height: brickHight))
        brick.position = CGPoint(x: xValues[randomIndex], y: Int(frame.size.height))
        brick.zPosition = 10
        
        print(xValues)
        print(randomIndex)
        brick.name = "brick"
        
        
        brick.physicsBody = SKPhysicsBody(rectangleOf: brick.size)
        brick.physicsBody?.isDynamic = false
        brick.physicsBody?.usesPreciseCollisionDetection = true
        brick.physicsBody?.contactTestBitMask = (brick.physicsBody?.collisionBitMask)!

        addChild(brick)
        
        
        //moves bricks down
        let moveDown = SKAction.moveBy(x: 0, y: -frame.size.height, duration: TimeInterval(difficulty) )
        let moveForever = SKAction.repeatForever(moveDown)
        
        
        brick.run(moveForever)
        
    }
    
    //starting brick so doesnt fall immedietly on lose zone
    func startBrick()
    {
        brick = SKSpriteNode(color: UIColor.brown, size: CGSize(width: (Int)((frame.width - 60)/5), height: 20))
        brick.position = CGPoint(x: frame.midX, y: frame.maxY - 20)
        brick.name = "startbrick"
        brick.zPosition = 10
        
        
        brick.physicsBody = SKPhysicsBody(rectangleOf: brick.size)
        brick.physicsBody?.isDynamic = false
        brick.physicsBody?.usesPreciseCollisionDetection = true
        brick.physicsBody?.contactTestBitMask = (brick.physicsBody?.collisionBitMask)!
        
        addChild(brick)
        
        //moves down
        let moveDown = SKAction.moveBy(x: 0, y: -frame.size.height, duration: 10 )
        let moveForever = SKAction.repeatForever(moveDown)
        brick.run(moveForever)
    }
    
    //creates background going up
    func createBackground()
    {
        let dojo = SKTexture(image: #imageLiteral(resourceName: "Dojo"))
        
        for i in 0...1
        {
            background = SKSpriteNode(texture: dojo)
            background.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            background.position = CGPoint(x: 0, y: (background.size.height * CGFloat(i) - CGFloat(1 * i)))
            background.zPosition = 0
            
            
            addChild(background)
            
            
            //infinite moving background
            let moveDown = SKAction.moveBy(x: 0, y: -background.size.height, duration: 10)
            let moveReset = SKAction.moveBy(x: 0, y: background.size.height , duration: 0)
            let moveLoop = SKAction.sequence([moveDown, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            
            background.run(moveForever)
        }
    }
    
    //creates loze zone
    func createLoseZone()
    {
        loseZone = SKSpriteNode(color: UIColor.clear, size: CGSize(width: frame.width, height: 25))
        loseZone.position = CGPoint(x: frame.midX, y: frame.minY + 25)
        loseZone.name = "loseZone"
        loseZone.zPosition = 10
       
        
        loseZone.physicsBody = SKPhysicsBody(rectangleOf: loseZone.size)
        loseZone.physicsBody?.isDynamic = false
        loseZone.physicsBody?.usesPreciseCollisionDetection = true
        loseZone.physicsBody?.contactTestBitMask = (loseZone.physicsBody?.collisionBitMask)!
    
        addChild(loseZone)
    }
    
    //creates player
    func makePlayer()
    {
        let ninja = SKTexture(image: #imageLiteral(resourceName: "Ninja"))
        player = SKSpriteNode(texture: ninja, color: UIColor.black, size: CGSize(width: 50, height: 50))
        player.position = CGPoint(x: frame.midX, y: frame.maxY - 10)
        player.zPosition = 10
        
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.usesPreciseCollisionDetection = true
        player.physicsBody?.affectedByGravity = true
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.friction = 0
        player.physicsBody?.restitution = 1
        player.physicsBody?.angularDamping = 0
        player.physicsBody?.linearDamping = 0
        player.physicsBody?.contactTestBitMask = (player.physicsBody?.collisionBitMask)!
        
        addChild(player)
        
    }
    
    //creates game
    func createGame()
    {
        if gamesOver == false
        {
        startBrick()
        makeBricks()
        createBackground()
        createLoseZone()
        makePlayer()
        scoreKeep()
        difficulty = 10
        makeHighScore()
        }
     
    }
    
    //calls game over
    func lose()
    {
        gameOver = SKLabelNode(text: "Game Over")
        gameOver.position = CGPoint(x: frame.midX, y: frame.midY)
        gameOver.fontColor = UIColor.white
        removeAllActions()
        removeAllChildren()
        
        addChild(gameOver)
        addChild(scoreBoard)
        scoreBoard.position = CGPoint(x: frame.midX, y: frame.midY - 35)
        scoreBoard.fontColor = UIColor.white
    }
    
    
    //score board
    func scoreKeep()
    {
        scoreBoard = SKLabelNode(text: "Score: \(score)")
        scoreBoard.position = CGPoint(x: frame.minX + 80, y: frame.maxY - 50)
        scoreBoard.fontColor = UIColor.black
        scoreBoard.zPosition = 10
    
        
        if score == 50
        {
            difficulty -= 2
            print("diff:\(difficulty)")
        }
        if score == 100
        {
            difficulty -= 2
            print("diff:\(difficulty)")
        }
        if score == 150
        {
            difficulty -= 2
            print("diff:\(difficulty)")
        }
        if score == 200
        {
            difficulty -= 2
            print("diff:\(difficulty)")
        }
        if score == 250
        {
            winner = SKLabelNode(text: "You Win!")
            win = true
            winner.position = CGPoint(x: frame.midX, y: frame.midY)
            winner.fontColor = UIColor.white
            removeAllActions()
            removeAllChildren()
            addChild(winner)
        }
        
        //changes high score
        if (score > highscore)
        {
            highscore = score
            highScore.removeFromParent()
            addChild(highScore)
        }
        
        addChild(scoreBoard)
    }
    
    //creates start "screen"
    func createStart()
    {
        start = SKLabelNode(text: "Ninja Jump")
        start.position = CGPoint(x: frame.midX, y: frame.midY + 100)
        start.fontColor = UIColor.red
        click = SKLabelNode(text: "Tap to Start")
        click.position = CGPoint(x: frame.midX, y: frame.midY + 50)
        click.fontColor = UIColor.red
        
        
        addChild(start)
        addChild(click)
    }
    
    func makeHighScore()
    {
        highScore = SKLabelNode(text: "Highscore: \(highscore)")
        highScore.position = CGPoint(x: frame.maxX - 100, y: frame.maxY - 50)
        highScore.fontColor = UIColor.black
        highScore.fontSize = 28
        highScore.zPosition = 10
        
        addChild(highScore)
        
        
    }
    
    //background music
    func playBackgroundMusic(filename: String) {
        let url = Bundle.main.url(forResource: filename, withExtension: "mp3")
        guard let newURL = url else {
            print("Could not find file: \(filename)")
            return
        }
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: newURL)
            backgroundMusicPlayer?.numberOfLoops = -1 //infinite loop
            backgroundMusicPlayer?.prepareToPlay()
            backgroundMusicPlayer?.play()
        } catch let error as NSError {
            print(error.description)
        }
    }
    
}





    

