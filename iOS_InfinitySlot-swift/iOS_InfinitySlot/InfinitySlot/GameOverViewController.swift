import MessageUI
import UIKit

protocol BviewControllerDelegate: AnyObject {
    func bviewcontrollerDidTapButton()
    func bviewcontrollerDidTapBackToMenuButton()
}

final class GameOverViewController: UIViewController, MFMailComposeViewControllerDelegate {
    var gameLevel: Int = 0
    var gameTime: Int = 0

    @IBOutlet private weak var gameLevelTensDigitalLabel: UIImageView!
    @IBOutlet private weak var gameLevelSingleDigital: UIImageView!
    @IBOutlet private weak var gameTimeMinuteTensDigitalLabel: UIImageView!
    @IBOutlet private weak var gameTimeMinuteSingleDigitalLabel: UIImageView!
    @IBOutlet private weak var gameTimeSecondTensDigitalLabel: UIImageView!
    @IBOutlet private weak var gameTimeSecondSingleDigitalLabel: UIImageView!
    @IBOutlet private weak var animationImageView: UIImageView!

    weak var delegate: BviewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        gameLevelTensDigitalLabel.image = getNumberImage((gameLevel + 1) / 10)
        gameLevelSingleDigital.image = getNumberImage((gameLevel + 1) % 10)

        gameTimeMinuteTensDigitalLabel.image = getNumberImage(gameTime / 60 / 10)
        gameTimeMinuteSingleDigitalLabel.image = getNumberImage(gameTime / 60 % 10)
        gameTimeSecondTensDigitalLabel.image = getNumberImage(gameTime % 60 / 10)
        gameTimeSecondSingleDigitalLabel.image = getNumberImage(gameTime % 60 % 10)

        let frames = (1...21).compactMap { UIImage(named: String(format: "m%02d", $0)) }.map { prerender($0) }
        animationImageView.animationImages = frames
        animationImageView.animationDuration = 2.0
        animationImageView.animationRepeatCount = 1
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
        animationImageView.image = animationImageView.animationImages?.last
        animationImageView.startAnimating()
    }

    @IBAction private func restartGameClick(_ sender: Any) {
        dismiss(animated: true) { [weak self] in
            self?.delegate?.bviewcontrollerDidTapButton()
        }
    }

    @IBAction private func backToMainMenuClick(_ sender: Any) {
        dismiss(animated: true) { [weak self] in
            self?.delegate?.bviewcontrollerDidTapBackToMenuButton()
        }
    }

    @IBAction private func giftClick(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let picker = MFMailComposeViewController()
            picker.mailComposeDelegate = self
            picker.setToRecipients(["app@engeniuscloud.com"])
            picker.setSubject("Feedback to EnGenius EnShare APP")
            picker.setMessageBody("hello", isHTML: true)
            present(picker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(
                title: "Failure",
                message: "Your device doesn't support the composer sheet. Make sure you set up an account for send email.Be  careful, Do Not close the  prize page after you send  the email. Otherwise, you  lost the prize.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }

    @IBAction private func backClick(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }

    private func getNumberImage(_ number: Int) -> UIImage? {
        let images = TextureHelper.timeImagesArray()
        if number >= 0 && number < images.count {
            return images[number]
        }
        return nil
    }

    private func prerender(_ frameImage: UIImage) -> UIImage {
        UIGraphicsBeginImageContext(frameImage.size)
        frameImage.draw(in: CGRect(origin: .zero, size: frameImage.size))
        let renderedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return renderedImage ?? frameImage
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
