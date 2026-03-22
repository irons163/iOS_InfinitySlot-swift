import StoreKit
import UIKit

final class BuyViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    weak var viewController: ViewController?

    @IBOutlet private weak var item5000Label: UILabel!
    @IBOutlet private weak var item30000Label: UILabel!
    @IBOutlet private weak var item65000Label: UILabel!
    @IBOutlet private weak var item175000Label: UILabel!
    @IBOutlet private weak var item375000Label: UILabel!
    @IBOutlet private weak var item850000Label: UILabel!
    @IBOutlet private weak var item850000RemoveAdLabel: UILabel!
    @IBOutlet private weak var restoreBtn: UIButton!
    @IBOutlet private weak var buy5000Btn: UIButton!
    @IBOutlet private weak var buy850000Btn: UIButton!

    private var areAdsRemoved = false
    private var currentClick = 0

    private let clickRestorebtn = -1
    private let click5000btn = 0
    private let click30000btn = 1
    private let click65000btn = 2
    private let click175000btn = 3
    private let click375000btn = 4
    private let click850000btn = 5

    private let kFirst5000RemoveAdsProductIdentifier = "com.irons.infinity.Firstcoin5000AndRemoveAds"
    private let kFirst30000RemoveAdsProductIdentifier = "com.irons.infinity.Firstcoin30000AndRemoveAds"
    private let kFirst65000RemoveAdsProductIdentifier = "com.irons.infinity.Firstcoin65000AndRemoveAds"
    private let kFirst175000RemoveAdsProductIdentifier = "com.irons.infinity.Firstcoin175000AndRemoveAds"
    private let kFirst375000RemoveAdsProductIdentifier = "com.irons.infinity.Firstcoin375000AndRemoveAds"
    private let kFirst850000RemoveAdsProductIdentifier = "com.irons.infinity.Firstcoin850000AndRemoveAds"

    private let k5000RemoveAdsProductIdentifier = "com.irons.infinity.coin5000AndRemoveAds"
    private let k30000RemoveAdsProductIdentifier = "com.irons.infinity.coin30000AndRemoveAds"
    private let k65000RemoveAdsProductIdentifier = "com.irons.infinity.coin65000AndRemoveAds"
    private let k175000RemoveAdsProductIdentifier = "com.irons.infinity.coin175000AndRemoveAds"
    private let k375000RemoveAdsProductIdentifier = "com.irons.infinity.coin375000AndRemoveAds"
    private let k850000RemoveAdsProductIdentifier = "com.irons.infinity.coin850000AndRemoveAds"

    private let k6000RemoveAdsProductIdentifier = "com.irons.infinity.coin6000"
    private let k35000RemoveAdsProductIdentifier = "com.irons.infinity.coin35000"
    private let k85000RemoveAdsProductIdentifier = "com.irons.infinity.coin85000"
    private let k225000RemoveAdsProductIdentifier = "com.irons.infinity.coin225000"
    private let k500000RemoveAdsProductIdentifier = "com.irons.infinity.coin500000"

    override func viewDidLoad() {
        super.viewDidLoad()

        if item5000Label == nil {
            configureFallbackUI()
            return
        }

        if !CommonUtil.shared.isFreeVersion {
            item5000Label.text = NSLocalizedString("get6000Coin", comment: "")
            item30000Label.text = NSLocalizedString("get35000Coin", comment: "")
            item65000Label.text = NSLocalizedString("get85000Coin", comment: "")
            item175000Label.text = NSLocalizedString("get225000Coin", comment: "")
            item375000Label.text = NSLocalizedString("get500000Coin", comment: "")
            item850000Label.isHidden = true
            item850000RemoveAdLabel.isHidden = true
            buy850000Btn.isHidden = true
            restoreBtn.isHidden = true
        }

        SKPaymentQueue.default().add(self)
    }

    private func configureFallbackUI() {
        view.backgroundColor = .white

        let titleLabel = UILabel()
        titleLabel.text = "Shop"
        titleLabel.textColor = .black
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let backButton = UIButton(type: .system)
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(.black, for: .normal)
        backButton.addTarget(self, action: #selector(backBtn(_:)), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        func makeRow(title: String, tag: Int) -> (UILabel, UIButton) {
            let label = UILabel()
            label.text = title
            label.textColor = .darkGray
            label.font = UIFont.systemFont(ofSize: 15, weight: .regular)

            let button = UIButton(type: .system)
            button.setTitle("Buy", for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.black.cgColor
            button.layer.cornerRadius = 6
            button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
            button.tag = tag
            button.addTarget(self, action: #selector(handleBuyButton(_:)), for: .touchUpInside)

            let row = UIStackView(arrangedSubviews: [label, UIView(), button])
            row.axis = .horizontal
            row.alignment = .center
            stack.addArrangedSubview(row)
            return (label, button)
        }

        let row5000 = makeRow(title: "Get 5000 Coins", tag: click5000btn)
        let row30000 = makeRow(title: "Get 30000 Coins", tag: click30000btn)
        let row65000 = makeRow(title: "Get 65000 Coins", tag: click65000btn)
        let row175000 = makeRow(title: "Get 175000 Coins", tag: click175000btn)
        let row375000 = makeRow(title: "Get 375000 Coins", tag: click375000btn)
        let row850000 = makeRow(title: "Get 850000 Coins + Remove Ads", tag: click850000btn)

        let restoreButton = UIButton(type: .system)
        restoreButton.setTitle("Restore", for: .normal)
        restoreButton.setTitleColor(.black, for: .normal)
        restoreButton.layer.borderWidth = 1
        restoreButton.layer.borderColor = UIColor.black.cgColor
        restoreButton.layer.cornerRadius = 6
        restoreButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
        restoreButton.addTarget(self, action: #selector(restore), for: .touchUpInside)
        restoreButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)
        view.addSubview(backButton)
        view.addSubview(stack)
        view.addSubview(restoreButton)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            restoreButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            restoreButton.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 20)
        ])

        item5000Label = row5000.0
        item30000Label = row30000.0
        item65000Label = row65000.0
        item175000Label = row175000.0
        item375000Label = row375000.0
        item850000Label = row850000.0
        item850000RemoveAdLabel = UILabel()
        buy5000Btn = row5000.1
        buy850000Btn = row850000.1
        restoreBtn = restoreButton
    }

    @objc private func handleBuyButton(_ sender: UIButton) {
        currentClick = sender.tag
        tapsRemoveAdsButton()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SKPaymentQueue.default().remove(self)
    }

    @IBAction private func tapsRemoveAdsButton() {
        if SKPaymentQueue.canMakePayments() {
            if CommonUtil.shared.isFreeVersion {
                doRestore()
            } else {
                guard let productId = productIdentifierForCurrentClick() else { return }
                let productsRequest = SKProductsRequest(productIdentifiers: [productId])
                productsRequest.delegate = self
                productsRequest.start()
            }
        } else {
            NSLog("User cannot make payments due to parental controls")
        }
    }

    @IBAction private func backBtn(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if let validProduct = response.products.first {
            NSLog("Products Available!")
            purchase(validProduct)
        } else {
            NSLog("No products available")
        }
    }

    private func purchase(_ product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(payment)
    }

    @IBAction private func restore() {
        currentClick = clickRestorebtn
        doRestore()
    }

    private func doRestore() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        NSLog("received fial restored transactions: %d", queue.transactions.count)
    }

    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        NSLog("received restored transactions: %d", queue.transactions.count)

        if currentClick == clickRestorebtn {
            for transaction in queue.transactions where transaction.transactionState == .restored {
                NSLog("Transaction state -> Restored")
                doRemoveAds()
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            }
            return
        }

        if queue.transactions.isEmpty && !CommonUtil.shared.isPurchased {
            guard let productId = firstPurchaseIdentifierForCurrentClick() else { return }
            let productsRequest = SKProductsRequest(productIdentifiers: [productId])
            productsRequest.delegate = self
            productsRequest.start()
        } else {
            for transaction in queue.transactions where transaction.transactionState == .restored {
                NSLog("Transaction state -> Restored")
                doRemoveAds()
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            }

            if !CommonUtil.shared.isFreeVersion {
                guard let productId = repeatPurchaseIdentifierForCurrentClick() else { return }
                let productsRequest = SKProductsRequest(productIdentifiers: [productId])
                productsRequest.delegate = self
                productsRequest.start()
            }
        }
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                NSLog("Transaction state -> Purchasing")
            case .purchased:
                doRemoveAds()
                checkMoneyAndAdd(transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
                NSLog("Transaction state -> Purchased")
            case .restored:
                NSLog("Transaction state -> Restored")
                SKPaymentQueue.default().finishTransaction(transaction)
            case .failed:
                if let error = transaction.error as NSError?, error.code == SKError.paymentCancelled.rawValue {
                    NSLog("Transaction state -> Cancelled")
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            case .deferred:
                break
            @unknown default:
                break
            }
        }
    }

    private func doRemoveAds() {
        viewController?.removeAd()

        areAdsRemoved = true
        restoreBtn.isHidden = true
        restoreBtn.isEnabled = false

        UserDefaults.standard.set(areAdsRemoved, forKey: "areAdsRemoved")
        UserDefaults.standard.set(areAdsRemoved, forKey: "isPurchased")
        UserDefaults.standard.synchronize()

        CommonUtil.shared.isPurchased = true
    }

    private func checkMoneyAndAdd(_ transaction: SKPaymentTransaction) {
        let productId = transaction.payment.productIdentifier
        if !CommonUtil.shared.isFreeVersion {
            if productId == k6000RemoveAdsProductIdentifier {
                addMoney(6000)
            } else if productId == k35000RemoveAdsProductIdentifier {
                addMoney(35000)
            } else if productId == k85000RemoveAdsProductIdentifier {
                addMoney(85000)
            } else if productId == k225000RemoveAdsProductIdentifier {
                addMoney(225000)
            } else if productId == k500000RemoveAdsProductIdentifier {
                addMoney(500000)
            }
        } else {
            if productId == kFirst5000RemoveAdsProductIdentifier || productId == k5000RemoveAdsProductIdentifier {
                addMoney(6000)
            } else if productId == kFirst30000RemoveAdsProductIdentifier || productId == k30000RemoveAdsProductIdentifier {
                addMoney(35000)
            } else if productId == kFirst65000RemoveAdsProductIdentifier || productId == k65000RemoveAdsProductIdentifier {
                addMoney(85000)
            } else if productId == kFirst175000RemoveAdsProductIdentifier || productId == k175000RemoveAdsProductIdentifier {
                addMoney(225000)
            } else if productId == kFirst375000RemoveAdsProductIdentifier || productId == k375000RemoveAdsProductIdentifier {
                addMoney(500000)
            }
        }
    }

    private func addMoney(_ money: Int) {
        viewController?.addMoney(money)
    }

    @IBAction private func buy5000Click(_ sender: Any) {
        currentClick = click5000btn
        tapsRemoveAdsButton()
    }

    @IBAction private func buy30000Click(_ sender: Any) {
        currentClick = click30000btn
        tapsRemoveAdsButton()
    }

    @IBAction private func buy65000Click(_ sender: Any) {
        currentClick = click65000btn
        tapsRemoveAdsButton()
    }

    @IBAction private func buy175000Click(_ sender: Any) {
        currentClick = click175000btn
        tapsRemoveAdsButton()
    }

    @IBAction private func buy375000Click(_ sender: Any) {
        currentClick = click375000btn
        tapsRemoveAdsButton()
    }

    @IBAction private func buy850000Click(_ sender: Any) {
        currentClick = click850000btn
        tapsRemoveAdsButton()
    }

    private func productIdentifierForCurrentClick() -> String? {
        if currentClick == click5000btn { return k6000RemoveAdsProductIdentifier }
        if currentClick == click30000btn { return k35000RemoveAdsProductIdentifier }
        if currentClick == click65000btn { return k85000RemoveAdsProductIdentifier }
        if currentClick == click175000btn { return k225000RemoveAdsProductIdentifier }
        if currentClick == click375000btn { return k500000RemoveAdsProductIdentifier }
        return nil
    }

    private func firstPurchaseIdentifierForCurrentClick() -> String? {
        if currentClick == click5000btn { return kFirst5000RemoveAdsProductIdentifier }
        if currentClick == click30000btn { return kFirst30000RemoveAdsProductIdentifier }
        if currentClick == click65000btn { return kFirst65000RemoveAdsProductIdentifier }
        if currentClick == click175000btn { return kFirst175000RemoveAdsProductIdentifier }
        if currentClick == click375000btn { return kFirst375000RemoveAdsProductIdentifier }
        if currentClick == click850000btn { return kFirst850000RemoveAdsProductIdentifier }
        return nil
    }

    private func repeatPurchaseIdentifierForCurrentClick() -> String? {
        if currentClick == click5000btn { return k5000RemoveAdsProductIdentifier }
        if currentClick == click30000btn { return k30000RemoveAdsProductIdentifier }
        if currentClick == click65000btn { return k65000RemoveAdsProductIdentifier }
        if currentClick == click175000btn { return k175000RemoveAdsProductIdentifier }
        if currentClick == click375000btn { return k375000RemoveAdsProductIdentifier }
        if currentClick == click850000btn { return k850000RemoveAdsProductIdentifier }
        return nil
    }
}
