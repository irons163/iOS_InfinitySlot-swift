import SpriteKit
import UIKit

private let testLaba = false

private var isCanPressStartBtn = true
private var isCanPressStopBtn = false
private var eachFrameHeight: CGFloat = 1
private var scrollCount = 0
private var scrollCount2 = 0
private var scrollCount3 = 0
private var reelPosition1 = -1
private var reelPosition2 = -1
private var reelPosition3 = -1
private var isLabaStickRun = false
private var isLabaStick2Run = false
private var isLabaStick3Run = false

private let moneyCoin10 = 10
private let moneyCoin30 = 30
private let moneyCoin50 = 50
private let moneyInitValue = 5000
private let moneyInitEveryday = 5000

private var currentMoneyLevel = 10
private var currentMoney = moneyInitValue

private let displayADPerTimes = 3
private var displayADCount = 1
private var isFocusStopFallWithCoinsRun = false

private var isAutoStop = false

private let autoStopTimeMs = 5000
private var firstStopTimeMs = autoStopTimeMs
private var secondStopTimeMs = autoStopTimeMs
private var thirdStopTimeMs = autoStopTimeMs

private let delayTimePerLabaStickMinMs = 500
private let delayTimePerLabaStickMaxMs = 1000

private let winLTFrame = 0
private let winTopFrame = 1
private let winRTFrame = 2
private let winLeftFrame = 3
private let winCenterFrame = 4
private let winRightFrame = 5
private let winLBFrame = 6
private let winBottomFrame = 7
private let winRBFrame = 8

private let winMidLine = 0
private let winLTtoRBLine = 1
private let winLBtoRTLine = 2

private let normalTextureIndex = 0
private let pressedTextureIndex = 1

private let moneyFieldKey = "money"

private let fallWithCoinsNumber = 30

private func colorFromRGB(_ rgbValue: Int) -> UIColor {
    let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
    let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
    let blue = CGFloat((rgbValue & 0x0000FF) >> 0) / 255.0
    return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
}

private final class MyTimer {
    private var isStopTheAutoStop = false
    private weak var scene: MyScene?

    init(scene: MyScene) {
        self.scene = scene
        DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + .milliseconds(autoStopTimeMs)) { [weak self] in
            guard let self = self, !self.isStopTheAutoStop else { return }
            for i in 0..<3 {
                if i == 0 {
                    isAutoStop = true
                    self.scene?.stop()
                } else if i == 1 {
                    usleep(useconds_t(secondStopTimeMs * 1000))
                    isAutoStop = true
                    self.scene?.stop()
                } else if i == 2 {
                    usleep(useconds_t(thirdStopTimeMs * 1000))
                    isAutoStop = true
                    self.scene?.stop()
                }
            }
        }
    }

    func stop() {
        isStopTheAutoStop = true
    }
}

final class MyScene: SKScene {
    typealias GameOverDialog = (Int, Int) -> Void
    typealias SimpleCallback = () -> Void

    var onGameOver: GameOverDialog?
    var showAdmob: SimpleCallback?
    var showBuyViewController: SimpleCallback?
    var showRankView: SimpleCallback?
    var showHintView: SimpleCallback?

    var lastSpawnTimeInterval: TimeInterval = 0
    var lastUpdateTimeInterval: TimeInterval = 0

    private var screenWidth = 0
    private var screenHeight = 0
    private var ccount = 0
    private var labaStickAppearPartHeight: CGFloat = 0
    private var labaStickCropNodeMaskY: CGFloat = 0

    private var backgroundNode = SKSpriteNode()
    private var labaFrameNode = SKSpriteNode()
    private var labaStickNode = SKSpriteNode()
    private var labaStickNode2 = SKSpriteNode()
    private var labaStickNode3 = SKSpriteNode()
    private var labaStickCropNode = SKCropNode()
    private var labaStickCropNode2 = SKCropNode()
    private var labaStickCropNode3 = SKCropNode()
    private var startBtn = SKSpriteNode()
    private var stopBtn = SKSpriteNode()
    private var labaHole = SKSpriteNode()
    private var coin10Btn = SKSpriteNode()
    private var coin30Btn = SKSpriteNode()
    private var coin50Btn = SKSpriteNode()
    private var myAdView = MyADView()
    private var storeBtn = SKSpriteNode()
    private var commonUtil = CommonUtil.shared
    private var currentMoneyNode = SKSpriteNode()

    private var winFrameArray: [SKSpriteNode] = []
    private var winLineArray: [SKSpriteNode] = []

    private var storeBtnClickTextureArray: [SKTexture] = []
    private var coin10BtnClickTextureArray: [SKTexture] = []
    private var coin30BtnClickTextureArray: [SKTexture] = []
    private var coin50BtnClickTextureArray: [SKTexture] = []
    private var stopBtnClickTextureArray: [SKTexture] = []
    private var startBtnClickTextureArray: [SKTexture] = []

    private var textViewMoneyLevel = SKLabelNode()
    private var textViewCurrentMoneyLevel = SKLabelNode()
    private var textViewMoney = SKLabelNode()
    private var textViewCurrentMoney = SKLabelNode()

    private var coin10BtnOriginPosition = CGPoint.zero
    private var coin30BtnOriginPosition = CGPoint.zero
    private var coin50BtnOriginPosition = CGPoint.zero

    private var fallWithCoins: [SKSpriteNode] = []
    private var fallWithCoinsY: [NSNumber] = []

    private var rankBtn = SKSpriteNode()
    private var hintBtn = SKSpriteNode()

    private var timer: MyTimer?
    private var lineCount = 0

    override init(size: CGSize) {
        super.init(size: size)

        commonUtil = CommonUtil.shared

        MyUtils.playBackgroundMusic("laba.mp3")

        loadMoney()
        makeUpMoney()

        backgroundNode = SKSpriteNode(imageNamed: "laba_bg.jpg")
        backgroundNode.size = CGSize(width: frame.size.width, height: frame.size.height)
        backgroundNode.position = CGPoint(x: 0, y: 0)
        backgroundNode.anchorPoint = CGPoint(x: 0, y: 0)
        addChild(backgroundNode)

        myAdView = MyADView(texture: nil)
        myAdView.size = CGSize(width: 200, height: 55)
        myAdView.position = CGPoint(x: frame.size.width / 2, y: frame.size.height - 35)
        myAdView.startAd()
        addChild(myAdView)

        storeBtn = SKSpriteNode(imageNamed: "store1")
        storeBtn.size = CGSize(width: (size.width - myAdView.size.width) / 2.0, height: myAdView.size.height)
        storeBtn.position = CGPoint(x: myAdView.position.x + myAdView.size.width / 2.0 + storeBtn.size.width / 2.0, y: myAdView.position.y)
        addChild(storeBtn)

        rankBtn = SKSpriteNode(imageNamed: "leader_board_btn")
        rankBtn.size = CGSize(width: (size.width - myAdView.size.width) / 2.0, height: myAdView.size.height)
        rankBtn.position = CGPoint(x: rankBtn.size.width / 2.0, y: myAdView.position.y)
        addChild(rankBtn)

        labaFrameNode = SKSpriteNode(imageNamed: "laba_fg")
        labaFrameNode.size = CGSize(width: frame.size.width, height: frame.size.height)
        labaFrameNode.position = CGPoint(x: 0, y: 0)
        labaFrameNode.anchorPoint = CGPoint(x: 0, y: 0)
        addChild(labaFrameNode)

        labaStickNode = SKSpriteNode(imageNamed: "lol_laba2.jpg")
        labaStickNode.anchorPoint = CGPoint(x: 0, y: 1)
        labaStickNode.position = CGPoint(x: (frame.size.width - frame.size.width / 3.6 * 3) / 2.0, y: myAdView.position.y - myAdView.size.height / 2.0 - 5)
        labaStickNode.size = CGSize(width: frame.size.width / 3.6, height: frame.size.height * 2)

        labaStickNode2 = SKSpriteNode(imageNamed: "lol_laba2.jpg")
        labaStickNode2.anchorPoint = CGPoint(x: 0, y: 1)
        labaStickNode2.position = CGPoint(x: labaStickNode.position.x + labaStickNode.size.width, y: myAdView.position.y - myAdView.size.height / 2.0 - 5)
        labaStickNode2.size = CGSize(width: frame.size.width / 3.6, height: frame.size.height * 2)

        labaStickNode3 = SKSpriteNode(imageNamed: "lol_laba2.jpg")
        labaStickNode3.anchorPoint = CGPoint(x: 0, y: 1)
        labaStickNode3.position = CGPoint(x: labaStickNode.position.x + labaStickNode.size.width * 2, y: myAdView.position.y - myAdView.size.height / 2.0 - 5)
        labaStickNode3.size = CGSize(width: frame.size.width / 3.6, height: frame.size.height * 2)

        startBtn = SKSpriteNode(imageNamed: "start_btn1")
        if UIScreen.main.bounds.size.height > 480.0 {
            startBtn.size = CGSize(width: 100, height: 100)
            startBtn.position = CGPoint(x: size.width / 2.0, y: startBtn.size.height / 2.0 + 50)
        } else {
            startBtn.size = CGSize(width: 60, height: 60)
            startBtn.position = CGPoint(x: startBtn.size.width * 2, y: startBtn.size.height / 2.0 + 50)
        }
        addChild(startBtn)

        stopBtn = SKSpriteNode(imageNamed: "stop_btn1")
        if UIScreen.main.bounds.size.height > 480.0 {
            stopBtn.size = CGSize(width: 100, height: 100)
            stopBtn.position = CGPoint(x: size.width / 2.0 - startBtn.size.width, y: stopBtn.size.height / 2.0 + 50)
        } else {
            stopBtn.size = CGSize(width: 60, height: 60)
            stopBtn.position = CGPoint(x: startBtn.position.x - startBtn.size.width, y: stopBtn.size.height / 2.0 + 50)
        }
        addChild(stopBtn)

        labaHole = SKSpriteNode(imageNamed: "money_in_bar.jpg")
        labaHole.size = CGSize(width: 30, height: 100)
        labaHole.position = CGPoint(x: 15, y: stopBtn.position.y + stopBtn.size.height / 2.0 + labaHole.size.height / 2.0 + 20)
        let disappearX = labaHole.position.x
        addChild(labaHole)

        coin10Btn = SKSpriteNode(imageNamed: "coin_10_btn01")
        coin10Btn.size = CGSize(width: 80, height: 80)
        coin10Btn.position = CGPoint(x: labaHole.position.x + labaHole.size.width / 2.0 + coin10Btn.size.width / 2.0, y: labaHole.position.y)
        coin10BtnOriginPosition = coin10Btn.position

        var coinMaskDisplaySize = CGSize(width: (coin10Btn.position.x - disappearX) * 2, height: coin10Btn.size.height)
        var coinMask = SKSpriteNode(color: .white, size: coinMaskDisplaySize)
        coinMask.anchorPoint = coin10Btn.anchorPoint
        coinMask.position = coin10Btn.position
        var coinCropNode = SKCropNode()
        coinCropNode.addChild(coin10Btn)
        coinCropNode.maskNode = coinMask
        addChild(coinCropNode)

        coin30Btn = SKSpriteNode(imageNamed: "coin_30_btn01")
        coin30Btn.size = CGSize(width: 80, height: 80)
        coin30Btn.position = CGPoint(x: coin10Btn.position.x + coin30Btn.size.width, y: labaHole.position.y)
        coin30BtnOriginPosition = coin30Btn.position
        coinMaskDisplaySize = CGSize(width: (coin30Btn.position.x - disappearX) * 2, height: coin30Btn.size.height)
        coinMask = SKSpriteNode(color: .white, size: coinMaskDisplaySize)
        coinMask.anchorPoint = coin30Btn.anchorPoint
        coinMask.position = coin30Btn.position
        coinCropNode = SKCropNode()
        coinCropNode.addChild(coin30Btn)
        coinCropNode.maskNode = coinMask
        addChild(coinCropNode)

        coin50Btn = SKSpriteNode(imageNamed: "coin_50_btn01")
        coin50Btn.size = CGSize(width: 80, height: 80)
        coin50Btn.position = CGPoint(x: coin30Btn.position.x + coin50Btn.size.width, y: labaHole.position.y)
        coin50BtnOriginPosition = coin50Btn.position
        coinMaskDisplaySize = CGSize(width: (coin50Btn.position.x - disappearX) * 2, height: coin50Btn.size.height)
        coinMask = SKSpriteNode(color: .white, size: coinMaskDisplaySize)
        coinMask.anchorPoint = coin50Btn.anchorPoint
        coinMask.position = coin50Btn.position
        coinCropNode = SKCropNode()
        coinCropNode.addChild(coin50Btn)
        coinCropNode.maskNode = coinMask
        addChild(coinCropNode)

        labaStickAppearPartHeight = labaStickNode.size.height / 15.0 * 3
        eachFrameHeight = labaStickNode.size.height / 15.0

        let displaySize = CGSize(width: labaStickNode.size.width, height: labaStickAppearPartHeight)
        let mask = SKSpriteNode(color: .white, size: displaySize)
        mask.anchorPoint = labaStickNode.anchorPoint
        mask.position = labaStickNode.position
        labaStickCropNodeMaskY = labaStickNode.position.y

        labaStickCropNode = SKCropNode()
        labaStickCropNode.addChild(labaStickNode)
        labaStickCropNode.maskNode = mask
        addChild(labaStickCropNode)

        let mask2 = SKSpriteNode(color: .white, size: displaySize)
        mask2.anchorPoint = labaStickNode2.anchorPoint
        mask2.position = labaStickNode2.position
        labaStickCropNode2 = SKCropNode()
        labaStickCropNode2.addChild(labaStickNode2)
        labaStickCropNode2.maskNode = mask2
        addChild(labaStickCropNode2)

        let mask3 = SKSpriteNode(color: .white, size: displaySize)
        mask3.anchorPoint = labaStickNode3.anchorPoint
        mask3.position = labaStickNode3.position
        labaStickCropNode3 = SKCropNode()
        labaStickCropNode3.addChild(labaStickNode3)
        labaStickCropNode3.maskNode = mask3
        addChild(labaStickCropNode3)

        textViewMoneyLevel = SKLabelNode(fontNamed: "Chalkduster")
        textViewMoneyLevel.fontSize = 15
        textViewMoneyLevel.fontColor = colorFromRGB(0x77FFEE)
        textViewMoneyLevel.position = CGPoint(x: stopBtn.position.x - stopBtn.size.width / 3.0, y: stopBtn.position.y + stopBtn.frame.size.height / 2.0)
        textViewMoneyLevel.text = NSLocalizedString("Level", comment: "")
        addChild(textViewMoneyLevel)

        textViewCurrentMoneyLevel = SKLabelNode(fontNamed: "Chalkduster")
        textViewCurrentMoneyLevel.fontSize = 15
        textViewCurrentMoneyLevel.fontColor = colorFromRGB(0xBBFF66)
        textViewCurrentMoneyLevel.text = "\(currentMoneyLevel)"
        textViewCurrentMoneyLevel.position = CGPoint(x: textViewMoneyLevel.position.x + textViewMoneyLevel.frame.size.width / 2 + textViewCurrentMoneyLevel.frame.size.width / 2, y: textViewMoneyLevel.position.y)
        addChild(textViewCurrentMoneyLevel)

        let money = SKSpriteNode()
        money.anchorPoint = CGPoint(x: 0, y: 0)
        addChild(money)

        textViewMoney = SKLabelNode(fontNamed: "Chalkduster")
        textViewMoney.fontSize = 15
        textViewMoney.fontColor = colorFromRGB(0x77FFEE)
        textViewMoney.text = NSLocalizedString("Coin", comment: "")
        money.position = CGPoint(x: textViewCurrentMoneyLevel.position.x + textViewCurrentMoneyLevel.frame.size.width + textViewMoney.frame.size.width / 2, y: startBtn.position.y + startBtn.frame.size.height / 2.0)
        money.addChild(textViewMoney)

        currentMoneyNode = SKSpriteNode()
        currentMoneyNode.anchorPoint = CGPoint(x: 0, y: 0)
        addChild(currentMoneyNode)

        textViewCurrentMoney = SKLabelNode(fontNamed: "Chalkduster")
        textViewCurrentMoney.fontSize = 15
        textViewCurrentMoney.fontColor = colorFromRGB(0xBBFF66)
        textViewCurrentMoney.text = "\(currentMoney)"
        currentMoneyNode.position = CGPoint(x: money.position.x + textViewMoney.frame.size.width / 2 + textViewCurrentMoney.frame.size.width / 2, y: money.position.y)
        currentMoneyNode.addChild(textViewCurrentMoney)

        hintBtn = SKSpriteNode(imageNamed: "btn_guide_hd")
        hintBtn.size = CGSize(width: 35, height: 35)
        hintBtn.anchorPoint = CGPoint(x: 0, y: 0)
        hintBtn.position = CGPoint(x: coin50Btn.position.x + coin50Btn.size.width / 2.0, y: coin50Btn.position.y)
        addChild(hintBtn)

        initWinFrameAndLine()
        initClickTextureArrays()
        initFallWithCoins()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func initClickTextureArrays() {
        storeBtnClickTextureArray = [SKTexture(imageNamed: "store1"), SKTexture(imageNamed: "store2")]
        coin10BtnClickTextureArray = [SKTexture(imageNamed: "coin_10_btn01"), SKTexture(imageNamed: "coin_10_btn02")]
        coin30BtnClickTextureArray = [SKTexture(imageNamed: "coin_30_btn01"), SKTexture(imageNamed: "coin_30_btn02")]
        coin50BtnClickTextureArray = [SKTexture(imageNamed: "coin_50_btn01"), SKTexture(imageNamed: "coin_50_btn02")]
        stopBtnClickTextureArray = [SKTexture(imageNamed: "stop_btn1"), SKTexture(imageNamed: "stop_btn2")]
        startBtnClickTextureArray = [SKTexture(imageNamed: "start_btn1"), SKTexture(imageNamed: "start_btn2")]
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        makeUpMoney()

        if coin10Btn.calculateAccumulatedFrame().contains(location) {
            if !isAutoStop && isCanPressStartBtn {
                currentMoneyLevel = moneyCoin10
                textViewCurrentMoneyLevel.text = "\(currentMoneyLevel)"
            }
            coin10Btn.texture = coin10BtnClickTextureArray[pressedTextureIndex]
        } else if coin30Btn.calculateAccumulatedFrame().contains(location) {
            if !isAutoStop && isCanPressStartBtn {
                currentMoneyLevel = moneyCoin30
                textViewCurrentMoneyLevel.text = "\(currentMoneyLevel)"
            }
            coin30Btn.texture = coin30BtnClickTextureArray[pressedTextureIndex]
        } else if coin50Btn.calculateAccumulatedFrame().contains(location) {
            if !isAutoStop && isCanPressStartBtn {
                currentMoneyLevel = moneyCoin50
                textViewCurrentMoneyLevel.text = "\(currentMoneyLevel)"
            }
            coin50Btn.texture = coin50BtnClickTextureArray[pressedTextureIndex]
        } else if stopBtn.calculateAccumulatedFrame().contains(location) {
            stopBtn.texture = stopBtnClickTextureArray[pressedTextureIndex]
            isAutoStop = false
            stop()
        } else if startBtn.calculateAccumulatedFrame().contains(location) {
            startBtn.texture = startBtnClickTextureArray[pressedTextureIndex]
            start()
        } else if myAdView.calculateAccumulatedFrame().contains(location) {
            myAdView.doClick()
        } else if storeBtn.calculateAccumulatedFrame().contains(location) {
            storeBtn.texture = storeBtnClickTextureArray[pressedTextureIndex]
            displayBuyView()
        } else if rankBtn.calculateAccumulatedFrame().contains(location) {
            showRankView?()
        } else if hintBtn.calculateAccumulatedFrame().contains(location) {
            showHintView?()
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        storeBtn.texture = storeBtnClickTextureArray[normalTextureIndex]
        coin10Btn.texture = coin10BtnClickTextureArray[normalTextureIndex]
        coin30Btn.texture = coin30BtnClickTextureArray[normalTextureIndex]
        coin50Btn.texture = coin50BtnClickTextureArray[normalTextureIndex]
        stopBtn.texture = stopBtnClickTextureArray[normalTextureIndex]
        startBtn.texture = startBtnClickTextureArray[normalTextureIndex]
    }

    private func initWinFrameAndLine() {
        winFrameArray = []
        for i in 0..<3 {
            for j in 0..<3 {
                let winFrameNode = SKSpriteNode(imageNamed: "win_frame")
                winFrameNode.size = CGSize(width: labaStickNode.size.width, height: eachFrameHeight)
                winFrameNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                winFrameNode.position = CGPoint(x: labaStickNode.position.x + labaStickNode.size.width / 2.0 * CGFloat(j * 2 + 1), y: labaStickCropNodeMaskY - eachFrameHeight / 2.0 * CGFloat(i * 2 + 1))
                winFrameNode.isHidden = true
                winFrameArray.append(winFrameNode)
                addChild(winFrameNode)
            }
        }

        winLineArray = []
        for i in 0..<3 {
            let winLineNode = SKSpriteNode(color: .red, size: CGSize(width: labaStickNode.size.width * 3, height: eachFrameHeight / 20.0))
            winLineNode.position = CGPoint(x: labaStickNode2.position.x + labaStickNode2.size.width / 2.0, y: labaStickCropNodeMaskY - eachFrameHeight * 1.5)
            if i == winLTtoRBLine {
                winLineNode.zRotation = -CGFloat.pi / 4.0
            } else if i == winLBtoRTLine {
                winLineNode.zRotation = CGFloat.pi / 4.0
            }
            winLineNode.isHidden = true
            winLineArray.append(winLineNode)
            addChild(winLineNode)
        }
    }

    private func hideWinFrameAndLine() {
        for node in winFrameArray { node.isHidden = true }
        for node in winLineArray { node.isHidden = true }
    }

    private let scollActionTag1 = "01"
    private let scollActionTag2 = "02"
    private let scollActionTag3 = "03"

    private func start() {
        isLabaStickRun = true
        isLabaStick2Run = true
        isLabaStick3Run = true

        if !isCanPressStartBtn { return }
        isCanPressStartBtn = false

        if (currentMoney - currentMoneyLevel) < 0 {
            displayBuyView()
            isCanPressStartBtn = true
            return
        }

        if !commonUtil.isPurchased && displayADCount >= displayADPerTimes {
            displayAD()
            isCanPressStartBtn = true
            displayADCount = 1
            return
        }

        displayADCount += 1
        isFocusStopFallWithCoinsRun = true
        focusStopFallWithCoinsRun()

        hideWinFrameAndLine()
        costMoneyWithCurrentMoneyLevel()

        let rotation = SKAction.repeat(SKAction.rotate(byAngle: 10, duration: 1.5), count: 1)
        let move = SKAction.moveTo(x: labaHole.position.x - coin10Btn.size.width, duration: 1.5)
        let end = SKAction.run { [weak self] in
            guard let self = self else { return }
            self.coin10Btn.removeAllActions()
            self.coin30Btn.removeAllActions()
            self.coin50Btn.removeAllActions()
            self.coin10Btn.zRotation = 0
            self.coin30Btn.zRotation = 0
            self.coin50Btn.zRotation = 0
            self.coin10Btn.position = self.coin10BtnOriginPosition
            self.coin30Btn.position = self.coin30BtnOriginPosition
            self.coin50Btn.position = self.coin50BtnOriginPosition

            DispatchQueue.global(qos: .default).async {
                for i in 0..<3 {
                    self.lineCount += 1
                    if self.lineCount == 1 {
                        self.scoll()
                    } else if self.lineCount == 2 {
                        secondStopTimeMs = self.getDelayTimePerLabaStick()
                        usleep(useconds_t(secondStopTimeMs * 1000))
                        self.scoll2()
                    } else if self.lineCount == 3 {
                        thirdStopTimeMs = self.getDelayTimePerLabaStick()
                        usleep(useconds_t(thirdStopTimeMs * 1000))
                        self.scoll3()
                    }
                }

                reelPosition1 = -1
                reelPosition2 = -1
                reelPosition3 = -1
                isCanPressStartBtn = false
                isCanPressStopBtn = true

                reelPosition1 = -1
                reelPosition2 = -1
                reelPosition3 = -1
                isCanPressStopBtn = true
                self.doAutoStopLabaStick()
            }
        }

        if currentMoneyLevel == moneyCoin10 {
            coin10Btn.run(SKAction.sequence([SKAction.group([rotation, move]), end]))
        } else if currentMoneyLevel == moneyCoin30 {
            coin30Btn.run(SKAction.sequence([SKAction.group([rotation, move]), end]))
        } else {
            coin50Btn.run(SKAction.sequence([SKAction.group([rotation, move]), end]))
        }
    }

    private func scoll() {
        let a = labaStickAppearPartHeight
        let b = labaStickNode.size.height
        let c = labaStickCropNodeMaskY

        let wait = SKAction.wait(forDuration: 0.06)
        let end2 = SKAction.run { [weak self] in
            guard let self = self else { return }
            if a > 0 && isLabaStickRun {
                self.labaStickNode.position = CGPoint(x: self.labaStickNode.position.x, y: self.labaStickNode.position.y + 30)
                scrollCount += 1
                if self.labaStickNode.position.y >= (c + b - a) {
                    self.labaStickNode.position = CGPoint(x: self.labaStickNode.position.x, y: c + (self.labaStickNode.position.y - (c + b - a)))
                    scrollCount = 0
                }
            }
        }
        run(SKAction.repeatForever(SKAction.sequence([end2, wait])), withKey: scollActionTag1)
    }

    private func scoll2() {
        let a = labaStickAppearPartHeight
        let b = labaStickNode.size.height
        let c = labaStickCropNodeMaskY

        let wait = SKAction.wait(forDuration: 0.06)
        let end2 = SKAction.run { [weak self] in
            guard let self = self else { return }
            if a > 0 && isLabaStick2Run {
                self.labaStickNode2.position = CGPoint(x: self.labaStickNode2.position.x, y: self.labaStickNode2.position.y + 30)
                scrollCount2 += 1
                if self.labaStickNode2.position.y >= (c + b - a) {
                    self.labaStickNode2.position = CGPoint(x: self.labaStickNode2.position.x, y: c + (self.labaStickNode2.position.y - (c + b - a)))
                    scrollCount2 = 0
                }
            }
        }
        run(SKAction.repeatForever(SKAction.sequence([end2, wait])), withKey: scollActionTag2)
    }

    private func scoll3() {
        let a = labaStickAppearPartHeight
        let b = labaStickNode.size.height
        let c = labaStickCropNodeMaskY

        let wait = SKAction.wait(forDuration: 0.06)
        let end2 = SKAction.run { [weak self] in
            guard let self = self else { return }
            if a > 0 && isLabaStick3Run {
                self.labaStickNode3.position = CGPoint(x: self.labaStickNode3.position.x, y: self.labaStickNode3.position.y + 30)
                scrollCount3 += 1
                if self.labaStickNode3.position.y >= (c + b - a) {
                    self.labaStickNode3.position = CGPoint(x: self.labaStickNode3.position.x, y: c + (self.labaStickNode3.position.y - (c + b - a)))
                    scrollCount3 = 0
                }
            }
        }
        run(SKAction.repeatForever(SKAction.sequence([end2, wait])), withKey: scollActionTag3)
    }

    private func doAutoStopLabaStick() {
        timer?.stop()
        timer = MyTimer(scene: self)
    }

    func stop() {
        if isCanPressStartBtn || !isCanPressStopBtn { return }
        doAutoStopLabaStick()

        if lineCount == 3 {
            isLabaStickRun = false
            removeAction(forKey: scollActionTag1)
            reelPosition1 = Int(round((labaStickNode.position.y - labaStickCropNodeMaskY) / eachFrameHeight))
            labaStickNode.position = CGPoint(x: labaStickNode.position.x, y: CGFloat(reelPosition1) * eachFrameHeight + labaStickCropNodeMaskY)
        } else if lineCount == 2 {
            isLabaStick2Run = false
            removeAction(forKey: scollActionTag2)
            reelPosition2 = Int(round((labaStickNode2.position.y - labaStickCropNodeMaskY) / eachFrameHeight))
            labaStickNode2.position = CGPoint(x: labaStickNode2.position.x, y: CGFloat(reelPosition2) * eachFrameHeight + labaStickCropNodeMaskY)
        } else if lineCount == 1 {
            isLabaStick3Run = false
            removeAction(forKey: scollActionTag3)
            reelPosition3 = Int(round((labaStickNode3.position.y - labaStickCropNodeMaskY) / eachFrameHeight))
            labaStickNode3.position = CGPoint(x: labaStickNode3.position.x, y: CGFloat(reelPosition3) * eachFrameHeight + labaStickCropNodeMaskY)
        }
        lineCount -= 1

        if reelPosition1 == -1 || reelPosition2 == -1 || reelPosition3 == -1 { return }

        if testLaba { test() }

        var bigWin = false
        var isWin = false
        var winMoney = 0

        if !(reelPosition1 == reelPosition2 && reelPosition2 == reelPosition3) &&
            !(reelPosition1 - 1 == reelPosition2 && reelPosition2 - 1 == reelPosition3) &&
            !(reelPosition1 + 1 == reelPosition2 && reelPosition2 + 1 == reelPosition3) &&
            !(reelPosition1 == 2 && reelPosition2 == 1) &&
            !(reelPosition2 == 1 && reelPosition3 == 2) &&
            !(reelPosition1 == 1 && reelPosition2 == 2) &&
            !(reelPosition2 == 2 && reelPosition3 == 1) {
            if reelPosition1 == 0 || reelPosition1 == 1 { reelPosition1 += 12 }
            if reelPosition2 == 0 || reelPosition2 == 1 { reelPosition2 += 12 }
            if reelPosition3 == 0 || reelPosition3 == 1 { reelPosition3 += 12 }
        }

        if reelPosition1 == reelPosition2 && reelPosition2 == reelPosition3 {
            winFrameArray[winLeftFrame].isHidden = false
            winFrameArray[winCenterFrame].isHidden = false
            winFrameArray[winRightFrame].isHidden = false
            winLineArray[winMidLine].isHidden = false
            winMoney = RuleUtil.getPrizeFactorBy3Connect(reelPosition2, money: currentMoneyLevel)
            bigWin = RuleUtil.isBigWin(reelPosition2)
            if bigWin {
                onGameOver?(10, 10)
                isAutoStop = false
            }
            isWin = true
        } else if reelPosition1 - 1 == reelPosition2 && reelPosition2 - 1 == reelPosition3 {
            winFrameArray[winLTFrame].isHidden = false
            winFrameArray[winCenterFrame].isHidden = false
            winFrameArray[winRBFrame].isHidden = false
            winLineArray[winLTtoRBLine].isHidden = false
            winMoney = RuleUtil.getPrizeFactorBy3Connect(reelPosition2, money: currentMoneyLevel)
            bigWin = RuleUtil.isBigWin(reelPosition2)
            if bigWin {
                onGameOver?(10, 10)
                isAutoStop = false
            }
            isWin = true
        } else if reelPosition1 + 1 == reelPosition2 && reelPosition2 + 1 == reelPosition3 {
            winFrameArray[winLBFrame].isHidden = false
            winFrameArray[winCenterFrame].isHidden = false
            winFrameArray[winRTFrame].isHidden = false
            winLineArray[winLBtoRTLine].isHidden = false
            winMoney = RuleUtil.getPrizeFactorBy3Connect(reelPosition2, money: currentMoneyLevel)
            bigWin = RuleUtil.isBigWin(reelPosition2)
            if bigWin {
                onGameOver?(10, 10)
                isAutoStop = false
            }
            isWin = true
        } else if reelPosition1 == reelPosition2 && reelPosition2 != reelPosition3 {
            winFrameArray[winLeftFrame].isHidden = false
            winFrameArray[winCenterFrame].isHidden = false
            winMoney = RuleUtil.getPrizeFactorBy2Connect(currentMoneyLevel)
            isWin = true
        } else if reelPosition2 == reelPosition3 && reelPosition1 != reelPosition2 {
            winFrameArray[winCenterFrame].isHidden = false
            winFrameArray[winRightFrame].isHidden = false
            winMoney = RuleUtil.getPrizeFactorBy2Connect(currentMoneyLevel)
            isWin = true
        } else if reelPosition1 - 1 == reelPosition2 && reelPosition2 - 1 != reelPosition3 {
            winFrameArray[winLTFrame].isHidden = false
            winFrameArray[winCenterFrame].isHidden = false
            winMoney = RuleUtil.getPrizeFactorBy2Connect(currentMoneyLevel)
            isWin = true
        } else if reelPosition2 - 1 == reelPosition3 && reelPosition1 - 1 != reelPosition2 {
            winFrameArray[winCenterFrame].isHidden = false
            winFrameArray[winRBFrame].isHidden = false
            winMoney = RuleUtil.getPrizeFactorBy2Connect(currentMoneyLevel)
            isWin = true
        } else if reelPosition1 + 1 == reelPosition2 && reelPosition2 + 1 != reelPosition3 {
            winFrameArray[winLBFrame].isHidden = false
            winFrameArray[winCenterFrame].isHidden = false
            winMoney = RuleUtil.getPrizeFactorBy2Connect(currentMoneyLevel)
            isWin = true
        } else if reelPosition2 + 1 == reelPosition3 && reelPosition1 + 1 != reelPosition2 {
            winFrameArray[winCenterFrame].isHidden = false
            winFrameArray[winRTFrame].isHidden = false
            winMoney = RuleUtil.getPrizeFactorBy2Connect(currentMoneyLevel)
            isWin = true
        }

        currentMoney += winMoney
        let w = textViewCurrentMoney.frame.size.width
        textViewCurrentMoney.text = "\(currentMoney)"
        currentMoneyNode.position = CGPoint(x: currentMoneyNode.position.x - w / 2 + textViewCurrentMoney.frame.size.width / 2, y: currentMoneyNode.position.y)

        MyScene.saveMoney()
        reportScore()

        var delayTime = 0
        if isWin {
            delayTime = 3500
            winWithFallCoins()
        } else {
            delayTime = 500
        }

        if isAutoStop && !bigWin {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(delayTime)) { [weak self] in
                self?.start()
            }
        }

        timer?.stop()
        isCanPressStartBtn = true
        isCanPressStopBtn = false
    }

    private func loadMoney() {
        let userDefaults = UserDefaults.standard
        currentMoney = userDefaults.integer(forKey: moneyFieldKey)
        if testLaba { currentMoney = 10 }
    }

    static func saveMoney() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(currentMoney, forKey: moneyFieldKey)
        userDefaults.synchronize()
    }

    private func getDelayTimePerLabaStick() -> Int {
        return Int(arc4random_uniform(UInt32(delayTimePerLabaStickMaxMs - delayTimePerLabaStickMinMs + 1))) + delayTimePerLabaStickMinMs
    }

    private func initFallWithCoins() {
        fallWithCoins = []
        fallWithCoinsY = Array(repeating: 0, count: fallWithCoinsNumber)

        for i in 0..<fallWithCoinsNumber {
            let fallWithCoin = SKSpriteNode(texture: nil)
            fallWithCoin.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            if i % 3 == 0 {
                fallWithCoin.texture = SKTexture(imageNamed: "coin_50_btn01")
            } else if i % 3 == 1 {
                fallWithCoin.texture = SKTexture(imageNamed: "coin_30_btn01")
            } else {
                fallWithCoin.texture = SKTexture(imageNamed: "coin_10_btn01")
            }

            fallWithCoin.size = CGSize(width: frame.size.width / 6, height: frame.size.width / 6)
            let randX = CGFloat(arc4random_uniform(UInt32(frame.size.width - frame.size.width / 6))) + fallWithCoin.size.width / 2
            fallWithCoin.position = CGPoint(x: randX, y: frame.size.width / 6.0 / 2.0 * CGFloat(i + 2) + frame.size.height)
            fallWithCoinsY[i] = NSNumber(value: Float(fallWithCoin.position.y))

            let coinMaskDisplaySize = CGSize(width: fallWithCoin.size.width, height: size.height / 2 + (fallWithCoin.position.y - size.height))
            let coinMask = SKSpriteNode(color: .white, size: coinMaskDisplaySize)
            coinMask.anchorPoint = CGPoint(x: 0.5, y: 1.0)
            coinMask.position = fallWithCoin.position
            let coinCropNode = SKCropNode()
            coinCropNode.addChild(fallWithCoin)
            coinCropNode.maskNode = coinMask
            addChild(coinCropNode)

            fallWithCoins.append(fallWithCoin)
        }
    }

    private func winWithFallCoins() {
        DispatchQueue.global(qos: .default).async {
            isFocusStopFallWithCoinsRun = false

            let distanceYWithCoinFromScreenTop = self.frame.size.height / 2
            let distanceYForPerMove = -distanceYWithCoinFromScreenTop / 20.0

            self.run(SKAction.playSoundFileNamed("money.wav", waitForCompletion: false), withKey: "fallCoinSound")

            for j in 0..<self.fallWithCoins.count {
                let rotation = SKAction.repeat(SKAction.rotate(byAngle: 10, duration: 2.5), count: 3)
                let move = SKAction.repeat(SKAction.moveBy(x: 0, y: distanceYForPerMove * 3, duration: 0.22), count: 32)
                let end = SKAction.run {
                    let selectCoinImageView = self.fallWithCoins[j]
                    selectCoinImageView.isHidden = true
                    isFocusStopFallWithCoinsRun = false
                    selectCoinImageView.position = CGPoint(x: selectCoinImageView.position.x, y: CGFloat(truncating: self.fallWithCoinsY[j]))
                }
                self.fallWithCoins[j].run(SKAction.sequence([SKAction.group([rotation, move]), end]))
            }
        }
    }

    private func focusStopFallWithCoinsRun() {
        removeAction(forKey: "fallCoinSound")

        for j in 0..<fallWithCoins.count {
            let end = SKAction.run {
                let selectCoinImageView = self.fallWithCoins[j]
                selectCoinImageView.isHidden = false
                isFocusStopFallWithCoinsRun = false
                selectCoinImageView.position = CGPoint(x: selectCoinImageView.position.x, y: CGFloat(truncating: self.fallWithCoinsY[j]))
            }
            fallWithCoins[j].removeAllActions()
            fallWithCoins[j].run(end)
        }
    }

    private func costMoneyWithCurrentMoneyLevel() {
        currentMoney -= currentMoneyLevel
        let w = textViewCurrentMoney.frame.size.width
        textViewCurrentMoney.text = "\(currentMoney)"
        currentMoneyNode.position = CGPoint(x: currentMoneyNode.position.x - w / 2 + textViewCurrentMoney.frame.size.width / 2, y: currentMoneyNode.position.y)
        MyScene.saveMoney()
    }

    func addMoney(_ money: Int) {
        currentMoney += money
        let w = textViewCurrentMoney.frame.size.width
        textViewCurrentMoney.text = "\(currentMoney)"
        currentMoneyNode.position = CGPoint(x: currentMoneyNode.position.x - w / 2 + textViewCurrentMoney.frame.size.width / 2, y: currentMoneyNode.position.y)
        MyScene.saveMoney()
        reportScore()
    }

    private func makeUpMoney() {
        if commonUtil.isDuringOneDay {
            commonUtil.isDuringOneDay = false
            if currentMoney < moneyInitEveryday {
                currentMoney = moneyInitEveryday
                let w = textViewCurrentMoney.frame.size.width
                textViewCurrentMoney.text = "\(currentMoney)"
                currentMoneyNode.position = CGPoint(x: currentMoneyNode.position.x - w / 2 + textViewCurrentMoney.frame.size.width / 2, y: currentMoneyNode.position.y)
                MyScene.saveMoney()
                let alertView = UIAlertView(title: "", message: "Make up money to 5000.", delegate: nil, cancelButtonTitle: "OK")
                alertView.show()
            }
        }
    }

    private func displayAD() {
        showAdmob?()
    }

    private func displayBuyView() {
        showBuyViewController?()
    }

    static var moneyField: String { moneyFieldKey }
    static var moneyInit: Int { moneyInitValue }

    private func reportScore() {
        let gameCenterUtil = GameCenterUtil.shared
        gameCenterUtil.reportScore(Int64(currentMoney), forCategory: "com.irons.InfiniteSlotMoney")
    }

    override func update(_ currentTime: TimeInterval) {
        var timeSinceLast = currentTime - lastUpdateTimeInterval
        lastUpdateTimeInterval = currentTime
        if timeSinceLast > 1 {
            timeSinceLast = 1.0 / 60.0
            lastUpdateTimeInterval = currentTime
        }
        updateWithTimeSinceLastUpdate(timeSinceLast)
    }

    private func updateWithTimeSinceLastUpdate(_ timeSinceLast: TimeInterval) {
        lastSpawnTimeInterval += timeSinceLast
        if lastSpawnTimeInterval > 0.5 {
            lastSpawnTimeInterval = 0
            ccount += 1
            if ccount == 10 {
                _ = arc4random_uniform(40)
            }
        }
    }

    private func test() {
        reelPosition1 = 0
        reelPosition2 = 11
        reelPosition3 = 10
        labaStickNode.position = CGPoint(x: labaStickNode.position.x, y: CGFloat(reelPosition1) * eachFrameHeight + labaStickCropNodeMaskY)
        labaStickNode2.position = CGPoint(x: labaStickNode2.position.x, y: CGFloat(reelPosition2) * eachFrameHeight + labaStickCropNodeMaskY)
        labaStickNode3.position = CGPoint(x: labaStickNode3.position.x, y: CGFloat(reelPosition3) * eachFrameHeight + labaStickCropNodeMaskY)
    }
}
