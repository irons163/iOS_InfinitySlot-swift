import SpriteKit
import UIKit

final class TextureHelper {
    private static var hand1Textures: [SKTexture] = []
    private static var hand2Textures: [SKTexture] = []
    private static var hand3Textures: [SKTexture] = []
    private static var cat1Textures: [SKTexture] = []
    private static var cat2Textures: [SKTexture] = []
    private static var cat3Textures: [SKTexture] = []
    private static var cat4Textures: [SKTexture] = []
    private static var cat5Textures: [SKTexture] = []
    private static var hamsterInjureTexture: SKTexture?
    private static var bgTextures: [SKTexture] = []
    private static var timeTextures: [SKTexture] = []
    private static var timeImages: [UIImage] = []

    static func hand1TexturesArray() -> [SKTexture] { hand1Textures }
    static func hand2TexturesArray() -> [SKTexture] { hand2Textures }
    static func hand3TexturesArray() -> [SKTexture] { hand3Textures }
    static func cat1TexturesArray() -> [SKTexture] { cat1Textures }
    static func cat2TexturesArray() -> [SKTexture] { cat2Textures }
    static func cat3TexturesArray() -> [SKTexture] { cat3Textures }
    static func cat4TexturesArray() -> [SKTexture] { cat4Textures }
    static func cat5TexturesArray() -> [SKTexture] { cat5Textures }
    static func bgTexturesArray() -> [SKTexture] { bgTextures }
    static func timeTexturesArray() -> [SKTexture] { timeTextures }
    static func timeImagesArray() -> [UIImage] { timeImages }
    static func hamsterInjure() -> SKTexture? { hamsterInjureTexture }

    static func getTextures(withSpriteSheetNamed spriteSheet: String, sourceRect source: CGRect, rowNumberOfSprites: Int, colNumberOfSprites: Int) -> [SKTexture] {
        var frames: [SKTexture] = []
        let ssTexture = SKTexture(imageNamed: spriteSheet)
        ssTexture.filteringMode = .nearest

        var sx = source.origin.x
        var sy = source.origin.y
        let sWidth = source.size.width
        let sHeight = source.size.height

        for i in 0..<(rowNumberOfSprites * colNumberOfSprites) {
            let cutter = CGRect(x: sx, y: sy, width: sWidth / ssTexture.size().width, height: sHeight / ssTexture.size().height)
            let temp = SKTexture(rect: cutter, in: ssTexture)
            frames.append(temp)

            sx += sWidth / ssTexture.size().width
            if (i + 1) % colNumberOfSprites == 0 {
                sx = source.origin.x
                sy += sHeight / ssTexture.size().height
            }
        }
        return frames
    }

    static func getTextures(withSpriteSheetNamed spriteSheet: String, sourceRect source: CGRect, rowNumberOfSprites: Int, colNumberOfSprites: Int, sequence: [NSNumber]) -> [SKTexture] {
        guard let path = Bundle.main.path(forResource: spriteSheet, ofType: "png"),
              let image = UIImage(contentsOfFile: path) else {
            return []
        }
        let ssTexture = SKTexture(image: image)
        ssTexture.filteringMode = .nearest

        var frames: [SKTexture] = []
        var sx = source.origin.x
        var sy = source.origin.y
        let sWidth = source.size.width
        let sHeight = source.size.height

        for i in 0..<(rowNumberOfSprites * colNumberOfSprites) {
            let cutter = CGRect(x: sx, y: sy, width: sWidth / ssTexture.size().width, height: sHeight / ssTexture.size().height)
            let temp = SKTexture(rect: cutter, in: ssTexture)
            frames.append(temp)

            sx += sWidth / ssTexture.size().width
            if (i + 1) % colNumberOfSprites == 0 {
                sx = source.origin.x
                sy += sHeight / ssTexture.size().height
            }
        }

        var ordered: [SKTexture] = []
        for pos in sequence {
            let idx = pos.intValue
            if idx >= 0 && idx < frames.count {
                ordered.append(frames[idx])
            }
        }
        return ordered
    }

    static func initHandTextures(sourceRect source: CGRect, rowNumberOfSprites: Int, colNumberOfSprites: Int) {
        hand1Textures = getTextures(withSpriteSheetNamed: "hand1", sourceRect: source, rowNumberOfSprites: rowNumberOfSprites, colNumberOfSprites: colNumberOfSprites)
        hand2Textures = getTextures(withSpriteSheetNamed: "hand2", sourceRect: source, rowNumberOfSprites: rowNumberOfSprites, colNumberOfSprites: colNumberOfSprites)
        hand3Textures = getTextures(withSpriteSheetNamed: "hand3", sourceRect: source, rowNumberOfSprites: rowNumberOfSprites, colNumberOfSprites: colNumberOfSprites)
    }

    static func initCatTextures() {
        cat1Textures = [SKTexture(imageNamed: "cat01_1"), SKTexture(imageNamed: "cat01_2"), SKTexture(imageNamed: "cat01_3"), SKTexture(imageNamed: "cat01_4")]
        cat2Textures = [SKTexture(imageNamed: "cat02_1"), SKTexture(imageNamed: "cat02_2"), SKTexture(imageNamed: "cat02_3"), SKTexture(imageNamed: "cat02_4")]
        cat3Textures = [SKTexture(imageNamed: "cat03_1"), SKTexture(imageNamed: "cat03_2"), SKTexture(imageNamed: "cat03_3"), SKTexture(imageNamed: "cat03_4")]
        cat4Textures = [SKTexture(imageNamed: "cat04_1"), SKTexture(imageNamed: "cat04_2"), SKTexture(imageNamed: "cat04_3"), SKTexture(imageNamed: "cat04_4")]
        cat5Textures = [SKTexture(imageNamed: "cat05_1"), SKTexture(imageNamed: "cat05_2"), SKTexture(imageNamed: "cat05_3"), SKTexture(imageNamed: "cat05_4")]
    }

    static func initTextures() {
        hamsterInjureTexture = SKTexture(imageNamed: "hamster_injure")

        let time01 = SKTexture(imageNamed: "s1")
        let time02 = SKTexture(imageNamed: "s2")
        let time03 = SKTexture(imageNamed: "s3")
        let time04 = SKTexture(imageNamed: "s4")
        let time05 = SKTexture(imageNamed: "s5")
        let time06 = SKTexture(imageNamed: "s6")
        let time07 = SKTexture(imageNamed: "s7")
        let time08 = SKTexture(imageNamed: "s8")
        let time09 = SKTexture(imageNamed: "s9")
        let time00 = SKTexture(imageNamed: "s0")
        let timeQ = SKTexture(imageNamed: "dot")
        timeTextures = [time00, time01, time02, time03, time04, time05, time06, time07, time08, time09, timeQ]

        let image01 = UIImage(named: "s1")
        let image02 = UIImage(named: "s2")
        let image03 = UIImage(named: "s3")
        let image04 = UIImage(named: "s4")
        let image05 = UIImage(named: "s5")
        let image06 = UIImage(named: "s6")
        let image07 = UIImage(named: "s7")
        let image08 = UIImage(named: "s8")
        let image09 = UIImage(named: "s9")
        let image00 = UIImage(named: "s0")
        let imageQ = UIImage(named: "dot")
        timeImages = [image00, image01, image02, image03, image04, image05, image06, image07, image08, image09, imageQ].compactMap { $0 }

        bgTextures = [
            SKTexture(imageNamed: "bg01.jpg"),
            SKTexture(imageNamed: "bg02.jpg"),
            SKTexture(imageNamed: "bg03.jpg"),
            SKTexture(imageNamed: "bg04.jpg"),
            SKTexture(imageNamed: "bg05.jpg"),
            SKTexture(imageNamed: "bg06.jpg"),
            SKTexture(imageNamed: "bg07.jpg"),
            SKTexture(imageNamed: "bg08.jpg"),
            SKTexture(imageNamed: "bg09.jpg"),
            SKTexture(imageNamed: "bg10.jpg"),
            SKTexture(imageNamed: "bg11.jpg"),
            SKTexture(imageNamed: "bg12.jpg"),
            SKTexture(imageNamed: "bg13.jpg"),
            SKTexture(imageNamed: "bg14.jpg"),
            SKTexture(imageNamed: "bg15.jpg")
        ]
    }
}
